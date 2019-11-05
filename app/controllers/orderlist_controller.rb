class OrderlistController < ApplicationController
    # ↓サインインしているかどうかの確認
    before_action :move_to_signin, :check_cart

    def first
    end

    def top_page
    end

    def set_menu
        @menus1 = Menu.where(category: 11)
        @menus2 = Menu.where(category: 12)
        @menus3 = Menu.where(category: 13)
        # binding.pry
    end

    def alacarte
        @menus1 = Menu.where(category: 21)
        @menus2 = Menu.where(category: 22)
        @menus3 = Menu.where(category: 23)
        # binding.pry
    end

    def noodle
        @menus1 = Menu.where(category: 31)
    end
    
    def rice
        @menus1 = Menu.where(category: 41)
        # @user = current_user.orderlists
        # アソシエーションができるかどうか試してみた：できた
    end
    
    def dessert
        @menus1 = Menu.where(category: 51)
        @menus2 = Menu.where(category: 52)
    end
    
    def drink
        @menus1 = Menu.where(category: 61)
        @menus2 = Menu.where(category: 62)
    end
    
    # 検索ページ
    def search
        @menus1 = Menu.where('name LIKE(?)', "%#{params[:keyword]}%").limit(20)
        @menus_en = Menu.where('name_en LIKE(?)', "%#{params[:keyword]}%").limit(20)
        @menus_zh = Menu.where('name_zh LIKE(?)', "%#{params[:keyword]}%").limit(20)
    end
    
    # おすすめ商品
    def recommend
        # レコメンドカテゴリーごと取り出す
        category_reco1 = Recommend.where(category_reco: 1)
        category_reco2 = Recommend.where(category_reco: 2)
        category_reco3 = Recommend.where(category_reco: 3)
        
        # 空の配列を用意
        @menus1 = []
        @menus2 = []
        @menus3 = []
        
        # カテゴリーごとのmenu_idから料理名等を取り出す
        category_reco1.each do |reco|
            @menus1 << Menu.find(reco[:menu_id])
        end
        category_reco2.each do |reco|
            @menus2 << Menu.find(reco[:menu_id])
        end
        category_reco3.each do |reco|
            @menus3 << Menu.find(reco[:menu_id])
        end
    end

    # モーダル部分
    def modal
        # パラムズのidにあったメニューを取り出す
        @menu = Menu.find(params[:id])
        @orderlist = Orderlist.new
        # 各オプションの中にものがあるかどうか
        # あったら変数に渡す
        if @menu.option1 then
            number = @menu.option1
            @option1 = Optiontable.find(number)
            @option_name1 = @option1.name_opt
            @option_price1 = @option1.price_opt
            @option_name1_zh = @option1.name_opt_zh
            @option_name1_en = @option1.name_opt_en
        end
        if @menu.option2 then
            number = @menu.option2
            @option2 = Optiontable.find(number)
            @option_name2 = @option2.name_opt
            @option_price2 = @option2.price_opt

            @option_name2_zh = @option2.name_opt_zh
            @option_name2_en = @option2.name_opt_en
        end
        if @menu.option3 then
            number = @menu.option3
            @option3 = Optiontable.find(number)
            @option_name3 = @option3.name_opt
            @option_price3 = @option3.price_opt

            @option_name3_zh = @option3.name_opt_zh
            @option_name3_en = @option3.name_opt_en
        end
        
        respond_to do |format|
            format.html
            format.js
        end
    end
    # モーダル「カートへ」のcreate
    def order_create
        # メニュー価格の呼び出し
        menu = Menu.find(orderlist_params[:menu_id])
        menu_price = menu.price
        
        # もしオプションがあったら
        if orderlist_params[:option_id] then
            # もしオプションがギョウザとかの一個増しだったら、オプションの個数は一個
            if orderlist_params[:option_id] == "44" || orderlist_params[:option_id] == "45" || orderlist_params[:option_id] == "46" 
                # オプション価格の呼び出し
                option = Optiontable.find(orderlist_params[:option_id])
                option_price = option.price_opt
    
                Orderlist.create(user_id: current_user.id, menu_id: orderlist_params[:menu_id], price: menu_price, number: orderlist_params[:number], state: "0")
                # ↓ここでオプションにメニューidを持たせたないのは
                # 未確定のところで、メニューidを持ってるかどうかで条件分岐させているから
                # （オプションidで条件分岐させてもよかったんだけど。。）
                Orderlist.create(user_id: current_user.id, option_id: orderlist_params[:option_id], price: option_price, number: "1", state: "0")
            else
                option = Optiontable.find(orderlist_params[:option_id])
                option_price = option.price_opt
    
                Orderlist.create(user_id: current_user.id, menu_id: orderlist_params[:menu_id], price: menu_price, number: orderlist_params[:number], state: "0")
                # ↓ここでオプションにメニューidを持たせたないのは
                # 未確定のところで、メニューidを持ってるかどうかで条件分岐させているから
                # （オプションidで��件分岐させてもよかったんだけど。。）
                Orderlist.create(user_id: current_user.id, option_id: orderlist_params[:option_id], price: option_price, number: orderlist_params[:number], state: "0")
                
            end
        # もしオプションがなかったら
        else
            Orderlist.create(user_id: current_user.id, menu_id: orderlist_params[:menu_id], price: menu_price, number: orderlist_params[:number], state: "0")
        end
        
        # createのあとは新しいビューに飛ばずに、backするように設定する
        # かつ、「カートに入れた」っていうメッセージを出す
        redirect_back(fallback_location: root_path)
        flash[:notice] = "カートに入りました！"
    end

    # 未確定注文のページ
    def pre_order
        # 現在ログインしているユーザーの状態が０のオーダーを引き出す
        preorder = Orderlist.where(user_id: params[:id]).where(state: 0)
        
        # ビューに渡す配列作成
        @preorder = []
        
        # 取り出したオーダーに対して、一つずつハッシュを作る
        # {:order_id, :number, :state, :menu_name, :menu_name_zh, :menu_name_en, :option_name, :option_name_zh, :option_name_en}　←キー
        # orderlistのテーブルにmenu_idはあるけど、
        # メニュー名のカラムがないからハッシュを作ってる
        preorder.each do |order|
            hash = {}
            hash[:order_id] = order.id
            hash[:number] = order.number
            hash[:state] = 1
            # viewに表示させるために必要↓
            if order.menu_id then
                number = order.menu_id
                menu = Menu.find(number)
                hash[:menu_name] = menu.name
                # 中国語と英語のメニューも呼び出している
                hash[:menu_name_zh] = menu.name_zh
                hash[:menu_name_en] = menu.name_en
            else
                number2 = order.option_id
                option = Optiontable.find(number2)
                # name2 = option.name_opt
                hash[:option_name] = option.name_opt
                hash[:option_name_zh] = option.name_opt_zh
                hash[:option_name_en] = option.name_opt_en
            end
            @preorder << hash
        end
        @orderlist = Orderlist.new
    end
    # 未確定の削除
    def delete_preorder
        # 削除を2回押すことで出るエラーを解決するために、if文を付け加えた 191103
        if Orderlist.where(id: params[:id]).exists?
            orderlist = Orderlist.find(params[:id])
            orderlist.destroy if orderlist.user_id = current_user.id
            # サインインしてがメニューを注文した人なら、削除する
            redirect_back(fallback_location: root_path)
            flash[:notice] = "Something"
        end
    end
    # 未確定のものを確定にする部分
    def post_order
        # 191103 空のときに注文するって押すとエラーがでるため、if文を付け加える
        if post_order_params[:orderlist]
            # paramsの配列を変数へ
            preorderlist = post_order_params[:orderlist]
            # 配列をeach文にかける
            preorderlist.each do |pre|
                # ↓オーダーのidを取り出す
                number = pre[":id"]
                # ↓文字列になっているため、数字にする
                number = number.to_i
                # ↓該当するidのオーダーレコードをだす
                orderlist = Orderlist.find(number)
    
                # ↓useridの確認
                if orderlist.user_id = current_user.id then
                    # 個数の書き換え
                    orderlist.number = pre[":number"]
                    # 状態の書き換え
                    orderlist.state = pre[":state"]
                    orderlist.ordered_time = DateTime.current
                    # binding.pry
                    # 上書き保存
                    orderlist.save
                end
            end
            
            # notificationテーブルに新しい注文が入ったことを知らせる
            Notification.create(table_id: current_user.id, state: 3)
            redirect_to order_top_path
            flash[:notice] = "something"
        end
    end

    # 注文済画面
    def ordered
        # 現在ログインしているユーザーの状態が０のオーダーを引き出す
        # 190622 4以外って選択しよう選択しようと思ったら、０も含まれてしまう
        ordered = Orderlist.where(user_id: params[:id]).where(state: 1..3).order('state ASC').order('id ASC')
        # ビューに渡す配列作成
        @ordered = []
        
        # 取り出したオーダーに対して、一つずつハッシュを作る
        ordered.each do |order|
            hash = {}
            hash[:number] = order.number
            hash[:price] = order.price
            if order.menu_id then
                number = order.menu_id
                menu = Menu.find(number)
                hash[:menu_name] = menu.name
                # 中国語と英語のメニューも呼び出している
                hash[:menu_name_zh] = menu.name_zh
                hash[:menu_name_en] = menu.name_en
            else
                number2 = order.option_id
                option = Optiontable.find(number2)
                hash[:option_name] = option.name_opt
                hash[:option_name_zh] = option.name_opt_zh
                hash[:option_name_en] = option.name_opt_en
            end
            
            if order.state == 1 then
                hash[:state] = "注文済"
                hash[:state_zh] = "已下单"
                hash[:state_en] = "Ordered"
            # elsif order.state == 2 then
            #     hash[:state] = "調理中"
            #     hash[:state_zh] = "炒菜中"
            #     hash[:state_en] = "Cooking"
            else
                hash[:state] = "届済み"
                hash[:state_zh] = "已上菜"
                hash[:state_en] = "Served"
            end    
            @ordered << hash
        end
    end
    
    # 「会計する」の呼び出し
    def call_cashier
        Notification.create(table_id: current_user.id, state: 1)
        # redirect_back(fallback_location: root_path)
        # flash[:error] = "something"
    end
    def call_cashier_get
    # リフレッシュを押されたときにバグらないためのアクション
    # これでいいかはまだわからない↓
        redirect_to root_path
    end
    
    # スタッフの呼び出し
    def call_staff
        Notification.create(table_id: current_user.id, state: 2)
        # redirect_back(fallback_location: root_path)
        # flash[:error] = "something"
    end
    def call_staff_get
    # リフレッシュを押されたときにバグらないためのアクション
    # これでいいかはまだわからない↓
        redirect_to root_path
    end

private
    def check_cart
        # 現在ログインしているユーザーの状態が０のオーダーを引き出す
        @cart = Orderlist.where(user_id: current_user.id).where(state: 0)
    end
    def orderlist_params
        params.require(:orderlist).permit(:number, :option_id, :menu_id)
    end
    
    def post_order_params
        params.permit(orderlist:[":id", ":number", ":state"])
    end

    # サインインしてなかったらアクセスできないようにする
    def move_to_signin
        redirect_to new_user_session_url unless user_signed_in?
    end
end
