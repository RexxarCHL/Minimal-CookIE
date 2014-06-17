$(document).ready ->
	$("#ToBuyBtn").click ->
		recipeIds = findRecipeIdsInDeck()
		getIngredientList(recipeIds)
		return
	$("#CookBtn").click ->
		recipeIds = findRecipeIdsInDeck()
		getScheduledRecipe(recipeIds)
		return
	return

addThisRecipeToDeck = (id)->
	console.log "Add recipe ##{id} to deck"

	### Push if not already in deck ###
	if window.recipesInDeck.lastIndexOf(id) is -1
		AddRecipeValue id # push this recipe into db
		checkRecipeInDB()

	return

deleteThisRecipeFromDeck = (id)->
	### TODO ###
	console.log "delete #{id} from deck"

	### If not in deck, which is not possible but check anyway ###
	if (index = window.recipesInDeck.lastIndexOf(id)) is -1 then return
	window.recipesInDeck.splice index, 1
	console.log "deck: #{window.recipesInDeck}"

	### delete from DB ###
	deleteRecipe(id)
	checkRecipeInDB()

	thisRecipeBtn = $("#Recipe#{id}")
	thisRecipeBtn.find(".recipe_btn")[0].outerHTML = '<div class="button recipe_btn recipe_add_btn" style="width:100%;align:center;margin-top:1px;margin-bottom:1px;border-radius:0;">Add To Deck</div>'
	thisRecipeBtn = thisRecipeBtn.find(".recipe_btn")
	thisRecipeBtn.unbind 'click'
	thisRecipeBtn.click do(id)->
		-> #closure
			addThisRecipeToDeck(id)
			$("#main_Browse_Recipe").find("#Recipe#{id}").find(".recipe_btn")[0].outerHTML = '<div class="button recipe_btn recipe_in_deck_btn" style="width:100%;align:center;margin-top:1px;margin-bottom:1px;border-radius:0;">Already in Deck</div>'
			return

	return

findRecipeIdsInDeck = ->
	recipeIds = []
	$('#main_Deck').find('.recipe_item').forEach (elem)->
		recipeIds.push elem.getAttribute 'data-recipe-id'
	console.log recipeIds
	return recipeIds

checkRecipeInDeck = (id)->
	#console.log "index for  #{id} is #{window.recipesInDeck.lastIndexOf(id)}"
	if window.recipesInDeck.lastIndexOf(id) is -1 then false else true

checkRecipeInDB = ->
	if not window.openDatabase
        alert 'Databases are not supported in this browser.'
        return

	sql = 'SELECT `recipeId` FROM `Recipes`'

	db.transaction (transaction)->
		transaction.executeSql sql, [], (transaction, result)->
			if result? and result.rows?
				### There is recipe in deck ###
				console.log "OK"
				window.recipesInDeck = []
				for x,i in result.rows
					row = result.rows.item(i)
					window.recipesExist = 1
					# console.log row.recipeId
					window.recipesInDeck.push row.recipeId
				return
			console.log "NOT OK"
			window.recipesExist = 0

		, errorHandler
		return
	, errorHandler, nullHandler
	return