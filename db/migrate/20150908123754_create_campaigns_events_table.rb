class CreateCampaignsEventsTable < ActiveRecord::Migration
  def change
    create_table :campaigns_events, id: false do |t|
      t.integer :campaign_id
      t.integer :event_id
    end

    add_index :campaigns_events, :campaign_id
    add_index :campaigns_events, :event_id
  end
end
