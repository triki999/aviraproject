//
//  ReadLaterViewController.swift
//  AviraProject
//
//  Created by andrei on 9/16/17.
//  Copyright © 2017 andrei. All rights reserved.
//

import Foundation
import UIKit
import ReactiveSwift
import ReactiveCocoa
import Result

fileprivate let cellIdentifier = "cell"

class ReadLaterViewController : UIViewController, UITableViewDelegate, UITableViewDataSource
{
    @IBOutlet weak var tableView: UITableView!
    let modelView = ReadLaterViewModel()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.estimatedRowHeight = 70;
        tableView.rowHeight = UITableViewAutomaticDimension
        
        let appearSignal = self.reactive.signal(for: #selector(UIViewController.viewWillAppear(_:)))
        
        appearSignal.flatMap(.latest) {[weak self] (_) in
            return self?.modelView.getAllReadLaterStories() ?? SignalProducer.empty
        }.doNext {[weak self] (_) in
            self?.tableView.reloadData()
            }.observeCompleted {
                
        }
        
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as! StoryDetailCell
        
        cell.storyAtIndexPath(indexPath, modelView: modelView).startWithCompleted {
            
        }
        
        return cell;
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let interuptSignal = self.reactive.signal(for: #selector(UITableViewDelegate.tableView(_:didSelectRowAt:)))
            .flatMap(.latest) { (_) -> SignalProducer<(),NoError> in
                SignalProducer.empty;
        }
        
        
        
        modelView.getStorySignal(index: indexPath)
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
    

    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let count = modelView.stories?.count else {
            return 0
        }
        
        
        return count;
    }
    
    
    
}
