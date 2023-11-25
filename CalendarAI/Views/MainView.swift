//
//  MainView.swift
//  CalendarAI
//
//  Created by Shubham Chawla on 11/22/23.
//

import SwiftUI

enum ApplicationTab: String, CaseIterable, View {
    case assistant
    case health
    case calendar
    
    public var icon: String {
        switch self {
        case .assistant:
            return "wand.and.stars"
        case .health:
            return "heart"
        case .calendar:
            return "calendar"
        }
    }
    
    public var label: String {
        return self.rawValue.capitalized
    }
    
    public var body: some View {
        switch self {
        case .assistant:
            AssistantView()
        case .health:
            HealthView()
        case .calendar:
            CalendarView()
        }
    }
}

struct MainView: View {
    @State var selectedTab: ApplicationTab = .assistant
    
    var body: some View {
        TabView(selection: $selectedTab) {
            ForEach(ApplicationTab.allCases, id:\.rawValue) { tab in
                NavigationView {
                    tab.navigationTitle(tab.label)
                }.tabItem {
                    Label(tab.label, systemImage: tab.icon)
                }
            }
        }
    }
}

#Preview {
    MainView()
}
