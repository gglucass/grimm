# highlight, kind, subkind, severity, false_positive
class Defect < ActiveRecord::Base
  belongs_to :story
  belongs_to :project
  has_many :comments, dependent: :destroy

  def create_comments(user)
    client = TrackerApi::Client.new(token: user.integrations.first.auth_info)
    project = client.project(self.project.external_id)
    story = project.story(self.story.external_id)
    response = client.post("/projects/#{project.id}/stories/#{story.id}/comments", params: {text: self.highlight})
    if response
      self.comments.create(external_id: response.body['id'], text: response.body['text'], user: user)
    end
  end
end