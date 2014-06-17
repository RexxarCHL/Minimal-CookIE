getCookingIngredientList = (recipeIds)->
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

				scope = $('#Ingredients')
				loadIngredientList(scope, data, recipeIds)

				return # avoid implicit rv
			error: (data, status)->
				console.log '[ERROR] fetching #'+recipeIds
				console.log data

				return # avoid implicit rv
	)
	return # avoid implicit rv

loadIngredientList = (scope, list, recipeIds)->
	listContent = scope.find('#ListContent')
	listContent.html ""

	for ingredient in list
		html = "<input type='checkbox' id='#{ingredient.ingredientId}' /><label for='#{ingredient.ingredientId}'>"
		html += "<b>#{ingredient.amount}#{ingredient.unitName}</b> #{ingredient.ingredientName}</label>"
		listContent.append html

	scope.find("#Next").unbind 'click'
	scope.find("#Next").click( do(list)->
		-> #closure
			getScheduledRecipe(recipeIds)
	)

	scope.find("#Loading").hide()
	scope.find("#Results").show()

	return

getScheduledRecipe = (recipeIds)->
	console.log "schedule_recipe #"+recipeIds
	$.ui.showMask "Loading data from server..."

	data = ''
	#recipeIds = JSON.parse(recipeIds)
	for id in recipeIds
		data += 'recipes='+id+'&'
	$.ajax(
			type: 'GET'
			url: 'http://54.178.135.71:8080/CookIEServer/schedule_recipe?'+data
			#timeout: 10000
			success: (data)->
				data = JSON.parse(data)
				console.log '[SUCCESS] fetching #'+recipeIds
				console.log data

				scope = $('#Cooking')
				window.cookingData = data
				window.currentStepNum = 0
				appendSteps scope, data

				return # avoid implicit rv
			error: (data, status)->
				console.log '[ERROR] fetching #'+recipeIds
				console.log data
				$.ui.hideMask()
				alert "ERROR"
				$.ui.loadContent "main_Deck"
				return # avoid implicit rv
	)
	return

appendSteps = (scope, data)->
	console.log "append steps"
	$.ui.showMask "Processing Data"

	# append time
	scope.find("#totalCookingTime").html "<b>"+parseTimeToMinutes(data.originTime)+" mins -> "+parseTimeToMinutes(data.scheduledTime)+" min</b>"

	# append step list
	stepsList = scope.find "#stepsList"
	stepsList.html '<h2 style="margin-left:5%;">Steps:</h2>'
	html = ""
	for step in data.steps
		html = '<div class="overview_stepWrapper">'
		if steps.imageURL?
			html += '<img src="'+steps.imageURL+'" class="overview_stepImg"></img>'
		html += '<h3 class="overview_stepText">'+(_i + 1)+'. '+step.digest+'</h3>'
		###debug###
		html += "    time: #{step.time}, people: #{step.people}, start time: #{step.startTime}"
		html += '</div>'
		stepsList.append html

	$.ui.hideMask();
	return
