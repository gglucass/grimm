class Issue < ActiveRecord::Base
  belongs_to :project

  def self.import_issues(integration, project, jql)
    client = integration.initialize_jira_client
    issues = client.Issue.jql(jql)
    issues.each do |issue|
      new_issue = Issue.find_or_initialize_by(external_id: issue.id, project_id: project.id)
      new_issue.title = issue.summary
      new_issue.kind = issue.issuetype.name
      new_issue.status = issue.status.name
      new_issue.story_points = issue.attrs['fields']['customfield_10022']
      new_issue.jira_create = issue.created
      new_issue.jira_update = issue.updated
      new_issue.jira_resolve = issue.resolutiondate
      new_issue.save if new_issue.changed?
    end
  end
end
