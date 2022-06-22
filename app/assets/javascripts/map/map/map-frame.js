/* exported MapFrame */
/* global mapboxgl, MapboxLanguage, OnlineMapLayer, OfflineMapLayer, SelectionMapLayer */

class MapFrame extends EventTarget {

  static EMPTY_STYLE = { version: 8,sources: {},layers: [] }

  // Private variables
  #mapbox
  #loading = true
  #layers = {}
  #selectionLayer
  #currentLayerId

  // Getters
  get loading() {
    return this.#loading || this.#currentLayer.loading
  }

  get #currentLayer() {
    return this.#layers[this.#currentLayerId]
  }

  constructor(containerId, config) {
    super()

    config = Object.assign({
      onload: () => {},
    }, config)

    mapboxgl.accessToken = 'pk.eyJ1Ijoic3lkZXZhZG1pbiIsImEiOiJjazczcXV4ZzQwZXJtM3JxZTF6a2g0dW9hIn0.avMfkC306-2PqpNRnz6otg'

    this.#mapbox = new mapboxgl.Map({
      container: containerId,
      style: MapFrame.EMPTY_STYLE,
      minZoom: 1,
      dragRotate: false,
      hash: true,
    })

    let initalizing = true

    this.#mapbox.on('load', () => {
      console.log('mapbox load')
      initalizing = false
      this.#selectionLayer = new SelectionMapLayer(this.#mapbox)
      this.#layers = {
        online: new OnlineMapLayer(this.#mapbox),
        offline: new OfflineMapLayer(this.#mapbox),
      }

      this.showLayer(config.layer)
      this.loadControlLayers()
      this._setupHooks()
    })

    this.#mapbox.on('style.load', () => {
      if (initalizing) return

      console.log('mapbox style loaded')
      this.#loading = true
      this.#currentLayer.visible = true

      this.#currentLayer.load().then(() => {
        this.#selectionLayer.load()
        this.#loading = false
        this.dispatchEvent(new Event('load'))
        this.dispatchEvent(new Event('update'))
      })
    })
  }

  waitForLoad() {
    if (this.#loading) {
      return new Promise((resolve, reject) => {
        this.addEventListener('load', () => resolve())
      })
    } else {
      return Promise.resolve()
    }
  }

  loadControlLayers() {
    this.#mapbox.addControl(new MapboxLanguage({ defaultLanguage: window.locale }))
    this.#mapbox.addControl(new mapboxgl.NavigationControl({ showCompass: false }))

    const geolocater = new mapboxgl.GeolocateControl()
    this.#mapbox.addControl(geolocater)

    geolocater.on('geolocate', event => {
      this.setUserLocation(event.coords, true)
    })
  }

  _setupHooks() {
    //window.addEventListener('resize', _event => this.updatePadding())
    this.#mapbox.on('render', _event => this.dispatchEvent(new Event('update')))
    //this.#mapbox.on('moveend', _event => this.dispatchEvent(new Event('update')))
  }

  getRenderedEventIds() {
    if (this.#loading) return null

    return this.#currentLayer.getRenderedEventIds()
  }

  showLayer(layerId) {
    layerId ||= 'offline'
    if (layerId == this.#currentLayerId) return

    Object.values(this.#layers).forEach(layer => { layer.visible = false })
    this.#currentLayerId = layerId
    this.#mapbox.setStyle(this.#layers[layerId].style)
  }

  async setSelection(location, options) {
    this.waitForLoad().then(() => {
      this.#selectionLayer.setSelection(location, options)
    })
  }

  getCenter() {
    const center = this.#mapbox.getCenter()
    return { latitude: center.lat, longitude: center.lng }
  }

  resize() {
    this.#mapbox.resize()
  }

  destroy() {
    this.#mapbox.remove()
  }

}