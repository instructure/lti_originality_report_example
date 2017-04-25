module OriginalityReportsHelper
  include LtiAuthorizationHelper

  # persist_originality_report
  #
  # Saves an originality report in the tool's
  # DB.
  def persist_originality_report(report_resposne)
    parsed_body = JSON.parse(report_resposne.body)
    submission.originality_reports.create!(
      originality_score: parsed_body['originality_score'],
      file_id: parsed_body['file_id'],
      tc_id: parsed_body['id']
    )
  end

  # originality_report_json
  #
  # Returns the originality report object
  # used to create a report via the Canvas
  # API. See the Canvas API for required
  # and non-required fields.
  def originality_report_json(score)
    {
      originality_report_url: 'http://www.instructure.com',
      # We just grab the last attachment for demoing
      file_id: submission.attachments&.last&.fetch('id'),
      originality_score: score
    }
  end

  # originality_report_edit_url
  #
  # Returns Canvas originality report
  # edit endpoint. Note this was sent in the
  # tool consumer profile during registration
  # and saved.
  def originality_report_edit_url
    "#{originality_report_creation_url}/#{params['or_tc_id']}"
  end

  # originality_report_creation_url
  #
  # Returns Canvas originality report
  # edit endpoint. Note this was sent in the
  # tool consumer profile during registration
  # and saved.
  def originality_report_creation_url
    template = assignment.tool_proxy.report_service_url
    template&.gsub!('{assignment_id}', params['assignment_tc_id'])
    template&.gsub!('{submission_id}', params['submission_tc_id'])
    template
  end

  # submission
  #
  # Returns the submission identified by the
  # request parameters.
  def submission
    @_submission ||= Submission.find_by(tc_id: params['submission_tc_id'])
  end

  # assignment
  #
  # Returns the assignment identified by the
  # request parameters.
  def assignment
    @_assignment ||= Assignment.find_by(tc_id: params['assignment_tc_id'])
  end

  # originality_report
  #
  # Returns the originality_report identified by the
  # request parameters.
  def originality_report
    @_originality_report ||= OriginalityReport.find_by(tc_id: params['or_tc_id'])
  end
end
