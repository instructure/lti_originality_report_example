class OriginalityReportsController < ApplicationController
  skip_before_filter :verify_authenticity_token, only: %i(create update)
  include OriginalityReportsHelper

  # create
  #
  # Creates an originality report in Canvas and persists
  # an report in the tool if succesfull.
  def create
    head :not_found and return if submission.blank? || assignment.blank?

    originality_score = params['originality_score'].present? ? params['originality_score'] : nil
    workflow_state = originality_score.blank? ? 'pending' : nil

    # Do the originality report create request
    response = HTTParty.post(originality_report_creation_url,
                             body: { originality_report: originality_report_json(score: originality_score,                                            workflow_state: workflow_state) },
                             headers: authorization_header)

    # Store the report if it was created in Canvas
    persist_originality_report(response) if response.code == 201

    render json: response.body, status: response.code
  end

  # update
  #
  # Updates an originality report in Canvas and the tool.
  def update
    if submission.blank? || assignment.blank? || originality_report.blank?
      head :not_found and return
    end

    response = HTTParty.put(originality_report_edit_url,
                            body: { originality_report: originality_report_json(params['originality_score']) },
                            headers: authorization_header)

    if response.code == 200
      originality_report.update_attributes(originality_score: JSON.parse(response.body)['originality_score'])
    end

    render json: response.body, status: response.code
  end
end
