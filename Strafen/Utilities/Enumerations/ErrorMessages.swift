//
//  ErrorMessages.swift
//  Strafen
//
//  Created by Steven on 12.05.21.
//

import Foundation

/// All error messages
enum ErrorMessages: Int {

    /// Textfield is empty
    case emptyField

    /// Invalid email
    case invalidEmail

    /// Less than 8 characters in password
    case tooFewCharacters

    /// No upper character in password
    case noUpperCharacter

    /// No lower character in password
    case noLowerCharacter

    /// No digit in password
    case noDigit

    /// Not same password
    case notSamePassword

    /// Internal error for sign in
    case internalErrorSignIn

    /// Internal error for log in
    case internalErrorLogIn

    /// Internal error for save
    case internalErrorSave

    /// Email is already signed in
    case alreadySignedInEmail

    /// User is already signed in
    case alreadySignedIn

    /// Password is too weak
    case weakPassword

    /// Club doesn't exist
    case clubNotExists

    /// No region given
    case noRegionGiven

    /// In app payment currency isn't euro
    case notEuro

    /// Club identifier already exists
    case identifierAlreadyExists

    /// Password is incorrect
    case incorrectPassword

    /// Not signed in
    case notSignedIn

    /// Amount can't be zero
    case amountZero

    /// Future date
    case futureDate

    /// Invalid number range
    case invalidNumberRange

    /// Internal error delete
    case internalErrorDelete

    /// Person is undeletable cause person is already registred
    case personUndeletable

    /// Reason is undeletable cause a fine uses this reason
    case reasonUndeletable

    /// No person is selected for fine add new
    case noPersonSelected

    /// No reason is given for fine add new
    case noReasonGiven

    /// Raw message of the error
    var rawMessage: String {
        switch self {
        case .emptyField: return String(localized: "error-message-emptyField", comment: "An error message displayed, when a text field is empty.")
        case .invalidEmail: return String(localized: "error-message-invalidEmail", comment: "An error message displayed, when inputed text isn't a valid email address.")
        case .tooFewCharacters: return String(localized: "error-message-tooFewCharacters", comment: "An error message displayed, when inputed password doesn't contain enough characters.")
        case .noUpperCharacter: return String(localized: "error-message-noUpperCharacter", comment: "An error message displayed, when inputed password doesn't contain an uppercased character.")
        case .noLowerCharacter: return String(localized: "error-message-noLowerCharacter", comment: "An error message displayed, when inputed password doesn't contain a lowercased character.")
        case .noDigit: return String(localized: "error-message-noDigit", comment: "An error message displayed, when inputed password doesn't contain a digit.")
        case .notSamePassword: return String(localized: "error-message-notSamePassword", comment: "An error message displayed, when repeat password doen't match orignial password.")
        case .internalErrorSignIn: return String(localized: "error-message-internalErrorSignIn", comment: "An error message displayed, when an error while signing in occured.")
        case .internalErrorLogIn: return String(localized: "error-message-internalErrorLogIn", comment: "An error message displayed, when an error while logging in occured.")
        case .internalErrorSave: return String(localized: "error-message-internalErrorSave", comment: "An error message displayed, when an error while saving occured.")
        case .alreadySignedInEmail: return String(localized: "error-message-alreadySignedInEmail", comment: "An error message displayed, when a person is already signed in with inputed email.")
        case .alreadySignedIn: return String(localized: "error-message-alreadySignedIn", comment: "An error message displayed, when a person is already signed in.")
        case .weakPassword: return String(localized: "error-message-weakPassword", comment: "An error message displayed, when the inputed password is too weak.")
        case .clubNotExists: return String(localized: "error-message-clubNotExists", comment: "An error message displayed, when no club with inputed club identfier exists.")
        case .noRegionGiven: return String(localized: "error-message-noRegionGiven", comment: "An error message displayed, when no region is given.")
        case .notEuro: return String(localized: "error-message-notEuro", comment: "An error message displayed, when inputed region doesn't have EUR as currency.")
        case .identifierAlreadyExists: return String(localized: "error-message-identifierAlreadyExists", comment: "An error message displayed, when a club with inputed club identfier already exists.")
        case .incorrectPassword: return String(localized: "error-message-incorrectPassword", comment: "An error message displayed, when inputed password is incorrect.")
        case .notSignedIn: return String(localized: "error-message-notSignedIn", comment: "An error message displayed, when person try to log in, that isn't signed in.")
        case .amountZero: return String(localized: "error-message-amountZero", comment: "An error message displayed, when inputed amount is zero.")
        case .futureDate: return String(localized: "error-message-futureDate", comment: "An error message displayed, when inputed date is in the future.")
        case .invalidNumberRange: return String(localized: "error-message-invalidNumberRange", comment: "An error message displayed, when inputed number isn't between 1 and 99.")
        case .internalErrorDelete: return String(localized: "error-message-internalErrorDelete", comment: "An error message displayed, when an error while deleting occured.")
        case .personUndeletable: return String(localized: "error-message-personUndeletable", comment: "An error message displayed, when person is undeletable cause person is already registred.")
        case .reasonUndeletable: return String(localized: "error-message-reasonUndeletable", comment: "An error message displayed, when reason is undeletable cause a fine uses this reason.")
        case .noPersonSelected: return String(localized: "error-message-noPersonSelected", comment: "An error message displayed, when no person is selected for fine add new.")
        case .noReasonGiven: return String(localized: "error-message-noReasonGiven", comment: "An error message displayed, when no reason is given for fine add new.")
        }
    }

    /// Message of the error
    var message: String {
        // "(\(rawValue + 1)) \(rawMessage)"
        rawMessage
    }
}
