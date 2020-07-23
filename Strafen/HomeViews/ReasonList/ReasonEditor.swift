//
//  ReasonEditor.swift
//  Strafen
//
//  Created by Steven on 17.07.20.
//

import SwiftUI

/// View to edit a reason
struct ReasonEditor: View {
    
    /// Reason to edit
    let reasonToEdit: Reason
    
    /// Presentation mode
    @Environment(\.presentationMode) var presentationMode
    
    /// Color scheme to get appearance of this device
    @Environment(\.colorScheme) var colorScheme
    
    /// Observed Object that contains all settings of the app of this device
    @ObservedObject var settings = Settings.shared
    
    /// Input importance
    @State var importance: Fine.Importance = .high
    
    /// Input reason
    @State var reason = ""
    
    /// Input amount
    @State var amount: Euro = .zero
    
    /// Input amount string
    @State var amountString = Euro.zero.stringValue
    
    /// Indicated if amount keyboard is on screen
    @State var isAmountKeyboardOnScreen = false
    
    /// Indicates if delete button is pressed and shows the delete alert
    @State var showDeleteAlert = false
    
    /// Indicates if confirm button is pressed and shows the confirm alert
    @State var showConfirmAlert = false
    
    var body: some View {
        VStack(spacing: 0) {
            
            // Bar to wipe sheet down
            SheetBar()
            
            // Title
            Header("Vorlage Ändern")
            
            Spacer()
            
            // Importance changer
            ImportanceChanger(importance: $importance)
                .frame(width: UIScreen.main.bounds.width * 0.7, height: 25)
            
            Spacer()
            
            // Reason
            CustomTextField("Grund", text: $reason)
                .frame(width: UIScreen.main.bounds.width * 0.95, height: 50)
            
            Spacer()
            
            // Amount
            HStack(spacing: 0) {
                
                // Text Field
                CustomTextField("Betrag", text: $amountString, keyboardType: .decimalPad, keyboardOnScreen: $isAmountKeyboardOnScreen) {
                    amount = amountString.euroValue
                    amountString = amount.stringValue
                }.frame(width: UIScreen.main.bounds.width * 0.45, height: 50)
                    .padding(.leading, 15)
                
                // € - Sign
                Text("€")
                    .frame(height: 50)
                    .foregroundColor(.textColor)
                    .font(.text(25))
                    .lineLimit(1)
                    .padding(.leading, 5)
                
                // Done button
                if isAmountKeyboardOnScreen {
                    Text("Fertig")
                        .foregroundColor(Color.custom.darkGreen)
                        .font(.text(25))
                        .lineLimit(1)
                        .padding(.leading, 15)
                        .onTapGesture {
                            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                        }
                }
                
            }
            
            
            Spacer()
                .alert(isPresented: $showDeleteAlert) {
                    if ListData.fine.list!.contains(where: { ($0.fineReason as? FineReasonTemplate)?.templateId == reasonToEdit.id }) {
                        return Alert(title: Text("Nicht Löschen"), message: Text("Die Vorlage kann nicht gelöscht werden, da es Strafen gibt, die diese Vorlage benutzt."), dismissButton: .default(Text("Verstanden")))
                    }
                    return Alert(title: Text("Vorlage Löschen"), message: Text("Möchtest du diese Vorlage wirklich löschen?"), primaryButton: .cancel(Text("Abbrechen")), secondaryButton: .destructive(Text("Löschen"), action: {
                        // TODO delete reason
                        presentationMode.wrappedValue.dismiss()
                    }))
                }
            
            // Delete / Confirm button
            DeleteConfirmButton {
                showDeleteAlert = true
            } confirmButtonHandler: {
                let newReason = Reason(reason: reason, id: reasonToEdit.id, amount: amount, importance: importance)
                if newReason == reasonToEdit {
                    presentationMode.wrappedValue.dismiss()
                } else {
                    showConfirmAlert = true
                }
            }.padding(.bottom, 50)
                .alert(isPresented: $showConfirmAlert) {
                    if reason.isEmpty {
                        return Alert(title: Text("Keinen Grund Angegeben"), message: Text("Bitte gebe einen Grund für diese Vorlage ein."), dismissButton: .default(Text("Verstanden")))
                    } else if amount == .zero {
                        return Alert(title: Text("Betrag ist Null"), message: Text("Bitte gebe einen Bertag ein, der nicht gleich Null ist."), dismissButton: .default(Text("Verstanden")))
                    }
                    return Alert(title: Text("Vorlage Hinzufügen"), message: Text("Möchtest du diese Vorlage wirklich hinzufügen?"), primaryButton: .destructive(Text("Abbrechen")), secondaryButton: .default(Text("Bestätigen"), action: {
                        let _ = Reason(reason: reason, id: reasonToEdit.id, amount: amount, importance: importance)
                        // TODO update reason
                        presentationMode.wrappedValue.dismiss()
                    }))
                }
            
        }.onAppear {
            reason = reasonToEdit.reason
            amount = reasonToEdit.amount
            amountString = reasonToEdit.amount.stringValue
            importance = reasonToEdit.importance
        }
    }
}