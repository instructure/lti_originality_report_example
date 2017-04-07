require 'rails_helper'
require 'lti_spec_helper'

RSpec.describe EventController, type: :controller do
  include_context 'lti_spec_helper'

  describe '#submission' do
    it 'does something' do
      post 'submission'
    end

  end

end