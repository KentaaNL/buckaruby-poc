class CreatePayments < ActiveRecord::Migration
  def change
    create_table :payments do |t|
      t.decimal :amount, null: false, precision: 8, scale: 2
      t.string :description

      t.string :transaction_id
      t.string :payment_id

      t.string :payment_method
      t.string :payment_issuer

      t.string :payment_account_name
      t.string :payment_account_iban

      t.integer :status

      t.datetime :started_at
      t.datetime :paid_at
      t.datetime :cancelled_at
      t.datetime :failed_at
      t.datetime :charged_back_at

      t.timestamps
    end
  end
end
