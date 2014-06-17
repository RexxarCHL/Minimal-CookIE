getIngredientList = (recipeIds)->
	console.log "get ingredient list"
	data = ''
	#recipeIds = JSON.parse(recipeIds)
	for id in recipeIds
		data += 'recipes='+id+'&'
	$.ajax(
			type: 'GET'
			url: 'http://54.178.135.71:8080/CookIEServer/list_ingredient?'+data
			timeout: 10000
			success: (data)->
				data = JSON.parse(data)
				console.log '[SUCCESS] fetching #'+recipeIds
				console.log data

				storeIngredientListToDB(data)
				showIngredientList()

				return # avoid implicit rv
			error: (data, status)->
				console.log '[ERROR] fetching #'+recipeIds
				console.log data

				return # avoid implicit rv
	)
	return # avoid implicit rv

storeIngredientListToDB = (data)->
	console.log "store ingredient list to db"

	db.transaction (transaction)->
		transaction.executeSql 'DELETE FROM `MenuIngredients`', [],
			successCallBack,
			errorHandler
		, errorHandler, nullHandler
		return

	for ingredient in data
		AddValueToIngredient ingredient.ingredientId,
			ingredient.recipeId,
			ingredient.ingredientName,
			ingredient.amount,
			ingredient.unitName
	return

showIngredientList = ->
	if not window.openDatabase
		alert 'Databases not supported by this browser'
		return

	console.log "show ingredient list"

	db.transaction (transaction)->
		transaction.executeSql 'SELECT * FROM MenuIngredients', [],
			(transaction,result)->
				if result? and result.rows?
					list = $("#list")
					list.html ""
					html = ''
					for x, i in result.rows
						row = result.rows.item(i)
						html += '<li class="listEle">'+row.name+'&nbsp;'+row.amount+'&nbsp;'+row.unitName+'</li>'
					console.log html
					list.append html
				return
			, errorHandler
		, errorHandler, nullHandler
		return