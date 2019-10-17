class CreateAccounts < ActiveRecord::Migration[6.0]
  def change
    create_table :accounts do |t|
      t.decimal :balance, :precision => 2, :scale => 2, :default => 0
      t.string :number
      t.integer :status, :limit => 2
      t.references :user

      t.timestamps
    end
  end
end
