//
//  MapView.swift
//  NavigationDemo
//
//  Created by Sergey Grishchev on 20/02/2025.
//

import SwiftUI
import MapKit
import CoreLocation

struct MapView: View {
    let quotes: [Quote]
    @State private var selectedQuote: Quote?
    @State private var region: MKCoordinateRegion
    @StateObject private var locationManager = LocationManager()
    
    init(quotes: [Quote], centerOnQuote: Quote? = nil) {
        self.quotes = quotes
        
        // Center on the provided quote, or first quote, or default to 0,0
        let initialQuote = centerOnQuote ?? quotes.first
        let latitude = initialQuote?.legs.first?.origin.lat ?? 0
        let longitude = initialQuote?.legs.first?.origin.lon ?? 0
        
        _region = State(initialValue: MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: latitude, longitude: longitude),
            span: MKCoordinateSpan(latitudeDelta: 0.5, longitudeDelta: 0.5)
        ))
    }
    
    var body: some View {
        Map(coordinateRegion: $region, showsUserLocation: true, annotationItems: quotes) { quote in
            MapAnnotation(coordinate: CLLocationCoordinate2D(
                latitude: quote.legs.first?.origin.lat ?? 0,
                longitude: quote.legs.first?.origin.lon ?? 0
            )) {
                Image(systemName: "mappin.circle.fill")
                    .foregroundColor(.red)
                    .onTapGesture {
                        selectedQuote = quote
                    }
            }
        }
        .sheet(item: $selectedQuote) { quote in
            QuoteDetailView(quote: quote)
        }
        .onChange(of: locationManager.location) { location in
            if let location = location {
                region.center = location.coordinate
            }
        }
    }
}

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
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

struct QuoteDetailView: View {
    let quote: Quote
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            List {
                Section("Route") {
                    ForEach(quote.legs, id: \.tripUid) { leg in
                        VStack(alignment: .leading) {
                            Text(leg.origin.name)
                            Text("↓")
                            Text(leg.destination.name)
                        }
                    }
                }
                
                if let prices = quote.prices.adult {
                    Section("Price") {
                        Text("Adult: \(prices)")
                    }
                }
                
                if let seats = quote.availability.seat {
                    Section("Availability") {
                        Text("Seats: \(seats)")
                    }
                }
            }
            .navigationTitle("Quote Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                Button("Close") {
                    dismiss()
                }
            }
        }
    }
}
