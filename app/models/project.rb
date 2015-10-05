# id, name, external_id
class Project < ActiveRecord::Base
  has_and_belongs_to_many :users, -> { uniq }
  has_many :stories

  def analyze
    Defect.where(project_id: self.id, false_positive: false).each do |defect|
      defect.destroy()
    end
    response = HTTP.get("http://127.0.0.1:5000/project/#{self.id}/analyze")
  end
end
