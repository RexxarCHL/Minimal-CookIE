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
    error: function(data, status) {
      console.log("[ERROR]fetch recipe #" + recipeId);
      console.log(data);
    }
  });
};

loadRecipeContent = function(scope, recipe) {
  var group, html, i, imgList, ingredient, ingredientList, step, stepList, _i, _j, _k, _len, _len1, _len2, _ref, _ref1, _ref2;
  $.ui.setTitle(recipe.recipeName);
  scope.find("#Results").hide();
  scope.find("#Loading").show();
  scope.find("#RecipeImg").attr("src", recipe.image);
  scope.find("#RecipeImg").attr("data-recipe-id", recipe.recipeId);
  scope.find("#RecipeDescription").text(recipe.description);
  scope.find("#RecipeUploadInfo").text("Uploaded by: " + recipe.authorName + ", " + (new Date(recipe.date)));
  ingredientList = scope.find("#RecipeIngredientListLeft");
  ingredientList.html("");
  _ref = recipe.ingredientGroup;
  for (_i = 0, _len = _ref.length; _i < _len; _i++) {
    group = _ref[_i];
    html = '';
    _ref1 = group.ingredients;
    for (_j = 0, _len1 = _ref1.length; _j < _len1; _j++) {
      ingredient = _ref1[_j];
      html += '<li>' + ingredient.ingredientName + " .............. " + ingredient.amount + " " + ingredient.unitName;
    }
    html += '<br />';
    ingredientList.append(html);
  }
  stepList = scope.find("#RecipeSteps");
  stepList.html("");
  _ref2 = recipe.stepDigests;
  for (i = _k = 0, _len2 = _ref2.length; _k < _len2; i = ++_k) {
    step = _ref2[i];
    html = '<li>' + i + '. ' + step.digest + '</li>';
    stepList.append(html);
  }
  stepList.append('<br />');
  imgList = scope.find("#RecipePhotos");
  scope.find("#Loading").hide();
  scope.find("#Results").show();
};
