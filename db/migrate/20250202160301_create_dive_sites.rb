class CreateDiveSites < ActiveRecord::Migration[7.2]
  def change
    create_table :dive_sites do |t|
      t.string :name
      t.float :latitude
      t.float :longitude
      t.references :country, foreign_key: true
      t.timestamps
    end
  end
end
