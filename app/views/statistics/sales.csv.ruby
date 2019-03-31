require 'csv'

CSV.generate do |csv|
  column_names = %w(date total)
  csv << column_names
  @this_month_total.each do |cashier|
    column_values = [
      cashier[0],cashier[1]
    ]
    csv << column_values
  end
  @last_month_total.each do |cashier|
    column_values = [
      cashier[0],cashier[1]
    ]
    csv << column_values
  end
  @month_before_last_total.each do |cashier|
    column_values = [
      cashier[0],cashier[1]
    ]
    csv << column_values
  end
end