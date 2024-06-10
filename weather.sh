#!/bin/bash
# Script to display weather forecast and city name using Tomorrow.io API and OpenCage Geocoding API

apikey_opencage=""  
apikey_tomorrow=""  


if [ $# -eq 0 ]; then
    # Prompt the user to enter a city name
    read -p "Enter the name of the city: " city_name
else
    city_name="$1"
fi

geo_data=$(curl -s --request GET --url "https://api.opencagedata.com/geocode/v1/json?q=$city_name&key=$apikey_opencage")

if [ $? -ne 0 ]; then
    echo "Error: Failed to fetch city information."
    exit 1
fi

latitude=$(echo "$geo_data" | jq -r '.results[0].geometry.lat')
longitude=$(echo "$geo_data" | jq -r '.results[0].geometry.lng')

weather=$(curl -s --request GET --url "https://api.tomorrow.io/v4/weather/forecast?location=$latitude,$longitude&apikey=$apikey_tomorrow")

if [ $? -ne 0 ]; then
    echo "Error: Failed to fetch weather data."
    exit 1
fi

temperature=$(echo "$weather" | jq -r '.timelines.minutely[0].values.temperature')

if [ "$temperature" = "null" ]; then
    echo "Error: Temperature data not available."
    exit 1
fi

echo "Weather forecast for $city_name: $temperature°C"

