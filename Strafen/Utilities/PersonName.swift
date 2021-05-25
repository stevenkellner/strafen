//
//  PersonName.swift
//  Strafen
//
//  Created by Steven on 04.05.21.
//

import Foundation

/// Contains first and last name of a person
struct PersonName {

    /// First name of the name
    let firstName: String

    /// Last name of the name, can be optional
    let lastName: String?

    /// Init person name with first and optional last name.
    /// - Parameters:
    ///   - firstName: first name
    ///   - lastName: last name, can be optional
    init(firstName: String, lastName: String? = nil) {
        self.firstName = firstName
        self.lastName = lastName?.isEmpty ?? true ? nil : lastName
    }
}

extension PersonName: Codable {

    /// Coding Keys for Decodable
    enum CodingKeys: String, CodingKey {
        case firstName = "first"
        case lastName = "last"
    }
}

extension PersonName: Equatable {}

extension PersonName {

    /// Name as PersonNameComponents
    private var personNameComponents: PersonNameComponents {
        var componets = PersonNameComponents()
        componets.givenName = firstName
        componets.familyName = lastName
        return componets
    }

    /// Formatted person name
    var formatted: String {
        let formatter = PersonNameComponentsFormatter()
        formatter.style = .default
        return formatter.string(from: personNameComponents)
    }
}

extension PersonName: RandomInstanceProtocol {

    /// Generates a random person name
    /// - Parameter generator: random number generator
    /// - Returns: random person name
    static func random<T>(using generator: inout T) -> PersonName where T: RandomNumberGenerator {
        let firstName = ["Florence", "Katy", "Rachel", "Rhonda", "Caitlyn", "Antonia", "Ellie-Mae", "Isobelle", "Annabelle", "Charlotte"].randomElement(using: &generator)!
        let lastName = Bool.random(using: &generator) ? nil : ["Wood", "Stark", "Vinson", "Bush", "Piper", "Santos", "Couch", "Hilton", "Booth", "Fletcher"].randomElement(using: &generator)!
        return PersonName(firstName: firstName, lastName: lastName)
    }
}

/// Person name with optional first and last name
struct OptionalPersonName: Codable {

    /// Optional first name
    let first: String?

    /// Optional last name
    let last: String?
}

extension OptionalPersonName: Equatable {}
