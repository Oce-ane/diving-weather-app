# How to make it better

## Frontend Design & UX
- Change the table conditions' names (current situation, Swells & Bells, Under the Weather, Dive Tide, wave it or Save it, Go with the Floe, No Reef Grets, Bubble Trouble, Diver's Snooze, To Dive or Not to Dive, ...)
- Autocomplete search: Use map.flyTo() to zoom to the searched location.
- Cluster customization: Adjust cluster colors, sizes, and behavior to match the design.

## Functionality
- Implement the map feature to select dive sites interactively.
- Improve autocomplete search to provide better suggestions (gem fuzzymatch)
- Add more robust handling of edge cases in search queries.

## Testing
- Implement unit tests for API calls.
- Add integration tests with Capybara for search and results flow.
- Test random search queries to ensure the app can handle unexpected results.

## Performance & Optimization
- Optimise API requests to reduce latency.
- Implement caching for search results to avoid redundant queries.
- Calculate if / how much is the map slowing down the app

## Diving Weather App - Graphic Charter
1. Color Palette
Light Theme
Primary: Ocean Blue (#0077b6)
Secondary: Soft Cyan (#90e0ef)
Background: Light Sand (#f8f9fa)
Text: Deep Navy (#023e8a)
Accent: Coral (#ff6b6b)

Dark Theme
Primary: Deep Blue (#001f3f)
Secondary: Aqua Glow (#00a8cc)
Background: Midnight Navy (#002855)
Text: Soft White (#f8f9fa)
Accent: Coral (#ff6b6b)

2. Typography
Font: Sans-serif (e.g., Inter, Lato, or Poppins)
Weights:
Headings: Bold (700)
Body Text: Regular (400)
Small Text & Labels: Medium (500)

3. UI Elements
Buttons
Primary Buttons: Filled with ocean blue (#0077b6) or deep blue (#001f3f in dark theme), white text.
Secondary Buttons: Bordered with text in primary color.
Hover Effect: Slight gradient shift or subtle shadow.

Forms & Inputs
Rounded edges for input fields.
Soft border and hover effects.
Placeholder text in a slightly lighter shade.

4. Animations & Effects
Hover Effects: Applied to buttons, links, and interactive elements.
No heavy animations, just smooth transitions.
Shadows: Light drop shadows for contrast in the light theme; soft glow in the dark theme.
