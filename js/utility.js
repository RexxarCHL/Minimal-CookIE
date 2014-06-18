// Generated by CoffeeScript 1.7.1
var addInfiniteScroll, allCatAjaxd, convertTimeToSeconds, loadCateogries, loadDeck, loadRecipes, parseSecondsToTime, parseTimeToMinutes, recipeAjaxd;

$(document).ready(function() {
  $("#ToBuyListCookBtn").click(function() {
    getScheduledRecipe(window.recipesInDeck);
    $.ui.loadContent('Cooking');
  });
  return $("#DoneBtn").click(function() {
    db.transaction(function(transaction) {
      var sql;
      sql = 'DELETE FROM `Recipes`';
      transaction.executeSql(sql, [], successCallBack, errorHandler);
      sql = 'DELETE FROM `MenuIngredients`';
      transaction.executeSql(sql, [], function() {
        $("#ToBuyListCookBtn").addClass('hidden');
        $("#EmptyNotify").removeClass('hidden');
        loadDeck();
        return loadRecipes();
      }, errorHandler);
    }, errorHandler, nullHandler);
    window.cookingData = null;
  });
});

addInfiniteScroll = function(scope, delay, callback) {
  var scrollerList;
  console.log("add infinite-scroll to scope:" + scope[0].id);
  scrollerList = scope.scroller();
  scrollerList.clearInfinite();
  scrollerList.addInfinite();
  $.bind(scrollerList, 'infinite-scroll', function() {
    console.log(scope[0].id + " infinite-scroll");
    scope.find("#infinite").text("Loading more...");
    scrollerList.addInfinite();
    clearTimeout(window.lastId);
    return window.lastId = setTimeout(function() {
      return callback();
    }, delay);
  });
};

recipeAjaxd = 0;

loadRecipes = function() {
  var scope;
  console.log("load recipes");
  scope = $('#main_Browse_Recipe');
  scope.find('#Results').html("");
  scope.find("#infinite").text("Reloading...");
  recipeAjaxd = 0;
  getRecipes(recipeAjaxd);
};

allCatAjaxd = 0;

loadCateogries = function() {
  var scope;
  console.log("load categories");
  scope = $("#main_Browse_Category");
  scope.find("#Results").html("");
  scope.find("#infinite").text("Loading...");
  allCatAjaxd = 0;
  getAllCategory(allCatAjaxd);
};

loadDeck = function() {
  var query, recipeId, _i, _len, _ref;
  console.log("loading deck");
  checkRecipeInDB();
  if (window.recipesInDeck.length === 0) {
    $("#main_Deck").find("#Results").html('<h2 style="padding-top:5%;padding-left:5%;">Browse recipes and add it into deck to start!</h2>');
    return;
  }
  $.ui.showMask('Fetching data...');
  query = "";
  _ref = window.recipesInDeck;
  for (_i = 0, _len = _ref.length; _i < _len; _i++) {
    recipeId = _ref[_i];
    query += "recipes=" + recipeId + "&";
  }
  console.log(query);
  $.ajax({
    type: 'GET',
    url: "http://54.178.135.71:8080/CookIEServer/deck_recipe?" + query,
    dataType: 'application/json',
    timeout: 10000,
    success: function(data) {
      var scope;
      data = JSON.parse(data);
      console.log("[SUCCESS]load deck");
      console.log(data);
      scope = $("#main_Deck");
      scope.find("#Results").html("");
      appendRecipeResult(scope, data, true);
      $.ui.hideMask();
    },
    error: function(resp) {
      console.log("[ERROR]load deck");
      console.log(resp);
      $.ui.hideMask();
    }
  });
};

parseTimeToMinutes = function(time) {
  time = time.split(":");
  return time = parseInt(time[0]) * 60 + parseInt(time[1]) + parseInt(time[2]) / 60;
};

convertTimeToSeconds = function(time) {
  time = time.split(":");
  return time = parseInt(time[0]) * 3600 + parseInt(time[1]) * 60 + parseInt(time[2]);
};

parseSecondsToTime = function(seconds) {
  var hour, min;
  hour = Math.floor(seconds / 3600);
  seconds %= 3600;
  hour = hour < 10 ? "0" + hour : hour;
  min = Math.floor(seconds / 60);
  seconds %= 60;
  min = min < 10 ? "0" + min : min;
  seconds = seconds < 10 ? "0" + seconds : seconds;
  return "" + hour + ":" + min + ":" + seconds;
};
