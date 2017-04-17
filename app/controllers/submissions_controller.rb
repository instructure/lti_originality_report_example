# SubmissionsController
#
# Retrieves and stores submissions from Canvas

class SubmissionsController < ApplicationController
  include SubmissionsHelper

  def retrieve_and_store
    submission_json = retrieve_submission
    byebug
    head :ok and return
  end
end
