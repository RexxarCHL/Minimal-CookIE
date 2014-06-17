// Generated by CoffeeScript 1.7.1

/*
ajaxSearchResults2
 	search(query, times)
 		Search for 'query' in server. Fetch (times*20)th to (times*20+20)th results.
 */
var recipeAjaxd, search, searchAjaxd;

searchAjaxd = 0;

recipeAjaxd = 0;

$(document).ready(function() {
  initSelectBtn();
  $("#SearchBar").keyup(function() {
    var query;
    console.log("searchbar keyup");
    clearTimeout(window.lastId);
    query = $("#SearchBar")[0].value;
    if (query === "") {
      searchAjaxd = 0;
      recipeAjaxd = 0;
      getRecipes(recipeAjaxd);
      return;
    }
    $('#main_Browse_Recipe').scroller().clearInfinite();
    $("#main_Search").find("#infinite").text("Searching...");
    window.lastId = setTimeout(function() {
      search(query, searchAjaxd);
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
      scope = $("#main_Search");
      if (searchAjaxd === 0) {
        addInfiniteScroll(scope, 1000, function() {
          return $("#SearchBar").trigger("keyup");
        });
      }
      searchAjaxd++;
      scrollerList = $("#main_Search").scroller();
      scrollerList.clearInfinite();
      if (data.length === 0) {
        if (searchAjaxd > 0) {
          $("#main_Search").find("#infinite").html("<i>No more results.</i>");
        } else {
          $("#main_Search").find("#infinite").html("<i>No result. Try another query?</i>");
        }
        searchAjaxd--;
        return;
      }
      appendRecipeResult(scope, data);
    },
    error: function(data, status) {
      console.log("[ERROR]search: " + status);
      $("#main_Search").scroller().clearInfinite();
    }
  });
};
