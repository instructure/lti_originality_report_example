require 'rails_helper'

RSpec.describe SubmissionsController, type: :controller do
  let(:rand_id) { SecureRandom.uuid }
  let(:shared_secret) { 'e5bf61debb355e4552732a943c74801ee02bc24ef1d6a077c6e68363fb9dcc4dceab75e6ae4f1e6ae9df5a6892ebbabe49feecc67f00f7e447b43f270e115c590533cd9a176a23eaba334834180da227521884bb49fae1993ca15d52c077b7d37d2ab6fd924a86a285f438f2fc161f63806468d1b977ff120635aa70f9d1d7a5' }
  let(:tool_proxy) { ToolProxy.create!(shared_secret: shared_secret, guid: SecureRandom.uuid, tcp_url: 'test.com', base_url: 'base.com') }
  let(:lti_assignment_id) { SecureRandom.uuid }
  let(:assignment) { tool_proxy.assignments.create!(lti_assignment_id: lti_assignment_id) }
  let(:submission_tc_id) { SecureRandom.uuid }
  let!(:submission) { assignment.submissions.create!(tc_id: submission_tc_id) }
  let(:params) do
    {
      oauth_consumer_key: tool_proxy.guid
    }
  end

  describe '#index' do
    it 'renders the submissions' do
      controller.class.skip_before_action :lti_authentication
      post :index, params: params
      expect(response).to have_http_status(:success)
    end
  end

  describe '#retrieve_and_store' do
    let(:lti_assignment_id) { SecureRandom.uuid }
    let(:tp_guid) { SecureRandom.uuid }
    let(:submission_id) { 2342 }
    let(:random_access_token) { SecureRandom.uuid }
    let(:assignment_tc_id) { 34 }
    let(:attachments) { [{ 'attachment_id' => 1, 'filename' => 'filename' }] }
    let(:submission_data) do
      {
        'id' => submission_id,
        'assignment_id' => assignment_tc_id,
        'attachments' => attachments
      }
    end
    let(:tool_proxy) do
      ToolProxy.create!(guid: tp_guid,
                        shared_secret: 'secret',
                        tcp_url: 'tcp-url',
                        base_url: 'base-url',
                        authorization_url: 'http://www.test.com/authorize')
    end
    let(:params) do
      {
        tool_proxy_guid: tp_guid
      }
    end

    before do
      allow(HTTParty).to receive(:get) { double(body: submission_data.to_json) }
      allow_any_instance_of(IMS::LTI::Services::AuthenticationService).to receive(:access_token) { random_access_token }
      @assignment = Assignment.create!(lti_assignment_id: lti_assignment_id, tool_proxy: tool_proxy)
    end

    it 'sets the submissions attachment data' do
      params[:tc_submission_id] = 1
      s = Submission.create!(assignment: @assignment, tc_id: 1)
      get :retrieve_and_store, params: params
      expect(Submission.find(s.id).attachments).to eq attachments
    end

    it "sets the submission's assignment 'tc_id'" do
      params[:tc_submission_id] = 1
      s = Submission.create!(assignment: @assignment, tc_id: 1)
      get :retrieve_and_store, params: params
      expect(Submission.find(s.id).assignment.tc_id).to eq assignment_tc_id
    end

    it 'returns 404 if the submission is not found' do
      params[:tc_submission_id] = Submission.count + 1
      get :retrieve_and_store, params: params
      expect(response).to be_not_found
    end

    it 'returns 404 if the submission is not found in Canvas' do
      params[:tc_submission_id] = 23
      Submission.create!(assignment: @assignment, tc_id: 23)
      allow(HTTParty).to receive(:get) { double(body: {}.to_json) }
      get :retrieve_and_store, params: params
      expect(response).to be_not_found
    end

    it 'looks up the submission if it exists' do
      params[:tc_submission_id] = 23
      s = Submission.create!(assignment: @assignment, tc_id: 23)
      get :retrieve_and_store, params: params
      expect(JSON.parse(response.body)['id']).to eq s.id
    end
  end
end
