class CreateSprints < ActiveRecord::Migration
  def change
    create_table :sprints do |t|
      t.belongs_to :board, index: { unique: true }
      t.string :name
      t.string :external_id

      t.timestamps null: false
    end
  end
end
