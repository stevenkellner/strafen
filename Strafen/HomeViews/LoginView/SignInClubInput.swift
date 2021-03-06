//
//  SignInClubInput.swift
//  Strafen
//
//  Created by Steven on 10/26/20.
//

import SwiftUI
import FirebaseFunctions

/// View to input all club properties
struct SignInClubInput: View {
    
    // MARK: Club Credentials
    /// Club credentials
    struct ClubCredentials {
        
        /// Club name
        var clubName: String = ""
        
        /// Club identifier
        var clubIdentifier: String = ""
        
        /// Region code
        var regionCode: String?
        
        /// Is in app payment active
        var inAppPaymentActive: Bool = false
        
        /// Club image
        var image: UIImage? = nil
        
        /// Type of club name textfield error
        var clubNameErrorMessages: ErrorMessages? = nil
        
        /// Type of club identifier error
        var clubIdentifierErrorMessages: ErrorMessages? = nil
        
        /// Type of region code error
        var regionCodeErrorMessages: ErrorMessages? = nil
        
        /// Type of activate in app payment error
        var activateInAppPaymentErrorMessage: ErrorMessages? = nil
        
        /// Check if club name is empty
        @discardableResult mutating func evaluteClubNameError() -> Bool {
            if clubName.isEmpty {
                Logging.shared.log(with: .debug, "Club name textfield is empty.")
                clubNameErrorMessages = .emptyField(code: 11)
            } else {
                clubNameErrorMessages = nil
                return false
            }
            return true
        }
        
        /// Check if club identifier is empty
        @discardableResult mutating func evaluateClubIdentifierError() -> Bool {
            if clubIdentifier.isEmpty {
                Logging.shared.log(with: .debug, "Club identifier textfield is empty.")
                clubIdentifierErrorMessages = .emptyField(code: 12)
            } else {
                clubIdentifierErrorMessages = nil
                return false
            }
            return true
        }
        
        /// Check if an error in region code occurs
        @discardableResult mutating func evalutateRegionCodeError() -> Bool {
            if regionCode == nil {
                Logging.shared.log(with: .debug, "Region code textfield is empty.")
                regionCodeErrorMessages = .noRegionGiven
            } else {
                regionCodeErrorMessages = nil
                return false
            }
            return true
        }
        
        /// Check if an error in activate in app payment occurs
        @discardableResult mutating func evalutateActivateInAppPaymantError() -> Bool {
            if inAppPaymentActive, let regionCode = regionCode {
                let languageCodeKey = Locale.current.languageCode ?? "de"
                let identifier = Locale.identifier(fromComponents: [
                    "kCFLocaleCountryCodeKey": regionCode,
                    "kCFLocaleLanguageCodeKey": languageCodeKey
                ])
                let locale = Locale(identifier: identifier)
                if locale.currencyCode != "EUR" {
                    activateInAppPaymentErrorMessage = .notEuro
                    return true
                }
            }
            activateInAppPaymentErrorMessage = nil
            return false
        }
        
        /// Check if any errors occurs
        mutating func checkErrors() -> Bool {
            evaluteClubNameError() |!| evaluateClubIdentifierError() |!| evalutateRegionCodeError() |!| evalutateActivateInAppPaymantError()
        }
    }
    
    // MARK: properties
    
    /// Club credentials
    @State var clubCredentials = ClubCredentials()
    
    /// State of the connection
    @State var connectionState: ConnectionState = .passed
    
    /// Progess of image upload
    @State var imageUploadProgess: Double? = nil
    
    /// Screen size of this view
    @State var screenSize: CGSize?
    
    // MARK: body
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                
                // Back button
                BackButton()
                
                VStack(spacing: 0) {
                    
                    // Bar to wipe sheet down
                    SheetBar()
                    
                    // Header
                    Header("Neuer Verein")
                        .padding(.top, 30)
                    
                    // Club properties input
                    ClubPropertiesInput(clubCredentials: $clubCredentials, imageUploadProgess: $imageUploadProgess)
                        .animation(.default)
                    
                    Spacer()
                    
                    // Confirm Button
                    ConfirmButton()
                        .title("Erstellen")
                        .connectionState($connectionState)
                        .onButtonPress(handleConfirmButton)
                        .padding(.bottom, 50)
                    
                }
            }.screenSize($screenSize, geometry: geometry)
        }
    }
    
    /// Handles confirm button press
    func handleConfirmButton() {
        guard connectionState != .loading else { return }
        connectionState = .loading
        Logging.shared.log(with: .info, "Started to create club.")
        
        guard !clubCredentials.checkErrors() else {
            return connectionState = .failed
        }
        
        // Id of new club
        let clubId = Club.ID(rawValue: UUID())
        
        // Check if club identifer already exists
        checkClubIdentifierExists {
                
            // Set club image
            setClubImage(of: clubId) {
                
                // Create new club in database
                createNewClub(of: clubId)
                
            }
        }
    }
    
    /// Checks if club identifier already exists
    func checkClubIdentifierExists(doesnotExistsHandler: @escaping () -> Void) {
        let existClubCallItem = ClubIdentifierAlreadyExistsCall(identifier: clubCredentials.clubIdentifier)
        FunctionCaller.shared.call(existClubCallItem) { (clubExists: ClubIdentifierAlreadyExistsCall.CallResult) in
            Logging.shared.log(with: .info, "Club does\(clubExists ? "" : "n't") already exists.")
            if !clubExists {
                doesnotExistsHandler()
            } else {
                clubCredentials.clubIdentifierErrorMessages = .identifierAlreadyExists(code: 1)
                connectionState = .failed
            }
        } failedHandler: { error in
            Logging.shared.log(with: .error, "An error occurs, that isn't handled: \(error.localizedDescription)")
            clubCredentials.clubNameErrorMessages = .internalErrorSignIn(code: 10)
            connectionState = .failed
        }
    }
    
    /// Set club image
    func setClubImage(of clubId: Club.ID, completionHandler: @escaping () -> Void) {
        let dispatchGroup = DispatchGroup()
        if let image = clubCredentials.image {
            imageUploadProgess = .zero
            dispatchGroup.enter()
            Logging.shared.log(with: .info, "Started to upload image.")
            ImageStorage.shared.store(image, of: .clubImage(clubId: clubId)) { _ in
                
                // Success
                Logging.shared.log(with: .info, "Successfully uploaded image.")
                dispatchGroup.leave()
                imageUploadProgess = nil
            
            // An error occurs
            } failedHandler: { error in
                Logging.shared.log(with: .error, "An error occurs, that isn't handled: \(error.localizedDescription)")
                clubCredentials.clubNameErrorMessages = .internalErrorSignIn(code: 11)
                connectionState = .failed
                imageUploadProgess = nil
                
            } progressChangeHandler: { progress in
                imageUploadProgess = progress
            }
        }
        dispatchGroup.notify(queue: .main) {
            completionHandler()
        }
    }
    
    /// Create new club in database
    func createNewClub(of clubId: Club.ID) {
        
        // New club call item
        let cachedProperty = SignInCache.shared.cachedStatus?.property as! SignInCache.PropertyUserIdName
        let personId = Person.ID(rawValue: UUID())
        let callItem = NewClubCall(cachedProperties: cachedProperty, clubCredentials: clubCredentials, clubId: clubId, personId: personId)
        
        // Create new club in database
        FunctionCaller.shared.call(callItem) { _ in
            
            Logging.shared.log(with: .info, "Successfully created club in database.")
            connectionState = .passed
            imageUploadProgess = nil
            SignInCache.shared.setState(to: nil)
            let clubProperties = Settings.Person.ClubProperties(id: clubId, name: clubCredentials.clubName, identifier: clubCredentials.clubIdentifier, regionCode: clubCredentials.regionCode!, inAppPaymentActive: clubCredentials.inAppPaymentActive)
            Settings.shared.person = .init(clubProperties: clubProperties, id: personId, name: cachedProperty.name, signInDate: Date(), isCashier: true)
            
        } failedHandler: { error in
            handleCallError(error)
        }
        
    }
    
    /// Handles error of get club id call
    func handleCallError(_ _error: Error) {
        
        // Get function error code
        guard let error = _error as NSError?, error.domain == FunctionsErrorDomain else {
            Logging.shared.log(with: .error, "An error occurs, that isn't handled: \(_error.localizedDescription)")
            return clubCredentials.clubNameErrorMessages = .internalErrorSignIn(code: 12)
        }
        let errorCode = FunctionsErrorCode(rawValue: error.code)
        
        switch errorCode {
        case .alreadyExists:
            Logging.shared.log(with: .debug, "Club identifier already exists.")
            clubCredentials.clubIdentifierErrorMessages = .identifierAlreadyExists(code: 2)
        default:
            Logging.shared.log(with: .error, "An error occurs, that isn't handled: \(error.localizedDescription)")
            clubCredentials.clubNameErrorMessages = .internalErrorSignIn(code: 13)
        }
        connectionState = .failed
        imageUploadProgess = nil
    }
    
    // MARK: Club Properties Input
    /// Club properties input
    struct ClubPropertiesInput: View {
        
        /// Club credentials
        @Binding var clubCredentials: ClubCredentials
        
        /// Progess of image upload
        @Binding var imageUploadProgess: Double?
        
        var body: some View {
            ScrollView {
                VStack(spacing: 20) {
                    
                    // Image
                    VStack(spacing: 5) {
                        
                        ImageSelector(image: $clubCredentials.image, uploadProgress: $imageUploadProgess)
                            .frame(width: 150, height: 150)
                            .padding(.bottom, 20)
                        
                        // Progress bar
                        if let imageUploadProgess = imageUploadProgess {
                            VStack(spacing: 5) {
                                Text("Bild hochladen")
                                    .configurate(size: 15)
                                    .padding(.horizontal, 20)
                                    .lineLimit(1)
                                ProgressView(value: imageUploadProgess)
                                    .progressViewStyle(LinearProgressViewStyle())
                                    .frame(width: UIScreen.main.bounds.width * 0.95)
                            }
                        }
                    }
                    
                    // Club name
                    TitledContent("Vereinsname") {
                        CustomTextField()
                            .title("Vereinsname")
                            .textBinding($clubCredentials.clubName)
                            .errorMessages($clubCredentials.clubNameErrorMessages)
                            .textFieldSize(width: UIScreen.main.bounds.width * 0.95, height: 50)
                            .onCompletion {
                                clubCredentials.evaluteClubNameError()
                            }
                    }
                    
                    // Region code
                    TitledContent("Region", errorMessages: $clubCredentials.regionCodeErrorMessages) {
                        RegionInput(clubCredentials: $clubCredentials)
                    }
                    
                    // Aktivate in app payment
                    #if DoesntExist // TODO
                    VStack(spacing: 5) {
                        TitledContent("In App Payment", errorMessages: $clubCredentials.activateInAppPaymentErrorMessage) {
                            BooleanChanger(boolToChange: $clubCredentials.inAppPaymentActive)
                                .frame(width: UIScreen.main.bounds.width * 0.7, height: 25)
                        }
                        
                        Text("Wenn aktiv, können deine Mitspieler die Strafen in der App zahlen und du sie dann auszahlen lassen.")
                            .configurate(size: 20)
                            .padding(.horizontal, 20)
                            .lineLimit(3)
                    }
                    #endif
                    
                    // Club identifier
                    VStack(spacing: 5) {
                        TitledContent("Vereinskennung") {
                            CustomTextField()
                                .title("Vereinskennung")
                                .textBinding($clubCredentials.clubIdentifier)
                                .errorMessages($clubCredentials.clubIdentifierErrorMessages)
                                .textFieldSize(width: UIScreen.main.bounds.width * 0.95, height: 50)
                                .onCompletion {
                                    clubCredentials.evaluateClubIdentifierError()
                                }
                        }
                        
                        // Text
                        Text("Benutze die eindeutige Kennung um andere Spieler hinzuzufügen.")
                            .configurate(size: 20)
                            .padding(.horizontal, 20)
                            .lineLimit(2)
                        
                    }
                    
                }.padding(.vertical, 10)
                .keyboardAdaptiveOffset
            }.padding(.vertical, 10)
        }
    }
    
    // MARK: Region Input
    /// Region input
    struct RegionInput: View {
        
        /// Club credentials
        @Binding var clubCredentials: ClubCredentials
        
        var body: some View {
            ZStack {
                
                // Outline
                Outline()
                    .lineWidth(clubCredentials.regionCodeErrorMessages.map({ _ in CGFloat(2) }))
                    .strokeColor(clubCredentials.regionCodeErrorMessages.map({ _ in Color.custom.red }))
                
                // Picker
                Picker({ () -> String in
                    guard let regionCode = clubCredentials.regionCode else { return "Region auswählen" }
                    return Locale.regionName(of: regionCode)
                }(), selection: $clubCredentials.regionCode) {
                    ForEach(Locale.availableRegionCodes, id: \.self) { regionCode in
                        Text(Locale.regionName(of: regionCode))
                            .tag(regionCode as String?)
                    }
                }.pickerStyle(MenuPickerStyle())
                    .font(.text(20))
                    .foregroundColor(.textColor)
                    .lineLimit(1)
                
            }.frame(width: UIScreen.main.bounds.width * 0.95, height: 50)
                .onAppear {
                    if let regionCode = Locale.current.regionCode, Locale.availableRegionCodes.contains(regionCode) {
                        clubCredentials.regionCode = regionCode
                    }
                }
        }
    }
}
