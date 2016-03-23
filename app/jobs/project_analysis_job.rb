class ProjectAnalysisJob < ActiveJob::Base
  queue_as :high_priority

  def perform(project, first_analysis)
    result = HTTP.get("http://127.0.0.1:5000/project/#{project.id}/analyze")
    result = JSON.parse(result.body.readpartial)
    if result["success"] == true and first_analysis == true
      project.create_comments = true
      project.save()
    end
  end
end