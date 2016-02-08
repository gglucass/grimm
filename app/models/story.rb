# id, title, external_id
class Story < ActiveRecord::Base
  has_paper_trail
  belongs_to :project
  has_many :defects, dependent: :destroy
  validates_uniqueness_of :external_id, scope: [:project_id]

  def analyze
    Defect.where(story_id: self.id, false_positive: false).each do |defect|
      defect.destroy()
    end
    Thread.start { HTTP.get("http://127.0.0.1:5000/project/#{self.project.id}/stories/#{self.id}/analyze") }
    self
  end
end
