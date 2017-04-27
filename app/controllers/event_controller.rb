class EventController < ApplicationController
  skip_before_action :verify_authenticity_token

  # submission
  #
  # Creates a submission for the specified assignment when a
  # webhook is received.
  def submission
    json = JSON.parse(request.body.read)
    assignment = Assignment.find_by(lti_assignment_id: json['body']['lti_assignment_id'])
    assignment.submissions.create(tc_id: json['body']['submission_id'])
    head :ok
  end
end
