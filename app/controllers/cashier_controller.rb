class CashierController < ApplicationController
    # サインインしているかどうかのチェック
    before_action :move_to_signin 

    # 会計ができるテーブルを表示する
    def table_cashier
        # ↓各テーブルの状態を入れておく配列
        @color = []
        number = 1
        # テーブルの回数だけ繰り返す
        while number <= 16 do
            # テーブル番号があるか
            if Orderlist.where(user_id: number).exists?
                # 今のテーブルのオーダーを全部抜き出す
                eachtable = Orderlist.where(user_id: number).where.not(:state => 4)

                # 状態が１のオーダーがあったら
                # if eachtable.exists?(:state => [0, 1, 2])
                if eachtable.exists?(:state => [0, 1])
                    color = 1
                elsif eachtable.exists?(:state => 3)
                    color = 2
                else
                    color = 0
                end
            # #テーブル番号がなかったら 
            else
                color = 0
            end
            @color << color
            number += 1
        end
    end
    
    # 各テーブルの計算
    def check_page
        @table_id = params[:id]
        # テーブル番号

        orderlist = Orderlist.where(user_id: params[:id]).where(state: 3)
        # 会計が必要なオーダーを全部入れる配列
        @forcheck = []

        # あとでメニューやオプションごとにオーダーをまとめたいので、
        # 2つの配列を作る
        menu_info = []
        option_info = []
        # それぞれのオーダーのmenu_idと数を取り出して、ハッシュに入れて配列に入れる
        orderlist.each do |each_order|
            if each_order.menu_id then
                hash2 = {}
                hash2[:menu_id] = each_order.menu_id
                hash2[:number] = each_order.number
                menu_info << hash2
            else
                hash2 = {}
                hash2[:option_id] = each_order.option_id
                hash2[:number] = each_order.number
                option_info << hash2
            end
        end

        # 同じmenu_idの数をまとめて、再度配列を作る
        menu_info2 = menu_info.group_by {|item| item[:menu_id] }.map do |menu_id,items|
            total_points = items.map{|item| item[:number]}.reduce(0, :+)
            {
                :menu_id => menu_id,    
                :number => total_points
            }
        end
        # menu_idの名前と価格を取ってきて
        # viewに渡す変数に入れる
        menu_info2.each do |order|
            hash = {}
            hash[:number] = order[:number]
            menu_id = order[:menu_id]
            menu = Menu.find(menu_id)
            hash[:menu_name] = menu.name
            hash[:menu_name_zh] = menu.name_zh
            hash[:price] = menu.price
            @forcheck << hash
        end
        
        if option_info then
            option_info2 = option_info.group_by {|item| item[:option_id] }.map do |option_id,items|
                total_points = items.map{|item| item[:number]}.reduce(0, :+)
                {
                    :option_id => option_id,
                    :number => total_points
                }
            end
            option_info2.each do |order|
                hash = {}
                hash[:number] = order[:number]
                option_id = order[:option_id]
                option = Optiontable.find(option_id)
                hash[:price] = option.price_opt
                hash[:option_name] = option.name_opt
                hash[:option_name_zh] = option.name_opt_zh
                @forcheck << hash
            end
        end

        @cashier = Cashier.new
        # form_forのための変数
    end
    # 支払い完了後の操作
    def paid
        # 190710
        cashier = Cashier.new(method: params[:cashier][:method], total: params[:cashier][:total])
        cashier.save
        # ↓以前の
        # Cashier.create(method: params[:cashier][:method], total: params[:cashier][:total])
        # 会計方法と合計を会計テーブルに保存する

        orderlist = Orderlist.where(user_id: params[:cashier][:id]).where(state: 3)
        orderlist.each do |state|
            state.state = 4
            # これから使うかもしれない↓
            # state.cashier_id = cashier.id
            state.save
        end
        redirect_to cashier_table_url
    end

private    
    # サインインしているかどうかの確認
    def move_to_signin
        if user_signed_in? then
            check_authority
            # サインインしてたら、権限のチェック
        else
            redirect_to new_user_session_url 
        end
    end

    # 権限があるかどうかの確認
    def check_authority
        user = User.find(current_user.id)
        authority = user.authority
        
        # redirect_to firstpage_url if authority == 1 || authority == 2
        redirect_to firstpage_url unless authority == 4 || authority == 3
    end
end
