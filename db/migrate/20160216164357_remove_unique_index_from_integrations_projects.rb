class RemoveUniqueIndexFromIntegrationsProjects < ActiveRecord::Migration
  def change
    remove_index(:integrations_projects, :project_id)
  end
end
