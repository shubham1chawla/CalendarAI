//
//  HealthFormViewModel.swift
//  WellnessAI
//
//  Created by Shubham Chawla on 12/17/23.
//

import Foundation
import CoreData
import CoreMotion

extension HealthFormView {
    @MainActor class ViewModel: ObservableObject {
        
        private var context: NSManagedObjectContext?
        private var decodableViewModel: DecodableViewModel?
        private var timer: Timer?
        private let defaults = UserDefaults.standard
        private let motionManager = CMMotionManager()
        
        @Published private(set) var symptoms: [Symptom] = []
        @Published private(set) var intensities: [Int:String] = [:]
        @Published private(set) var userSymptoms: [UserSymptom] = []
        
        @Published var heartRate: Double?
        @Published var respRate: Double?
        
        @Published var showRespRateTip: Bool = false
        @Published var isMeasuringRespRate: Bool = false
        @Published var showSaveAlert: Bool = false
        
        @Published var selectedSymptomIndex: Int = 0
        @Published var selectedIntensityValue: Int = 1
        
        func setup(context: NSManagedObjectContext, decodableViewModel: DecodableViewModel) {
            self.context = context
            self.decodableViewModel = decodableViewModel
            
            // Setting up symptoms & intensities from JSON file
            loadDefaultSymptoms()
            loadDefaultIntensities()
            
            // Loading symptoms from database
            setSymptoms()
        }
        
        func measureRespiratoryRate() -> Void {
            isMeasuringRespRate.toggle()
            
            // Setting up accelerometer for capturing motion
            motionManager.startAccelerometerUpdates()
            motionManager.accelerometerUpdateInterval = MeasurementConstants.ACCELEROMETER_INTERVAL
            
            // Setting up variable to measure respiratory rate
            var previousValue: Double = 0
            var intervalCount: Int = 0
            var rawRespCount: Int = 0
            
            // Setting up timer to measure respiratory rate
            timer = Timer.scheduledTimer(withTimeInterval: MeasurementConstants.ACCELEROMETER_INTERVAL, repeats: true) { _ in
                Task { @MainActor in
                    // Checking if duration is within the acceptable time interval
                    let duration = MeasurementConstants.ACCELEROMETER_INTERVAL * Double(intervalCount)
                    guard duration < Double(MeasurementConstants.MAX_TIME_DURATION) else {
                        self.respRate = (Double(rawRespCount) / duration) * 30
                        self.timer?.invalidate()
                        self.isMeasuringRespRate.toggle()
                        return
                    }
                    
                    // Fetching accelerometer data
                    if let data = self.motionManager.accelerometerData {
                        let value = sqrt(pow(data.acceleration.x, 2) + pow(data.acceleration.y, 2) + pow(data.acceleration.z, 2))
                        if abs(value - previousValue) > MeasurementConstants.ACCELEROMETER_DIFFERENCE_THRESHOLD {
                            rawRespCount += 1
                        }
                        previousValue = value
                    }
                    intervalCount += 1
                }
            }
        }
        
        func addUserSymptom() -> Void {
            guard let context = context else { return }
            userSymptoms.removeAll { userSymptom in
                return userSymptom.symptom == symptoms[selectedSymptomIndex]
            }
            let userSymptom = UserSymptom(context: context)
            userSymptom.symptom = symptoms[selectedSymptomIndex]
            userSymptom.intensityValue = Int16(selectedIntensityValue)
            userSymptom.intensityLabel = intensities[selectedIntensityValue]
            userSymptoms.append(userSymptom)
        }
        
        func removeUserSymptoms(atOffsets: IndexSet) -> Void {
            userSymptoms.remove(atOffsets: atOffsets)
        }
        
        func saveHealthInformation() -> Void {
            guard let context = context else { return }
            
            // Extracting user session id from defaults
            let uuid = defaults.string(forKey: Keys.LAST_USER_SESSSION)
            if (uuid ?? "").isEmpty {
                fatalError("No user session was set!")
            }
            
            // Getting current user session
            let request = UserSession.fetchRequest()
            request.predicate = NSPredicate(format: "uuid CONTAINS %@", uuid!)
            let userSessions = try! context.fetch(request)
            let userSession = userSessions.first ?? UserSession(context: context)
            userSession.uuid = userSession.uuid ?? uuid!
            userSession.timestamp = Date()
            
            // Adding user measurements if exists
            let userMeasurement = userSession.userMeasurement ?? UserMeasurement(context: context)
            userMeasurement.heartRate = heartRate ?? 0
            userMeasurement.respRate = respRate ?? 0
            userMeasurement.userSession = userSession
            
            // Deleting old user symptoms and overwriting user symptoms
            userSession.userSymptoms?.forEach{ object in
                let userSymptom = object as! UserSymptom
                context.delete(userSymptom)
            }
            for userSymptom in userSymptoms {
                userSymptom.userSession = userSession
            }
            
            // Persisting changes to the database
            try? context.save()
        }
        
        private func setSymptoms() -> Void {
            guard let context = context else { return }
            let request = Symptom.fetchRequest()
            request.sortDescriptors = [NSSortDescriptor(key: "id", ascending: true)]
            var symptoms: [Symptom] = []
            for symptom in try! context.fetch(request) {
                symptoms.append(symptom)
            }
            self.symptoms = symptoms
        }
        
        private func loadDefaultSymptoms() -> Void {
            guard let context = context else { return }
            decodableViewModel?.decodableSymptoms.forEach { decodableSymptom in
                
                // Checking if the symptom exists in database
                let request = Symptom.fetchRequest()
                request.predicate = NSPredicate(format: "id == %i", decodableSymptom.id)
                let symptoms = try? context.fetch(request)
        
                if (symptoms ?? []).isEmpty {
                    let symptom = Symptom(context: context)
                    symptom.id = decodableSymptom.id
                    symptom.name = decodableSymptom.name
                    try? context.save()
                }
            }
        }
        
        private func loadDefaultIntensities() -> Void {
            decodableViewModel?.decodableIntensities.forEach { decodableIntensity in
                intensities[decodableIntensity.value] = decodableIntensity.label
            }
        }
        
    }
}
