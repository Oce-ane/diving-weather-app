// Initialise the map
var map = L.map('map', {
  center: [0, 0],
  zoom: 1
});

L.tileLayer('https://tile.openstreetmap.org/{z}/{x}/{y}.png', {
  maxZoom: 19,
  attribution: '&copy; <a href="http://www.openstreetmap.org/copyright">OpenStreetMap</a>'
}).addTo(map);

// Load dive sites from the server

// Add cluster layer

// Cluster count labels

// Unclustered dive sites

// Click to zoom into clusters

// Click to show dive site details
