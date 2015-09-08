class CreateCampaignsTable < ActiveRecord::Migration
  def change
    create_table :campaigns do |t|
      t.string :name

      t.timestamps null: true
    end
  end
end
