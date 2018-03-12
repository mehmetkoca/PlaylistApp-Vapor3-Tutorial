import Vapor
import FluentSQLite

final class Genre: Codable {
    var id: Int?
    var name: String
    
    init(name: String) {
        self.name = name
    }
}

extension Genre: SQLiteModel {}
extension Genre: Migration {}
extension Genre: Content {}

extension Genre {
    // Song sınıfında yaptığımız gibi ilk parametremiz
    // extension yazdığımız model, ikincisi ilişki içerisinde olacağı model
    // üçüncüsü ile bağlantıyı sağlayacak modelimiz.
    var songs: Siblings<Genre, Song, SongGenrePivot> {
        return siblings()
    }
}
