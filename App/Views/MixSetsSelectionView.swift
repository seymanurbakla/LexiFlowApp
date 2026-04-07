import SwiftUI

struct MixSetsSelectionView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var store: StudySetStore
    @State private var selection = Set<UUID>()
    
    var body: some View {
        NavigationStack {
            List {
                Section(header: Text("Select Sets to Mix")) {
                    ForEach(store.studySets) { set in
                        Button(action: {
                            if selection.contains(set.id) {
                                selection.remove(set.id)
                            } else {
                                selection.insert(set.id)
                            }
                        }) {
                            HStack {
                                VStack(alignment: .leading) {
                                    Text(set.title)
                                        .font(.headline)
                                        .foregroundColor(.primary)
                                    Text("\(set.cards.count) cards")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                
                                Spacer()
                                
                                if selection.contains(set.id) {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(.blue)
                                        .font(.title3)
                                } else {
                                    Image(systemName: "circle")
                                        .foregroundColor(.gray)
                                        .font(.title3)
                                }
                            }
                            .contentShape(Rectangle())
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
            }
            .navigationTitle("Mix Everything")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
            .safeAreaInset(edge: .bottom) {
                if selection.count > 1 {
                    HStack(spacing: 10) {
                        NavigationLink(destination: TestSessionView(studySets: store.studySets.filter { selection.contains($0.id) }, store: store, isHardMode: false)) {
                            Text("Normal Mix")
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.indigo)
                                .cornerRadius(10)
                        }
                        
                        NavigationLink(destination: TestSessionView(studySets: store.studySets.filter { selection.contains($0.id) }, store: store, isHardMode: true)) {
                            Text("AI Mix")
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.purple)
                                .cornerRadius(10)
                        }
                    }
                    .padding(.horizontal)
                    .shadow(radius: 5)
                    .padding(.bottom, 20)
                } else {
                    Text("Select at least 2 sets.")
                        .foregroundColor(.secondary)
                        .padding()
                }
            }
        }
    }
}
