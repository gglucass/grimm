class AddStatusCategoryToStatus < ActiveRecord::Migration
  def change
    add_column :statuses, :status_category, :string
  end
end
