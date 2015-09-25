class CreateIntegrations < ActiveRecord::Migration
  def change
    create_table :integrations do |t|

      t.timestamps null: false
    end
  end
end
