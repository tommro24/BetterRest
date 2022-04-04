//
//  ContentView.swift
//  BetterRest
//
//  Created by Tomek on 31/03/2022.
//

import CoreML
import SwiftUI

struct ContentView: View {
    @State private var wakeUp = defaultWakeTime
    @State private var sleepAmount = 8.0
    @State private var coffeAmount = 1
    
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    @State private var showAllert = false
    
    static var defaultWakeTime: Date {
        var component = DateComponents()
        component.hour = 7
        component.minute = 13
        return Calendar.current.date(from: component) ?? Date.now
    }
    
    var sleepTime: Date {
        do {
        let config = MLModelConfiguration()
        let model = try SleepCalculator(configuration: config)
        let components = Calendar.current.dateComponents([.hour,.minute], from: wakeUp)
        
        let hour = components.hour ?? 0
        let minute = components.minute ?? 0
        let wake = hour * 3600 + minute * 60
        let prediction = try model.prediction(wake: Double(wake), estimatedSleep: sleepAmount, coffee: Double(coffeAmount))
        return wakeUp - prediction.actualSleep
        } catch {
            return Date.now
        }
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section("When do you want to wake up?"){
                    HStack {
                        Spacer()
                        DatePicker("Please enter a time",selection: $wakeUp, displayedComponents: .hourAndMinute)
                            .labelsHidden()
                    }
                }

                Section("Desired amount of sleep"){
                    Stepper("\(sleepAmount.formatted()) hours", value: $sleepAmount,in: 4...12,step: 0.25)
                }
                
                Section("Daily coffee intake"){
                    Picker("Number of cups", selection: $coffeAmount) {
                        let range = 0...20
                        ForEach(range, id: \.self) { numberofCups in
                            Text(numberofCups == 1 ? "1 cup" : "\(numberofCups) cups")
                        }
                    }
                }
                
                VStack(alignment: .center) {
                    HStack(alignment: .center){
                        Spacer()
                        Text("Recommended bedtime...")
                        Spacer()
                    }
                    HStack(alignment: .center){
                        Spacer()
                        Text("\(sleepTime.formatted(date: .omitted, time: .shortened))")
                            .font(.largeTitle).bold()
                        Spacer()
                    }
                    
                }
            }
            .navigationTitle("BetterRest")
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
