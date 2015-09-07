class CreateReferrersTable < ActiveRecord::Migration
  def change
    create_table :referrers do |t|
      t.text :referred_by

      t.timestamps null: false
    end
  end
end
