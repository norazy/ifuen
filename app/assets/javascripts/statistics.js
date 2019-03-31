// 月別のランキングの中身の切り替え部分
window.addEventListener('turbolinks:load', function() {
  $(".select_month li").on("click", function() {
    $("li.selected").removeClass("selected");
    $(this).addClass("selected");
    $(".ranking_table").children().hide();
    $("."+this.id).show();
  }); 
});