every 1.day, :at => '1:00 am' do
  runner "DailyImportStoriesJob.perform_later()"
end
every 1.day, :at => '3:00 am' do
  runner "DailyCalculateSprintStatsJob.perform_later()"
end