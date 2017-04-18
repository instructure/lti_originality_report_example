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
RSpec.describe SubmissionsHelper, type: :helper do
  describe '#retrieve_submission' do
    let(:tp_guid) { SecureRandom.uuid }
    let(:params) { { tool_proxy_guid: tp_guid } }
    let(:access_token) { SecureRandom.uuid }
    let(:submission_data) { { 'id' => 1, 'assignment_id' => 2 } }

    before do
      allow(HTTParty).to receive(:get) { double(body: submission_data.to_json ) }
      allow(helper).to receive(:access_token) { access_token }
      allow(controller).to receive(:params).and_return(params)
    end

    it 'retrives a submission' do
      ToolProxy.create!(guid: tp_guid,
                        shared_secret: 'secret',
                        tcp_url: 'tcp-url',
                        base_url: 'base-url',
                        authorization_url: 'http://www.test.com/authorize')

      expect(helper.retrieve_submission).to eq submission_data
    end
  end
end
