import Vapor

struct GenresController: RouteCollection {
    func boot(router: Router) throws {
        let genresRoutes = router.grouped("api","genres")
        // genre oluşturmak için /api/genres üzerinden post isteği atacağız.
        genresRoutes.post(use: createGenre)
        // tüm genre'ları getirmek için /api/genres üzerinden get isteği atacağız.
        genresRoutes.get(use: getAllGenres)
        // parametre kullanarak tek bir genre'yı getirmek için get isteği atacağız
        genresRoutes.get(Genre.parameter, use: getGenre)
        // parametre kullanılarak tüm song'ları getirecek route yapısı
        genresRoutes.get(Genre.parameter, "songs", use: getSongs)
    }
    
    // genre oluşturmak için kullanacağımız fonksiyon
    func createGenre(_ req: Request) throws -> Future<Genre> {
        let genre = try req.content.decode(Genre.self)
        return genre.save(on: req)
    }
    
    // tüm genre'ları getirmek için kullanacağımız fonksiyon
    func getAllGenres(_ req: Request) throws -> Future<[Genre]> {
        return Genre.query(on: req).all()
    }
    
    // tek bir genre getirmek için kullanacağımız fonksiyon
    // parametre kullanarak getireceğimiz için
    // Genre sınıfına Parameter extension'ı ekledik.
    func getGenre(_ req: Request) throws -> Future<Genre> {
        return try req.parameter(Genre.self)
    }
    
    // genre içerisindeki song'ları getirecek fonksiyon.
    func getSongs(_ req: Request) throws -> Future<[Song]> {
        return try req.parameter(Genre.self).flatMap(to: [Song].self) { genre in
            return try genre.songs.query(on: req).all()
        }
    }
}

extension Genre: Parameter {}
