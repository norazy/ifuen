class KitchenController < ApplicationController
    # サインインしているかどうかのチェック
    before_action :move_to_signin 
    # 通知があるかどうかチェック
    before_action :check_notification, except: :notification
    # flashの中身を消す
    after_action :clear_flash

    # テーブルの状態を表示
    def table_kitchen
        # ↓各テーブルの状態を入れておく配列
        @color = []
        number = 1
        # テーブルの回数だけ繰り返す
        while number <= 16 do
            # テーブル番号があるか
            if Orderlist.where(user_id: number).exists?
                # 今のテーブルのオーダーを全部抜き出す
                eachtable = Orderlist.where(user_id: number)
                # 状態が１のオーダーがあったら
                if eachtable.exists?(:state => 1)
                    color = 1
                elsif eachtable.exists?(:state => 0)
                    color = 2
                elsif eachtable.exists?(:state => 2)
                    color = 2
                elsif eachtable.exists?(:state => 3)
                    color = 2
                else
                    color = 0
                end
            #テーブル番号がなかったら 
            else
                color = 0
            end
            @color << color
            number += 1
        end
    end
    
    # 調理待の注文一覧
    def ordered_kitchen
        # 全オーダーから状態が1,2のオーダーを取り出す
        # さらにusr_idごとにグループ化して、それぞれの一番最初のデータを取り出す
        groupdata = Orderlist.where(:state => [1, 2]).group(:user_id)

        # テーブル番号を入れる配列の変数
        tablenumber = []
        
        # それぞれのユーザーの一番最初のレコードをeachにかける
        # そのレコードのuser_idを取り出して、テーブル番号を入れる変数に追加する
        groupdata.each do |data|
        #   user_id = data.user_id
        #   tablenumber << user_id
        #   上の二行のコードをまとめる↓
           tablenumber << data.user_id
        end

        # キッチンにはオーダーの順番に並び変えたいので、
        # テーブル番号の配列を時間順に並び替える

        # 新しい空の配列を作る
        tablenumber2 = []
        
        tablenumber.each do |table_id|
            #それぞれのテーブルの最新のオーダーを取り出す
            order = Orderlist.where(:user_id => table_id).order("ordered_time DESC").limit(1)
            
            # そのオーダーをした時間とテーブル番号を配列にいれ
            each_table = []
            each_table << order[0].ordered_time.strftime("%H:%M")
            each_table << table_id
            # ex. ["05:49", 1]
            
            # すべてのテーブルの時間と番号をさらに一つ上の配列に入れる
            tablenumber2 << each_table
            # ex.[["05:49", 1], ["07:53", 2], ["04:50", 3], ["17:14", 9], ["17:16", 10], ["17:18", 17], ["17:20", 19]]
        end

        # オーダー時間順に並び変えて、テーブル番号を取り出す
        tablenumber3 = []
        tablenumber2.sort.each do |time|
            tablenumber3 << time[1]
        end
        # ex. => [3, 1, 2, 9, 10, 17, 19]

        # それぞれのテーブルのオーダーを入れる配列の変数を作る
        @each_table_order = []
        # それぞれのテーブルの最後のオーダー時間を入れる配列の変数を作る
        # それぞれのテーブル番号を入れる配列の変数を作る
        @time = []
        @table_id = []

        # ユーザー番号を一つ一つ取り出す
        tablenumber3.each do |table_id|
            # その番号のuser_idを取り出して、かつstate=1のオーダーを全部取り出す
            table_order = Orderlist.where(:user_id => table_id).where(state: [1, 2]).order('id ASC')
                # 取り出したオーダーにはメニューnameがないので、
                # オーダーを一つずつ取り出して、メニューの名前を入れた新たな配列を作る
                table_order2 = []
                # 時間は最新のものでいいので、配列ではなくただの変数にする
                time = ""
                table_order.each do |order|
                    hash = {}
                    
                    hash[:order_id] = order.id
                    hash[:number] = order.number
                    hash[:state] = order.state
                    time = order.ordered_time.strftime("%H:%M")
                    
                    if order.menu_id then
                        hash[:menu_id] = order.menu_id
                    else
                        hash[:menu_id] = 0
                    end

                    # viewに表示させるために必要↓
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
                    table_order2 << hash
                end
            
                # lastorder = table_order.first
                # time = lastorder.created_at.strftime("%H:%M")
                # # binding.pry

            # 名前が付いたオーダーの配列をuser-idの順番ごとビューに渡す変数の配列に入れる
            # 時間も同様に
            @each_table_order << table_order2
            @time << time
            @table_id << table_id
        end
    end
    # 調理待一覧でメニューを消す
    def destroy_order
        Orderlist.find(params[:id]).destroy
        redirect_back(fallback_location: root_path)
    end
    # 調理待一覧で状態変更：調理済
    def change_state
        orderlist = Orderlist.find(params[:id])
        # 状態の書き換え
        orderlist.state = 2
        # 上書き保存
        orderlist.save
        redirect_back(fallback_location: root_path)
    end
    # 調理待一覧で状態を変更：提供済
    def change_state2
        orderlist = Orderlist.find(params[:id])
        # 状態の書き換え
        orderlist.state = 3
        # 上書き保存
        # binding.pry
        orderlist.save
        redirect_back(fallback_location: root_path)
    end
    
    # 注文一覧
    def served
        # テーブル番号を入れる配列の変数
        tablenumber = []
        # 全オーダーから状態が1,2,3のオーダーを取り出す
        # さらにusr_idごとにグループ化して、それぞれの一番最初のデータを取り出す
        groupdata = Orderlist.where(:state => [1, 2, 3]).group(:user_id)
        # それぞれのユーザーの一番最初のレコードをeachにかける
        # それぞれのuser_idを取り出して、
        # テーブル番号を入れる配列の変数に追加する
        groupdata.each do |data|
           user_id = data.user_id
           tablenumber << user_id
        end

        # それぞれのテーブルのオーダーを入れる配列の変数を作る
        @each_table_order = []
        # それぞれのテーブル番号を入れる配列の変数を作る
        @table_id = []

        # ユーザー番号を一つ一つ取り出す
        tablenumber.each do |table_id|
            # その番号のuser_idを取り出して、かつstate=1のオーダーを全部取り出す
            # 最初は状態の順番で並べる
            # それからidで順番に並べる
            table_order = Orderlist.where(:user_id => table_id).where(state: [1, 2, 3]).order('state ASC').order('id ASC')
                # 取り出したオーダーにはメニューnameがないので、
                # オーダーを一つずつ取り出して、メニューの名前を入れた新たな配列を作る
                table_order2 = []
                table_order.each do |order|
                    hash = {}
                    
                    hash[:order_id] = order.id
                    hash[:number] = order.number

                    # viewに表示させるために必要↓
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

                    if order.state == 1 then
                        hash[:state] = "注文済"
                        hash[:state_zh] = "已下单"
                    elsif order.state == 2 then
                        hash[:state] = "調理中"
                        hash[:state_zh] = "炒菜中"
                    else
                        hash[:state] = "届済み"
                        hash[:state_zh] = "已上菜"
                    end

                    table_order2 << hash
                end
                
            # 名前が付いたオーダーの配列をuser-idの順番ごとビューに渡す変数の配列に入れる
            # 時間も同様に
            @each_table_order << table_order2
            @table_id << table_id
        end
    end

    # 通知一覧
    def notification
        @notification = Notification.all
        
        @time = []
        @notification.each do |noti|
            @time << noti.created_at.strftime("%H:%M")
        end
    end
    # 通知の削除
    def destroy
        Notification.find(params[:id]).destroy
        redirect_back(fallback_location: root_path)
    end

    # オプション追加ページ
    def option_change
        @orderlist = Orderlist.new
    end
    # オプションの保存
    def post_option
        # オプション価格の呼び出し
        option = Optiontable.find(option_params[:option_id])
        option_price = option.price_opt
        time = DateTime.current
        Orderlist.create(user_id: option_params[:user_id], option_id: option_params[:option_id], price: option_price, number: option_params[:number], state: "1", ordered_time: time)

        redirect_back(fallback_location: root_path)
    end
    

private    
    # サインインしているかどうかの確認
    def move_to_signin
        if user_signed_in? then
            user = User.find(current_user.id)
            authority = user.authority
            
            redirect_to firstpage_url if authority == 1 
            # サインインしてたら、権限のチェック
        else
            redirect_to new_user_session_url 
        end
    end

    # 通知があるかどうかの確認
    def check_notification
        # if Notification.exists?(:id => 1)
        if Notification.exists?
            flash[:alert] = "通知"
        end
    end

    def clear_flash
        flash[:alert] = nil
    end

    def option_params
        params.require(:orderlist).permit(:user_id, :option_id, :number)
    end

    
end
