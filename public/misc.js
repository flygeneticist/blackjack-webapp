function validateWagerForm()
{
var bankroll=document.forms["newround_wager"]["secret-bankroll"].value;
var minbid=document.forms["newround_wager"]["minbid"].value;
var maxbid=document.forms["newround_wager"]["maxbid"].value;
var wager=document.forms["newround_wager"]["wager"].value;
if (wager==null || wager=="" || wager==0 || (bankroll-wager) < 0)
  {
  alert("Wager must not be blank, zero, or greater than your bankroll!");
  return false;
  }
if ((wager-maxbid) > 0 || (wager-minbid) < 0)
  {
  alert("Wager must be within the table limits!");
  return false;
  }
  return true;
}

function validateNewPlayerForm()
{
var bankroll=document.forms["gamesettings"]["bankroll"].value;
var player=document.forms["gamesettings"]["player"].value;
var wager=document.forms["gamesettings"]["wager"].value;
var minbid=document.forms["gamesettings"]["minbid"].value;
var maxbid=document.forms["gamesettings"]["maxbid"].value;
if (player==null || player=="")
  {
  alert("Please enter a player name!");
  return false;
  }
if (wager==null || wager=="" || wager==0 || (bankroll-wager) < 0)
  {
  alert("Wager must not be blank, zero, or greater than your bankroll!");
  return false;
  }
if ((wager-maxbid) > 0 || (wager-minbid) < 0)
  {
  alert("Wager must be within the table limits!");
  return false;
  }
  return true;
}

$(function(){
  validateNewPlayerForm();
  validateWagerForm();
});

// TEST CODE BEYOND THIS POINT
$(document).on("click","form#hit_form button", function(){
    alert("HELP!");

    $.ajax ({
      type: "POST"
      url: "/game/player/hit"
    }).done(function(msg){
      $("#player-hand").replaceWith(msg)
    });

    return false;
  });
}
