import SwiftUI

struct AddBookView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject private var libraryData: LibraryData
    
    // User input fields
    @State private var title = ""
    @State private var author = ""
    @State private var status: BookStatus = .wantToRead
    @State private var progressBar: Double = 0.0

    @State private var showingImagePicker = false
    @State private var selectedUIImage: UIImage?
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Book Info")) {
                    TextField("Title", text: $title)
                    TextField("Author", text: $author)
                    Picker("Status", selection: $status) {
                        ForEach(BookStatus.allCases, id: \.self) { status in
                            Text(status.rawValue).tag(status)
                        }
                    }
                }
                
                if status == .reading {
                    Section(header: Text("Reading Progress")) {
                        Slider(value: $progressBar, in: 0...1)
                    }
                }
                
                Section(header: Text("Book Cover")) {
                                    Button(action: {
                                        showingImagePicker = true
                                    }) {
                                        Text(selectedUIImage == nil ? "Select Cover Image" : "Change Image")
                                    }

                                    if let uiImage = selectedUIImage {
                                        Image(uiImage: uiImage)
                                            .resizable()
                                            .scaledToFit()
                                            .frame(height: 200)
                                    }
                                }
                
                Section {
                    Button("Save Book") {
                        saveBook()
                    }
                    .disabled(title.isEmpty || author.isEmpty)
                }
            }
            .navigationTitle("Add Book")
            .navigationBarItems(trailing: Button("Cancel") {
                presentationMode.wrappedValue.dismiss()
            })
        }
        .sheet(isPresented: $showingImagePicker) {
                        ImagePicker(selectedImage: $selectedUIImage, sourceType: .photoLibrary)
                    }
    }

    private func saveBook() {
        let imageData = selectedUIImage?.jpegData(compressionQuality: 0.8)
        
        let newBook = Book(
            id: UUID(),
            title: title,
            author: author,
            status: status,
            coverImageData: imageData,
            notes: nil,
            progress: progressBar,
            addedDate: Date(),
            deletionDate: nil
        )

        libraryData.books.append(newBook)
        libraryData.saveBooks()
        
        presentationMode.wrappedValue.dismiss()
    }
}

// MARK: - Preview
struct AddBookView_Previews: PreviewProvider {
    static var previews: some View {
        AddBookView()
            .environmentObject(LibraryData())
    }
}
