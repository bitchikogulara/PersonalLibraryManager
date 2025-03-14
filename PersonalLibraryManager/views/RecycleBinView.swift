import SwiftUI

struct RecycleBinView: View {
    @EnvironmentObject var libraryData: LibraryData
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        NavigationView {
            VStack{
            if !libraryData.deletedBooks.isEmpty {
                Section {
                    VStack{
                        Text("➡️ Swipe right to restore.")
                            .font(.footnote)
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.trailing)
                            .frame(maxWidth: .infinity, alignment: .trailing)
                            .padding(.vertical, 2)
                            .padding(.trailing, 75)
                        Text("⬅️ Swipe left to permanently delete.")
                            .font(.footnote)
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.trailing)
                            .frame(maxWidth: .infinity, alignment: .trailing)
                            .padding(.vertical, 2)
                            .padding(.trailing, 9)
                    }
                }
            }
            List {
                if libraryData.deletedBooks.isEmpty {
                    Text("Recycle bin is empty.")
                        .foregroundColor(.gray)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding()
                } else {
                    Section(header: Text("Deleted Books")) {
                        ForEach(libraryData.deletedBooks) { book in
                            VStack(alignment: .leading) {
                                Text(book.title).font(.headline)
                                Text(book.author).font(.subheadline).foregroundColor(.secondary)
                                Text("Deleted: \(book.deletionDate!, formatter: dateFormatter)")
                                    .font(.caption)
                                    .foregroundColor(.red)
                            }
                            .padding(.vertical, 4)
                            .swipeActions(edge: .leading, allowsFullSwipe: true) {
                                Button {
                                    libraryData.restoreFromRecycleBin(book)
                                } label: {
                                    Label("Restore", systemImage: "arrow.uturn.backward")
                                }
                                .tint(.blue)
                            }
                            .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                Button {
                                    permanentlyDelete(book)
                                } label: {
                                    Label("Permanently Delete", systemImage: "trash")
                                }
                                .tint(.red)
                            }
                        }
                    }
                }
            }
            .listStyle(InsetGroupedListStyle())
            .navigationTitle("🗑️ Recycle Bin")
            .toolbar  {
                    Button("Close") {
                        presentationMode.wrappedValue.dismiss()
                    }
            }
            
        }
        }
    }

    private func permanentlyDelete(_ book: Book) {
            if let realIndex = libraryData.books.firstIndex(where: { $0.id == book.id }) {
                libraryData.books.remove(at: realIndex)
            }
        
        libraryData.saveBooks()
    }

    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter
    }
}

struct RecycleBinView_Previews: PreviewProvider {
    static var previews: some View {
            RecycleBinView()
                .environmentObject(LibraryData())
    }
}
