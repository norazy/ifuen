Rails.application.routes.draw do
scope '(:locale)', locale: /#{I18n.available_locales.map(&:to_s).join('|')}/ do

    devise_for :users
#     # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
    root 'orderlist#first'
    
#     # get 'api/test' => 'orderlist#test'
    get 'firstpage' => 'orderlist#first'
#     # get 'toptest' => 'orderlist#top_test'

    # オーダーページ
      # 各メニューページ 
    get 'order/top' => 'orderlist#top_page'
    get 'order/set_menu' => 'orderlist#set_menu'
    get 'order/alacarte_menu' => 'orderlist#alacarte'
    get 'order/noodle_menu' => 'orderlist#noodle'
    get 'order/rice_menu' => 'orderlist#rice'
    get 'order/dessert_menu' => 'orderlist#dessert'
    get 'order/drink_menu' => 'orderlist#drink'
    get 'order/recommend_menu' => 'orderlist#recommend'
    get 'order/search' => 'orderlist#search'
    post 'order/cashier' => 'orderlist#call_cashier'
    post 'order/staff' => 'orderlist#call_staff'

      # 注文確認ページ
    get 'order/pre_order/:id' => 'orderlist#pre_order'
    delete 'order/pre_order/:id' => 'orderlist#delete_preorder', as: 'delete_preorder'
    post 'order/pre_order' => 'orderlist#post_order'
    get 'order/ordered/:id' => 'orderlist#ordered'


    get 'order/modal/:id' => 'orderlist#modal', as: 'order_indiv'
    post 'order/modal_order' => 'orderlist#order_create'
    
    # キッチン側のページ
      # テーブル状態一覧
    get 'kitchen/table' => 'kitchen#table_kitchen'
    
      # 通知一覧
    get 'kitchen/notification' => 'kitchen#notification'
    delete 'kitchen/notification/:id' => 'kitchen#destroy', as: 'notification_destroy'
    
      # 調理待一覧
    get 'kitchen/ordered' => 'kitchen#ordered_kitchen'
    delete 'kitchen/forcook/:id' => 'kitchen#destroy_order', as: 'forcook_destroy'
    post 'kitchen/cooked/:id' => 'kitchen#change_state', as: 'change_to_cooked'
    post 'kitchen/served/:id' => 'kitchen#change_state2', as: 'change_to_served'

      # 注文一覧
    get 'kitchen/served' => 'kitchen#served'

      # オプション追加一覧
    get 'kitchen/option_change' => 'kitchen#option_change'
    post 'kitchen/option_change' => 'kitchen#post_option'
    
    # 会計ページ
    get 'cashier/table' => 'cashier#table_cashier'
    get 'cashier/:id' => 'cashier#check_page'
    post 'cashier/paid' => 'cashier#paid'
    
    # 統計ページ
    get 'statistics/sales' => 'statistics#sales'
    get 'statistics/ranking' => 'statistics#ranking'
    delete 'statistics/delete_data' => 'statistics#delete_data', as: 'ranking_data_destroy'
    get 'statistics/csv' => 'statistics#csv'
    
    # メニュー追加
    get 'statistics/addmenu' => 'statistics#add_menu'
    post 'statistics/addmenu' => 'statistics#post_menu'
  end 
end
