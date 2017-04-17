require 'rails_helper'
require 'lti_spec_helper'

RSpec.describe AssignmentsHelper,
type: :helper do
  include_context 'lti_spec_helper'
  let(:secret) { 'e5bf61debb355e4552732a943c74801ee02bc24ef1d6a077c6e68363fb9dcc4dceab75e6ae4f1e6ae9df5a6892ebbabe49feecc67f00f7e447b43f270e115c590533cd9a176a23eaba334834180da227521884bb49fae1993ca15d52c077b7d37d2ab6fd924a86a285f438f2fc161f63806468d1b977ff120635aa70f9d1d7a5' }
  let(:tp_guid) { '6c13a735-7981-48db-b9ff-8d67dfcc4e7c' }
  let(:time_now) { '1491575331' }
  let(:request_parameters) do
    {
      oauth_callback: 'about:blank',
      oauth_consumer_key: tp_guid,
      oauth_nonce: '55fcaa93ff0f1cde699b98d656a123f1',
      oauth_signature_method: 'HMAC-SHA1',
      oauth_timestamp: time_now,
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
  let(:params) { { 'oauth_consumer_key' => tp_guid } }

  before do
    ToolProxy.create!(shared_secret: secret,
                      guid: tp_guid,
                      tcp_url: 'test.com',
                      base_url: 'base.com')
    allow(controller).to receive(:params).and_return(params)
  end

  describe '#lti_authentication' do
    before do
      allow(helper).to receive(:not_expired?) { true }
    end

    it 'returns true if the signiture is valid' do
      allow(IMS::LTI::Services::OAuth1MessageAuthenticator).to receive(:new) { double(valid_signature?: true) }
      expect(helper.lti_authentication).to be_truthy
    end

    it 'renders unathorized if the signature is invalid' do
      expect { helper.lti_authentication }.to raise_exception NoMethodError
    end
  end

  describe '#message' do
    it 'sets the launch url to the request url' do
      expect(helper.message.launch_url).to eq 'http://test.host'
    end
  end

  describe '#shared_secret' do
    it 'returns the tool proxy shared secret' do
      expect(helper.shared_secret).to eq shared_secret
    end
  end

  describe '#not_expired?' do
    it 'returns true if the request is not expired' do
      allow(helper).to receive(:params) { { 'oauth_timestamp' => time_now } }
      allow(Time).to receive(:now) { Time.at(time_now.to_i) }
      expect(helper.not_expired?).to be_truthy
    end

    it 'returns false if the request is beyond 5 minutes old' do
      allow(helper).to receive(:params) { { 'oauth_timestamp' => time_now } }
      allow(Time).to receive(:now) { Time.at(time_now.to_i - 6.minutes.to_i) }
      expect(helper.not_expired?).not_to be_truthy
    end

    it 'returns false if the request is too far into the future' do
      allow(helper).to receive(:params) { { 'oauth_timestamp' => time_now } }
      expect(helper.not_expired?).not_to be_truthy
    end
  end

  describe '#tool_proxy' do
    it 'finds the correct tool proxy' do
      expect(helper.tool_proxy.guid).to eq tp_guid
    end
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
      expect(helper.find_or_create_assignment).to eq a
    end

    it 'correctly sets the lti_assignent_id when creating an assignment' do
      expect(helper.find_or_create_assignment.lti_assignment_id).to eq @lti_assignment_id
    end

    it 'associates the assignment with a tool proxy' do
      expect(helper.find_or_create_assignment.tool_proxy.guid).to eq tp_guid
    end
  end
end
