require 'csv'

CSV.generate do |csv|
    column_names = %w(month category 1 2 3 4 5)
    csv << column_names
    @last_month_ranking.zip(@ranking_category).each do |ranking, category|
        column_values = []
        column_values << @last_month
        column_values << category
        ranking.each do |menu_name|
            column_values << menu_name
        end
        csv << column_values
    end
    @month_before_last_ranking.zip(@ranking_category).each do |ranking, category|
        column_values = []
        column_values << @month_before_last
        column_values << category
        ranking.each do |menu_name|
            column_values << menu_name
        end
        csv << column_values
    end
    @three_months_ago_ranking.zip(@ranking_category).each do |ranking, category|
        column_values = []
        column_values << @three_months_ago
        column_values << category
        ranking.each do |menu_name|
            column_values << menu_name
        end
        csv << column_values
    end
end