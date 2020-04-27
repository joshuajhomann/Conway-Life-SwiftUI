//
//  LifeView.swift
//  Conway-Life-SwiftUI
//
//  Created by Joshua Homann on 4/26/20.
//  Copyright © 2020 com.josh. All rights reserved.
//

import SwiftUI

struct LifeView: View {
  @EnvironmentObject private var model: SimulationModel
  @State private var squares: [SquarePreferenceKey.Squares] = []
  @State private var lastSelection: (Int, Int)?
  private enum Constant {
    static let spacing: CGFloat = 1
    static let stackSpace = CoordinateSpace.named(Space.stack)
  }
  private enum Space: Int {
    case stack
  }
  var body: some View {
    GeometryReader { outer in
      VStack(spacing: Constant.spacing) {
        ForEach (0..<self.model.height) { y in
          HStack(spacing: Constant.spacing) {
            ForEach (0..<self.model.width) { x in
              GeometryReader { geometry in
                ZStack {
                  Rectangle()
                    .fill(self.fillColor(x: x, y: y))
                    .cornerRadius(Constant.spacing)
                  Circle()
                    .fill(self.overlayColor(x: x, y: y))
                }
                .animation(.easeInOut)
                .preference(
                  key: SquarePreferenceKey.self,
                  value: [.init(x: x, y: y,rect: geometry.frame(in: Constant.stackSpace))]
                )
                .onTapGesture { self.model.select(x: x, y: y) }
              }
            }
          }
        }
      }
      .frame(
        width: min(outer.size.width, outer.size.height),
        height: min(outer.size.width, outer.size.height)
      )
    }
    .coordinateSpace(name: Space.stack)
    .onPreferenceChange(SquarePreferenceKey.self) { squares in
      self.squares = squares
    }
    .gesture(
      DragGesture()
      .onChanged { value in
        let point = value.location
        guard let square = self.squares.first(where: { $0.rect.contains(point)}),
          !(square.x == self.lastSelection?.0 && square.y == self.lastSelection?.1) else {
          return
        }
        self.lastSelection = (square.x, square.y)
        self.model.select(x: square.x, y: square.y)
      }
      .onEnded({ _ in
        self.lastSelection = nil
      })
    )
  }
  private func fillColor(x: Int, y: Int) -> Color {
    switch model.cells[x][y] {
    case .alive:
      return Color(#colorLiteral(red: 0.2392156869, green: 0.6745098233, blue: 0.9686274529, alpha: 1))
    case .dead(let age):
      return Color(#colorLiteral(red: 0.2588235438, green: 0.7568627596, blue: 0.9686274529, alpha: 1).mix(with: #colorLiteral(red: 0.1215686277, green: 0.01176470611, blue: 0.4235294163, alpha: 1), proportion: CGFloat(min(age, 80)) / 80.0))
    case .empty:
      return Color(#colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1))
    }
  }
  private func overlayColor(x: Int, y: Int) -> Color {
    switch model.cells[x][y] {
    case .alive (let age):
      return Color(#colorLiteral(red: 0.4666666687, green: 0.7647058964, blue: 0.2666666806, alpha: 1).mix(with: #colorLiteral(red: 0.7254902124, green: 0.4784313738, blue: 0.09803921729, alpha: 1), proportion: CGFloat(min(age, 20)) / 20.0))
    case .dead, .empty:
      return .clear
    }
  }
}
