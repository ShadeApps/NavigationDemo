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
        Button("Load quotes") {
            Task {
                try? await viewModel.loadQuotes()
            }
        }
        .frame(maxWidth: .infinity, alignment: .center)
    }
}

#Preview {
    ContentView(viewModel: ContentViewViewModel(networkManager: NetworkManager()))
}
