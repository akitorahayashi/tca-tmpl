import ComposableArchitecture
import CounterFeatureCore
import XCTest

@testable import AppFeatureCore

@MainActor
final class AppFeatureTests: XCTestCase {
  func testInitialState() {
    let state = AppFeature.State()
    XCTAssertEqual(state.counter.count, 0)
  }

  func testCounterIncrement() async {
    let store = TestStore(initialState: AppFeature.State()) {
      AppFeature()
    }

    await store.send(.counter(.incrementButtonTapped)) {
      $0.counter.count = 1
    }
  }

  func testCounterDecrement() async {
    let store = TestStore(initialState: AppFeature.State(counter: CounterFeature.State(count: 5))) {
      AppFeature()
    }

    await store.send(.counter(.decrementButtonTapped)) {
      $0.counter.count = 4
    }
  }

  func testOnAppear() async {
    let store = TestStore(initialState: AppFeature.State()) {
      AppFeature()
    }

    await store.send(.onAppear)
  }

  func testCounterReset() async {
    let store = TestStore(initialState: AppFeature.State(counter: CounterFeature.State(count: 42))) {
      AppFeature()
    }

    await store.send(.counter(.resetButtonTapped)) {
      $0.counter.count = 0
    }
  }
}
