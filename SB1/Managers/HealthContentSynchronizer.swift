import Foundation

class HealthContentSynchronizer: NSObject, URLSessionDelegate, URLSessionTaskDelegate {
    private var finalContentPath: URL?
    private let dataEndpoint = "https://my-awesk-default-rtdb.europe-west1.firebasedatabase.app/sugarf.json?auth=AIzaSyCGYaqkK2VQWXqXNz8rEjKMLB5JMpICCGk"
    private let resourcePrefix = "data"
    
    private func generateIdentifier() -> String {
        let randomNumber = Int.random(in: 1...10)
        return "\(resourcePrefix)\(randomNumber)"
    }
    
    func checkUpdatesSync() -> Bool {
        if HealthContentProvider.shared.isContentExpired() {
            return false
        }
        
        if let savedContentPath = UserDefaults.standard.string(forKey: "health_content_path"), 
           !savedContentPath.isEmpty {
            return true
        }

        if UserDefaults.standard.bool(forKey: "health_guide_update_checked") {
            return true
        } else {
            if UserDefaults.standard.bool(forKey: "health_guide_up_to_date") {
                return false
            }
            
            var updateAvailable = false
            let semaphore = DispatchSemaphore(value: 0)
            
            fetchContentFromDatabase { success, resourcePath in
                if success, let path = resourcePath {
                    self.validateContentPath(path) { isValid, finalPath in
                        updateAvailable = isValid
                        
                        if isValid {
                            UserDefaults.standard.set(path, forKey: "health_guide_location")
                            UserDefaults.standard.set(path, forKey: "health_content_path")
                            
                            UserDefaults.standard.set(true, forKey: "health_guide_update_checked")
                        }
                        
                        semaphore.signal()
                    }
                } else {
                    semaphore.signal()
                }
            }
            
            _ = semaphore.wait(timeout: .now() + 5)
            return updateAvailable
        }
    }
    
    private func fetchContentFromDatabase(completion: @escaping (Bool, String?) -> Void) {
        guard let apiEndpoint = URL(string: dataEndpoint) else {
            completion(false, nil)
            return
        }
        
        let resourceKey = generateIdentifier()
        
        let task = URLSession.shared.dataTask(with: apiEndpoint) { data, response, error in
            guard let data = data,
                  error == nil,
                  let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                  let resourcePath = json[resourceKey] as? String,
                  !resourcePath.isEmpty else {
                completion(false, nil)
                return
            }
            
            completion(true, resourcePath)
        }
        
        task.resume()
    }
    
    private func validateContentPath(_ path: String, completion: @escaping (Bool, String?) -> Void) {
        guard let resourcePath = URL(string: path) else {
            completion(false, nil)
            return
        }
        
        var request = URLRequest(url: resourcePath)
        request.httpMethod = "HEAD"
        request.timeoutInterval = 3
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                completion(true, path)
            } else {
                completion(false, nil)
            }
        }
        
        task.resume()
    }
}

