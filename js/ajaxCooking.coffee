###
ajaxCooking.coffee
	ajax the scheduled plan of cook and show the data

	getScheduledRecipe(recipeIds)
		get the scheduled plan for 'recipeIds'
	appendData(scope, data)
		show the information of the scheduled plan
###

# get the scheduled plan
getScheduledRecipe = (recipeIds)->
	# check if there is a cooking in progress
	if window.cookingData?
		# if there is a cooking in progress, ask if the user really want to overwrite the result
		ans = confirm "You have a cooking in progress. Resume?"

		# if the user wants to resume the cooking
		if ans is yes
			# show cooking interface
			$.ui.loadContent "Step"
			return
		# else overwrite the current cooking progress
			
	console.log "schedule_recipe #"+recipeIds

	# empty the panel
	$.ui.updatePanel "Cooking",""

	# let the user know that we're loading and block the ui
	$.ui.showMask "Loading data from server..."
	$.ui.blockUI(.1)

	# construct the query string
	data = ''
	for id in recipeIds
		data += 'recipes='+id+'&'

	# do the ajax
	$.ajax(
			type: 'GET'
			url: 'http://54.178.135.71:8080/CookIEServer/schedule_recipe?'+data
			#timeout: 10000
			success: (data)->
				# SUCCESS
				# parse the data
				data = JSON.parse(data)
				console.log '[SUCCESS] fetching #'+recipeIds
				console.log data

				# get to ROI
				scope = $('#Cooking')

				# store the new data received for future references
				window.cookingData = data
				window.currentStepNum = 0

				# show the information
				appendData scope, data

				return # avoid implicit rv
			error: (resp)->
				# ERROR
				# log the result for DEBUG
				console.log '[ERROR] fetching #'+recipeIds
				console.log resp

				# unblock the UI and hide the spinning wheel
				$.ui.unblockUI()
				$.ui.hideMask()

				# determine the error message
				# if the status is 404 then the calculation is too long and the server killed the process
				if resp.status is 404 then alert "Server aborted the scheduling process. Please try again with fewer recipes."
				# if the status is 0 then the server rejected the request
				else if resp.status is 0 then alert "Server Error. Try again later."
				# else this is an unknown error
				else alert "Connection error: #{resp.status}"

				# return to Deck
				$.ui.loadContent "main_Deck"
				return # avoid implicit rv
	)
	return # avoid implicit rv

# show the information about this plan
appendData = (scope, data)->
	console.log "append scheduled plan"

	$.ui.updatePanel "Cooking",""+
		'<div style="background-color:#F2F2F2">'+
			'<h2 style="margin-left:5%;margin-top:5%">本次共有 <span id="totalRecipes">'+data.recipeLength.length+'</span> 道食譜排程</h2>'+
			'<h2 style="margin-left:5%;">原本需要時間：</h2>'+
			'<i id="originalCookingTime" style="margin-left:7%;font-size:17px;">'+data.originTime+'</i>'+
			'<h2 style="margin-left:5%;">排程優化時間：</h2>'+
			'<i id="scheduledCookingTime" style="margin-left:7%;font-size:17px;">'+data.scheduledTime+'</i>'+
			'<br />'+
			'<div class="bottom_btn_holder" style="margin-top:80%;">'+
				'<a class="button" style="width:100%;background: hsl(204.1,35%,53.1%);height:10%;color:white;text-shadow: -1px -1px gray;border-radius: 8px;" href="#Step">開始！</a>'+
			'</div>'+
		'</div>'

	# unblock the ui and hide the spinning wheel
	$.ui.unblockUI()
	$.ui.hideMask();
	return
