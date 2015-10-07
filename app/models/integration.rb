class Integration < ActiveRecord::Base
  # kind, auth_info
  belongs_to :user
  serialize :auth_info
  after_create :sync_integration

  def sync_integration
    eval("self.initialize_#{self.kind}")
  end

  def initialize_pivotal
    client = TrackerApi::Client.new(token: self.auth_info)
    
    client.projects.each do |project|
      new_project = Project.find_or_create_by(external_id: project.id, kind: self.kind)
      new_project.name ||= project.name
      new_project.users << user
      new_project.save
      project.stories.each do |story|
        new_project.stories.find_or_create_by(external_id: story.id, title: story.name)
      end
      sleep 1.5
      new_project.analyze()
      self.create_pivotal_webhook(new_project)
    end
    return self.user.projects
  end

  def initialize_jira
    options = {
      site: self.auth_info["jira_url"],
      context_path: '',
      auth_type: :basic,
      username: self.auth_info["jira_username"],
      password: self.auth_info["jira_password"]
    }
    client = JIRA::Client.new(options)
    client.Project.all.each do |project|
      new_project = Project.find_or_create_by(external_id: project.id, kind: self.kind)
      new_project.name ||= project.name
      new_project.users << user
      new_project.save
      project.issues.each do |issue|
        new_project.stories.find_or_create_by(external_id: issue.id, title: issue.summary)
      end
      sleep 1.5
      new_project.analyze()
    end
    return self.user.projects
  end

  def create_pivotal_webhook(project)
    HTTP.headers('X-TrackerToken' => self.auth_info).post("https://www.pivotaltracker.com/services/v5/projects/#{project.external_id}/webhooks", form: {webhook_url: "#{ENV["HOSTNAME"]}/webhook", webhook_version: "v5"} )
  end
end
