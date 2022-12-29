class AddDiscaredAtColumnToScrapes < ActiveRecord::Migration[7.0]
  def change
		add_column :scrapes, :discarded_at, :datetime
		remove_column :scrapes, :discard
  end
end
