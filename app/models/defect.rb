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
    integration = self.project.integrations.where(kind: 'pivotal').first
    client = TrackerApi::Client.new(token: integration.auth_info)
    project = client.project(self.project.external_id)
    story = project.story(self.story.external_id)
    text = "__" + I18n.t("defect_comments.#{self.kind}.#{self.subkind}") + "__\n" + I18n.t("defect_comments.#{self.kind}.#{self.subkind}_explanation") + "\n" + "__Suggestion__: " + self.highlight

    response = client.post("/projects/#{project.id}/stories/#{story.id}/comments", params: {text: text})
    if response
      self.comments.create(external_id: response.body['id'], text: response.body['text'], user: integration.user)
    end
  end

  def create_jira_comment
    integration = self.project.integrations.where(kind: 'jira').first
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
    if integration.jira_visibility
      comment.save({'body': text, 
        "visibility": {"type": "group", "value": integration.jira_visibility}
        })
    else
      comment.save({'body': text})
    end
    if comment.id
      self.comments.create(external_id: comment.id, text: comment.body, user: integration.user)
    end
  end
end