# How to make it better

## Frontend Design & UX
- Change the table conditions' names (current situation, Swells & Bells, Under the Weather, Dive Tide, wave it or Save it, Go with the Floe, No Reef Grets, Bubble Trouble, Diver's Snooze, To Dive or Not to Dive, ...)
- Autocomplete search: Use map.flyTo() to zoom to the searched location.
- Cluster customization: Adjust cluster colors, sizes, and behavior to match the design.

## Functionality
- Implement the map feature to select dive sites interactively.
- Improve autocomplete search to provide better suggestions.
- Add more robust handling of edge cases in search queries.

## Testing
- Implement unit tests for API calls.
- Add integration tests with Capybara for search and results flow.
- Test random search queries to ensure the app can handle unexpected results.

## Performance & Optimization
- Optimise API requests to reduce latency.
- Implement caching for search results to avoid redundant queries.
- Calculate if / how much is the map slowing down the app
