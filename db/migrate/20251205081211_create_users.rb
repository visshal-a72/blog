class CreateUsers < ActiveRecord::Migration[6.1]
  def change
    create_table :users do |t|
      # Login
      t.string :email, null: false
      t.string :crypted_password, null: false
      t.string :password_salt, null: false
      
      # Profile
      t.string :name
      
      # Authlogic magic columns (auto-maintained)
      t.string :persistence_token, null: false
      t.string :single_access_token  # For API access
      t.string :perishable_token     # For password reset
      
      # Session tracking
      t.integer :login_count, default: 0, null: false
      t.integer :failed_login_count, default: 0, null: false
      t.datetime :last_request_at
      t.datetime :current_login_at
      t.datetime :last_login_at
      t.string :current_login_ip
      t.string :last_login_ip
      
      t.timestamps
    end
    
    add_index :users, :email, unique: true
    add_index :users, :persistence_token, unique: true
  end
end