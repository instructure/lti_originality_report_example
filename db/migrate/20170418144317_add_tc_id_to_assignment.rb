class AddTcIdToAssignment < ActiveRecord::Migration[5.0]
  def change
    add_column :assignments, :tc_id, :integer
    add_index :assignments, [:tc_id]
  end
end
