//
//  SignInNameInput.swift
//  Strafen
//
//  Created by Steven on 10/26/20.
//

import SwiftUI

/// Sign in view for name input
struct SignInNameInput: View {
    
    /// Name credentials with first, last name and errors
    struct NameCredentials {
        
        /// First name
        var firstName: String = ""
        
        /// Last name
        var lastName: String = ""
        
        /// Type of first name textfield error
        var firstNameErrorMessages: ErrorMessages? = nil
        
        /// Set name from cached properties
        mutating func setFromCache() {
            let cacheProperty = SignInCache.shared.cachedStatus?.property as! SignInCache.PropertyUserId
            if let firstName = cacheProperty.name.givenName, let lastName = cacheProperty.name.familyName {
                Logging.shared.log(with: .info, "Got cached name: \(firstName) \(lastName)")
            }
            firstName = cacheProperty.name.givenName ?? ""
            lastName = cacheProperty.name.familyName ?? ""
        }
        
        /// Check if first name is empty
        @discardableResult mutating func evaluteFirstNameError() -> Bool {
            if firstName.isEmpty {
                Logging.shared.log(with: .debug, "First name textfield is empty.")
                firstNameErrorMessages = .emptyField(code: 5)
            } else {
                firstNameErrorMessages = nil
                return false
            }
            return true
        }
        
        /// Check if any errors occurs
        mutating func checkErrors() -> Bool {
            evaluteFirstNameError()
        }
    }
    
    /// Name credential
    @State var nameCredentials = NameCredentials()
    
    /// Indicates if navigation link to club selection is active
    @State var isNavigationLinkActive = false
    
    /// Size of sign in email view
    @State var screenSize: CGSize?
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                
                /// Navigation link to club selection
                EmptyNavigationLink(swipeBack: false, isActive: $isNavigationLinkActive) {
                    SignInClubSelection()
                }
                
                VStack(spacing: 0) {
                    
                    // Bar to wipe sheet down
                    SheetBar()
                                
                    // Header
                    Header("Registrieren")
                    
                    Spacer()
                    
                    // Name input
                    NameInputTextfields(nameCredentials: $nameCredentials)
                    
                    Spacer()
                    
                    // Confirm Button
                    ConfirmButton()
                        .title("Weiter")
                        .onButtonPress(handleConfirmPress)
                        .padding(.bottom, 50)
                    
                }
            }.screenSize($screenSize, geometry: geometry)
        }.onAppear {
            nameCredentials.setFromCache()
        }
    }
    
    /// Handles confirm button press
    func handleConfirmPress() {
        guard !nameCredentials.checkErrors() else { return }
        let oldCacheProperty = SignInCache.shared.cachedStatus?.property as! SignInCache.PropertyUserId
        let name = PersonName(firstName: nameCredentials.firstName, lastName: nameCredentials.lastName)
        let cacheProperty = SignInCache.PropertyUserIdName(userId: oldCacheProperty, name: name)
        let state: SignInCache.Status = .clubSelection(property: cacheProperty)
        Logging.shared.log(with: .info, "Set cached to to: \(state)")
        SignInCache.shared.setState(to: state)
        isNavigationLinkActive = true
    }
    
    /// Name input textfields
    struct NameInputTextfields: View {
        
        /// Name credential
        @Binding var nameCredentials: NameCredentials
        
        var body: some View {
            VStack(spacing: 20) {
                
                // Text
                Text("Dein Name wird für die Registrierung benötigt.")
                    .configurate(size: 20)
                    .padding(.horizontal, 20)
                    .lineLimit(2)
                
                // Name input
                VStack(spacing: 5) {
                    
                    // Title
                    Title("Name")
                    
                    // name input
                    VStack(spacing: 10) {
                        
                        // First name input
                        CustomTextField()
                            .title("Vorname")
                            .textBinding($nameCredentials.firstName)
                            .errorMessages($nameCredentials.firstNameErrorMessages)
                            .textFieldSize(width: UIScreen.main.bounds.width * 0.95, height: 50)
                            .onCompletion {
                                nameCredentials.evaluteFirstNameError()
                            }
                        
                        // Last name input
                        CustomTextField()
                            .title("Nachname (optional)")
                            .textBinding($nameCredentials.lastName)
                            .textFieldSize(width: UIScreen.main.bounds.width * 0.95, height: 50)
                        
                    }
                }
                
            }.animation(.default)
                .keyboardAdaptiveOffset
        }
    }
}
