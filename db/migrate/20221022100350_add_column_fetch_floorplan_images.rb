class AddColumnFetchFloorplanImages < ActiveRecord::Migration[7.0]
  def change
		add_column :links, :fetch_floorplan_images, :boolean, default: true
  end
end
