class CreateSubmissions < ActiveRecord::Migration[5.0]
  def change
    create_table :submissions do |t|
      t.integer :tc_id, null:false
      t.timestamps
    end

    add_index :submissions, [:tc_id]
  end
end
