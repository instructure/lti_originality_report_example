module SubmissionsHelper
  include LtiAuthorizationHelper

  def retrieve_submission
    url = "#{tool_proxy_from_params.base_tc_url}/api/lti/assignments/:assignment_id/submissions/#{params[:tc_submission_id]}"
    response = HTTParty.get(url, headers: { 'Authorization' => "Bearer #{access_token}" })
    JSON.parse(response.body)
  end
end
