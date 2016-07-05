#external_id, text
class Comment < ActiveRecord::Base
  has_paper_trail
  belongs_to :defect
  belongs_to :story
  belongs_to :user

  before_destroy :remove_externally

  def self.import_comments(integration, project)
    client = integration.initialize_jira_client()
    Issue.where(project_id: project.id, kind: 'story').each do |story|
      begin
        jira_story = client.Issue.find(story.external_id)
        jira_story.comments.each do |comment|
          new_comment = story.comments.find_or_initialize_by(external_id: comment.id)
          new_comment.text = comment.body
          new_comment.save()
        end
      rescue
      end
    end
  end

  def remove_externally
    if !self.defect.nil?
      integration = self.defect.project.integrations.where(kind: self.defect.project.kind).first
      self.send("remove_from_#{integration.kind}", integration)
    end
  end

  def remove_from_pivotal(integration)
    HTTP.headers('X-TrackerToken' => integration.auth_info).delete("https://www.pivotaltracker.com/services/v5/projects/#{self.defect.project.external_id}/stories/#{self.defect.story.external_id}/comments/#{self.external_id}")
  end

  def remove_from_jira(integration)
    HTTP.basic_auth(user: integration.auth_info["jira_username"], pass: integration.auth_info["jira_password"]).delete("https://#{integration.site_url_full}/rest/api/2/issue/#{self.defect.story.external_id}/comment/#{self.external_id}")
  end

  def self.parse_jira_highlight(highlight)
    highlight.gsub(/<span .*'>/, '{color:d04437}').gsub(/<\/span>/, '{color}')
  end
end
