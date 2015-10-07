class ProjectsController < ApplicationController
  before_action :set_and_authorize_project, only: [:show]
  
  def show
  end


  def set_and_authorize_project
    authorize @project = Project.find(params[:id])
  end

end