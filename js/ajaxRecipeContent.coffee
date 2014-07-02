###
ajaxRecipeContent.coffee
	Functions to fetch detailed information for a particular recipe.

	getRecipeContent(recipeId)
		Get the detailed information for recipe whose id is 'recipeId' and forward it to loadRecipeContent
	loadRecipeContent(scope, recipe)
		show the data received in 'scope'
###

# fetch information of recipe whose id is 'recipeId' from the server
getRecipeContent = (recipeId)->
	$.ajax(
		type: 'GET'
		url: 'http://54.178.135.71:8080/CookIEServer/recipedigest'
		dataType: 'application/json'
		data:
			'recipe_id': recipeId
		timeout: 10000
		success: (data)->
			# SUCCESS
			# parse and log the data received
			data = JSON.parse(data)
			console.log "[SUCCESS]fetch recipe #"+recipeId
			console.log data

			# get ot ROI and show the detailed information of the recipe
			scope = $("#RecipeContent")
			setTimeout(loadRecipeContent(scope, data), 1000)
			return #avoid implicit rv
		
		error: (resp)->
			# ERROR
			# log the response for DEBUG
			console.log "[ERROR]fetch recipe #"+recipeId
			console.log resp

			# determine the error message
			if resp.status is 0
				# if the status code is 0, then the server rejected the request
				alert "Server Error. Try again later."
			else
				# else this is an unknown error
				alert "Connection Error: #{resp.status}"

			# return to #main_Browse_Recipe
			$.ui.loadContent "main_Browse_Recipe"
			return #avoid implicit rv
	)
	return #avoid implicit rv

# show the detailed information of the 'recipe' in 'scope'
loadRecipeContent = (scope, recipe)->
	# change the title
	$.ui.setTitle recipe.recipeName

	# hide the results box and show the loading wheel while we're loading the content
	scope.find("#Results").hide()
	scope.find("#Loading").show()

	
	# load Info
	# load the image
	scope.find("#RecipeImg").attr("src", recipe.image)
	# secretly hide recipe id in img tag
	scope.find("#RecipeImg").attr("data-recipe-id", recipe.recipeId)
	# load the description
	scope.find("#RecipeDescription").text recipe.description
	# load who contributed to this recipe
	scope.find("#RecipeUploadInfo").text "Uploaded by: "+recipe.authorName+", "+(new Date(recipe.date))
	# load the share of the recipe
	if recipe.share is 0 then scope.find("#RecipeShare").html ""
	else scope.find("#RecipeShare").html "（#{recipe.share} 人份）"

	
	# load Ingredients
	# split the ingredient list in half
	len = recipe.ingredientGroup[0].length
	len = Math.ceil len/2

	# get the ingredient lists on the left and right and empty the previous results
	ingListLeft = scope.find("#RecipeIngredientListLeft")[0]
	ingListLeft.firstElementChild.innerHTML = ""
	ingListLeft.lastElementChild.innerHTML = ""
	ingListRight = scope.find("#RecipeIngredientListRight")[0]
	ingListRight.firstElementChild.innerHTML = ""
	ingListRight.lastElementChild.innerHTML = ""

	# for every ingredient group
	for group, i in recipe.ingredientGroup
		# construct the html of the group
		html = ''
		# for every ingredient in this group
		for ingredient, j in group.ingredients
			console.log ingredient.ingredientName
			if (i+j)%2 # odd
				# append ing. name
				html = "<li>#{ingredient.ingredientName}</li>"
				$(ingListRight.firstElementChild).append html
				# append ing. amount
				html = "<li>#{ingredient.amount}#{ingredient.unitName}</li>"
				$(ingListRight.lastElementChild).append html
			else # even
				# append ing. name
				html = "<li>#{ingredient.ingredientName}</li>"
				$(ingListLeft.firstElementChild).append html
				# append ing. amount
				html = "<li>#{ingredient.amount}#{ingredient.unitName}</li>"
				$(ingListLeft.lastElementChild).append html
	

	# load Steps
	stepList = scope.find("#RecipeSteps")
	stepList.html "" #remove previous content
	for step, i in recipe.stepDigests
		html = '<li>'+(i+1)+'. '+step.step+'</li>'
		stepList.append html
	stepList.append '<br />'

	# load Photos
	imgList = scope.find("#RecipePhotos")
		# do something

	# append button according to whether the recipe exist in deck or not
	id = recipe.recipeId
	if window.recipesInDeck.lastIndexOf(id) isnt -1
		### recipe already in the deck ###
		scope.find("#RecipeContentBtn")[0].outerHTML = '<div id="RecipeContentBtn" class="button" style="width:100%;background-color:#D8D8D8;opacity:.8;height:8%;border-radius:0;border:0;">已加入調理台</div>'
		thisRecipeBtn = scope.find "#RecipeContentBtn"
		thisRecipeBtn.click ->
			# jump to Deck
			$.ui.loadContent 'main_Deck'
			undefined
	else
		scope.find("#RecipeContentBtn")[0].outerHTML = '<div id="RecipeContentBtn" class="button" style="width:100%;background:hsl(204.1,35%,53.1%);opacity:.8;height:8%;border-radius:0;border:0;">加到調理台</div>'
		thisRecipeBtn = scope.find "#RecipeContentBtn"
		thisRecipeBtn.click do(id)->
			-> # closure
				addThisRecipeToDeck(id)
				
				if window.recipesInDeck.length >= 6 then return
				thisRecipeBtn[0].outerHTML = '<div id="RecipeContentBtn" class="button" style="width:100%;background-color:#D8D8D8;height:8%;border-radius:0;border:0;">已加入調理台</div>'
				$("#main_Browse_Recipe").find("#Recipe#{id}").find(".recipe_btn")[0].outerHTML = '<div class="button recipe_btn recipe_in_deck_btn" >已加入調理台</div>'
				undefined

	# hide the spinning wheel and show the loaded content
	scope.find("#Loading").hide()
	scope.find("#Results").show()

	return #avoid implicit rv
	