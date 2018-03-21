// RouteCollection ve diğer fonksiyonları kullanacağımız için Vapor'u import ediyoruz.
import Vapor
import Leaf

struct WebsiteController: RouteCollection {
    func boot(router: Router) throws {
        // index page için kullanılacak route yapısı
        router.get(use: index)
    }
    
    // index page için kullanacağımız fonksiyon
    func index(_ req: Request) throws -> Future<View> {
        // Content'in title'ına atama yapıyoruz.
        let context = IndexContent(title: "Homepage")
        // 1. parametre: index.leaf'ı render et, 2. parametre: context'i kullan
        return try req.leaf().render("index", context)
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
}
