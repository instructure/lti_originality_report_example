class SubmissionsController < ApplicationController
  include LtiHelper
  include SubmissionsHelper

  skip_before_action :verify_authenticity_token, only: :index
  after_action :allow_iframe, only: :index
  before_action :lti_authentication, only: :index

  # retrieve_and_store
  #
  # retrieves the following submission data from Canvas
  # after a submission is received via webhook:
  #
  # assignment_id - before this point the actual ID of the
  # assignment is not known. This data is contained in the
  # payload of the Canvas submission endpoint which is used
  # in this method.
  #
  # attachments - data reguarding the attachments is needed to
  # retrieve submission attachments for processing. This data
  # is also in the Canvas submission endpoint payload.
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

  # get_submission

  # Given a tool consumer submission id, determines if the tool has an existing
  # submission record in its database, and returns it if it does. Otherwise
  # returns Not Found.

  # params[:tc_submission_id] - The tool consumer id to use when searching. In Canvas
  # terms, a tool consumer submission id is equivalent to a Canvas Submission's
  # global_id.
  #

  def show_by_tc_id
    submission = Submission.find_by!(tc_id: params[:tc_submission_id])
    render json: submission, status: :ok
  end

  # index
  #
  # presents a list of submissions received via webhook
  def index
    @submissions = tool_proxy.submissions
  end
end
