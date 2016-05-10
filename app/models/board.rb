class Board < ActiveRecord::Base
  belongs_to :project
  has_many :sprints, dependent: :destroy
  has_many :statuses, dependent: :destroy


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

# todo: redo parse board status every now and then so recidivism is correctly calculated after updating the workflow
  def parse_board_status(integration, project)
    board_statuses = JSON.parse(HTTP.basic_auth(user: integration.auth_info["jira_username"], pass: integration.auth_info["jira_password"]).get("https://#{integration.site_url}/rest/api/2/project/#{project.external_id}/statuses").body.readpartial)
    board_statuses.each do |board_status|
      if board_status["name"] == "Story"
        statuses = board_status["statuses"]
        statuses.each_with_index do |status, index|
          if self.statuses.find_by(name: status["name"].downcase).nil?
            if status["statusCategory"]["name"] == status["name"]
                self.statuses.create(name: status["name"].downcase, priority: index)
            else
              parent_status = self.statuses.find_by(name: status["statusCategory"]["name"].downcase)
              parent_priority = parent_status.try(:priority) || self.statuses.order(:priority).last.try(:priority) || -1
              next_boards = self.statuses.where("priority > ?", parent_priority)
              next_boards.each { |nb| nb.priority += 1; nb.save }
              self.statuses.create(name: status["name"].downcase, priority: parent_priority + 1 )
            end
          end
        end
      end
    end
    return self.statuses.pluck(:name, :priority).to_h
  end
end
