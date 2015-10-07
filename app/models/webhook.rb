class Webhook
  
  def self.parse(data)
    kind = data.has_key?('webhookEvent') ? 'jira' : 'pivotal'
    if kind == 'pivotal'
      project = Project.find_by(external_id: data[:project][:id], kind: kind)
      data[:changes].each do |change|
        Webhook.send("#{kind}_#{change[:change_type]}_#{change[:kind]}", change, project)
      end
    elsif kind == 'jira'
      project = Project.find_by(external_id: data[:issue][:fields][:project][:id], kind: kind)
      Webhook.send("#{kind}_#{data['webhookEvent'].gsub('jira:',"")}", data, project)
    end
  end

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

  def self.jira_issue_created(data, project)
    story = Story.create(title: data[:issue][:fields][:summary], project_id: project.id, external_id: data[:issue][:id])
    story.analyze()
  end

  def self.jira_issue_updated(data, project)
    story = Story.where(project_id: project.id, external_id: data[:issue][:id]).first
    story.title = data[:issue][:fields][:summary]
    if story.save()
      story.analyze()
    end
  end

  def self.jira_issue_deleted(data, project)
    story = Story.where(project_id: project.id, external_id: data[:issue][:id]).first
    story.destroy()
    return :ok
  end
end
