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
    
    var body: some View {
        NavigationView {
            VStack {
                if vm.isEditing {                    
                    TabView {
                        ForEach(vm.session.configurations) { configuration in
                            let index = vm.session.configurations.firstIndex { $0.id == configuration.id}
                            CircleSelector(configuration: $vm.session.configurations[index!])
                                
                        }
                    }
                    .frame(minHeight: UIScreen.main.bounds.height * 0.42)
                    .tabViewStyle(.page(indexDisplayMode: .always))
                    .padding()
                    
                } else {
                    RotationLabel()
                    TimerView()
                }
                HStack {
                    Spacer()
                    
                    if !vm.mobTimer.isTimerRunning {
                        shuffleButton
                    }
                }
                
                TeamMemberList()
                    .environment(\.editMode, $editMode)
            }
            .toolbar {
                logo
                toggleSettingsButton
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
