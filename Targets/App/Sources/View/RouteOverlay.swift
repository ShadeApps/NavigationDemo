//
//  RouteOverlay.swift
//  NavigationDemo
//
//  Created by Sergey Grishchev on 20/02/2025.
//

import MapKit

struct RouteOverlay: Identifiable {
    let id = UUID()
    let coordinates: [CLLocationCoordinate2D]
}
