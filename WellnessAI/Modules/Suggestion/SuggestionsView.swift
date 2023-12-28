//
//  SuggestionsView.swift
//  WellnessAI
//
//  Created by Shubham Chawla on 12/16/23.
//

import SwiftUI

struct SuggestionsView: View {
    
    @Environment(\.managedObjectContext) var context
    @StateObject private var viewModel = ViewModel()
    
    var body: some View {
        HStack {
            Image(systemName: "wand.and.stars")
            Text("AI Notifications")
        }
        .font(.subheadline)
        ScrollView(.horizontal, showsIndicators: false) {
            HStack {
                if viewModel.isError {
                    ErrorSuggestionCardView(errorMessage: viewModel.errorMessage).frame(width: 300)
                } else if viewModel.isUpdatingSuggestions {
                    LoadingSuggestionCardView().frame(width: 300)
                } else {
                    ForEach(viewModel.suggestions) { suggestion in
                        SuggestionView(suggestion: suggestion, dateFormatter: { $0?.formatted(relativeTo: Date.now) ?? "" })
                    }
                    .frame(width: 300)
                }
            }
            .fixedSize(horizontal: false, vertical: /*@START_MENU_TOKEN@*/true/*@END_MENU_TOKEN@*/)
        }
        .padding(EdgeInsets(
            top: 8, leading: 0, bottom: 8, trailing: 0
        ))
        .onAppear {
            viewModel.refreshSuggestions(context: context)
        }
    }
}
