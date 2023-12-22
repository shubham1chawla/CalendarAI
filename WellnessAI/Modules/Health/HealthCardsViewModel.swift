//
//  HealthCardsViewModel.swift
//  WellnessAI
//
//  Created by Shubham Chawla on 12/19/23.
//

import Foundation
import CoreData

extension HealthCardsView {
    @MainActor class ViewModel: ObservableObject {
        
        private var context: NSManagedObjectContext?
        private let defaults = UserDefaults.standard
        
        @Published private(set) var userSessions: [UserSession] = []
        
        func setup(context: NSManagedObjectContext) {
            self.context = context
            
            // Loading user sessions from database
            loadUserSessions()
        }
        
        private func loadUserSessions() -> Void {
            guard let context = context else { return }
            
            let request = UserSession.fetchRequest()
            request.predicate = NSPredicate(format: "userMeasurement != nil || userSymptoms.@count > 0")
            request.sortDescriptors = [NSSortDescriptor(key: "timestamp", ascending: false)]
            
            var userSessions: [UserSession] = []
            for userSession in try! context.fetch(request) {
                userSessions.append(userSession)
            }
            self.userSessions = userSessions
        }
        
    }
}
