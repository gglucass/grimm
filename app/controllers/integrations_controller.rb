class IntegrationsController < ApplicationController
  
  def create
    user = User.find(params[:user_id])
    user.integrations.create(strong_params)
    redirect_to root_path
  end

  def strong_params
    params.require(:integration).permit(:kind, :auth_info => [:jira_url, :jira_username, :jira_password])
  end

end