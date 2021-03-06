#TODO: Fix DRY Stuff
class Webhook < ActiveRecord::Base
  serialize :json_string, JSON
  after_create :set_site_url
  
  def self.parse(data)
    Webhook.create(json_string: data)
    kind = data.has_key?('webhookEvent') ? 'jira' : 'pivotal'
    if kind == 'pivotal'
      project = Project.find_by(external_id: data[:project][:id], kind: kind)
      data[:changes].each do |change|
        Webhook.send("#{kind}_#{change[:change_type]}_#{change[:kind]}", change, project)
      end
    elsif kind == 'jira'
      Webhook.send("#{kind}_#{data['webhookEvent'].gsub('jira:',"")}", data)
    end
  end

  def set_site_url
    kind = self.json_string.has_key?('webhookEvent') ? 'jira' : 'pivotal'
    if kind == 'jira'
      webhook_object = self.json_string["webhookEvent"].split('_').first
      case webhook_object
      when 'jira:issue' 
        webhook_object = 'issue'
      when 'board'
        webhook_object = 'configuration'
      end
      begin
        self.site_url = URI.parse(self.json_string[webhook_object]["self"]).host
        self.save
      rescue
      end
    end
  end

  ## PIVOTAL
  def self.pivotal_create_story(change, project)
    values = change[:new_values]
    story = Story.create(title: values[:name], project_id: project.id, external_id: values[:id])
    story.analyze()
  end

  def self.pivotal_update_story(change, project)
    original_values = change[:original_values]
    story = Story.where(project_id: project.id, external_id: change[:id]).first()
    new_values = change[:new_values]
    story.title = new_values[:name]
    if story.save()
      story.analyze()
    end
  end

  def self.pivotal_delete_story(change, project)
    story = Story.where(project_id: project.id, external_id: change[:id]).first()
    story.destroy()
    return :ok
  end

  ## JIRA Issue
  def self.jira_issue_created(data)
    project = Project.find_by(external_id: data[:issue][:fields][:project][:id], site_url: URI.parse(data[:issue][:self]).host)
    issuetype = data[:issue][:fields][:issuetype][:name]
    if issuetype.in?(['Story', project.custom_issue_type])
      story = Story.create(title: data[:issue][:fields][:summary], project_id: project.id, external_id: data[:issue][:id])
      story.assign_attributes(Webhook.parse_jira_data(data))
      story.save()
      story.analyze()
    end
  end

  def self.jira_issue_updated(data)
    project = Project.find_by(external_id: data[:issue][:fields][:project][:id], site_url: URI.parse(data[:issue][:self]).host)
    story = Story.where(project_id: project.id, external_id: data[:issue][:id]).first
    if story
      story.assign_attributes(Webhook.parse_jira_data(data))
      if story.changed?
        if story.title_changed?
          story.save()
          story.analyze()
        else
          story.save
        end
      end
    end
  end

  def self.jira_issue_deleted(data)
    project = Project.find_by(external_id: data[:issue][:fields][:project][:id], site_url: URI.parse(data[:issue][:self]).host)
    story = Story.where(project_id: project.id, external_id: data[:issue][:id]).first
    story.destroy()
    return :ok
  end

  def self.parse_jira_data(data)
    external_key = data[:issue][:key]
    data = data[:issue][:fields]
    priority = data[:priority][:name]
    status = data[:status][:name]
    title = data[:summary]
    comments = data[:comment]
    description = data[:description]
    estimation = data[:customfield_10008]
    { priority: priority, status: status, title: title, comments_json: comments, 
      description: description, estimation: estimation, external_key: external_key }
  end

  ## JIRA Project

  def self.jira_project_created(data)
    site_url = URI.parse(data[:project][:self]).host
    integrations = Integration.where(site_url: site_url)
    integrations.each do |integration|
      integration.sync_integration()
    end
  end

  def self.jira_project_deleted(data)
    project = Project.find_by(external_id: data[:project][:id], site_url: URI.parse(data[:project][:self]).host)
    project.delete()
  end

  def self.jira_project_updated(data)
    project = Project.find_by(external_id: data[:project][:id], site_url: URI.parse(data[:project][:self]).host)
    project.name = data[:project][:name]
    project.save()
  end
end
