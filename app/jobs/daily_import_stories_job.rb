class DailyImportStoriesJob < ActiveJob::Base
  queue_as :default

  def perform()
    Integration.where(kind: 'jira').each do |integration|
      client = integration.initialize_jira_client
      integration.initialize_jira_stories(client, [])
    end
  end
  
end