class ChangeUsersPasswordColumns < ActiveRecord::Migration[6.1]
  def change
    # First add column without NOT NULL constraint
    add_column :users, :password_digest, :string
    
    # Remove old Authlogic columns
    remove_column :users, :crypted_password, :string
    remove_column :users, :password_salt, :string
  end
end