//
//  FavoritePrimesAction.swift
//  PrimeTime
//
//  Created by Oluwatobi Omotayo on 31/05/2022.
//

import Foundation

public enum FavoritePrimesAction: Equatable {
  case deleteFavoritePrimes(IndexSet)
  case loadedFavoritePrimes([Int])
  case loadButtonTapped
  case saveButtonTapped
  
  var deleteFavoritePrimes: IndexSet? {
    get {
      guard case let .deleteFavoritePrimes(value) = self else { return nil }
      return value
    }
    set {
      guard case .deleteFavoritePrimes = self, let newValue = newValue else { return }
      self = .deleteFavoritePrimes(newValue)
    }
  }
}
