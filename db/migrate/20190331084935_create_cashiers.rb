class CreateCashiers < ActiveRecord::Migration[5.2]
  def change
    create_table :cashiers do |t|
      t.integer     :total, null: false
      t.integer     :method, null: false
      t.timestamps
    end
  end
end
