require 'rails_helper'
require 'lti_spec_helper'

RSpec.describe AssignmentsHelper,
 type: :helper do
  include_context 'lti_spec_helper'
  let(:shared_secret) { 'e5bf61debb355e4552732a943c74801ee02bc24ef1d6a077c6e68363fb9dcc4dceab75e6ae4f1e6ae9df5a6892ebbabe49feecc67f00f7e447b43f270e115c590533cd9a176a23eaba334834180da227521884bb49fae1993ca15d52c077b7d37d2ab6fd924a86a285f438f2fc161f63806468d1b977ff120635aa70f9d1d7a5' }
  let(:tp_guid) { '6c13a735-7981-48db-b9ff-8d67dfcc4e7c' }
  let(:request_parameters) do
    {
      oauth_callback: 'about:blank',
      oauth_consumer_key: tp_guid,
      oauth_nonce: '55fcaa93ff0f1cde699b98d656a123f1',
      oauth_signature_method: 'HMAC-SHA1',
      oauth_timestamp: '1491575331',
      oauth_version: '1.0',
      oauth_signature: 'JTC8tJNRMVfqYPL4mxYSzrOMsRc=',
      ext_lti_assignment_id: '518d3adf-f3ac-47c6-b2ff-618c4d8fcec3',
      lti_message_type: 'basic-lti-launch-request',
      lti_version: 'LTI-2p0',
      resource_link_id: 'a6b5a5f44902018e4e257fe89fd5a285a0b37dad',
      user_id: '14e94b100f487430355fd888cf3d298ae474188b'
    }
  end
  let(:url) { 'http://www.request-url.com' }
  let(:request) { double(url: url, request_parameters: request_parameters) }
  let(:params) { {'oauth_consumer_key' => tp_guid} }

  describe '#lti_authentication' do
    before do
      ToolProxy.create!(shared_secret: shared_secret, guid: tp_guid, tcp_url: 'test.com', base_url: 'base.com')
      allow(helper).to receive(:not_expired?) { true }
    end

    it 'returns true if the signiture is valid' do
      expect(helper.lti_authentication).to be_truthy
    end

    it 'renders unathorized if the signature is invalid'
  end

  describe '#message' do
    it 'sets the launch url to the request url'
  end

  describe '#shared_secret' do
    it 'returns the tool proxy shared secret'
  end

  describe '#not_expired?' do
    it 'returns true if the request is not expired'
    it 'returns false if the request is expired'
  end

  describe '#tool_proxy' do
    it 'finds the correct tool proxy'
  end

  describe '#edit_assignment?' do
    it 'returns true if the assignment configuration is being edited'
    it 'returns false if the assignment configuration is being created'
  end

  describe '#existing_assignment' do
    it 'finds the correct assignment'
  end

  describe '#find_or_create_assignment' do
    it 'returns the assignment if it exists'
    it 'creates a new assignment if it does not exist'
    it 'correctly sets the lti_assignent_id'
    it 'associates the assignment with a tool proxy'
  end
end
