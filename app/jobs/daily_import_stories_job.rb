class DailyImportStoriesJob < ActiveJob::Base
  queue_as :default

  def perform()
    if ENV["HOSTNAME"] == "https://aqusa-coolblue.science.uu.nl"
      integrations = Integration.where(kind: 'jira', site_url: 'jira.coolblue.eu')
    else
      integrations = Integration.where(kind: 'jira').where.not(site_url: 'jira.coolblue.eu')
    end
    integrations.each do |integration|
      client = integration.initialize_jira_client
      integration.initialize_jira_stories(client, [])
    end
  end
  
end