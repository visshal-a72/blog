class RemoveAuthlogicColumnsFromUsers < ActiveRecord::Migration[6.1]
  def change
    remove_index :users, :persistence_token, if_exists: true
    
    remove_column :users, :persistence_token, :string
    remove_column :users, :single_access_token, :string
    remove_column :users, :perishable_token, :string
    remove_column :users, :login_count, :integer
    remove_column :users, :failed_login_count, :integer
    remove_column :users, :last_request_at, :datetime
    remove_column :users, :current_login_at, :datetime
    remove_column :users, :last_login_at, :datetime
    remove_column :users, :current_login_ip, :string
    remove_column :users, :last_login_ip, :string
  end
end