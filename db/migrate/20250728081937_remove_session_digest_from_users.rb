class RemoveSessionDigestFromUsers < ActiveRecord::Migration[7.0]
  def change
    remove_column :users, :session_digest, :string
  end
end
