# id, title, external_id
class Story < ActiveRecord::Base
  belongs_to :project
  has_many :defects, dependent: :destroy

  def analyze
    Defect.where(story_id: self.id, false_positive: false).each do |defect|
      defect.destroy()
    end
    Thread.start { HTTP.get("http://127.0.0.1:5000/project/#{self.project.id}/stories/#{self.id}/analyze") }
    self
  end
end
