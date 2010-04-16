class CreateLocations < ActiveRecord::Migration
  def self.up
    create_table :locations do |t|
      t.decimal :lat, :precision => 15, :scale => 10
      t.decimal :lng, :precision => 15, :scale => 10
      t.float :distance
      t.integer :taggable_id
      t.string :taggable_type
      t.timestamps
    end
  end
  
  def self.down
    drop_table :locations
  end
end
