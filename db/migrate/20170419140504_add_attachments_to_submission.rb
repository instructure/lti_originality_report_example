class AddAttachmentsToSubmission < ActiveRecord::Migration[5.0]
  def change
    add_column :submissions, :attachments, :text
  end
end
