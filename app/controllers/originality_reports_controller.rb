class OriginalityReportsController < ApplicationController
  skip_before_filter :verify_authenticity_token, only: :create
  include OriginalityReportsHelper

  def create
    head :not_found and return if submission.blank? || assignment.blank?
    response = HTTParty.post(originality_report_creation_url,
                             body: { originality_report: originality_report(4) }.to_json,
                             headers: authorization_header)
    byebug
  end
end
