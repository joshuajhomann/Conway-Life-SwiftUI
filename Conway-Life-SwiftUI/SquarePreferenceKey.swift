//
//  SquarePreference.swift
//  Conway-Life-SwiftUI
//
//  Created by Joshua Homann on 4/26/20.
//  Copyright © 2020 com.josh. All rights reserved.
//

import SwiftUI

struct SquarePreferenceKey: PreferenceKey {
  typealias Value = [Squares]
  struct Squares: Equatable {
    var x: Int
    var y: Int
    var rect: CGRect
  }
  static var defaultValue: Value = Value()
  static func reduce(value: inout Value, nextValue: () -> Value) {
    value += nextValue()
  }
}
