class UsersController < ApplicationController
  before_action :set_and_authorize_user, only: [:show]
  
  def show
    @integrations = @user.integrations
  end


  def set_and_authorize_user
    authorize @user = User.find(params[:id])
  end

end