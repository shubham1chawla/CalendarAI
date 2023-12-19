//
//  DateUtils.swift
//  WellnessAI
//
//  Created by Shubham Chawla on 12/20/23.
//

import Foundation

extension Date {
    
    // Formats time nicely for the UI
    func asTimeAgoFormatted() -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .full
        return formatter.localizedString(for: self, relativeTo: Date())
    }
    
}
