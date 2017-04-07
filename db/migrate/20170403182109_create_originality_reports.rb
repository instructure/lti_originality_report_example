class CreateOriginalityReports < ActiveRecord::Migration[5.0]
  def change
    create_table :originality_reports do |t|
      t.integer :tc_id, null: false
      t.integer :file_id, null: false
      t.float :originality_score, null: false
      t.integer :submission_id, null: false
      t.integer :originality_report_file_id
      t.string :originality_report_url
      t.string :originality_report_lti_url
      t.timestamps
    end

    add_foreign_key :originality_reports, :submissions
    add_index :originality_reports, [:submission_id]
    add_index :originality_reports, [:tc_id]
  end
end
