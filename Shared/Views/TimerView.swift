//
//  TimerView.swift
//  MobPro
//
//  Created by Tom Phillips on 7/7/22.
//

import SwiftUI

struct TimerView: View {
    @EnvironmentObject var vm: MobSessionManager
    var body: some View {
        ZStack {
            Circle()
                .foregroundColor(vm.isOnBreak ? .mobOrange : .mobGreen)
                .padding()
                .animation(.default, value: vm.isOnBreak)
                .animation(.default, value: vm.mobTimer.isTimerRunning)
                .opacity(vm.isTeamValid ? 1 : 0.5)
                .onTapGesture {
                    if vm.isTeamValid {
                        withAnimation {
                            vm.timerTapped()
                        }
                    }
                }
            VStack {
                
                if vm.isOnBreak {
                    Text("BREAK")
                }
                
                Text(vm.timerText)
                    .padding()
                
                if !vm.isOnBreak {
                    Button(action: {
                        withAnimation {
                            vm.timerTapped()
                        }
                    }, label: {
                        Image(systemName: vm.mobTimer.isTimerRunning ? "pause.fill" : "play.fill")
                    })
                    .disabled(!vm.isTeamValid)
                }
            }
            .font(.largeTitle)
            .foregroundColor(.white)
        }
    }
}

struct TimerView_Previews: PreviewProvider {
    static var previews: some View {
        TimerView()
            .environmentObject(MobSessionManager())
    }
}
