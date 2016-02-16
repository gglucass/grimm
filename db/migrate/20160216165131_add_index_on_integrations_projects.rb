class AddIndexOnIntegrationsProjects < ActiveRecord::Migration
  def change
    add_index(:integrations_projects, :project_id)
    add_index(:integrations_projects, [:project_id, :integration_id], unique: true)
  end
end
