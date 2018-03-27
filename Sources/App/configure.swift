import FluentMySQL
import Vapor
import Leaf

/// Called before your application initializes.
///
/// [Learn More →](https://docs.vapor.codes/3.0/getting-started/structure/#configureswift)
public func configure(
    _ config: inout Config,
    _ env: inout Environment,
    _ services: inout Services
) throws {
    // Register providers first
    try services.register(FluentMySQLProvider())
    // LeafProvider register
    try services.register(LeafProvider())

    // Register routes to the router
    let router = EngineRouter.default()
    try routes(router)
    services.register(router, as: Router.self)

    // Register middleware
    var middlewares = MiddlewareConfig() // Create _empty_ middleware config
    // middlewares.use(FileMiddleware.self) // Serves files from `Public/` directory
    middlewares.use(DateMiddleware.self) // Adds `Date` header to responses
    middlewares.use(ErrorMiddleware.self) // Catches errors and converts to HTTP response
    services.register(middlewares)

    // Configure a SQLite database
    var databases = DatabaseConfig()
    let mysqlConfig = MySQLDatabaseConfig(hostname: "localhost", port: 3306, username: "root", password: "password", database: "vapor")
    let database = MySQLDatabase(config: mysqlConfig)
    databases.add(database: database, as: .mysql)
    services.register(databases)

    // Configure migrations
    var migrations = MigrationConfig()
    migrations.add(model: Song.self, database: .mysql)
    // SQLite'ın User sınıfını kullanacağını belirttik.
    migrations.add(model: User.self, database: .mysql)
    // SQLite'ın Genre sınıfını kullanacını belirttik.
    migrations.add(model: Genre.self, database: .mysql)
    // SQLite'ın SongGenrePivot sınıfını kullanılacağını belirttik.
    migrations.add(model: SongGenrePivot.self, database: .mysql)
    services.register(migrations)

    // Configure the rest of your application here
}
