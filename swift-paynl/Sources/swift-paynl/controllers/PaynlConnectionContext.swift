//
//  PaynlConnectionContext.swift
//
//
//  Created by Zhanna Hakobyan on 18.11.24.
//

import Foundation

// TODO: Switch to actor in the future
public class PaynlConnectionContext {
    /*
     Overview

     1. The `token` is mandatory for authenticating API requests
     - API endpoint: https://rest.pay.nl/v2/authenticationtokens
     - The `authenticationtokens` API request returns all authentication tokens (an array of token objects)
     - The token object contains an `deletedAt` field that indicates the expiration time
     - If a token is requested but all tokens are expired, a new API request must be sent to retrieve and return a valid token

     2. The `serviceId` is mandatory for performing an API call
     - Link: https://my.pay.nl/programs/programs
     - The value of serviceId is retrieved from an external directory. The directory path is passed as an argument to the `PaynlConnectionContext` initializer
     */


    fileprivate var config             : PaynlConfiguration?
    private     var tokens             : [PaynlAuthenticationTokenTest]?
    private     var timer              : Timer?
    private     let duration           = 300.0 // 5 minutes in seconds
    private     var needToUpdateToken  = false
    public      var updateTokenIsNeeded: (() -> Void)?

    public init(configPath: String) {
        self.config = loadConfig(atPath: configPath)
    }

    private func validTokens() -> [PaynlAuthenticationTokenTest]? {
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

    private func loadConfig(atPath path: String) -> PaynlConfiguration? {
        do    { return try Data.decode(from: path, as: PaynlConfiguration.self) }
        catch { return nil }
    }

    private func fetchTokens() async -> [PaynlAuthenticationTokenTest]? {
        // TODO: Implement me!
        return nil
    }
}

// MARK: - Timer
extension PaynlConnectionContext {
    private func startTimer() {
        stopTimer()
        let mSelf = self

        // TODO: This will be called when no valid token remains within the next 5min
        timer = Timer.scheduledTimer(withTimeInterval: duration, repeats: false) { _ in
            mSelf.updateTokenIsNeeded?()
        }
    }

    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
}

// MARK: - PaynlConnectionContextProtocol
public protocol PaynlConnectionContextProtocol {
    var serviceId: String? { get }
    var token    : String? { get async }
}

extension PaynlConnectionContext: PaynlConnectionContextProtocol {
    public var serviceId: String? {
        self.config?.serverId
    }

    public var token: String? {
        get async {
            if let token = validTokens()?.first?.token { return token }
            else {
                self.tokens = await fetchTokens()
                return validTokens()?.first?.token
            }
        }
    }
}

// MARK: - Test type with minimal fields
private struct PaynlAuthenticationTokenTest {
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

// MARK: - PaynlConfiguration
private struct PaynlConfiguration: Codable {
    let serverId: String
}
