class Integration < ActiveRecord::Base
  # kind, auth_info
  has_paper_trail
  belongs_to :user
  has_and_belongs_to_many :projects, -> { uniq }
  serialize :auth_info
  after_create :sanitize_site_url
  after_create :create_jira_webhook
  after_commit :sync_integration
  before_destroy :remove_user_from_projects

  def sanitize_site_url
    self.update_attribute(:site_url, URI.parse(self.site_url).host)
  end

  def sync_integration
    eval("self.initialize_#{self.kind}")
  end

  def initialize_pivotal
    client = TrackerApi::Client.new(token: self.auth_info)
    projects = []
    client.projects.each do |project|
      new_project = Project.find_or_create_by(external_id: project.id, kind: self.kind)
      new_project.name ||= project.name
      new_project.users += [user]
      new_project.integrations += [self]
      new_project.save()
      project.stories.each do |story|
        new_project.stories.find_or_create_by(external_id: story.id, title: story.name)
      end
      projects << new_project
      self.create_pivotal_webhook(new_project)
    end
    projects.each { |p| p.reload.analyze(first_analysis: true) }
    return self.user.projects
  end

  def initialize_jira
    InitializeJiraJob.perform_later(self)
  end

  def initialize_jira_projects(client)
    new_projects = []
    client.Project.all.each do |jira_project|
      new_project = Project.find_or_initialize_by(external_id: jira_project.id, kind: self.kind, site_url: URI.parse(client.options[:site]).host)
      new_project.name ||= jira_project.name
      new_project.users += [self.user]
      new_project.integrations += [self]
      new_record_project = new_project.new_record?
      new_project.save()
      if new_record_project
        new_projects << new_project.reload
      end
    end
    return new_projects
  end

  def initialize_jira_stories(client, new_projects)
    self.projects.each do |project|
      jira_project = client.Project.find(project.external_id)
      project.name = jira_project.name
      continue = true
      start_at = 0
      new_stories = []
      while continue
        issues = jira_project.issues(startAt: start_at, maxResults: 100)
        selected_issues = issues.select { |i| i.issuetype.name.in?(['Story', project.custom_issue_type]) }
        continue = issues.count == 100
        start_at += 100
        selected_issues.each do |issue|
          new_story = project.stories.find_or_initialize_by(external_id: issue.id, title: issue.summary) 
          if new_story.new_record?
            new_stories << new_story
            new_story.save()
          end
          new_story.update_attributes(priority: issue.priority.name, status: issue.status.name, comments_json: issue.comments.to_json, 
            description: issue.description, external_key: issue.key)
          if issue.try(:customfield_10008)
            new_story.update_attributes(estimation: issue.customfield_10008)
          end
        end
      end
      if new_projects.exclude?(project)
        new_stories.each do |story|
          story.analyze()
        end
      end
    end
  end

  def test_while
    start_at = 1
    continue = true
    while continue
      puts start_at
      start_at += 1
      continue = start_at < 5
    end
  end

  def initialize_jira_client
    options = {
      site: 'https://' + self.site_url,
      context_path: self.auth_info["context_path"] || '',
      auth_type: :basic,
      username: self.auth_info["jira_username"],
      password: self.auth_info["jira_password"]
    }    
    return JIRA::Client.new(options)
  end

    def get_user_story_point_field_name
      fields = JSON.parse(HTTP.basic_auth(user: self.auth_info["jira_username"], pass: self.auth_info["jira_password"]).get("https://#{self.site_url_full}/rest/api/2/field").body.readpartial)
      fields.keep_if { |f| f["name"].downcase() == "story points" }
      return fields.first["id"]
    end

  def create_pivotal_webhook(project)
    HTTP.headers('X-TrackerToken' => self.auth_info).post("https://www.pivotaltracker.com/services/v5/projects/#{project.external_id}/webhooks", form: {webhook_url: "#{ENV["HOSTNAME"]}/webhook", webhook_version: "v5"} )
  end

  def create_jira_webhook
    if self.kind == 'jira' and Integration.where(site_url: self.site_url).count <= 1
      begin
        HTTP.basic_auth(:user => self.auth_info['jira_username'], :pass => self.auth_info['jira_password']).headers('Content-Type' => 'application/json').post("https://#{self.site_url_full}/rest/webhooks/1.0/webhook", json: { name: 'AQUSA webhook', 
          url: "#{ENV["HOSTNAME"]}/webhook", 
          events: ["jira:issue_created", "jira:issue_updated", "jira:issue_deleted", "jira:worklog_updated",
                "sprint_created", "sprint_updated", "sprint_deleted", "sprint_started", "sprint_closed",
                "board_created", "board_updated", "board_deleted", "board_configuration_changed",
                "project_created", "project_updated", "project_deleted"],
          jqlFilter: "", 
          excludeIssueDetails: false})
      rescue
      end
    end
  end

  def remove_user_from_projects
    self.projects.each do |project|
      project.users -= [self.user]
      if project.users.count == 0
        project.destroy()
      end
    end
  end

  def self.get_all_integrations
    if ENV["HOSTNAME"] == "https://aqusa-coolblue.science.uu.nl"
      integrations = Integration.where(kind: 'jira', site_url: 'jira.coolblue.eu')
    else
      integrations = Integration.where(kind: 'jira').where.not(site_url: ['jira.coolblue.eu', 'jira.isatis.nl'])
    end
    return integrations
  end

  def site_url_full
    self.site_url + (self.auth_info['context_path'] || '')
  end
end
