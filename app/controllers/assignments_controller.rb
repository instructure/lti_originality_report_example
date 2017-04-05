class AssignmentsController < ApplicationController
  include AssignmentsHelper
  skip_before_filter :verify_authenticity_token, only: :create
  after_action :allow_iframe, only: :create
  before_action :lti_authentication, only: :create

  def create; end
end
