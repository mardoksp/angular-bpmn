
'use strict'

angular.module('templates', [])
angular.module('appFilters', [])
angular.module('appControllers', [])
angular.module('appServices', ['ngResource'])
app = angular
  .module('app', [
    'templates'
    'ngRoute'
    'appControllers'
    'appFilters'
    'appServices'
    'route-segment'
    'view-segment'
    'angular-bpmn'
  ])

angular.module('app')
  .config ['$routeProvider', '$locationProvider', '$routeSegmentProvider'
  ($routeProvider, $locationProvider, $routeSegmentProvider) ->
    $routeSegmentProvider
      .when '/',                    'base'
      .when '/',                    'base.home'
      .when '/events',              'base.events'
      .when '/tasks',               'base.tasks'
      .when '/gateway',             'base.gateway'
      .when '/two_scheme',          'base.two_scheme'
      .when '/base_scheme',         'base.base_scheme'
      .when '/base_scheme_with_grouping',         'base.base_scheme_with_grouping'
      .when '/base_scheme_with_swimlane',         'base.base_scheme_with_swimlane'
      .when '/update_scheme_data',                'base.update_scheme_data'
      .when '/process_monitor',                   'base.process_monitor'
      .when '/themes',                            'base.themes'

      .segment 'base',
        templateUrl: '/templates/base.html'
        controller: 'baseCtrl'
        controllerAs: 'base'

      .within()

      .segment 'home',
        default: true
        templateUrl: '/templates/home.html'
        controller: 'homeCtrl'
        controllerAs: 'home'

      .segment 'events',
        templateUrl: '/templates/events.html'
        controller: 'eventsCtrl'
        controllerAs: 'events'

      .segment 'tasks',
        templateUrl: '/templates/tasks.html'
        controller: 'tasksCtrl'
        controllerAs: 'tasks'

      .segment 'gateway',
        templateUrl: '/templates/gateway.html'
        controller: 'gatewayCtrl'
        controllerAs: 'gateway'

      .segment 'two_scheme',
        templateUrl: '/templates/two_scheme.html'
        controller: 'twoSchemeCtrl'
        controllerAs: 'ctrl'

      .segment 'base_scheme',
        templateUrl: '/templates/base_scheme.html'
        controller: 'baseSchemeCtrl'
        controllerAs: 'ctrl'

      .segment 'base_scheme_with_grouping',
        templateUrl: '/templates/base_scheme_with_grouping.html'
        controller: 'baseSchemeWithGroupingCtrl'
        controllerAs: 'ctrl'

      .segment 'base_scheme_with_swimlane',
        templateUrl: '/templates/base_scheme_with_swimlane.html'
        controller: 'baseSchemeWithSwimlaneCtrl'
        controllerAs: 'ctrl'

      .segment 'update_scheme_data',
        templateUrl: '/templates/update_scheme_data.html'
        controller: 'updateSchemeDataCtrl'
        controllerAs: 'ctrl'

      .segment 'process_monitor',
        templateUrl: '/templates/process_monitor.html'
        controller: 'processMonitorCtrl'
        controllerAs: 'ctrl'

      .segment 'themes',
        templateUrl: '/templates/themes.html'
        controller: 'themesCtrl'
        controllerAs: 'ctrl'

    $locationProvider.html5Mode
      enabled: true
      requireBase: false

    $routeProvider.otherwise
      redirectTo: '/'
  ]

angular.module('app')
  .run ['$rootScope'
  ($rootScope) =>

  ]