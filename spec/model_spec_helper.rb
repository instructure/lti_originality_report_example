require 'lti_spec_helper'
RSpec.shared_context 'model_spec_helper', shared_context: :metadata do
  include_context 'lti_spec_helper'

  let(:lti_assignment_id) { SecureRandom.uuid }
  let(:assignment) { Assignment.create!(lti_assignment_id: lti_assignment_id, tool_proxy: tool_proxy) }
  let(:submission) { Submission.create!(tc_id: 23, assignment: assignment) }
  let(:originality_report) { OriginalityReport.create!(originality_score: 50, file_id: 2, tc_id: 3, submission: submission) }
end
