class AssignmentsController < ApplicationController
  include AssignmentsHelper
  skip_before_filter :verify_authenticity_token, only: [:configure, :update]
  after_action :allow_iframe, only: :configure
  before_action :lti_authentication, only: :configure

  # configure
  #
  # Handles rendering the configuration form in the assignment create/edit
  # page of Canvas.
  def configure
    @editing = edit_assignment?
    assignment = find_or_create_assignment
    @settings = assignment.settings
  end

  # update
  #
  # Handles settings changes that happen asynchronously as
  # options from the configure page of this tool are changed by the user.
  def update
    assignment = Assignment.find_by(lti_assignment_id: params[:lti_assignment_id])
    head :not_found and return unless assignment.present?
    assignment.update_attributes(settings: params.require(:settings))
    head :ok
  end
end
