class AddCreateCommentsToProject < ActiveRecord::Migration
  def change
    add_column :projects, :create_comments, :boolean, default: false
  end
end
