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
        @Published private(set) var intensities: [Int:String] = [:]
        
        func setNSManagedObjectContext(_ context: NSManagedObjectContext? = nil) {
            self.context = context
            
            // Loading user sessions from database
            loadUserSessions()
            
            // Preparing intensity map
            let decodableIntensities: [DecodableIntensity] = decodeJson(forResource: "intensities")
            for decodableIntensity in decodableIntensities {
                intensities[decodableIntensity.value] = decodableIntensity.label
            }
        }
        
        private func loadUserSessions() -> Void {
            guard let context = context else { return }
            
            let request = UserSession.fetchRequest()
            request.sortDescriptors = [NSSortDescriptor(key: "timestamp", ascending: false)]
            
            var userSessions: [UserSession] = []
            for userSession in try! context.fetch(request) {
                userSessions.append(userSession)
            }
            self.userSessions = userSessions
        }
        
    }
}
