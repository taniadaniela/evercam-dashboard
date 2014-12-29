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
    onComplete: (swaggerApi, swaggerUi) ->
      window.authorizations.add "api_id", new ApiKeyAuthorization("api_id", "#{Evercam.User.api_id}", "query")
      window.authorizations.add "api_key", new ApiKeyAuthorization("api_key", "#{Evercam.User.api_key}", "query")
      $("pre code").each (i, e) ->
        hljs.highlightBlock e

      $("#resources h2").each ->
        $(this).next("ul").find("li:last").remove()

      $("a:contains('/cameras/{id}/snapshot.jpg.json')").text "/cameras/{id}/snapshot.jpg"
      $("input[name='id'].required.parameter").val Evercam.Camera.id

    onFailure: (data) ->

    docExpansion: "list"

  window.swaggerUi.load()

window.initializeExplorerTab = ->
  initializeSwagger()
