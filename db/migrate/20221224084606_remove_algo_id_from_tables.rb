class RemoveAlgoIdFromTables < ActiveRecord::Migration[7.0]
  def change
		remove_column :links, :algo_id
		remove_column :scrapes, :algo_id
  end
end
