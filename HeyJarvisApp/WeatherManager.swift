//
//  WeatherManager.swift
//  HeyJarvisApp
//
//  Weather data using wttr.in (free, no API key required)
//

import Foundation
import CoreLocation

class WeatherManager: NSObject, ObservableObject {
    static let shared = WeatherManager()
    
    @Published var currentWeather: WeatherData?
    @Published var isLoading = false
    @Published var error: String?
    
    private let locationManager = CLLocationManager()
    private var locationCompletion: ((CLLocation?) -> Void)?
    
    override private init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyKilometer
    }
    
    // MARK: - Public Methods
    
    func getWeatherResponse() async -> String {
        isLoading = true
        defer { isLoading = false }
        
        // Try to get location first
        guard let location = await getCurrentLocation() else {
            // Fall back to IP-based location
            return await fetchWeatherByIP()
        }
        
        return await fetchWeather(lat: location.coordinate.latitude, lon: location.coordinate.longitude)
    }
    
    // MARK: - Location
    
    private func getCurrentLocation() async -> CLLocation? {
        let status = locationManager.authorizationStatus
        
        if status == .notDetermined {
            locationManager.requestWhenInUseAuthorization()
            try? await Task.sleep(nanoseconds: 1_000_000_000) // Wait 1 second for user response
        }
        
        guard status == .authorizedWhenInUse || status == .authorizedAlways else {
            return nil
        }
        
        return await withCheckedContinuation { continuation in
            locationCompletion = { location in
                continuation.resume(returning: location)
            }
            locationManager.requestLocation()
            
            // Timeout after 5 seconds
            Task {
                try? await Task.sleep(nanoseconds: 5_000_000_000)
                if self.locationCompletion != nil {
                    self.locationCompletion?(nil)
                    self.locationCompletion = nil
                }
            }
        }
    }
    
    // MARK: - Weather API (wttr.in - free, no key required)
    
    private func fetchWeatherByIP() async -> String {
        guard let url = URL(string: "https://wttr.in/?format=j1") else {
            return "I'm afraid I couldn't access weather services, sir."
        }
        
        return await fetchWeatherFromURL(url)
    }
    
    private func fetchWeather(lat: Double, lon: Double) async -> String {
        guard let url = URL(string: "https://wttr.in/\(lat),\(lon)?format=j1") else {
            return "I'm afraid I couldn't access weather services, sir."
        }
        
        return await fetchWeatherFromURL(url)
    }
    
    private func fetchWeatherFromURL(_ url: URL) async -> String {
        do {
            var request = URLRequest(url: url)
            request.addValue("application/json", forHTTPHeaderField: "Accept")
            request.timeoutInterval = 10
            
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                return "Weather services are temporarily unavailable, sir."
            }
            
            let weather = try JSONDecoder().decode(WttrResponse.self, from: data)
            return formatWeatherResponse(weather)
            
        } catch {
            print("Weather error: \(error)")
            return "I encountered a difficulty retrieving the weather data, sir."
        }
    }
    
    private func formatWeatherResponse(_ weather: WttrResponse) -> String {
        guard let current = weather.current_condition?.first,
              let area = weather.nearest_area?.first else {
            return "Weather data is currently unavailable, sir."
        }
        
        let location = area.areaName?.first?.value ?? "your location"
        let temp_c = current.temp_C ?? "Unknown"
        let temp_f = current.temp_F ?? "Unknown"
        let condition = current.weatherDesc?.first?.value ?? "Unknown conditions"
        let humidity = current.humidity ?? "Unknown"
        let feelsLike_f = current.FeelsLikeF ?? temp_f
        
        return "Currently in \(location), it's \(temp_f) degrees Fahrenheit with \(condition.lowercased()). " +
               "Humidity is at \(humidity) percent, and it feels like \(feelsLike_f) degrees, sir."
    }
}

// MARK: - Location Delegate

extension WeatherManager: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        locationCompletion?(locations.first)
        locationCompletion = nil
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location error: \(error)")
        locationCompletion?(nil)
        locationCompletion = nil
    }
}

// MARK: - Weather Data Models

struct WeatherData {
    let temperature: String
    let condition: String
    let humidity: String
    let location: String
}

// wttr.in JSON response models
struct WttrResponse: Codable {
    let current_condition: [WttrCurrentCondition]?
    let nearest_area: [WttrNearestArea]?
}

struct WttrCurrentCondition: Codable {
    let temp_C: String?
    let temp_F: String?
    let humidity: String?
    let weatherDesc: [WttrValue]?
    let FeelsLikeC: String?
    let FeelsLikeF: String?
}

struct WttrNearestArea: Codable {
    let areaName: [WttrValue]?
    let country: [WttrValue]?
    let region: [WttrValue]?
}

struct WttrValue: Codable {
    let value: String?
}
