require 'rails_helper'
require 'lti_spec_heler'

RSpec.describe AssignmentsHelper, type: :helper do
  include_context 'lti_spec_heler'

  describe '#lti_authentication' do
    it 'returns true if the signiture is valid'
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
