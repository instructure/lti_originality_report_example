class OriginalityReport < ApplicationRecord
  validates :originality_score, :file_id, :tc_id, :submission, presence: true
  validates :originality_score, inclusion: { in: 0..100, message: 'score must be between 0 and 100' }
  belongs_to :submission
end
