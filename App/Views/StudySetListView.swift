import SwiftUI
import UniformTypeIdentifiers

struct StudySetListView: View {
    @EnvironmentObject var store: StudySetStore
    @State private var showingMixSheet = false
    @State private var showingEditSheet = false
    @State private var showingImportSheet = false
    @StateObject private var stats = StatsManager.shared
    
    var body: some View {
        NavigationStack {
            List {
                Section {
                    NavigationLink(destination: StatsView()) {
                        VStack(alignment: .leading, spacing: 6) {
                            Text("LEARNING ACTIVITY")
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .bold()
                            
                            HStack {
                                Label("\(stats.currentStreak) Days Streak", systemImage: "flame.fill")
                                    .foregroundColor(.orange)
                                    .font(.headline)
                                
                                Spacer()
                                
                                Label("\(stats.wordsLearnedToday) Learned Today", systemImage: "checkmark.seal.fill")
                                    .foregroundColor(.blue)
                                    .font(.subheadline)
                            }
                        }
                        .padding(.vertical, 4)
                    }
                }
                
                Section(header: Text("Your Packages")) {
                    ForEach(store.studySets) { set in
                        NavigationLink(destination: StudySetDetailView(studySetID: set.id)) {
                        VStack(alignment: .leading, spacing: 6) {
                            Text(set.title)
                                .font(.headline)
                            
                            let learnedCount = set.cards.filter { $0.isKnown }.count
                            let inProgressCount = set.cards.count - learnedCount
                            
                            HStack(spacing: 8) {
                                Text("\(set.cards.count) words")
                                    .foregroundColor(.secondary)
                                
                                if set.cards.count > 0 {
                                    Text("•")
                                        .foregroundColor(.secondary)
                                    Text("\(learnedCount) learned")
                                        .foregroundColor(.green)
                                    Text("•")
                                        .foregroundColor(.secondary)
                                    Text("\(inProgressCount) learning")
                                        .foregroundColor(.orange)
                                }
                            }
                            .font(.caption)
                        }
                        .padding(.vertical, 4)
                    }
                }
                .onDelete { indexSet in
                    indexSet.map { store.studySets[$0] }.forEach { store.deleteStudySet($0) }
                }
                } // End of Section
            }
            .navigationTitle("Your Study Sets")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Menu {
                        if let url = store.getExportURL() {
                            ShareLink(item: url) {
                                Label("Yedekle (Export)", systemImage: "square.and.arrow.up")
                            }
                        }
                        
                        Button(action: { showingImportSheet = true }) {
                            Label("Geri Yükle (Import)", systemImage: "square.and.arrow.down")
                        }
                    } label: {
                        Image(systemName: "folder.badge.gearshape")
                    }
                }
                
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
            .fileImporter(
                isPresented: $showingImportSheet,
                allowedContentTypes: [.json],
                allowsMultipleSelection: false
            ) { result in
                switch result {
                case .success(let urls):
                    if let fileURL = urls.first {
                        store.importData(from: fileURL)
                    }
                case .failure(let error):
                    print("Import error: \(error.localizedDescription)")
                }
            }
        }
    }
}
