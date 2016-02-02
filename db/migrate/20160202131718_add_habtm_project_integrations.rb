class AddHabtmProjectIntegrations < ActiveRecord::Migration
  def change
    create_table :integrations_projects, id: false do |t|
      t.belongs_to :project, index: { unique: true }
      t.belongs_to :integration, index: true
    end
  end
end
