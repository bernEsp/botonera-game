$(function(){
  $(".new_method").submit(function(event){
    if ($("#title").val.length <= 15){
      return;
    }
    event.preventDefault();
  });

});
