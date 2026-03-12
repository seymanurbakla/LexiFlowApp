import SwiftUI

struct StudySetListView: View {
    @EnvironmentObject var store: StudySetStore
    @State private var showingMixSheet = false
    @EnvironmentObject var languageManager: AppLanguageManager
    
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
                    HStack {
                        Button(action: { showingMixSheet = true }) {
                            Text("Mix Sets")
                        }
                        
                        Button(action: { showingEditSheet = true }) {
                            Image(systemName: "plus")
                        }
                    }
                }
                
                ToolbarItem(placement: .navigationBarLeading) {
                    Menu {
                        Picker("Language", selection: $languageManager.storedLanguage) {
                            Text("English").tag("en")
                            Text("Türkçe").tag("tr")
                        }
                    } label: {
                        Image(systemName: "gearshape")
                    }
                }
            }

            .sheet(isPresented: $showingEditSheet) {
                NavigationStack {
                    EditStudySetView(studySet: StudySet(title: ""))
                }
            }
            .sheet(isPresented: $showingMixSheet) {
                MixSetsSelectionView()
                    .environmentObject(store)
            }
        }
    }
}
