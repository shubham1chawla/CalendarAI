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
    var body: some View {
        TabView {
            ForEach(ApplicationTab.allCases, id:\.rawValue) { tab in
                tab.tabItem {
                    Label(tab.label, systemImage: tab.icon)
                }
            }
        }
    }
}

#Preview {
    MainView()
}
