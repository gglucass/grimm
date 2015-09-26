# id, title, external_id
class Story < ActiveRecord::Base
  belongs_to :project
end
