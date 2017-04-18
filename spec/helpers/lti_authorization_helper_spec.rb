require 'rails_helper'

# Specs in this file have access to a helper object that includes
# the SubmissionsHelper. For example:
#
# describe SubmissionsHelper do
#   describe "string concat" do
#     it "concats two strings with spaces" do
#       expect(helper.concat_strings("this","that")).to eq("this that")
#     end
#   end
# end
RSpec.describe LtiAuthorizationHelper, type: :helper do
  let(:random_access_token) { SecureRandom.uuid }
  let(:tp_guid) { SecureRandom.uuid }
  let(:params) { { tool_proxy_guid: tp_guid } }
  let(:request) { double(base_url: 'http://www.base-url.com') }
  let(:auth_url) { 'http://www.test.com/authorize' }
  let(:secret) { 'secret' }

  before do
    allow(controller).to receive(:params).and_return(params)
    allow_any_instance_of(IMS::LTI::Services::AuthenticationService).to receive(:access_token) { random_access_token }
    @tp = ToolProxy.create!(guid: tp_guid,
                      shared_secret: secret,
                      tcp_url: 'tcp-url',
                      base_url: 'base-url',
                      authorization_url: auth_url)
  end

  describe '#access_token' do
    it 'returns the access token from the authentication service' do
      expect(helper.access_token).to eq random_access_token
    end
  end

  describe '#authentication_service' do
    it "Uses the request base_url for 'iss" do
      expect(helper.authentication_service.iss).to eq 'http://test.host'
    end

    it "Uses the authoirzaiton url for the 'aud'" do
      expect(helper.authentication_service.aud).to eq auth_url
    end

    it "Uses the tool proxy guid for the 'sub'" do
      expect(helper.authentication_service.sub).to eq tp_guid
    end

    it 'Uses the tool proxy shared secret for signing' do
      expect(helper.authentication_service.secret).to eq secret
    end
  end

  describe '#tool_proxy_from_params' do
    it 'finds the tool proxy identified by the guid in params' do
      expect(helper.tool_proxy_from_params).to eq @tp
    end
  end

end
