//
//  WellnessAIApp.swift
//  WellnessAI
//
//  Created by Shubham Chawla on 11/22/23.
//

import SwiftUI
import CoreData

@main
struct WellnessAIApp: App {
    
    let container = NSPersistentContainer(name: Keys.APPLICATION_NAME)
    
    init() {
        container.loadPersistentStores { description, error in
            if let error = error {
                fatalError(error.localizedDescription)
            }
        }
    }
    
    var body: some Scene {
        WindowGroup {
            AppView()
                .environment(\.managedObjectContext, container.viewContext)
        }
    }
}
