//
//  SignInEmailView.swift
//  Strafen
//
//  Created by Steven on 10.05.21.
//

import SwiftUI
import FirebaseAuth

/// View to input email properties and name
struct SignInEmailView: View {

    // MARK: input properties

    /// Contains all properties of the textfield inputs
    struct InputProperties: InputPropertiesProtocol {

        /// All textfields
        enum TextFields: Int, TextFieldsProtocol {
            case firstName, lastName, email, password, repeatPassword
        }

        var inputProperties = [TextFields: String]()

        var errorMessages = [TextFields: ErrorMessages]()

        var firstResponders = TextFieldFirstResponders<TextFields>()

        /// Validates the first name input and sets associated error messages
        /// - Parameter setErrorMessage: Indicates whether error message will be set
        /// - Returns: result of this validation
        private mutating func validateFirstName(setErrorMessage: Bool = true) -> ValidationResult {
            var errorMessage: ErrorMessages?
            if self[.firstName].isEmpty {
                errorMessage = .emptyField
            } else {
                if setErrorMessage { self[error: .firstName] = nil }
                return .valid
            }
            if setErrorMessage { self[error: .firstName] = errorMessage }
            return .invalid
        }

        /// Validates the last name input and sets associated error messages
        /// - Parameter setErrorMessage: Indicates whether error message will be set
        /// - Returns: result of this validation
        private mutating func validateLastName(setErrorMessage: Bool = true) -> ValidationResult {
            if setErrorMessage { self[error: .lastName] = nil }
            return .valid
        }

        /// Validates the email input and sets associated error messages
        /// - Parameter setErrorMessage: Indicates whether error message will be set
        /// - Returns: result of this validation
        private mutating func validateEmail(setErrorMessage: Bool = true) -> ValidationResult {
            var errorMessage: ErrorMessages?
            if self[.email].isEmpty {
                errorMessage = .emptyField
            } else if !self[.email].isValidEmail {
                errorMessage = .invalidEmail
            } else {
                if setErrorMessage { self[error: .email] = nil }
                return .valid
            }
            if setErrorMessage { self[error: .email] = errorMessage }
            return .invalid
        }

        /// Validates the password input and sets associated error messages
        /// - Parameter setErrorMessage: Indicates whether error message will be set
        /// - Returns: result of this validation
        private mutating func validatePassword(setErrorMessage: Bool = true) -> ValidationResult {
            var errorMessage: ErrorMessages?
            let capitalPredicate = NSPredicate(format: "SELF MATCHES %@", ".*[A-Z]+.*")
            let lowerPredicate = NSPredicate(format: "SELF MATCHES %@", ".*[a-z]+.*")
            let digitPredicate = NSPredicate(format: "SELF MATCHES %@", ".*[0-9]+.*")
            if self[.password, trimm: nil].isEmpty {
                errorMessage = .emptyField
            } else if self[.password, trimm: nil].count < 8 {
                errorMessage = .tooFewCharacters
            } else if !capitalPredicate.evaluate(with: self[.password, trimm: nil]) {
                errorMessage = .noUpperCharacter
            } else if !lowerPredicate.evaluate(with: self[.password, trimm: nil]) {
                errorMessage = .noLowerCharacter
            } else if !digitPredicate.evaluate(with: self[.password, trimm: nil]) {
                errorMessage = .noDigit
            } else {
                if setErrorMessage { self[error: .password] = nil }
                return .valid
            }
            if setErrorMessage { self[error: .password] = errorMessage }
            return .invalid
        }

        /// Validates the repeat password input and sets associated error messages
        /// - Parameter setErrorMessage: Indicates whether error message will be set
        /// - Returns: result of this validation
        private mutating func validateRepeatPassword(setErrorMessage: Bool = true) -> ValidationResult {
            var errorMessage: ErrorMessages?
            if self[.repeatPassword, trimm: nil].isEmpty {
                errorMessage = .emptyField
            } else if self[.repeatPassword, trimm: nil] != self[.password, trimm: nil] {
                errorMessage = .notSamePassword
            } else {
                if setErrorMessage { self[error: .repeatPassword] = nil }
                return .valid
            }
            if setErrorMessage { self[error: .repeatPassword] = errorMessage }
            return .invalid
        }

        mutating func validateTextField(_ textfield: TextFields, setErrorMessage: Bool) -> ValidationResult {
            switch textfield {
            case .firstName: return validateFirstName(setErrorMessage: setErrorMessage)
            case .lastName: return validateLastName(setErrorMessage: setErrorMessage)
            case .email: return validateEmail(setErrorMessage: setErrorMessage)
            case .password: return validatePassword(setErrorMessage: setErrorMessage)
            case .repeatPassword: return validateRepeatPassword(setErrorMessage: setErrorMessage)
            }
        }

        /// State of continue button press
        var connectionState: ConnectionState = .notStarted

        /// Sign in property with userId and name
        var signInProperty: SignInProperty.UserIdName?

        /// Evaluates auth error and sets associated error messages
        /// - Parameter error: auth error
        mutating func evaluateErrorCode(of error: NSError) {
            guard error.domain == AuthErrorDomain else { return self[error: .email] = .internalErrorSignIn }
            let errorCode = AuthErrorCode(rawValue: error.code)
            switch errorCode {
            case .invalidEmail:
                self[error: .email] = .invalidEmail
            case .emailAlreadyInUse:
                self[error: .email] = .alreadySignedInEmail
            case .weakPassword:
                self[error: .password] = .weakPassword
            default:
                self[error: .email] = .internalErrorSignIn
            }
        }
    }

    // MARK: properties

    /// Sign in properties if not signed in with email
    let signInProperties: (name: PersonNameComponents, userId: String)?

    /// Init with sign in properties if not signed in with email
    /// - Parameter signInProperties: sign in properties
    init(_ signInProperties: (name: PersonNameComponents, userId: String)?) {
        self.signInProperties = signInProperties
        inputProperties[.firstName] = signInProperties?.name.givenName ?? ""
        inputProperties[.lastName] = signInProperties?.name.familyName ?? ""
    }

    /// All properties of the textfield inputs
    @State private var inputProperties = InputProperties()

    // MARK: body

    var body: some View {
        ZStack {

            if let signInProperty = inputProperties.signInProperty {
                EmptyNavigationLink {
                    SignInClubSelectionView(signInProperty: signInProperty)
                }
            }

            // Background color
            Color.backgroundGray

            // Content
            VStack(spacing: 0) {

                // Back button
                BackButton()
                    .padding(.top, 50)

                // Header
                Header("sign-in-header", table: .logInSignIn, comment: "Header of sign in views")
                    .padding(.top, 10)

                Spacer()

                ScrollView(showsIndicators: false) {
                    ScrollViewReader { proxy in
                        VStack(spacing: 15) {

                            if signInProperties != nil {
                                Text("name-is-required-message", table: .logInSignIn, comment: "Name is required message")
                                    .foregroundColor(.customRed)
                                    .font(.system(size: 24, weight: .regular))
                                    .multilineTextAlignment(.center)
                                    .lineLimit(2)
                                    .padding(.horizontal, 15)
                                    .padding(.top, 30)
                            }

                            // Name
                            TitledContent("name", table: .logInSignIn, comment: "name text") {
                                VStack(spacing: 5) {

                                    // First name
                                    CustomTextField(.firstName, inputProperties: $inputProperties)
                                        .placeholder("first-name", table: .logInSignIn, comment: "first name text")
                                        .defaultTextFieldSize
                                        .scrollViewProxy(proxy)

                                    // Last name
                                    CustomTextField(.lastName, inputProperties: $inputProperties)
                                        .placeholder("optional-last-name", table: .logInSignIn, comment: "optional last name text")
                                        .defaultTextFieldSize
                                        .scrollViewProxy(proxy)

                                }
                            }

                            if signInProperties == nil {

                                // Email
                                TitledContent("email", table: .logInSignIn, comment: "email text") {
                                    CustomTextField(.email, inputProperties: $inputProperties)
                                        .placeholder("email", table: .logInSignIn, comment: "email text")
                                        .defaultTextFieldSize
                                        .scrollViewProxy(proxy)

                                }

                                // Password
                                TitledContent("password", table: .logInSignIn, comment: "password text") {
                                    VStack(spacing: 5) {

                                        // Password
                                        CustomTextField(.password, inputProperties: $inputProperties)
                                            .placeholder("password", table: .logInSignIn, comment: "password text")
                                            .defaultTextFieldSize
                                            .scrollViewProxy(proxy)
                                            .secure

                                        // Repeat password
                                        CustomTextField(.repeatPassword, inputProperties: $inputProperties)
                                            .placeholder("repeat-password", table: .logInSignIn, comment: "repeat password text")
                                            .defaultTextFieldSize
                                            .scrollViewProxy(proxy)
                                            .secure

                                    }
                                }

                            }
                        }.padding(.vertical, 10)
                    }
                }

                Spacer()

                // Continue button
                SingleButton.continue
                    .connectionState($inputProperties.connectionState)
                    .onClick(perform: handleContinueButtonPress)
                    .padding(.bottom, 55)

            }

        }.maxFrame
            .onAppear { inputProperties.signInProperty = nil }
    }

    /// Handles the click on the continue button
    func handleContinueButtonPress() async {
        await Self.handleContinueButtonPress(userId: signInProperties?.userId, inputProperties: $inputProperties)
    }

    /// Handles the click on the continue button
    /// - Parameter userId: userId if not signed in with email
    /// - Parameter inputProperties: binding of the input properties
    static func handleContinueButtonPress(userId: String?, inputProperties: Binding<InputProperties>) async {
        guard inputProperties.wrappedValue.connectionState.restart() == .passed else { return }
        if let userId = userId {
            guard inputProperties.wrappedValue.validateTextFields([.firstName, .lastName]) == .valid else {
                return inputProperties.wrappedValue.connectionState.failed()
            }
            let name = PersonName(firstName: inputProperties.wrappedValue[.firstName], lastName: inputProperties.wrappedValue[.lastName])
            inputProperties.wrappedValue.signInProperty = SignInProperty.UserIdName(userId: userId, name: name)
            inputProperties.wrappedValue.connectionState.passed()
        } else {
            guard inputProperties.wrappedValue.validateAllInputs() == .valid else {
                return inputProperties.wrappedValue.connectionState.failed()
            }
            do {
                let result = try await Auth.auth().createUser(withEmail: inputProperties.wrappedValue[.email], password: inputProperties.wrappedValue[.password, trimm: nil])
                async {
                    try? await Auth.auth().currentUser?.sendEmailVerification()
                }
                let name = PersonName(firstName: inputProperties.wrappedValue[.firstName], lastName: inputProperties.wrappedValue[.lastName])
                inputProperties.wrappedValue.signInProperty = SignInProperty.UserIdName(userId: result.user.uid, name: name)
                inputProperties.wrappedValue.connectionState.passed()
            } catch {
                inputProperties.wrappedValue.evaluateErrorCode(of: error as NSError)
                inputProperties.wrappedValue.connectionState.failed()
            }
        }
    }
}
