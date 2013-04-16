var alertMe = false;
var alertAt = 5;
var gameNum = null;

$( function() {
  $(".hidden").hide();
  updateBotStatus();

  $('#current-game').click(function(){
    $('#current-game-hidden-area').show();
    $('#current-game-title').hide(1000);
  });
  
  $('#alert-me').change(function(){
    if ($(this).attr('checked')) {
      alertMe = true;
    } else {
      alertMe = false;
    }
  });
  
  $('#alert-at').change(function(){
    alertAt = $(this).val();
    if (alertAt > 12 || alertAt < 1) {
      if (alertAt > 12) alertAt = 12;
      if (alertAt < 1) alertAt = 1;
      $(this).val(alertAt);
    }
  });
});
        
function updateBotStatus () {
  $.ajax({
    url: "/botstatus.html",
    cache: false,
    dataType: "json"
  }).done(function(gameobj){
    if (gameobj==null) updateBotStatus();
    else {
      var currGameNum = parseInt(gameobj.gamename.match(/[0-9][0-9][0-9][0-9]|[0-9][0-9][0-9]|[0-9][0-9]|[0-9]/));
      if (!gameNum) gameNum = currGameNum;
      var numPlayer = null;
      var html = "<br>";
      var twgbtime = new Date(gameobj.datetime);
      var tttt = twgbtime.getTime();
      var currenttime = new Date();
      var cttt = currenttime.getTime();
      var ctts = currenttime.toString();
      var x = ctts.indexOf(' ');
      var y = ctts.lastIndexOf(':');
      ctts = ctts.substr(x+1,y-x-1);
      var m = ctts.match(/[0-9]\ /g);
      for (var i=0;i<m.length;i++) {
        ctts = ctts.replace(m[i],m[i].substr(0,m[i].length-1)+", ");
      }
      if (cttt > tttt + 240000) {
        html += "<b>A bot isn't responding</b><br>";
        html += "<br>"+ctts;
      }
      else {
        html += "<b>"+gameobj.gamename+"</b><br>";
        if ( gameobj.slotsfull ) {
          html += "Slots Full: "+gameobj.slotsfull+"<br><br>";
          html += $("#servers").html();
          numPlayer = parseInt(gameobj.slotsfull.substr(1,gameobj.slotsfull.length-3))
        }
        html += "<br>"+ctts;
      }
      $('#botstatus').html(html);
      if (alertMe && gameobj.slotsfull && numPlayer >= alertAt) {
        alertMe = false;
        $('#alert-me').removeAttr('checked');
        alert("Game has reached "+numPlayer+" players!");
      }
      else if (alertMe && gameobj.slotsfull && (currGameNum > gameNum || gameobj.gamename=="The hostbot is in the channel") ) {
        alertMe = false;
        $('#alert-me').removeAttr('checked');
        alert("Game has started!");
      }
      gameNum = currGameNum;
    }
  });
  setTimeout("updateBotStatus()",10000);   
}    