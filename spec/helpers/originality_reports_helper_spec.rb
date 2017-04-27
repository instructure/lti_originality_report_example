require 'rails_helper'
require 'lti_spec_helper'

# Specs in this file have access to a helper object that includes
# the OriginalityReportsHelper. For example:
#
# describe OriginalityReportsHelper do
#   describe "string concat" do
#     it "concats two strings with spaces" do
#       expect(helper.concat_strings("this","that")).to eq("this that")
#     end
#   end
# end
RSpec.describe OriginalityReportsHelper, type: :helper do
  include_context 'lti_spec_helper'
  let(:file_id) { 25 }
  let(:tc_id) { 22 }
  let(:originality_score) { 50 }
  let(:lti_assignment_id) { SecureRandom.uuid }
  let(:assignment_model) { Assignment.create!(lti_assignment_id: lti_assignment_id, tool_proxy: tool_proxy, tc_id: 3) }
  let(:submission_model) { Submission.create!(tc_id: 23, assignment: assignment_model) }
  let(:originality_report_model) { submission_model.originality_reports.create!(tc_id: tc_id, originality_score: originality_score, file_id: file_id) }
  let(:params) { { 'submission_tc_id' => submission_model.tc_id, 'assignment_tc_id' => assignment_model.tc_id, 'or_tc_id' => originality_report_model.tc_id } }
  let(:params) { { 'submission_tc_id' => submission_model.tc_id.to_s, 'assignment_tc_id' => assignment_model.tc_id.to_s, 'or_tc_id' => originality_report_model.tc_id.to_s } }
  let(:report_response) { double(body: { originality_score: originality_score, file_id: file_id, id: tc_id }.to_json) }

  before do
    allow(controller).to receive(:params) { params }
  end

  describe '#persist_originality_report' do
    it 'creates an originlaity report' do
      helper.persist_originality_report(report_response)
      expect(OriginalityReport.find_by(file_id: file_id, submission: submission_model)).not_to be_nil
    end

    it 'associates the originality report with the submission' do
      helper.persist_originality_report(report_response)
      report = OriginalityReport.find_by(file_id: file_id)
      expect(report.submission).to eq submission_model
    end

    it 'sets the originality score' do
      helper.persist_originality_report(report_response)
      report = OriginalityReport.find_by(file_id: file_id)
      expect(report.originality_score).to eq originality_score
    end

    it 'sets the file id' do
      helper.persist_originality_report(report_response)
      report = OriginalityReport.find_by(submission: submission_model)
      expect(report.file_id).to eq file_id
    end

    it 'sets the tool consumer id' do
      helper.persist_originality_report(report_response)
      report = OriginalityReport.find_by(submission: submission_model)
      expect(report.tc_id).to eq tc_id
    end
  end

  describe '#originality_report' do
    it 'includes an originality report url' do
      report = helper.originality_report_json(score: originality_score)
      expect(report[:originality_report_url]).not_to be_blank
    end

    it 'includes the a file id' do
      submission.attachments = [{ 'id' => 44 }]
      report = helper.originality_report_json(score: originality_score)
      expect(report[:file_id]).to eq 44
    end

    it 'uses the specified originality score' do
      report = helper.originality_report_json(score: originality_score)
      expect(report[:originality_score]).to eq originality_score
    end

    it 'sets the score to nil if not provied' do
      report = helper.originality_report_json
      expect(report[:originality_score]).to eq nil
    end

    it 'sets the workflow state' do
      report = helper.originality_report_json(workflow_state: 'pending')
      expect(report[:workflow_state]).to eq 'pending'
    end
  end

  describe '#originality_report_creation_url' do
    it 'creates the proper url' do
      tool_proxy.update_attributes(report_service_url: 'http://www.test.com/{assignment_id}/{submission_id}')
      expect(helper.originality_report_creation_url).to eq "http://www.test.com/#{assignment_model.tc_id}/#{submission_model.tc_id}"
    end
  end

  describe '#submission' do
    it 'finds the correct submission' do
      expect(helper.submission).to eq submission_model
    end
  end

  describe '#assignment' do
    it 'finds the correct assignment' do
      expect(helper.assignment).to eq assignment_model
    end
  end

  describe '#originality_report' do
    it 'finds the correct originality report' do
      expect(helper.originality_report).to eq originality_report_model
    end
  end
end
