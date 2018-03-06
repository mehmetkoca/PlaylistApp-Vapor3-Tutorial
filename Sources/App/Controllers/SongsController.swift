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
}



