require 'open-uri'
require 'uri'
require 'nokogiri'
require 'parallel'
require_relative "../models/country.rb"
require_relative "../models/dive_site.rb"

start_time = Time.now

BASE_URL = "https://www.wannadive.net"

# Open the index page and get the country links
index_url = "#{BASE_URL}/spot/index.html"
index_html = URI.open(index_url).read
index_doc = Nokogiri::HTML.parse(index_html)

# Get all country links
country_links = index_doc.css("p.wanna-main-menu-static-country-line a:not(.wanna-main-menu-static-tabbar-submenu-inactive)")

puts "Starting the scraping process..."

# Convert the coordinates
def convert_to_decimal_degrees(coord)
  degrees, minutes, direction = coord.match(/(\d+)°\s*(\d+\.\d+)' (\w)/).captures
  decimal_degrees = degrees.to_f + (minutes.to_f / 60)
  decimal_degrees = -decimal_degrees if direction == 'S' || direction == 'W'
  decimal_degrees
end

# Scraping method for each dive site
def scrape_dive_site(site_name, site_url, country_name)
  puts "    Scraping dive site: #{site_name}"

  # Use regex to separate the name and any content in parentheses
  name_match = site_name.match(/^([^(]+)(?:\s*\(([^)]+)\))?$/)
  if name_match
    site_name = name_match[1].strip
    site_name_in_parentheses = name_match[2]
    puts "      Name extracted: #{site_name}"
    puts "      Parentheses content: #{site_name_in_parentheses}" if site_name_in_parentheses
  else
    puts "      No match for site name with parentheses"
  end

  begin
    # Fetch dive site page
    site_html = URI.open(site_url).read
    site_doc = Nokogiri::HTML.parse(site_html)

    # Check if there are sub-level areas or links within this site
    deeper_areas = site_doc.css("a.wanna-tabzonespot-item-title")

    if deeper_areas.any?
      puts "      Found deeper levels. Scraping them..."

      # Recursively scrape deeper areas (sub-links)
      deeper_areas.each do |deeper_area|
        deeper_area_name = deeper_area.text.strip
        deeper_area_url = BASE_URL + URI::DEFAULT_PARSER.escape(deeper_area["href"])
        scrape_dive_site(deeper_area_name, deeper_area_url, country_name)
      end
    else
      # Extract latitude and longitude if no deeper areas
      latitude_text = site_doc.at('td[valign="top"] p:contains("Latitude:")')&.text
      longitude_text = site_doc.at('td[valign="top"] p:contains("Longitude:")')&.text
      latitude_match = latitude_text.match(/Latitude:\s*([\d°'"\sNSEW.-]+)/) if latitude_text
      longitude_match = longitude_text.match(/Longitude:\s*([\d°'"\sNSEW.-]+)/) if longitude_text

      if latitude_match && longitude_match
        latitude = convert_to_decimal_degrees(latitude_match[1])
        longitude = convert_to_decimal_degrees(longitude_match[1])

        puts "      Latitude: #{latitude}, Longitude: #{longitude}"

        # Store in database
        country_record = Country.find_or_create_by(name: country_name)
        DiveSite.find_or_create_by(name: site_name, country_id: country_record.id) do |ds|
          ds.latitude = latitude
          ds.longitude = longitude
        end

        puts "      Stored: #{site_name} at #{latitude}, #{longitude}"
      else
        puts "      Could not extract GPS data for #{site_name}."
      end
    end

  rescue => e
    puts "    Error scraping site #{site_name}: #{e.message}"
  end
end


# Iterate over each country
country_links.each do |country|
  country_name = country.text.strip
  country_url = BASE_URL + country["href"]
  country_url += "/index.html" unless country_url.include?("index.html")

  puts "  Checking country: #{country_name}..."
  puts "  Country URL: #{country_url}"

  begin
    # Fetch country page
    country_html = URI.open(country_url).read
    country_doc = Nokogiri::HTML.parse(country_html)

    # Find dive sites within this country
    dive_sites = country_doc.css("td a.wanna-tabzonespot-item-title")

    if dive_sites.empty?
      puts "  No dive sites found for #{country_name}. Skipping..."
      next
    end

    puts "  Found #{dive_sites.length} dive sites in #{country_name}."

    # Start parallel scraping dive sites
    Parallel.each(dive_sites, in_threads: 10) do |site_link|
      site_name = site_link.text.strip
      site_url = BASE_URL + URI::DEFAULT_PARSER.escape(site_link["href"])

      # Call the scrape method for each dive site
      scrape_dive_site(site_name, site_url, country_name)
    end

  rescue => e
    puts "  Error processing country #{country_name}: #{e.message}"
  end

  # Sleep between countries to avoid server overload
  sleep(rand(2..5))
end

puts "Scraping complete!"

end_time = Time.now

# Calculate the time taken
elapsed_time = end_time - start_time

puts "Total scraping time: #{elapsed_time} seconds"
