//
//  MobSessionManager.swift
//  MobPro
//
//  Created by Tom Phillips on 7/7/22.
//

import Foundation
import UserNotifications

class MobSessionManager: ObservableObject {
    @Published var session = MobSession()
    @Published var mobTimer = MobTimer()
    @Published var isEditing = false
    @Published var currentRotationNumber = 1
    @Published var isOnBreak = false
    @Published var movedToBackgroundDate = Date()
    @Published var isKeyboardPresented = false

    var numberOfRoundsBeforeBreak: Int {
        session.numberOfRotationsBetweenBreaks.value / 60
    }
    
    var timerText: String {
        if mobTimer.isTimerRunning {
            return mobTimer.formattedTime
        } else {
            return "START"
        }
    }
    
    var isTeamValid: Bool {
        session.teamMembers.count > 1
    }
}

// MARK: Team Management Logic
extension MobSessionManager {
    
    func endSession() {
        currentRotationNumber = 1
        mobTimer.timer = nil
        mobTimer.timeRemaining = mobTimer.rotationLength.value
        isOnBreak = false
        isEditing = false
        session.teamMembers = []
    }
    
    func shuffleTeam() {
        session.teamMembers.shuffle()
        assignRoles()
    }
    
    func moveTeamMember(from source: IndexSet, to destination: Int) {
        session.teamMembers.move(fromOffsets: source, toOffset: destination)
        assignRoles()
    }
    
    private func setUpNewRotation() {
        if isOnBreak {
            endBreak()
        } else {
            setUpNextRound()
        }
        
        resetTimer()
        let isBreakTime = currentRotationNumber == numberOfRoundsBeforeBreak + 1
        
        if isBreakTime {
            startBreak()
        }
    }
    
    private func endBreak() {
        isOnBreak = false
        currentRotationNumber = 1
        mobTimer.timeRemaining = mobTimer.rotationLength.value
    }
    
    private func setUpNextRound() {
        currentRotationNumber += 1
        mobTimer.timeRemaining = mobTimer.rotationLength.value
        shiftTeam()
        assignRoles()
    }
    
    private func startBreak() {
        isOnBreak = true
        mobTimer.timeRemaining = session.breakLengthInSeconds.value
        startTimer()
    }

    private func shiftTeam() {
        session.teamMembers.shiftInPlace()
    }
    
    private func assignRoles() {
        for index in 0..<session.teamMembers.count {
            session.teamMembers[index].role = determineRole(for: index)
        }
    }

    private func determineRole(for index: Int) -> Role {
        switch index {
        case 0:
            return .driver
        case 1:
            return .navigator
        default:
            return .researcher
        }
    }
}

// MARK: CRUD Functions
extension MobSessionManager {
    func addMember(named name: String) {
        let indexOfNewMember = session.teamMembers.count
        let role = determineRole(for: indexOfNewMember)
        let memberToAdd = TeamMember(name: name, role: role)
        session.teamMembers.append(memberToAdd)
    }
    
    func delete(at offsets: IndexSet) {
        session.teamMembers.remove(atOffsets: offsets)
        assignRoles()
    }
    
    func delete(teamMember: TeamMember) {
        session.teamMembers.removeAll { $0.id == teamMember.id }
        assignRoles()
    }
}

// MARK: Timer Logic
extension MobSessionManager {
    func timerTapped() {
        if mobTimer.isTimerRunning {
            resetTimer()
        } else {
            startTimer()
            scheduleLocalNotification()
        }
    }
    
    private func startTimer() {
        mobTimer.timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            if self.mobTimer.timeRemaining == 0 {
                self.setUpNewRotation()
            } else {
                self.mobTimer.timeRemaining -= 1
            }
        }
    }

    private func resetTimer() {
        mobTimer.timer?.invalidate()
        mobTimer.timer = nil
    }
}

// MARK: Custom User Notifications
extension MobSessionManager {
    func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge , .sound]) { success, error in
            if success {
                print("Permission Granted!")
            } else if let error = error {
                print(error.localizedDescription)
            }
        }
    }
                      
    func movedToBackground() {
        print("Moving to the background")
        movedToBackgroundDate = Date()
        resetTimer()
    }
    
    func movingToForeGround() {
        print("Moving to the foreground")
        if mobTimer.timeRemaining < mobTimer.rotationLength.value {
            let deltaTime = Int(Date().timeIntervalSince(movedToBackgroundDate))
            
            mobTimer.timeRemaining = mobTimer.timeRemaining - deltaTime < 0 ? 0 : mobTimer.timeRemaining - deltaTime
            startTimer()
        }
    }
    
    func scheduleLocalNotification() {
        let content = UNMutableNotificationContent()
        content.title = "\(isOnBreak ? "Break" : "Round") has ended."
        content.sound = .default
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: Double(mobTimer.rotationLength.value), repeats: false)
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request)
    }
}
