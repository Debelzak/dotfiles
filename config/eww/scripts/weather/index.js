// Config
const forecastIntervalMin = 6*60;    // Forecast reload interval in 6h
const conditionIntervalMin = 60;   // Condition reload interval in 1h
const apiKey = process.env._EWW_WEATHER_API_KEY;
const location = process.env._EWW_WEATHER_LOCATION;
const language = process.env._EWW_WEATHER_LANG;
// Endconfig

async function OpenWeather(location) {
    const getLocation = async() => {
        const callUrl = `http://api.openweathermap.org/geo/1.0/direct?q=${location}&limit=1&appid=${apiKey}`;
        const request = await fetch(callUrl);
        const response = await request.json();
    
        return response[0];
    }

    const getWeather = async() =>
    {
        //const location = await getLocation(searchString);
    
        const callUrl = `https://api.openweathermap.org/data/2.5/weather?q=${location}&units=metric&appid=${apiKey}&lang=pt_BR`;
        const request = await fetch(callUrl);
        const response = await request.json();
        return response;
    }

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

    const forecast = await getWeather();

    const weatherIcon = forecast.weather[0].icon;
    forecast.glyph = getGlyph(weatherIcon);

    console.log(JSON.stringify(forecast));
}

async function WeatherApi(location) {
    const getWeather = async() => {
        const callUrl = `https://api.weatherapi.com/v1/forecast.json?key=${apiKey}&q=${location}&lang=pt`;
        const request = await fetch(callUrl);
        const response = await request.json();

        return response;
    }

    const getConditions = async() => {
        const callUrl = `https://www.weatherapi.com/docs/conditions.json`;
        const request = await fetch(callUrl);
        const response = await request.json();

        return response;
    }

    const getGlyph = (conditionCode, isDay) => {
        switch(conditionCode) {
            //Code: 1000 | Icon: 113 | Text Day: Sol | Text Night: Céu limpo
            case 1000: return (isDay == 1) ? "" : "";
            //Code: 1003 | Icon: 116 | Text Day: Parcialmente nublado | Text Night: Parcialmente nublado
            case 1003: return (isDay == 1) ? "" : "";
            //Code: 1006 | Icon: 119 | Text Day: Nublado | Text Night: Nublado
            case 1006: return (isDay == 1) ? "" : "";
            //Code: 1009 | Icon: 122 | Text Day: Encoberto | Text Night: Encoberto
            case 1009: return (isDay == 1) ? "" : "";
            //Code: 1030 | Icon: 143 | Text Day: Neblina | Text Night: Neblina
            case 1030: return (isDay == 1) ? "" : "";
            //Code: 1063 | Icon: 176 | Text Day: Possibilidade de chuva irregular | Text Night: Possibilidade de chuva irregular
            case 1063: return (isDay == 1) ? "" : "";
            //Code: 1066 | Icon: 179 | Text Day: Possibilidade de neve irregular | Text Night: Possibilidade de neve irregular
            case 1066: return (isDay == 1) ? "" : "";
            //Code: 1069 | Icon: 182 | Text Day: Possibilidade de neve molhada irregular | Text Night: Possibilidade de neve molhada irregular
            case 1069: return (isDay == 1) ? "" : "";
            //Code: 1072 | Icon: 185 | Text Day: Possibilidade de chuvisco gelado irregular | Text Night: Possibilidade de chuvisco gelado irregular
            case 1072: return (isDay == 1) ? "" : "";
            //Code: 1087 | Icon: 200 | Text Day: Possibilidade de trovoada | Text Night: Possibilidade de trovoada
            case 1087: return (isDay == 1) ? "" : "";
            //Code: 1114 | Icon: 227 | Text Day: Rajadas de vento com neve | Text Night: Rajadas de vento com neve
            case 1114: return (isDay == 1) ? "" : "";
            //Code: 1117 | Icon: 230 | Text Day: Nevasca | Text Night: Nevasca
            case 1117: return (isDay == 1) ? "" : "";
            //Code: 1135 | Icon: 248 | Text Day: Nevoeiro | Text Night: Nevoeiro
            case 1135: return (isDay == 1) ? "" : "";
            //Code: 1147 | Icon: 260 | Text Day: Nevoeiro gelado | Text Night: Nevoeiro gelado
            case 1147: return (isDay == 1) ? "" : "";
            //Code: 1150 | Icon: 263 | Text Day: Chuvisco irregular | Text Night: Chuvisco irregular
            case 1150: return (isDay == 1) ? "" : "";
            //Code: 1153 | Icon: 266 | Text Day: Chuvisco | Text Night: Chuvisco
            case 1153: return (isDay == 1) ? "" : "";
            //Code: 1168 | Icon: 281 | Text Day: Chuvisco gelado | Text Night: Chuvisco gelado
            case 1168: return (isDay == 1) ? "" : "";
            //Code: 1171 | Icon: 284 | Text Day: Chuvisco forte gelado | Text Night: Chuvisco forte gelado
            case 1171: return (isDay == 1) ? "" : "";
            //Code: 1180 | Icon: 293 | Text Day: Chuva fraca irregular | Text Night: Chuva fraca irregular
            case 1180: return (isDay == 1) ? "" : "";
            //Code: 1183 | Icon: 296 | Text Day: Chuva fraca | Text Night: Chuva fraca
            case 1183: return (isDay == 1) ? "" : "";
            //Code: 1186 | Icon: 299 | Text Day: Períodos de chuva moderada | Text Night: Períodos de chuva moderada
            case 1186: return (isDay == 1) ? "" : "";
            //Code: 1189 | Icon: 302 | Text Day: Chuva moderada | Text Night: Chuva moderada
            case 1189: return (isDay == 1) ? "" : "";
            //Code: 1192 | Icon: 305 | Text Day: Períodos de chuva forte | Text Night: Períodos de chuva forte
            case 1192: return (isDay == 1) ? "" : "";
            //Code: 1195 | Icon: 308 | Text Day: Chuva forte | Text Night: Chuva forte
            case 1195: return (isDay == 1) ? "" : "";
            //Code: 1198 | Icon: 311 | Text Day: Chuva fraca e gelada | Text Night: Chuva fraca e gelada
            case 1198: return (isDay == 1) ? "" : "";
            //Code: 1201 | Icon: 314 | Text Day: Chuva gelada moderada ou forte | Text Night: Chuva gelada moderada ou forte
            case 1201: return (isDay == 1) ? "" : "";
            //Code: 1204 | Icon: 317 | Text Day: Chuva fraca com neve | Text Night: Chuva fraca com neve
            case 1204: return (isDay == 1) ? "" : "";
            //Code: 1207 | Icon: 320 | Text Day: Chuva forte ou moderada com neve | Text Night: Chuva forte ou moderada com neve
            case 1207: return (isDay == 1) ? "" : "";
            //Code: 1210 | Icon: 323 | Text Day: Queda de neve irregular e fraca | Text Night: Queda de neve irregular e fraca
            case 1210: return (isDay == 1) ? "" : "";
            //Code: 1213 | Icon: 326 | Text Day: Queda de neve fraca | Text Night: Queda de neve fraca
            case 1213: return (isDay == 1) ? "" : "";
            //Code: 1216 | Icon: 329 | Text Day: Queda de neve moderada e irregular | Text Night: Queda de neve moderada e irregular
            case 1216: return (isDay == 1) ? "" : "";
            //Code: 1219 | Icon: 332 | Text Day: Queda de neve moderada | Text Night: Queda de neve moderada
            case 1219: return (isDay == 1) ? "" : "";
            //Code: 1222 | Icon: 335 | Text Day: Queda de neve forte e irregular | Text Night: Queda de neve forte e irregular
            case 1222: return (isDay == 1) ? "" : "";
            //Code: 1225 | Icon: 338 | Text Day: Neve intensa | Text Night: Neve intensa
            case 1225: return (isDay == 1) ? "" : "";
            //Code: 1237 | Icon: 350 | Text Day: Granizo | Text Night: Granizo
            case 1237: return (isDay == 1) ? "" : "";
            //Code: 1240 | Icon: 353 | Text Day: Aguaceiros fracos | Text Night: Aguaceiros fracos
            case 1240: return (isDay == 1) ? "" : "";
            //Code: 1243 | Icon: 356 | Text Day: Aguaceiros moderados ou fortes | Text Night: Aguaceiros moderados ou fortes
            case 1243: return (isDay == 1) ? "" : "";
            //Code: 1246 | Icon: 359 | Text Day: Chuva torrencial | Text Night: Chuva torrencial
            case 1246: return (isDay == 1) ? "" : "";
            //Code: 1249 | Icon: 362 | Text Day: Aguaceiros fracos com neve | Text Night: Aguaceiros fracos com neve
            case 1249: return (isDay == 1) ? "" : "";
            //Code: 1252 | Icon: 365 | Text Day: Aguaceiros moderados ou fortes com neve | Text Night: Aguaceiros moderados ou fortes com neve
            case 1252: return (isDay == 1) ? "" : "";
            //Code: 1255 | Icon: 368 | Text Day: Chuva fraca com neve | Text Night: Chuva fraca com neve
            case 1255: return (isDay == 1) ? "" : "";
            //Code: 1258 | Icon: 371 | Text Day: Chuva moderada ou forte com neve | Text Night: Chuva moderada ou forte com neve
            case 1258: return (isDay == 1) ? "" : "";
            //Code: 1261 | Icon: 374 | Text Day: Aguaceiros fracos com granizo | Text Night: Aguaceiros fracos com granizo
            case 1261: return (isDay == 1) ? "" : "";
            //Code: 1264 | Icon: 377 | Text Day: Aguaceiros moderados ou fortes com granizo | Text Night: Aguaceiros moderados ou fortes com granizo
            case 1264: return (isDay == 1) ? "" : "";
            //Code: 1273 | Icon: 386 | Text Day: Chuva fraca irregular com trovoada | Text Night: Chuva fraca irregular com trovoada
            case 1273: return (isDay == 1) ? "" : "";
            //Code: 1276 | Icon: 389 | Text Day: Chuva moderada ou forte com trovoada | Text Night: Chuva moderada ou forte com trovoada
            case 1276: return (isDay == 1) ? "" : "";
            //Code: 1279 | Icon: 392 | Text Day: Neve fraca irregular com trovoada | Text Night: Neve fraca irregular com trovoada
            case 1279: return (isDay == 1) ? "" : "";
            //Code: 1282 | Icon: 395 | Text Day: Neve moderada ou forte com trovoada | Text Night: Neve moderada ou forte com trovoada
            case 1282: return (isDay == 1) ? "" : "";
            default: return "?";
        }
    }
    
    const forecast = await getWeather();
    forecast.glyph = getGlyph(forecast.current.condition.code, forecast.current.is_day);

    console.log(JSON.stringify(forecast));
}

const AccuWeather = async() => {
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

    const glyphMap = {
        1: "\uf185",  // Sunny                        (D)
        2: "\uf6c4",  // Mostly Sunny                 (D)
        3: "\uf6c4",  // Partly Sunny                 (D)
        4: "\uf6c4",  // Intermittent Clouds          (D)
        5: "\uf6c4",  // Hazy Sunshine                (D)
        6: "\uf6c4",  // Mostly Cloudy                (D)
        7: "\uf0c2",  // Cloudy                   
        8: "\uf0c2",  // Dreary (Overcast)        
        11: "\uf75f", // Fog                      
        12: "\uf740", // Showers                  
        13: "\uf743", // Mostly Cloudy w/ Showers     (D)
        14: "\uf743", // Partly Sunny w/ Showers      (D)
        15: "\uf76c", // T-Storms                 
        16: "\uf76c", // Mostly Cloudy w/ T-Storms    (D)
        17: "\uf76c", // Partly Sunny w/ T-Storms     (D)
        18: "\uf740", // Rain                         
        19: "\uf740", // Flurries                     
        20: "\uf743", // Mostly Cloudy w/ Flurries    (D)
        21: "\uf743", // Partly Sunny w/ Flurries     (D)
        22: "\uf2dc", // Snow                         
        23: "\uf2dc", // Mostly Cloudy w/ Snow        (D)
        24: "\uf7ad", // Ice                          
        25: "\uf7ad", // Sleet                        
        26: "\uf740", // Freezing Rain                           
        29: "\uf740", // Rain and Snow                          
        30: "\ue040", // Hot                                                 
        31: "\ue03f", // Cold                         
        32: "\uf72e", // Windy                        
        33: "\uf186", // Clear                        (N)
        34: "\uf6c3", // Mostly Clear                 (N)
        35: "\uf6c3", // Partly Cloudy                (N)
        36: "\uf6c3", // Intermittent Clouds          (N)
        37: "\uf6c3", // Hazy Moonlight               (N)
        38: "\uf6c3", // Mostly Cloudy                (N)
        39: "\uf73c", // Partly Cloudy w/ Showers     (N)
        40: "\uf73c", // Mostly Cloudy w/ Showers     (N)
        41: "\uf76c", // Partly Cloudy w/ T-Storms    (N)
        42: "\uf76c", // Mostly Cloudy w/ T-Storms    (N)
        43: "\uf73c", // Mostly Cloudy w/ Flurries    (N)
        44: "\uf2dc", // Mostly Cloudy w/ Snow        (N)
    };

    const getGlyph = (iconCode) => glyphMap[iconCode] || "?";

    const loadLocation = async(reFetch = false) => {
        let loc = loadFile("./accuweather/location.json") || {};
        if(!loc.Key || reFetch || loc.lastSearchQuery !== location) {
            const callUrl = `http://dataservice.accuweather.com/locations/v1/cities/autocomplete?apikey=${apiKey}&q=${location}&language=${language}`;
            const request = await fetch(callUrl);
            const response = await request.json();
            loc = response[0];
            loc.lastSearchQuery = location;
            saveFile('./accuweather/location.json', loc);
        }

        return loc;
    }

    const loadCurrent = async(locationKey) => {
        let cur = loadFile("./accuweather/current.json") || {};

        if(cur.lastLocationKey && cur.lastLocationKey !== locationKey) {
            const newLocation = await loadLocation(true);
            locationKey = newLocation.Key;
        }

        if (cur.lastLocationKey !== locationKey || Date.now() > new Date(cur.lastUpdate).getTime() + conditionIntervalMin * 60 * 1000) {
            const updateCount = cur.updateCount ++ || 1
            const callUrl = `https://dataservice.accuweather.com/currentconditions/v1/${locationKey}?apikey=${apiKey}&details=true&language=${language}`;
            const request = await fetch(callUrl);
            const response = await request.json();
            console.log(response);
            cur = response[0];
            
            cur.lastUpdate = Date.now();
            cur.updateCount = updateCount;
            cur.lastLocationKey = locationKey;
            saveFile('./accuweather/current.json', cur);
        }

        return cur;
    }

    const loadForecast = async(locationKey) => {
        let frc = loadFile("./accuweather/forecast.json") || {};

        if(frc.lastLocationKey && frc.lastLocationKey !== locationKey) {
            const newLocation = await loadLocation(true);
            locationKey = newLocation.Key;
        }

        if (frc.lastLocationKey !== locationKey || Date.now() > new Date(frc.lastUpdate).getTime() + forecastIntervalMin * 60 * 1000) {
            const updateCount = frc.updateCount ++ || 1
            const callUrl = `https://dataservice.accuweather.com/forecasts/v1/daily/5day/${locationKey}?apikey=${apiKey}&details=true&metric=true&language=${language}`;
            const request = await fetch(callUrl);
            const response = await request.json();
            frc = response;
            frc.lastUpdate = Date.now();
            frc.updateCount = updateCount;
            frc.lastLocationKey = locationKey;
            frc.updateCount = frc.updateCount ++ || 1
            saveFile('./accuweather/forecast.json', frc);
        }

        return frc;
    }
    
    
    const weather = {};
    weather.location = await loadLocation();
    weather.current = await loadCurrent(weather.location.Key);
    weather.forecast = await loadForecast(weather.location.Key);

    // Add Glyphs
    for(const f of weather.forecast.DailyForecasts) {
        f.DayNameShort = new Date(f.EpochDate*1000).toLocaleDateString(`${language}`, { weekday: 'short' })
        f.Day.glyph = getGlyph(f.Day.Icon);
        f.Night.glyph = getGlyph(f.Night.Icon);
    }

    weather.current.glyph = getGlyph(weather.current.WeatherIcon);

    console.log(JSON.stringify(weather));
}

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
    //OpenWeather(location);
    //WeatherApi(location);
    //AccuWeather();
    OpenWeatherMap();
}

main();