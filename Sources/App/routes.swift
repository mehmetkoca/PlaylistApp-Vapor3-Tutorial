import Routing
import Vapor

public func routes(_ router: Router) throws {
    let songsController = SongsController()
    try router.register(collection: songsController)
    
    let usersController = UsersController()
    try router.register(collection: usersController)
    
    let genresController = GenresController()
    try router.register(collection: genresController)
}


