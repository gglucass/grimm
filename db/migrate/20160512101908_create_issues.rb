class CreateIssues < ActiveRecord::Migration
  def change
    create_table :issues do |t|
      t.belongs_to :project
      t.string :external_id
      t.text :title
      t.string :status
      t.string :kind


      t.timestamps null: false
    end
  end
end
