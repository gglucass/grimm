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

  def parse_board_status(integration, project)
    board_config = JSON.parse(HTTP.basic_auth(user: integration.auth_info["jira_username"], pass: integration.auth_info["jira_password"]).get("https://#{integration.site_url}/rest/api/2/project/#{project.external_id}/statuses").body.readpartial)
    status_hash = {}
    board_config.each do |board|
      if board["name"] == "Story"
        statuses = board["statuses"]
        statuses.each_with_index do |status, index|
          status_hash[status["name"].downcase] = index
        end
      end
    end
    return status_hash
  end
end
