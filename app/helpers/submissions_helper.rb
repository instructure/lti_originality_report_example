module SubmissionsHelper
  include LtiAuthorizationHelper

  # retrieve_submission
  #
  # Retrieve a submission and its details via the submission
  # service endpoint provided in the tool consumer profile.
  def retrieve_submission
    template = tool_proxy_from_guid.submission_service_url
    template&.gsub!('{submission_id}', params[:tc_submission_id])
    template&.gsub!('{assignment_id}', 'assignment_id')
    response = HTTParty.get(template, headers: { 'Authorization' => "Bearer #{access_token}" })
    JSON.parse(response.body)
  end
end
