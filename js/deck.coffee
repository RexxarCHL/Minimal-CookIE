addThisRecipeToDeck = (id)->
	console.log "Add recipe ##{id} to deck"

	### Push if not already in deck ###
	if window.recipesInDeck.lastIndexOf(id) is -1
		window.recipesInDeck.push id # push this recipe into deck
		AddRecipeValue id # push this recipe into db

	return

deleteThisRecipeFromDeck = (id)->
	### TODO ###
	console.log "delete #{id} from deck"

	### delete from DB ###
	deleteRecipe(id)
	checkRecipeInDB()

	loadDeck()
	return

findRecipeIdsInDeck = ->
	recipeIds = []
	$('#main_Deck').find('.recipe_item').forEach (elem)->
		recipeIds.push elem.getAttribute 'data-recipe-id'
	console.log recipeSelectedId
	return recipeIds

checkRecipeInDeck = (id)->
	#console.log "index for  #{id} is #{window.recipesInDeck.lastIndexOf(id)}"
	if window.recipesInDeck.lastIndexOf(id) is -1 then false else true

checkRecipeInDB = ->
	if not window.openDatabase
        alert 'Databases are not supported in this browser.'
        return

	sql = 'SELECT `recipeId` FROM `Recipes`'

	window.recipesInDeck = []
	db.transaction (transaction)->
		transaction.executeSql sql, [], (transaction, result)->
			if result? and result.rows?
				### There is recipe in deck ###
				console.log "OK"
				for x,i in result.rows
					row = result.rows.item(i)
					window.recipesExist = 1
					console.log row.recipeId
					window.recipesInDeck.push row.recipeId
				return
			console.log "NOT OK"
			window.recipesExist = 0

		, errorHandler
		return
	, errorHandler, nullHandler
	return