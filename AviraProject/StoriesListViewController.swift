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
fileprivate let headerIdentifier = "header"




class StoriesListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    let modelview = StoriesListViewModel()
    @IBOutlet weak var tableView: UITableView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.estimatedRowHeight = 70;
        tableView.rowHeight = UITableViewAutomaticDimension
        
        tableView.estimatedSectionHeaderHeight = 70;
        tableView.sectionHeaderHeight = UITableViewAutomaticDimension;
        
        
        modelview.getAllStoriesIDS()
            .observe(on: UIScheduler())
            .doNext {[weak self] (_) in
                self?.tableView.reloadData()
            }.startWithCompleted {
                
        }
        
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as! StoryDetailCell
        cell.setCellIndexPath(indexPath, modelView: modelview)
        cell.lbTitle.text = "aaa"
        
        return cell;
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let countNew = modelview.newStoriesListIDS?.ids.count, let countTop = modelview.topStoriesListIDS?.ids.count else {
            return 0
        }
        
        if section == 0{
            return countNew
        }
        
        return countTop;
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        guard let _ = modelview.newStoriesListIDS, let _ = modelview.topStoriesListIDS else {
            return nil
        }
        
        let view = UIView()
        
        let headerCell = tableView.dequeueReusableCell(withIdentifier: headerIdentifier) as! StoryCellHeader
        if section == 0{
            headerCell.lbTitle.text = "New Stories"
        }else{
            headerCell.lbTitle.text = "Top Stories"
        }
        view.addSubview(headerCell)
        
        return view
        
        
    }
    
    
    
}

