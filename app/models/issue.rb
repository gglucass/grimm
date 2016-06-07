class Issue < ActiveRecord::Base
  belongs_to :project

  def self.import_issues(integration, project, jql)
    client = integration.initialize_jira_client
    field_name = integration.get_user_story_point_field_name
    continue = true
    start_at = 0
    while continue
      issues = client.Issue.jql(jql, start_at: start_at, max_results: 100)
      continue = issues.count == 100
      start_at += 100
      issues.each do |issue|
        new_issue = Issue.find_or_initialize_by(external_id: issue.id, project_id: project.id)
        new_issue.title = issue.summary
        new_issue.kind = issue.issuetype.name
        new_issue.status = issue.status.name
        new_issue.story_points = issue.attrs['fields'][field_name]
        new_issue.jira_create = issue.created
        new_issue.jira_update = issue.updated
        new_issue.jira_resolve = issue.resolutiondate
        new_issue.save if new_issue.changed?
      end
    end
  end

end
