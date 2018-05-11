import Vapor
import Fluent

// RouteCollection boot fonksiyonunu içeriyor.
// boot fonksiyonu SongsContoller için routing
// işlemlerini yapmamızı sağlayacak.
struct SongsController: RouteCollection {
    
    func boot(router: Router) throws {
        // /api/songs üzerinden erişim sağlayacağım
        let songsRoute = router.grouped("api","songs")
        /*
         /api/songs'a get isteği gönderip
         getAllSongs fonksiyonunun çalışmasını istiyoruz.
         */
        songsRoute.get(use: getAllSongs)
        /*
         /api/songs'a parametler ile post isteği gönderiyoruz.
         parametlerimiz Song sınıfının init'inde kullandığımız
         değişkenler olacak.
         */
        songsRoute.post(use: createSong)
        /*
         /api/songs/1 gibi parametre kullanmak için kullandığımız
         route yapısı.
        */
        songsRoute.get(Song.parameter, use: getSong)
        /*
         /api/songs/1 gibi spesifik bir veriyi silmek için
         kullandığımız route yapısı.
        */
        songsRoute.delete(Song.parameter, use: deleteSong)
        /*
         /api/songs/1 gibi URL'deki verileri güncellemek için
         put methodu kullandığımız route yapısı.
        */
        songsRoute.put(Song.parameter, use: updateSong)
        
        // api/songs/1/creator üzerinden ulaşılacak route yapısı
        songsRoute.get(Song.parameter, "creator", use: getCreator)
        // api/songs/1/genres üzerinden ulaşılacak route yapısı
        songsRoute.get(Song.parameter, "genres", use: getGenres)
        // api/songs/1/genres/2 gibi bir route yapısı oluşturduk
        songsRoute.post(Song.parameter, "genres", Genre.parameter, use: addGenre)
        // search için kullanacağımız route yapısı
        songsRoute.get("search", use: searchSong)
    }
    
    // Tüm Song tipindeki verileri geri döndürecek fonksiyon
    func getAllSongs(_ req: Request) throws -> Future<[Song]> {
        /*
         Fluent query ile request'i işleyip
         tüm verileri geri döndürecek.
         */
        return Song.query(on: req).all()
    }
    
    func createSong(_ req: Request) throws -> Future<Song> {
        /*
         request'in tamamlanıp geriye Future döndürebilmesi için
         await kullanıyoruz. Bu, işlemimizin yarıda kesilmesini
         engelliyor.
         */
        let song = try req.content.decode(Song.self)
        // Fluent query ile song'u kaydediyoruz.
        return song.save(on: req)
    }
    
    /*
     parametre girerek spesifik bir veriyi getirmek için
     kullandığımız fonksiyon yapısı.
    */
    func getSong(_ req: Request) throws -> Future<Song> {
        return try req.parameters.next(Song.self)
    }
    
    /*
     silme işlemi sonucunda dönecek olan HTTPStatus değerini
     flatMap ile yakalayıp içeriği noContent ile değiştiriyoruz.
     silme işlemini Fluent delete() methodu ile yapıyor.
    */
    func deleteSong(_ req: Request) throws -> Future<HTTPStatus> {
        return try req.parameters.next(Song.self).flatMap(to: HTTPStatus.self) { song in
            return song.delete(on: req).transform(to: .noContent)
        }
    }
    
    /*
     güncelleme işlemi için aşağıdaki gibi bir yapı kullanıyoruz.
     flatMap içerisinde Song'u decode ettikten sonra var olan verileri
     güncelliyoruz.
    */
    func updateSong(_ req: Request) throws -> Future<Song> {
        return try flatMap(to: Song.self, req.parameters.next(Song.self), req.content.decode(Song.self)) { song, updatedSong in
            song.artist = updatedSong.artist
            song.title = updatedSong.title
            return song.save(on: req)
        }
    }
    
    // Song'un creator'unu getirmek için kullanılacak fonksiyon
    func getCreator(_ req: Request) throws -> Future<User> {
        return try req.parameters.next(Song.self).flatMap(to: User.self) { song in
            return try song.creator.get(on: req)
        }
    }
    
    // Song'un genre'larını getirmek için kullanacağımız fonksiyon.
    func getGenres(_ req: Request) throws -> Future<[Genre]> {
        return try req.parameters.next(Song.self).flatMap(to: [Genre].self) { song in
            return try song.genres.query(on: req).all()
        }
    }
    
    // Song'a Genre eklemek için kullanacağımız fonksiyon
    func addGenre(_ req: Request) throws -> Future<HTTPStatus> {
        return try flatMap(to: HTTPStatus.self, req.parameters.next(Song.self), req.parameters.next(Genre.self)) { song, genre in
            // SongGenrePivot'u burada modellerin requireID'leri ile kullanacağız
            let pivot = try SongGenrePivot(song.requireID(), genre.requireID())
            return pivot.save(on: req).transform(to: .ok)
        }
    }
    
    func searchSong(_ req: Request) throws -> Future<[Song]> {
        // /api/songs/search?term=Bonobo gibi bir URL üzerinden istek atacağız.
        // String parametre alan ve term keyword'u üzerinden işlem yaptıracağımız
        // yapı aşağıdaki gibi olacak.
        // Optional String geri döneceği için unwrap etmemiz ve nil gelme
        // ihtimaline karşı guard-let yapısı kullanmamız gerekiyor.
        guard let searchTerm = req.query[String.self, at: "term"] else {
            throw Abort(.badRequest, reason: "Missing search term in request")
        }
        // artist üzerinden term'e girdiğimiz string'i aratıyoruz ve tüm sonuçları döndürüyoruz.
        return try Song.query(on: req).group(.or){ or in
            try or.filter(\.artist == searchTerm)
            try or.filter(\.title == searchTerm)
        }.all()
    }
}

/*
 Song sınıfı ile ilgili işlemlerde requestin parametre kabul etmesi
 için extension ekliyoruz.
 */
extension Song: Parameter {}
