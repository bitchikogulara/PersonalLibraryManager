import Foundation

class LibraryData: ObservableObject {
    @Published var books: [Book] = []

    private static let fileName = "books.json"

    init() {
        loadBooks()
        permanentlyDeleteOldBooks()
    }

    // Save books to JSON file
    func saveBooks() {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        if let data = try? encoder.encode(books) {
            let url = getDocumentsDirectory().appendingPathComponent(Self.fileName)
            try? data.write(to: url, options: [.atomicWrite])
        }
    }

    // Load books from JSON file
    func loadBooks() {
        let url = getDocumentsDirectory().appendingPathComponent(Self.fileName)
        if let data = try? Data(contentsOf: url) {
            let decoder = JSONDecoder()
            if let decodedBooks = try? decoder.decode([Book].self, from: data) {
                books = decodedBooks
                return
            }
        }
        books = Book.sampleBooks // If no saved data, load sample data
    }

    private func getDocumentsDirectory() -> URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
    
    var activeBooks: [Book] {
        books.filter { $0.deletionDate == nil }
    }

    var deletedBooks: [Book] {
        books.filter { $0.deletionDate != nil }
    }
    
    func moveToRecycleBin(_ book: Book) {
        if let index = books.firstIndex(where: { $0.id == book.id }),
           books[index].deletionDate == nil {  // ← ensure not already deleted
            books[index].deletionDate = Date()
            saveBooks()
        }
    }

    func restoreFromRecycleBin(_ book: Book) {
        if let index = books.firstIndex(where: { $0.id == book.id }),
           books[index].deletionDate != nil {
            books[index].deletionDate = nil
            saveBooks()
        }
    }

    func permanentlyDeleteOldBooks() {
        books.removeAll { book in
            if let deletionDate = book.deletionDate {
                return Date().timeIntervalSince(deletionDate) > (4 * 7 * 24 * 3600) // 4 weeks
            }
            return false
        }
        saveBooks()
    }

}
