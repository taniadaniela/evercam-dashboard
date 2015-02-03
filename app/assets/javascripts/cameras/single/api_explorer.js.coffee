initializeSwagger = ->
  window.swaggerUi = new SwaggerUi
    url: "#{Evercam.API_URL}swagger/cameras.json"
    dom_id: "swagger-ui-container"
    supportedSubmitMethods: [
      "get"
      "post"
      "put"
      "delete"
    ]
    docExpansion: "list"
    sorter: "alpha"

    onComplete: (swaggerApi, swaggerUi) ->
      window.authorizations.add "api_id", new ApiKeyAuthorization("api_id", "#{Evercam.User.api_id}", "query")
      window.authorizations.add "api_key", new ApiKeyAuthorization("api_key", "#{Evercam.User.api_key}", "query")
      $("pre code").each (i, e) ->
        hljs.highlightBlock e

      $("#resources h2").each ->
        $(this).next("ul").find("li:last").remove()

      $("a:contains('/cameras/{id}/live/snapshot.json')").text "/cameras/{id}/live/snapshot"
      $("input[name='id'].required.parameter").val Evercam.Camera.id

  window.swaggerUi.load()

initializePortRemover = ->
  $(document).on 'DOMSubtreeModified', '.response .request_url', ->
    $('pre:contains(":443/v1/")').each ->
      $(this).text $(this).text().replace(':443', '')

window.initializeExplorerTab = ->
  initializeSwagger()
  initializePortRemover()
