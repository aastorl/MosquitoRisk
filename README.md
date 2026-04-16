# MosquitoRisk 🦟

[![Swift](https://img.shields.io/badge/Swift-6.0-orange.svg)](https://swift.org)
[![Platform](https://img.shields.io/badge/Platform-iOS%2017%2B-blue.svg)](https://www.apple.com/ios/)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

**MosquitoRisk** is a native iOS application designed to assess and track epidemiological risks related to mosquitoes (such as Dengue, Zika, and Chikungunya) based on real-time weather data. 

The app translates complex meteorological variables into an intuitive risk scale, helping users and health authorities take preventive measures.

## 📱 Features

* **Real-time Risk Assessment:** Calculates risk levels using temperature, humidity, and rainfall data.
* **Location-based Data:** Integration with CoreLocation to provide accurate local forecasts in Rosario, Argentina.
* **Interactive UI:** Clean and modern interface built entirely with SwiftUI.
* **Data Visualization:** Clear indicators of risk factors and prevention tips.

## 🛠 Tech Stack & Architecture

* **Language:** Swift 6
* **UI Framework:** SwiftUI
* **Architecture:** MVVM (Model-View-ViewModel) for a clean separation of concerns and testability.
* **Networking:** URLSession for REST API integration (OpenWeatherMap / custom epidemiological data).
* **Concurrency:** Swift Concurrency (async/await).
* **Dependency Management:** Swift Package Manager (SPM).

## 🏗 Project Structure

```text
MosquitoRisk/
├── Models/          # Data structures and Logic
├── ViewModels/      # Business logic and UI state
├── Views/           # SwiftUI View components
├── Services/        # API Clients and Location Managers
└── Resources/       # Assets and localizations

