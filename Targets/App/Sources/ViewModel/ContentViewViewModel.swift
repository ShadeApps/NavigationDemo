//
//  ContentViewViewModel.swift
//  NavigationDemo
//
//  Created by Sergey Grishchev on 16/02/2025.
//

import Foundation

protocol ContentViewViewModelProtocol: ObservableObject {
    var state: ContentViewViewModel.State { get }
    func loadQuotes() async
}

final class ContentViewViewModel: ContentViewViewModelProtocol {
    enum State {
        case idle
        case loading
        case error(Error)
        case loaded(Trip)
    }

    @Published private(set) var state: State = .idle
    private let networkManager: NetworkManagerProtocol

    init(networkManager: NetworkManagerProtocol) {
        self.networkManager = networkManager
    }

    @MainActor
    func loadQuotes() async {
        state = .loading
        do {
            let now = Date()
            var departureFrom = now.addingTimeInterval(30 * 60)
            var departureTo = now.endOfDay

            // If less than 1 hour remaining today, load tomorrow's data
            if departureTo.timeIntervalSince(departureFrom) < 3600 {
                let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: now) ?? now
                departureFrom = Calendar.current.startOfDay(for: tomorrow)
                departureTo = departureFrom.endOfDay
            }

            let quotesResponse = try await networkManager.fetchQuotes(
                origin: 13,
                destination: 42,
                departureDateFrom: departureFrom.iso8601String,
                departureDateTo: departureTo.iso8601String
            )

            if let tripId = quotesResponse.quotes.first?.legs.first?.tripUid {
                let trip = try await networkManager.fetchTrip(tripId: tripId)
                state = .loaded(trip)
            } else {
                throw URLError(.cannotFindHost)
            }
        } catch {
            state = .error(error)
        }
    }
}

