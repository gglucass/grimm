class ProjectsController < ApplicationController
  before_action :set_and_authorize_project, only: [:show]
  
  def show
    @project_defects = @project.defects.where(false_positive: false)
    @severe_defects = @project.defects.where(severity: "medium", false_positive: false)
    @medium_defects = @project.defects.where(severity: "high", false_positive: false)
    @minor_defects = @project.defects.where(severity: "minor", false_positive: false)
    @false_positives = @project.defects.where(false_positive: true)
    @perfect_stories = Story.includes(:defects).where(defects: {id: nil}, project_id: @project.id)
    @stories = @project.stories.sort
  end


  def set_and_authorize_project
    authorize @project = Project.find(params[:id])
  end

end