//
//  Loadable.swift
//  SenSoyleAvrupa
//
//  Created by Ing. Ebu Celik on 18.03.22.
//

import Foundation

public enum Loadable<T: Equatable>: Equatable where T: Codable {
    case none
    case loading
    case loaded(T)
    case refreshing(T)
    case error(APIError)
}

extension Loadable {
    public static func == (lhs: Loadable<T>, rhs: Loadable<T>) -> Bool {
        switch (lhs, rhs) {
        case (.none, .none):
            return true
        case (.loading, .loading):
            return true
        case (.loaded(let lhsT), .loaded(let rhsT)):
            return lhsT == rhsT
        case (.refreshing(let lhsT), .refreshing(let rhsT)):
            return lhsT == rhsT
        case (.error(let lhsError), .error(let rhsError)):
            return lhsError.localizedDescription == rhsError.localizedDescription
        default:
            return false
        }
    }
}

public struct APIError: Error, Equatable {
    var error: Error

    init(error: Error) {
        self.error = error
    }

    public static func == (lhs: APIError, rhs: APIError) -> Bool {
        return lhs.error.localizedDescription == rhs.error.localizedDescription
    }
}
