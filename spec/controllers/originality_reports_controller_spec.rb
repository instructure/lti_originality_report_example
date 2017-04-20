require 'rails_helper'
require 'lti_spec_helper'

RSpec.describe OriginalityReportsController, type: :controller do
  include_context 'lti_spec_helper'
  let(:attachments) { [{ 'id' => 44 }] }
  let(:file_id) { 25 }
  let(:tc_id) { 22 }
  let(:originality_score) { 50 }
  let(:lti_assignment_id) { SecureRandom.uuid }
  let(:assignment_model) { Assignment.create!(lti_assignment_id: lti_assignment_id, tool_proxy: tool_proxy, tc_id: 3) }
  let(:submission_model) { Submission.create!(tc_id: 23, assignment: assignment_model, attachments: attachments) }
  let(:params) { { 'submission_tc_id' => submission_model.tc_id, 'assignment_tc_id' => assignment_model.tc_id } }
  let(:report_response) { double(body: { originality_score: originality_score, file_id: file_id, id: tc_id }.to_json, code: 201) }
  let(:random_access_token) { SecureRandom.uuid }

  before do
    tool_proxy.update_attributes(authorization_url: 'http://www.test.com/authorize')
    allow(controller).to receive(:params) { params }
    allow(HTTParty).to receive(:post) { report_response }
    allow_any_instance_of(IMS::LTI::Services::AuthenticationService).to receive(:access_token) { random_access_token }
  end

  describe '#create' do
    it 'returns not found if submission is not found' do
      submission_model.destroy!
      post :create, params: { assignment_tc_id: assignment_model.tc_id, submission_tc_id: submission_model.tc_id }
      expect(response).to be_not_found
    end

    it 'returns not found if assignment is not found' do
      submission_model.destroy!
      assignment_model.destroy!
      post :create, params: { assignment_tc_id: assignment_model.tc_id, submission_tc_id: submission_model.tc_id }
      expect(response).to be_not_found
    end

    it 'uses the originality score from params' do
      post :create, params: { assignment_tc_id: assignment_model.tc_id, submission_tc_id: submission_model.tc_id }
      expect(JSON.parse(response.body)['originality_score']).to eq originality_score
    end

    it 'returns 201 if succesful' do
      post :create, params: { assignment_tc_id: assignment_model.tc_id, submission_tc_id: submission_model.tc_id }
      expect(response.status).to eq 201
    end

    it 'persists an originality report if request is succesful' do
      count = OriginalityReport.count
      post :create, params: { assignment_tc_id: assignment_model.tc_id, submission_tc_id: submission_model.tc_id }
      expect(OriginalityReport.count). to eq count + 1
    end

    it 'returns the originality report' do
      post :create, params: { assignment_tc_id: assignment_model.tc_id, submission_tc_id: submission_model.tc_id }
      expect(JSON.parse(response.body)['id']).to eq tc_id
    end
  end
end
