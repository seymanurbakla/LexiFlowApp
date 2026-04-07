import Foundation
import SwiftUI

class StatsManager: ObservableObject {
    static let shared = StatsManager()
    
    @AppStorage("currentStreak") var currentStreak: Int = 0
    @AppStorage("studiedSetsCount") var studiedSetsCount: Int = 0
    @AppStorage("lastStudyDateString") private var lastStudyDateString: String = ""
    
    @AppStorage("wordsLearnedToday") var wordsLearnedToday: Int = 0
    @AppStorage("lastWordLearnedDateString") private var lastWordLearnedDateString: String = ""
    
    private init() {
        checkDailyResets()
    }
    
    // Call this whenever a session ends or starts
    func logStudySession() {
        studiedSetsCount += 1
        
        let today = DateFormatter.localizedString(from: Date(), dateStyle: .short, timeStyle: .none)
        
        if lastStudyDateString == today {
            // Already studied today, streak stays the same
            return
        }
        
        if isYesterday(dateString: lastStudyDateString) {
            // Studied yesterday, increment streak
            currentStreak += 1
        } else if lastStudyDateString.isEmpty {
            // First time studying
            currentStreak = 1
        } else {
            // Missed a day, streak resets to 1
            currentStreak = 1
        }
        
        lastStudyDateString = today
    }
    
    // Call this whenever a card is swiped right
    func logWordLearned() {
        let today = DateFormatter.localizedString(from: Date(), dateStyle: .short, timeStyle: .none)
        if lastWordLearnedDateString != today {
            wordsLearnedToday = 0
            lastWordLearnedDateString = today
        }
        wordsLearnedToday += 1
    }
    
    private func isYesterday(dateString: String) -> Bool {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .none
        
        guard let lastDate = formatter.date(from: dateString) else { return false }
        
        let calendar = Calendar.current
        return calendar.isDateInYesterday(lastDate)
    }
    
    private func checkDailyResets() {
        let today = DateFormatter.localizedString(from: Date(), dateStyle: .short, timeStyle: .none)
        
        // Reset words learned today if it's a new day
        if lastWordLearnedDateString != today {
            wordsLearnedToday = 0
        }
        
        // Check streak
        if lastStudyDateString.isEmpty || lastStudyDateString == today {
            return
        }
        
        if !isYesterday(dateString: lastStudyDateString) {
            // Missed a day before today, streak broken
            currentStreak = 0
        }
    }
}
