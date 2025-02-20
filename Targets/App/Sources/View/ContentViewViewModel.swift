//
//  ContentViewViewModel.swift
//  NavigationDemo
//
//  Created by Sergey Grishchev on 16/02/2025.
//

import Foundation

protocol ContentViewViewModelProtocol: ObservableObject {
    func loadQuotes() async throws
}

@MainActor
final class ContentViewViewModel: ContentViewViewModelProtocol {
    private let networkManager: NetworkManagerProtocol
    
    init(networkManager: NetworkManagerProtocol) {
        self.networkManager = networkManager
    }
    
    func loadQuotes() async throws {
        let departureFrom = Date().addingTimeInterval(30 * 60)
        let departureTo = Date().endOfDay
        
        let response = try await networkManager.fetchQuotes(
            origin: 13,
            destination: 42,
            departureDateFrom: departureFrom.iso8601String,
            departureDateTo: departureTo.iso8601String
        )

        print("quotes are: \(response.quotes)")
        // Handle quotes data here
    }
}

