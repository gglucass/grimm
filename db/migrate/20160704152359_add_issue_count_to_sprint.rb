class AddIssueCountToSprint < ActiveRecord::Migration
  def change
    add_column :sprints, :issue_count, :integer
  end
end
