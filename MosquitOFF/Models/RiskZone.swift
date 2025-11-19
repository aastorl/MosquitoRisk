//
//  RiskZone.swift
// 
//
//  Created by Astor Ludueña  on 03/06/2025.
//

import Foundation
internal import CoreLocation
import SwiftUI

struct RiskZone: Identifiable {
    let id = UUID()
    let coordinate: CLLocationCoordinate2D
    let riskLevel: MosquitoRisk.RiskLevel
}
