class DefectsController < ApplicationController
  skip_before_filter :authenticate_user!, only: [:create_comments]
  # before_action :set_and_authorize_defect, only: [:create_comments]
  skip_after_action :verify_authorized, only: [:create_comments]
  

  def create_comments
    @defect = Defect.find(params[:defect_id])
    @defect.create_comment()
    render nothing: true, status: :ok
  end

  def strong_params
    params.require(:defect).permit(:id)
  end

  # def set_and_authorize_defect
  #   authorize @defect = Defect.find(params[:defect_id])
  # end
end