//
//  WolframAlpha.swift
//  Counter
//
//  Created by Oluwatobi Omotayo on 01/06/2022.
//

import ComposableArchitecture

private let wolframAlphaApiKey = "6H69Q3-828TKQJ4EP"

struct WolframAlphaResult: Decodable {
  let queryresult: QueryResult
  
  struct QueryResult: Decodable {
    let pods: [Pod]
    
    struct Pod: Decodable {
      let primary: Bool?
      let subpods: [SubPod]
      
      struct SubPod: Decodable {
        let plaintext: String
      }
    }
  }
}

/// This network function is the sole side effect in our app so far.
//func nthPrime(_ n: Int, callback: @escaping (Int?) -> Void) -> Void {
public func nthPrime(_ n: Int) -> Effect<Int?> {
  return wolframAlpha(query: "prime \(n)").map { result in
    result
      .flatMap {
        $0.queryresult
          .pods
          .first(where: { $0.primary == .some(true) })?
          .subpods
          .first?
          .plaintext
      }
      .flatMap(Int.init)
  }
  .eraseToEffect()
}

//func wolframAlpha(query: String, callback: @escaping (WolframAlphaResult?) -> Void) -> Void {
func wolframAlpha(query: String) -> Effect<WolframAlphaResult?> {
  var components = URLComponents(string: "https://api.wolframalpha.com/v2/query")!
  components.queryItems = [
    URLQueryItem(name: "input", value: query),
    URLQueryItem(name: "format", value: "plaintext"),
    URLQueryItem(name: "output", value: "JSON"),
    URLQueryItem(name: "appid", value: wolframAlphaApiKey),
  ]
  
  return URLSession.shared
    .dataTaskPublisher(for: components.url(relativeTo: nil)!)
    .map { data, _ in data }
    .decode(type: WolframAlphaResult?.self, decoder: JSONDecoder())
    .replaceError(with: nil)
    .eraseToEffect()
  
//  return dataTask(with: components.url(relativeTo: nil)!)
//    .decode(as: WolframAlphaResult.self)
}
