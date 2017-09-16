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
import Result




fileprivate let cellIdentifier = "cell"
fileprivate let headerIdentifier = "header"




class StoriesListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    let modelview = StoriesListViewModel()
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var btnNewAndTopStories: UIButton!
    @IBOutlet weak var btnSaveForLater: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.estimatedRowHeight = 70;
        tableView.rowHeight = UITableViewAutomaticDimension
        
        tableView.estimatedSectionHeaderHeight = 70;
        tableView.sectionHeaderHeight = UITableViewAutomaticDimension;
        
        
        self.edgesForExtendedLayout = .all
        
        
        
        let appearSignal = self.reactive.signal(for: #selector(UIViewController.viewWillAppear(_:))).take(during: self.reactive.lifetime)
        appearSignal.flatMap(.latest) {[weak self] (_) in
            return self?.modelview.getAllStoriesIDS().observe(on: UIScheduler()) ?? SignalProducer.empty
            }.doNext {[weak self] (_) in
                self?.tableView.reloadData()
            }.observeCompleted {
                
        }
        
        self.modelview.getLocalStoriesIDS()
            .observe(on: UIScheduler())
            .take(during: self.reactive.lifetime).doNext {[weak self] (_) in
             self?.tableView.reloadData()
            }.startWithCompleted {
                
        }
        
        btnNewAndTopStories.reactive.controlEvents(.touchUpInside)
            .take(during: self.reactive.lifetime)
            .flatMap(.latest) {[weak self] (_) in
                return self?.modelview.getAllStoriesIDS().observe(on: UIScheduler()) ?? SignalProducer.empty
            }.doNext {[weak self] (_) in
                self?.tableView.reloadData()
                self?.tableView.scrollToRow(at: IndexPath(item: 0, section: 0), at: .top, animated: true)
            }.observeCompleted {
                
        }
        
        
        btnSaveForLater.reactive.controlEvents(.touchUpInside)
            .take(during: self.reactive.lifetime).doNext {[weak self] (_) in
                //goto ReadLater
                guard let controller = self?.storyboard?.instantiateViewController(withIdentifier: "ReadLaterViewController") as? ReadLaterViewController else {
                    return;
                }
                
                self?.navigationController?.pushViewController(controller, animated: true)
                
            }.observeCompleted {
                
        }
        
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as! StoryDetailCell
        cell.setCellIndexPath(indexPath, modelView: modelview).startWithCompleted {
            
        }
        
        return cell;
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let interuptSignal = self.reactive.signal(for: #selector(UITableViewDelegate.tableView(_:didSelectRowAt:)))
            .flatMap(.latest) { (_) -> SignalProducer<(),NoError> in
                SignalProducer.empty;
        }
        
        
        modelview.getStorySignal(index: indexPath)
            .take(until: interuptSignal)
            .take(during: self.reactive.lifetime).doNext {[weak self] (dbStory) in
                print(dbStory)
                
                guard let controller = self?.storyboard?.instantiateViewController(withIdentifier: "StoryWebviewController") as? StoryWebviewController else {
                    return
                }
                controller.dbStoryData = dbStory;
                
                self?.navigationController?.pushViewController(controller, animated: true)
                
            }.startWithCompleted {
                
        }
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
        
        
        let headerCell = tableView.dequeueReusableCell(withIdentifier: headerIdentifier) as! StoryCellHeader
        if section == 0{
            headerCell.lbTitle.text = "New Stories"
        }else{
            headerCell.lbTitle.text = "Top Stories"
        }
        
        
        return headerCell
        
        
    }
    
    
    
}

