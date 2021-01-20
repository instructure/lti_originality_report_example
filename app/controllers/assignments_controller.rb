class AssignmentsController < ApplicationController
  include AssignmentsHelper
  include LtiHelper
  skip_before_action :verify_authenticity_token, only: %i(configure update)
  after_action :allow_iframe, only: :configure
  before_action :lti_authentication, only: :configure

  # configure
  #
  # Handles rendering the configuration form in the assignment create/edit
  # page of Canvas.
  def configure
    @editing = edit_assignment?
    assignment = find_or_create_assignment(tool_proxy: tool_proxy)
    @settings = assignment.settings
  end

  # get_assignment

  # Given an lti_assignment_id, finds an assignment with a matching
  # lti_assignment_id and returns it. If no assignment is found, a
  # 404 Not Found is returned.
  #
  # params[:lti_assignment_id] - The lti_assignment_id to search with. In
  # Canvas terms, this is equivalent to an Assignment's lti_context_id.
  #

  def get_assignment
    assignment = Assignment.find_by!(lti_assignment_id: params[:lti_assignment_id])
    render json: assignment, status: :ok
  end

  # update
  #
  # Handles settings changes that happen asynchronously as
  # options from the configure page of this tool are changed by the user.
  def update
    head :unauthorized and return unless request.origin == request.base_url
    assignment = Assignment.find_by(lti_assignment_id: params[:lti_assignment_id])
    head :not_found and return unless assignment.present?
    assignment.update_attributes(settings: params.require(:settings))
    head :ok
  end
end
