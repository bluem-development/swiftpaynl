//
//  PaynlAuthenticationTokensBrowseResponse.swift
//
//
//  Created by Zhanna Hakobyan on 14.11.24.
//

import Foundation

struct PaynlAuthenticationTokensBrowseResponse: Codable {
    let total               : Int
    let links               : [Link]
    let authenticationTokens: [AuthenticationToken]

    enum CodingKeys: String, CodingKey {
        case total
        case authenticationTokens
        case links = "_links"
    }
}

struct AuthenticationToken: Codable {
    let code      : String
    let secret    : String
    let name      : String
    let createdAt : String
    let createdBy : String
    let modifiedAt: String?
    let modifiedBy: String?
    let deletedAt : String?
    let deletedBy : String?
    let merchant  : Merchant
    let links     : [Link]
}
