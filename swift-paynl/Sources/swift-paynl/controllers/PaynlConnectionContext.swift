//
//  PaynlConnectionContext.swift
//
//
//  Created by Zhanna Hakobyan on 18.11.24.
//

import Foundation

public struct PaynlConnectionContext {
    /*
     Overview

     1. The token is mandatory for authenticating API requests
     - API endpoint: https://rest.pay.nl/v2/authenticationtokens
     - The `authenticationtokens` API request returns all authentication tokens (an array of token objects)
     - The token object contains an `deletedAt` field that indicates the expiration time
     - If a token is requested but all tokens are expired, a new API request must be sent to retrieve and return a valid token

     2. `serviceId` is mandatory for performing an API call
     - Link: https://my.pay.nl/programs/programs
     - The value of serviceId is retrieved from an external directory. The directory path is passed as an argument to the `PaynlConnectionContext` initializer
     */


    fileprivate let _serviceId         : String?
    private     var tokens             : [AuthenticationTokenTest]?
    private     var timer              : Timer?
    private     let duration           = 300.0 // 5 minutes in seconds
    private     var needToUpdateToken  = false
    public      var updateTokenIsNeeded: (() -> Void)?

    public init(configPath: String) {
        // TODO: Take `serviceId` from json located at configPath
        // TODO: Initialize the `serviceId`
        _serviceId = "testId"
    }

    private mutating func validTokens() -> [AuthenticationTokenTest]? {
        guard let tokens = tokens
        else { return nil }

        needToUpdateToken = true
        let currentDate   = Date()

        let validTokens = tokens.filter { token in
            guard let expDate = token.expDate else { return false }

            let timeInterval        = currentDate.timeIntervalSince(expDate)
            let isExpired           = timeInterval > 0
            let isCloseToExpiration = -timeInterval < duration

            // Dont update needToUpdateToken unless all tokens are invalid
            needToUpdateToken = needToUpdateToken ? (isExpired || isCloseToExpiration) : needToUpdateToken

            return !isExpired
        }

        return validTokens
    }
}

// MARK: - Timer
extension PaynlConnectionContext {
    private mutating func startTimer() {
        stopTimer()
        let mSelf = self

        // TODO: This will be called when no valid token remains within the next 5min
        timer = Timer.scheduledTimer(withTimeInterval: duration, repeats: false) { _ in
            mSelf.updateTokenIsNeeded?()
        }
    }

    private mutating func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
}

// MARK: - PaynlConnectionContextProtocol
public protocol PaynlConnectionContextProtocol {
    var serviceId: String? { get }

    mutating func token() -> String?
    mutating func loadToken(callback:((String?) -> Void))
}

extension PaynlConnectionContext: PaynlConnectionContextProtocol {
    public mutating func loadToken(callback:((String?) -> Void)) {
        // TODO: Send the `authenticationtokens` API request
        // TODO: Initialize the `tokens`
        let tokens = [AuthenticationTokenTest(deletedAt: "2024-12-02T00:30:12+02:00", token: "1111"),
                      AuthenticationTokenTest(deletedAt: "2024-12-02T22:30:24+02:00", token: "3333")]
        self.tokens = tokens

        callback(validTokens()?.first?.token)
        if needToUpdateToken { startTimer() }
    }

    public var serviceId: String? {
        self._serviceId
    }

    public mutating func token() -> String? {
        // Create a loop of `tokens`, return non-expired token or nil if there is no valid token
        let token = validTokens()?.first?.token
        if needToUpdateToken { startTimer() }

        return token
    }
}

// MARK: - Test type with minimal fields
struct AuthenticationTokenTest {
    let deletedAt: String?
    let token    : String

    var expDate: Date? {
        let formatter           = ISO8601DateFormatter()
        formatter.timeZone      = TimeZone.current
        formatter.formatOptions = [.withInternetDateTime]

        guard let deletedAt = deletedAt, let date = formatter.date(from: deletedAt)
        else { return nil }

        return date
    }
}


// MARK: - Usage
/*
func start() {
    var context = PaynlConnectionContext(configPath: "")
    guard context.serviceId != nil
    else { print("The `serviceId` is not found."); return }

    //Subscribe to event
    context.updateTokenIsNeeded = {
        context.loadToken { token in
            print("Update. The new token is: \(token ?? "nil")")
        }
    }

    if let token = context.token(), !token.isEmpty {
        // The next api call
    } else {
        context.loadToken { token in
            print("First Load. The new token is: \(token ?? "nil")")
        }
    }
}
*/
