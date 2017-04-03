class Submission < ApplicationRecord
  validates :tc_id, presence: true
  has_one :originality_report
end
