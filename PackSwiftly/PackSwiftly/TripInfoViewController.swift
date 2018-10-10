//
//  TripInfoViewController.swift
//  PackSwiftly
//
//  Created by Bernadett Kiss on 10/5/18.
//  Copyright © 2018 Bernadett Kiss. All rights reserved.
//

import UIKit

class TripInfoViewController: UIViewController, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    
    var selectedTrip: Trip!
    var forecast = [WeatherData]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        
        let latitude = selectedTrip.destination?.latitude
        let longitude = selectedTrip.destination?.longitude
        OpenWeatherMapClient.shared.getForecast(latitude: latitude!, longitude: longitude!) { (result) in
            switch result {
            case .success(weatherData: let weatherDataArray):
                self.forecast = weatherDataArray
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            case .failure:
                self.forecast = []
            }
        }
    }
    
    // MARK: - TableViewDataSource Methods
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return forecast.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "WeatherDataCell", for: indexPath)
        let weatherData = forecast[indexPath.row]
        cell.textLabel?.text = "\(weatherData.date) \(weatherData.minimumTemperature) \(weatherData.maximumTemperature)"
        cell.detailTextLabel?.text = weatherData.description
        return cell
    }
}
