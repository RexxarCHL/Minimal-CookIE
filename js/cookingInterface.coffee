### Steps information ###
class Step
	### For logging the time used in every step ###
	constructor: (@stepNum, @recipeId, @stepId, @timeDiff)->

extendStepInfo = (step)->
	### For to be used in related functions ###
	step.duration = convertTimeToSeconds step.time
	step.finishTime = step.startTime + step.duration
	step.timeElapsed = 0
	step.percentage = 0
	step.remainTime = calculateRemainTime(step)

	step

calculateRemainTime = (step)->
	step.remainTime = step.duration - step.timeElapsed

calculatePercentage = (step)->
	remainTime = calculateRemainTime(step)
	step.percentage = Math.floor(remainTime / step.duration * 100)

	step.percentage + "%"

### Function definitions ###
cookingStarted = ->
	# on-panel-load function for #Step aka cooking interface
	### Check if cooking data exist. It should exist when this is called but check anyways. ###
	if not window.cookingData? then return

	currentStepNum = window.currentStepNum
	window.currentTime = 0
	window.waitingStepQueue = []
	window.stepsTimeUsed = []
	window.cookingStartTime = new Date()

	console.log "cooking started"

	# reset the interface
	$(".waiting_step_outer_wrapper").addClass 'invisible'
	finishPercentage = Math.ceil (currentStepNum+1) / window.cookingData.steps.length * 100
	$("#Step").attr "data-title", "Step #{currentStepNum+1} (#{finishPercentage}%)"

	# load this/next step data
	loadStep(currentStepNum)

	setTimeout ->
		timer()
	, 1000

	return # avoid implicit rv

cookingEnded = ->
	# on-panel-unload function for #Step aka cooking interface
	stopTimer()

### Timer: for clocking the cook process ###
timer = ->
	# clock tick
	window.currentStep.timeElapsed += 1
	window.waitingStepQueue.forEach (step)->
		step.timeElapsed += 1
		calculateRemainTime(step)
	
	### Check waiting queue status ###
	checkWaitingStepsFinish()

	### Update progress bars ###
	updateNextStepProgressBar()
	showTwoUrgentSteps()

	#start another timer
	startTimer()

	return # avoid implicit rv

startTimer = ->
	# clear the any previous timer
	clearTimeout window.lastId

	# reserve next clock tick
	window.lastId = setTimeout ->
			timer()
		, 1000
	return

stopTimer = ->
	# clear previous timer
	clearTimeout window.lastId

### Steps ###
loadStep = (stepNum)->
	console.log "load step##{stepNum}"
	thisStep = window.cookingData.steps[stepNum]
	window.currentTime = thisStep.startTime
	window.currentStep = extendStepInfo thisStep
	window.currentStepNum = stepNum

	# animation and change the title
	animationMoveThisStepFromLeftToRight()
	checkFinishPercentageAndChangeTitle()

	scope = $("#Step")
	# load this step
	scope.find(".this_step_recipe_name").html thisStep.recipeName
	scope.find(".this_step_digest").html thisStep.digest

	# load next step info
	nextStep = window.cookingData.steps[stepNum+1]
	if nextStep?
		scope.find(".next_step_name").html trimStringLength(nextStep.stepName)
		scope.find(".next_step_time").html "#{thisStep.timeElapsed}/#{thisStep.time}"
		scope.find(".step_next_btn").html "下一步"
	else
		scope.find(".next_step_name").html "最後一步"
		scope.find(".next_step_time").html ""
		scope.find(".step_next_btn").html "完成"

	# bind next step btn behaviour
	nextBtn = scope.find(".step_next_btn")
	nextBtn.unbind 'click'
	nextBtn.click ->
		checkNextStep()
		return # avoid implicit rv

	return # avoid implicit rv

loadBlockingStep = (index)->
	console.log "load blocking step, index:#{index}"
	console.log window.waitingStepQueue
	# dequeue
	step = window.waitingStepQueue.splice(index, 1)[0]
	showTwoUrgentSteps() # update remaining waiting steps
	window.currentStep = step

	animationMoveThisStepFromRightToLeft()

	scope = $("#Step")
	# load the step
	scope.find(".this_step_recipe_name").html step.recipeName
	scope.find(".this_step_digest").html "#{step.digest}"

	# bind next step btn behaviour
	nextBtn = scope.find(".step_next_btn")
	nextBtn.html "等待完成"
	nextBtn.unbind 'click'
	nextBtn.click ->
		console.log "?"
		checkNextStep(true)
		return # avoid implicit rv

	return # avoid implicit rv

checkNextStep = (blocked = 0)->
	thisStep = window.currentStep
	thisStepFinishTime = thisStep.finishTime
	
	if not (nextStep = window.cookingData.steps[window.currentStepNum+1])?
		### There is no next step ###
		console.log "finished"
		$.ui.loadContent "Finish"
		return

	### Check if there is a step blocking in the waiting queue ###
	if checkWaitingStepBlocking(thisStep, nextStep) then return

	### No blocking step -> load next step ###
	# log the time difference of expected time and actual time spend in this step
	timeDiff = nextStep.startTime - (thisStep.startTime + thisStep.timeElapsed)
	if thisStep.people or blocked
		# this step needs people or this step is a blocking step(need no people)
		stepNum = if not blocked then window.currentStepNum else window.cookingData.steps.lastIndexOf(thisStep) 
		window.stepsTimeUsed.push new Step(stepNum, thisStep.recipeId, thisStep.stepId, timeDiff)
	else
		# this step needs no people, push to waiting queue
		pushStepToWaitingQueue thisStep
	
	loadStep(window.currentStepNum+1)
	return # avoid implicit rv

pushStepToWaitingQueue = (step, currentTime)->
	console.log "push #{window.currentStepNum}: #{step.digest} into queue"
	window.waitingStepQueue.push step
	window.waitingStepQueue.sort (a,b)->
		b.remainTime - a.remainTime

	console.log window.waitingStepQueue
	showTwoUrgentSteps()

	return # avoid implicit rv

### Checks ###
# Check if there is a step blocking in the waiting queue
checkWaitingStepBlocking = (thisStep, nextStep)->
	flag = false
	waitingQueue = window.waitingStepQueue
	if thisStep.finishTime < nextStep.startTime
		### This step does not directly lead to next step -> there is a blocking step in waiting queue ###
		waitingQueue.forEach (waitingStep)->
			if waitingStep.finishTime is nextStep.startTime
				### The blocking step is found ###
				waitingStepIndex = waitingQueue.lastIndexOf waitingStep
				loadBlockingStep waitingStepIndex
				flag = true
				return

	### Check the waiting steps for next step's previous steps ###
	waitingQueue.forEach (waitingStep)->
		if waitingStep.recipeId is nextStep.recipeId
			### There is a step with the same recipeId as next step in the waiting queue. ###
			# retrieve the index of the blocking step in the waiting queue
			waitingStepIndex = waitingQueue.lastIndexOf(waitingStep)
			loadBlockingStep waitingStepIndex
			flag = true
			return

	return flag

checkWaitingStepsFinish = ->
	queue = window.waitingStepQueue
	queueLen = queue.length

	queue.forEach (waitingStep)->
		if waitingStep.remainTime <= 0
			### Finished ###
			index = queue.lastIndexOf waitingStep
			# pop the step out of the queue
			step = queue.splice(index, 1)[0]
			showTwoUrgentSteps()
			# alert the user
			alert "Step finished: #{step.digest}"
			return
	return

checkFinishPercentageAndChangeTitle = ->
	stepNum = window.currentStepNum
	finishPercentage = Math.ceil (stepNum+1) / window.cookingData.steps.length * 100
	$.ui.setTitle "Step #{stepNum+1} (#{finishPercentage}%)"

	return

### Update functions ###
showTwoUrgentSteps = ->
	#console.log "show two urgent steps"
	waitingQueue = window.waitingStepQueue
	queueLen = waitingQueue.length
	nextStep = waitingQueue[queueLen-1]
	nextNextStep = waitingQueue[queueLen-2]
	if queueLen is 1
		updateWaitingProgressBar $("#NextNextWaitingStep"), nextStep
		updateWaitingProgressBar $("#NextWaitingStep"), nextNextStep #should be undefined
	else
		updateWaitingProgressBar $("#NextNextWaitingStep"), nextNextStep
		updateWaitingProgressBar $("#NextWaitingStep"), nextStep

	###
	if nextStep? and nextNextStep?
		console.log "enough steps. steps:#{nextStep.stepNum}, #{nextNextStep.stepNum}"
	else if nextStep?
		console.log "not enough steps. step:#{nextStep.stepNum}"
	else
		console.log "no step waiting"
	###

	return # avoid implicit rv

updateNextStepProgressBar = ->
	# show current time elapse on next step progress bar
	thisStep = window.currentStep
	timeElapsed = parseSecondsToTime thisStep.timeElapsed
	nextStep = $("#NextStep")
	nextStep.find("#ProgressRemainTime").html "#{timeElapsed}/#{thisStep.time}"

	return # avoid implicit rv

updateWaitingProgressBar = (scope, step)->
	progressBar = scope.find "#ProgressBar"
	progressName = scope.find "#ProgressName"
	progressRemainTime = scope.find "#ProgressRemainTime"

	if not step?
		### step = null: hide empty progress bar ###
		$(scope[0].parentNode).addClass 'invisible'
	else
		progressBar.css3Animate
			width: "#{calculatePercentage(step)}%"
			time: '500ms'
		progressName.html trimStringLength(step.stepName)
		progressRemainTime.html parseSecondsToTime step.remainTime
		$(scope[0].parentNode).removeClass 'invisible'

	return

finishedShowStatus = -> 
	timeElapsed = (new Date()) - window.cookingStartTime # in milliseconds
	timeElapsed = parseSecondsToTime Math.floor(timeElapsed/1000)
	
	scope = $("#Finish")
	scope.find("#TotalTimeSpent").html timeElapsed
	scope.find("#OriginalTime").html window.cookingData.originTime

	return

### Animation functions ###
animationMoveThisStepFromLeftToRight = ->
	thisStep = window.currentStep
	$('.this_step_inner_wrapper').addClass 'animate_old'
	$('.this_step_outer_wrapper').append $('<div class="this_step_inner_wrapper animate_new">')
	$('.this_step_inner_wrapper.animate_new').append $('<div class="this_step_recipe_name">').html(thisStep.recipeName)
	$('.this_step_inner_wrapper.animate_new').append $('<h3 class="this_step_digest">').html(thisStep.digest)

	$('.this_step_inner_wrapper.animate_old').css3Animate
		x: 500
		time: 300
		success: ()->
			$('.this_step_inner_wrapper.animate_old').remove()
			return

	$('.this_step_inner_wrapper.animate_new').css3Animate
		x: -500
		time: 10
		success: ()->
			$('.this_step_inner_wrapper.animate_new').css3Animate
				x: 500
				time: 300
				previous: true
				success: ()->
					$('.animate_new').removeClass 'animate_new'
					return
			return

	return

animationMoveThisStepFromRightToLeft = ->
	thisStep = window.currentStep
	$('.this_step_inner_wrapper').addClass 'animate_old'
	$('.this_step_outer_wrapper').append $('<div class="this_step_inner_wrapper animate_new">')
	$('.this_step_inner_wrapper.animate_new').append $('<div class="this_step_recipe_name">').html(thisStep.recipeName)
	$('.this_step_inner_wrapper.animate_new').append $('<h3 class="this_step_digest">').html(thisStep.digest)

	$('.this_step_inner_wrapper.animate_old').css3Animate
		x: -500
		time: 300
		success: ()->
			$('.this_step_inner_wrapper.animate_old').remove()
			return

	$('.this_step_inner_wrapper.animate_new').css3Animate
		x: 500
		time: 10
		success: ()->
			$('.this_step_inner_wrapper.animate_new').css3Animate
				x: -500
				time: 300
				previous: true
				success: ()->
					$('.animate_new').removeClass 'animate_new'
					return
			return

	return


