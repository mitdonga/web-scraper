class AddDiscardToScrapes < ActiveRecord::Migration[7.0]
  def change
    add_column :scrapes, :discard, :boolean, default: false
  end
end
