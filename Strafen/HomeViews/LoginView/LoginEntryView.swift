//
//  LoginView.swift
//  Strafen
//
//  Created by Steven on 27.06.20.
//

import SwiftUI

/// First View in login for switching between login view
struct LoginEntryView: View {
    
    /// Indicates if sign in sheet is shown
    @State var showSignInSheet = false
    
    /// Indicates if cached sign in view is shown
    @State var showCachedState = false
    
    var body: some View {        
        ZStack {
            
            // Sheet for sign in
            EmptySheetLink(isPresented: $showSignInSheet) {
                SignInView(showSignInSheet: $showSignInSheet)
            } onDismiss: {
                
                // Get cached status
                if let cachedStatus = SignInCache.shared.cachedStatus {
                    Logging.shared.log(with: .info, "Show cached sheet, since cached state isn't nil.")
                    Logging.shared.log(with: .info, "Cached state: \(cachedStatus)")
                    
                    // Show cached state sheet if a state is cached
                    showCachedState = true
                }
            }


            // Sheet for sign in with cached properties
            EmptySheetLink(isPresented: $showCachedState) {
                SignInCacheView(state: SignInCache.shared.cachedStatus)
            }
            
            // Login View
            LoginView(showSignInSheet: $showSignInSheet, showCachedState: $showCachedState)
                
        }.onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                
                // Get cached status
                if let cachedStatus = SignInCache.shared.cachedStatus {
                    Logging.shared.log(with: .info, "Show cached sheet, since cached state isn't nil.")
                    Logging.shared.log(with: .info, "Cached state: \(cachedStatus)")
                    
                    // Show cached state sheet if a state is cached
                    showCachedState = true
                } else {
                    showCachedState = false
                }
            }
            
        }
    }
}
