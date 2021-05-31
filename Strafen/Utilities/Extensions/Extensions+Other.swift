//
//  Extensions+Other.swift
//  Strafen
//
//  Created by Steven on 04.05.21.
//

import SwiftUI
import Hydra

extension UISceneConfiguration {

    /// Default configuration of UISceneConfiguration.
    /// - Parameter session: UISceneSession for session role
    /// - Returns: the default configuration
    static func `default`(session: UISceneSession) -> UISceneConfiguration {
        UISceneConfiguration(name: "Default Configuration", sessionRole: session.role)
    }
}

extension URL {

    /// Appends given url and returns combinding url
    /// - Parameter url: url to append
    /// - Returns: combinding url
    func appendingUrl(_ url: URL?) -> URL {
        guard let url = url else { return self }
        var newUrl = self
        for component in url.pathComponents {
            newUrl.appendPathComponent(component)
        }
        return newUrl
    }
}

extension Bundle {

    /// Contains content of a property list
    @dynamicMemberLookup struct PropertyListContent {

        /// Content of a property list
        private let content: [String: AnyObject]?

        /// Init content by the path to the property list
        /// - Parameter path: path to the property list
        init(path: String) {
            var format =  PropertyListSerialization.PropertyListFormat.xml
            let data = FileManager.default.contents(atPath: path)!
            content = try? PropertyListSerialization.propertyList(from: data, options: .mutableContainersAndLeaves, format: &format) as? [String: AnyObject]
        }

        /// Init content by the name of the property list
        /// - Parameter name: name of the property list in the bundle
        init?(name: String) {
            guard let path = Bundle.main.path(forResource: name, ofType: "plist") else { return nil }
            self.init(path: path)
        }

        /// Gets the content with given key
        /// - Parameter key: key of content
        /// - Returns: value of given key
        @inlinable subscript(dynamicMember key: String) -> AnyObject? {
            content?[key]
        }
    }

    /// Content of `KeysInfo` property list
    static var keysPropertyList: PropertyListContent {
        PropertyListContent(name: "KeysInfo")!
    }
}

extension Promise {

    /// Transforms value to Result.succes(value) and an error to Result.failure(error)
    /// - Parameter handler: code block to execute
    @discardableResult func thenResult(in context: Context? = nil, _ handler: @escaping (Result<Value, Error>) -> Void) -> Promise<Void> {
        then(in: context) { value in
            handler(.success(value))
        }.catch { error in
            handler(.failure(error))
        }
    }
}

extension Result {

    /// Optional error of the result
    var error: Failure? {
        guard case .failure(let error) = self else { return nil }
        return error
    }
}

extension CGPoint {

    /// Adds a CGSize to a CGPoint
    /// - Parameters:
    ///   - lhs: point to add to
    ///   - rhs: size to add to the point
    /// - Returns: new point
    public static func + (lhs: CGPoint, rhs: CGSize) -> CGPoint {
        CGPoint(x: lhs.x + rhs.width, y: lhs.y + rhs.height)
    }

    /// Subtracts a CGSize from a CGPoint
    /// - Parameters:
    ///   - lhs: point to subtract from
    ///   - rhs: size to subtract from the point
    /// - Returns: new point
    public static func - (lhs: CGPoint, rhs: CGSize) -> CGPoint {
        CGPoint(x: lhs.x - rhs.width, y: lhs.y - rhs.height)
    }
}

extension CGPoint {

    /// Adds a CGVector to a CGPoint
    /// - Parameters:
    ///   - lhs: point to add to
    ///   - rhs: vector to add to the point
    /// - Returns: new point
    public static func + (lhs: CGPoint, rhs: CGVector) -> CGPoint {
        CGPoint(x: lhs.x + rhs.dx, y: lhs.y + rhs.dy)
    }

    /// Subtracts a CGVector from a CGPoint
    /// - Parameters:
    ///   - lhs: point to subtract from
    ///   - rhs: vector to subtract from the point
    /// - Returns: new point
    public static func - (lhs: CGPoint, rhs: CGVector) -> CGPoint {
        CGPoint(x: lhs.x - rhs.dx, y: lhs.y - rhs.dy)
    }
}

extension CGSize {

    /// Multiplies a CGFloat to a CGSize
    /// - Parameters:
    ///   - lhs: size to multiply to
    ///   - rhs: number to multiply to the size
    /// - Returns: new size
    public static func * (lhs: CGSize, rhs: CGFloat) -> CGSize {
        CGSize(width: lhs.width * rhs, height: lhs.height * rhs)
    }
}

extension CGVector {

    /// Multiplies a CGFloat to a CGVector
    /// - Parameters:
    ///   - lhs: vector to multiply to
    ///   - rhs: number to multiply to the vector
    /// - Returns: new size
    public static func * (lhs: CGVector, rhs: CGFloat) -> CGVector {
        CGVector(dx: lhs.dx * rhs, dy: lhs.dy * rhs)
    }
}

extension Color {

    /// Init with red, green and blue vue from 0 to 255
    /// - Parameters:
    ///   - red: red color
    ///   - green: green color
    ///   - blue: blue color
    init(red: Int, green: Int, blue: Int) {
        self.init(red: Double(red) / 255, green: Double(green) / 255, blue: Double(blue) / 255)
    }

    /// Gray color of the background
    static let backgroundGray = Color(red: 47, green: 49, blue: 54)

    /// Gray color of the wave
    static let waveGray = Color(red: 70, green: 75, blue: 81)

    /// Gray color of buttons, textfields, etc.
    static let fieldGray = Color(red: 55, green: 57, blue: 63)

    /// Color of a text
    static let textColor = Color(red: 185, green: 187, blue: 190)

    /// Red color
    static let customRed = Color(red: 185, green: 83, blue: 79)

    /// Green color
    static let customGreen = Color(red: 95, green: 178, blue: 128)

    /// Blue color
    static let customBlue = Color(red: 78, green: 90, blue: 240)

    /// Orange color
    static let customOrange = Color(red: 249, green: 156, blue: 25)

    /// Yellow color
    static let customYellow = Color(red: 231, green: 197, blue: 5)

    /// Tab bar color
    static let tabBarColor = Color(red: 40, green: 40, blue: 40)

    /// Tab bar border color
    static let tabBarBorderColor = Color(red: 180, green: 180, blue: 180)
}

extension View {

    /// Sets frame to maximum and hide navigation bar
    var maxFrame: some View {
        navigationTitle("")
            .navigationBarHidden(true)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .edgesIgnoringSafeArea(.all)
    }

    /// Toggles given binding on tap gesture
    /// - Parameter binding: bool binding to toggle
    ///   - animation: animation on value change
    /// - Returns: modified view
    func toggleOnTapGesture(_ binding: Binding<Bool>, animation: Animation? = nil) -> some View {
        onTapGesture {
            guard let animation = animation else { return binding.wrappedValue.toggle() }
            withAnimation(animation) { binding.wrappedValue.toggle() }
        }
    }

    /// Sets binding to given value on tap gesture
    /// - Parameters:
    ///   - valueBinding: value binding to set
    ///   - newValue: new value
    ///   - animation: animation on value change
    /// - Returns: modified view
    func setOnTapGesture<T>(_ valueBinding: Binding<T>, to newValue: T, animation: Animation? = nil) -> some View {
        onTapGesture {
            guard let animation = animation else { return valueBinding.wrappedValue = newValue }
            withAnimation(animation) { valueBinding.wrappedValue = newValue }
        }
    }
}

extension UIApplication {

    /// Dismisses the keyboard
    func dismissKeyboard() {
        sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

extension String {

    /// Check if string is valid emial
    var isValidEmail: Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPred = NSPredicate(format: "SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: self)
    }
}

extension Bundle {

    /// Indicates whether build configuration is debug
    var isDebug: Bool {
        #if DEBUG
        true
        #else
        false
        #endif
    }
}

extension Locale {

    /// All available region codes with valid currency Symbol
    static var availableRegionCodes: [String] {
        availableIdentifiers.compactMap { identifier in
            guard let regionCode = Locale(identifier: identifier).regionCode else { return nil }
            let locale = Locale(identifier: Locale.identifier(fromComponents: ["kCFLocaleCountryCodeKey": regionCode]))
            guard locale.currencyCode != nil else { return nil }
            return regionCode
        }.unique.sorted { identifier in
            Locale.regionName(of: identifier)
        }
    }

    /// Region name of given region code
    /// - Parameter regionCode: region code
    /// - Returns: region name
    static func regionName(of regionCode: String) -> String {
        let regionName = Locale.current.localizedString(forRegionCode: regionCode)
        return regionName ?? regionCode
    }
}

extension CGPoint {

    /// Returns a point on a circle with this point as origin and
    /// given radius and angle starting on the right turning anitclockwise
    /// - Parameters:
    ///   - angle: angle starting on the right and turning anticlockwise
    ///   - radius: radius of the circle
    /// - Returns: point on the cirlce
    func onCircle(angle: Angle, radius: CGFloat) -> CGPoint {
        self + CGVector(dx: cos(angle.radians), dy: -sin(angle.radians)) * radius
    }
}

extension PersonNameComponents {

    /// Person name
    var personName: PersonName? {
        guard let firstName = givenName else { return nil }
        return PersonName(firstName: firstName, lastName: familyName)
    }
}

extension FileManager {

    /// Url of shared container
    var sharedContainerUrl: URL {
        FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.stevenkellner.Strafen.settings")!
    }
}

/// All available localization tables
enum LocalizationTables: String {

    /// Localization table for error messages
    case errorMessages = "ErrorMessages"

    /// Localization table for other texts
    case otherTexts = "OtherTexts"

    /// Localization table for log in and sign in views
    case logInSignIn = "LogIn-SignIn"

    /// Localization table for profile detail views
    case profileDetail = "ProfileDetail"
}

/// Localized string of given table with given key
/// - Parameters:
///   - key: key of localized string
///   - table: table of localization
///   - replaceDict: dictionary to replace for string interpolation
///   - comment: comment for localization
/// - Returns: localized string
func NSLocalizedString(_ key: String, table: LocalizationTables, replaceDict: [String: String] = [:], comment: String) -> String {
    var rawString = NSLocalizedString(key, tableName: table.rawValue, value: "(Error L.1) This text isn't available in your language.", comment: comment)
    for (key, value) in replaceDict {
        rawString = rawString.replacingOccurrences(of: "${\(key)}", with: value)
    }
    return rawString
}

extension Text {

    /// Init text with localized string
    /// - Parameters:
    ///   - key: key of lacalized string
    ///   - table: table of localization
    ///   - replaceDict: dictionary to replace for string interpolation   
    ///   - comment: comment for localization
    init(_ key: String, table: LocalizationTables, replaceDict: [String: String] = [:], comment: String) {
        self.init(NSLocalizedString(key, table: table, replaceDict: replaceDict, comment: comment))
    }
}

extension UIImage {

    /// Initializes and returns the image object with the specified data.
    /// - Parameter data: The data object containing the image data.

    convenience init?(data: Data?) {
        guard let data = data else { return nil }
        self.init(data: data)
    }
}

extension Text {

    /// Creates a text representing the given value.
    public init<Subject>(describing instance: Subject) {
        self.init(String(describing: instance))
    }

    /// Creates a text representing the given value.
    public init<Subject>(describing instance: Subject) where Subject: CustomStringConvertible {
        self.init(String(describing: instance))
    }

    /// Creates a text representing the given value.
    public init<Subject>(describing instance: Subject) where Subject: TextOutputStreamable {
        self.init(String(describing: instance))
    }

    /// Creates a text representing the given value.
    public init<Subject>(describing instance: Subject) where Subject: CustomStringConvertible, Subject: TextOutputStreamable {
        self.init(String(describing: instance))
    }
}

extension View {

    /// Positions this view within an invisible frame with the specified size.
    /// - Parameters:
    ///   - size: The size of this view
    ///   - alignment: The alignment of this view inside the resulting view. alignment applies if this view is smaller than the size given by the resulting frame.
    func frame(size: CGSize, alignment: Alignment = .center) -> some View {
        frame(width: size.width, height: size.width, alignment: alignment)
    }
}

extension Date {

    /// Formatted with long style
    var formattedLong: String {
        let formatter = DateFormatter()
        formatter.locale = Locale.current
        formatter.dateStyle = .long
        return formatter.string(from: self)
    }
}

/// Applies tap handler only if not nil
struct OptionalTapGesture: ViewModifier {

    /// Tap handler to execute on tap
    let tapHandler: (() -> Void)?

    func body(content: Content) -> some View {
        if let tapHandler = tapHandler {
            content.onTapGesture(perform: tapHandler)
        } else {
            content
        }
    }
}

extension View {

    /// Applies tap handler only if not nil
    /// - Parameter tapHandler: tap handler to execute on tap
    /// - Returns: modified view
    func optionalTapGesture(perform tapHandler: (() -> Void)?) -> some View {
        ModifiedContent(content: self, modifier: OptionalTapGesture(tapHandler: tapHandler))
    }
}
