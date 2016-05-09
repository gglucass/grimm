class DailyImportStoriesJob < ActiveJob::Base
  queue_as :default

  def perform()
    integrations = Integration.get_all_integrations()
    integrations.each do |integration|
      client = integration.initialize_jira_client
      begin
        integration.initialize_jira_stories(client, [])
      rescue
      end
    end
  end
  
end