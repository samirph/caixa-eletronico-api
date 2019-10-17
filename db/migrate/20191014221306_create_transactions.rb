class CreateTransactions < ActiveRecord::Migration[6.0]
  def change
    create_table :transactions do |t|
      t.decimal :operation_value
      t.string :operation_type
      t.decimal :previous_origin_balance
      t.decimal :previous_target_balance
      t.references :origin_account
      t.references :target_account

      t.timestamps
    end
  end
end
