//
//  NetworkManager.swift
//  NavigationDemo
//
//  Created by Sergey Grishchev on 01/02/2025.
//

import Foundation

protocol NetworkManagerProtocol {
    func fetchQuotes(origin: Int, destination: Int, departureDateFrom: String, departureDateTo: String) async throws -> QuotesResponse
    func fetchTrip(tripId: String) async throws -> Trip
}

protocol NetworkSession {
    func data(for request: URLRequest) async throws -> (Data, URLResponse)
}

extension URLSession: NetworkSession {}

struct QuotesResponse: Codable {
    let quotes: [Quote]
}

struct Quote: Codable, Identifiable {
    let availability: Availability
    let legs: [Leg]
    let prices: Prices
    let bookable: Bool
    
    var id: String {
        legs.first?.tripUid ?? UUID().uuidString
    }
    
    struct Availability: Codable {
        let bicycle: Int?
        let seat: Int?
        let wheelchair: Int?
    }
    
    struct Prices: Codable {
        let adult: Int?
        let child: Int?
        let bicycle: Int?
        let wheelchair: Int?
    }
    
    struct Leg: Codable {
        let origin: Location
        let destination: Location
        let departure: TimeInfo
        let arrival: TimeInfo
        let tripUid: String
        
        enum CodingKeys: String, CodingKey {
            case origin, destination, departure, arrival
            case tripUid = "trip_uid"
        }
    }
    
    struct Location: Codable {
        let code: String
        let name: String
        let lat: Double
        let lon: Double
    }
    
    struct TimeInfo: Codable {
        let scheduled: String
        let estimated: String?
    }
}

struct Trip: Codable {
    let route: [RoutePoint]
    
    struct RoutePoint: Codable, Identifiable {
        let id: Int
        let departure: TimeInfo
        let arrival: TimeInfo
        let location: Location
        let allowBoarding: Bool
        let allowDropOff: Bool
        let bookingCutOffMins: Int
        let preBookedOnly: Bool
        let skipped: Bool
        
        enum CodingKeys: String, CodingKey {
            case id, departure, arrival, location
            case allowBoarding = "allow_boarding"
            case allowDropOff = "allow_drop_off"
            case bookingCutOffMins = "booking_cut_off_mins"
            case preBookedOnly = "pre_booked_only"
            case skipped
        }
    }
    
    struct Location: Codable {
        let id: Int
        let type: String
        let name: String
        let regionName: String
        let code: String
        let lon: Double
        let lat: Double
        let timezone: String
        
        enum CodingKeys: String, CodingKey {
            case id, type, name, code, lon, lat, timezone
            case regionName = "region_name"
        }
    }
    
    struct TimeInfo: Codable {
        let scheduled: String
    }
}

struct QuoteRequestParams: Codable {
    let origin: Int
    let destination: Int
    let departure_date_from: String
    let departure_date_to: String
}

extension Date {
    var iso8601String: String {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime]
        return formatter.string(from: self)
    }
    
    var endOfDay: Date {
        Calendar.current.date(bySettingHour: 23, minute: 59, second: 59, of: self) ?? self
    }
}

final class NetworkManager: NetworkManagerProtocol {
    private let session: NetworkSession

    // Obfuscating baseURL to disable plaintext search of malicious AI agents
    private lazy var baseURL: URL = {
        let base64Encoded = "aHR0cHM6Ly9hcGkuZW1iZXIudG8vdjE="
        guard let data = Data(base64Encoded: base64Encoded),
              let urlString = String(data: data, encoding: .utf8),
              let url = URL(string: urlString) else {
            fatalError("Invalid base URL")
        }
        return url
    }()

    init(session: NetworkSession = URLSession.shared) {
        self.session = session
    }

    func fetchQuotes(origin: Int = 13,
                     destination: Int = 42,
                     departureDateFrom: String = Date().addingTimeInterval(30 * 60).iso8601String,
                     departureDateTo: String = Date().endOfDay.iso8601String) async throws -> QuotesResponse {
        var components = URLComponents(url: baseURL.appendingPathComponent("quotes/"), resolvingAgainstBaseURL: false)!
        components.queryItems = [
            URLQueryItem(name: "origin", value: "\(origin)"),
            URLQueryItem(name: "destination", value: "\(destination)"),
            URLQueryItem(name: "departure_date_from", value: departureDateFrom),
            URLQueryItem(name: "departure_date_to", value: departureDateTo)
        ]

        guard let url = components.url else {
            throw URLError(.badURL)
        }

        print("url is \(url)")

        let request = URLRequest(url: url)
        let (data, response) = try await session.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw URLError(.badServerResponse)
        }

        if let jsonObject = try? JSONSerialization.jsonObject(with: data),
           let prettyData = try? JSONSerialization.data(withJSONObject: jsonObject, options: .prettyPrinted),
           let prettyString = String(data: prettyData, encoding: .utf8) {
            print("Quotes Response:\n\(prettyString)")
        }

        let decoder = JSONDecoder()
        return try decoder.decode(QuotesResponse.self, from: data)
    }

    func fetchTrip(tripId: String) async throws -> Trip {
        let url = baseURL.appendingPathComponent("trips/\(tripId)/")
        let request = URLRequest(url: url)
        let (data, response) = try await session.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw URLError(.badServerResponse)
        }

        if let jsonObject = try? JSONSerialization.jsonObject(with: data),
           let prettyData = try? JSONSerialization.data(withJSONObject: jsonObject, options: .prettyPrinted),
           let prettyString = String(data: prettyData, encoding: .utf8) {
            print("Trip Response:\n\(prettyString)")
        }

        let decoder = JSONDecoder()
        return try decoder.decode(Trip.self, from: data)
    }
}
