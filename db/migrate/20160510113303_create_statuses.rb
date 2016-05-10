class CreateStatuses < ActiveRecord::Migration
  def change
    create_table :statuses do |t|
      t.integer :priority
      t.string :name
      t.belongs_to :board, index: true

      t.timestamps null: false
    end
  end
end
