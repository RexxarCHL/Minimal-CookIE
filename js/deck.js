// Generated by CoffeeScript 1.7.1
var addThisRecipeToDeck, checkRecipeInDB, checkRecipeInDeck, deleteThisRecipeFromDeck, findRecipeIdsInDeck;

$(document).ready(function() {
  $("#ToBuyBtn").click(function() {
    var recipeIds;
    recipeIds = findRecipeIdsInDeck();
    getIngredientList(recipeIds);
  });
  $("#CookBtn").click(function() {
    var recipeIds;
    recipeIds = findRecipeIdsInDeck();
    getScheduledRecipe(recipeIds);
  });
});

addThisRecipeToDeck = function(id) {
  console.log("Add recipe #" + id + " to deck");

  /* Push if not already in deck */
  if (window.recipesInDeck.lastIndexOf(id) === -1) {
    AddRecipeValue(id);
    checkRecipeInDB();
  }
};

deleteThisRecipeFromDeck = function(id) {

  /* TODO */
  var index, thisRecipeBtn;
  console.log("delete " + id + " from deck");

  /* If not in deck, which is not possible but check anyway */
  if ((index = window.recipesInDeck.lastIndexOf(id)) === -1) {
    return;
  }
  window.recipesInDeck.splice(index, 1);
  console.log("deck: " + window.recipesInDeck);

  /* delete from DB */
  deleteRecipe(id);
  checkRecipeInDB();
  thisRecipeBtn = $("#Recipe" + id);
  thisRecipeBtn.find(".recipe_btn")[0].outerHTML = '<div class="button recipe_btn recipe_add_btn chinese_font" style="width:80%;text-align:center;text-shadow:-1px -1px gray;padding:8px 0px;margin-top:5%;margin-bottom:3px;margin-left:10%;border:none;">Add To Deck</div>';
  thisRecipeBtn = thisRecipeBtn.find(".recipe_btn");
  thisRecipeBtn.unbind('click');
  thisRecipeBtn.click((function(id) {
    return function() {
      addThisRecipeToDeck(id);
      $("#main_Browse_Recipe").find("#Recipe" + id).find(".recipe_btn")[0].outerHTML = '<div class="button recipe_btn recipe_in_deck_btn chinese_font" style="color:gray;width:80%;text-align:center;padding:8px 0px;margin-top:5%;margin-bottom:3px;margin-left:10%;border:none;">已加入 Deck</div>';
    };
  })(id));
};

findRecipeIdsInDeck = function() {
  var recipeIds;
  recipeIds = [];
  $('#main_Deck').find('.recipe_item').forEach(function(elem) {
    return recipeIds.push(elem.getAttribute('data-recipe-id'));
  });
  console.log(recipeIds);
  return recipeIds;
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
        window.recipesInDeck = [];
        _ref = result.rows;
        for (i = _i = 0, _len = _ref.length; _i < _len; i = ++_i) {
          x = _ref[i];
          row = result.rows.item(i);
          window.recipesExist = 1;
          window.recipesInDeck.push(row.recipeId);
        }
        return;
      }
      console.log("NOT OK");
      return window.recipesExist = 0;
    }, errorHandler);
  }, errorHandler, nullHandler);
};
