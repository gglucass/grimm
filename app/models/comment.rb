#external_id, text
class Comment < ActiveRecord::Base
  has_paper_trail
  belongs_to :defect
  belongs_to :user

  before_destroy :remove_externally

  def remove_externally
    integration = self.user.integrations.where(kind: self.defect.project.kind).first
    self.send("remove_from_#{integration.kind}", integration)
  end

  def remove_from_pivotal(integration)
    HTTP.headers('X-TrackerToken' => integration.auth_info).delete("https://www.pivotaltracker.com/services/v5/projects/#{self.defect.project.external_id}/stories/#{self.defect.story.external_id}/comments/#{self.external_id}")
  end

  def remove_from_jira(integration)
    HTTP.basic_auth(user: integration.auth_info["jira_username"], pass: integration.auth_info["jira_password"]).delete("#{integration.auth_info["jira_url"]}/rest/api/2/issue/#{self.defect.story.external_id}/comment/#{self.external_id}")
  end
end
