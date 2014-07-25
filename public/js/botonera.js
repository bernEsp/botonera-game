$(function(){
  $(".new_method").submit(function(event){
    if ($("#title").val.length <= 40){
      return;
    }
    event.preventDefault();
  });

});
