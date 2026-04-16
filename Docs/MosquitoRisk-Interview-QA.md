# MosquitoRisk (iOS) Interview Q&A

Documento orientado a entrevistas: preguntas y respuestas sobre **cómo funciona** MosquitoRisk, su arquitectura y decisiones técnicas. Complementa el documento: `Docs/MosquitoRisk-DeepDive.md`.

Estado: **versión 1.1.1** (MARKETING_VERSION `1.1.1`, build `5`). Deployment target iOS `17.6`.

## 1) Elevator Pitch

**Q: Explicá MosquitoRisk en 20-30 segundos.**  
A: MosquitoRisk es una app iOS en SwiftUI que estima el riesgo de mosquitos en Rosario usando clima (temperatura/humedad/lluvia/viento) y ubicación del usuario. Muestra el riesgo con una UI visual (cards, fondo por clima, animaciones), envía notificaciones locales cuando el riesgo es alto, y ofrece un mapa interactivo con zonas (parques/islas) renderizadas con overlays de MapKit.

**Q: Qué stack tecnológico usa?**  
A: SwiftUI + MVVM, Combine para bindings (`@Published`), CoreLocation para ubicación, MapKit para mapa/overlays, URLSession para API REST + JSON decoding, UserNotifications para notificaciones locales, NWPathMonitor para conectividad, AVKit para video background y Lottie para animaciones.

## 2) Arquitectura y Separación de Responsabilidades

**Q: Cómo se organiza la app?**  
A: En capas simples: Views (SwiftUI), ViewModels (orquestan estado/side-effects), Services (network), Utils (riesgo, ubicación, red, notificaciones) y Models (WeatherData/RiskZone).

**Q: Cuál es el “single source of truth” para la UI principal?**  
A: `WeatherViewModel`: expone `@Published weather`, `authorizationStatus` y `hasNetworkError`, y de ahí derivan `mosquitoRisk`, `riskColor` y `weatherVideoName`.

**Q: Cómo se conecta ubicación con clima?**  
A: `WeatherViewModel` se suscribe a `LocationManager.$location`, guarda la última coordenada y dispara `WeatherService.fetchWeather(lat:lon:)`. Con el `WeatherData` resultante calcula el riesgo.

## 3) Modelo de Riesgo

**Q: Cómo se calcula el riesgo?**  
A: Es un scoring heurístico en `MosquitoRisk.calculateRisk(from:)` basado en rangos de temperatura y humedad, con ajustes por lluvia (sube riesgo) y viento (reduce riesgo, con “override” a bajo si es muy fuerte).

**Q: Qué tradeoffs tiene este modelo?**  
A: Es simple y explicable, pero depende de calidad/unidades de datos y no incorpora variables epidemiológicas (criaderos, densidad, casos, estacionalidad completa). Se compensa con transparencia (explicar factores) y validación iterativa.

## 4) MapKit y Heatmap

**Q: Por qué usar `UIViewRepresentable` con `MKMapView` en lugar del `Map` de SwiftUI?**  
A: Para renderizar overlays (`MKCircle`) con un renderer (`MKCircleRenderer`) y customizar anotaciones/markers con más control. SwiftUI `Map` es útil para preview, pero overlays avanzados son más directos con `MKMapView`.

**Q: Cómo se construyen las zonas del mapa?**  
A: `HeatMapView` define coordenadas por zona (parques/islas). `HeatMapViewModel` consulta clima para cada punto y promedia el riesgo, usando el centro de las coordenadas como ubicación de la zona.

**Q: Qué problema de performance podés anticipar?**  
A: Muchas requests en paralelo (varios puntos por zona). Una mejora natural es cache con TTL por coordenada y/o limitar concurrencia (TaskGroup + rate limiting).

## 5) Resiliencia (red/permisos)

**Q: Qué pasa si el usuario niega ubicación?**  
A: La UI muestra una pantalla dedicada (full-screen) y ofrece botón para abrir Ajustes del sistema. La app evita quedar en “loading” infinito.

**Q: Qué pasa si no hay internet o falla el endpoint?**  
A: `NetworkMonitor` detecta desconexión y `WeatherViewModel` tiene timeout de 10 segundos + flag `hasNetworkError`. `HomeView` presenta una pantalla de fallback y un botón de reintento.

## 6) Notificaciones

**Q: Cuándo se notifica al usuario?**  
A: Solo cuando el riesgo pasa a **alto**. `NotificationManager` aplica throttling de 30 minutos y revalida permiso del sistema.

**Q: Cómo se permite apagar notificaciones desde la app?**  
A: `SettingsView` usa `@AppStorage("notificationsEnabled")`. Si se desactiva, se limpian notificaciones pendientes/entregadas.

## 7) Testing

**Q: Qué testearías y qué ya está testeado?**  
A: Ya hay unit tests para el cálculo de riesgo y para `WeatherViewModel` (colores, video name, estado inicial, `@Published`). Próximo paso: tests de `WeatherService` con mocks (URLProtocol) y tests de concurrencia/caching.

## 8) Preguntas “de Senior” (para lucirte)

**Q: Qué mejorarías sin cambiar la UI?**  
A: Normalizar unidades (viento/lluvia) en un solo lugar, introducir cache con TTL, convertir `HeatMapViewModel` a `async/await`, y reemplazar `print` por `Logger`.

**Q: Qué riesgo técnico ves en apps con scoring “de salud”?**  
A: Evitar claims médicos: el scoring debe presentarse como estimación, con explicación de factores, y con disclaimers. Además, se debe ser cuidadoso con privacidad (ubicación) y con consistencia de datos.
