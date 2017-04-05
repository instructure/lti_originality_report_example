class AssignmentsController < ApplicationController
  include AssignmentsHelper
  skip_before_filter :verify_authenticity_token, only: :configure
  after_action :allow_iframe, only: :configure
  before_action :lti_authentication, only: :configure

  def configure
    @editing = edit_assignment?
    find_or_create_assignment
  end
end
