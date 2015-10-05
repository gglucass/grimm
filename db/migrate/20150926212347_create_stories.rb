class CreateStories < ActiveRecord::Migration
  def change
    create_table :stories do |t|
      t.text :title
      t.string :external_id 
      t.belongs_to :project, index: true

      t.timestamps null: false
    end
    add_foreign_key :stories, :projects
  end
end
