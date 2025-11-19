//
//  WeatherService.swift
// 
//
//  Created by Astor Ludueña  on 05/05/2025.
//

//
//  WeatherService.swift
//
//  Created by Astor Ludueña on 05/05/2025.
//

import Foundation
internal import CoreLocation

class WeatherService {

    // MARK: - Fetch Weather from Vercel Proxy
    func fetchWeather(lat: Double, lon: Double, completion: @escaping (WeatherData?) -> Void) {
        // URL del endpoint en Vercel
        let urlString = "https://mosquito-risk.vercel.app/api/weather?lat=\(lat)&lon=\(lon)"
        
        guard let url = URL(string: urlString) else {
            print("URL inválida")
            completion(nil)
            return
        }
        
        let request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalCacheData)
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            // Validación básica de errores
            if let error = error {
                print("Error en la petición:", error.localizedDescription)
                completion(nil)
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode) else {
                print("Error HTTP:", (response as? HTTPURLResponse)?.statusCode ?? 0)
                completion(nil)
                return
            }
            
            guard let data = data, !data.isEmpty else {
                print("No se recibieron datos")
                completion(nil)
                return
            }
            
            do {
                let decoded = try JSONDecoder().decode(OpenWeatherResponse.self, from: data)
                
                let precipitation = decoded.rain?.lastHour ?? 0.0
                let windSpeed = decoded.wind?.speed ?? 0.0
                
                let weather = WeatherData(
                    temperature: decoded.main.temp,
                    humidity: decoded.main.humidity,
                    condition: decoded.weather.first?.main ?? "Desconocido",
                    precipitation: max(0, precipitation),
                    windSpeed: max(0, windSpeed),
                    sunrise: Date(timeIntervalSince1970: decoded.sys.sunrise),
                    sunset: Date(timeIntervalSince1970: decoded.sys.sunset)
                )
                
                DispatchQueue.main.async {
                    completion(weather)
                }
                
            } catch {
                print("Error decodificando JSON:", error.localizedDescription)
                completion(nil)
            }
            
        }.resume()
    }
}

// MARK: - API Response Structs
struct OpenWeatherResponse: Decodable {
    let main: Main
    let weather: [Weather]
    let rain: Rain?
    let wind: Wind?
    let sys: Sys

    struct Main: Decodable {
        let temp: Double
        let humidity: Double
    }

    struct Weather: Decodable {
        let main: String
    }

    struct Rain: Decodable {
        let lastHour: Double?

        enum CodingKeys: String, CodingKey {
            case lastHour = "1h"
        }
    }
    
    struct Wind: Decodable {
        let speed: Double
    }
    
    struct Sys: Decodable {
        let sunrise: TimeInterval
        let sunset: TimeInterval
    }
}


