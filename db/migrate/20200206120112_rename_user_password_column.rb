class RenameUserPasswordColumn < ActiveRecord::Migration[6.0]
  def up
    change_table :users, bulk: true do |t|
      t.rename :encrypted_password, :password_digest
      t.change_default :email, nil
      t.change_default :password_digest, nil
    end
  end

  def down
    change_table :users, bulk: true do |t|
      t.rename :password_digest, :encrypted_password
      t.change_default :email, ''
      t.change_default :encyrpted_password, ''
    end
  end
end
