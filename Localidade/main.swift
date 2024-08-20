import Foundation
import CoreLocation

class GeolocationCoordinator {
    let locationManager = LocationManager()
    let analyzer = GeolocationAnalyzer()
    
    func startAnalysis() {
        locationManager.requestLocation { location in
            guard let location = location else {
                print("Não consegui pegar a localização.")
                return
            }
            
            self.analyzer.analyze(location: location) { result in
                self.saveToDesktop(fileName: "GeolocationAnalysis.txt", content: result)
            }
        }
    }
    
    func saveToDesktop(fileName: String, content: String) {
        let fileManager = FileManager.default
        
        if let desktopURL = fileManager.urls(for: .desktopDirectory, in: .userDomainMask).first {
            let fileURL = desktopURL.appendingPathComponent(fileName)
            
            do {
                try content.write(to: fileURL, atomically: true, encoding: .utf8)
                print("Arquivo salvo na área de trabalho: \(fileURL.path)")
            } catch {
                print("Deu erro ao salvar o arquivo: \(error.localizedDescription)")
            }
        }
    }
}

let coordinator = GeolocationCoordinator()
coordinator.startAnalysis()

RunLoop.main.run()
