require 'rails_helper'

RSpec.describe SubmissionsController, type: :controller do
  describe '#retrieve_and_store' do

    let(:lti_assignment_id) { SecureRandom.uuid }
    let(:tp_guid) { SecureRandom.uuid }
    let(:submission_id) { 2342 }
    let(:random_access_token) { SecureRandom.uuid }
    let(:submission_data) { { 'id' => submission_id, 'assignment_id' => 2 } }
    let(:tool_proxy) do
      ToolProxy.create!(guid: tp_guid,
                        shared_secret: 'secret',
                        tcp_url: 'tcp-url',
                        base_url: 'base-url',
                        authorization_url: 'http://www.test.com/authorize')
    end
    let(:params) do
      {
        lti_assignment_id: lti_assignment_id,
        tool_proxy_guid: tp_guid
      }
    end

    before do
      allow(HTTParty).to receive(:get) { double(body: submission_data.to_json ) }
      allow_any_instance_of(IMS::LTI::Services::AuthenticationService).to receive(:access_token) { random_access_token }
      @assignment = Assignment.create!(lti_assignment_id: lti_assignment_id, tool_proxy: tool_proxy)
    end

    it 'retrieves submissions from the tool consumer' do
      params[:tc_submission_id] = 1
      get :retrieve_and_store, params: params
      expect(Submission.find_by(tc_id: submission_id)).not_to be_blank
    end

    it 'returns 404 if the assignment is not found' do
      params[:tc_submission_id] = 1
      Assignment.delete_all
      get :retrieve_and_store, params: params
      expect(response).to be_not_found
    end

    it 'returns 404 if the submission is not found in Canvas' do
      allow(HTTParty).to receive(:get) { double(body: {} ) }
    end

    it 'creates a submission if one does not exist' do
      submission_count = Submission.count
      params[:tc_submission_id] = submission_count + 1
      get :retrieve_and_store, params: params
      expect(Submission.count).to eq submission_count + 1
    end

    it 'looks up the submission if it already exists' do
      params[:tc_submission_id] = 23
      s = Submission.create!(assignment: @assignment, tc_id: 23)
      get :retrieve_and_store, params: params
      expect(response.body).to eq s.to_json
    end

    it 'does not create another submission if it already exists' do
      params[:tc_submission_id] = 23
      Submission.create!(assignment: @assignment, tc_id: 23)
      submission_count = Submission.count
      get :retrieve_and_store, params: params
      expect(Submission.count).to eq submission_count
    end
  end
end
