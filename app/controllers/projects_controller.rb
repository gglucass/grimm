class ProjectsController < ApplicationController
  before_action :set_and_authorize_project, only: [:show, :edit, :update, :toggle_comments]

  def new
    @project = Project.new
  end
  
  def create
    @project = Project.new(project_params)
    @project.users << current_user
    if @project.save
      redirect_to project_path(@project)
    else
      render new
    end
  end

  def edit
  end

  def update
    @project.update_attributes(project_params)
    redirect_to project_path(@project)
  end

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
    authorize @project = Project.find(params[:id] || params[:project_id])
  end

  def toggle_comments
    @project.toggle!(:create_comments)
    redirect_to project_path(@project)
  end

  private
    def project_params
      params.require(:project).permit(:name, :requirements_document, :kind)
    end
end