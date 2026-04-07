import SwiftUI

struct StatsView: View {
    @StateObject private var stats = StatsManager.shared
    @EnvironmentObject var store: StudySetStore
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Streak Card
                VStack(spacing: 12) {
                    Image(systemName: "flame.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.orange)
                        .padding(.top)
                    
                    Text("\(stats.currentStreak) Days")
                        .font(.system(size: 40, weight: .bold, design: .rounded))
                    
                    Text("Current Study Streak")
                        .font(.headline)
                        .foregroundColor(.secondary)
                        .padding(.bottom)
                }
                .frame(maxWidth: .infinity)
                .background(Color(UIColor.secondarySystemGroupedBackground))
                .cornerRadius(16)
                .shadow(color: Color.black.opacity(0.05), radius: 5, y: 3)
                
                // Words Learned Today Card
                VStack(spacing: 12) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 50))
                        .foregroundColor(.green)
                        .padding(.top)
                    
                    Text("\(stats.wordsLearnedToday)")
                        .font(.system(size: 40, weight: .bold, design: .rounded))
                    
                    Text("Words Learned Today")
                        .font(.headline)
                        .foregroundColor(.secondary)
                        .padding(.bottom)
                }
                .frame(maxWidth: .infinity)
                .background(Color(UIColor.secondarySystemGroupedBackground))
                .cornerRadius(16)
                .shadow(color: Color.black.opacity(0.05), radius: 5, y: 3)
                
                // Overall Stats Grid
                let allCards = store.studySets.flatMap { $0.cards }
                let totalLearned = allCards.filter { $0.isKnown }.count
                let totalLearning = allCards.count - totalLearned
                
                HStack(spacing: 16) {
                    StatBox(title: "Total Learned", value: "\(totalLearned)", icon: "brain.head.profile", color: .blue)
                    StatBox(title: "In Progress", value: "\(totalLearning)", icon: "book.fill", color: .orange)
                }
            }
            .padding()
        }
        .background(Color(UIColor.systemGroupedBackground))
        .navigationTitle("Your Progress")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct StatBox: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            
            Text(value)
                .font(.title)
                .fontWeight(.bold)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(UIColor.secondarySystemGroupedBackground))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 5, y: 3)
    }
}
