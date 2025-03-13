import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var libraryData: LibraryData
    @State private var showingAddBook = false
    @State private var showingRecycleBin = false
    @State private var searchText = ""

    var body: some View {
        NavigationView {
            VStack{
                
                TextField("Search books...", text: $searchText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                
                List {
                    bookSection(for: .reading )
                    bookSection(for: .wantToRead)
                    bookSection(for: .read)
                }
                .listStyle(InsetGroupedListStyle())
                .navigationTitle("My Library")
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action: {
                            searchText = ""
                            showingAddBook = true
                        }) {
                            Image(systemName: "plus")
                        }
                    }
                    
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button(action: {showingRecycleBin = true}) {
                            Image(systemName: "trash")
                        }
                    }
                }
                .sheet(isPresented: $showingAddBook) {
                    AddBookView()
                }
                .sheet(isPresented: $showingRecycleBin) {
                    RecycleBinView()
                }
            }
        }
    }

    @ViewBuilder
    private func bookSection(for status: BookStatus) -> some View {
        let filteredBooks = libraryData.books.filter { book in
            book.status == status && book.deletionDate == nil && (searchText.isEmpty || book.title.localizedCaseInsensitiveContains(searchText) || book.author.localizedCaseInsensitiveContains(searchText))
        }

        Section(header: Text(status.rawValue)) {
            if filteredBooks.isEmpty {
                Text("No books here yet.")
                    .foregroundColor(.gray)
            } else {
                ForEach(filteredBooks) { book in
                    NavigationLink(destination: BookDetailView(book: book)) {
                        HStack{
                            if let imageData = book.coverImageData,
                               let uiImage = UIImage(data: imageData) {
                                Image(uiImage: uiImage)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 50, height: 75)
                                    .cornerRadius(5)
                            } else {
                                Image(systemName: "book.closed")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 50, height: 75)
                                    .foregroundColor(.gray)
                            }
                            
                            VStack(alignment: .leading) {
                                Text(book.title)
                                    .font(.headline)
                                Text(book.author)
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)

                                if status == .reading {
                                    ProgressView(value: book.progress)
                                }
                            }
                            .padding(.vertical, 4)
                        }
                    }
                }
                .onDelete { indexSet in
                    deleteBooks(at: indexSet, from: filteredBooks)
                }
            }
        }
    }
    
    private func deleteBooks(at indexSet: IndexSet, from filteredBooks: [Book]) {
        for index in indexSet {
            let book = filteredBooks[index]
            libraryData.moveToRecycleBin(book)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(LibraryData())
    }
}
