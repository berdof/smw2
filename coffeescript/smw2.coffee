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

(($smw2Jq, window) ->
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
    #981 658
    eventHandlers:
      foo: (e)->
        return

    attachEvents: ()->
      @$el.find('.yaw__feedback__sort a').on('click', {plugin: @}, @eventHandlers.foo)
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
    buildOfferFrag:(data)->
      $frag = $smw2Jq(
        '<tr></tr>'
          "data-smw2-href":data.clickUrl
          html:
            [
              $smw2Jq(
                '<td></td>'
                  "data-smw2":'offerName'
              )
            ]
      )
      #$smw2Jq('body').html($frag)
      console.log $frag
#
#    offerElem:
#    """
#    <td data-smw2='offerName'></td>
#    <td>
#    <div class="smw2__rate">
#    <span data-smw2='offerRate' style="width: 0%;"></span>
#    </div>
#    </td>
#    <td data-smw2='offerPrice'></td>
#    """
      return

    fillOffers:(name)->
      self = @
      $offer =  $smw2Jq(self.offerElem)

      #$offer =  $smw2Jq('[data-smw2=repeater]')
      self.dataCache.offers.forEach(
        (dOffers,i)->
          self.buildOfferFrag(dOffers)
          $offer.find('[data-smw2=offerName]').html(dOffers.name)
          $offer.find('[data-smw2=offerPrice]').html("#{dOffers.price} р.")
          $offer.find('[data-smw2=offerRate]').css('width',"#{dOffers.shopRating*20}%")

          $smw2Jq('[data-smw2=repeater]').append($offer)
          return
      )


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
                          shopRating : data.shopRating
                          price : data.price
                          clickUrl: data.clickUrl
                      return
                  )
                  self.fillOffers()
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
