class Board < ActiveRecord::Base
  belongs_to :project
  has_many :sprints, dependent: :destroy


  def self.import_boards(integration, project)
    boards = JSON.parse(HTTP.basic_auth(user: integration.auth_info["jira_username"], pass: integration.auth_info["jira_password"]).get("https://#{integration.site_url}/rest/agile/1.0/board/", params: { projectKeyOrId: project.external_id}).body.readpartial)
    boards["values"].each do |board|
      new_board = project.boards.find_or_initialize_by(external_id: board["id"])
      new_board.name = board["name"]
      if new_board.changed?
        new_board.save()
      end
    end
  end

  def parse_board_status(integration)
    board_config = JSON.parse(HTTP.basic_auth(user: integration.auth_info["jira_username"], pass: integration.auth_info["jira_password"]).get("https://#{integration.site_url}/rest/agile/1.0/board/#{self.external_id}/configuration").body.readpartial)
    columns = board_config["columnConfig"]["columns"]
    column_hash = {}
    columns.each_with_index do |column, index|
      column_hash[column["name"].downcase] =  index
    end
    return column_hash
  end
end
