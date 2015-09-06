class AddRequestTypeColumnToResponses < ActiveRecord::Migration
  def change
    add_column :responses, :request_type, :text
  end
end
