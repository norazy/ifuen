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
                if eachtable.exists?(:state => [0, 1, 2])
                # if eachtable.exists?(:state => 0)
                #     # 未注文のものも入れて検索する
                #     color = 1
                # elsif eachtable.exists?(:state => 1)
                #     color = 1
                # elsif eachtable.exists?(:state => 2)
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
            # binding.pry
    end
    
    # 各テーブルの計算
    def check_page
        @table_id = params[:id]
        # テーブル番号

        orderlist = Orderlist.where(user_id: params[:id]).where(state: 3)
        @forcheck = []
        # 会計が必要なオーダーを全部入れる配列
        
        orderlist.each do |order|
            hash = {}
            hash[:number] = order.number
            hash[:price] = order.price
            hash[:id] = order.id
            if order.menu_id then
                number = order.menu_id
                menu = Menu.find(number)
                hash[:menu_name] = menu.name
                hash[:menu_name_zh] = menu.name_zh
            else
                number2 = order.option_id
                option = Optiontable.find(number2)
                hash[:option_name] = option.name_opt
                hash[:option_name_zh] = option.name_opt_zh
            end
            @forcheck << hash
        end
        
        @orderlist = Orderlist.new
        @cashier = Cashier.new
        # form_forのための変数
    end
    # 支払い完了後の操作
    def paid
        # 会計が済んだメニュー一覧をstate_change変数へ
        # state_change = params[:orderlist]
        state_change = paid_params[:orderlist]
        state_change.each do |state|
            # 一つずつ取り出してstateを書き換える
            number = state[":id"]
            order_id = number.to_i
            order_indiv = Orderlist.find(order_id)
            order_indiv.state = state[":state"]
            # 上書き保存する
            order_indiv.save
        end
        Cashier.create(method: params[:cashier][:method], total: params[:cashier][:total])
        # 会計方法と合計を会計テーブルに保存する
        redirect_to cashier_table_url

        # 確定処理をして
        # cashersモデルをcreateする
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
        
        redirect_to firstpage_url if authority == 1 
    end
    
    def paid_params
        params.permit(orderlist:[":id", ":state"])
    end
end
