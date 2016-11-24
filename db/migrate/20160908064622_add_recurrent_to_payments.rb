class AddRecurrentToPayments < ActiveRecord::Migration
  def change
    add_column :payments, :recurrent, :boolean, null: false, default: false
  end
end
