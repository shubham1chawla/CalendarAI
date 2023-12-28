//
//  Extensions.swift
//  WellnessAI
//
//  Created by Shubham Chawla on 12/21/23.
//

import SwiftUI
import CoreData
import EventKit

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
    
    static func getCurrentUUID() -> String {
        let uuid = UserDefaults.standard.string(forKey: Keys.LAST_USER_SESSSION)
        if (uuid ?? "").isEmpty { fatalError("No user session was set!") }
        return uuid!
    }
    
    static func fetchCurrentRequest() -> NSFetchRequest<UserSession> {
        return UserSession.fetchRequest(uuid: getCurrentUUID())
    }
    
    static func fetchRequest(uuid: String) -> NSFetchRequest<UserSession> {
        let request = UserSession.fetchRequest()
        request.predicate = NSPredicate(format: "uuid CONTAINS %@", uuid)
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
    
    static func fetchWithSuggestionsRequest() -> NSFetchRequest<UserSession> {
        let request = UserSession.fetchRequest()
        request.predicate = NSPredicate(format: "suggestions.@count > 0")
        request.sortDescriptors = [NSSortDescriptor(key: "timestamp", ascending: false)]
        return request
    }
    
    static func getCurrent(context: NSManagedObjectContext) -> UserSession {
        let uuid = getCurrentUUID()
        let userSessions = try! context.fetch(UserSession.fetchRequest(uuid: uuid))
        let userSession = userSessions.first ?? UserSession(context: context)
        userSession.uuid = userSession.uuid ?? uuid
        userSession.timestamp = Date.now
        return userSession
    }
    
}

extension Symptom {
    
    static func fetchRequest(forId: Int16) -> NSFetchRequest<Symptom> {
        let request = Symptom.fetchRequest()
        request.predicate = NSPredicate(format: "id == %i", forId)
        return request
    }
    
}

extension Suggestion {
    
    enum Source: String {
        case Calendar
        case Health
    }
    
    static func fromCalendar(context: NSManagedObjectContext, content: String) -> Suggestion {
        let suggestion = Suggestion(context: context)
        suggestion.source = Source.Calendar.rawValue
        suggestion.content = content
        suggestion.userSession = UserSession.getCurrent(context: context)
        return suggestion
    }
    
}

extension EKEventStore {
    
    func upcomingEvents() -> [EKEvent] {
        let startDate = Date.now
        let endDate = startDate + CalendarConstants.EVENTS_FUTURE_LOOKUP_TIME_INTERVAL
        let calendars = self.calendars(for: .event)
        let predicate = self.predicateForEvents(withStart: startDate, end: endDate, calendars: calendars)
        
        var events = self.events(matching: predicate)
        events.sort { $0.startDate > $1.startDate }
        return events
    }
    
}
