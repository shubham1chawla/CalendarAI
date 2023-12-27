//
//  Extensions.swift
//  WellnessAI
//
//  Created by Shubham Chawla on 12/21/23.
//

import SwiftUI
import CoreData

extension View {
    
    func snapshot() -> UIImage {
        let controller = UIHostingController(rootView: self)
        let view = controller.view
    
        let format = UIGraphicsImageRendererFormat()
        format.scale = 1
        format.opaque = true
            
        let targetSize = controller.view.intrinsicContentSize
        view?.bounds = CGRect(origin: .zero, size: targetSize)
        view?.backgroundColor = .clear
            
        let window = UIWindow(frame: view!.bounds)
        window.addSubview(controller.view)
        window.makeKeyAndVisible()
            
        let renderer = UIGraphicsImageRenderer(bounds: view!.bounds, format: format)
        return renderer.image { rendererContext in
            view?.layer.render(in: rendererContext.cgContext)
        }
    }
    
}

extension Date {
    
    func formatted(relativeTo: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .full
        return formatter.localizedString(for: self, relativeTo: relativeTo)
    }
    
}

extension UserSession {
    
    static func fetchCurrentRequest() -> NSFetchRequest<UserSession> {
        let uuid = UserDefaults.standard.string(forKey: Keys.LAST_USER_SESSSION)
        if (uuid ?? "").isEmpty { fatalError("No user session was set!") }
        let request = UserSession.fetchRequest()
        request.predicate = NSPredicate(format: "uuid CONTAINS %@", uuid!)
        return request
    }
    
    static func fetchWithHealthRequest() -> NSFetchRequest<UserSession> {
        let request = UserSession.fetchRequest()
        request.predicate = NSPredicate(format: "userMeasurement != nil || userSymptoms.@count > 0")
        request.sortDescriptors = [NSSortDescriptor(key: "timestamp", ascending: false)]
        return request
    }
    
    static func fetchWithWeatherRequest() -> NSFetchRequest<UserSession> {
        let request = UserSession.fetchRequest()
        request.predicate = NSPredicate(format: "weather != nil")
        request.sortDescriptors = [NSSortDescriptor(key: "timestamp", ascending: false)]
        return request
    }
    
}

extension Symptom {
    
    static func fetchRequest(forId: Int16) -> NSFetchRequest<Symptom> {
        let request = Symptom.fetchRequest()
        request.predicate = NSPredicate(format: "id == %i", forId)
        return request
    }
    
}
