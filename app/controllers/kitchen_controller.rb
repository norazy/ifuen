class KitchenController < ApplicationController
    # サインインしているかどうかのチェック
    before_action :move_to_signin 
    # 通知があるかどうかチェック
    # before_action :check_notification, except: [:notification, :table_change]
    before_action :check_notification, only: [:table_kitchen, :ordered_kitchen]
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
                # elsif eachtable.exists?(:state => 2)
                #     color = 2
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
        # 190503　テーブルごとの伝票を注文伝票ごとの表示に変える
        # ↓調理待ちの料理をすべて抜け出す
        waiting_order = Orderlist.where(:state => [1])
        # ↓注文した時間別にグループ分けしてから、その注文時間を配列に入れる
        waiting_order_by_ordered_time = waiting_order.group(:ordered_time)
        # ↓注文時間ごとにグループ分けされた一番最初のデータから、時間を取り出して新しい配列に入れる
        ordered_time = []
        waiting_order_by_ordered_time.each do |time|
            ordered_time << time.ordered_time
        end
        
        # ↓viewに渡す変数を定義する
        @time = []
            # 注文時間
        @table_id = []
            # 注文テーブル
        @each_table_order = []
            # 注文詳細
            
        # 注文時間を一つ一つ取り出し、その時間のオーダーを全部取り出す
        ordered_time.each do |time2|
            # ↓注文時間Xのすべてのオーダーと取り出す
            orders = waiting_order.where(:ordered_time => time2).order('id ASC')
            # 190711　同じ時間に2つのテーブルから注文があった時に、一つにまとめられてしまうので、
            # 同じ注文時間で、user_idがちがうものがあるか調べる↓
            # もしあれば、ユーザーでグループ分けする↓
            if (orders.group(:user_id).length >= 2) then
                split_by_table = orders.group(:user_id)
                split_user_id = []
                split_by_table.each do |table|
                    split_user_id << table.user_id
                end
                # 注文時間とuser_id2つが当てはまるオーダーを取り出す↓
                split_user_id.each do |id|
                    orders3 = orders.where(:user_id => id).order('id ASC')
                    # メニューの名前と個数を取り出すメソッド呼び出す
                    call_ordered_menu(orders3, time2)
                end
            # 同じ時間で違うテーブルの注文がなければ↓
            # メニューの名前と個数を取り出すメソッド呼び出す
            else
                call_ordered_menu(orders, time2)
            end
            # orders2 = []
            # orders.each do |order|
            #     @table = order.user_id
            #     # テーブル番号は一つだけなので、オーダーごとに書き換える

            #     hash = {}
            #     hash[:order_id] = order.id
            #     hash[:number] = order.number
            #     hash[:state] = order.state
                
            #     if order.menu_id then
            #         hash[:menu_id] = order.menu_id
            #     else
            #         hash[:menu_id] = 0
            #     end
            #     # こので:menu_idを渡しているのjqueryで
            #     # 同じ料理の背景の色を変更させるため。

            #     if order.menu_id then
            #         number = order.menu_id
            #         menu = Menu.find(number)
            #         hash[:menu_name] = menu.name
            #         hash[:menu_name_zh] = menu.name_zh
            #     else
            #         number2 = order.option_id
            #         option = Optiontable.find(number2)
            #         hash[:option_name] = option.name_opt
            #         hash[:option_name_zh] = option.name_opt_zh
            #     end

            #     orders2 << hash
            # end
            # # 注文時間をわかりやすくする↓
            # @time << time2.strftime("%H:%M")

            # @table_id << @table
            # @each_table_order << orders2
        end
    end
    
    # 調理待一覧でメニューを消す
    def destroy_order
        if Orderlist.where(id: params[:id]).exists?
            Orderlist.find(params[:id]).destroy
        end
        redirect_back(fallback_location: root_path)
    end
    # 調理待一覧で状態を変更：提供済
    def change_state2
        orderlist = Orderlist.find(params[:id])
        # 状態の書き換え
        orderlist.state = 3
        # 上書き保存
        orderlist.save
        redirect_back(fallback_location: root_path)
    end
    
    # 注文一覧
    def served
        # テーブル番号を入れる配列の変数
        tablenumber = []
        # 全オーダーから状態が1,2,3のオーダーを取り出す
        # さらにusr_idごとにグループ化して、それぞれの一番最初のデータを取り出す
        groupdata = Orderlist.where(:state => [1, 3]).group(:user_id)
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
            table_order = Orderlist.where(:user_id => table_id).where(state: [1, 3]).order('state ASC').order('id ASC')
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
                    # elsif order.state == 2 then
                    #     hash[:state] = "調理中"
                    #     hash[:state_zh] = "炒菜中"
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
        if Notification.exists?
            @notification = Notification.all
            @time = []
            @notification.each do |noti|
                @time << noti.created_at.strftime("%H:%M")
            end
        else
            @notification = []
            @time = []
        end
    end
    # 通知の削除
    def destroy
        if Notification.where(id: params[:id]).exists?
            Notification.find(params[:id]).destroy
        end
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

    # テーブルチェンジページ
    def table_change
        @orderlist = Orderlist.new
    end
    # テーブルチェンジの保存
    def post_table_change
        order_table_now = Orderlist.where(user_id: table_change_params[:user_id]).where.not(:state => 4)
        table_new = table_change_params[:number]

        if order_table_now then
            table_new = table_change_params[:number]
            
            order_table_now.each do |order|
                order.user_id = table_new
                order.save
            end
        end
        # # オプション価格の呼び出し
        # option = Optiontable.find(option_params[:option_id])
        # option_price = option.price_opt
        # time = DateTime.current
        # Orderlist.create(user_id: option_params[:user_id], option_id: option_params[:option_id], price: option_price, number: option_params[:number], state: "1", ordered_time: time)

        redirect_back(fallback_location: root_path)
    end
    

private    
    # サインインしているかどうかの確認
    def move_to_signin
        if user_signed_in? then
            user = User.find(current_user.id)
            authority = user.authority
            
            # redirect_to firstpage_url if authority == 1 || authority == 4 
            redirect_to firstpage_url unless authority == 3 || authority == 2 
            # サインインしてたら、権限のチェック
        else
            redirect_to new_user_session_url 
        end
    end
    # 通知があるかどうかの確認
    def check_notification
        if Notification.exists?
            flash[:alert] = "通知"
        else
            flash[:alert] = nil
        end
    end
    def clear_flash
        flash[:alert] = nil
    end
    def option_params
        params.require(:orderlist).permit(:user_id, :option_id, :number)
    end
    def table_change_params
        params.require(:orderlist).permit(:user_id, :number)
    end
    # 190711　注文されたメニューの名前と個数を呼び出すメソッド
    def call_ordered_menu(orders, time2)
        orders2 = []
        orders.each do |order|
            @table = order.user_id
            # テーブル番号は一つだけなので、オーダーごとに書き換える
            
            # ＠each_table_orderの変数に入れるハッシュを定義する
            hash = {}
            hash[:order_id] = order.id
            hash[:number] = order.number
            hash[:state] = order.state
            # if order.menu_id then
            #     hash[:menu_id] = order.menu_id
            # else
            #     hash[:menu_id] = 0
            # end
            # こので:menu_idを渡しているのjqueryで
            # 同じ料理の背景の色を変更させるため。
            if order.menu_id then
                number = order.menu_id
                hash[:menu_id] = number
                menu = Menu.find(number)
                hash[:menu_name] = menu.name
                hash[:menu_name_zh] = menu.name_zh
            else
                hash[:menu_id] = 0
                number2 = order.option_id
                option = Optiontable.find(number2)
                hash[:option_name] = option.name_opt
                hash[:option_name_zh] = option.name_opt_zh
            end
            # こので:menu_idを渡しているのjqueryで
            # 同じ料理の背景の色を変更させるため。
            orders2 << hash
        end
        # 注文時間をわかりやすくする↓
        @time << time2.strftime("%H:%M")
        @table_id << @table
        @each_table_order << orders2
    end
end