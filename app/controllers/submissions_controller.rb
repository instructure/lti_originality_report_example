# SubmissionsController
#
# Retrieves and stores submissions from Canvas

class SubmissionsController < ApplicationController
  include SubmissionsHelper

  def retrieve_and_store
    # Find the assignment by lti_context_id
    assignment = Assignment.find_by(lti_assignment_id: params[:lti_assignment_id])
    head :not_found and return unless assignment.present?

    # Get the submission if it's already been created
    submission = Submission.find_by(tc_id: params[:tc_submission_id])

    if submission.blank?
      # Retrive the submission from Canvas
      submission_data = retrieve_submission
      head :not_found and return unless submission_data.present?

      # Set the assignments id
      assignment.update_attributes(tc_id: submission_data['assignment_id'])

      # Persist the submission
      submission = assignment.submissions.create!(tc_id: submission_data['id'])
    end

    render json: submission, status: :ok
  end
end
