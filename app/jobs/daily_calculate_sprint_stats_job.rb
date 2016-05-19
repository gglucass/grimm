class DailyCalculateSprintStatsJob < ActiveJob::Base
  queue_as :default

  def perform(first_run=false)
    integrations = Integration.get_all_integrations()
    integrations.each do |integration|
      begin
        integration.projects.each do |project| 
          Board.import_boards(integration, project)
          jql = first_run ? "project=#{project.external_id}" : "project=#{project.external_id} and updated > -30d"
          Issue.import_issues(integration, project, jql)
          Comment.import_comments(integration, project)
          project.boards.each do |board|
            Sprint.import_sprints(integration, project, board)
            sprints = first_run ? board.sprints : board.sprints.where("end_date > ?", (Date.today-30))
            sprints.each { |s| s.calculate_sprint_stats() }
          end
        end
      rescue
      end
    end
  end
end