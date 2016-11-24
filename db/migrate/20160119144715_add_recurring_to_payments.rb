class AddRecurringToPayments < ActiveRecord::Migration
  def change
    add_column :payments, :recurring, :boolean, null: false, default: false
  end
end
