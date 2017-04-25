class AddSubmissionServiceUrlToToolProxy < ActiveRecord::Migration[5.0]
  def change
    add_column :tool_proxies, :submission_service_url, :string
    add_column :tool_proxies, :string, :string
  end
end
