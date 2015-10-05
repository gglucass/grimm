class AddFormatToProjects < ActiveRecord::Migration
  def change
    add_column :projects, :format, :text, default: "As a, I'm able to, So that"
  end
end
