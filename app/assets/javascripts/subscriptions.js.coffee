# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

sendAJAXRequest = (settings) ->
  token = $('meta[name="csrf-token"]')
  if token.size() > 0
    headers =
      "X-CSRF-Token": token.attr("content")
    settings.headers = headers
  xhrRequestChangeMonth = jQuery.ajax(settings)
  true

showConfirmation = ->
  $('.delete-add-ons').on 'click', ->
    confirm('Are you sure you wish to cancel this add-on?')

onUpgradeDownGrade = ->
  $('.change-plan').on 'click', ->
    clearModal()
    plan_control = $(this)
    plan_change_to =  plan_control.val()
    has_credit_card = $("#has-credit-card").val()
    $("#change-plan-id").val(plan_control.attr('data-plan-id'))
    $(".modal").on "show.bs.modal", ->
      if has_credit_card is "false"
        $("#plan-descprition").html('You will need to add a credit card before changing your plan.')
        $("#change-plan-action").val("")
        $("#btn-change-plan").val($(".stripe-button-el span").text())
      else
        if plan_change_to is "Upgrade"
          $("#section-downgrade").hide()
          $("#change-plan-action").val("upgrade")
          $("#btn-change-plan").val("Upgrade my plan")
          $("#plan-descprition").html("The total #{plan_control.attr('data-period')} cost for you to upgrade " +
            "to the #{plan_control.attr('data-plan')} would be #{plan_control.attr('data-price')} per #{plan_control.attr('data-period')}")
        else
          $("#change-plan-action").val("downgrade")
          $("#btn-change-plan").val("Downgrade my plan")
          $("#plan-descprition").html("Downgrading to the #{plan_control.attr('data-plan')} plan will change your " +
            "#{plan_control.attr('data-period')} cost to #{plan_control.attr('data-price')}")
          $("#section-downgrade").show()
      centerModal(this)
    true

clearModal = ->
  $("#change-plan-id").val("")
  $("#change-plan-action").val("")
  $("#plan-descprition").show()
  $(".modal-footer").show()
  $("#confirm-upgrading").hide()
  $("#section-downgrade").hide()
  true

changePlan = ->
  $("#btn-change-plan").on 'click', ->
    if $("#has-credit-card").val() is "false"
      $(".stripe-button-el").click()
      $('.modal').modal('hide')
      return
    action = $("#change-plan-action").val()

    if action is "downgrade" && $("#downgrade-plan").val() is ''
      Notification.show "Please type 'downgrade' to confirm downgrade your plan."
      return
    if $("#change-plan-id").val() is ""
      Notification.show "Empty plan id."
      return
    if action is "upgrade"
      $("#plan-descprition").hide()
      $(".modal-footer").hide()
      $("#confirm-upgrading").show()

    data = {}
    data.plan_id = $("#change-plan-id").val()

    onError = (jqXHR, status, error) ->
      if action is "upgrade"
        $("#plan-descprition").show()
        $(".modal-footer").show()
        $("#confirm-upgrading").hide()
      false

    onSuccess = (result, status, jqXHR) ->
      if result.success
        Notification.show "Your account has been successfully #{action}d."
        window.location = 'plans'
      else
        Notification.show "Failed to #{action} plan."

    settings =
      cache: false
      data: data
      dataType: 'json'
      error: onError
      success: onSuccess
      contentType: "application/x-www-form-urlencoded"
      type: 'POST'
      url: "plans/change"

    sendAJAXRequest(settings)

centerModal = (model) ->
  $(model).css "display", "block"
  $dialog = $(model).find(".modal-dialog")
  offset = ($(window).height() - $dialog.height()) / 2
  $dialog.css "margin-top", offset

window.initializeSubscription = ->
  Notification.init(".bb-alert")
  showConfirmation()


window.initializeChangePlan = ->
  onUpgradeDownGrade()
  changePlan()