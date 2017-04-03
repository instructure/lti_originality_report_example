class Assignment < ApplicationRecord
  validates :lti_assignment_id, :tool_proxy, presence: true
  store_accessor :settings
  belongs_to :tool_proxy
  has_many :submissions
end
