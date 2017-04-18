class ChangeIdLimits < ActiveRecord::Migration[5.0]
  def change
    change_column :submissions, :tc_id, :integer, limit: 8
    change_column :originality_reports, :tc_id, :integer, limit: 8
  end

end
