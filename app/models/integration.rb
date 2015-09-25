class Integration < ActiveRecord::Base
  # kind, auth_info
  belongs_to :user
  serialize :auth_info
end
