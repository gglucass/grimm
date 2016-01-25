class StaticPagesController < ApplicationController
  skip_before_filter :authenticate_user!, only: [:index, :webhook, :instructions]
  skip_before_filter :verify_authenticity_token, only: [:webhook]
  skip_after_action :verify_authorized, only: [:webhook]

  def index
    unless user_signed_in?
      case ActiveRecord::Base.connection.instance_values["config"][:adapter]
      when 'mysql'
        @project = Project.where(publik: true).order("RAND()").first
      when 'pg'
        @project = Project.where(publik: true).order("RANDOM()").first
      else
        @project = Project.where(publik: true).first
      end
    end
  end

  def webhook
    status = Webhook.parse(params)
    render nothing: true, status: :ok
  end

  def instructions
  end
end
