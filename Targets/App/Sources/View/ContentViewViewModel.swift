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
        case loaded([Quote])
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
            let departureFrom = Date().addingTimeInterval(30 * 60)
            let departureTo = Date().endOfDay

            let response = try await networkManager.fetchQuotes(
                origin: 13,
                destination: 42,
                departureDateFrom: departureFrom.iso8601String,
                departureDateTo: departureTo.iso8601String
            )
            print("response.quotes.first?.price: \(response.quotes.first?.legs.first?.tripUid ?? "nil")")
            state = .loaded(response.quotes)
        } catch {
            state = .error(error)
        }
    }
}
