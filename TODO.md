# How to make it better

## Frontend Design & UX
- Set the background color of the body and container to the same color.
- Remove the box shadow from the main container.
- Add a second container just for the diving conditions, with a subtle box shadow.
- Increase padding between elements for better spacing.
- Move the rating above the table.
- Use flexbox to align the table and a color-indicator div side by side.
- Add a fixed footer at the bottom of the page.

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
