// User için UUID kullanacağımız için
// Foundation import ediyoruz
import Foundation
import FluentMySQL
import Vapor

final class User: Codable {
    // UUID, unique bir kullanıcı id'si üretecek.
    var id: UUID?
    var name: String
    var username: String
    
    init(name: String, username: String) {
        self.name = name
        self.username = username
    }
}

extension User: MySQLUUIDModel {}
extension User: Content {}
extension User: Migration {}

// Parent-Child ilişkisi tanımlandı
extension User {
    // User içerisinde computed property yaratıyoruz.
    // Children<> tipinde olan songs, User'ın birden fazla
    // song'u olabileceğini belirtiyor.
    var songs: Children<User, Song> {
        // geriye creatorID'nin children'ını döndürüyoruz.
        return children(\.creatorID)
    }
}
