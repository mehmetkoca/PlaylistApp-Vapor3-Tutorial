import FluentSQLite
import Vapor

final class Song: Codable {
    var id: Int?
    var artist: String
    var title: String
    
    init(artist: String, title: String) {
        self.artist = artist
        self.title = title
    }
}
// Song sınıfını model olarak görmesini sağladık
extension Song: SQLiteModel {}
extension Song: Content {}
extension Song: Migration {}
