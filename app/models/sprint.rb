class Sprint < ActiveRecord::Base
  belongs_to :board

  def self.import_sprints(integration, project, board)
    sprints = JSON.parse(HTTP.basic_auth(user: integration.auth_info["jira_username"], pass: integration.auth_info["jira_password"]).get("https://#{integration.site_url}/rest/agile/1.0/board/#{board.external_id}/sprint").body.readpartial)
    begin
      sprints["values"].each do |sprint|
        new_sprint = board.sprints.find_or_initialize_by(external_id: sprint["id"])
        new_sprint.name = sprint["name"]
        new_sprint.start_date = DateTime.parse(sprint["startDate"])
        new_sprint.end_date = DateTime.parse(sprint["endDate"])
        if new_sprint.changed?
          new_sprint.save()
        end
      end
    rescue
    end
  end

  def calculate_sprint_stats
    board = self.board
    project = board.project
    integration = project.integrations.first
    client = integration.initialize_jira_client
    issues = self.get_sprint_issues(integration, project, board)
    puts "These are the issues\n#{issues}"
    self.calculate_recidivism_rate(board, client, integration, project, issues.values_at("story", "task", "story task", "sub-task", "story-task").flatten()) #Story and Task specify what kind of issues are taken into account for recidivism rate
    self.recidivism_rate = nil if self.recidivism_rate.nan?
    self.calculate_comments(issues.values_at("story").flatten()) 
    self.calculate_bug_count(project)
    self.calculate_bug_count_long(project)
    self.calculate_velocity(project)
    self.save if self.changed?
  end

  def calculate_recidivism_rate(board, client, integration, project, issues)
    status_hash = board.parse_board_status(integration, project)
    forward = 0.0
    backward = 0.0
    issues.each do |story|
      jira_issue = client.Issue.find(story, expand: 'changelog')
      issue_changelog = jira_issue.attrs["changelog"]["histories"]
      issue_changelog.each do |history|
        history["items"].each do |item|
          if item["field"] == 'status'
            from = status_hash[item['fromString'].downcase] || -1
            to   = status_hash[item['toString'].downcase]   || -1
            if from == -1 || to == -1
              puts "Date: #{history['created']} From: #{item['fromString']} To: #{item['toString']} "
            elsif from < to
              forward += (to-from)
            elsif from > to
              backward += (from-to)
            end
          end
        end
      end
    end
    self.recidivism_rate = (backward/(forward+backward)*100)
  end

  def calculate_comments(stories)
    comments = 0
    stories.each do |s|
      story = Story.find_by_external_id(s)
      begin
        comments += Comment.where(story_id: story.id, defect: nil).count
      rescue
      end
    end
    self.comment_count = comments
  end

  def calculate_bug_count(project)
    self.bug_count = Issue.where(kind: 'Bug', project_id: project.id, jira_create: self.start_date..self.end_date).count
  end

  def calculate_bug_count_long(project)
    sprint_length = self.end_date - self.start_date
    self.bug_count_long = Issue.where(kind: 'Bug', project_id: project.id, jira_create: self.end_date..self.end_date+(sprint_length*2)).count
  end

  def calculate_velocity(project)
    self.velocity = Issue.where(kind: ['Story', 'Task'], project_id: project.id, jira_resolve: self.start_date..self.end_date).sum('story_points')
  end

  def get_sprint_issues(integration, project, board)
    body = HTTP.basic_auth(user: integration.auth_info["jira_username"], pass: integration.auth_info["jira_password"]).headers('Content-Type' => 'application/json').get("https://#{integration.site_url}/rest/agile/1.0/board/#{board.external_id}/sprint/#{self.external_id}/issue", params: { fields: "summary, issuetype", expand: "changelog", maxResults: 1000} ).body
    sprint_issues = JSON.parse(Project.parse_http_body(body))
    stories = []
    bugs = []
    issues = Hash.new{ |issues,k| issues[k]=[] }
    f = sprint_issues["issues"].map { |i| [i["fields"]["issuetype"]["name"].downcase, i["id"]] }
    f.each{ |k,v| issues[k] << v }
    return issues
  end
end
