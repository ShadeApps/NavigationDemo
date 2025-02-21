//
//  MapView.swift
//  NavigationDemo
//
//  Created by Sergey Grishchev on 20/02/2025.
//

import SwiftUI
import MapKit

struct MapView: View {
    let trip: Trip
    let busLocation: CLLocationCoordinate2D?
    @State private var selectedPoint: Trip.RoutePoint?
    @State private var selectedVehicle: Trip.Vehicle?
    @State private var region: MKCoordinateRegion
    @StateObject private var locationManager = LocationManager()

    init(trip: Trip, busLocation: CLLocationCoordinate2D? = nil) {
        self.trip = trip
        self.busLocation = busLocation
        
        let firstPoint = trip.route.first
        let initialLatitude = firstPoint?.location.lat ?? 0
        let initialLongitude = firstPoint?.location.lon ?? 0
        
        _region = State(initialValue: MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: initialLatitude, longitude: initialLongitude),
            span: MKCoordinateSpan(latitudeDelta: 0.5, longitudeDelta: 0.5)
        ))
    }

    var body: some View {
        UIKitMapView(
            trip: trip,
            region: $region,
            selectedPoint: $selectedPoint,
            selectedVehicle: $selectedVehicle
        )
        .sheet(item: $selectedPoint) { point in
            RoutePointDetailView(point: point)
        }
        .sheet(item: $selectedVehicle) { vehicle in
            BusDetailView(vehicle: vehicle)
        }
        .onChange(of: locationManager.location) { location in
            if let location = location {
                region.center = location.coordinate
            }
        }
        .onChange(of: busLocation) { newBusLocation in
            if let newBusLocation = newBusLocation {
                region.center = newBusLocation
                region.span = MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
            }
        }
    }
}

final class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let manager = CLLocationManager()
    @Published var location: CLLocation?
    
    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.startUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        location = locations.first
    }
}

struct RoutePointDetailView: View {
    let point: Trip.RoutePoint
    @Environment(\.dismiss) var dismiss
    
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter
    }()
    
    private func formatDate(_ iso8601String: String) -> String {
        guard let date = ISO8601DateFormatter().date(from: iso8601String) else {
            return iso8601String
        }
        return dateFormatter.string(from: date)
    }
    
    var body: some View {
        NavigationView {
            List {
                Section("Location") {
                    Text(point.location.name)
                    Text(point.location.regionName)
                }
                
                Section("Schedule") {
                    Text("Departure: \(formatDate(point.departure.scheduled))")
                    Text("Arrival: \(formatDate(point.arrival.scheduled))")
                }
                
                Section("Status") {
                    Text("Boarding: \(point.allowBoarding ? "Yes" : "No")")
                    Text("Drop-off: \(point.allowDropOff ? "Yes" : "No")")
                    if point.preBookedOnly {
                        Text("Pre-booking required")
                    }
                }
            }
            .navigationTitle("Stop Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                Button("Close") {
                    dismiss()
                }
            }
        }
    }
}

extension Array: @retroactive Identifiable where Element == CLLocationCoordinate2D {
    public var id: String {
        map { "\($0.latitude),\($0.longitude)" }.joined()
    }
}

// Make Vehicle Identifiable so it can be used with sheet
extension Trip.Vehicle: Identifiable { }

extension CLLocationCoordinate2D: @retroactive Equatable {
    public static func == (lhs: CLLocationCoordinate2D, rhs: CLLocationCoordinate2D) -> Bool {
        lhs.latitude == rhs.latitude && lhs.longitude == rhs.longitude
    }
}
