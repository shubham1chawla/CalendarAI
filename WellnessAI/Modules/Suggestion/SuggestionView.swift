//
//  SuggestionView.swift
//  WellnessAI
//
//  Created by Shubham Chawla on 12/16/23.
//

import SwiftUI

struct SuggestionView: View {

    let suggestion: Suggestion
    let dateFormatter: (Date?) -> String
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Image(systemName: "clock")
                Text(dateFormatter(suggestion.userSession?.timestamp))
            }
            .font(.caption)
            .padding()
            HStack {
                Text(suggestion.content ?? "Unable to present suggestion's content!")
            }
            .font(.headline)
            .frame(maxWidth: .infinity)
            .padding()
            VStack(spacing: 8) {
                HStack {
                    Image(systemName: "slider.horizontal.3")
                    Text("Fine-tune Parameters")
                }
                ForEach(suggestion.parameters?.allObjects as! [FineTuneParameter]) { parameter in
                    HStack {
                        Image(systemName: parameter.icon!)
                        Text(parameter.label!)
                        Spacer()
                        Text(parameter.value!)
                    }
                }
            }
            .font(.subheadline)
            .padding()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 4))
    }
}

