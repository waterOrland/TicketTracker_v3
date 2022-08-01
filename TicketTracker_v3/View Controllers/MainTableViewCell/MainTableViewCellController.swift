//
//  MainTableViewCell.swift
//  TicketTracker_v3
//
//  Created by Orland Tompkins on 7/25/22.
//

import UIKit

class MainTableViewCellController: UITableViewCell {
    static let reusableIdentifier = "MainTableViewCell"
    
    @IBOutlet var ticketLabel: UILabel!
    @IBOutlet var arrivalLabel: UILabel!
}
