class CreateMenus < ActiveRecord::Migration[5.2]
  def change
    create_table :menus do |t|
      t.integer     :category
      t.text        :name
      t.text        :detail
      t.integer     :price
      t.text        :image
      t.integer     :option1
      t.integer     :option2
      t.integer     :option3
      t.text        :name_zh
      t.text        :name_en
      t.text        :detail_zh
      t.text        :detail_en
      t.timestamps
    end
  end
end
