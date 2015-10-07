# highlight, kind, subkind, severity, false_positive
class Defect < ActiveRecord::Base
  belongs_to :story
  belongs_to :project
  has_many :comments, dependent: :destroy

  def create_comments(user)
    client = TrackerApi::Client.new(token: user.integrations.first.auth_info)
    project = client.project(self.project.external_id)
    story = project.story(self.story.external_id)
    text = "__" + I18n.t("defect_comments.#{self.kind}.#{self.subkind}") + "__\n" + I18n.t("defect_comments.#{self.kind}.#{self.subkind}_explanation") + "\n" + "__Suggestion__: " + self.highlight

    response = client.post("/projects/#{project.id}/stories/#{story.id}/comments", params: {text: text})
    if response
      self.comments.create(external_id: response.body['id'], text: response.body['text'], user: user)
    end
  end
end