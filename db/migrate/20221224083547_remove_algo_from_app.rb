class RemoveAlgoFromApp < ActiveRecord::Migration[7.0]
  def change
		drop_table :algos, force: :cascade
  end
end
