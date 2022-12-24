class AddAlgoIdToScrapes < ActiveRecord::Migration[7.0]
  def change
    add_reference :scrapes, :algo, null: false, foreign_key: true, default: 1
  end
end
