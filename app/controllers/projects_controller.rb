class ProjectsController < ApplicationController
  before_action :set_and_authorize_project, only: [:show, :edit, :update, :toggle_comments, :analyze, :report]

  def new
    @project = Project.new
  end
  
  def create
    @project = Project.new(project_params)
    @project.users << current_user
    if @project.save
      redirect_to project_path(@project)
    else
      redirect_to new_project_path
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
    @severe_defects = @project_defects.where(severity: "high")
    @medium_defects = @project_defects.where(severity: "medium")
    @minor_defects = @project_defects.where(severity: "minor")
    @false_positives = @project.defects.where(false_positive: true)
    @perfect_stories_all = Story.includes(:defects).where(defects: {id: nil}, project_id: @project.id).order(:external_key)
    @perfect_stories = @perfect_stories_all.paginate(page: params[:page])
    @stories = Story.where(project_id: @project.id).order(:external_key).paginate(page: params[:page])
  end


  def set_and_authorize_project
    authorize @project = Project.find(params[:id] || params[:project_id])
  end

  def toggle_comments
    @project.toggle!(:create_comments)
    redirect_to project_path(@project)
  end

  def analyze
    @project.analyze()
    redirect_to project_path(@project)
  end

  def report
    respond_to do |format|
      format.html
      format.csv { send_data @project.to_csv, filename: "#{@project.name}.csv" }
    end
  end

  private
    def project_params
      params.require(:project).permit(:name, :requirements_document, :kind, :publik, :page)
    end
end