// Generated by CoffeeScript 1.7.1

/*
ajaxCooking.coffee
	ajax the scheduled plan of cook and show the data

	getScheduledRecipe(recipeIds)
		get the scheduled plan for 'recipeIds'
	appendData(scope, data)
		show the information of the scheduled plan
 */
var appendData, getScheduledRecipe;

getScheduledRecipe = function(recipeIds) {
  var ans, data, id, _i, _len;
  if (window.cookingData != null) {
    ans = confirm("You have a cooking in progress. Resume?");
    if (ans === true) {
      $.ui.loadContent("Step");
      return;
    }
  }
  console.log("schedule_recipe #" + recipeIds);
  $.ui.updatePanel("Cooking", "");
  $.ui.showMask("Loading data from server...");
  $.ui.blockUI(.1);
  data = '';
  for (_i = 0, _len = recipeIds.length; _i < _len; _i++) {
    id = recipeIds[_i];
    data += 'recipes=' + id + '&';
  }
  $.ajax({
    type: 'GET',
    url: 'http://54.178.135.71:8080/CookIEServer/schedule_recipe?' + data,
    success: function(data) {
      var scope;
      data = JSON.parse(data);
      console.log('[SUCCESS] fetching #' + recipeIds);
      console.log(data);
      scope = $('#Cooking');
      window.cookingData = data;
      window.currentStepNum = 0;
      appendData(scope, data);
    },
    error: function(resp) {
      console.log('[ERROR] fetching #' + recipeIds);
      console.log(resp);
      $.ui.unblockUI();
      $.ui.hideMask();
      if (resp.status === 404) {
        alert("Server aborted the scheduling process. Please try again with fewer recipes.");
      } else if (resp.status === 0) {
        alert("Server Error. Try again later.");
      } else {
        alert("Connection error: " + resp.status);
      }
      $.ui.loadContent("main_Deck");
    }
  });
};

appendData = function(scope, data) {
  console.log("append scheduled plan");
  $.ui.updatePanel("Cooking", "" + '<div style="background-color:#F2F2F2">' + '<h2 style="margin-left:5%;margin-top:5%">本次共有 <span id="totalRecipes">' + data.recipeLength.length + '</span> 道食譜排程</h2>' + '<h2 style="margin-left:5%;">原本需要時間：</h2>' + '<i id="originalCookingTime" style="margin-left:7%;font-size:17px;">' + data.originTime + '</i>' + '<h2 style="margin-left:5%;">排程優化時間：</h2>' + '<i id="scheduledCookingTime" style="margin-left:7%;font-size:17px;">' + data.scheduledTime + '</i>' + '<br />' + '<div class="bottom_btn_holder" style="margin-top:80%;">' + '<a class="button" style="width:100%;background: hsl(204.1,35%,53.1%);height:10%;color:white;text-shadow: -1px -1px gray;border-radius: 8px;" href="#Step">開始！</a>' + '</div>' + '</div>');
  $.ui.unblockUI();
  $.ui.hideMask();
};
