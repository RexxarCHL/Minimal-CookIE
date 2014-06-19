// Generated by CoffeeScript 1.7.1

/*
ajaxSearchResults2
 	search(query, times)
 		Search for 'query' in server. Fetch (times*20)th to (times*20+20)th results.
 */
var appendSearchResults, recipeAjaxd, search, searchAjaxd;

searchAjaxd = 0;

recipeAjaxd = 0;

window.query = 0;

$(document).ready(function() {
  $("#SearchBar").keyup(function() {
    var scope;
    console.log("searchbar keyup");
    clearTimeout(window.lastId);
    scope = $('#main_Browse_Recipe');
    window.query = $("#SearchBar")[0].value;
    if (window.query === "") {
      searchAjaxd = 0;
      $("#SearchResults").html("");
      $("#SearchResults").addClass('hidden');
      scope.find("#Results").removeClass('hidden');
      return;
    }
    scope.scroller().clearInfinite();
    scope.find("#infinite").text("Searching...");
    scope.find("#Results").addClass('hidden');
    scope.find("#SearchResults").removeClass('hidden');
    window.lastId = setTimeout(function() {
      search(window.query, searchAjaxd);
    }, 1500);
  });
});

search = function(query, times) {
  var type, url;
  type = 0;
  url = 'http://54.178.135.71:8080/CookIEServer/discover_recipes';
  $.ajax({
    type: "GET",
    url: url,
    dataType: 'application/json',
    data: {
      'type': 'search',
      'name': query,
      'times': searchAjaxd
    },
    timeout: 10000,
    success: function(data) {
      var scope, scrollerList;
      data = JSON.parse(data);
      console.log("[SUCCESS]search");
      console.log(data);
      scope = $("#main_Browse_Recipe");
      searchAjaxd++;
      scrollerList = $("#main_Browse_Recipe").scroller();
      scrollerList.clearInfinite();
      if (data.length === 0) {
        if (searchAjaxd > 0) {
          $("#main_Browse_Recipe").find("#infinite").html("<i>No more results.</i>");
        } else {
          $("#main_Browse_Recipe").find("#infinite").html("<i>No result. Try another query?</i>");
        }
        searchAjaxd--;
        return;
      }
      appendSearchResults(data);
    },
    error: function(resp) {
      console.log("[ERROR]search: " + resp.status);
      $("#main_Browse_Recipe").scroller().clearInfinite();
      if (resp.status === 0) {
        $("#main_Browse_Recipe").find("#infinite").html("Server Error. Try again later.");
      } else {
        $("#main_Browse_Recipe").find("#infinite").html("Unknow Error: " + resp.status);
      }
    }
  });
};

appendSearchResults = function(data) {
  var count, exist, html, id, name, rating, recipe, results, thisRecipe, url, _i, _len;
  console.log("Append search results");
  results = $("#SearchResults");
  results.find('.new').removeClass('new');
  count = 0;
  for (_i = 0, _len = data.length; _i < _len; _i++) {
    recipe = data[_i];
    html = '';
    id = recipe.recipe_id;
    name = recipe.name;
    rating = recipe.rating;
    url = recipe.smallURL;
    exist = checkRecipeInDeck(id) ? true : false;
    if (count % 2) {
      html += '<div class="recipe_item right new" id="Recipe' + id + '" data-recipe-id="' + id + '">';
    } else {
      html += '<div class="recipe_item left new" id="Recipe' + id + '" data-recipe-id="' + id + '">';
    }
    html += '<div class="recipe_item_container">';
    html += '<img class="recipe_image_wrapper" src="' + url + '">';
    html += '<div class="recipe_descrip chinese_font">' + name + '</div>';
    html += '<div class="recipe_cooked">人氣：' + recipe.popularity + '</div></div>';
    if (!exist) {
      html += '<div class="button recipe_btn recipe_add_btn chinese_font">加到 Deck</div>';
    } else {
      html += '<div class="button recipe_btn recipe_in_deck_btn chinese_font">已加入 Deck</div>';
    }
    html += '</div>';
    results.append(html);
    count++;
    thisRecipe = results.find("#Recipe" + id);
    thisRecipe.find("img").click((function(id) {
      return function() {
        $.ui.loadContent("#RecipeContent");
        $("#RecipeContent").find("#Results").hide();
        $("#RecipeContent").find("#Loading").show();
        getRecipeContent(id);
      };
    })(id));
    if (!exist) {
      thisRecipe.find(".recipe_btn").click((function(id, thisRecipe) {
        return function() {
          addThisRecipeToDeck(id);
          thisRecipe.find(".recipe_btn")[0].outerHTML = '<div class="button recipe_btn recipe_in_deck_btn chinese_font">已加入 Deck</div>';
        };
      })(id, thisRecipe));
    }
  }
  results.find("#bottomBar").remove();
  results.append('<div id="bottomBar" style="display:block;height:0;clear:both;">&nbsp;</div>');
  return $("#main_Browse_Recipe").find("#infinite").text("Load More");
};
