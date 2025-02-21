//
//  ContentView.swift
//  NavigationDemo
//
//  Created by Sergey Grishchev on 01/02/2025.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel: ContentViewViewModel
    @Environment(\.dismiss) private var dismiss

    init(viewModel: ContentViewViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        ZStack {
            switch viewModel.state {
            case .idle, .loading:
                ProgressView()
            case .error(let error):
                VStack(spacing: 16) {
                    Text(error.localizedDescription)
                        .foregroundColor(.red)
                        .multilineTextAlignment(.center)

                    Button(action: {
                        Task {
                            await viewModel.loadQuotes()
                        }
                    }) {
                        Label("Try Again", systemImage: "arrow.clockwise")
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.accentColor)
                            .cornerRadius(8)
                    }
                }
                .padding()
            case .loaded(let trip):
                MapView(trip: trip, busLocation: viewModel.busLocation)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .ignoresSafeArea()
        .requireCapabilityPermission(of: .locationAccess) {
            // On successful permission granted
            Task {
                await viewModel.loadQuotes()
            }
        } onCancel: {
            dismiss()

            Task {
                await viewModel.loadQuotes()
            }
        }
    }
}

#Preview {
    ContentView(viewModel: ContentViewViewModel(networkManager: NetworkManager()))
}
