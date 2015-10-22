class AddPublicToProjectAndAdminToUser < ActiveRecord::Migration
  def change
    add_column :projects, :publik, :boolean, default: false
    add_column :users, :admin, :boolean, default: false
  end
end
