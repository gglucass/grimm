class CreateWebhooks < ActiveRecord::Migration
  def change
    create_table :webhooks do |t|
      t.text :json_string

      t.timestamps null: false
    end
  end
end