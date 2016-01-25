require 'csv'
# id, name, external_id
class Project < ActiveRecord::Base
  has_attached_file :requirements_document
  validates_attachment :requirements_document, content_type: { content_type: 'text/csv'}

  has_and_belongs_to_many :users, -> { uniq }
  has_many :defects
  has_many :stories, dependent: :destroy

  after_save :process_attachment, if: Proc.new { |a| a.requirements_document_updated_at_changed? }

  def analyze
    Defect.where(project_id: self.id, false_positive: false).each do |defect|
      defect.destroy()
    end
    Thread.start { HTTP.get("http://127.0.0.1:5000/project/#{self.id}/analyze") }
  end

  def process_attachment
    self.stories.destroy_all()
    CSV.foreach(self.requirements_document.path) do |row|
      stories.create(title: row[0])
    end
    self.analyze()
  end
end
