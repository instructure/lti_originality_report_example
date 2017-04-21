class OriginalityReport < ApplicationRecord
  validates :file_id, :tc_id, :submission, presence: true
  belongs_to :submission
end
