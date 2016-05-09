class AddRecidivismRateToSprint < ActiveRecord::Migration
  def change
    add_column :sprints, :recidivism_rate, :float
    add_column :sprints, :start_date, :datetime
    add_column :sprints, :end_date, :datetime
  end
end
