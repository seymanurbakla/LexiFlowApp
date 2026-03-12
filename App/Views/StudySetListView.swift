import SwiftUI

struct StudySetListView: View {
    @EnvironmentObject var store: StudySetStore
    @State private var showingEditSheet = false
    @State private var selection = Set<UUID>()
    @AppStorage("appLanguage") private var appLanguage = "tr"
    
    var body: some View {
        NavigationStack {
            List(selection: $selection) {
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
            .navigationTitle(NSLocalizedString("Your Study Sets", comment: ""))
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    HStack {
                        EditButton()
                        Button(action: { showingEditSheet = true }) {
                            Image(systemName: "plus")
                        }
                    }
                }
                
                ToolbarItem(placement: .navigationBarLeading) {
                    Menu {
                        Picker(NSLocalizedString("Language", comment: ""), selection: $appLanguage) {
                            Text(NSLocalizedString("English", comment: "")).tag("en")
                            Text(NSLocalizedString("Türkçe", comment: "")).tag("tr")
                        }
                    } label: {
                        Image(systemName: "gearshape")
                    }
                }
            }
            .safeAreaInset(edge: .bottom) {
                if selection.count > 1 {
                    NavigationLink(destination: TestSessionView(studySets: store.studySets.filter { selection.contains($0.id) }, store: store)) {
                        Text(String(format: NSLocalizedString("Mix & Test (%d sets)", comment: ""), selection.count))
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.indigo)
                            .cornerRadius(10)
                            .padding()
                            .shadow(radius: 5)
                        
                    }
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                    .animation(.spring(), value: selection.count)
                }
            }
            .sheet(isPresented: $showingEditSheet) {
                NavigationStack {
                    EditStudySetView(studySet: StudySet(title: ""))
                }
            }
        }
    }
}
