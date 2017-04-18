require 'rails_helper'
require 'lti_spec_helper'

RSpec.describe EventController, type: :controller do
  include_context 'lti_spec_helper'

  describe '#submission' do

    let(:submission_id) {'30000065089104'}
    let(:lti_assignment_id) {'899d6635-8f9e-4646-8622-2ed1ec0c951a'}
    let(:tool_proxy) do
      ToolProxy.create!(
        guid: SecureRandom.uuid,
        shared_secret: SecureRandom.uuid,
        tcp_url: 'https://example.com/tcp_url',
        base_url: 'https://example.com'
      )
    end
    let!(:assignment) { tool_proxy.assignments.create!( lti_assignment_id: lti_assignment_id ) }

    let(:webhook) do
      {
        metadata: {
          root_account_id: '30000000001996',
          root_account_lti_guid: 'b9030a8a5264ced1ce7483680885e44cb260b98b.canvas.instructure.com',
          user_id: '30000003207225',
          real_user_id: '170000003472990',
          user_login: '5207217b0bd216811de700729a5976345e85c03b',
          hostname: 'nathanm.beta.instructure.com',
          user_agent: 'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/56.0.2924.87 Safari/537.36',
          context_type: 'Course',
          context_id: '30000000686853',
          context_role: 'StudentEnrollment',
          request_id: 'd1d337a2-4120-478d-8c78-cb672b66fd6f',
          session_id: '54ac807370d205ed7370270b359f286e',
          event_name: 'submission_created',
          event_time: '2017-03-09T17 =>49 =>52Z'
        },
        body: {
          submission_id: submission_id,
          assignment_id: '30000005822547',
          user_id: '30000003207225',
          submitted_at: '2017-03-09T17 =>49 =>52Z',
          graded_at: nil,
          updated_at: '2017-03-09T17 =>49 =>52Z',
          score: nil,
          grade: nil,
          submission_type: 'online_upload',
          body: nil,
          url: nil,
          attempt: 1,
          lti_assignment_id: '899d6635-8f9e-4646-8622-2ed1ec0c951a'
        },
        subscription: {
          id: '470c4d60-bf6c-4feb-9dbc-8695744d43b6'
        }
      }
    end

    it 'creates a submission' do
      post :submission, body: webhook.to_json, format: :json
      expect(Submission.find_by(tc_id: submission_id)).to_not be nil
    end

  end

end