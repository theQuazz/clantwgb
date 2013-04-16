class SwitchNameToNicknameOnUser < ActiveRecord::Migration
  def up
    rename_column :users, :name, :nickname
  end

  def down
  end
end
