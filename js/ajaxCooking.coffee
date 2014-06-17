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
		html += '<h3 style="padding-top:3%;padding-left:5%;">'+(_i + 1)+'. '+step.digest+'</h3>'
		###debug###
		###
		html += "    time: #{step.time}, people: #{step.people}, start time: #{step.startTime}"
		###
		html += '</div>'
		stepsList.append html

	$.ui.hideMask();
	return
