class CreateRecommends < ActiveRecord::Migration[5.2]
  def change
    create_table :recommends do |t|
      t.integer     :category_reco, null: false
      t.integer     :menu_id, null: false
      t.timestamps
    end
  end
end
