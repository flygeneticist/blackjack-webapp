$(document).ready(function(){
  $('#rules_list').find('dd').hide().end().find('dt').click(function(){
    $(this).next().slideDown();
    $(this).siblings('dd').not($(this).next()).slideUp();
  });
});

// TEST CODE BEYOND THIS POINT
function.addremovePlayers
  $('#add').click(function(){
    $('#extender').fadeIn('fast');
  });
  $('#remove').click(function(){
    $('#extender').fadeOut('slow');
  });
});

$("#hit_button").click(function(){
  $.getJSON("/game/player/hit");
});
