class AddSiteUrlToIntegration < ActiveRecord::Migration
  def change
    add_column :integrations, :site_url, :string
  end
end
