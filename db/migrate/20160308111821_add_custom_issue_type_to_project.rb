class AddCustomIssueTypeToProject < ActiveRecord::Migration
  def change
    add_column :projects, :custom_issue_type, :string
  end
end
