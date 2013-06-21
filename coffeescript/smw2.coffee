###
 **
* jQuery Yandex fedbacks Plugin for socialmart.ru
*
* Author: Alexander Berdyshev
*
* Version: 1.0
*
 **
###

(($smw2Jq, window1,window) ->
  class Smw2
    $el: null
    defaults:
      title: ''
      serverUrl: 'http://socialmart.ru'
      searchMode: 'splitbylat'
      region: 213
      cssLinkPath: 'http://socialmart.ru/css/style.css'
      widgetSelectorId: 'smw2'
      modelId : 0
      limit:5

    dataCache:
      name:""
      offers: []

    log: (str)->
      console.log str
      return

    appendLibraries:()->
      self = @
      $smw2Jq('head').prepend($smw2Jq('<link/>', {
        'href': self.options.cssLinkPath,
        'rel': 'stylesheet'
      }));
      return

    constructor: (el, options) ->
      @options = $smw2Jq.extend({}, @defaults, options)
      @$el = $smw2Jq(el)
      @init()
      @appendLibraries();
      return

    eventHandlers:
      redirectClick: (e)->
        self =  e.data.plugin
        href =  $smw2Jq(@).data('smw2Redirect')
        #window.location.href = href
        window.open(href)

        return

    attachEvents: ()->
      self = @
      $smw2Jq('#smw2').on('click','.smw2__body tr', {plugin: self},self.eventHandlers.redirectClick)
      return

    fetchId: ()->
      selfOpts = @options
      url = "#{selfOpts.serverUrl}/widget/get/model/?name=#{selfOpts.title}&jsonp=?"
      $smw2Jq.ajax(
        'url': url
        'dataType': 'jsonp'
      )

    fetchPrices:()->
      selfOpts = @options
      console.log @.options.modelId
      url = "http://socialmart.ru/widget/get/model/prices?model=#{selfOpts.modelId}&region=#{selfOpts.region}&jsonp=?"
      $smw2Jq.ajax(
        'url': url
        'dataType': 'jsonp'
      )

    fetchDescription:()->
      selfOpts = @options
      url = "http://socialmart.ru/widget/get/model/info?model=#{selfOpts.modelId}&region=#{selfOpts.region}&jsonp=?"
      $smw2Jq.ajax(
        'url': url
        'dataType': 'jsonp'
      )
    fillWidget:()->
      console.log @dataCache
      #
      source   = $smw2Jq("#smw2-template").html()
      template = Handlebars.compile(source)
      html = template(@dataCache)
      $smw2Jq('#smw2').html(html)
      return

    init: () ->
      self = this
      self.attachEvents()

      self.fetchId().done(
        (d)->
          self.options.modelId = d.model_id
          self.fetchDescription().done(
            (d)->
              self.dataCache.name = d.name
              self.fetchPrices().done(
                (d)->
                  d.offers.forEach(
                    (data,index)->
                      if index < self.options.limit

                        self.dataCache.offers.push
                          name : data.name
                          shopRating : data.shopRating*20
                          price : data.price
                          clickUrl: data.clickUrl
                      return
                  )
                  self.fillWidget()
                  return
              )
              return
          )
          return
      )
      return

    $smw2Jq.fn.extend smw2: (option, args...) ->
      @each ->
        $this = $smw2Jq(this)
        data = $this.data('smw2')

        if !data
          $this.data 'smw2', (data = new Smw2(this, option))
        if typeof option == 'string'
          data[option].apply(data, args)
) $smw2Jq, window.jQuery, window
