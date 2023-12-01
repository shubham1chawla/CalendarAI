//
//  HistoryView.swift
//  CalendarAI
//
//  Created by Himanshu Sharma on 11/29/23.
//

import SwiftUI

struct HistoryView: View {
    @FetchRequest(sortDescriptors: [NSSortDescriptor(key: "timestamp", ascending: false)]) var userSessions: FetchedResults<UserSession>
    
    var body: some View {
        NavigationStack {
            List(userSessions, id: \.uuid) { userSession in
                NavigationLink {
                    SummaryView(userSession: userSession)
                } label: {
                    Image(systemName: "clock.arrow.circlepath")
                    Text(userSession.timestamp!.asTimeAgoFormatted())
                }
            }
        }
        .navigationTitle("History")
    }
    
}

