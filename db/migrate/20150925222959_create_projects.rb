class CreateProjects < ActiveRecord::Migration
  def change
    create_table :projects do |t|
      t.string :name
      t.string :external_id
      t.timestamps null: false
    end

    create_table :projects_users, id: false do |t|
      t.belongs_to :project, index: true
      t.belongs_to :user, index: true
    end
  end
end
