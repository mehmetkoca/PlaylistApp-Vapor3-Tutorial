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
        // Song eklemek için kullanacağımız route yapısı
        router.get("add-song", use: addSongHandler)
        // Form'dan aldığımız verileri kaydetmek için kullanacağımız fonksiyonun route yapısı
        router.post("add-song", use: addSongPostHandler)
        // Song edit sayfası için kullanılacak route yapısı
        router.get("songs", Song.parameter, "edit", use: editSongHandler)
        // Edit işlemi gerçekleştirilecek song için post işlemi route yapısı
        router.post("songs", Song.parameter, "edit", use: editSongPostHandler)
        // Song delete işlemi için kullanılacak route yapısı
        router.post("songs", Song.parameter, "delete", use: deleteSongHandler)
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
    
    // Song eklemek için kullanacağımız fonksiyon.
    // Song ekleme sayfasında title, user gibi seçimlerimiz olacağı için
    // daha önce yaptığımız gibi Struct yapısı oluşturuyoruz aşağıda. -AddSongContext adında-
    func addSongHandler(_ req: Request) throws -> Future<View> {
        return User.query(on: req).all().flatMap(to: View.self) { users in
             let context = AddSongContext(title: "Add Song", users: users)
             return try req.leaf().render("addSong", context )
        }
    }
    
    // View'dan aldığımız dataları Song olarak kaydetmemizi sağlayacak fonksiyon.
    // Geri dönüş değerimiz Response tipinde olacak.
    func addSongPostHandler(_ req: Request) throws -> Future<Response> {
        // View'dan gelecek datalarımız belli olduğu için SongPostData adında bir Struct oluşturduk.
        return try req.content.decode(SongPostData.self).flatMap(to: Response.self) { data in
            // Datalar ile yeni bir Song yarattık.
            let song = Song(artist: data.songArtist, title: data.songTitle, creatorID: data.user )
            // Song'u kaydedeceğiz fakat geri dönüş değerine göre sayfa yönlendirmesi de yapmak istiyoruz.
            return song.save(on: req).map(to: Response.self) { song in
                guard let id = song.id else {
                    // id almakta başarısız olursak anasayfaya yönlendirsin
                    return req.redirect(to: "/")
                }
                // Song oluşturma başarılı olduğunda kaydettiğimiz Song'un sayfasına yönlendirsin.
                return req.redirect(to: "/songs/\(id)")
            }
        }
    }
    
    // Edit Song sayfasını render etmemizi sağlayacak fonksiyon
    func editSongHandler(_ req: Request) throws -> Future<View> {
        return try flatMap(to: View.self, req.parameters.next(Song.self), User.query(on: req).all()) { song, users in
            let context = EditSongContext(title: "Edit Song", song: song, users: users)
            return try req.leaf().render("addSong",context)
        }
    }
    
    // editlenen song'un post işlemini gerçekleştirecek fonksiyon
    func editSongPostHandler(_ req: Request) throws -> Future<Response> {
        return try flatMap(to: Response.self, req.parameters.next(Song.self), req.content.decode(SongPostData.self)) {song, data in
            song.artist = data.songArtist
            song.title = data.songTitle
            song.creatorID = data.user
            
            return song.save(on: req).map(to: Response.self) { song in
                guard let id = song.id else {
                    return req.redirect(to: "/")
                }
                return req.redirect(to: "/songs/\(id)")
            }
        }
    }
    
    // Song delete işlemini gerçekleştirecek fonksiyon
    func deleteSongHandler(_ req: Request) throws -> Future<Response> {
        return try req.parameters.next(Song.self).flatMap(to: Response.self) { song in
            return song.delete(on: req).transform(to: req.redirect(to: "/"))
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

struct AddSongContext: Encodable {
    let title: String
    let users: [User]
}

struct SongPostData: Content {
    static var defaultMediaType = MediaType.urlEncodedForm
    let songArtist: String
    let songTitle: String
    let user: UUID
}

struct EditSongContext: Encodable {
    let title: String
    let song: Song
    let users: [User]
    let editing = true
}
