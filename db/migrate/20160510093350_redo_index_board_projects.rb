class RedoIndexBoardProjects < ActiveRecord::Migration
  def change
    remove_index :boards, :project_id
    add_index(:boards, :project_id)
  end
end
