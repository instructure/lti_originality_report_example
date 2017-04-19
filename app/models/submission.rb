class Submission < ApplicationRecord
  validates :tc_id, :assignment, presence: true
  belongs_to :assignment
  has_many :originality_reports
  serialize :attachments, Array
end
