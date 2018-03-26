// RouteCollection ve diğer fonksiyonları kullanacağımız için Vapor'u import ediyoruz.
import Vapor
import Leaf

struct WebsiteController: RouteCollection {
    func boot(router: Router) throws {
        // index page için kullanılacak route yapısı
        router.get(use: index)
        // song sayfası için kullanılacak route yapısı
        router.get("songs", Song.parameter, use: songHandler)
    }
    
    // index page için kullanacağımız fonksiyon
    func index(_ req: Request) throws -> Future<View> {
        // tüm song'ları çekip view'e göndereceğiz.
        return Song.query(on: req).all().flatMap(to: View.self) { songs in
            // Content'in title'ına atama yapıyoruz.
            // IndexContent yaratırken songs için kontrolü de yapıyoruz
            let context = IndexContent(title: "Homepage", songs: songs.isEmpty ? nil : songs)
            // 1. parametre: index.leaf'ı render et, 2. parametre: context'i kullan
            return try req.leaf().render("index", context)
        }
    }
    
    // linklendirdiğimiz song'lar için kullanılacak fonksiyon
    func songHandler(_ req: Request) throws -> Future<View> {
        return try req.parameter(Song.self).flatMap(to: View.self) { song in
            return try song.creator.get(on: req).flatMap(to: View.self) { creator in
                let context = SongContent(title: song.title, song: song, creator: creator)
                return try req.leaf().render("song",context)
            }
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
struct IndexContent: Encodable {
    let title: String
    // songs dizisi oluşturduk
    let songs: [Song]?
}

// SongHandler için hazırladığımız content yapısı
struct SongContent: Encodable {
    let title: String
    let song: Song
    let creator: User
}
