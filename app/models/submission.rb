class Submission < ApplicationRecord
  validates :tc_id, :assignment, presence: true
  belongs_to :assignment
  has_one :originality_report
end
