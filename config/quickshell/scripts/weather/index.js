// Config
const forecastIntervalMin = 6*60;    // Forecast reload interval in 6h
const conditionIntervalMin = 60;   // Condition reload interval in 1h
const apiKey = process.env._SHELL_WEATHER_API_KEY;
const location = process.env._SHELL_WEATHER_LOCATION;
const language = process.env._SHELL_WEATHER_LANG;
// Endconfig

const OpenWeatherMap = async() => {
    const fs = require("fs");
    const path = require("path");

    const ensureDirectoryExists = (dirPath) => {
        if (!fs.existsSync(dirPath)) {
            fs.mkdirSync(dirPath, { recursive: true });
        }
    };

    const loadFile = (filePath) => {
        try {
            return require(filePath);
        } catch (error) {
            return undefined;
        }
    }

    const saveFile = (relativePath, data) => {
        const absolutePath = path.join(__dirname, relativePath); // Converte para caminho absoluto
        const dirPath = path.dirname(absolutePath); // Obtém o diretório do arquivo
        ensureDirectoryExists(dirPath); // Garante que o diretório existe
        fs.writeFileSync(absolutePath, JSON.stringify(data, null, 2), 'utf8');
    };

    const getGlyph = (icon) =>
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

    const loadLocation = async(reFetch = false) => {
        let loc = loadFile("./openweathermap/location.json") || {};
        if(!loc.name || reFetch || loc.lastSearchQuery !== location) {
            const callUrl = `http://api.openweathermap.org/geo/1.0/direct?q=${location}&limit=1&appid=${apiKey}`;
            const request = await fetch(callUrl);
            const response = await request.json();
            loc = response[0];
            loc.lastSearchQuery = location;
            saveFile('./openweathermap/location.json', loc);
        }

        return loc;
    }

    const loadCurrent = async(location) => {
        let cur = loadFile("./openweathermap/current.json") || {};

        if(cur.lastLocation && cur.lastLocation.name !== location.name) {
            const newLocation = await loadLocation(true);
            location = newLocation;
        }

        if ( cur.cod != "200" || (cur.lastLocation.name !== location.name || Date.now() > new Date(cur.lastUpdate).getTime() + conditionIntervalMin * 60 * 1000)) {
            const updateCount = cur.updateCount ++ || 1
            const callUrl = `https://api.openweathermap.org/data/2.5/weather?lat=${location.lat}&lon=${location.lon}&appid=${apiKey}&lang=${language}&units=metric`;
            const request = await fetch(callUrl);
            const response = await request.json();
            cur = response;
            cur.lastUpdate = Date.now();
            cur.updateCount = updateCount;
            cur.lastLocation = location;
            saveFile('./openweathermap/current.json', cur);
        }

        return cur;
    }

    const loadForecast = async(location) => {
        let frc = loadFile("./openweathermap/forecast.json") || {};

        if(frc.lastLocation && frc.lastLocation.name !== location.name) {
            const newLocation = await loadLocation(true);
            location = newLocation;
        }
        
        if ( frc.cod != "200" || (frc.lastLocation.name !== location.name || Date.now() > new Date(frc.lastUpdate).getTime() + forecastIntervalMin * 60 * 1000 )) {
            const updateCount = frc.updateCount ++ || 1
            const callUrl = `http://api.openweathermap.org/data/2.5/forecast?lat=${location.lat}&lon=${location.lon}&appid=${apiKey}&lang=${language}&units=metric`;
            const request = await fetch(callUrl);
            const response = await request.json();
            frc = response;
            frc.lastUpdate = Date.now();
            frc.updateCount = updateCount;
            frc.lastLocation = location;
            frc.updateCount = frc.updateCount ++ || 1
            saveFile('./openweathermap/forecast.json', frc);
        }

        return frc;
    }
    
    
    const weather = {};
    weather.location = await loadLocation();
    weather.current = await loadCurrent(weather.location);
    const rawForecast = await loadForecast(weather.location);

    // Add Glyphs
    weather.current.glyph = getGlyph(weather.current.weather[0].icon);

    // Build a 5-day forecast array with min/max per day (include today)
    // Use timezone from forecast response or from saved location, fallback to -3
    let tzOffset = -3 * 3600;
    if (rawForecast && rawForecast.city && typeof rawForecast.city.timezone === 'number') {
        tzOffset = rawForecast.city.timezone;
        // Save timezone to location for future reference
        if (weather.location) {
            weather.location.timezone = tzOffset;
            saveFile('./openweathermap/location.json', weather.location);
        }
    } else if (weather.location && typeof weather.location.timezone === 'number') {
        tzOffset = weather.location.timezone;
    }

    const dailyMap = new Map();
    if (rawForecast && Array.isArray(rawForecast.list)) {
        for (const entry of rawForecast.list) {
            const localDate = new Date((entry.dt + tzOffset) * 1000);
            const y = localDate.getUTCFullYear();
            const m = String(localDate.getUTCMonth() + 1).padStart(2, '0');
            const d = String(localDate.getUTCDate()).padStart(2, '0');
            const dateKey = `${y}-${m}-${d}`;
            const hour = localDate.getUTCHours();

            const tempMin = (entry.main && typeof entry.main.temp_min === 'number') ? entry.main.temp_min : (entry.main && typeof entry.main.temp === 'number' ? entry.main.temp : null);
            const tempMax = (entry.main && typeof entry.main.temp_max === 'number') ? entry.main.temp_max : (entry.main && typeof entry.main.temp === 'number' ? entry.main.temp : null);
            const feelsLike = (entry.main && typeof entry.main.feels_like === 'number') ? entry.main.feels_like : null;
            const humidity = (entry.main && typeof entry.main.humidity === 'number') ? entry.main.humidity : null;
            const pressure = (entry.main && typeof entry.main.pressure === 'number') ? entry.main.pressure : null;
            const seaLevel = (entry.main && typeof entry.main.sea_level === 'number') ? entry.main.sea_level : null;
            const wind = (entry.wind && typeof entry.wind.speed === 'number') ? { speed: entry.wind.speed, gust: entry.wind.gust || null, deg: entry.wind.deg || null } : null;
            const clouds = (entry.clouds && typeof entry.clouds.all === 'number') ? entry.clouds.all : null;
            const visibility = (typeof entry.visibility === 'number') ? entry.visibility : null;
            const rain = (entry.rain && typeof entry.rain['3h'] === 'number') ? entry.rain['3h'] : null;
            const snow = (entry.snow && typeof entry.snow['3h'] === 'number') ? entry.snow['3h'] : null;
            const currentIcon = (entry.weather && entry.weather[0] && entry.weather[0].icon) ? entry.weather[0].icon : null;
            const description = (entry.weather && entry.weather[0] && entry.weather[0].description) ? entry.weather[0].description : null;

            if (!dailyMap.has(dateKey)) {
                dailyMap.set(dateKey, {
                    date: dateKey,
                    min: tempMin,
                    max: tempMax,
                    feelsLike: feelsLike ? [feelsLike] : [],
                    humidity: humidity !== null ? [humidity] : [],
                    pressure: pressure !== null ? [pressure] : [],
                    seaLevel: seaLevel !== null ? [seaLevel] : [],
                    wind: wind ? [wind] : [],
                    clouds: clouds !== null ? [clouds] : [],
                    visibility: visibility !== null ? [visibility] : [],
                    rain: rain !== null ? rain : 0,
                    snow: snow !== null ? snow : 0,
                    icon: currentIcon,
                    description: description,
                    dayNameShort: localDate.toLocaleDateString('pt-br', { weekday: 'short', timeZone: 'UTC' })
                });
            } else {
                const cur = dailyMap.get(dateKey);
                if (tempMin !== null && (cur.min === null || tempMin < cur.min)) cur.min = tempMin;
                if (tempMax !== null && (cur.max === null || tempMax > cur.max)) cur.max = tempMax;
                if (feelsLike !== null) cur.feelsLike.push(feelsLike);
                if (humidity !== null) cur.humidity.push(humidity);
                if (pressure !== null) cur.pressure.push(pressure);
                if (seaLevel !== null) cur.seaLevel.push(seaLevel);
                if (wind !== null) cur.wind.push(wind);
                if (clouds !== null) cur.clouds.push(clouds);
                if (visibility !== null) cur.visibility.push(visibility);
                if (rain !== null) cur.rain += rain;
                if (snow !== null) cur.snow += snow;
                if (currentIcon && cur.icon === null) cur.icon = currentIcon;
                if (description && cur.description === null) cur.description = description;
                if (hour === 12 && currentIcon) {
                    cur.icon = currentIcon;
                    if (description) cur.description = description;
                }
            }
        }
    }

    // Build ordered array starting from local today and include next 4 days
    const startLocal = new Date(Date.now() + tzOffset * 1000);
    const baseYear = startLocal.getUTCFullYear();
    const baseMonth = startLocal.getUTCMonth();
    const baseDate = startLocal.getUTCDate();

    const dailyArray = [];
    for (let i = 0; i < 5; i++) {
        const dt = new Date(Date.UTC(baseYear, baseMonth, baseDate + i));
        const y = dt.getUTCFullYear();
        const m = String(dt.getUTCMonth() + 1).padStart(2, '0');
        const d = String(dt.getUTCDate()).padStart(2, '0');
        const key = `${y}-${m}-${d}`;
        const found = dailyMap.get(key);
        if (found) {
            // round to 1 decimal
            const min = (typeof found.min === 'number') ? Math.round(found.min * 10) / 10 : null;
            const max = (typeof found.max === 'number') ? Math.round(found.max * 10) / 10 : null;
            const glyph = getGlyph(found.icon);
            
            // Calculate averages for aggregated fields
            const avgFeelsLike = found.feelsLike.length > 0 ? Math.round(found.feelsLike.reduce((a,b) => a+b, 0) / found.feelsLike.length * 10) / 10 : null;
            const avgHumidity = found.humidity.length > 0 ? Math.round(found.humidity.reduce((a,b) => a+b, 0) / found.humidity.length) : null;
            const avgPressure = found.pressure.length > 0 ? Math.round(found.pressure.reduce((a,b) => a+b, 0) / found.pressure.length) : null;
            const avgSeaLevel = found.seaLevel.length > 0 ? Math.round(found.seaLevel.reduce((a,b) => a+b, 0) / found.seaLevel.length) : null;
            const avgClouds = found.clouds.length > 0 ? Math.round(found.clouds.reduce((a,b) => a+b, 0) / found.clouds.length) : null;
            const avgVisibility = found.visibility.length > 0 ? Math.round(found.visibility.reduce((a,b) => a+b, 0) / found.visibility.length) : null;
            
            // Get wind info from noon entry or last available
            const windInfo = found.wind.length > 0 ? found.wind[found.wind.length - 1] : null;
            
            dailyArray.push({ 
                date: key, 
                dayNameShort: found.dayNameShort, 
                min, 
                max, 
                feelsLike: avgFeelsLike,
                humidity: avgHumidity,
                pressure: avgPressure,
                seaLevel: avgSeaLevel,
                wind: windInfo,
                clouds: avgClouds,
                visibility: avgVisibility,
                rain: Math.round(found.rain * 100) / 100,
                snow: Math.round(found.snow * 100) / 100,
                icon: found.icon,
                description: found.description,
                glyph 
            });
        } else {
            const dayNameShort = dt.toLocaleDateString('pt-br', { weekday: 'short', timeZone: 'UTC' });

            if (i === 0 && weather.current) {
                const cur = weather.current;
                const curMain = cur.main || {};
                const minCur = (typeof curMain.temp_min === 'number') ? curMain.temp_min : (typeof curMain.temp === 'number' ? curMain.temp : null);
                const maxCur = (typeof curMain.temp_max === 'number') ? curMain.temp_max : (typeof curMain.temp === 'number' ? curMain.temp : null);
                const feels = (typeof curMain.feels_like === 'number') ? Math.round(curMain.feels_like * 10) / 10 : null;
                const hum = (typeof curMain.humidity === 'number') ? curMain.humidity : null;
                const pres = (typeof curMain.pressure === 'number') ? curMain.pressure : null;
                const sea = (typeof curMain.sea_level === 'number') ? curMain.sea_level : null;
                const wind = (cur.wind && typeof cur.wind.speed === 'number') ? { speed: cur.wind.speed, gust: cur.wind.gust || null, deg: cur.wind.deg || null } : null;
                const clouds = (cur.clouds && typeof cur.clouds.all === 'number') ? cur.clouds.all : null;
                const visibility = (typeof cur.visibility === 'number') ? cur.visibility : null;
                const rain = (cur.rain && (cur.rain['1h'] || cur.rain['3h'])) ? (cur.rain['1h'] || cur.rain['3h']) : 0;
                const snow = (cur.snow && (cur.snow['1h'] || cur.snow['3h'])) ? (cur.snow['1h'] || cur.snow['3h']) : 0;
                const icon = (cur.weather && cur.weather[0] && cur.weather[0].icon) ? cur.weather[0].icon : null;
                const description = (cur.weather && cur.weather[0] && cur.weather[0].description) ? cur.weather[0].description : null;
                const glyphCur = getGlyph(icon);

                dailyArray.push({ 
                    date: key,
                    dayNameShort,
                    min: (typeof minCur === 'number') ? Math.round(minCur * 10) / 10 : null,
                    max: (typeof maxCur === 'number') ? Math.round(maxCur * 10) / 10 : null,
                    feelsLike: feels,
                    humidity: hum,
                    pressure: pres,
                    seaLevel: sea,
                    wind: wind,
                    clouds: clouds,
                    visibility: visibility,
                    rain: Math.round(rain * 100) / 100,
                    snow: Math.round(snow * 100) / 100,
                    icon: icon,
                    description: description,
                    glyph: glyphCur
                });
            } else {
                dailyArray.push({ 
                    date: key, 
                    dayNameShort, 
                    min: null, 
                    max: null, 
                    feelsLike: null,
                    humidity: null,
                    pressure: null,
                    seaLevel: null,
                    wind: null,
                    clouds: null,
                    visibility: null,
                    rain: 0,
                    snow: 0,
                    icon: null,
                    description: null,
                    glyph: '?' 
                });
            }
        }
    }

    weather.forecast = dailyArray;

    console.log(JSON.stringify(weather));
}

async function main() {
    OpenWeatherMap();
}

main();