//
//  ViewController.swift
//  HealthKit_Steps
//
//  Created by Motoki Onayama on 2021/10/16.
//

import UIKit
import HealthKit

class ViewController: UIViewController {
    
    @IBOutlet weak var stepLbl: UILabel!
    
    @IBOutlet weak var distanceLbl: UILabel!
    
    @IBOutlet weak var stepView: UIView! {
        didSet {
            stepView.layer.cornerRadius = 20
        }
    }
    
    @IBOutlet weak var distanceView: UIView! {
        didSet {
            distanceView.layer.cornerRadius = 20
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        usagePermission()
        print("起動")
    }
    
    /// 認証許可
    private func usagePermission() {
        
        if HKHealthStore.isHealthDataAvailable() {
            print("対応")
        } else {
            print("非対応")
        }
        
        let dictionaryData = [
            HKObjectType.quantityType(forIdentifier: .stepCount)!,
            HKObjectType.quantityType(forIdentifier: .distanceWalkingRunning)!
        ]
        
        let readDataTypes = Set(dictionaryData)
        HKHealthStore().requestAuthorization(toShare: nil, read: readDataTypes) { success, _ in
            if success {
                self.getData()
            }
        }
    }
    
    private func getData() {
        
        let startDay = Calendar.current.date(bySettingHour: 0, minute: 0, second: 0, of: Date())
        let endDay = Calendar.current.date(bySettingHour: 23, minute: 59, second: 59, of: Date())
        
        let predicate = HKQuery.predicateForSamples(withStart: startDay,
                                                    end: endDay,
                                                    options: [])
        
        let step = HKStatisticsCollectionQuery(quantityType: HKObjectType.quantityType(forIdentifier: .stepCount)!,
                                                quantitySamplePredicate: predicate,
                                                options: .cumulativeSum,
                                                anchorDate: startDay!,
                                                intervalComponents: DateComponents(day: 1))
        
        let distance = HKStatisticsCollectionQuery(quantityType: HKObjectType.quantityType(forIdentifier: .distanceWalkingRunning)!,
                                                quantitySamplePredicate: predicate,
                                                options: .cumulativeSum,
                                                anchorDate: startDay!,
                                                intervalComponents: DateComponents(day: 1))
        
        step.initialResultsHandler = { _, results, _ in
            
            guard let statsCollection = results else { return }
            
            statsCollection.enumerateStatistics(from: startDay!, to: endDay!) { statistics, _ in
                
                if let quantity = statistics.sumQuantity() {
                    
                    let stepValue = quantity.doubleValue(for: HKUnit.count())
                    
                    DispatchQueue.main.async {
                        self.stepLbl.text = "\(Int(stepValue))歩"
                        print(stepValue)
                    }
                    
                } else {
                    // No Data
                    DispatchQueue.main.async {
                        self.stepLbl.text = "0歩"
                    }
                }
            }
        }
        distance.initialResultsHandler = { _, results, _ in
            
            guard let statsCollection = results else { return }
            
            statsCollection.enumerateStatistics(from: startDay!, to: endDay!) { statistics, _ in
                
                if let quantity = statistics.sumQuantity() {
                    
                    let distanceValue = quantity.doubleValue(for: HKUnit.meter())
                    
                    DispatchQueue.main.async {
                        self.distanceLbl.text = "\(Int(distanceValue))m"
                        print(distanceValue)
                    }
                    
                } else {
                    // No Data
                    DispatchQueue.main.async {
                        self.distanceLbl.text = "0m"
                    }
                }
            }
        }
        HKHealthStore().execute(step)
        HKHealthStore().execute(distance)
    }
    
    
    
}

