class IntegrationsController < ApplicationController
  
  def create
    user = User.find(params[:integration][:user_id])
    user.integrations.create(strong_params)
    redirect_to user_path(user)
  end

  def strong_params
    params.require(:integration).permit(:kind, :auth_info,)
  end

end