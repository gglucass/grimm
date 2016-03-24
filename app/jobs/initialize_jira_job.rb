class InitializeJiraJob < ActiveJob::Base
  queue_as :default

  def perform(integration)
    client = integration.initialize_jira_client()
    new_projects = integration.initialize_jira_projects(client)
    integration.initialize_jira_stories(client, new_projects)
    new_projects.each do |project|
      project.analyze()
    end
  end
end