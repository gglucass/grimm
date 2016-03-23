class DestroyDefectJob < ActiveJob::Base
  queue_as :default

  def perform(defect)
    defect.destroy()
  end
end