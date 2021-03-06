//
//  FineReason.swift
//  Strafen
//
//  Created by Steven on 11/7/20.
//

import Foundation

/// Protocol of fine reason for reason / amount / importance or templateId
protocol FineReason {
    
    /// Reason
    func reason(with reasonList: [ReasonTemplate]?) -> String
    
    /// Amount
    func amount(with reasonList: [ReasonTemplate]?) -> Amount
    
    /// Importance
    func importance(with reasonList: [ReasonTemplate]?) -> Importance
    
    #if TARGET_MAIN_APP
    /// Parameters for database change call
    var callParameters: Parameters { get }
    #endif
}

extension FineReason {
    
    /// Complete reason
    func complete(with reasonList: [ReasonTemplate]?) -> FineReasonCustom {
        FineReasonCustom(reason: reason(with: reasonList),
                       amount: amount(with: reasonList),
                       importance: importance(with: reasonList))
    }
}

/// Fine Reason for reason / amount / importance
struct FineReasonCustom: FineReason, Equatable {
    
    /// Reason
    let reason: String
    
    /// Amount
    let amount: Amount
    
    /// Importance
    let importance: Importance
    
    /// Reason
    func reason(with reasonList: [ReasonTemplate]?) -> String { reason }
    
    /// Amount
    func amount(with reasonList: [ReasonTemplate]?) -> Amount { amount }
    
    /// Importance
    func importance(with reasonList: [ReasonTemplate]?) -> Importance { importance }
    
    #if TARGET_MAIN_APP
    /// Parameters for database change call
    var callParameters: Parameters {
        Parameters { parameters in
            parameters["reason"] = reason
            parameters["amount"] = amount
            parameters["importance"] = importance
        }
    }
    #endif
}

/// Fine Reason for templateId
struct FineReasonTemplate: FineReason, Equatable {
    
    /// Template id
    let templateId: ReasonTemplate.ID
    
    /// Reason
    func reason(with reasonList: [ReasonTemplate]?) -> String {
        reasonList?.first(where: { $0.id == templateId })?.reason ?? ""
    }
    
    /// Amount
    func amount(with reasonList: [ReasonTemplate]?) -> Amount {
        reasonList?.first(where: { $0.id == templateId })?.amount ?? .zero
    }
    
    /// Importance
    func importance(with reasonList: [ReasonTemplate]?) -> Importance {
        reasonList?.first(where: { $0.id == templateId })?.importance ?? .low
    }
    
    #if TARGET_MAIN_APP
    /// Parameters for database change call
    var callParameters: Parameters {
        Parameters { parameters in
            parameters["templateId"] = templateId
        }
    }
    #endif
}

/// Codable fine reason to get custom or template fine reason
struct CodableFineReason: Decodable {
    
    /// Reason
    let reason: String?
    
    /// Amount
    let amount: Amount?
    
    /// Importance
    let importance: Importance?
    
    /// Template id
    let templateId: ReasonTemplate.ID?
    
    /// Custom or template fine reason
    var fineReason: FineReason {
        if let templateId = templateId {
            return FineReasonTemplate(templateId: templateId)
        } else if let reason = reason,
                  let amount = amount,
                  let importance = importance {
            return FineReasonCustom(reason: reason, amount: amount, importance: importance)
        } else {
            fatalError("No template id and no properties for custom fine reason.")
        }
    }
}
