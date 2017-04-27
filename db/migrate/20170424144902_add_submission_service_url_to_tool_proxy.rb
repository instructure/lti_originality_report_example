class AddSubmissionServiceUrlToToolProxy < ActiveRecord::Migration[5.0]
  def change
    add_column :tool_proxies, :submission_service_url, :string
  end
end
