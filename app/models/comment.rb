#external_id, text
class Comment < ActiveRecord::Base
  belongs_to :defect
  belongs_to :user

  before_destroy :remove_externally

  def remove_externally
    self.send("remove_from_#{self.user.integrations.first.kind}")
  end

  def remove_from_pivotal
    HTTP.headers('X-TrackerToken' => self.user.integrations.first.auth_info).delete("https://www.pivotaltracker.com/services/v5/projects/#{self.defect.project.external_id}/stories/#{self.defect.story.external_id}/comments/#{self.external_id}")
  end
end
