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

  def calculate_sprint_stats(integration, project, board)
    client = integration.initialize_jira_client
    stories = self.get_sprint_stories(integration, project, board)
    if self.recidivism_rate.nil? or self.recidivism_rate.nan? or self.end_date > (Date.today-30)
      self.calculate_recidivism_rate(board, client, integration, project, stories)
      self.recidivism_rate = nil if self.recidivism_rate.nan?
    end
    self.calculate_comments(client, stories) if self.end_date > (Date.today-30)
    self.save if self.changed?
  end

  def calculate_recidivism_rate(board, client, integration, project, stories)
    status_hash = board.parse_board_status(integration, project)
    forward = 0.0
    backward = 0.0
    stories.each do |story|
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

  def calculate_comments(client, stories)
    comments = 0
    stories.each { |s| comments += Comment.where(external_id: s, defect: nil).count }
    self.comment_count = comments
  end

  def get_sprint_stories(integration, project, board)
    body = HTTP.basic_auth(user: integration.auth_info["jira_username"], pass: integration.auth_info["jira_password"]).headers('Content-Type' => 'application/json').get("https://#{integration.site_url}/rest/agile/1.0/board/#{board.external_id}/sprint/#{self.external_id}/issue", params: { fields: "summary, issuetype", expand: "changelog", maxResults: 1000} ).body
    sprint_issues = JSON.parse(Project.parse_http_body(body))
    issues = []
    sprint_issues["issues"].each do |sprint_issue|
      if sprint_issue["fields"]["issuetype"]["name"].in?(['Story', project.custom_issue_type])
        issues.append(sprint_issue["id"])
      end
    end
    return issues
  end
end
