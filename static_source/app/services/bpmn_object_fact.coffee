
'use strict'

angular
.module('angular-bpmn')
.factory 'bpmnObjectFact', ['bpmnSettings', '$compile', '$rootScope', 'log', '$templateRequest', '$templateCache'
  (bpmnSettings, $compile, $rootScope, log, $templateRequest, $templateCache) ->
    class schemeObject

      id: null
      isDebug: true
      parentScope: null
      data: null
      anchor: null
      make: null
      draggable: null
      templateUrl: null
      template: null
      element: null
      container: null
      size: null
      points: null
      settings: null
      childs: null
      position:
        top: 0
        left: 0
      isParent: false
      childsAABB: null

      constructor: (data, parentScope)->
        log.debug 'object construct'
        @parentScope = parentScope
        @settings = parentScope.settings
        @data = data

        tpl = bpmnSettings.template(data.type.name)
        @anchor = tpl.anchor
        @size = tpl.size
        @make = tpl.make
        @draggable = tpl.draggable
        @templateUrl = tpl.templateUrl || null
        @template = tpl.template || null
        @childs = []
        @position =
          top: data.position.top
          left: data.position.left
        @templateUpdate()

      templateUpdate: ()->
        childScope = $rootScope.$new()
        childScope.data = @data
        childScope.instance = @parentScope.instance
        childScope.object = this

        # компилим темплейт для него
        appendToElement = (element)=>
          @element
            .empty()
            .append(element)

        if @templateUrl? && @templateUrl != ''
          if !@element?
            @element = $compile('<div bpmn-object class="'+@data.type.name+' draggable etc" ng-class="[data.status]"></div>')(childScope)
          templateUrl = @settings.theme.root_path + '/' + @settings.engine.theme + '/' + @templateUrl
          template = $templateCache.get(templateUrl)
          if !template?
            log.debug 'template not found', templateUrl
            @elementPromise = $templateRequest(templateUrl)
            @elementPromise.then (result)->
              appendToElement($compile(result)(childScope))
              $templateCache.put(templateUrl, result)
          else
            appendToElement($compile(template)(childScope))
        else
          if !@element?
            @element = $compile(@template)(childScope)

      generateAnchor: (options)->
        if !@anchor || @anchor.length == 0
          return

        if !@element
          log.debug 'generateAnchor: @element is null', this
          return

        points = []
        angular.forEach @anchor, (anchor)=>
          point = @parentScope.instance.addEndpoint(@element, {
            anchor: anchor
            maxConnections: -1
          }, options)

          if points.indexOf(point) == -1
            points.push(point)

        @points = points

      appendTo: (container, options)->
        if !@element || @element == ''
          log.debug 'appendTo: @element is null', this
          return

        @container = container
        container.append(@element)

        if @size
          $(@element).css({
            width: @size.width
            height: @size.height
          })
        else
          log.error '@size is null, element:', @element

        @checkParent()

        # генерируем точки соединений для нового объекта
        @generateAnchor(options)

        @setDraggable(@draggable)

      select: (tr)->
        if tr
          $(@element).addClass("selected")
        else
          $(@element).removeClass("selected")

      getId: ()->
        if !@id?
          @id = $(@element).attr('id')

        @id

      setDraggable: (tr)->
        @parentScope.instance.setDraggable($(@element), tr)

      # --------------------------------------------------
      # группировка элементов
      # --------------------------------------------------

      group: (groupId)->
        @parentScope.instance.addToPosse(@getId(), {id:groupId,active:true})

      ungroup: (groupId)->
        @parentScope.instance.removeFromPosse(@getId(), groupId);

      # --------------------------------------------------
      # операции с потомками
      # --------------------------------------------------
      checkParent: ()->

        # Проверим конфиг, если указаны родители, подключимся к ним
        if !@data.parent? || @data.parent == ''
          return

        parent = null
        angular.forEach @parentScope.intScheme.objects, (obj)=>
          if obj.data.id == @data.parent
            parent = obj

        if !parent?
          return

        @element.removeClass("etc")

        parentId = @setParent(parent)
        #------------------------
        if (@data.draggable? && @data.draggable) || @data.draggable?
          @parentScope.instance.draggable(@element, $.extend({}, @settings.draggable, {
            containment: parentId
            drag: (event, ui)=>
#              $log.debug 'child dragging'
#              @parentScope.instance.repaintEverything()
            stop: (event, ui)=>

              # update position info
              @position.left = event.pos[0]
              @position.top = event.pos[1]

              parent.updateChildsAABB()

              @parentScope.instance.repaintEverything()
          }))

      setParent: (parent)->
        if !parent?
          return

        parent_element = parent.element
        @parentScope.instance.setParent(@element, parent_element)
        id = parent_element.attr('id')

        parent.isParent = true
        if $.inArray(@data, parent.childs) == -1
          parent.childs.push(this)

        if parent_element.hasClass(id)
          return id

        parent_element
          .addClass(id)
          .removeClass("etc")

        #------------------------
        if (parent.data.draggable? && parent.data.draggable) || parent.data.draggable?
          @parentScope.instance.draggable(parent_element, $.extend({}, @settings.draggable, {
            drag: (event, ui)=>
              @parentScope.instance.repaintEverything()
#            $log.debug 'parent dragging'

            stop: (event, ui)=>
              # update position info
              @position.left = event.pos[0]
              @position.top = event.pos[1]

              @parentScope.instance.repaintEverything()
          }))

        parent_element

      removeParent: ()->
        #TODO add remove parent

      getAllChilds: ()->
        childs = []
        angular.forEach @childs, (child)->
          childs.push(child)
          tch = child.getAllChilds()
          if tch.length > 0
            childs = childs.concat(tch)

        return childs

      getChildsAABB: ()->
        if !@childsAABB
          childs = @getAllChilds()
          @childsAABB = @getAABB(childs)
        return @childsAABB

      updateChildsAABB: ()->
        childs = @getAllChilds()
        @childsAABB = @getAABB(childs)

      getAABB: (objects)->

        l_min = 9999
        t_min = 9999

        l_max = 0
        t_max = 0

        angular.forEach objects, (object)=>

          w = object.size.width
          if object.size.width == 'auto'
            w = $(object.element).width()

          h = object.size.height
          if object.size.height == 'auto'
            h = $(object.element).height()

          # min
          if object.position.left < l_min
            l_min = object.position.left

          if object.position.top < t_min
            t_min = object.position.top

          # max
          l = object.position.left + w
          t = object.position.top + h

          if l > l_max
            l_max = l

          if t > t_max
            t_max = t

        {
          l_min: l_min
          t_min: t_min
          l_max: l_max
          t_max: t_max
        }

      remove: ()->
        id = @getId()

        if !id?
          return

        log.debug 'remove: ', id

        @parentScope.instance
          .detachAllConnections(@element)
          .empty(id)
          .remove(id)

        @childs = null
        @isParent = false
        @container = null
        @element = null
        @points = null

    schemeObject
  ]