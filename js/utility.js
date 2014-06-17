// Generated by CoffeeScript 1.7.1
var addInfiniteScroll, addThisRecipeToDeck, checkRecipeInDB, checkRecipeInDeck, convertTimeToSeconds, deleteThisRecipeFromDeck, findChosenRecipeId, loadRecipes, parseSecondsToTime, parseTimeToMinutes, recipeAjaxd, resetSelectedRecipe;

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

findChosenRecipeId = function() {

  /* TODO */
  var recipeSelectedId;
  recipeSelectedId = [];
  $('#main_Kitchen_Recipes').find('.chosen').forEach(function(elem) {
    return recipeSelectedId.push(elem.getAttribute('data-recipe-id'));
  });
  console.log(recipeSelectedId);
  return recipeSelectedId;
};


/* Recipe -> Deck */

addThisRecipeToDeck = function(id) {
  var html, leftright, scope, thisRecipeBtn;
  console.log("Add recipe #" + id + " to deck");

  /* Push if not already in deck */
  if (window.recipesInDeck.lastIndexOf(id) === -1) {
    window.recipesInDeck.push(id);
    AddRecipeValue(id);
  }
  html = $("#Recipe" + id).html();
  scope = $("#main_Deck").find("#Results");
  scope.find(".new").removeClass('new');
  scope.find("#bottomBar").remove();

  /* Append the recipe directly from Browse Recipe */
  if (scope.length % 2) {
    leftright = 'left';
  } else {
    leftright = 'right';
  }
  scope.append("<div class='kitchen_recipe_item " + leftright + " new' data-recipe-id='" + id + "'>" + html + "</div>");

  /* Add bottomBar to maintain the scroller */
  scope.append('<div id="bottomBar" style="display:block;height:0;clear:both;"> </div>');

  /* Modify the button */
  thisRecipeBtn = scope.find(".new").find(".recipe_btn");
  thisRecipeBtn.removeClass('recipe_in_deck_btn').removeClass('recipe_add_btn');
  thisRecipeBtn.addClass('recipe_remove_btn');
  thisRecipeBtn.html("Remove from Deck");

  /* Add onclick function to remove btn */
  thisRecipeBtn.click((function(id) {
    return function() {
      deleteThisRecipeFromDeck(id);
    };
  })(id));
};

deleteThisRecipeFromDeck = function(id) {

  /* TODO */
  console.log("delete " + id + " from deck");

  /* delete from DB */
  deleteRecipe(id);
  return checkRecipeInDB();
};

checkRecipeInDeck = function(id) {
  if (window.recipesInDeck.lastIndexOf(id) === -1) {
    return false;
  } else {
    return true;
  }
};

checkRecipeInDB = function() {
  var sql;
  if (!window.openDatabase) {
    alert('Databases are not supported in this browser.');
    return;
  }
  sql = 'SELECT `recipeId` FROM `Recipes`';
  db.transaction(function(transaction) {
    transaction.executeSql(sql, [], function(transaction, result) {
      var i, row, x, _i, _len, _ref;
      if ((result != null) && (result.rows != null)) {

        /* There is recipe in deck */
        console.log("OK");
        _ref = result.rows;
        for (i = _i = 0, _len = _ref.length; _i < _len; i = ++_i) {
          x = _ref[i];
          row = result.rows.item(i);
          window.recipesExist = 1;
          console.log(row.recipeId);
          window.recipesInDeck.push(row.recipeId);
        }
        return;
      }
      console.log("NOT OK");
      return window.recipesExist = 0;
    }, errorHandler);
  }, errorHandler, nullHandler);
};

resetSelectedRecipe = function() {

  /* TODO */
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
