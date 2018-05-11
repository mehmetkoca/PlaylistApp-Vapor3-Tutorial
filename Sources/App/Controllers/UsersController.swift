import Vapor

struct UsersController: RouteCollection {
    func boot(router: Router) throws {
        // user route için /api/users üzerinden erişmek istiyorum.
        let usersRoutes = router.grouped("api", "users")
        // user oluşturmak için yazdığımız fonksiyonu kaydettik.
        usersRoutes.post(use: createUser)
        // get request'i ile tüm user'ları getireceğiz.
        usersRoutes.get(use: getAllUsers)
        // parametre ile get isteği yapıp tek bir user getireceğiz.
        usersRoutes.get(User.parameter, use: getUser)
        // User'ın tüm Song'larına ulaşmamızı sağlayan route yapısı.
        usersRoutes.get(User.parameter, "songs", use: getSongs)
    }
    
    // user oluşturmak için kullandığımız fonksiyon
    func createUser(_ req: Request) throws -> Future<User> {
        return try req.content.decode(User.self).flatMap(to: User.self, { user in
            return user.save(on: req)
        })
    }
    
    // tüm user'ları getirecek fonksiyon
    func getAllUsers(_ req: Request) throws -> Future<[User]> {
        return User.query(on: req).all()
    }
    
    // tek bir user getirmek için kullanacağımız fonksiyon
    // user'ı parametre ile getireceğimiz için
    // User sınıfına Parameter extension'ı ekliyoruz.
    func getUser(_ req: Request) throws -> Future<User> {
        return try req.parameters.next(User.self)
    }
    
    // User'ın tüm Song'larını geri döndüren fonksiyon.
    func getSongs(_ req: Request) throws -> Future<[Song]> {
        return try req.parameters.next(User.self).flatMap(to: [Song].self) {user in
            return try user.songs.query(on: req).all()
        }
    }
}

extension User: Parameter {}
