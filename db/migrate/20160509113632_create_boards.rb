class CreateBoards < ActiveRecord::Migration
  def change
    create_table :boards do |t|
      t.belongs_to :project, index: { unique: true }
      t.string :name
      t.string :external_id

      t.timestamps null: false
    end
  end
end
