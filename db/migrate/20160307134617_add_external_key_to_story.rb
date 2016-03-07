class AddExternalKeyToStory < ActiveRecord::Migration
  def change
    add_column :stories, :external_key, :string
  end
end
