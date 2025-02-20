//
//  ContentView.swift
//  NavigationDemo
//
//  Created by Sergey Grishchev on 01/02/2025.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel: ContentViewViewModel
    
    init(viewModel: ContentViewViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        ZStack {
            switch viewModel.state {
            case .idle, .loading:
                ProgressView()
            case .error(let error):
                Text(error.localizedDescription)
                    .foregroundColor(.red)
                    .multilineTextAlignment(.center)
                    .padding()
            case .loaded(let quotes):
                MapView(quotes: quotes, centerOnQuote: quotes.first)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .requireCapabilityPermission(of: .locationAccess) {
            // On successful permission granted
            Task {
                await viewModel.loadQuotes()
            }
        } onCancel: {
            // On permission denied
            // Probably add error to logs, no need to bother the user
        }
        .task {
            await viewModel.loadQuotes()
        }
    }
}

#Preview {
    ContentView(viewModel: ContentViewViewModel(networkManager: NetworkManager()))
}
