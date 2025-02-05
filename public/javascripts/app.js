// AUTOCOMPLETE FUNCTION
$(document).ready(function() {
  $('#dive-site-search').on('input', function() {
    var query = $(this).val();
    if (query.length > 2) { // Trigger after typing 3 characters
      $.ajax({
        url: '/autocomplete',
        data: { query: query },
        dataType: 'json',
        success: function(data) {
          var suggestions = $('#suggestions');
          suggestions.empty(); // Clear previous suggestions
          data.forEach(function(diveSite) {
            suggestions.append('<div class="suggestion">' + diveSite.name + ' (' + diveSite.country_name + ')</div>');
          });
        }
      });
    }
  });

  $(document).on('click', '.suggestion', function() {
    $('#dive-site-search').val($(this).text());  // Fill input with selected name
    $('#suggestions').empty();  // Clear suggestions
  });
});

// SEARCH FUNCTION
async function search() {
  const query = document.querySelector('input[name="query"]').value;
  if (query.length < 3) {
    alert("Please enter at least 3 characters");
    return;
  }

  // Search for results
  const response = await fetch(`/search?query=${encodeURIComponent(query)}`);
  const data = await response.json();

  const resultsContainer = document.getElementById('search-results');
  const conditionsContainer = document.getElementById('conditions');

  if (data.error) {
    resultsContainer.innerHTML = `<p>${data.error}</p>`;
    conditionsContainer.innerHTML = '';
  } else {
    resultsContainer.innerHTML = '';
    data.results.forEach(result => {
      const p = document.createElement('p');
      p.textContent = result.name;
      resultsContainer.appendChild(p);
    });

    // Parse the conditions string into an object
    const conditions = parseConditions(data.conditions);

    // Creating the conditions table
    conditionsContainer.innerHTML = `
      <p>${data.conditions.rating}</p>
      <div class="weather">
        <div class="table_conditions">
          <table>
            <thead>
              <tr>
                <th>Condition</th>
                <th>Value</th>
              </tr>
            </thead>
            <tbody>
              <tr>
                <td>Water temperature</td>
                <td>${data.conditions.water_temp}</td>
              </tr>
              <tr>
                <td>Current</td>
                <td>${data.conditions.current_speed}</td>
              </tr>
              <tr>
                <td>Wave height</td>
                <td>${data.conditions.wave_height}</td>
              </tr>
              <tr>
                <td>Wave period</td>
                <td>${data.conditions.wave_period}</td>
              </tr>
              <tr>
                <td>Precipitation</td>
                <td>${data.conditions.precipitation}</td>
              </tr>
            </tbody>
          </table>
        </div>
        <div class="color_conditions">
        </div>
      </div>
    `;
  }
}

// This function updates the suggestions as the user types
async function fetchSuggestions() {
  const query = document.querySelector('input[name="query"]').value;
  if (query.length < 3) {
    document.getElementById('suggestions').innerHTML = '';
    return;
  }

  const response = await fetch(`/autocomplete?query=${encodeURIComponent(query)}`);
  const suggestions = await response.json();

  const suggestionsContainer = document.getElementById('suggestions');
  suggestionsContainer.innerHTML = '';  // Clear previous suggestions

  if (suggestions.length > 0) {
    suggestions.forEach(suggestion => {
      const suggestionElement = document.createElement('p');
      suggestionElement.textContent = `${suggestion.name} (${suggestion.country_name})`;
      suggestionsContainer.appendChild(suggestionElement);
    });
  } else {
    suggestionsContainer.innerHTML = '<p>No suggestions found</p>';
  }
}

// Function to parse the condition string into an object
function parseConditions(conditionsString) {
const conditions = {};

// Use regular expressions to extract key-value pairs from the conditions string
const regex = /([a-zA-Z\s]+):\s([0-9.]+)([a-zA-Z\/]*)/g;
let match;

// Extract each condition and store it in the conditions object
while ((match = regex.exec(conditionsString)) !== null) {
  const key = match[1].trim().replace(/\s+/g, '_').toLowerCase(); // e.g., "Water Temp" => "water_temp"
  const value = match[2]; // e.g., "22.85"
  conditions[key] = value;
}

// Add a rating key if it’s available
conditions.rating = "Good"; // You can dynamically assign this based on the conditions or calculate it elsewhere

return conditions;
}

// Listen for input and update suggestions dynamically
document.querySelector('input[name="query"]').addEventListener('input', fetchSuggestions);
