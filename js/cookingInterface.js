// Generated by CoffeeScript 1.7.1

/* Class Definitions */
var Step, addStepInfo, calculateRemainTime, checkFinishPercentageAndChangeTitle, checkNextStep, checkWaitingStepBlocking, cookingEnded, cookingStarted, finishedShowStatus, loadStep, startTimer, stopTimer, timer;

Step = (function() {
  function Step(obj) {
    this.finishTime = this.startTime + this.duration;
    this.timeElapsed = 0;
    this.percentage = "";
    return;
  }

  Step.prototype.calculateRemainTime = function() {
    return this.remainTime = this.duration - this.timeElapsed;
  };

  Step.prototype.calculatePercentage = function() {
    var remainTime;
    remainTime = this.calculateRemainTime();
    this.percentage = Math.floor(remainTime / this.duration * 100);
    return this.percentage + "%";
  };

  return Step;

})();


/* Function definitions */

cookingStarted = function() {

  /* Check if cooking data exist. It should exist when this is called but check anyways. */
  var currentStepNum;
  if (window.cookingData == null) {
    return;
  }
  currentStepNum = window.currentStepNum;
  window.currentTime = 0;
  window.waitingStepQueue = [];
  window.cookingStartTime = new Date();
  console.log("cooking started");
  $(".step_next_btn").html("Next");
  $(".waiting_step_outer_wrapper").addClass('invisible');
  checkFinishPercentageAndChangeTitle();
  $("#Step").attr("data-title", "Step " + (currentStepNum + 1) + " (" + finishPercentage + "%)");
  loadStep(currentStepNum);
  setTimeout(function() {
    return timer();
  }, 1000);
};

cookingEnded = function() {
  return stopTimer();
};


/* Timer: for clocking the cook process */

timer = function() {
  window.currentTime = window.currentTime + 1;
  window.waitingStepQueue.forEach(function(step) {
    step.timeElapsed += 1;
    return step.calculateRemainTime();
  });
  checkProgress();
  showTwoUrgentSteps();
  startTimer();
};

startTimer = function() {
  clearTimeout(window.lastId);
  window.lastId = setTimeout(function() {
    return timer();
  }, 1000);
};

stopTimer = function() {
  return clearTimeout(window.lastId);
};


/* Steps */

loadStep = function(stepNum) {
  var nextStep, scope, thisStep;
  console.log("load step#" + stepNum);
  thisStep = window.cookingData.steps[stepNum];
  window.currentStep = addStepInfo(thisStep);
  window.currentStepNum = stepNum;
  checkFinishPercentageAndChangeTitle();
  scope = $("#Step");
  scope.find(".this_step_recipe_name").html(thisStep.recipeName);
  scope.find(".this_step_digest").html(thisStep.digest);
  nextStep = window.cookingData.steps[stepNum + 1];
  if (nextStep != null) {
    scope.find(".next_step_name").html(nextStep.stepName);
    scope.find(".next_step_time").html(thisStep.time);
  } else {
    scope.find(".next_step_name").html("Final Step Reached");
    scope.find(".next_step_time").html("00:00");
    scope.find(".step_next_btn").html("Finish ");
  }
  scope.find(".step_next_btn").unbind('click');
  scope.find(".step_next_btn").click(function() {
    checkNextStep();
  });
};

checkNextStep = function() {
  var currentTime, nextStep, thisStep, thisStepFinishTime;
  currentTime = window.currentTime;
  thisStep = window.currentStep;
  thisStepFinishTime = thisStep.finishTime;
  if ((nextStep = window.cookingData.steps[thisStep.stepNum + 1]) == null) {

    /* There is no next step */
    console.log("finished");
    $.ui.loadContent("Finish");
    return;
  }

  /* Check if there is a step blocking in the waiting queue */
  if (checkWaitingStepBlocking(thisStep, nextStep)) {
    return;
  }

  /* No blocking step -> load next step */
  checkProgress();
  loadStep(thisStep.stepNum + 1);
};

checkWaitingStepBlocking = function(thisStep, nextStep) {
  var clonedQueue;
  clonedQueue = clone(window.waitingStepQueue);
  if (thisStep.finishTime < nextStep.startTime) {

    /* This step does not directly lead to next step -> there is a blocking step in waiting queue */
    window.waitingStepQueue.forEach(function(waitingStep) {
      var waitingStepIndex;
      if (waitingStep.finishTime === nextStep.startTime) {

        /* The blocking step is found */
        waitingStepIndex = clonedQueue.lastIndexOf(waitingStep);
        showBlockingStep(waitingStepIndex);
        return true;
      }
    });
  }

  /* Check the waiting steps for next step's previous steps */
  window.waitingStepQueue.forEach(function(waitingStep) {
    var waitingStepIndex;
    if (waitingStep.recipeId === nextStep.recipeId) {

      /* There is a step with the same recipeId as next step in the waiting queue. */
      waitingStepIndex = clonedQueue.lastIndexOf(waitingStep);
      showBlockingStep(waitingStepIndex);
      return true;
    }
  });
  return false;
};

checkFinishPercentageAndChangeTitle = function() {
  var finishPercentage, stepNum;
  stepNum = window.currentStepNum;
  finishPercentage = Math.ceil((stepNum + 1) / window.cookingData.steps.length * 100);
  $.ui.setTitle("Step " + (stepNum + 1) + " (" + finishPercentage + "%)");
};

addStepInfo = function(step) {
  step.duration = convertTimeToSeconds(step.time);
  step.finishTime = step.startTime + step.duration;
  step.timeElapsed = 0;
  step.percentage = "";
  step.remainTime = calculateRemainTime(step);
  return step;
};

calculateRemainTime = function(step) {
  return step.remainTime = step.duration - step.timeElapsed;
};

finishedShowStatus = function() {
  var scope, timeElapsed;
  timeElapsed = (new Date()) - window.cookingStartTime;
  timeElapsed = parseSecondsToTime(timeElapsed / 1000);
  scope = $("#Finish");
  scope.find("#TotalTimeSpent").html(timeElapsed);
  scope.find("#OriginalTime").html(window.cookingData.originTime);
};
