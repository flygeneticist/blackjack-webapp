function validateWagerForm()
{
var wager=document.forms["newround_wager"]["bankroll"].value;
var wager=document.forms["newround_wager"]["wager"].value;
if (wager==null || wager=="" || wager==0 || wager>bankroll)
  {
  alert("Wager must not be blank, zero, or greater than your bankroll!");
  return false;
  }
  return true;
}

function validateNewPlayerForm()
{
var bankroll=document.forms["gamesettings"]["bankroll"].value;
var player=document.forms["gamesettings"]["player"].value;
var wager=document.forms["gamesettings"]["wager"].value;
if (player==null || player=="")
  {
  alert("Please enter a player name!");
  return false;
  }
if (wager==null || wager=="" || wager==0 || wager>bankroll)
  {
  alert("Wager must not be blank, zero, or greater than your bankroll!");
  return false;
  }
  return true;
}

$(function(){
  validateNewPlayerForm();
  validateWagerForm();
});

// TEST CODE BEYOND THIS POINT
