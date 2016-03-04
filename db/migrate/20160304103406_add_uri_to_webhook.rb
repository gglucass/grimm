class AddUriToWebhook < ActiveRecord::Migration
  def change
    add_column :webhooks, :site_url, :string
  end
end
