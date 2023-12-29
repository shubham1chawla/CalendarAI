//
//  SuggestionsView.swift
//  WellnessAI
//
//  Created by Shubham Chawla on 12/16/23.
//

import SwiftUI

struct SuggestionsView: View {
    
    @ObservedObject var viewModel: ViewModel
    
    var body: some View {
        HStack {
            Image(systemName: "wand.and.stars")
            Text("AI Suggestions")
        }
        .font(.subheadline)
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(alignment: .top) {
                if viewModel.isError {
                    ErrorSuggestionCardView(errorMessage: viewModel.errorMessage).frame(width: 300)
                } else if viewModel.suggestions.isEmpty {
                    LoadingSuggestionCardView().frame(width: 300)
                } else {
                    if viewModel.isUpdatingSuggestions {
                        HStack(alignment: .center) {
                            ProgressView()
                        }
                        .frame(maxHeight: .infinity)
                        .controlSize(.large)
                        .padding()
                    }
                    ForEach(viewModel.suggestions) { suggestion in
                        SuggestionView(suggestion: suggestion, dateFormatter: { $0?.formatted(relativeTo: Date.now) ?? "" })
                    }
                    .frame(width: 300)
                }
                NavigationLink {
                    HistoricalSuggestionsCardView(viewModel: viewModel)
                } label: {
                    ViewHistoricalSuggestionsCardView()
                }
                .frame(width: 300)
            }
            .fixedSize(horizontal: false, vertical: true)
        }
        .padding(EdgeInsets(
            top: 8, leading: 0, bottom: 8, trailing: 0
        ))
    }
}
