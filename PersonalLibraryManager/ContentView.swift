import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var libraryData: LibraryData
    @State private var showingAddBook = false
    @State private var showingRecycleBin = false
    @State private var searchText = ""

    var body: some View {
        NavigationView {
            VStack{
                HStack{
                    TextField("Search books...", text: $searchText)
                        .padding(.leading,25)
                        .background(Color(.systemGray6))
                        .cornerRadius(10)
                        .overlay(
                            HStack {
                                Spacer()
                                if !searchText.isEmpty {
                                    Button(action: { searchText = "" }) {
                                        Image(systemName: "xmark.circle.fill")
                                            .foregroundColor(.gray)
                                    }
                                }
                            }
                        )
                    Section {
                            Text("⬅️ Swipe left to delete.")
                                .font(.footnote)
                                .foregroundColor(.gray)
                                .multilineTextAlignment(.trailing)
                                .frame(maxWidth: .infinity, alignment: .trailing)
                                .padding(.trailing, 9)
                    }
                }
                List {
                    bookSection(for: .reading )
                    bookSection(for: .wantToRead)
                    bookSection(for: .read)
                }
                .listStyle(InsetGroupedListStyle())
                .navigationTitle("📚 My Library")
            }
            .background(Color(.systemGray6).edgesIgnoringSafeArea(.all))
            .overlay(
                VStack {
                    Spacer()
                    HStack {
                        Button(action: { showingRecycleBin = true }) {
                            Image(systemName: "trash.circle.fill")
                                .resizable()
                                .frame(width: 50, height: 50)
                                .foregroundColor(.red)
                                .padding()
                                .background(Color.white)
                                .clipShape(Circle())
                                .shadow(radius: 5)
                        }
                        .padding(.leading, 20)
                        .padding(.bottom, 20)
                        
                        Spacer()
                        
                        Button(action: {
                            searchText = ""
                            showingAddBook = true
                        }) {
                            Image(systemName: "plus.circle.fill")
                                .resizable()
                                .frame(width: 50, height: 50)
                                .foregroundColor(.blue)
                                .padding()
                                .background(Color.white)
                                .clipShape(Circle())
                                .shadow(radius: 5)
                        }
                        .padding(.trailing, 20)
                        .padding(.bottom, 20)
                    }
                }
            )
            .sheet(isPresented: $showingAddBook) {
                AddBookView()
            }
            .sheet(isPresented: $showingRecycleBin) {
                RecycleBinView()
            }
        }
    }

    @ViewBuilder
    private func bookSection(for status: BookStatus) -> some View {
        let filteredBooks = libraryData.books.filter { book in
            book.status == status && book.deletionDate == nil && (searchText.isEmpty || book.title.localizedCaseInsensitiveContains(searchText) || book.author.localizedCaseInsensitiveContains(searchText))
        }

        Section(header: Text(status.rawValue).font(.headline).foregroundColor(.blue)) {
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
                                    .scaledToFill()
                                    .frame(width: 60, height: 60)
                                    .clipShape(RoundedRectangle(cornerRadius: 8))
                                    .shadow(radius: 3)
                                    .padding()
                            } else {
                                Image(systemName: "book.closed")
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 40)
                                    
                                    .foregroundColor(.gray)
                                    .shadow(radius: 3)
                                    .padding()
                            }
                            
                            VStack(alignment: .leading) {
                                Text(book.title)
                                    .font(.headline)
                                    .foregroundColor(.primary)
                                Text(book.author)
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)

                                if status == .reading {
                                    ProgressView(value: book.progress)
                                        .progressViewStyle(LinearProgressViewStyle())
                                        .accentColor(.blue)
                                }
                            }
                            .padding(.vertical, 4)
                        }
                        .padding(.vertical, 5)
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
