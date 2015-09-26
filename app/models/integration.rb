class Integration < ActiveRecord::Base
  # kind, auth_info
  belongs_to :user
  serialize :auth_info
  after_create :sync_integration

  private

  def sync_integration
    eval("initialize_#{self.kind}")
  end

  def initialize_pivotal
    client = TrackerApi::Client.new(token: self.auth_info)  
    
    client.projects.each do |project|
      new_project = Project.find_or_create_by(external_id: project.id)
      new_project.name ||= project.name
      new_project.users << user
      new_project.save
      project.stories.each do |story|
        new_project.stories.create(external_id: story.id, title: story.name)
      end
      # create a webhook for that project
      # analyze all stories
    end
    return self.user.projects
  end

  def initialize_jira
    raise 'jira is unsupported for now'
  end
end
