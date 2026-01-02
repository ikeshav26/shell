import QtQuick
import Quickshell
pragma Singleton

// Root must be Item (not QtObject) to support the Timer
Item {
    // 30 Minutes
    // --- Logic ---

    id: root

    // --- Live Properties ---
    property string temperature: "--"
    property string conditionText: "Unknown"
    property string city: "Locating..."
    property string icon: ""
    property bool isDay: true
    // Detailed Stats
    property string humidity: "--%"
    property string wind: "-- km/h"
    property string pressure: "-- hPa"
    property string uvIndex: "--"
    property string sunrise: "--:--"
    property string sunset: "--:--"
    
    // Hourly Forecast Model (Array of values for graph)
    property var hourlyForecast: [] // [20, 21, 19, ...] for next 24h
    
    // Weekly Forecast Model (Array of objects)
    // Structure: { day: "Mon", icon: "...", max: "20°", min: "10°", condition: "Sunny" }
    property var forecastModel: []
    // --- Configuration ---
    
    // ... (keep weatherCodes) ...

    function formatTime(isoString) {
        if (!isoString) return "--:--";
        var date = new Date(isoString);
        return date.toLocaleTimeString(Qt.locale(), Locale.ShortFormat).replace(/:\d\d /, " "); // Simple HH:MM
    }

    // ... (keep getDayName and fetchLocation) ...

    function fetchWeather(lat, lon) {
        // Added hourly=temperature_2m and daily=sunrise,sunset
        var url = "https://api.open-meteo.com/v1/forecast?latitude=" + lat + "&longitude=" + lon + 
                  "&current=temperature_2m,is_day,weather_code,relative_humidity_2m,wind_speed_10m,surface_pressure" + 
                  "&hourly=temperature_2m" +
                  "&daily=weather_code,temperature_2m_max,temperature_2m_min,uv_index_max,sunrise,sunset" + 
                  "&timezone=auto&temperature_unit=celsius&wind_speed_unit=kmh&forecast_days=7";
                  
        var xhr = new XMLHttpRequest();
        xhr.onreadystatechange = function() {
            if (xhr.readyState === XMLHttpRequest.DONE) {
                if (xhr.status === 200) {
                    try {
                        var response = JSON.parse(xhr.responseText);
                        
                        // 1. Current Weather
                        var current = response.current;
                        root.temperature = Math.round(current.temperature_2m) + "°";
                        root.isDay = current.is_day === 1;
                        root.humidity = current.relative_humidity_2m + "%";
                        root.wind = current.wind_speed_10m + " km/h";
                        root.pressure = Math.round(current.surface_pressure) + " hPa";
                        
                        var code = current.weather_code;
                        var info = root._weatherCodes[code] || { "day": "", "night": "", "desc": "Unknown" };
                        root.icon = root.isDay ? info.day : info.night;
                        root.conditionText = info.desc;

                        // 2. Daily Data (UV, Sun, Forecast)
                        var daily = response.daily;
                        if (daily) {
                            if (daily.uv_index_max && daily.uv_index_max.length > 0)
                                root.uvIndex = daily.uv_index_max[0].toString();
                            
                            if (daily.sunrise && daily.sunrise.length > 0)
                                root.sunrise = formatTime(daily.sunrise[0]);
                                
                            if (daily.sunset && daily.sunset.length > 0)
                                root.sunset = formatTime(daily.sunset[0]);
                        }

                        // 3. Hourly Forecast (Graph Data)
                        var hourly = response.hourly;
                        if (hourly && hourly.temperature_2m) {
                            // Get next 24 hours starting from current time roughly
                            // API returns hourly data starting from 00:00 today.
                            // We should slice based on current hour, but for simplicity/robustness taking first 24 points is okay
                            // or better, if we can find the current hour index. 
                            // OpenMeteo hourly returns all hours for the requested days.
                            // We'll just take the next 24 points from the current time index?
                            // Actually, simpler to just take every 1st point for 24h if we assume it starts at 00:00 today 
                            // Timezone=auto aligns it to local time.
                            
                            var currentHourIndex = new Date().getHours();
                            // Slice 24 hours from current hour
                            var slice = hourly.temperature_2m.slice(currentHourIndex, currentHourIndex + 24);
                            root.hourlyForecast = slice;
                        }

                        // 4. Process Forecast (Next 5 days)
                        var newForecast = [];
                        for (var i = 1; i < 6; i++) {
                            if (!daily.time[i]) break;

                            var fCode = daily.weather_code[i];
                            var fInfo = root._weatherCodes[fCode] || { "day": "", "desc": "Unknown" };
                            
                            newForecast.push({
                                "day": getDayName(daily.time[i]),
                                "icon": fInfo.day,
                                "max": Math.round(daily.temperature_2m_max[i]) + "°",
                                "min": Math.round(daily.temperature_2m_min[i]) + "°",
                                "condition": fInfo.desc
                            });
                        }
                        root.forecastModel = newForecast;
                        
                    } catch (e) {
                         console.warn("[Weather] Weather JSON parse error", e);
                    }
                }
            }
        };
        xhr.open("GET", url);
        xhr.send();
    }

    // Timer works because root is Item
    Timer {
        interval: root.refreshInterval
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: root.fetchLocation()
    }

}
