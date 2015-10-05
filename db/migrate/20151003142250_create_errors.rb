class CreateErrors < ActiveRecord::Migration
  def change
    create_table :errors do |t|
      t.text :highlight
      t.string :kind
      t.string :subkind
      t.string :severity
      t.boolean :false_positive
      t.belongs_to :project, index: true
      t.belongs_to :story, index: true

      t.timestamps null: false
    end

    add_foreign_key :errors, :projects
    add_foreign_key :errors, :stories
  end
end