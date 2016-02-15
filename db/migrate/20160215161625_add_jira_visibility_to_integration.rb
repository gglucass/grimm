class AddJiraVisibilityToIntegration < ActiveRecord::Migration
  def change
    add_column :integrations, :jira_visibility, :string
  end
end
