class StaticPagesController < ApplicationController
  skip_before_filter :authenticate_user!, only: [:index, :webhook, :instructions, :smshook]
  skip_before_filter :verify_authenticity_token, only: [:webhook, :smshook]
  skip_after_action :verify_authorized, only: [:webhook, :smshook]

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

  def smshook
    body = params[:Body]
    pin = body[/(PIN \+ )\d*-\d*./].gsub(/(PIN \+ )/, '').gsub('.', '')
    if pin.present?
      text = File.read(ENV["VPN_FILE"])
      new_contents = text.gsub(/^(set coolbluepass) .*$/, "set coolbluepass 35121742#{pin}")
      File.open(ENV["VPN_FILE"], "w") {|file| file.puts new_contents}
    else
    end
    render nothing: true, status: :ok
  end

  def instructions
  end
end
