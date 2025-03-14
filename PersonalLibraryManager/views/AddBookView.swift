import SwiftUI

struct AddBookView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject private var libraryData: LibraryData
    
    @State private var title = ""
    @State private var author = ""
    @State private var status: BookStatus = .wantToRead
    @State private var progressBar: Double = 0.0
    @State private var notes: String = ""

    @State private var showingImagePicker = false
    @State private var selectedUIImage: UIImage?
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Book Info").font(.headline).foregroundColor(.blue) ) {
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
                        Slider(value: $progressBar, in: 0...1)
                    }.padding(5)
                }
                
                Section(header: Text("Notes").font(.headline).foregroundColor(.blue)) {
                                        TextEditor(text: $notes)
                                            .frame(height: 120)
                                            .padding(10)
                                            .cornerRadius(10)
                                    }.padding(5)
                
                Section(header: Text("Book Cover").font(.headline).foregroundColor(.blue)) {
                    Button(action: {
                                                showingImagePicker = true
                                            }) {
                                                Text(selectedUIImage == nil ? "Select Cover Image" : "Change Image")
                                                    .foregroundColor(.blue)
                                                    .padding(5)
                                                    .frame(maxWidth: .infinity)
                                                    .background(Color(.systemGray6))
                                                    .cornerRadius(10)
                                            }

                                            if let uiImage = selectedUIImage {
                                                HStack {
                                                    Spacer()
                                                    Image(uiImage: uiImage)
                                                        .resizable()
                                                        .scaledToFit()
                                                        .frame(height: 200)
                                                        .clipShape(RoundedRectangle(cornerRadius: 10))
                                                        .shadow(radius: 3)
                                                    Spacer()
                                                }
                                            }
                                }.padding(5)
                
                Section {
                    Button("Save Book") {
                        saveBook()
                    }
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(title.isEmpty || author.isEmpty ? Color.gray : Color.blue)
                    .cornerRadius(10)
                }
            }
            .navigationTitle("📖 Add Book")
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

struct AddBookView_Previews: PreviewProvider {
    static var previews: some View {
        AddBookView()
            .environmentObject(LibraryData())
    }
}
