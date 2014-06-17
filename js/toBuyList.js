// Generated by CoffeeScript 1.7.1
var getIngredientList, showIngredientList, storeIngredientListToDB;

getIngredientList = function(recipeIds) {
  var data, id, _i, _len;
  console.log("get ingredient list");
  data = '';
  for (_i = 0, _len = recipeIds.length; _i < _len; _i++) {
    id = recipeIds[_i];
    data += 'recipes=' + id + '&';
  }
  $.ajax({
    type: 'GET',
    url: 'http://54.178.135.71:8080/CookIEServer/list_ingredient?' + data,
    timeout: 10000,
    success: function(data) {
      data = JSON.parse(data);
      console.log('[SUCCESS] fetching #' + recipeIds);
      console.log(data);
      storeIngredientListToDB(data);
      showIngredientList();
    },
    error: function(data, status) {
      console.log('[ERROR] fetching #' + recipeIds);
      console.log(data);
    }
  });
};

storeIngredientListToDB = function(data) {
  var ingredient, _i, _len;
  console.log("store ingredient list to db");
  db.transaction(function(transaction) {
    transaction.executeSql('DELETE FROM `MenuIngredients`', [], successCallBack, errorHandler, errorHandler, nullHandler);
  });
  for (_i = 0, _len = data.length; _i < _len; _i++) {
    ingredient = data[_i];
    AddValueToIngredient(ingredient.ingredientId, ingredient.recipeId, ingredient.ingredientName, ingredient.amount, ingredient.unitName);
  }
};

showIngredientList = function() {
  if (!window.openDatabase) {
    alert('Databases not supported by this browser');
    return;
  }
  console.log("show ingredient list");
  return db.transaction(function(transaction) {
    transaction.executeSql('SELECT * FROM MenuIngredients', [], function(transaction, result) {
      var html, i, list, row, x, _i, _len, _ref;
      if ((result != null) && (result.rows != null)) {
        list = $("#list");
        list.html("");
        html = '';
        _ref = result.rows;
        for (i = _i = 0, _len = _ref.length; _i < _len; i = ++_i) {
          x = _ref[i];
          row = result.rows.item(i);
          html += '<li class="listEle">' + row.name + '&nbsp;' + row.amount + '&nbsp;' + row.unitName + '</li>';
        }
        console.log(html);
        list.append(html);
        $('.listEle').click(function(event) {
          this.style.textDecoration = this.style.textDecoration === 'line-through' ? 'none' : 'line-through';
          return this.style.color = this.style.textDecoration === 'line-through' ? '#D8D8D8' : '#53575E';
        });
      }
    }, errorHandler, errorHandler, nullHandler);
  });
};
