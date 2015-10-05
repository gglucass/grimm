class AddRoleMeansEndsToStories < ActiveRecord::Migration
  def change
    add_column :stories, :role, :text
    add_column :stories, :means, :text
    add_column :stories, :ends, :text
  end
end
