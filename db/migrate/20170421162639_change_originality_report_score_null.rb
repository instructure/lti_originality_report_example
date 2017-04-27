class ChangeOriginalityReportScoreNull < ActiveRecord::Migration[5.0]
  def change
    change_column_null :originality_reports, :originality_score, true
  end
end
