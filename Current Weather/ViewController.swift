//
//  ViewController.swift
//  Current Weather
//
//  Created by Ege Sucu on 6.07.2019.
//  Copyright © 2019 Ege Sucu. All rights reserved.
//

import UIKit
import CoreLocation

struct Weather {
    var current : Double
    var description : String
    var max : Double
    var min : Double
    
    
    init() {
        current = 0.0
        description = ""
        max = 0.0
        min = 0.0
    }
    
    
}


class ViewController: UIViewController {
    
    @IBOutlet weak var textLabel : UILabel!
    
    
    fileprivate let api = "b93245a348c342b734fa6a52321aa6d8"
    fileprivate let shared = URLSession.shared
    fileprivate var weather = Weather()
    fileprivate var latitude = 0.0
    fileprivate var longitude = 0.0
    fileprivate var locationManager: CLLocationManager!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        askLocation()
        
        
        
    }
    
    func askLocation(){
        if CLLocationManager.locationServicesEnabled(){
            locationManager = CLLocationManager()
            
            locationManager.requestWhenInUseAuthorization()
            locationManager.startUpdatingLocation()
            
        }
    }
    
    @IBAction func buttonPressed(_ sender: Any) {
        let (lan,lon) = getLocation()
        getDataFromServer(api: api, lat: lan ,lon: lon)
    }
    
    func getLocation()->(Double,Double){
        
        
        if CLLocationManager.authorizationStatus() == .authorizedWhenInUse {
            let currentLocatiom = locationManager.location ?? CLLocation(latitude: 34.0, longitude: 22.0)
            latitude = currentLocatiom.coordinate.latitude
            longitude = currentLocatiom.coordinate.longitude
            
            return (latitude,longitude)
            
        }
        
        return(0,0)
        
    }
    
    
    private func getDataFromServer(api: String,lat: Double,lon: Double){
        
        
        guard let url = URL(string: "https://api.openweathermap.org/data/2.5/weather?lat=\(lat)&lon=\(lon)&APPID=\(api)") else {return}
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        shared.dataTask(with: request) { (data, response, error) in
            if let error = error{
                print(error.localizedDescription)
            } else if let response = response as? HTTPURLResponse{
                if response.statusCode == 200{
                    // we have json
                    
                    DispatchQueue.main.async {
                        self.changeString(with: self.getData(from: data))
                    }
                    
                    
                } else {
                    print("Server did not like us and gave any data, check APİ key or parameters")
                }
            }
            }.resume()
        
    
    }
    
    private func getData(from data: Data?)-> Weather{
        
        guard let data = data else {return Weather()}
        
        do {
            
            
            if let dictionary = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String:Any],
                let weatherSituation = dictionary["weather"] as? [[String:Any]],
                let description = weatherSituation[0]["description"] as? String,
                let weatherTemperatures = dictionary["main"] as? [String:Any],
                let currentTemp = weatherTemperatures["temp"] as? Double,
                let minTemp = weatherTemperatures["temp_min"] as? Double,
                let maxTemp = weatherTemperatures["temp_max"] as? Double {
                
                self.weather.description = description
                self.weather.current = currentTemp - 273.15
                self.weather.min = minTemp - 273.15
                self.weather.max = maxTemp - 273.15
                
                return self.weather
                
                
            } else {
                return Weather()
            }
            
        } catch let error{
            print(error.localizedDescription)
        }
        
        return weather
        
        
    }
    
    private func changeString(with weather: Weather){
        if !weather.current.isZero {
            self.textLabel.text = "Hi, right now the weather is \(weather.description). It is currently \(String(format: "%.0f", weather.current))ºC with maximum of \(String(format: "%.0f", weather.max))ºC and minimum of \(String(format: "%.0f", weather.min))ºC."
        } else {
            self.textLabel.text = "I could not got any data."
        }
    }
    
    
}

