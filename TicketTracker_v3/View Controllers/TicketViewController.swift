//
//  TicketViewController.swift
//  TicketTracker_v3
//
//  Created by Orland Tompkins on 7/25/22.
//
// * time convertion

import UIKit

class TicketViewController: UIViewController {
    @IBOutlet var ticketLabel: UILabel!
    @IBOutlet var arrivalTime: UILabel!
    @IBOutlet var departureTime: UILabel!
    @IBOutlet var totalStayed: UILabel!
    @IBOutlet var totalCost: UILabel!
    
    private lazy var timeDateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        
        return dateFormatter
    }()
    
    var ticket: Ticket!

    override func viewDidLoad() {
        super.viewDidLoad()

        viewSetup()
    }
    
    private func viewSetup() {
        let interval = DateInterval(start: ticket.arrival!, end: Date())
        
        ticketLabel.text = String(ticket.number)
        arrivalTime.text = timeDateFormatter.string(from: ticket.arrival!)
        departureTime.text = timeDateFormatter.string(from: Date())
        totalStayed.text = timeInterval(interval.duration)
        totalCost.text = "$\(calculateCost(interval.duration))0"
    }
    
    @IBAction func completionButton(_ sender: UIButton) {
        ticket.isDone = true
        ticket.departure = Date()
        
        dismiss(animated: true)
    }
    
    private func timeInterval(_ interval: Double) -> String {
        let formatter = DateComponentsFormatter()
        let time = interval
        
        formatter.allowedUnits = [.day, .hour, .minute]
        formatter.unitsStyle = .abbreviated
        
        return formatter.string(from: time)!
    }
    
    private func calculateCost(_ time: Double) -> Double {
        if time > 9060 {
            return 36.00
        } else if time > 8160 {
            return 35.00
        } else if time > 7260 {
            return 31.50
        } else if time > 6360 {
            return 28.00
        } else if time > 5460 {
            return 24.50
        } else if time > 4560 {
            return 21.00
        } else if time > 4560 {
            return 17.50
        } else if time > 3660 {
            return 14.00
        } else if time > 1860 {
            return 10.50
        } else if time > 960 {
            return 7.00
        } else {
            return 3.50
        }
    }
}
