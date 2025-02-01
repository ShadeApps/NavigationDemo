//
//  NetworkManager.swift
//  NavigationDemo
//
//  Created by Sergey Grishchev on 01/02/2025.
//

import Foundation

protocol NetworkManagerProtocol {
    func fetchQuotes(origin: Int, destination: Int, departureDateFrom: String, departureDateTo: String) async throws -> Quote
    func fetchTrip(tripId: String) async throws -> Trip
}

protocol NetworkSession {
    func data(for request: URLRequest) async throws -> (Data, URLResponse)
}

extension URLSession: NetworkSession {}

struct Quote: Codable {}

struct Trip: Codable {}

struct QuoteRequestParams: Codable {
    let origin: Int
    let destination: Int
    let departure_date_from: String
    let departure_date_to: String
}

class NetworkManager: NetworkManagerProtocol {
    private let session: NetworkSession

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
                     departureDateFrom: String = "2025-01-28T00:00:00Z",
                     departureDateTo: String = "2025-01-28T23:59:59Z") async throws -> Quote {
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

        let request = URLRequest(url: url)
        let (data, response) = try await session.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw URLError(.badServerResponse)
        }

        let decoder = JSONDecoder()
        return try decoder.decode(Quote.self, from: data)
    }

    func fetchTrip(tripId: String) async throws -> Trip {
        let url = baseURL.appendingPathComponent("trips/\(tripId)/")
        let request = URLRequest(url: url)
        let (data, response) = try await session.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw URLError(.badServerResponse)
        }

        let decoder = JSONDecoder()
        return try decoder.decode(Trip.self, from: data)
    }
}
