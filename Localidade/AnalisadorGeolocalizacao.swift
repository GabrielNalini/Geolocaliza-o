import Foundation
import CoreLocation

class AnalisadorGeolocalizacao {
    
    func analisar(localizacao: CLLocation, completado: @escaping (String) -> Void) {
        let latitude = localizacao.coordinate.latitude
        let longitude = localizacao.coordinate.longitude
        let altitude = localizacao.altitude
        
        var resultado = "Localização capturada:\n"
        resultado += "Latitude: \(latitude)\n"
        resultado += "Longitude: \(longitude)\n"
        resultado += "Altitude: \(altitude) metros\n"
        
        self.obterCidadeMaisProxima(localizacao: localizacao) { infoCidade in
            resultado += infoCidade
            completado(resultado)
        }
    }
    
    func obterCidadeMaisProxima(localizacao: CLLocation, completado: @escaping (String) -> Void) {
        let geocoder = CLGeocoder()
        
        geocoder.reverseGeocodeLocation(localizacao) { placemarks, erro in
            if let erro = erro {
                print("Erro ao buscar a cidade: \(erro.localizedDescription)")
                completado("Erro na geocodificação.")
                return
            }
            
            if let placemark = placemarks?.first {
                let cidade = placemark.locality ?? "Cidade desconhecida"
                let pais = placemark.country ?? "País desconhecido"
                
                let infoCidade = "Cidade mais próxima: \(cidade), \(pais)\n"
                infoCidade += "Distância até \(cidade): 0 km\n"
                completado(infoCidade)
            } else {
                completado("Nenhuma cidade encontrada para essas coordenadas.\n")
            }
        }
    }
}
