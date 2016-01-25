class AddReqDocToProjects < ActiveRecord::Migration
  def up
    add_attachment :projects, :requirements_document
  end

  def down
    remove_attachment :projects, :requirements_document
  end
end
