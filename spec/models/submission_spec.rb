require 'rails_helper'
require 'model_spec_helper'

RSpec.describe Submission, type: :model do
  include_context 'model_spec_helper'

  it "validates presence of 'tc_id'" do
    expect { submission.update_attributes!(tc_id: nil) }.to raise_exception(ActiveRecord::RecordInvalid)
  end

  it "validates presence of 'assignment'" do
    expect { submission.update_attributes!(assignment: nil) }.to raise_exception(ActiveRecord::RecordInvalid)
  end

  it 'has one originality report' do
    expect { submission.originality_report = originality_report }.not_to raise_exception
  end
end
