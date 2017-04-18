require 'rails_helper'
require 'lti_spec_helper'

RSpec.describe AssignmentsHelper, type: :helper do
  include_context 'lti_spec_helper'
  let(:secret) { 'e5bf61debb355e4552732a943c74801ee02bc24ef1d6a077c6e68363fb9dcc4dceab75e6ae4f1e6ae9df5a6892ebbabe49feecc67f00f7e447b43f270e115c590533cd9a176a23eaba334834180da227521884bb49fae1993ca15d52c077b7d37d2ab6fd924a86a285f438f2fc161f63806468d1b977ff120635aa70f9d1d7a5' }
  let(:tp_guid) { '6c13a735-7981-48db-b9ff-8d67dfcc4e7c' }
  let(:params) { { 'oauth_consumer_key' => tp_guid } }
  let!(:tp) do
    ToolProxy.create!(shared_secret: secret,
                      guid: tp_guid,
                      tcp_url: 'test.com',
                      base_url: 'base.com')
  end

  before do
    allow(controller).to receive(:params).and_return(params)
  end

  describe '#edit_assignment?' do
    let(:lti_assignment_id) { SecureRandom.uuid }
    before do
      allow(controller).to receive(:params) { { 'ext_lti_assignment_id' => lti_assignment_id }.merge(params) }
    end

    it 'returns true if the assignment configuration is being edited' do
      Assignment.create!(tool_proxy: ToolProxy.last, lti_assignment_id: lti_assignment_id)
      expect(helper.edit_assignment?).to be_truthy
    end

    it 'returns false if the assignment configuration is being created' do
      expect(helper.edit_assignment?).not_to be_truthy
    end
  end

  describe '#find_or_create_assignment' do
    before do
      @lti_assignment_id = SecureRandom.uuid
      allow(controller).to receive(:params) { { 'ext_lti_assignment_id' => @lti_assignment_id }.merge(params) }
    end

    it 'returns the assignment if it exists' do
      a = Assignment.create!(tool_proxy: ToolProxy.last, lti_assignment_id: @lti_assignment_id)
      expect(helper.find_or_create_assignment(tool_proxy: tool_proxy)).to eq a
    end

    it 'correctly sets the lti_assignent_id when creating an assignment' do
      expect(helper.find_or_create_assignment(tool_proxy: tool_proxy).lti_assignment_id).to eq @lti_assignment_id
    end

    it 'associates the assignment with a tool proxy' do
      expect(helper.find_or_create_assignment(tool_proxy: tp).tool_proxy.guid).to eq tp_guid
    end
  end
end
