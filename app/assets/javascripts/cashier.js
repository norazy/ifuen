// テーブルの状態を示す部分
$(document).on('turbolinks:load', function() {
    $(".cashier_table_indiv").each(function(i){
    
    var color = $(".cashier_table_indiv span").eq(i).html();
      if (color == 1) {
          $(".cashier_table_indiv").eq(i).addClass("blue2");
          $(".cashier_table_indiv a").eq(i).click(function(){
              return false;
          });
      } else if (color == 2){
          $(".cashier_table_indiv").eq(i).addClass("orange2");
      } else {
          $(".cashier_table_indiv").eq(i).addClass("gray");
          $(".cashier_table_indiv a").eq(i).click(function(){
              return false;
          });
      }        
    });
});

// 各オーダー毎の小計
$(document).on('turbolinks:load', function() {
  var subtotal = 0;
  // 小計を計算するための変数
    $(".check_detail_indiv").each(function(i){
      var price = $(".price p").eq(i).html();
      var number = $(".number p").eq(i).html();
      var subsubtotal = price * number;
      // それぞれのオーダーの価格と数量を描ける
      var subsubtotal2 = String(subsubtotal).replace(/(\d)(?=(\d\d\d)+(?!\d))/g, '$1,');
      // 得られた合計をカンマ入りの数に書き換える
      $(".subtotal p").eq(i).html(subsubtotal2);
      // htmlを書き換える
      subtotal += subsubtotal;
      // 小計の変数に足す
    });
  // 191002今後書き加える予定
  // $("#cashier_subtotal").val(subtotal);

  var subtotal2 = String(subtotal).replace(/(\d)(?=(\d\d\d)+(?!\d))/g, '$1,');
  // 小計をカンマ入りの数に書き換える
  $(".subtotal_n p").html(subtotal2);
  // 小計のhtmlを書き換える
  var discount = $(".discount_n p").html();
  // 割引の値を取得する
  var discount2 = subtotal - discount;
  // 割引料金を引く
  var discount3 = String(discount2).replace(/(\d)(?=(\d\d\d)+(?!\d))/g, '$1,');
  // カンマのある値にする
  $(".check_total_right p").html(discount3);
  // 合計のhtmlの書き換え
  $("#cashier_total").val(discount2);
  // 会計テーブルに渡すtotalカラムのvalueも変化させる
});

// ↓支払方法のクリック後の色変更
$(document).on('turbolinks:load', function() {
  $(".check_method_indiv_button label").click(function(){
    // 全部クラスになっているので、まずクラスの色を全部更新する。
    // 前の選択が残ってる場合とか。
    $(".check_method_indiv_button").css("background-color", "#ea5317");
    // クリックしたradioのクラスの色を変える
    $(this).parent().css("background-color", "#000a34");
  });
});

// 普通の割引のボタンをクリックしたら、合計をもう一度計算し直す
$(document).on('turbolinks:load', function() {
  $(".normal").click(function(){
    var value = $("#discout_input_field").val();
    // 割引入力したフィールドのvalueを取り出す
    
    var value2 = String(value).replace(/(\d)(?=(\d\d\d)+(?!\d))/g, '$1,');
    $(".discount_n p").html(value2);
    // 取り出した数値にカンマを入れて、割引の欄に送る
    
    var subtotal = $(".subtotal_n p").html();
    var subtotal2 = parseInt(subtotal.replace(",",""), 10);
    // 小計を取り出して、文字列から数値にする

    var sum = subtotal2 - value;
    var sum2 = String(sum).replace(/(\d)(?=(\d\d\d)+(?!\d))/g, '$1,');
    $(".check_total_right p").html(sum2);
    // 小計から割引の料金を引いて、
    // カンマを入れた文字列にして、合計を書き換える
    
    $("#cashier_total").val(sum);
    // 会計テーブルに渡すtotalカラムのvalueも変化させる
  });
});

// 持ち帰りの割引のボタンをクリックしたら、合計をもう一度計算し直す
$(document).on('turbolinks:load', function() {
  $(".take_out").click(function(){
    // 小計を取り出して、文字列から数値にする
    var subtotal = $(".subtotal_n p").html();
    var subtotal2 = parseInt(subtotal.replace(",",""), 10);
    // 小計から2%引きの料金を計算し、小数点以降切り捨て
    var take_out_discount = Math.floor(subtotal2*2/110);
    // 2%の金額にカンマを入れて、割引の欄に送る
    var take_out_discount2 = String(take_out_discount).replace(/(\d)(?=(\d\d\d)+(?!\d))/g, '$1,');
    $(".discount_n p").html(take_out_discount2);
    // 小計から割引の料金を引いて、
    // カンマを入れた文字列にして、合計を書き換える
    var sum = subtotal2 - take_out_discount;
    var sum2 = String(sum).replace(/(\d)(?=(\d\d\d)+(?!\d))/g, '$1,');
    $(".check_total_right p").html(sum2);
    // 会計テーブルに渡すtotalカラムのvalueも変化させる
    $("#cashier_total").val(sum);
  });
});
