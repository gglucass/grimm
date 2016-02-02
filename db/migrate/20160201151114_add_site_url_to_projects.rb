class AddSiteUrlToProjects < ActiveRecord::Migration
  def change
    add_column :projects, :site_url, :string
  end
end
