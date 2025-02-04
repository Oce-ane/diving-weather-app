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
