# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

showConfirmation = ->
  $('.delete-add-ons').on 'click', ->
    confirm('Are you sure you wish to cancel this add-on?')

window.initializeSubscription = ->
  Notification.init(".bb-alert")
  showConfirmation()