// 通知テーブルのデータがある時に呼び出されるアラート
$(document).on('turbolinks:load', function() {
    var p = $("div").hasClass('flashes');
    if (p) {
      alert('通知があります！');
    }
})

// ページのトグルの部分
$(document).on('turbolinks:load', function() {
	$("#kitchen_nav_button").click(function(){
		$("#kitchen_nav_button2").slideToggle();
	});
});

// テーブルの状態を示す部分
$(document).on('turbolinks:load', function() {
    $(".table_indiv").each(function(i){
    
    var color = $(".table_indiv span").eq(i).html();
    // console.log(color)
      if (color == 1) {
          $(".table_indiv").eq(i).addClass("blue2");
      } else if (color == 2){
          $(".table_indiv").eq(i).addClass("green");
      } else {
          $(".table_indiv").eq(i).addClass("gray");
      }        
    });
});


// 調理待の状態を示す部分
$(document).on('turbolinks:load', function() {
    $(".cooked").each(function(i){
    
    var color = $(".cooked span").eq(i).html();

      if (color == 2) {
          $(".cooked").eq(i).addClass("orange2");
      }        
    });
});

// 調理待のページ
// 同じ料理があったら、その料理の背景をハイライトする機能
$(document).on('turbolinks:load', function() {
  var arr1 = new Array();
  // ↑全てのmenu_idを入れる配列

  $(".forcook_menu_indiv_name").each(function(i){
    arr2 = $(".forcook_menu_indiv_name span").eq(i).html();
    arr1.unshift(arr2);
    // メニュー番号を取り出して、配列へ
  });

  // ↓2回以上出てきたmenu_idをarr3配列へ
  var arr3 = arr1.filter(function (val, idx, arr){
    return arr.indexOf(val) === idx && idx !== arr.lastIndexOf(val);
  });
  
  // arr3の番号と同じ番号があるクラスの背景を変える
  $(".forcook_menu_indiv_name").each(function(i){
    var aaa = $(".forcook_menu_indiv_name span").eq(i).html();
    $.each(arr3, function(index, value) {
      var bbb = value;
      if (aaa == bbb && aaa != 0) {
        // オプションのidを0として渡しているので、
        // 0の以外のもので、共通するものがあったら、背景を変えるようにしている
        $(".forcook_menu_indiv_name").eq(i).css("background", "#f4bfca");
        return false;
        // ↑同じものが見つかったら、他のものとの比較はしなくてもいいようにする
      }
    });
  });
});

// menu_idを使わずに文字列で取り出したバージョン
// $(document).on('turbolinks:load', function() {
//   $(".destroy_btn").click(function(){
//     console.log(1)
//     // var number = $(".plus_btn").index(this);
//     // var letter = $(".preorder_menu_number2 p").eq(number).html();
//     // // 文字列を数値にする↓
//     // letter = parseInt(letter);

//     // if (letter < 4 ) {
//     //     var letter2 = letter + 1
//     //     $(".preorder_menu_number2 p").eq(number).html(letter2);
//     //     $(".orderlist_number_value").eq(number).val(letter2);

//     // }
//   });
// })


// $(document).on('turbolinks:load', function() {
//   var arr1 = new Array();

//   $(".forcook_menu_indiv_name").each(function(i){
//   arr2 = $(".forcook_menu_indiv_name p").eq(i).html();
//   arr1.unshift(arr2);
//   });

// var arr3 =
//   arr1.filter(function (val, idx, arr){
//     return arr.indexOf(val) === idx && idx !== arr.lastIndexOf(val);
//   });
//   // console.log(arr3)
//   $(".forcook_menu_indiv_name").each(function(i){
//     var aaa = $(".forcook_menu_indiv_name p").eq(i).html();
    
//     $.each(arr3, function(index, value) {
//       var bbb = value
//       if (aaa == bbb){
//         $(".forcook_menu_indiv_name").eq(i).css("background", "pink");
//         // consosle.log(bbb)
//         return false
//       }
//     })
//   });
// });