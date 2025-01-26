import Foundation
class Container {
    static let shared = Container()
    
    private var services: [String: Any] = [:]
    
    private init() {}
    
    func register<T>(service: T) {
        let key = String(describing: T.self)
        services[key] = service
    }
    
    func resolve<T>() -> T? {
        let key = String(describing: T.self)
        return services[key] as? T
    }
}
