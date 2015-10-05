class Webhook
  
  def self.parse(data)
    project = Project.find_by(external_id: data[:project][:id])
    data[:changes].each do |change|
      Webhook.send("#{change[:change_type]}_#{change[:kind]}", change, project)
    end
  end

  def self.create_story(change, project)
    values = change[:new_values]
    story = Story.create(title: values[:name], project_id: project.id, external_id: values[:id])
    story.analyze()
  end

  def self.update_story(change, project)
    original_values = change[:original_values]
    story = Story.where(project_id: project.id, external_id: change[:id]).first()
    new_values = change[:new_values]
    story.title = new_values[:name]
    if story.save()
      story.analyze()
    end
  end

  def self.delete_story(change, project)
    story = Story.where(project_id: project.id, external_id: change[:id]).first()
    story.destroy()
    return :ok
  end
end
