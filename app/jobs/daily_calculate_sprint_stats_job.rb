class DailyCalculateSprintStatsJob < ActiveJob::Base
  queue_as :default

  def perform()
    integrations = Integration.get_all_integrations()
    integrations.each do |integration|
      begin
        integration.projects.each do |project| 
          Board.import_boards(integration, project)
          Comment.import_comments(integration, project)
        end
        
        integration.projects.each do |project|
          project.boards.each do |board|
            Sprint.import_sprints(integration, project, board)
          end
        end

        integration.projects.each do |project|
          project.boards.each do |board|
            board.sprints.each do |sprint|
              sprint.calculate_sprint_stats(integration, project, board)
            end
          end
        end
      rescue
      end
    end
  end
end