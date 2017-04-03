class Assignment < ApplicationRecord
  validates :lti_assignment_id, :tool_proxy_id, presence: true
  store_accessor :settings
  belongs_to :tool_proxy
end
