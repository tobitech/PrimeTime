//
//  AppState.swift
//  PrimeTime
//
//  Created by Oluwatobi Omotayo on 31/05/2022.
//

import Foundation
import PrimeModal
import Counter

/// This models our entire app's state in a simple value type.
struct AppState {
  var count = 0
  var favoritePrimes: [Int] = []
  var loggedInUser: User? = nil
  var activityFeed: [Activity] = []
  var alertNthPrime: PrimeAlert? = nil
  var isNthPrimeButtonDisabled: Bool = false
  
  struct Activity {
    let timestamp: Date
    let type: ActivityType
    
    enum ActivityType {
      case addedFavoritePrime(Int)
      case removedFavoritePrime(Int)
      
      var addedFavoritePrime: Int? {
        get {
          guard case let .addedFavoritePrime(value) = self else { return nil }
          return value
        }
        set {
          guard case .addedFavoritePrime = self, let newValue = newValue else { return }
          self = .addedFavoritePrime(newValue)
        }
      }
      
      var removedFavoritePrime: Int? {
        get {
          guard case let .removedFavoritePrime(value) = self else { return nil }
          return value
        }
        set {
          guard case .removedFavoritePrime = self, let newValue = newValue else { return }
          self = .removedFavoritePrime(newValue)
        }
      }
    }
  }
  
  struct User {
    let id: Int
    let name: String
    let bio: String
  }
}

extension AppState {
  var counterView: CounterViewState {
    get {
      CounterViewState(
        alertNthPrime: self.alertNthPrime,
        count: self.count,
        favoritePrimes: self.favoritePrimes,
        isNthPrimeButtonDisabled: self.isNthPrimeButtonDisabled
      )
    }
    set {
      self.alertNthPrime = newValue.alertNthPrime
      self.count = newValue.count
      self.favoritePrimes = newValue.favoritePrimes
      self.isNthPrimeButtonDisabled = newValue.isNthPrimeButtonDisabled
    }
  }
}
