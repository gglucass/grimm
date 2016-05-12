class AddCommentCountToSprint < ActiveRecord::Migration
  def change
    add_column :sprints, :comment_count, :integer
  end
end
