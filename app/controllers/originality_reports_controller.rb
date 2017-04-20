class OriginalityReportsController < ApplicationController
  skip_before_filter :verify_authenticity_token, only: :create
  include OriginalityReportsHelper

  def create
    head :not_found and return if submission.blank? || assignment.blank?

    originality_score = params['originality_score'] || Random.rand(100)

    # Do the originality report create request
    response = HTTParty.post(originality_report_creation_url,
                             body: { originality_report: originality_report(originality_score) },
                             headers: authorization_header)

    # Store the report if it was created in Canvas
    persist_originality_report(response) if response.code == 201

    render json: response.body, status: response.code
  end
end