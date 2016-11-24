class AddModeToPayments < ActiveRecord::Migration
  def change
    add_column :payments, :mode, :string, null: false, default: "test"
  end
end
