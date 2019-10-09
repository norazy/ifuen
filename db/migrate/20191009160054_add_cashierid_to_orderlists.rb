class AddCashieridToOrderlists < ActiveRecord::Migration[5.2]
  def change
    add_column :orderlists, :cashier_id, :integer
  end
end
