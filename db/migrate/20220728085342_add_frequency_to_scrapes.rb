class AddFrequencyToScrapes < ActiveRecord::Migration[7.0]
  def change
    add_column :scrapes, :frequency, :integer
  end
end
