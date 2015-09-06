class AddReferrerIdColumnToPayloads < ActiveRecord::Migration
  def change
    add_column :payloads, :referrer_id, :integer
  end
end
