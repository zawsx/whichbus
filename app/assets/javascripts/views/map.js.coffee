class Transit.Views.Map extends Backbone.View
  el: 'div#map'


  initialize: =>
    api_url = 'http://{s}.tiles.mapbox.com/v3/mapbox.mapbox-streets/{z}/{x}/{y}.png'
    @map = new L.Map(@el)
    cloudmade = new L.TileLayer(api_url,
      attribution: 'Map data &copy;
      <a href="http://openstreetmap.org">OpenStreetMap</a> contributors,
      <a href="http://creativecommons.org/licenses/by-sa/2.0/">CC-BY-SA</a>,
      Imagery &copy; <a href="http://mapbox.com/">Mapbox</a>',
      maxZoom: 18)
    seattle = new L.LatLng(47.62167,-122.349072)
    @map.setView(seattle, 13).addLayer(cloudmade)
    Transit.events.on 'plan:complete', @draw_route
    @marker_icon = L.Icon.extend(
      iconUrl: 'assets/marker.png'
      shadowUrl: 'assets/marker-shadow.png')
    @from = new L.Marker(
      new L.LatLng(47.63320158032844, -122.36168296958942),
      icon: new @marker_icon, clickable: false, draggable: true)
    @to = new L.Marker(
      new L.LatLng(47.618624, -122.320796),
      icon: new @marker_icon, clickable: false, draggable: true)
    @from.on 'dragend', @plan
    @to.on 'dragend', @plan
    @from.on 'dragstart', @clean_up
    @to.on 'dragstart', @clean_up
    Transit.events.on 'geocode:complete', @update_markers
    @plan_route = new L.LayerGroup()

  render: =>
    # route
    @map.addLayer(@from)
    @map.addLayer(@to)
    @plan()
    this


  plan: =>
    Transit.plan.set
      date: new Date()
      from: lat: @from.getLatLng().lat, lon: @from.getLatLng().lng
      to: lat: @to.getLatLng().lat, lon: @to.getLatLng().lng

    Transit.plan.fetch
      success: (plan) -> Transit.events.trigger 'plan:complete', plan
      error: (model, message) -> console.log message



  clean_up: =>
    Transit.events.trigger 'plan:clear'
    @plan_route.clearLayers()

  draw_route: (plan) =>
    @clean_up()
    console.log plan
    itinerary = plan.get('itineraries')[0]
    colors = {'BUS': 'blue', 'WALK': 'black'}
    for leg in itinerary.legs
      @draw_polyline(leg.legGeometry.points, colors[leg.mode] ? 'red')
    @map.addLayer(@plan_route)


  draw_polyline: (points, color) =>
    points = decodeLine(points)
    latlngs = (new L.LatLng(point[0], point[1]) for point in points)
    polyline = new L.Polyline(latlngs, color: color)
    @plan_route.addLayer(polyline)
    # zoom the map to the polyline
    #@map.fitBounds(new L.LatLngBounds(latlngs))

  update_markers: (from, to) =>
    @from.setLatLng(new L.LatLng(from.lat, from.lon))
    @to.setLatLng(new L.LatLng(to.lat, to.lon))
    @plan()
