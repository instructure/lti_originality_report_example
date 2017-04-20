module OriginalityReportsHelper
  include LtiAuthorizationHelper

  def persist_originality_report(report_resposne)
    parsed_body = JSON.parse(report_resposne.body)
    submission.originality_reports.create!(
      originality_score: parsed_body['originality_score'],
      file_id: parsed_body['file_id'],
      tc_id: parsed_body['id']
    )
  end

  def originality_report_json(score)
    {
      originality_report_url: 'http://www.instructure.com',
      # We just grab the last attachment for demoing
      file_id: submission.attachments&.last&.fetch('id'),
      originality_score: score
    }
  end

  def originality_report_edit_url
    base_url = tool_proxy_from_assignment.base_tc_url
    "#{base_url}/api/lti/assignments/#{params['assignment_tc_id']}"\
    "/submissions/#{params['submission_tc_id']}/originality_report/#{params['or_tc_id']}"
  end

  def originality_report_creation_url
    base_url = tool_proxy_from_assignment.base_tc_url
    "#{base_url}/api/lti/assignments/#{params['assignment_tc_id']}/submissions/#{params['submission_tc_id']}/originality_report"
  end

  def submission
    @_submission ||= Submission.find_by(tc_id: params['submission_tc_id'])
  end

  def assignment
    @_assignment ||= Assignment.find_by(tc_id: params['assignment_tc_id'])
  end

  def originality_report
    @_originality_report ||= OriginalityReport.find_by(tc_id: params['or_tc_id'])
  end
end
