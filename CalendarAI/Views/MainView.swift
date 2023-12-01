//
//  MainView.swift
//  CalendarAI
//
//  Created by Shubham Chawla on 11/22/23.
//

import SwiftUI

enum ApplicationTab: String, CaseIterable, View {
    case assistant
    case calendar
    case health
    
    public var icon: String {
        switch self {
        case .assistant:
            return "wand.and.stars"
        case .calendar:
            return "calendar"
        case .health:
            return "heart"
        }
    }
    
    public var label: String {
        return self.rawValue.capitalized
    }
    
    public var body: some View {
        switch self {
        case .assistant:
            AssistantView()
        case .calendar:
            CalendarView()
        case .health:
            HealthView()
        }
    }
}

struct MainView: View {
    var body: some View {
        TabView {
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
