# highlight, kind, subkind, severity, false_positive
class Error < ActiveRecord::Base
  belongs_to :story
  belongs_to :project
end
