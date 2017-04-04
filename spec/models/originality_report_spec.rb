require 'rails_helper'
require 'model_spec_helper'

RSpec.describe OriginalityReport, type: :model do
  include_context 'model_spec_helper'

  it "validates presence of 'originality_score'" do
    expect { originality_report.update_attributes!(originality_score: nil) }.to raise_exception(ActiveRecord::RecordInvalid)
  end

  it "validates presence of 'file_id'" do
    expect { originality_report.update_attributes!(file_id: nil) }.to raise_exception(ActiveRecord::RecordInvalid)
  end

  it "validates presence of 'tc_id'" do
    expect { originality_report.update_attributes!(tc_id: nil) }.to raise_exception(ActiveRecord::RecordInvalid)
  end

  it "validates presence of 'submission'" do
    expect { originality_report.update_attributes!(submission: nil) }.to raise_exception(ActiveRecord::RecordInvalid)
  end

  it "verifies 'originality_score' is between 0 and 100" do
    expect { originality_report.update_attributes!(originality_score: 101) }.to raise_exception(ActiveRecord::RecordInvalid)
  end
end
