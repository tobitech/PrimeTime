//
//  Pullback.swift
//  PrimeTime
//
//  Created by Oluwatobi Omotayo on 31/05/2022.
//

import Foundation

/// One of two functions that form the foundation of reducer composition.
/// This lets us transform a reducer that understands local state and actions into one that understands global states and actions.
public func pullback<LocalValue, GlobalValue, LocalAction, GlobalAction, LocalEnvironment, GlobalEnvironment>(
  _ reducer: @escaping Reducer<LocalValue, LocalAction, LocalEnvironment>,
  value: WritableKeyPath<GlobalValue, LocalValue>,
  action: WritableKeyPath<GlobalAction, LocalAction?>,
  environment: @escaping (GlobalEnvironment) -> LocalEnvironment
) -> Reducer<GlobalValue, GlobalAction, GlobalEnvironment> {
  return { globalValue, globalAction, globalEnvironment in
    guard let localAction = globalAction[keyPath: action] else { return [] }
    let localEffects = reducer(&globalValue[keyPath: value], localAction, environment(globalEnvironment))
    
    return localEffects.map { localEffect in
      localEffect.map { localAction -> GlobalAction in
        var globalAction = globalAction
        globalAction[keyPath: action] = localAction
        return globalAction
      }.eraseToEffect()
    }
  }
}
