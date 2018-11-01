//
//  DestinationInfoViewController.swift
//  PackSwiftly
//
//  Created by Bernadett Kiss on 10/5/18.
//  Copyright © 2018 Bernadett Kiss. All rights reserved.
//

import UIKit
import Charts

class DestinationInfoViewController: UIViewController, IAxisValueFormatter {
    
    @IBOutlet weak var unitSwitch: UISwitch!
    @IBOutlet weak var chartView: LineChartView!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var selectedTrip: Trip!
    var forecast = [WeatherData]()
    var dates = [String]()
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    lazy var celsiusFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.maximumFractionDigits = 1
        formatter.negativeSuffix = "℃"
        formatter.positiveSuffix = "℃"
        return formatter
    }()
    
    lazy var fahrenheitFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.maximumFractionDigits = 1
        formatter.negativeSuffix = "℉"
        formatter.positiveSuffix = "℉"
        return formatter
    }()
    
    // MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let destinationName = selectedTrip.destination?.name
        unitSwitch.setOn(appDelegate.unitOfTemperatureIsCelsius, animated: true)
        activityIndicator.startAnimating()
        chartView.noDataText = "No weather data available"
        getWeatherForecast()
        
        WikipediaClient.shared.getInfo(about: destinationName!) { result in
            switch result {
            case .success(info: let destinationInfo):
                DispatchQueue.main.async {
                    self.activityIndicator.stopAnimating()
                    self.textView.text = destinationInfo
                }
            case .failure:
                DispatchQueue.main.async {
                    self.activityIndicator.stopAnimating()
                    self.textView.text = "No data available"
                }
            }
        }
    }
    
    // MARK: - Actions
    
    @IBAction func unitSwitchValueChanged(_ sender: UISwitch) {
        appDelegate.unitOfTemperatureIsCelsius = sender.isOn
        UserDefaults.standard.set(sender.isOn, forKey: "unitOfTemperatureIsCelsius")
        getWeatherForecast()
    }
    
    // MARK: - Methods
    
    func getWeatherForecast() {
        let latitude = selectedTrip.destination?.latitude
        let longitude = selectedTrip.destination?.longitude
        OpenWeatherMapClient.shared.getForecast(latitude: latitude!, longitude: longitude!, inCelsius: appDelegate.unitOfTemperatureIsCelsius) { (result) in
            switch result {
            case .success(weatherData: let weatherDataArray):
                self.forecast = weatherDataArray
                DispatchQueue.main.async {
                    self.setChart(dataPoints: self.forecast)
                }
            case .failure:
                self.forecast = []
            }
        }
    }
    
    private func setChart(dataPoints: [WeatherData]) {
        chartView.isUserInteractionEnabled = false
        
        chartView.rightAxis.enabled = false
        if appDelegate.unitOfTemperatureIsCelsius {
            chartView.leftAxis.valueFormatter = DefaultAxisValueFormatter(formatter: celsiusFormatter)
        } else {
            chartView.leftAxis.valueFormatter = DefaultAxisValueFormatter(formatter: fahrenheitFormatter)
        }
        
        let xAxis = chartView.xAxis
        xAxis.labelPosition = .bottom
        xAxis.axisMinimum = 0
        xAxis.valueFormatter = self
        xAxis.drawGridLinesEnabled = false
        
        var temperaturedataEntries: [ChartDataEntry] = []
        
        for i in 0..<dataPoints.count {
            let dataEntry = ChartDataEntry(x: Double(i), y: dataPoints[i].temperature.value)
            dates.append(dataPoints[i].date)
            temperaturedataEntries.append(dataEntry)
        }
        
        let chartDataSet = LineChartDataSet(values: temperaturedataEntries, label: "Temperature")
        chartDataSet.drawValuesEnabled = false
        chartDataSet.lineWidth = 2
        chartDataSet.circleRadius = 3
        chartDataSet.drawCircleHoleEnabled = false
        
        chartDataSet.setColor(NSUIColor(red: 255/255, green: 169/255, blue: 0/255, alpha: 1))
        chartDataSet.setCircleColor(NSUIColor(red: 255/255, green: 169/255, blue: 0/255, alpha: 1))
        
        let data = LineChartData(dataSet: chartDataSet)
        chartView.data = data
        
        chartView.animate(xAxisDuration: 2.5)
    }
    
    // MARK: - IAxisValueFormatter Methods
    
    func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        return dates[Int(value)]
    }
}
