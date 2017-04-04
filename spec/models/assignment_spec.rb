require 'rails_helper'
require 'model_spec_helper'

RSpec.describe Assignment, type: :model do
  include_context 'model_spec_helper'

  it "validates presence of 'lti_assignment_id'" do
    expect { assignment.update_attributes!(lti_assignment_id: nil) }.to raise_exception(ActiveRecord::RecordInvalid)
  end

  it "validates presence of 'tool_proxy'" do
    expect { assignment.update_attributes!(tool_proxy: nil) }.to raise_exception(ActiveRecord::RecordInvalid)
  end

  it "belongs to a 'ToolProxy'" do
    expect { tool_proxy.assignments << assignment }.not_to raise_exception
  end
end
