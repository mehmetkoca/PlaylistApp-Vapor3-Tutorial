// RouteCollection ve diğer fonksiyonları kullanacağımız için Vapor'u import ediyoruz.
import Vapor
import Leaf

struct WebsiteController: RouteCollection {
    func boot(router: Router) throws {
        // index page için kullanılacak route yapısı
        router.get(use: index)
        // song sayfası için kullanılacak route yapısı
        router.get("songs", Song.parameter, use: songHandler)
        // user sayfası için kullanılacak route yapısı
        router.get("users", User.parameter, use: userHandler)
        // tüm userları getirecek fonksiyon için yazdığımız route yapısı.
        router.get("users", use: allUsersHandler)
        // genre'ya ulaşacağımız route yapısı
        router.get("genres", Genre.parameter, use: GenreHandler)
        // tüm genre'ları getirmek için kullanacağımız route yapısı
        router.get("genres", use: allGenresHandler)
    }
    
    // index page için kullanacağımız fonksiyon
    func index(_ req: Request) throws -> Future<View> {
        // tüm song'ları çekip view'e göndereceğiz.
        return Song.query(on: req).all().flatMap(to: View.self) { songs in
            // Content'in title'ına atama yapıyoruz.
            // IndexContent yaratırken songs için kontrolü de yapıyoruz
            let context = IndexContext(title: "Homepage", songs: songs.isEmpty ? nil : songs)
            // 1. parametre: index.leaf'ı render et, 2. parametre: context'i kullan
            return try req.leaf().render("index", context)
        }
    }
    
    // linklendirdiğimiz song'lar için kullanılacak fonksiyon
    func songHandler(_ req: Request) throws -> Future<View> {
        return try req.parameters.next(Song.self).flatMap(to: View.self) { song in
            return try flatMap(to: View.self, song.creator.get(on: req), song.genres.query(on: req).all()) { creator, genres in
                let context = SongContext(title: song.title, song: song, creator: creator, genres: genres.isEmpty ? nil : genres )
                return try req.leaf().render("song",context)
            }
        }
    }
    
    // linklendirdiğimiz user sayfası için kullanılacak fonksiyon
    func userHandler(_ req: Request) throws -> Future<View> {
        return try req.parameters.next(User.self).flatMap(to: View.self) { user in
            return try user.songs.query(on: req).all().flatMap(to: View.self) { songs in
                let context = UserContext(title: user.name, user: user, songs: songs.isEmpty ? nil: songs)
                return try req.leaf().render("user",context)
            }
        }
    }
    
    // tüm User'ları çekeceğimiz fonksiyon
    func allUsersHandler(_ req: Request) throws -> Future<View> {
        return User.query(on: req).all().flatMap(to: View.self) { users in
            let context = AllUserContext(title: "All Users", users: users)
            return try req.leaf().render("allUsers",context)
        }
    }
    
    // genre page için kullanacağımız fonksiyon
    func GenreHandler(_ req: Request) throws -> Future<View> {
        return try req.parameters.next(Genre.self).flatMap(to: View.self) { genre in
            return try genre.songs.query(on: req).all().flatMap(to: View.self) { songs in
                let context = GenreContext(title: genre.name, genre: genre, songs: songs)
                return try req.leaf().render("genre", context)
            }
        }
    }
    
    // tüm genre'ları getirmek için kullanacağımız fonksiyon
    func allGenresHandler(_ req: Request) throws -> Future<View> {
        return Genre.query(on: req).all().flatMap(to: View.self) { genres in
            let context = AllGenresContext(title: "All Genres", genres: genres)
            return try req.leaf().render("allGenres", context)
        }
    }
}

extension Request {
    // leaf() ile her seferinde make fonksiyonunu yazmamak için extension içinde handle ediyoruz.
    // make() fonksiyonu request için istenen sayfayı render etmemize yardım edecek.
    func leaf() throws -> LeafRenderer{
        return try self.make(LeafRenderer.self)
    }
}

// Leaf dosyasının kullanacağı bir yapı oluşturduk.
struct IndexContext: Encodable {
    let title: String
    // songs dizisi oluşturduk
    let songs: [Song]?
}

// SongHandler için hazırladığımız content yapısı
struct SongContext: Encodable {
    let title: String
    let song: Song
    let creator: User
    let genres: [Genre]?
}

struct UserContext: Encodable {
    let title: String
    let user: User
    let songs: [Song]?
}

struct AllUserContext: Encodable {
    let title: String
    let users: [User]
}

struct GenreContext: Encodable {
    let title: String
    let genre: Genre
    let songs: [Song]
}

struct AllGenresContext: Encodable {
    let title: String
    let genres: [Genre]
}
