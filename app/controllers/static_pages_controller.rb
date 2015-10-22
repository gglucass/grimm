class StaticPagesController < ApplicationController
  skip_before_filter :authenticate_user!, only: [:index, :webhook, :instructions]
  skip_before_filter :verify_authenticity_token, only: [:webhook]
  skip_after_action :verify_authorized, only: [:webhook]

  def index
    unless user_signed_in?
      @project = Project.where(publik: true).order("RANDOM()").first
    end
  end

  def webhook
    status = Webhook.parse(params)
    render nothing: true, status: :ok
  end

  def instructions
  end
end
