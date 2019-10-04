class AddSubtotalToCashiers < ActiveRecord::Migration[5.2]
  def change
    add_column :cashiers, :user_id, :integer
    add_column :cashiers, :tax_type, :integer
    add_column :cashiers, :discount, :integer
    add_column :cashiers, :subtotal, :integer
  end
end
