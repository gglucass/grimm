class Integration < ActiveRecord::Base
  # kind, auth_info
  belongs_to :user
  serialize :auth_info
  after_create :sync_integration


  def process_pivotal_webhook(data)
  end

  def sync_integration
    eval("self.initialize_#{self.kind}")
  end

  def initialize_pivotal
    client = TrackerApi::Client.new(token: self.auth_info)
    
    client.projects.each do |project|
      new_project = Project.find_or_create_by(external_id: project.id)
      new_project.name ||= project.name
      new_project.users << user
      new_project.save
      project.stories.each do |story|
        new_project.stories.find_or_create_by(external_id: story.id, title: story.name)
      end
      new_project.analyze()
      self.create_pivotal_webhook(new_project)
    end
    return self.user.projects
  end

  def initialize_jira
    raise 'jira is unsupported for now'
  end

  def create_pivotal_webhook(project)
    HTTP.headers('X-TrackerToken' => self.auth_info).post("https://www.pivotaltracker.com/services/v5/projects/#{project.external_id}/webhooks", form: {webhook_url: "http://requestb.in/1ayt1p91", webhook_version: "v5"} )
  end
end
