class AddKindToIntegrations < ActiveRecord::Migration
  def change

    add_column :integrations, :kind, :string
    add_column :integrations, :auth_info, :text
    
    change_table(:integrations) do |t|
      t.belongs_to :user, index: true
    end
    
    change_table(:users) do |t|
      t.belongs_to :integration, index: true
    end
  end
end
