import Foundation
import CoreLocation

class GerenciadorLocalizacao: NSObject, CLLocationManagerDelegate {
    private let gerenciadorLocalizacao = CLLocationManager()
    private var completado: ((CLLocation?) -> Void)?
    
    override init() {
        super.init()
        gerenciadorLocalizacao.delegate = self
        gerenciadorLocalizacao.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    func solicitarLocalizacao(completado: @escaping (CLLocation?) -> Void) {
        self.completado = completado
        
        if CLLocationManager.locationServicesEnabled() {
            gerenciadorLocalizacao.requestWhenInUseAuthorization()
            gerenciadorLocalizacao.requestLocation()
        } else {
            print("Os serviços de localização estão desligados.")
            completado(nil)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        completado?(locations.first)
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Erro ao pegar a localização: \(error.localizedDescription)")
        completado?(nil)
    }
}
