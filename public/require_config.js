
define([], function() {
  return require.config({
    packages: ['core', 'game/levels/_base', 'game/levels/reaction_time_disc', 'game/levels/rank_images', 'game/levels/circle_size', 'game/levels/circle_proximity', 'game/levels/alex_trebek', 'game/levels/emotions_circles', 'game/levels/snoozer', 'game/levels/interest_picker', 'dashboard/widgets/base', 'dashboard/widgets/lister', 'ui_widgets/formation'],
    paths: {
      jquery: '//ajax.googleapis.com/ajax/libs/jquery/1.10.1/jquery.min',
      bootstrap: '//netdna.bootstrapcdn.com/twitter-bootstrap/2.3.2/js/bootstrap.min',
      Handlebars: "bower_components/require-handlebars-plugin/Handlebars",
      underscore: "bower_components/underscore-amd/underscore",
      jqueryui: "bower_components/jquery-ui/jqueryui",
      jquiTouchPunch: 'bower_components/jquery-ui-touch-punch/jquery.ui.touch-punch.min',
      backbone: "bower_components/backbone-amd/backbone",
      syphon: 'bower_components/tidepool-backbone.syphon/lib/amd/backbone.syphon',
      text: "bower_components/requirejs-text/text",
      toastr: "bower_components/toastr",
      chart: "bower_components/Chart.js/Chart.min",
      markdown: 'bower_components/markdown/lib/markdown',
      fastclick: 'bower_components/fastclick/lib/fastclick',
      nested_view: "scripts/vendor/nested_view",
      results: "scripts/views/results",
      controllers: "scripts/controllers",
      helpers: "scripts/helpers"
    },
    shim: {
      bootstrap: {
        deps: ['jquery'],
        exports: 'jquery'
      },
      chart: {
        exports: "Chart"
      },
      markdown: {
        exports: 'markdown'
      }
    },
    waitSeconds: 14
  });
});
