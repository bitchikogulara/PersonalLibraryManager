import Foundation

// Enum for book reading status
enum BookStatus: String, Codable, CaseIterable {
    case read = "Read"
    case reading = "Currently Reading"
    case wantToRead = "Want to Read"
}

// Data model for books
struct Book: Identifiable, Codable {
    let id: UUID
    var title: String
    var author: String
    var status: BookStatus
    var coverImageData: Data?
    var notes: String?
    var progress: Double // 0.0 - 1.0 for progress
    var addedDate: Date
    var deletionDate: Date?
    
    // Sample book data for quick testing
    static var sampleBooks: [Book] {
        [
            Book(id: UUID(), title: "1984", author: "George Orwell", status: .read, coverImageData: nil, notes: "Classic dystopia.", progress: 1.0, addedDate: Date()),
            Book(id: UUID(), title: "Clean Code", author: "Robert C. Martin", status: .reading, coverImageData: nil, notes: "Important for developers.", progress: 0.4, addedDate: Date()),
            Book(id: UUID(), title: "The Swift Programming Language", author: "Apple Inc.", status: .wantToRead, coverImageData: nil, notes: "Official documentation.", progress: 0.0, addedDate: Date())
        ]
    }
}
