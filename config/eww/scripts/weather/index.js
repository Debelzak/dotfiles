// Config
const apiKey = process.env.API_KEY;
const location = process.env.LOCATION;
// Endconfig

async function main() {
    const forecast = await getWeather(location);
    const weatherIcon = forecast.weather[0].icon;
    forecast.glyph = getGlyph(weatherIcon);

    console.log(JSON.stringify(forecast));
}

async function getLocation(searchString) 
{
    const callUrl = `http://api.openweathermap.org/geo/1.0/direct?q=${searchString}&limit=1&appid=${apiKey}`;
    const request = await fetch(callUrl);
    const response = await request.json();

    return response[0];
}

async function getWeather(searchString)
{
    const location = await getLocation(searchString);

    const callUrl = `https://api.openweathermap.org/data/2.5/weather?lat=${location.lat}&lon=${location.lon}&units=metric&appid=${apiKey}`;
    const request = await fetch(callUrl);
    const response = await request.json();

    return response;
}

function getGlyph(icon)
{
    switch(icon)
    {
        case "01d": return ""; // clear sky
        case "01n": return ""; 
        case "02d": return ""; // few clouds
        case "02n": return "";
        case "03d": return ""; // scattered clouds
        case "03n": return "";
        case "04d": return ""; // broken clouds
        case "04n": return "";
        case "09d": return ""; // shower rain
        case "09n": return "";
        case "10d": return ""; // rain
        case "10n": return "";
        case "11d": return ""; // thunderstorm
        case "11n": return "";
        case "13d": return ""; // snow
        case "13n": return "";
        case "50d": return ""; // mist 
        case "50n": return "";

        default: return "?";
    }
}

main();