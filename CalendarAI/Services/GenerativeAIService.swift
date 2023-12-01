//
//  GenerativeAIService.swift
//  CalendarAI
//
//  Created by Ujjwal Sharma on 30/11/23.
//

import Foundation
import EventKit

// Struct for the request payload
struct ChatRequest: Codable {
    let model: String
    let messages: [Message]
    let temperature: Double
}

struct Message: Codable {
    let role: String
    let content: String
}

// Struct for the response
struct ChatResponse: Codable {
    let choices: [Choice]
}

struct Choice: Codable {
    let message: Message
}

enum EventCategory: String, CaseIterable {
    case health
    case celebration
    case work
}

class GenerativeAIService: ObservableObject{
      
    func classifyEvent(event: EKEvent, completion: @escaping (String?) -> Void) {
        var prompt = "Event title is \(event.title!). Classify this in one of the following categories. The categories are "
        var events: [String] = []
        for event in EventCategory.allCases {
            events.append("\(event.rawValue)")
        }
        let joinedString = events.joined(separator: ", ")
        prompt.append(joinedString)
        prompt.append(". Give only the category name.")
        
        print(prompt)
        self.promptGPT4(prompt: prompt, completion: completion)
    }
    
    func generateNotificationContent(event: EKEvent, place: GoogleNearbyPlace?, completition: @escaping (String?) -> Void) -> Void {
        var prompt = "Event title is \(event.title!)."
        if let place = place {
            prompt.append(" The user is currently near \(place.name).")
        }
        prompt.append(" Give a one liner mobile notification for the user based on the event on their calendar.")
        
        print(prompt)
        self.promptGPT4(prompt: prompt, completion: completition)
    }
    
    private func getAPIKey() -> String {
        let key = UserDefaults.standard.string(forKey: Keys.OPENAI_API_KEY_IDENTIFIER)
        if (key == nil || key!.isEmpty) {
            fatalError("Please provide a valid OpenAI API key in Settings!")
        }
        return key!
    }
    
    private func promptGPT4(prompt: String, completion: @escaping (String?) -> Void) {
        let url = URL(string: "https://api.openai.com/v1/chat/completions")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("Bearer \(getAPIKey())", forHTTPHeaderField: "Authorization")
        
        let chatRequest = ChatRequest(model: "gpt-3.5-turbo", messages: [Message(role: "user", content: prompt)], temperature: 0.7)
        let requestData = try! JSONEncoder().encode(chatRequest)
        request.httpBody = requestData
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let httpResponse = response as? HTTPURLResponse {
                print("HTTP Status Code: \(httpResponse.statusCode)")
            }

            if let error = error {
                print("Error: \(error.localizedDescription)")
                completion("Error: \(error.localizedDescription)")
                return
            }

            guard let data = data else {
                completion("No data received")
                return
            }

            do {
                let response = try JSONDecoder().decode(ChatResponse.self, from: data)
                let result = response.choices.first?.message.content
                completion(result)
            } catch {
                print("Decoding error: \(error)")
                completion("Decoding error: \(error.localizedDescription)")
            }
        }
        task.resume()
    }
    
}
