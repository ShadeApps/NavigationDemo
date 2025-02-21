//
//  UIKitMapView.swift
//  NavigationDemo
//
//  Created by Sergey Grishchev on 21/02/2025.
//

import SwiftUI
import MapKit
import CoreLocation

// Custom annotation subclass to store a Trip.RoutePoint.
class TripAnnotation: MKPointAnnotation {
    let routePoint: Trip.RoutePoint
    init(routePoint: Trip.RoutePoint) {
        self.routePoint = routePoint
        super.init()
        self.coordinate = CLLocationCoordinate2D(latitude: routePoint.location.lat,
                                                   longitude: routePoint.location.lon)
        self.title = routePoint.location.name
    }
}

// A UIViewRepresentable that wraps an MKMapView.
struct UIKitMapView: UIViewRepresentable {
    let trip: Trip
    @Binding var region: MKCoordinateRegion
    @Binding var selectedPoint: Trip.RoutePoint?

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView(frame: .zero)
        mapView.delegate = context.coordinator
        mapView.showsUserLocation = true
        mapView.setRegion(region, animated: false)
        return mapView
    }

    func updateUIView(_ mapView: MKMapView, context: Context) {
        // Update region if needed.
        mapView.setRegion(region, animated: true)

        // Clear old annotations and overlays.
        mapView.removeAnnotations(mapView.annotations)
        mapView.removeOverlays(mapView.overlays)

        // Add annotations for each route point.
        for point in trip.route {
            let annotation = TripAnnotation(routePoint: point)
            mapView.addAnnotation(annotation)
        }

        // Draw a polyline connecting the route points.
        let coordinates = trip.route.map {
            CLLocationCoordinate2D(latitude: $0.location.lat, longitude: $0.location.lon)
        }
        if !coordinates.isEmpty {
            let polyline = MKPolyline(coordinates: coordinates, count: coordinates.count)
            mapView.addOverlay(polyline)
        }
    }

    class Coordinator: NSObject, MKMapViewDelegate {
        var parent: UIKitMapView
        init(_ parent: UIKitMapView) {
            self.parent = parent
        }

        func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
            // Let the system handle the user location annotation.
            if annotation is MKUserLocation {
                return nil
            }
            let identifier = "TripAnnotationView"
            var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
            if annotationView == nil {
                annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: identifier)
                annotationView?.canShowCallout = true
            } else {
                annotationView?.annotation = annotation
            }
            if let tripAnnotation = annotation as? TripAnnotation {
                // Set the desired color based on allowBoarding.
                let color: UIColor = tripAnnotation.routePoint.allowBoarding ? .systemGreen : .systemRed
                if let image = UIImage(systemName: "mappin.circle.fill") {
                    // Use the extension to fill the image with the color.
                    annotationView?.image = image.fill(with: color)
                }
            }
            return annotationView
        }

        // Render the polyline overlay.
        func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
            if let polyline = overlay as? MKPolyline {
                let renderer = MKPolylineRenderer(polyline: polyline)
                renderer.strokeColor = .lightGray
                renderer.lineWidth = 3
                return renderer
            }
            return MKOverlayRenderer(overlay: overlay)
        }

        // When an annotation is selected, update the selectedPoint binding.
        func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
            if let tripAnnotation = view.annotation as? TripAnnotation {
                parent.selectedPoint = tripAnnotation.routePoint
            }
        }
    }
}

extension UIImage {
    /// Returns a copy of the image filled with the specified color.
    func fill(with color: UIColor) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(self.size, false, self.scale)
        guard let context = UIGraphicsGetCurrentContext(), let cgImage = self.cgImage else {
            return self
        }
        let rect = CGRect(origin: .zero, size: self.size)

        // Flip the image context vertically.
        context.translateBy(x: 0, y: self.size.height)
        context.scaleBy(x: 1.0, y: -1.0)

        // Draw the original image as a mask.
        context.setBlendMode(.normal)
        context.clip(to: rect, mask: cgImage)

        // Fill the clipped area with the color.
        color.setFill()
        context.fill(rect)

        let coloredImage = UIGraphicsGetImageFromCurrentImageContext() ?? self
        UIGraphicsEndImageContext()
        return coloredImage
    }
}
