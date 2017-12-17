//
//  FirstViewController.swift
//  Thread
//
//  Created by Developer on 11/28/16.
//  Copyright © 2016 JwitApps. All rights reserved.
//

import UIKit

import FirebaseDatabase

import SwiftTools

class ThreadListViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    
    var threads: [Thread] = [] {
        didSet {
            tableView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let databaseRef = FIRDatabase.database().reference()
        databaseRef.child("threads").observe(.value, with: {
            self.threads = ($0.children.allObjects as! [FIRDataSnapshot]).map(Thread.init)
            
            self.updateActiveUsersCounts(for: self.threads)
        })
    }
    
    func updateActiveUsersCounts(for threads: [Thread]) {
        
        for thread in threads {
            
            let databaseRef = FIRDatabase.database().reference()
            databaseRef.child("active/"+thread.key).observe(.value, with: { snapshot in
                
                self.tableView.visibleCells.forEach {
                    if let threadCell = $0 as? ThreadTableViewCell,
                        threadCell.thread.name == thread.name {
                        
                        threadCell.activeUsers = Int(snapshot.childrenCount)
                    }
                }
                
            })
        }
        
    }
}

extension ThreadListViewController: UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return threads.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let controller = ConversationViewController()
        controller.thread = threads[indexPath.row]
        controller.hidesBottomBarWhenPushed = true
        navigationController!.pushViewController(controller, animated: true)
        
        tableView.selectRow(at: nil, animated: true, scrollPosition: .none)
    }
}

extension ThreadListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ThreadTableViewCell") as? ThreadTableViewCell ?? Bundle.main.loadNibNamed("ThreadTableViewCell", owner: nil, options: nil)![0] as! ThreadTableViewCell
        cell.thread = threads[indexPath.row]
        
//        let cell = tableView.dequeueReusableCell(withIdentifier: "default") ?? UITableViewCell(style: .default, reuseIdentifier: "default")
//        cell.textLabel?.text = threads[indexPath.row].name
        return cell
    }
}
