import FluentMySQL
import Vapor
import Foundation

final class SongGenrePivot: MySQLUUIDPivot {
    var id: UUID?
    var songID: Song.ID
    var genreID: Genre.ID
    
    // Fluent'in aralarında ilişki kurması için Right ve Left tanımladık.
    typealias Left = Song
    typealias Right = Genre
    
    // modellerin id'lerini tanıtıyoruz.
    static let leftIDKey: LeftIDKey = \SongGenrePivot.songID
    static let rightIDKey: RightIDKey = \SongGenrePivot.genreID
    
    // init oluşturuyoruz
    init(_ songID: Song.ID, _ genreID: Genre.ID) {
        self.songID = songID
        self.genreID = genreID
    }
}

// Migration extension'ı ekledikten sonra
// bu ilişkimiz için veritabanında tablomuz oluşacak.
extension SongGenrePivot: Migration {}
