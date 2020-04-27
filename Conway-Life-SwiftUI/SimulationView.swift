//
//  ContentView.swift
//  Conway-Life-SwiftUI
//
//  Created by Joshua Homann on 4/25/20.
//  Copyright © 2020 com.josh. All rights reserved.
//

import SwiftUI

struct SimulationView: View {
  @ObservedObject private var model: SimulationModel = .init()
  var body: some View {
    VStack {
      LifeView().environmentObject(self.model)
      HStack(alignment: .firstTextBaseline, spacing: 80) {
        Button("Reset") { self.model.reset() }
        Spacer()
        Button(self.model.isPaused ? "Resume" : "Pause") { self.model.isPaused.toggle() }
        Spacer()
        Text("Generation: \(self.model.generation)")
      }
      Picker(selection: self.$model.speed, label: EmptyView()) {
        ForEach(0..<SimulationModel.Speed.allCases.count) { index in
          Text(String(describing: SimulationModel.Speed.allCases[index]).capitalized)
          .tag(SimulationModel.Speed.allCases[index])
        }
      }
      .pickerStyle(SegmentedPickerStyle())
    }
    .padding()
  }
}

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    SimulationView()
  }
}
