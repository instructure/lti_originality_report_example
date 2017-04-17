module SubmissionsHelper
  include LtiAuthorizationHelper

  def retrieve_submission
    response = HTTParty.get("http://canvas.docker/api/lti/assignments/:assignment_id/submissions/#{params[:tc_submission_id]}",
                            headers: {
                              'Authorization' => "Bearer #{access_token}"
                            })
    response.body
  end
end
