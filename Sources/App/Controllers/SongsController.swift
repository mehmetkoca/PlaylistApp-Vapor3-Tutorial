import Vapor

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
        let song = try req.content.decode(Song.self).await(on: req)
        // Fluent query ile song'u kaydediyoruz.
        return song.save(on: req)
    }
    
    /*
     parametre girerek spesifik bir veriyi getirmek için
     kullandığımız fonksiyon yapısı.
    */
    func getSong(_ req: Request) throws -> Future<Song> {
        return try req.parameter(Song.self)
    }
    
    /*
     silme işlemi sonucunda dönecek olan HTTPStatus değerini
     flatMap ile yakalayıp içeriği noContent ile değiştiriyoruz.
     silme işlemini Fluent delete() methodu ile yapıyor.
    */
    func deleteSong(_ req: Request) throws -> Future<HTTPStatus> {
        return try req.parameter(Song.self).flatMap(to: HTTPStatus.self) { song in
            return song.delete(on: req).transform(to: .noContent)
        }
    }
    
    /*
     güncelleme işlemi için aşağıdaki gibi bir yapı kullanıyoruz.
     flatMap içerisinde Song'u decode ettikten sonra var olan verileri
     güncelliyoruz.
    */
    func updateSong(_ req: Request) throws -> Future<Song> {
        return try flatMap(to: Song.self, req.parameter(Song.self), req.content.decode(Song.self)) { song, updatedSong in
            song.artist = updatedSong.artist
            song.title = updatedSong.title
            return song.save(on: req)
        }
    }
}

/*
 Song sınıfı ile ilgili işlemlerde requestin parametre kabul etmesi
 için extension ekliyoruz.
 */
extension Song: Parameter {}






























