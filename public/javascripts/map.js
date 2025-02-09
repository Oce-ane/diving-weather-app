// Initialise the map
var map = L.map('map', {
  center: [0, 0],
  zoom: 1
});

L.tileLayer('https://tile.openstreetmap.org/{z}/{x}/{y}.png', {
  maxZoom: 19,
  attribution: '&copy; <a href="http://www.openstreetmap.org/copyright">OpenStreetMap</a>'
}).addTo(map);

// Add Leaflet.markercluster library
var markers = L.markerClusterGroup({
  singleMarkerMode: true,
  iconCreateFunction: function(cluster) {
    var count = cluster.getChildCount();
    return L.divIcon({
      html: `<div class="cluster-count">${count}</div>`,
      className: 'custom-cluster-icon',
      iconSize: L.point(40, 40) 
    });
  }
});

// Fetch dive sites
fetch('/dive_sites')
  .then(response => response.json())
  .then(data => {
    data.forEach(site => {
      if (site.latitude && site.longitude) {
        var marker = L.marker([site.latitude, site.longitude])
          .bindPopup(`<b>${site.name}</b>`);
        markers.addLayer(marker);
      }
    });

    map.addLayer(markers);
  })
  .catch(error => console.error('Error fetching dive sites:', error));
