class AddBugCountsToSprint < ActiveRecord::Migration
  def change
    add_column :sprints, :bug_count, :integer
    add_column :sprints, :bug_count_long, :integer
  end
end
