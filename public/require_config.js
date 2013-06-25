
define([], function() {
  return require.config({
    packages: ['core', 'game/levels/reaction_time_disc', 'game/levels/rank_images', 'game/levels/circle_size', 'game/levels/circle_proximity', 'dashboard/widget-lister', 'ui_widgets/formation'],
    paths: {
      Handlebars: "bower_components/require-handlebars-plugin/Handlebars",
      underscore: "bower_components/underscore-amd/underscore",
      jquery: "bower_components/jquery/jquery",
      jqueryui: "bower_components/jquery-ui/jqueryui",
      backbone: "bower_components/backbone-amd/backbone",
      syphon: 'bower_components/tidepool-backbone.syphon/lib/amd/backbone.syphon',
      text: "bower_components/requirejs-text/text",
      toastr: "bower_components/toastr",
      chart: "bower_components/Chart.js/Chart.min",
      markdown: 'bower_components/markdown/lib/markdown',
      nested_view: "scripts/vendor/nested_view",
      bootstrap: "scripts/vendor/bootstrap",
      results: "scripts/views/results",
      controllers: "scripts/controllers",
      helpers: "scripts/helpers"
    },
    shim: {
      bootstrap: {
        deps: ["jquery"],
        exports: "jquery"
      },
      chart: {
        exports: "Chart"
      },
      markdown: {
        exports: 'markdown'
      }
    }
  });
});
