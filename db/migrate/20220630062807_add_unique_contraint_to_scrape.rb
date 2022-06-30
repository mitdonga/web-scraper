class AddUniqueContraintToScrape < ActiveRecord::Migration[7.0]
  def change
    add_index :scrapes, :name, unique: true
  end
end
