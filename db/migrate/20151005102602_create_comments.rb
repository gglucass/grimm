class CreateComments < ActiveRecord::Migration
  def change
    create_table :comments do |t|
      t.string :external_id
      t.text :text
      t.belongs_to :defect, index: true
      t.belongs_to :user, index: true

      t.timestamps null: false
    end
    add_foreign_key :comments, :defects
    add_foreign_key :comments, :users
  end
end
