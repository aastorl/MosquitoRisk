# MosquitoRisk (iOS) Deep Dive

Este documento describe la app **MosquitoRisk** tal como está implementada en este repo: su estructura, tecnologías, arquitectura, flujos de UI, networking y decisiones técnicas visibles en el código.

Estado: **versión 1.1.1** (MARKETING_VERSION `1.1.1`, build `5`). Deployment target iOS `17.6`.

## 1) Vista Rápida (resumen)

MosquitoRisk es una app iOS hecha en **SwiftUI** que estima el **riesgo de mosquitos** (heurístico) en **Rosario, Argentina**, usando clima (temperatura, humedad, lluvia, viento) y la **ubicación del usuario**. Incluye:

- Pantalla principal con “Riesgo en tu ubicación” + cards del clima.
- Fondo animado por condición climática (video).
- Animación de mosquitos (según riesgo).
- Notificaciones locales cuando el riesgo es **alto** (con throttling).
- “Mapa de riesgo” con zonas (parques/islas) renderizadas como overlays en MapKit.

## 2) Estructura del Repo

En la raíz del proyecto:
- `MosquitOFF/`: código fuente de la app.
- `MosquitOFF.xcodeproj/`: configuración de Xcode.
- `MosquitOFFTests/`: unit tests (XCTest).
- `README.md`: descripción breve.
- `Docs/`: documentación (este archivo + Q&A).

Dentro de `MosquitOFF/`:
- `MosquitOFF.swift`: entrypoint SwiftUI `@main`.
- `Models/`: modelos de dominio (`WeatherData`, `RiskZone`).
- `Services/`: networking (`WeatherService`).
- `ViewModels/`: view models (`WeatherViewModel`, `HeatMapViewModel`).
- `Views/`: pantallas, sheets y bridges a UIKit (`StaticHeatMapView`, `WeatherVideoBackgroundView`, `LottieView`).
- `Utils/`: utilitarios (`MosquitoRisk`, `LocationManager`, `NetworkMonitor`, `NotificationManager`).

Nota de naming: el target/código usa el nombre `MosquitOFF`, pero la marca/UI se muestra como **MosquitoRisk**.

## 3) Targets y Configuración (Xcode)

Targets:
- `MosquitOFF` (app).
- `MosquitOFFTests` (unit tests).

Config detectada (según `MosquitOFF.xcodeproj/project.pbxproj`):
- `SWIFT_VERSION = 5.0`.
- Deployment target app: iOS `17.6`.
- Permiso de ubicación vía build setting `INFOPLIST_KEY_NSLocationWhenInUseUsageDescription`.

Dependencias externas:
- **Lottie** (Swift Package) para animaciones.

## 4) Tecnologías y “por qué”

### SwiftUI para UI
La UI usa `NavigationStack`, `NavigationLink`, `sheet`, `@StateObject`, `@AppStorage` y composición de vistas para manejar:
- Pantalla principal (`HomeView`).
- Pantallas informativas (`RiskInfoSheetView`, `HeatMapInfoSheet`).
- Ajustes (`SettingsView`).

### MapKit + CoreLocation
- CoreLocation para obtener la ubicación del usuario (`LocationManager`).
- MapKit para mostrar un mapa con overlays (círculos de riesgo) y anotaciones.
- Se usa un bridge UIKit (`MKMapView`) desde SwiftUI: `StaticHeatMapView`.

### Networking con URLSession (vía Proxy)
`WeatherService` consulta un endpoint HTTP (proxy en Vercel) y decodifica respuesta tipo OpenWeather para construir `WeatherData`.

### Notificaciones locales
`NotificationManager` solicita permisos, define categorías y agenda notificaciones únicamente para riesgo **alto**, aplicando throttling (30 minutos).

### Video background (AVKit)
`WeatherVideoBackgroundView` usa `AVPlayerLayer` en un `UIViewRepresentable` para reproducir loops cortos dependiendo del clima (y “día/noche” por sunrise/sunset).

## 5) Modelo de Datos

### `WeatherData` (`MosquitOFF/Models/WeatherData.swift`)
Representa el estado de clima relevante para el scoring:
- `temperature`, `humidity`, `condition`.
- `precipitation`, `windSpeed`.
- `sunrise`, `sunset`.

### `RiskZone` (`MosquitOFF/Models/RiskZone.swift`)
- `coordinate`: centro de la zona.
- `riskLevel`: `MosquitoRisk.RiskLevel`.

### `MosquitoRisk` (`MosquitOFF/Utils/MosquitoRisk.swift`)
- Enum `RiskLevel`: `.low/.medium/.high` con labels en español.
- `calculateRisk(from:)`: heurística basada en temperatura/humedad, ajustada por lluvia y viento.

## 6) Arquitectura y Flujo General

La app sigue un MVVM “simple”:

### 6.1 `HomeView` → `WeatherViewModel`
- `HomeView` (`MosquitOFF/Views/HomeView.swift`) es la pantalla principal.
- Observa `WeatherViewModel` para:
  - clima actual (`weather`)
  - estado de permisos (`authorizationStatus`)
  - errores de red (`hasNetworkError`)
- Gestiona pantallas de fallback (sin red / sin ubicación), intro (`@AppStorage("hasSeenIntro")`) y sheets de info.

### 6.2 `WeatherViewModel` orquesta ubicación + clima + notificaciones
`WeatherViewModel` (`MosquitOFF/ViewModels/WeatherViewModel.swift`):
- Se suscribe a `LocationManager.$location` y dispara `fetchWeather(lat:lon:)`.
- Implementa timeout (10s) para detectar que no llegó respuesta.
- Calcula `mosquitoRisk` a partir de `WeatherData`.
- Envía notificación cuando cambia el riesgo y llega a **alto** (throttling en `NotificationManager`).

### 6.3 Mapa: `HeatMapView` → `HeatMapViewModel` → `StaticHeatMapView`
- `HeatMapView` (`MosquitOFF/Views/HeatMapView.swift`) define zonas (parques/islas) como coordenadas.
- `HeatMapViewModel.fetchRiskZones(for:)` consulta clima para cada punto y promedia el riesgo por zona.
- `StaticHeatMapView` (`MosquitOFF/Views/StaticHeatMapView.swift`) renderiza:
  - overlays circulares coloreados por riesgo
  - anotaciones con nombre
  - user location

## 7) Features (qué hace la app y dónde vive)

### 7.1 Riesgo en tu ubicación
- UI: `HomeView`.
- Datos: `WeatherViewModel.weather`.
- Scoring: `MosquitoRisk.calculateRisk`.
- Visual: cards (`WeatherInfoCard`) + animación (`MosquitoAnimationView`) + fondo por clima (`WeatherVideoBackgroundView`).

### 7.2 Mapa de riesgo (Rosario)
- UI: `HeatMapView` y `StaticHeatMapView`.
- Zonas: parques/islas hardcodeadas en `HeatMapView`.
- Render: `MKCircle` overlays con alpha + markers distintos para islas/parques.

### 7.3 Notificaciones
- Config: `SettingsView` toggles `notificationsEnabled`.
- Lógica: `NotificationManager`.
- Regla principal: notificar solo si riesgo **alto**.

### 7.4 Manejo de errores de red y permisos
- Red: `NetworkMonitor` (`NWPathMonitor`) + `hasNetworkError` en `WeatherViewModel`.
- Ubicación: `LocationManager` + pantallas dedicadas en `HomeView`.

## 8) Networking: endpoint, decode y resiliencia

- Endpoint: `https://mosquito-risk.vercel.app/api/weather?lat=...&lon=...` (`WeatherService`).
- Decoding: `OpenWeatherResponse` → `WeatherData`.
- Resiliencia:
  - validación HTTP (2xx)
  - timeout (10s) en `WeatherViewModel`
  - fallback UI si no hay conectividad (vía `NetworkMonitor`)

Nota importante para mantenimiento: conviene verificar/normalizar **unidades** (temperatura, viento, precipitación) en el proxy o en la app para que el scoring sea consistente.

## 9) Testing

Unit tests (XCTest):
- `MosquitOFFTests/MosquitoRiskTest.swift`: casos para `calculateRisk`.
- `MosquitOFFTests/WeatherViewModelTest.swift`: propiedades publicadas, `riskColor`, `weatherVideoName` y comportamiento básico de estado.

## 10) Mejoras futuras (técnicas y de producto)

- Cache con TTL por coordenada (reduce requests al heatmap y al home).
- Separar configuración de zonas (JSON/plist/back-end) para no hardcodear coordenadas en la vista.
- Pasar el heatmap a `async/await` (TaskGroup) para simplificar `DispatchGroup` + `NSLock`.
- Observabilidad: reemplazar `print` por `Logger` y errores tipados.
- Validación de modelo: documentar “qué significa” el riesgo (heurístico) y permitir ajustar thresholds por temporada.
