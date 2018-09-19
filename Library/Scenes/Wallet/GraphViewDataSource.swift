//
//  Library
//
//  Created by Otto Suess on 06.09.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import BTCUtil
import Foundation
import Lightning
import ScrollableGraphView

final class GraphViewDataSource: ScrollableGraphViewDataSource {
    let plotData: [(date: Date, amount: Satoshi)]
    
    init(plottableEvents: [PlottableEvent]) {
        var transactionsByDay = [Int: [PlottableEvent]]()
        let currentDate = Date()
        
        for plottableEvent in plottableEvents {
            let dayDistance = currentDate.daysTo(end: plottableEvent.date)
            if transactionsByDay[dayDistance] == nil {
                transactionsByDay[dayDistance] = [plottableEvent]
            } else {
                transactionsByDay[dayDistance]?.append(plottableEvent)
            }
        }
        
        var sum: Satoshi = 0
        if let longestDayDistance = transactionsByDay.keys.min() {
            plotData = ((longestDayDistance - 1)...0).map { day in
                let date = currentDate.add(day: day)
                let delta = GraphViewDataSource.transactionSum(transactionsByDay[day] ?? [])
                sum += delta
                
                return (date, sum)
            }
        } else {
            plotData = []
        }
    }
    
    private static func transactionSum(_ events: [PlottableEvent]) -> Satoshi {
        return events.reduce(0) { $0 + $1.amount }
    }
    
    // MARK: - ScrollableGraphViewDataSource
    
    func value(forPlot plot: Plot, atIndex pointIndex: Int) -> Double {
        let currency = Settings.shared.cryptoCurrency.value
        guard let value = currency.value(satoshis: plotData[pointIndex].amount) else { return 0 }
        return Double(truncating: value as NSNumber)
    }
    
    func label(atIndex pointIndex: Int) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        dateFormatter.timeStyle = .none
        return dateFormatter.string(from: plotData[pointIndex].date)
    }
    
    func numberOfPoints() -> Int {
        return plotData.count
    }
}
