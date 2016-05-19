class AddJiraCreateUpdateResolveToIssues < ActiveRecord::Migration
  def change
    add_column :issues, :jira_create, :datetime
    add_column :issues, :jira_update, :datetime
    add_column :issues, :jira_resolve, :datetime
  end
end
