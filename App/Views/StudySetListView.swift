import SwiftUI

struct StudySetListView: View {
    @EnvironmentObject var store: StudySetStore
    @State private var showingEditSheet = false
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(store.studySets) { set in
                    NavigationLink(destination: StudySetDetailView(studySetID: set.id)) {
                        VStack(alignment: .leading, spacing: 5) {
                            Text(set.title)
                                .font(.headline)
                            Text("\(set.cards.count) cards")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        .padding(.vertical, 4)
                    }
                }
                .onDelete { indexSet in
                    indexSet.map { store.studySets[$0] }.forEach { store.deleteStudySet($0) }
                }
            }
            .navigationTitle("Your Study Sets")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingEditSheet = true }) {
                        Image(systemName: "plus")
                    }
                }
                #if os(iOS)
                ToolbarItem(placement: .navigationBarLeading) {
                    EditButton()
                }
                #endif
            }
            .sheet(isPresented: $showingEditSheet) {
                NavigationStack {
                    EditStudySetView(studySet: StudySet(title: ""))
                }
            }
        }
    }
}
