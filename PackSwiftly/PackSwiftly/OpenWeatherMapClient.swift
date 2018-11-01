//
//  OpenWeatherMapClient.swift
//  PackSwiftly
//
//  Created by Bernadett Kiss on 10/8/18.
//  Copyright © 2018 Bernadett Kiss. All rights reserved.
//

import Foundation

enum OpenWeatherMapResult {
    case success(weatherData: [WeatherData])
    case failure
}

struct WeatherData {
    let date: String
    let temperature: Measurement<UnitTemperature>
    let minimumTemperature: Measurement<UnitTemperature>
    let maximumTemperature: Measurement<UnitTemperature>
    let description: String
}

class OpenWeatherMapClient {
    
    static let shared = OpenWeatherMapClient()
    var unitOfTemperatureIsCelsius = true
    
    struct Constants {
        static let ApiScheme = "https"
        static let ApiHost = "api.openweathermap.org"
        static let ApiPath = "/data/2.5"
        static let CurrentWeatherPathExtension = "/weather"
        static let ForecastPathExtension = "/forecast"
    }
    
    struct ParameterKeys {
        static let Latitude = "lat"
        static let Longitude = "lon"
        static let APIKey = "APPID"
        static let Units = "units"
    }
    
    struct ParameterValues {
        static let APIKey = myOpenWeatherMapApiKey
        static let Metric = "metric"
        static let Imperial = "imperial"
    }
    
    struct ResponseKeys {
        static let List = "list"
        static let Date = "dt"
        static let Main = "main"
        static let Temp = "temp"
        static let TempMax = "temp_max"
        static let TempMin = "temp_min"
        static let Weather = "weather"
        static let Description = "description"
    }
    
    func getWeatherData(latitude: Double, longitude: Double, inCelsius: Bool, completionHandler: @escaping (OpenWeatherMapResult) -> Void) {
        unitOfTemperatureIsCelsius = inCelsius
        let urlParameters = openWeatherMapURLParameters(latitude: latitude, longitude: longitude)
        NetworkManager.shared.request(client: .openWeatherMap, pathExtension: Constants.CurrentWeatherPathExtension, urlParameters: urlParameters) { networkResponse in
            switch networkResponse {
            case .failure(error: let error):
                debugPrint(error)
                completionHandler(.failure)
                return
            case .success(response: let result):
                let parsedResult = self.process(result as! JSONObject)
                if let parsedWeatherData = parsedResult {
                    completionHandler(OpenWeatherMapResult.success(weatherData: parsedWeatherData))
                } else {
                    completionHandler(.failure)
                }
            }
        }
    }
    
    func getForecast(latitude: Double, longitude: Double, inCelsius: Bool, completionHandler: @escaping (OpenWeatherMapResult) -> Void) {
        unitOfTemperatureIsCelsius = inCelsius
        let urlParameters = openWeatherMapURLParameters(latitude: latitude, longitude: longitude)
        NetworkManager.shared.request(client: .openWeatherMap, pathExtension: Constants.ForecastPathExtension, urlParameters: urlParameters) { networkResponse in
            switch networkResponse {
            case .failure(error: let error):
                debugPrint(error)
                completionHandler(.failure)
                return
            case .success(response: let result):
                let parsedResult = self.process(result as! JSONObject)
                if let parsedWeatherData = parsedResult {
                    completionHandler(OpenWeatherMapResult.success(weatherData: parsedWeatherData))
                } else {
                    completionHandler(.failure)
                }
            }
        }
    }
    
    private func openWeatherMapURLParameters(latitude: Double, longitude: Double) -> Parameters {
        var units = ParameterValues.Metric
        if !unitOfTemperatureIsCelsius {
            units = ParameterValues.Imperial
        }
        
        let urlParameters = [
            ParameterKeys.Latitude: "\(latitude)",
            ParameterKeys.Longitude: "\(longitude)",
            ParameterKeys.Units: units,
            ParameterKeys.APIKey: ParameterValues.APIKey
        ]
        return urlParameters
    }
    
    private func process(_ result: JSONObject) -> [WeatherData]? {
        guard let forecast = result[ResponseKeys.List] as? [[String: AnyObject]] else { return nil }
        
        var parsedForecast = [WeatherData]()
        for weatherDataJSON in forecast {
            if let parsedWeatherData = self.weatherData(fromJSON: weatherDataJSON) {
                parsedForecast.append(parsedWeatherData)
            }
        }
        return parsedForecast
    }
    
    private func weatherData(fromJSON json: [String: AnyObject]) -> WeatherData? {
        guard let timeResult = json[ResponseKeys.Date] as? Double,
            let mainDictionary = json[ResponseKeys.Main] as? [String: AnyObject],
            let temperature = mainDictionary[ResponseKeys.Temp] as? Double,
            let minimumTemperature = mainDictionary[ResponseKeys.TempMin] as? Double,
            let maximumTemperature = mainDictionary[ResponseKeys.TempMax] as? Double,
            let weatherArray = json[ResponseKeys.Weather] as? [[String: AnyObject]],
            let description = weatherArray[0][ResponseKeys.Description] as? String else {
                return nil
        }
        let date = Date(timeIntervalSince1970: timeResult)
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        dateFormatter.timeStyle = .none
        dateFormatter.timeZone = TimeZone.current
        let localDate = dateFormatter.string(from: date)
        
        var unit = UnitTemperature.celsius
        if !unitOfTemperatureIsCelsius {
            unit = UnitTemperature.fahrenheit
        }
        
        return WeatherData(date: localDate, temperature: Measurement(value: temperature, unit: unit), minimumTemperature: Measurement(value: minimumTemperature, unit: unit), maximumTemperature: Measurement(value: maximumTemperature, unit: unit), description: description)
    }
}
