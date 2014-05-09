# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/
showError = (message) ->
  Notification.show(message)
  true

showFeedback = (message) ->
  Notification.show(message)
  true


initialize = ->
  Notification.init(".bb-alert")
  true

if !window.Evercam
  window.Evercam = {}

window.Evercam.Users =
  initialize: initialize
