class RenameCommentsToCommentStringAndCreateCommentAssociation < ActiveRecord::Migration
  def change
    rename_column :stories, :comments, :comments_json
    add_reference :comments, :story, index: true
  end
end
