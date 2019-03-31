// トップページのトグルの部分
$(document).on('turbolinks:load', function() {
	$("#nav_button").click(function(){
		$("#nav_button2").slideToggle();
	});
});

// メニューカテゴリー２の中身の切り替え部分
window.addEventListener('turbolinks:load', function() {
  $(".menu_category2 li").on("click", function() {
    $("li.selected").removeClass("selected");
    $(this).addClass("selected");
    $(".menu_indiv").children().hide();
    $("."+this.id).show();
  }); 
});

// モーダルの呼び出し
$(document).on('turbolinks:load', function() {
  $(".menu_indiv_block").click(function(event){
    var lang = ""
    if ($('body').hasClass("zh")) {
      lang = "/zh"
    } else if ($('body').hasClass("en")){
      lang = "/en"
    }
    var id = $(this).attr('menuid')
    var url =  lang + '/order/modal/' + id;
    // var url = lang + '/order/modal/' + id;
      // console.log(url);
    
    $.ajax({
        url: url,
        success: function(modal){
          // ↑これで呼び出すとhtmlのheadとかも全部呼び出される
          // ↓なのでappendしたいidのみ呼び出す
          modal_bg = $(modal).filter("#modal_bg");
          modal_menu = $(modal).filter("#modal_menu_indiv");
          modal_close = $(modal).filter("#modal_close");
          
          // ダブルクリックすると画面がフリーズするので、
          // それを防ぐために、appendする前に、removeさせる
          $("#modal_bg").remove();
          $("#modal_menu_indiv").remove();
          
          $("body").append(modal_bg);
          $("body").append(modal_menu);
          $("body").append(modal_close);

           // モーダルを消す。ボタンの動き
           $("#modal_close").click(function(){
                $("#modal_bg").remove();
                $("#modal_menu_indiv").remove();
            });
          
          // ↓注文個数のクリック後の色変更
          $(".modal_menu_number label").click(function(){
            $(".modal_menu_number").css("background-color", "#f5f5dc");
            $(this).parent().css("background-color", "#ea5317");
          });
          
          // ↓オプションの選択部分、選択すると色が変わる
          $(".modal_menu_option label").click(function(){
            $(".modal_menu_option").css("background-color", "#000a34");
            $(this).parent().css("background-color", "#ea5317");
          });
        }
    });

  });
});  

// 未確定メニューの数量変更　マイナス
$(document).on('turbolinks:load', function() {
  $(".minus_btn").click(function(){
    
    var number = $(".minus_btn").index(this);
    var letter = $(".preorder_menu_number2 p").eq(number).html();
    // 文字列を数値にする↓
    letter = parseInt(letter);

    if (letter >= 2) {
        var letter2 = letter - 1
        $(".preorder_menu_number2 p").eq(number).html(letter2);
        $(".orderlist_number_value").eq(number).val(letter2);
    }
  });
})

// 未確定メニューの数量変更　プラス
$(document).on('turbolinks:load', function() {
  $(".plus_btn").click(function(){
    var number = $(".plus_btn").index(this);
    var letter = $(".preorder_menu_number2 p").eq(number).html();
    // 文字列を数値にする↓
    letter = parseInt(letter);

    if (letter < 4 ) {
        var letter2 = letter + 1
        $(".preorder_menu_number2 p").eq(number).html(letter2);
        $(".orderlist_number_value").eq(number).val(letter2);

    }
  });
})

// 合計を求める
$(document).on('turbolinks:load', function() {
  var sum = 0
  // 合計を入れる変数を作成
  
  $(".ordered_menu").each(function(i){
    // each文で注文済みのメニューを全部繰り返す
    
    var price = $(".ordered_menu_price p").eq(i).html();
    // 価格を取り出す
    var number = $(".ordered_menu_number p").eq(i).html();
    // 個数を取り出す
    var subtotal = price * number
    // 各オーダーの小計を出す

    sum += subtotal
    // 小計をこれまでの合計に足す
  });
  
  var sum2 = String(sum).replace(/(\d)(?=(\d\d\d)+(?!\d))/g, '$1,');
  // 合計の数値を金額表示にする

  $("#ordered_sum_price p").html(sum2);
  // 合計の部分を表示させる
})

// トーストのフェイドアウト
$(function(){
    $("#toasts").show();
    $("#toasts").fadeOut(5000);
});
// $(document).on('turbolinks:load', function() 
//↑これをつけると動かなくなる
