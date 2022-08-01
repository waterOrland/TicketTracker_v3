//
//  ViewController.swift
//  TicketTracker_v3
//
//  Created by Orland Tompkins on 7/25/22.
//
// TODO: -
//  * Label proper open ticket label vs arrival
//  

// MARK: - FIX NEEDED
/*
    Terminating app loses shift connection -> Prompts new ticket
 */

import UIKit
import CoreData

class MainViewController: UITableViewController {
    private enum Segue {
        static let MonthlyViewController = "MonthlyViewController"
        static let TicketViewController = "TicketViewController"
    }
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    private lazy var fetchResultsController: NSFetchedResultsController<Ticket> = {
        let fetchedRequest: NSFetchRequest<Ticket> = Ticket.fetchRequest()
        fetchedRequest.sortDescriptors = [NSSortDescriptor(key: #keyPath(Ticket.number), ascending: true)]
        fetchedRequest.predicate = NSPredicate(format: "isDone == FALSE")
        
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchedRequest,
                                                                  managedObjectContext: self.context,
                                                                  sectionNameKeyPath: nil, cacheName: nil)
        
        fetchedResultsController.delegate = self
        
        try? fetchedResultsController.performFetch()
        
        return fetchedResultsController
    }()
    private lazy var timeDateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        
        return dateFormatter
    }()
    private lazy var dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM dd YYYY"
        
        return dateFormatter
    }()
    
    private var shift: Shift?

    override func viewDidLoad() {
        super.viewDidLoad()
        
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let identifier = segue.identifier else { return }
        
        switch (identifier) {
        case Segue.TicketViewController:
            guard let destination = segue.destination as? TicketViewController else { return }
            guard let indexPath = tableView.indexPathForSelectedRow else { return }
            
            destination.ticket = fetchResultsController.object(at: indexPath)
        default:
            break
        }
    }
    
    // MARK: - Navigation Buttons
    
    @IBAction func addButton(_ sender: UIBarButtonItem) {
        ticketHandler()
    }
    
    @IBAction func monthlyButton(_ sender: Any) {
        print("monthly button pressed")
    }
    
    // MARK: - Ticket/Monthly Handler
    
    private func ticketHandler(_ : Shift? = nil) {
        let today = dateFormatter.string(from: Date())
        let shift = fetchResultsController.fetchedObjects?.last?.shift

        if  shift?.createdAt == nil || today != shift?.createdAt {
            let alert = UIAlertController(title: "Add Ticket", message: nil, preferredStyle: .alert)
            
            alert.addTextField { txtField in
                txtField.placeholder = "Opening Ticket"
                txtField.keyboardType = .numberPad
            }
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
            alert.addAction(UIAlertAction(title: "Enter", style: .default, handler: { _ in
                guard let openTxtField = alert.textFields else { return }
                
                if let ticketNumber = openTxtField[0].text, !ticketNumber.isEmpty {
                    self.shift = Shift(context: self.context)
                    let ticket = Ticket(context: self.context)
                    
                    ticket.number = Int64(ticketNumber)!
                    ticket.arrival = Date()
                    ticket.isDone = false
                    self.shift?.createdAt = today
                    self.shift?.addToTickets(ticket)
                }
            }))
            
            present(alert, animated: true)
        } else {
            guard let lastIssuedTicket = fetchResultsController.fetchedObjects?.last else { return }
            
            let ticket = Ticket(context: context)
            
            ticket.number = lastIssuedTicket.number + 1
            ticket.arrival = Date()
            ticket.isDone = false
            shift?.addToTickets(ticket)
        }
    }
    
    
    // MARK: - Table View
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: MainTableViewCellController.reusableIdentifier,
                                                       for: indexPath) as? MainTableViewCellController else {
            fatalError("Unexpected Index Path")
        }
        
        cellConfiguration(cell, at: indexPath)
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let section = fetchResultsController.sections?[section] else { return 0 }
        
        return section.numberOfObjects
    }
    
//    override func numberOfSections(in tableView: UITableView) -> Int {
//        guard let sections = fetchTicketResultsController.sections else { return 0 }
//
//        return sections.count
//    }
//
    // MARK: - Save Context
    
    private func notificationHandler() {
        let notificationCenter = NotificationCenter.default
        
        notificationCenter.addObserver(self,
                                       selector: #selector(saveChanges(_:)),
                                       name: UIApplication.didEnterBackgroundNotification,
                                       object: nil)
    }
    
    @objc func saveChanges(_ notification: NotificationCenter) {
        let saveContext: () = (UIApplication.shared.delegate as! AppDelegate).saveContext()
        saveContext
    }
}

extension MainViewController: NSFetchedResultsControllerDelegate {
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch (type) {
        case .insert:
            if let indexPath = newIndexPath {
                tableView.insertRows(at: [indexPath], with: .fade)
            }
        case .delete:
            if let indexPath = indexPath {
                tableView.deleteRows(at: [indexPath], with: .fade)
            }
        case .move:
            if let indexPath = indexPath {
                tableView.deleteRows(at: [indexPath], with: .fade)
            }
            
            if let newIndexPath = newIndexPath {
                tableView.insertRows(at: [newIndexPath], with: .fade)
            }
        case .update:
            if let indexPath = indexPath, let cell = tableView.cellForRow(at: indexPath) {
                cellConfiguration(cell as! MainTableViewCellController, at: indexPath)
            }
        @unknown default:
            break
        }
    }
    
    func cellConfiguration(_ cell: MainTableViewCellController, at indexPath: IndexPath) {
        let ticket = fetchResultsController.object(at: indexPath)
        
        cell.ticketLabel.text = String(ticket.number)
        cell.arrivalLabel.text = "Arrival: \(timeDateFormatter.string(from: ticket.arrival!))"
    }
}
