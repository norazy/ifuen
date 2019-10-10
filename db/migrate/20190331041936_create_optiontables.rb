class CreateOptiontables < ActiveRecord::Migration[5.2]
  def change
    create_table :optiontables do |t|
      t.text        :name_opt
      t.integer     :price_opt
      t.text        :name_opt_zh
      t.text        :name_opt_en
      t.timestamps
    end
  end
end
