class AddStoryPointsToIssue < ActiveRecord::Migration
  def change
    add_column :issues, :story_points, :float
    add_column :sprints, :velocity, :float
  end
end
