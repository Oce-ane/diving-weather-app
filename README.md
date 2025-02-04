<h1>Diving Weather App</h1>

<h3>Overview</h3>

This is a side project that focuses on scraping large datasets (over 10,000 entries) from a dive site directory, processing marine weather data, and presenting it to users in an intuitive way. The goal is to provide a diving conditions rating system based on data from the Storm Glass API, allowing users to assess whether conditions are ideal for diving at a particular location.

As a side project, this app also serves as a great way to work with several key technologies, including scraping complex data, working with APIs, and using Sinatra to create a simple web application. It’s a work in progress and there are many features that will be improved or added over time.

<h3>Key Features (Work in Progress)</h3>

- **Dive Site Search:** Users can search for dive sites by name or country and get diving conditions like wave height, wind speed, water temperature, and more.
Weather Data: Weather conditions are fetched using the Storm Glass API and evaluated to provide a diving suitability rating (from "Not worth getting out of bed" to "These are dream diving conditions").
- **Large Dataset Scraping:** The app scrapes over 10,000 dive sites from an external directory, dealing with the complexity of different levels of nesting (countries, continents, and dive spots) in the data structure.
Result Display: Results will be presented in a table, along with a colorful and user-friendly diving conditions rating.

**Future Features:**
- **Interactive Map:** The ability to choose a dive site from a map, rather than just search.
- **Enhanced Design:** Working on improving the design to make the results colorful and easy to read.
- **Better Error Handling:** Improvements for API request failures and rate limiting (for example, handling the free plan limits of Storm Glass).

<h3>Technologies Used</h3>

- Sinatra: A lightweight Ruby framework used to build the web application and handle routing.
- HTTParty: Used to make API requests to the Storm Glass API for marine weather data.
- PG Search: Full-text search for querying dive sites and countries in the database.
- Nokogiri: Used for web scraping, specifically for extracting dive site data from an external site (wannadive.net).
- PostgreSQL: Database for storing dive site and country information.
- JavaScript/CSS: Used for frontend features such as autocomplete and styling.
- jQuery UI: Used the widget for autocomplete

<h3>Features to Explore</h3>

- **Scraping Dive Sites:** The scraper retrieves data from a large external database of dive sites. Due to the complex nesting structure (countries within continents, dive sites within countries), it’s a great exercise in handling complex data relationships.
- **API Integration:** Fetch weather data from the Storm Glass API, which has limitations on the number of requests that can be made per day (in the free plan). Learning how to handle API rate limits and deal with responses is an essential skill.
- **Dynamic Diving Conditions:** The app calculates and displays diving conditions using wave height, wave period, and other factors. This allows for an interesting exploration of how to use environmental data to inform user decisions.

<h3>Future Plans</h3>

- **Better Design:** The results table will be revamped to have a more colorful and intuitive design that makes it easier for users to assess diving conditions at a glance.
- **Interactive Map:** Users will be able to choose a dive site from a map instead of typing out a name. This will improve the usability and interactivity of the app.
- **Rate Limiting Handling:** The app currently works with Storm Glass's free tier, which has limited API requests per day. Future versions will implement better handling of this limitation to inform users when the data is unavailable due to request limits.
