class StatisticsController < ApplicationController
    # サインインしているかどうか、且つ権限を持っているか
    before_action :move_to_signin 

    before_action :set_beginning
    def set_beginning
        # 今月の月の始めの日時
        # その日付を渡すと、以下のデータ取得で月の途中からになってしまうから。
        @beginning = Date.current.beginning_of_month
    end

    def sales
        # 月の名前の表示
            @this_month = @beginning.strftime("%-m月")
            # 今月
            @last_month = @beginning.prev_month(1).strftime("%-m月")
            # 先月
            @month_before_last = @beginning.prev_month(2).strftime("%-m月")
            # 先々月
            
        # 各月の内容を表す数字を渡して、メソッドを呼び出す
        # 今月の会計データ
            @this_month_total = take_data(0)
        # 先月の会計データ
            @last_month_total = take_data(1)
        # 先月の会計データ
            @month_before_last_total = take_data(2)
    end

    def ranking
        @ranking_category = ["セット", "一品料理", "麺類", "ご飯類", "デザート", "飲み物"]

        # menu_idがあるオーダーを全部取り出す
        order_has_menu_id = Orderlist.where.not(menu_id: nil)

        # カテゴリーidが入った配列
        category_number = [[11,12,13], [21,22,23], [31], [41], [51,52], [61,62]]

        # 「menu_idがあるオーダー」と「月を呼び出す数字」と「カテゴリーを表す数字」を引数として
        # メソッドを呼び出す
        @last_month_ranking = get_ranking(order_has_menu_id, 1, category_number)
        @month_before_last_ranking = get_ranking(order_has_menu_id, 2, category_number)
        @three_months_ago_ranking = get_ranking(order_has_menu_id, 3, category_number)
        
        # csvファイルに渡すもの
        @last_month = @beginning.prev_month(1).strftime("%Y%m")
        @month_before_last = @beginning.prev_month(2).strftime("%Y%m")
        @three_months_ago = @beginning.prev_month(3).strftime("%Y%m")
    end

    def delete_data
        # menu_idがあるオーダーを全部取り出す
        order_has_menu_id = Orderlist.where.not(menu_id: nil)
        # 4ヶ月より前全部というのが、分からなかったので、
        # 去年から４ヶ月前というコードにした。
        four_months_ago = Date.current.end_of_month.prev_month(4)
        # 月末↑
        prev_year = @beginning.prev_year
        # 4月のオーダーを呼び出す
        @four_months_ago = order_has_menu_id.where(created_at: prev_year..four_months_ago)

        # ↓もしデータがあったら、削除する
        if @four_months_ago.present?
            @four_months_ago.each do |order|
                order.destroy
            end
        end

        redirect_back(fallback_location: root_path)
    end
    
    # メニュー追加画面
    def add_menu
        @menu = Menu.new
    end
    # 記入したメニューの保存
    def post_menu
        Menu.create(category: menu_params[:category], name: menu_params[:name], price: menu_params[:price], image: menu_params[:image], option1: menu_params[:option1], option2: menu_params[:option2], option3: menu_params[:option3])
        redirect_back(fallback_location: root_path)
    end

private
    # メニュー保存のストロングパラメータ
    def menu_params
        params.require(:menu).permit(:category, :name, :price, :image, :option1, :option2, :option3)
    end

    # 月のランキングを呼び出すメソッド
    def get_ranking(order_has_menu_id, prev_month_number, category_number)
        each_ranking = []
        # おのおのの月のオーダーを呼び出す
        monthly_order = order_has_menu_id.where(created_at: @beginning.prev_month(prev_month_number).all_month)

        # メニューテーブルからカテゴリー番号を取ってくる
        orders_with_category = []
        monthly_order.each do |order|
            subarry = []
            subarry << order.menu_id
            subarry << Menu.find(order.menu_id).category
            orders_with_category << subarry
        end
        
        category_number.each do |number|
            each_ranking << take_ranking_by_category(orders_with_category, number)
            # メソッドの呼び出し
            # それぞれのカテゴリ別の中のランキングを出すため
        end
        
        each_ranking
    end

    # カテゴリーランギングを呼び出すメソッド
    def take_ranking_by_category(orders_with_category, category_numbers)
        # 該当するカテゴリーのオーダーを取り出す
        orders_divided_by_category = orders_with_category.map do |category|
            category if category_numbers.any?{ |category_number| category[1] == category_number }
            # ここでオーダー番号を一つ一つ取り出してる
        end
        orders_divided_by_category = orders_divided_by_category.compact
        # nilを取り除く
        
        # その中で同じメニューをまとめて、それぞれの個数を数える
        orders_with_served_number  = orders_divided_by_category.group_by{|order| order[0]}.map do |date_indiv, array|
            # [date_indiv, array]
            [date_indiv, array.count]
        end
        
        # オーダーされた回数が多い順に並べる
        orders_sort_by_served_number = orders_with_served_number.sort_by{ | k, v | v }.reverse

        category_ranking = []
        # メニューの名前を取ってくる
        orders_sort_by_served_number.first(5).each do |order|
          name = Menu.find(order[0]).name
          category_ranking << name
        end

        category_ranking
    end

    # 毎日の会計データを呼び出すメソッド
    def take_data(month_num)
        # その月の全部の日付を取り出す
        month_date = @beginning.prev_month(month_num).all_month
        # その月の全部の会計データ
        month_all_total = Cashier.where(created_at: @beginning.prev_month(month_num).all_month)

    	# 日付が入る配列を作成して、
        # その日の日付を文字列にして配列に入れる	
    	all_dates = []
    	month_date.each do |date|
    		all_dates << date.strftime('%Y%m%d')
    	end

        #　全ての会計データを日別に分ける
        # その日別ごとにグループ化する
    	date_has_data = month_all_total.group_by { |a| a.created_at.strftime('%Y%m%d') }.map do |date_indiv, array|
            [date_indiv, array]
        end.to_h
        # 扱いやすいようにハッシュにする
    
        @toview =[]
        all_dates.each do |date|
        # 日付を一日ずつ取り出す
        	if date_has_data.has_key?(date) then
        	   # 該当する日に会計のデータがあったら、
        	   # その日の会計の合計を出す
        		subtotal = date_has_data[date]
        		total = 0
        		subtotal.each do |subtotal2|
        			total += subtotal2[:total]
                # total変数に入れる
        		end
        	else
        		total = 0
                # その日に会計データがなかったら、totalにゼロを入れる
        	end
        	@toview << [date, total]
            # その日の日付と会計の合計を配列に入れて、後ほどビューに渡す変数にいれる
        end
        return @toview
    end
    
    # サインインしているかどうかの確認
    def move_to_signin
        if user_signed_in? then
            user = User.find(current_user.id)
            authority = user.authority
            
            # redirect_to firstpage_url if authority == 1 || authority == 2 || authority == 4
            redirect_to firstpage_url if authority != 3
            # サインインしてたら、権限のチェック
        else
            redirect_to new_user_session_url 
        end
    end    
end
