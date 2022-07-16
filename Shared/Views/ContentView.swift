//
//  ContentView.swift
//  Shared
//
//  Created by Tom Phillips on 7/7/22.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var vm: MobSessionManager
    @State private var editMode = EditMode.inactive
    @State private var showingEndSessionAlert = false
    
    var body: some View {
        NavigationView {
            VStack {
                if vm.isEditing {
                    ConfigureSessionView()
                } else {
                    RotationLabel()
                    if vm.mobTimer.isTimerRunning {
                        TimerCountdown()
                    } else {
                        TimerView()
                    }
                }
                HStack {
                    Spacer()
                    
                    if !vm.mobTimer.isTimerRunning {
                        shuffleButton
                    }
                }
                
                TeamMemberList()
                    .environment(\.editMode, $editMode)
                
                if vm.isEditing {
                    RoundedRectangleButton(label: "End Mobbing Session", color: .mobRed) {
                        showingEndSessionAlert = true
                    }
                    .padding()
                }
            }
            .toolbar {
                logo
                toggleSettingsButton
            }
            .alert("Are You Sure You Want to End Your Mobbing Session?", isPresented: $showingEndSessionAlert) {
                Button("Cancel", role: .cancel) {
                    showingEndSessionAlert = false
                }
                Button("End Session", role: .destructive) {
                    vm.endSession()
                }
            }
        }
    }
    
    var shuffleButton: some View {
        SymbolButton(action: {
            withAnimation {
                vm.shuffleTeam()
            }
        }, symbolName: "shuffle", color: .mobOrange)
        .font(.title)
        .padding(.trailing, 30)
    }
}

// MARK: Navigation Toolbar Items
extension ContentView {
    var logo: some ToolbarContent {
        ToolbarItem(placement: .principal) {
            Image("MobProLogo")
        }
    }
    
    var toggleSettingsButton: some ToolbarContent {
        ToolbarItem(placement: .navigationBarTrailing) {
            Button(action: {
                withAnimation {
                    if editMode == .inactive {
                        editMode = .active
                    } else if editMode == .active{
                        editMode = .inactive
                    }
                    vm.isEditing.toggle()
                }
            }, label: {
                if vm.isEditing {
                    Text("Save")
                        .foregroundColor(.mobGreen)
                } else {
                    Image(systemName: "gear")
                }
            })
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(MobSessionManager())
    }
}
