class IntegrationsController < ApplicationController
  
  def create
    user = User.find(params[:user_id])
    user.integrations.create(strong_params)
    redirect_to root_path
  end

  def destroy
    user = User.find(params[:user_id])
    integration = user.integrations.find(params[:id])
    integration.destroy()
    redirect_to user_path(user)
  end

  def strong_params
    if params.require(:integration).permit(:kind)[:kind] == 'pivotal'
      return pivotal_params
    elsif params.require(:integration).permit(:kind)[:kind] == 'jira'
      return jira_params
    end
  end

  def jira_params
    params.require(:integration).permit(:kind, :site_url, :auth_info => [:jira_username, :jira_password])
  end

  def pivotal_params
    params.require(:integration).permit(:kind, :auth_info)
  end
end