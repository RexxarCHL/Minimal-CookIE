// Generated by CoffeeScript 1.7.1
var addInfiniteScroll, convertTimeToSeconds, loadDeck, loadRecipes, parseSecondsToTime, parseTimeToMinutes, recipeAjaxd;

$(document).ready(function() {});

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

loadDeck = function() {
  var query, recipeId, _i, _len, _ref;
  console.log("loading deck");
  $.ui.showMask('Fetching data...');
  checkRecipeInDB();
  if (window.recipesInDeck.length === 0) {
    return;
  }
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
