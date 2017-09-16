//
//  ViewController.swift
//  AviraProject
//
//  Created by andrei on 9/16/17.
//  Copyright © 2017 andrei. All rights reserved.
//

import UIKit
import ReactiveSwift
import ReactiveCocoa





fileprivate let cellIdentifier = "cell"





class StoriesListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    

    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.estimatedRowHeight = 70;
        tableView.rowHeight = UITableViewAutomaticDimension


    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as! StoryDetailCell
        cell.lbTitle.text = "pai ce faci bai nene \n unde te duci mai tz \n vi si pe la mine \n pai ce faci bai nene \n unde te duci mai tz \n vi si pe la mine,pai ce faci bai nene \n unde te duci mai tz \n vi si pe la mine aaaaaaaaaa"
        return cell;
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10;
    }



}

