class AddMetricAttributesToStory < ActiveRecord::Migration
  def change
    add_column :stories, :priority, :text
    add_column :stories, :status, :text
    add_column :stories, :comments, :text
    add_column :stories, :description, :text
    add_column :stories, :estimation, :string
  end
end
