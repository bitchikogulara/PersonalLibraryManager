import SwiftUI

struct BookDetailView: View {
    @EnvironmentObject var libraryData: LibraryData
    @Environment(\.presentationMode) var presentationMode

    @State private var title: String
    @State private var author: String
    @State private var notes: String
    @State private var status: BookStatus
    @State private var progress: Double
    @State private var selectedUIImage: UIImage?
    @State private var showingImagePicker = false

    private var book: Book

    init(book: Book) {
        self.book = book
        _title = State(initialValue: book.title)
        _author = State(initialValue: book.author)
        _notes = State(initialValue: book.notes ?? "")
        _status = State(initialValue: book.status)
        _progress = State(initialValue: book.progress)
        
        if let imageData = book.coverImageData {
            _selectedUIImage = State(initialValue: UIImage(data: imageData))
        }
    }

    var body: some View {
        
        Form {
            if let uiImage = selectedUIImage {
                HStack {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFit()
                        .frame(height: 250)
                        .cornerRadius(10)
                        .padding()
                }
                .frame(maxWidth: .infinity, alignment: .center)
                
            }

            Section(header: Text("Book Cover").font(.headline).foregroundColor(.blue)) {
                Button(selectedUIImage == nil ? "Select Cover Image" : "Change Image") {
                    showingImagePicker = true
                }
            }.padding(5)

            Section(header: Text("Book Info").font(.headline).foregroundColor(.blue)) {
                TextField("Title", text: $title)
                TextField("Author", text: $author)
                Picker("Status", selection: $status) {
                    ForEach(BookStatus.allCases, id: \.self) { status in
                        Text(status.rawValue).tag(status)
                    }
                }
            }.padding(5)

            if status == .reading {
                Section(header: Text("Reading Progress").font(.headline).foregroundColor(.blue)) {
                    Slider(value: $progress, in: 0...1)
                }.padding(5)
            }
            
            
            
            Section(header: Text("Notes").font(.headline).foregroundColor(.blue)) {
                TextEditor(text: $notes)
                    .frame(height: 120)
            }.padding(5)

            Section {
                Button("Save Changes") {
                    saveChanges()
                    presentationMode.wrappedValue.dismiss()
                    }
                }.foregroundColor(.white)
                .padding()
                .frame(maxWidth: .infinity)
                .background(title.isEmpty || author.isEmpty ? Color.gray : Color.blue)
                .cornerRadius(10)
            }
            .navigationTitle("📖 Edit Book")
            .sheet(isPresented: $showingImagePicker) {
                ImagePicker(selectedImage: $selectedUIImage, sourceType: .photoLibrary)
            }
    }

    private func saveChanges() {
        if let index = libraryData.books.firstIndex(where: { $0.id == book.id }) {
            libraryData.books[index].title = title
            libraryData.books[index].author = author
            libraryData.books[index].status = status
            libraryData.books[index].notes = notes
            libraryData.books[index].progress = (status == .read) ? 1.0 : progress
            
            if let uiImage = selectedUIImage {
                libraryData.books[index].coverImageData = uiImage.jpegData(compressionQuality: 0.8)
            }

            libraryData.saveBooks()
        }
    }
}

struct BookDetailView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            BookDetailView(book: Book.sampleBooks[0])
                .environmentObject(LibraryData())
        }
    }
}
