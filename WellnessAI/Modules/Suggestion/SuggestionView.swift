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
                HStack {
                    Image(systemName: "clock")
                    Text(dateFormatter(suggestion.userSession?.timestamp))
                }
                Spacer()
                HStack {
                    Image(systemName: "tag")
                    Text(suggestion.source ?? "Unknown")
                }
            }
            .font(.caption)
            .padding()
            HStack {
                Text(suggestion.content ?? "Unable to present suggestion's content!")
            }
            .font(.headline)
            .frame(maxWidth: .infinity)
            .padding()
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Image(systemName: "slider.horizontal.3")
                    Text("Fine-tune Parameters")
                }
                .fontWeight(.bold)
                let parameters = suggestion.parameters?.allObjects as! [FineTuneParameter]
                if parameters.isEmpty {
                    Text("No fine-tune parameters recorded!")
                } else {
                    ForEach(parameters.sorted(by: { $0.label! < $1.label! })) { parameter in
                        HStack {
                            Image(systemName: parameter.icon)
                            Text(parameter.label!)
                            Spacer()
                            Text(parameter.value!)
                        }
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

