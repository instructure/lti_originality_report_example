# SubmissionsController
#
# Retrieves and stores submissions from Canvas

class SubmissionsController < ApplicationController
  include SubmissionsHelper

  def retrieve_and_store
    # Get the submission
    submission = Submission.find_by(tc_id: params['tc_submission_id'])
    head :not_found and return unless submission.present?

    # Retrive the submission from Canvas
    submission_data = retrieve_submission
    head :not_found and return unless submission_data.present?

    # Set the assignments id
    submission.assignment.update_attributes(tc_id: submission_data['assignment_id'])

    # Update the submission attachment data
    submission.update_attributes(attachments: submission_data['attachments'])
    render json: submission, status: :ok
  end
end
