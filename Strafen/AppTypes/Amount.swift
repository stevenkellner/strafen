//
//  Amount.swift
//  Strafen
//
//  Created by Steven on 11/8/20.
//

import SwiftUI

/// Stores an amount
struct Amount {
    
    /// Value of the amount
    @NonNegative private var value: Int = .zero
    
    /// Value of the subunit of this amount
    @Clamping(0...99) private var subUnitValue: Int = .zero
    
    /// Init with euro and cent
    init(_ value: Int, subUnit: Int) {
        self.value = value
        self.subUnitValue = subUnit
    }
    
    /// Double value
    var doubleValue: Double {
        Double(value) + Double(subUnitValue) / 100
    }
    
    /// String value
    var stringValue: String {
        if subUnitValue == 0 {
            return "\(value)"
        } else if (1..<10).contains(subUnitValue) {
            return "\(value),0\(subUnitValue)"
        } else {
            return "\(value),\(subUnitValue)"
        }
    }
    
    var forPayment: String {
        if subUnitValue == 0 {
            return "\(value).00"
        } else if (1..<10).contains(subUnitValue) {
            return "\(value).0\(subUnitValue)"
        } else {
            return "\(value).\(subUnitValue)"
        }
    }
    
    /// Is zero
    var isZero: Bool {
        value == 0 && subUnitValue == 0
    }
}

// Extension of Amount to confirm to CustomStringConvertible
extension Amount: CustomStringConvertible {
    
    /// Locale
    static var locale: Locale {
        let countryCodeKey = Settings.shared.person?.clubProperties.regionCode ?? "DE"
        let languageCodeKey = Locale.current.languageCode ?? "de"
        let identifier = Locale.identifier(fromComponents: [
            "kCFLocaleCountryCodeKey": countryCodeKey,
            "kCFLocaleLanguageCodeKey": languageCodeKey
        ])
        return Locale(identifier: identifier)
    }
    
    /// Description
    var description: String {
        let numberFormatter = NumberFormatter()
        numberFormatter.locale = Amount.locale
        numberFormatter.numberStyle = .currency
        return numberFormatter.string(from: NSNumber(value: doubleValue)) ?? numberFormatter.string(from: 0)!
    }
}

// Extension of Amount to confirm to CustomDebugStringConvertible
extension Amount: CustomDebugStringConvertible {
    
    /// Debug description
    var debugDescription: String {
        let numberFormatter = NumberFormatter()
        numberFormatter.locale = Locale.current
        numberFormatter.numberStyle = .currency
        return numberFormatter.string(from: NSNumber(value: doubleValue)) ?? numberFormatter.string(from: 0)!
    }
}

// Extension of Amount to confirm to AdditiveArithmetic
extension Amount: AdditiveArithmetic {
    static var zero: Amount {
        Amount(.zero, subUnit: .zero)
    }
    
    static func +(lhs: Amount, rhs: Amount) -> Amount {
        let newSubUnitValue = lhs.subUnitValue + rhs.subUnitValue
        let value = lhs.value + rhs.value + newSubUnitValue / 100
        let subUnitValue = newSubUnitValue % 100
        return Amount(value, subUnit: subUnitValue)
    }
    
    static func -(lhs: Amount, rhs: Amount) -> Amount {
        let newSubUnitValue = lhs.subUnitValue - rhs.subUnitValue
        let value = lhs.value - rhs.value - (newSubUnitValue >= 0 ? 0 : 1)
        let subUnitValue = (newSubUnitValue + 100) % 100
        guard value >= 0 else { return .zero }
        return Amount(value, subUnit: subUnitValue)
    }
}

// Extension of Amount to confirm to VectorArithmetic
extension Amount: VectorArithmetic {
    
    /// Multiplies each component of this value by the given value.
    mutating func scale(by rhs: Double) {
        self *= rhs
    }

    /// Returns the dot-product of this vector arithmetic instance with itself.
    var magnitudeSquared: Double {
        doubleValue.magnitudeSquared
    }
}

// Extension of Amount to multiply with an Int
extension Amount {
    static func *(amount: Amount, multiplier: Int) -> Amount {
        let multiplier = abs(multiplier)
        let value = amount.value * multiplier + (amount.subUnitValue * multiplier) / 100
        let subUnitValue = (amount.subUnitValue * multiplier) % 100
        return Amount(value, subUnit: subUnitValue)
    }
    
    static func *(amount: Amount, multiplier: Double) -> Amount {
        let multiplier = abs(multiplier)
        let doubleValue = amount.doubleValue * multiplier
        let value = Int(doubleValue)
        let subUnitValue = Int(doubleValue * 100) - value * 100
        return Amount(value, subUnit: subUnitValue)
    }
    
    static func *= (amount: inout Amount, multiplier: Int) {
        amount = amount * multiplier
    }
    
    static func *= (amount: inout Amount, multiplier: Double) {
        amount = amount * multiplier
    }
}

// Extension of Amount to confirm to Equatable
extension Amount: Equatable {
    static func ==(lhs: Amount, rhs: Amount) -> Bool {
        lhs.value == rhs.value && lhs.subUnitValue == rhs.subUnitValue
    }
}

// Extension of Amount to confirm to Comparable
extension Amount: Comparable {
    static func <(lhs: Amount, rhs: Amount) -> Bool {
        if lhs.value < rhs.value {
            return true
        } else if lhs.value == rhs.value && lhs.subUnitValue < rhs.subUnitValue {
            return true
        }
        return false
    }
}

// Extension of Amount to confirm to Decodable
extension Amount: Decodable {
    
    init(doubleValue: Double) {
        let doubleValue = abs(doubleValue)
        self.value = Int(doubleValue)
        self.subUnitValue = Int(doubleValue * 100) - value * 100
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let rawAmount = try container.decode(Double.self)
        
        // Check if amount is positive
        guard rawAmount >= 0 else {
            throw DecodingError.dataCorruptedError(in: container, debugDescription: "Amount is negative.")
        }
        
        self.init(doubleValue: rawAmount)
    }
}

// Extension of Amount to confirm to Encodable
extension Amount: Encodable {
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(doubleValue)
    }
}

#if TARGET_MAIN_APP
// Extension of Amount to confirm to ParameterableObject
extension Amount: ParameterableObject {
    
    // Object call with Firebase function as Parameter
    var parameterableObject: _ParameterableObject {
        doubleValue
    }
}
#endif
