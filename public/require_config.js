
define([], function() {
  return require.config({
    packages: ['core', 'game/levels/rank_images', 'game/levels/circle_proximity'],
    paths: {
      Handlebars: "bower_components/require-handlebars-plugin/Handlebars",
      underscore: "bower_components/underscore-amd/underscore",
      jquery: "bower_components/jquery/jquery",
      jqueryui: "bower_components/jquery-ui/jqueryui",
      backbone: "bower_components/backbone-amd/backbone",
      syphon: 'bower_components/backbone.syphon/lib/amd/backbone.syphon',
      text: "bower_components/requirejs-text/text",
      toastr: "bower_components/toastr",
      nested_view: "scripts/vendor/nested_view",
      bootstrap: "scripts/vendor/bootstrap",
      chart: "scripts/vendor/Chart",
      assessments: "scripts/views/assessments",
      dashboard: "scripts/views/dashboard",
      components: "scripts/views/components",
      results: "scripts/views/results",
      routers: "scripts/routers",
      models: "scripts/models",
      controllers: "scripts/controllers",
      collections: "scripts/collections",
      helpers: "scripts/helpers",
      messages: "scripts/views/messages"
    },
    shim: {
      bootstrap: {
        deps: ["jquery"],
        exports: "jquery"
      },
      chart: {
        exports: "Chart"
      }
    }
  });
});
