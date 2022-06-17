//
//  CounterTests.swift
//  CounterTests
//
//  Created by Oluwatobi Omotayo on 31/05/2022.
//

import XCTest
@testable import Counter
import ComposableArchitecture

struct Step<Value, Action> {
  let action: Action
  let update: (inout Value) -> Void
  let file: StaticString
  let line: UInt
  
  init(
    _ action: Action,
    file: StaticString = #file,
    line: UInt = #line,
    _ update: @escaping (inout Value) -> Void
  ) {
    self.action = action
    self.update = update
    self.file = file
    self.line = line
  }
}

func assert<Value: Equatable, Action>(
  initialValue: Value,
  reducer: Reducer<Value, Action>,
  steps: Step<Value, Action>...
) {
  var state = initialValue
  steps.forEach { step in
    var expected = state
    _ = reducer(&state, step.action)
    step.update(&expected)
    XCTAssertEqual(state, expected, file: step.file, line: step.line)
  }
}

class CounterTests: XCTestCase {
  
  override func setUp() {
    super.setUp()
    Current = .mock
  }
  
  func testIncrButtonTapped() {
    
    assert(
      initialValue: CounterViewState(count: 2),
      reducer: counterViewReducer,
      steps:
      Step(.counter(.incrTapped)) { $0.count = 3 },
      Step(.counter(.incrTapped)) { $0.count = 4 },
      Step(.counter(.decrTapped)) { $0.count = 3 }
    )
  }
  
  func testDecrButtonTapped() {
    var state = CounterViewState(count: 2)
    var expected = state
    let effects = counterViewReducer(&state, .counter(.decrTapped))
    expected.count = 1
    
    XCTAssertEqual(state, expected)
    
    XCTAssert(effects.isEmpty)
  }
  
  func testNthPrimeButtonHappyFlow() {
    Current.nthPrime = { _ in .sync { 17 } }
    
    var state = CounterViewState(
      alertNthPrime: nil,
      isNthPrimeButtonDisabled: false
    )
    
    var expected = state
    
    var effects = counterViewReducer(&state, .counter(.nthPrimeButtonTapped))
    
    expected.isNthPrimeButtonDisabled = true
    XCTAssertEqual(state, expected)
    
    XCTAssertEqual(effects.count, 1)
    
    var nextAction: CounterViewAction!
    let receivedCompletion = self.expectation(description: "receivedCompletion")
    effects[0].sink(
      receiveCompletion: { _ in
        receivedCompletion.fulfill()
      },
      receiveValue: { action in
        XCTAssertEqual(action, .counter(.nthPrimeResponse(17)))
        nextAction = action
      }
    )
    // timeout of `0` doesn't work.
    // it's not happening immediately because of the thread hop from the background thread running the side-effect
    // to the main thread
    self.wait(for: [receivedCompletion], timeout: 0.01)
    
    effects = counterViewReducer(&state, nextAction)
    
    expected.isNthPrimeButtonDisabled = false
    expected.alertNthPrime = PrimeAlert(prime: 17)
    
    XCTAssertEqual(state, expected)
    
//    XCTAssertEqual(
//      state,
//      CounterViewState(
//        alertNthPrime: PrimeAlert(prime: 17),
//        count: 2,
//        favoritePrimes: [3, 5],
//        isNthPrimeButtonDisabled: false
//      )
//    )
    
    XCTAssertTrue(effects.isEmpty)
    
    effects = counterViewReducer(&state, .counter(.alertDismissButtonTapped))
    expected.alertNthPrime = nil
    expected.isNthPrimeButtonDisabled = false
    
    XCTAssertEqual(state, expected)
    
//    XCTAssertEqual(
//      state,
//      CounterViewState(
//        alertNthPrime: nil,
//        count: 2,
//        favoritePrimes: [3, 5],
//        isNthPrimeButtonDisabled: false
//      )
//    )
    
    XCTAssertTrue(effects.isEmpty)
  }
  
  func testNthPrimeButtonUnhappyFlow() {
    Current.nthPrime = { _ in .sync { nil } }
    
    var state = CounterViewState(
      alertNthPrime: nil,
      count: 2,
      favoritePrimes: [3, 5],
      isNthPrimeButtonDisabled: false
    )
    
    var effects = counterViewReducer(&state, .counter(.nthPrimeButtonTapped))
    
    XCTAssertEqual(
      state,
      CounterViewState(
        alertNthPrime: nil,
        count: 2,
        favoritePrimes: [3, 5],
        isNthPrimeButtonDisabled: true
      )
    )
    
    XCTAssertEqual(effects.count, 1)
    
    var nextAction: CounterViewAction!
    let receivedCompletion = self.expectation(description: "receivedCompletion")
    effects[0].sink(
      receiveCompletion: { _ in
        receivedCompletion.fulfill()
      },
      receiveValue: { action in
        XCTAssertEqual(action, .counter(.nthPrimeResponse(nil)))
        nextAction = action
      }
    )
    self.wait(for: [receivedCompletion], timeout: 0.01)
    
    effects = counterViewReducer(&state, nextAction)
    
    XCTAssertEqual(
      state,
      CounterViewState(
        alertNthPrime: nil,
        count: 2,
        favoritePrimes: [3, 5],
        isNthPrimeButtonDisabled: false
      )
    )
    
    XCTAssertTrue(effects.isEmpty)
  }
  
  // this is an integration test
  // to test the integration with primemodal module.
  func testPrimeModal() {
    var state = CounterViewState(
      alertNthPrime: nil,
      count: 2,
      favoritePrimes: [3, 5],
      isNthPrimeButtonDisabled: false
    )
    
    var effects = counterViewReducer(&state, .primeModal(.saveFavoritePrimeTapped))
    
    XCTAssertEqual(
      state,
      CounterViewState(
        alertNthPrime: nil,
        count: 2,
        favoritePrimes: [3, 5, 2],
        isNthPrimeButtonDisabled: false
      )
    )
    
    XCTAssertTrue(effects.isEmpty)
    
    effects = counterViewReducer(&state, .primeModal(.removeFavoritePrimeTapped))
    
    XCTAssertEqual(
      state,
      CounterViewState(
        alertNthPrime: nil,
        count: 2,
        favoritePrimes: [3, 5],
        isNthPrimeButtonDisabled: false
      )
    )
    
    XCTAssertTrue(effects.isEmpty)
  }
}
