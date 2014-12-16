//= require sharing
//= require recording
//= require live
//= require info
//= require settings
//= require explorer
//= require logs
//= require webhooks

$(document).ready(function() {
    Metronic.init(); // init metronic core components
    Layout.init(); // init current layout
    QuickSidebar.init(); // init quick sidebar
    handleScrollToEvents();
});

function handleScrollToEvents() {
    // Javascript to enable link to tab
    var url = document.location.toString();
    if (url.match('#')) {
        $('.nav-tabs a[href=#' + url.split('#')[1] + ']').tab('show');
        setTimeout(function () {
            scrollTo(0, 0)
        }, 10);
    }
    this.$('.nav-tabs').tabdrop('layout');

    // Change hash for page-reload
    $('.nav-tabs a').on('shown.bs.tab', function (e) {
        window.location.hash = e.target.hash;
        scrollTo(0, 0);
    })
}