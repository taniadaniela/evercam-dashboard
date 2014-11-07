#= require metronic/jquery-1.11.0.min.js
#= require metronic/jquery-migrate-1.2.1.min.js
#= require metronic/jquery-ui-1.10.3.custom.min.js
#= require metronic/bootstrap.min.js
#= require metronic/bootstrap-hover-dropdown.min.js
#= require metronic/jquery.slimscroll.min.js
#= require metronic/jquery.blockui.min.js
#= require metronic/jquery.cokie.min.js
#= require metronic/jquery.uniform.min.js
#= require metronic/jquery.flot.js
#= require metronic/jquery.flot.categories.min.js
#= require metronic/jquery.flot.pie.min.js
#= require metronic/bootstrap-switch.min.js
#= require metronic/select2.min.js
#= require metronic/jquery.dataTables.min.js
#= require metronic/dataTables.bootstrap.js
#= require metronic/bootstrap-datepicker.js
#= require metronic/metronic.js
#= require metronic/datatable.js
#= require metronic/layout.js
#= require metronic/quick-sidebar.js
#= require alerts.js

$ ->
  Metronic.init()
  Layout.init()
  QuickSidebar.init()
  $(".table-datatable").dataTable
    aaSorting: [1, "asc"]
    aLengthMenu: [
      [25, 50, 100, 200, -1]
      [25, 50, 100, 200, "All"]
    ]
    iDisplayLength: 50
    columnDefs: [
      type: "date-uk"
      targets: 'datatable-date'
    ]


$.extend $.fn.dataTableExt.oSort,
  "date-uk-pre": (a) ->
    ukDatea = a.split("/")
    (ukDatea[2] + ukDatea[1] + ukDatea[0]) * 1

  "date-uk-asc": (a, b) ->
    (if (a < b) then -1 else ((if (a > b) then 1 else 0)))

  "date-uk-desc": (a, b) ->
    (if (a < b) then 1 else ((if (a > b) then -1 else 0)))
