# id, name, external_id
class Project < ActiveRecord::Base
  has_and_belongs_to_many :users, -> { uniq }
  has_many :stories
end
