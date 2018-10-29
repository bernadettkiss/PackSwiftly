//
//  TripInfoViewController.swift
//  PackSwiftly
//
//  Created by Bernadett Kiss on 10/5/18.
//  Copyright © 2018 Bernadett Kiss. All rights reserved.
//

import UIKit
import Charts

class TripInfoViewController: UIViewController, IAxisValueFormatter {
    
    @IBOutlet weak var chartView: LineChartView!
    @IBOutlet weak var textView: UITextView!
    
    var selectedTrip: Trip!
    var forecast = [WeatherData]()
    var dates = [String]()
    
    lazy var formatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.maximumFractionDigits = 1
        formatter.negativeSuffix = "℃"
        formatter.positiveSuffix = "℃"
        return formatter
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let destinationName = selectedTrip.destination?.name
        let latitude = selectedTrip.destination?.latitude
        let longitude = selectedTrip.destination?.longitude
        OpenWeatherMapClient.shared.getForecast(latitude: latitude!, longitude: longitude!) { (result) in
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
        
        WikipediaClient.shared.getData(about: destinationName!) { result in
            switch result {
            case .success(info: let destinationInfo):
                DispatchQueue.main.async {
                    self.textView.text = destinationInfo
                }
            case .failure:
                DispatchQueue.main.async {
                    self.textView.text = "No data available"
                }
            }
        }
    }
    
    private func setChart(dataPoints: [WeatherData]) {
        chartView.noDataText = "No weather data available"
        chartView.isUserInteractionEnabled = false
        
        chartView.rightAxis.enabled = false
        chartView.leftAxis.valueFormatter = DefaultAxisValueFormatter(formatter: formatter)
        
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
        
        chartDataSet.setColor(NSUIColor(red: 121/255, green: 162/255, blue: 175/255, alpha: 1))
        chartDataSet.setCircleColor(NSUIColor(red: 121/255, green: 162/255, blue: 175/255, alpha: 1))
        
        let gradientColors = [UIColor(red: 121/255, green: 162/255, blue: 175/255, alpha: 1).cgColor,
                              UIColor(red: 103/255, green: 110/255, blue: 129/255, alpha: 1).cgColor]
        let gradient = CGGradient(colorsSpace: nil, colors: gradientColors as CFArray, locations: nil)!
        chartDataSet.fillAlpha = 0.7
        chartDataSet.fill = Fill(linearGradient: gradient, angle: 90)
        chartDataSet.drawFilledEnabled = true
        
        let data = LineChartData(dataSet: chartDataSet)
        chartView.data = data
        
        chartView.animate(xAxisDuration: 2.5)
        // chartView.animate(xAxisDuration: 2.0, yAxisDuration: 2.0, easingOption: .easeInBounce)
    }
    
    // MARK: - IAxisValueFormatter Methods
    
    func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        return dates[Int(value)]
    }
}
