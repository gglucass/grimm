class DailyCalculateSprintStatsJob < ActiveJob::Base
  queue_as :default

  def perform()
    integrations = Integration.get_all_integrations()
    integrations.each do |integration|
      begin
        integration.projects.each do |project|
          Board.import_boards(integration, project)
          project.boards.each do |board|
            Sprint.import_sprints(integration, project, board)
            board.sprints.each do |sprint|
              if sprint.recidivism_rate.nil? or sprint.recidivism_rate.nan? or sprint.end_date > (Date.today-30)
                sprint.calculate_recidivism_rate(integration, project, board)
                sprint.save()
              end
            end
          end
        end
      rescue
      end
    end
  end
end