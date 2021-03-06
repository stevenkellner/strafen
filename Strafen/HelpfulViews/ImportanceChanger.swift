//
//  ImportanceChanger.swift
//  Strafen
//
//  Created by Steven on 16.07.20.
//

import SwiftUI

/// Bar to change between the differnt importance types
struct ImportanceChanger: View {
    
    /// Importance to change
    @Binding var importance: Importance
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                HStack(spacing: 0) {
                    
                    // Left Part
                    Outline(.left)
                        .fillColor(Color.custom.red, onlyDefault: false)
                        .frame(width: geometry.size.width / 3, height: geometry.size.height)
                        .setOnTapGesture($importance, to: .high, animation: .default)
                    
                    // Middle Part
                    Outline(.none)
                        .fillColor(Color.custom.orange, onlyDefault: false)
                        .frame(width: geometry.size.width / 3, height: geometry.size.height)
                        .setOnTapGesture($importance, to: .medium, animation: .default)
                    
                    // Right Part
                    Outline(.right)
                        .fillColor(Color.custom.yellow, onlyDefault: false)
                        .frame(width: geometry.size.width / 3, height: geometry.size.height)
                        .setOnTapGesture($importance, to: .low, animation: .default)
                    
                }
                
                // Indicator
                Indicator(width: geometry.size.width / 8)
                    .offset(x: importance == .high ? -geometry.size.width / 3 : importance == .low ? geometry.size.width / 3 : 0)
                
            }
        }
    }
}

/// Bar to change between the the boolean types
struct BooleanChanger: View {
    
    /// Boolean to change
    @Binding var boolToChange: Bool
    
    /// Color scheme to get appearance of this device
    @Environment(\.colorScheme) var colorScheme
    
    /// Observed Object that contains all settings of the app of this device
    @ObservedObject var settings = Settings.shared
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                
                // Bar
                HStack(spacing: 0) {
                    
                    // Left Part
                    Outline(.left)
                        .fillColor(Color.custom.lightGreen, onlyDefault: false)
                        .frame(width: geometry.size.width / 2, height: geometry.size.height)
                        .onTapGesture {
                            withAnimation {
                                boolToChange = true
                            }
                        }
                    
                    // Right Part
                    Outline(.right)
                        .fillColor(Color.custom.red, onlyDefault: false)
                        .frame(width: geometry.size.width / 2, height: geometry.size.height)
                        .onTapGesture {
                            withAnimation {
                                boolToChange = false
                            }
                        }
                }
                
                // Indicator
                RoundedCorners()
                    .strokeColor(.textColor)
                    .lineWidth(2.5)
                    .radius(2.5)
                    .frame(width: geometry.size.width / 8, height: 2.5)
                    .offset(x: geometry.size.width / 4 * (boolToChange ? -1 : 1))
                
            }
        }
    }
}
