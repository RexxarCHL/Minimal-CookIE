// Generated by CoffeeScript 1.7.1
var getRecipeContent, loadRecipeContent;

getRecipeContent = function(recipeId) {
  $.ajax({
    type: 'GET',
    url: 'http://54.178.135.71:8080/CookIEServer/recipedigest',
    dataType: 'application/json',
    data: {
      'recipe_id': recipeId
    },
    timeout: 10000,
    success: function(data) {
      var scope;
      data = JSON.parse(data);
      console.log("[SUCCESS]fetch recipe #" + recipeId);
      console.log(data);
      scope = $("#RecipeContent");
      setTimeout(loadRecipeContent(scope, data), 1000);
    },
    error: function(resp) {
      console.log("[ERROR]fetch recipe #" + recipeId);
      console.log(resp);
      if (resp.status === 0) {
        alert("Server Error. Try again later.");
      } else {
        alert("Connection Error: " + resp.status);
      }
      $.ui.loadContent("main_Browse_Recipe");
    }
  });
};

loadRecipeContent = function(scope, recipe) {
  var group, html, i, id, imgList, ingListLeft, ingListRight, ingredient, j, len, step, stepList, thisRecipeBtn, _i, _j, _k, _len, _len1, _len2, _ref, _ref1, _ref2;
  $.ui.setTitle(recipe.recipeName);
  scope.find("#Results").hide();
  scope.find("#Loading").show();
  scope.find("#RecipeImg").attr("src", recipe.image);
  scope.find("#RecipeImg").attr("data-recipe-id", recipe.recipeId);
  scope.find("#RecipeDescription").text(recipe.description);
  scope.find("#RecipeUploadInfo").text("Uploaded by: " + recipe.authorName + ", " + (new Date(recipe.date)));
  len = recipe.ingredientGroup[0].length;
  len = Math.ceil(len / 2);
  ingListLeft = scope.find("#RecipeIngredientListLeft")[0];
  ingListLeft.firstElementChild.innerHTML = "";
  ingListLeft.lastElementChild.innerHTML = "";
  ingListRight = scope.find("#RecipeIngredientListRight")[0];
  ingListRight.firstElementChild.innerHTML = "";
  ingListRight.lastElementChild.innerHTML = "";
  _ref = recipe.ingredientGroup;
  for (i = _i = 0, _len = _ref.length; _i < _len; i = ++_i) {
    group = _ref[i];
    html = '';
    _ref1 = group.ingredients;
    for (j = _j = 0, _len1 = _ref1.length; _j < _len1; j = ++_j) {
      ingredient = _ref1[j];
      console.log(ingredient.ingredientName);
      if ((i + j) % 2) {
        html = "<li>" + ingredient.ingredientName + "</li>";
        $(ingListRight.firstElementChild).append(html);
        html = "<li>" + ingredient.amount + ingredient.unitName + "</li>";
        $(ingListRight.lastElementChild).append(html);
      } else {
        html = "<li>" + ingredient.ingredientName + "</li>";
        $(ingListLeft.firstElementChild).append(html);
        html = "<li>" + ingredient.amount + ingredient.unitName + "</li>";
        $(ingListLeft.lastElementChild).append(html);
      }
    }
  }
  stepList = scope.find("#RecipeSteps");
  stepList.html("");
  _ref2 = recipe.stepDigests;
  for (i = _k = 0, _len2 = _ref2.length; _k < _len2; i = ++_k) {
    step = _ref2[i];
    html = '<li>' + (i + 1) + '. ' + step.digest + '</li>';
    stepList.append(html);
  }
  stepList.append('<br />');
  imgList = scope.find("#RecipePhotos");
  id = recipe.recipeId;
  if (window.recipesInDeck.lastIndexOf(id) !== -1) {

    /* recipe already in the deck */
    scope.find("#RecipeContentBtn")[0].outerHTML = '<div id="RecipeContentBtn" class="button" style="width:100%;background-color:#D8D8D8;opacity:.8;height:8%;border-radius:0;border:0;">已加入 Deck</div>';
    thisRecipeBtn = scope.find("#RecipeContentBtn");
    thisRecipeBtn.click(function() {
      $.ui.loadContent('main_Deck');
      return void 0;
    });
  } else {
    scope.find("#RecipeContentBtn")[0].outerHTML = '<div id="RecipeContentBtn" class="button" style="width:100%;background:hsl(204.1,35%,53.1%);opacity:.8;height:8%;border-radius:0;border:0;">加到 Deck</div>';
    thisRecipeBtn = scope.find("#RecipeContentBtn");
    thisRecipeBtn.click((function(id) {
      return function() {
        addThisRecipeToDeck(id);
        thisRecipeBtn[0].outerHTML = '<div id="RecipeContentBtn" class="button" style="width:100%;background-color:#D8D8D8;height:8%;border-radius:0;border:0;">已加入 Deck</div>';
        $("#main_Browse_Recipe").find("#Recipe" + id).find(".recipe_btn")[0].outerHTML = '<div class="button recipe_btn recipe_in_deck_btn" >已加入 Deck</div>';
        return void 0;
      };
    })(id));
  }
  scope.find("#Loading").hide();
  scope.find("#Results").show();
};
