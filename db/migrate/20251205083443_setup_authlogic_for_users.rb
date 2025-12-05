class SetupAuthlogicForUsers < ActiveRecord::Migration[6.1]
  def change
    # Remove has_secure_password column
    remove_column :users, :password_digest, :string, if_exists: true
    
    # Add Authlogic columns
    add_column :users, :crypted_password, :string
    add_column :users, :password_salt, :string
    add_column :users, :persistence_token, :string
    add_column :users, :perishable_token, :string
    
    add_index :users, :persistence_token, unique: true
    add_index :users, :perishable_token, unique: true
  end
end