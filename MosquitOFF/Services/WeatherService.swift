//
//  WeatherService.swift
//  MosquitOFF
//
//  Created by Astor Ludueña  on 05/05/2025.
//

import Foundation
import CoreLocation

class WeatherService {
    let apiKey = "ecd27ae9b48df86066912ed7e837fe85"

    func fetchWeather(lat: Double, lon: Double, completion: @escaping (WeatherData?) -> Void) {
        let urlString =
        "https://api.openweathermap.org/data/2.5/weather?lat=\(lat)&lon=\(lon)&units=metric&appid=\(apiKey)&lang=es"
        
        guard let url = URL(string: urlString) else {
            print("❌ URL inválida")
            completion(nil)
            return
        }

        URLSession.shared.dataTask(with: url) { data, _, error in
            if let data = data {
                do {
                    let decoded = try JSONDecoder().decode(OpenWeatherResponse.self, from: data)

                    let precipitation = decoded.rain?.lastHour ?? 0.0

                    let weather = WeatherData(
                        temperature: decoded.main.temp,
                        humidity: decoded.main.humidity,
                        condition: decoded.weather.first?.main ?? "Desconocido",
                        precipitation: precipitation,
                        windSpeed: decoded.wind?.speed ?? 0.0,
                        sunrise: Date(timeIntervalSince1970: decoded.sys.sunrise),
                        sunset: Date(timeIntervalSince1970: decoded.sys.sunset)
                    )

                    DispatchQueue.main.async {
                        completion(weather)
                    }
                } catch {
                    print("❌ Error decoding:", error)
                    completion(nil)
                }
            } else {
                print("❌ Error en la petición:", error?.localizedDescription ?? "Desconocido")
                completion(nil)
            }
        }.resume()
    }
}

// MARK: - API Response Struct

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


