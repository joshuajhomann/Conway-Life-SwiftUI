//
//  SimulationModel.swift
//  Conway-Life-SwiftUI
//
//  Created by Joshua Homann on 4/26/20.
//  Copyright © 2020 com.josh. All rights reserved.
//

import SwiftUI
import Combine

final class SimulationModel: ObservableObject {
  typealias Cells = [[Cell]]
  enum Cell {
    case empty, alive(Int), dead(Int)
    var isAlive: Bool {
      switch self {
      case .alive: return true
      case .dead, .empty: return false
      }
    }
  }
  enum Speed: TimeInterval, CaseIterable {
    case slowest = 1.5, slow = 1, medium = 0.5, fast = 0.25 , fastest = 0.125
  }

  // MARK: - Bidirectional
  @Published var isPaused = false
  var speed: Speed = .medium {
    didSet { tickInterval.value = speed.rawValue }
  }

  // MARK: - Outputs
  @Published private (set) var cells: Cells = []
  private (set) var generation = 0
  private (set) var width = 30
  private (set) var height = 30

  // MARK: - Instance
  private let unpauseSubject = PassthroughSubject<Void, Never>()
  private var tickInterval: CurrentValueSubject<TimeInterval,Never> = .init(Speed.medium.rawValue)
  private var subscriptions: Set<AnyCancellable> = []
  private enum Constant {
    static let adjacentOffsets: [(Int, Int)] = (-1...1)
      .flatMap {x in (-1...1).map { y in (x,y)}}
      .filter {(x,y) in !(x == 0 && y == 0)}
  }
  init() {

  reset()

  unpauseSubject
    .debounce(for: .seconds(2.5), scheduler: RunLoop.main)
    .map { _ in false }
    .assign(to: \.isPaused, on: self)
    .store(in: &subscriptions)

  Publishers
    .CombineLatest(
      $isPaused,
      tickInterval
    )
    .map { (isPaused, interval) -> AnyPublisher<Date, Never> in
      isPaused
        ? Empty().eraseToAnyPublisher()
        : Timer
          .publish(every: interval, on: RunLoop.main, in: .default)
          .autoconnect()
          .eraseToAnyPublisher()
    }
    .switchToLatest()
    .receive(on: DispatchQueue.global(qos: .userInitiated))
    .map { [weak self] _ in
      guard let inputs = self?.cells,
        let width = self?.width,
        let height = self?.height else {
        return []
      }
      self?.generation += 1
      let outputs = inputs.indices.map { x in
        inputs[x].indices.map { y -> Cell in
          let count = Constant.adjacentOffsets
            .map {(i,j) in ((x + i + width) % width, (y + j + height) % height)}
            .reduce(0) { accumulated, xy in
              accumulated + (inputs[xy.0][xy.1].isAlive ? 1 : 0)
            }
          switch inputs[x][y] {
          case .alive(let age):
            return (2...3).contains(count) ? Cell.alive(age + 1) : .dead(1)
          case .empty:
            return count == 3 ? Cell.alive(1) : .empty
          case .dead(let age):
            return count == 3 ? Cell.alive(1) : .dead(age + 1)
          }
        }
      }
      return outputs
    }
    .receive(on: DispatchQueue.main)
    .assign(to: \.cells, on: self)
    .store(in: &subscriptions)
  }

  // MARK: - Inputs
  func select(x: Int, y: Int) {
    isPaused = true
    unpauseSubject.send(())
    switch cells[x][y] {
    case .alive:
      return cells[x][y] = .dead(1)
    case .dead, .empty:
      return cells[x][y] = .alive(1)
    }
  }

  func reset() {
    cells = Cells(repeating: [Cell](repeating: .empty, count: height), count: width)
    generation = 0
    isPaused = true
  }
}
