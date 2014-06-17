// Generated by CoffeeScript 1.7.1
var appendSteps, getCookingIngredientList, getScheduledRecipe, loadIngredientList;

getCookingIngredientList = function(recipeIds) {
  var ans, data, id, _i, _len;
  if (window.cookingData != null) {
    ans = confirm("You have a cooking in progress. Resume?");
    if (ans === true) {
      $.ui.loadContent("Step");
    } else {
      window.cookingData = null;
    }
  }
  data = '';
  recipeIds = JSON.parse(recipeIds);
  for (_i = 0, _len = recipeIds.length; _i < _len; _i++) {
    id = recipeIds[_i];
    data += 'recipes=' + id + '&';
  }
  $.ajax({
    type: 'GET',
    url: 'http://54.178.135.71:8080/CookIEServer/list_ingredient?' + data,
    timeout: 10000,
    success: function(data) {
      var scope;
      data = JSON.parse(data);
      console.log('[SUCCESS] fetching #' + recipeIds);
      console.log(data);
      scope = $('#Ingredients');
      loadIngredientList(scope, data, recipeIds);
    },
    error: function(data, status) {
      console.log('[ERROR] fetching #' + recipeIds);
      console.log(data);
    }
  });
};

loadIngredientList = function(scope, list, recipeIds) {
  var html, ingredient, listContent, _i, _len;
  listContent = scope.find('#ListContent');
  listContent.html("");
  for (_i = 0, _len = list.length; _i < _len; _i++) {
    ingredient = list[_i];
    html = "<input type='checkbox' id='" + ingredient.ingredientId + "' /><label for='" + ingredient.ingredientId + "'>";
    html += "<b>" + ingredient.amount + ingredient.unitName + "</b> " + ingredient.ingredientName + "</label>";
    listContent.append(html);
  }
  scope.find("#Next").unbind('click');
  scope.find("#Next").click((function(list) {
    return function() {
      return getScheduledRecipe(recipeIds);
    };
  })(list));
  scope.find("#Loading").hide();
  scope.find("#Results").show();
};

getScheduledRecipe = function(recipeIds) {
  var data, id, _i, _len;
  console.log("schedule_recipe #" + recipeIds);
  $.ui.showMask("Loading data from server...");
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
      appendSteps(scope, data);
    },
    error: function(data, status) {
      console.log('[ERROR] fetching #' + recipeIds);
      console.log(data);
      $.ui.hideMask();
      alert("ERROR");
      $.ui.loadContent("main_Popular_Recipes");
    }
  });
};

appendSteps = function(scope, data) {
  var html, step, stepsList, _i, _len, _ref;
  console.log("append steps");
  $.ui.showMask("Processing Data");
  scope.find("#totalCookingTime").html("<b>" + parseTimeToMinutes(data.originTime) + " mins -> " + parseTimeToMinutes(data.scheduledTime) + " min</b>");
  stepsList = scope.find("#stepsList");
  stepsList.html('<h2 style="margin-left:5%;">Steps:</h2>');
  html = "";
  _ref = data.steps;
  for (_i = 0, _len = _ref.length; _i < _len; _i++) {
    step = _ref[_i];
    html = '<div class="overview_stepWrapper">';
    if (steps.imageURL != null) {
      html += '<img src="' + steps.imageURL + '" class="overview_stepImg"></img>';
    }
    html += '<h3 class="overview_stepText">' + (_i + 1) + '. ' + step.digest + '</h3>';

    /*debug */
    html += "    time: " + step.time + ", people: " + step.people + ", start time: " + step.startTime;
    html += '</div>';
    stepsList.append(html);
  }
  $.ui.hideMask();
};