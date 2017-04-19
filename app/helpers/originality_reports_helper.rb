module OriginalityReportsHelper
  include LtiAuthorizationHelper

  def originality_report(score)
    {
      originality_report_url: 'http://www.instructure.com',
      # We just grab the last attachment for demoing
      file_id: submission.attachments.last['id'],
      originality_score: score
    }
  end

  def originality_report_creation_url
    base_url = tool_proxy_from_assignment.base_tc_url
    "#{base_url}/assignments/#{params['assignment_tc_id']}/submissions/#{params['submission_tc_id']}/originality_report"
  end

  def submission
    @_submission ||= Submission.find_by(tc_id: params['submission_tc_id'])
  end

  def assignment
    @_assignment ||= Assignment.find_by(tc_id: params['assignment_tc_id'])
  end
end
