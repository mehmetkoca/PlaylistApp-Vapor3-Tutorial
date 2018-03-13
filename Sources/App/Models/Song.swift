import FluentMySQL
import Vapor

final class Song: Codable {
    var id: Int?
    var artist: String
    var title: String
    var creatorID: User.ID
    
    init(artist: String, title: String, creatorID: User.ID) {
        self.artist = artist
        self.title = title
        self.creatorID = creatorID
    }
}
// Song sınıfını model olarak görmesini sağladık
extension Song:  MySQLModel {}
extension Song: Content {}
extension Song: Migration {}

// Parent-Child ilişkisi tanımlandı
extension Song {
    // Song içerisinde computed property yaratıyoruz.
    // Type olarak belirttiğimiz ifade, "User Song'un parent'ıdır"
    // anlamına geliyor.
    var creator: Parent<Song, User> {
        // geriye döndürdüğümüz değer Parent'ın ID'si.
        // yani creatorID
        return parent(\.creatorID)
    }
    
    // Sibling ilişkisinde 3 parametre kullanıyoruz,
    // ilişki içinde olan iki model ve bağlantıyı sağlayacak üçüncü model
    // ilk parametremiz ilgili sınıf için yazdığımız model olacak.
    var genres: Siblings<Song, Genre, SongGenrePivot> {
        return siblings()
    }
}
