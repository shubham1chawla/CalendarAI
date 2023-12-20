//
//  DateUtils.swift
//  WellnessAI
//
//  Created by Shubham Chawla on 12/20/23.
//

import Foundation

func standardFormat(date: Date?) -> String {
    return date?.formatted() ?? ""
}

func timeAgoFormat(date: Date?) -> String {
    guard let date = date else { return "" }
    let formatter = RelativeDateTimeFormatter()
    formatter.unitsStyle = .full
    return formatter.localizedString(for: date, relativeTo: Date())
}
