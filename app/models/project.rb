require 'csv'
# id, name, external_id
class Project < ActiveRecord::Base
  has_paper_trail
  has_attached_file :requirements_document
  validates_attachment :requirements_document, content_type: { content_type: 'text/csv'}

  has_and_belongs_to_many :users, -> { uniq }
  has_and_belongs_to_many :integrations, -> { uniq }
  has_many :defects
  has_many :stories, dependent: :destroy

  after_save :process_attachment, if: Proc.new { |a| a.requirements_document_updated_at_changed? }

  def analyze(first_analysis: false)
    Defect.where(project_id: self.id, false_positive: false).each do |defect|
      DestroyDefectJob.perform_later(defect)
    end
    ProjectAnalysisJob.perform_later(self, first_analysis)
  end

  def process_attachment
    self.stories.destroy_all()
    index = 0
    CSV.foreach(self.requirements_document.path) do |row|
      stories.create(title: row[0], external_id: index)
      index += 1
    end
    self.analyze()
  end
end
