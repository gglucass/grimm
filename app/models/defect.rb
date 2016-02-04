# highlight, kind, subkind, severity, false_positive
class Defect < ActiveRecord::Base
  has_paper_trail
  belongs_to :story
  belongs_to :project
  has_many :comments, dependent: :destroy

  def create_comment
    if self.project.create_comments?
      self.send("create_#{self.project.kind}_comment")
    end
  end

  def create_pivotal_comment
    user = self.project.users.first
    client = TrackerApi::Client.new(token: user.integrations.where(kind: 'pivotal').first.auth_info)
    project = client.project(self.project.external_id)
    story = project.story(self.story.external_id)
    text = "__" + I18n.t("defect_comments.#{self.kind}.#{self.subkind}") + "__\n" + I18n.t("defect_comments.#{self.kind}.#{self.subkind}_explanation") + "\n" + "__Suggestion__: " + self.highlight

    response = client.post("/projects/#{project.id}/stories/#{story.id}/comments", params: {text: text})
    if response
      self.comments.create(external_id: response.body['id'], text: response.body['text'], user: user)
    end
  end

  def create_jira_comment
    user = self.project.users.first
    integration = user.integrations.where(kind: 'jira').first
    options = {
      site: 'https://' + integration.site_url,
      context_path: '',
      auth_type: :basic,
      username: integration.auth_info["jira_username"],
      password: integration.auth_info["jira_password"]
    }
    client = JIRA::Client.new(options)
    issue = client.Issue.find(self.story.external_id)
    text = "*:" + I18n.t("defect_comments.reports") + I18n.t("defect_comments.#{self.kind}.#{self.subkind}") + "*\n" + I18n.t("defect_comments.#{self.kind}.#{self.subkind}_explanation") + "\n" + "*Suggestion*: " + self.highlight
    comment = issue.comments.build
    comment.save({'body': text})
    if comment.id
      self.comments.create(external_id: comment.id, text: comment.body, user: user)
    end
  end
end