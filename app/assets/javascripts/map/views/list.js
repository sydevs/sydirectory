/* exported ListView */

/* global m, App, Search, List, ListFallback, Navigation, Util */

function ListView() {
  let onlineEventsCount = null
  let events = null
  let layer = null

  function updateEvents() {
    if (layer == 'online') {
      return App.atlas.getOnlineList().then(response => {
        events = response
      })
    } else {
      return App.map.getRenderedEventIds().then(eventIds => {
        return eventIds.length > 0 ? App.atlas.getEvents(eventIds) : []
      }).then(response => {
        events = response
      }).catch(() => {
        events = null
      })
    }
  }

  function updateLayer(newLayer) {
    if (layer != newLayer) {
      layer = newLayer
      updateEvents().finally(() => m.redraw())
    }
  }

  return {
    oncreate: function(vnode) {
      layer = m.route.param('layer') || vnode.attrs.layer
      App.map.addEventListener('update', () => {
        updateEvents().finally(() => m.redraw())
      })
    },
    onupdate: function(vnode) {
      updateLayer(m.route.param('layer') || vnode.attrs.layer)
    },
    view: function(vnode) {
      let mobile = Util.isDevice('mobile')
      let list = null

      if (events && events.length > 0) {
        list = m(List, { events: events })
      } else if (vnode.attrs.layer == 'offline') {
        list = m(ListFallback)
      }

      App.atlas.getOnlineList().then(events => { onlineEventsCount = events.length })

      return [
        m(Search),
        m(Navigation, {
          items: mobile ?
            [[Util.translate('navigation.mobile.back'), '/']] :
            ['offline', 'online'].map((layer) => {
              const active = vnode.attrs.layer == layer
              return {
                label: Util.translate(`navigation.desktop.${layer}`),
                href: `/${layer}`,
                active: active,
                badge: (layer == 'online' && !active) ? onlineEventsCount : null,
              }
            })
        }),
        list,
      ]
    }
  }
}