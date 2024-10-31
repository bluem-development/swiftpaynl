//
//  PaynlOrderCreateResponse.swift
//
//
//  Created by Zhanna Hakobyan on 31.10.24.
//

import Foundation

// MARK: - MainModel
struct PaynlOrderCreateResponse: Codable {
    let id                : String
    let serviceId         : String
    let description       : String
    let reference         : String
    let manualTransferCode: String
    let orderId           : String
    let uuid              : String
    let status            : Status
    let customerKey       : String?
    let receipt           : String?
    let checkoutData      : String?
    let integration       : Integration
    let stats             : Stats
    let amount            : Amount
    let authorizedAmount  : Amount
    let capturedAmount    : Amount
    let links             : Links
    let createdBy         : String
    let modifiedBy        : String
    var createdAt         : String  // TODO: Change to `Date`
    var modifiedAt        : String  // TODO: Change to `Date`
    var expiresAt         : String  // TODO: Change to `Date`
    var completedAt       : String? // TODO: Change to `Date?`
    let payments          : [String]
    let transferData      : [String: String]
}

// MARK: - Status
struct Status: Codable {
    let code  : Int
    let action: String //TODO: what type should be used for "PENDING"?
}

// MARK: - Integration
struct Integration: Codable {
    let test: Bool
}

// MARK: - Stats
struct Stats: Codable {
    let extra1    : String
    let extra2    : String
    let extra3    : String
    let tool      : String
    let info      : String
    let object    : String
    let promotorId: Int
    let domainId  : String
}

// MARK: - Amount
struct Amount: Codable {
    let value   : Int
    let currency: String
}

// MARK: - Links
struct Links: Codable {
    let status  : String
    let abort   : String
    let redirect: String
}
