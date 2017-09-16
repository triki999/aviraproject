//
//  StoryDetailCell.swift
//  AviraProject
//
//  Created by andrei on 9/16/17.
//  Copyright © 2017 andrei. All rights reserved.
//

import Foundation
import UIKit
import ReactiveCocoa
import ReactiveSwift

fileprivate let formater = DateFormatter()

func getTimeFromInterval(_ interval:Double) -> String
{
    formater.dateFormat = "MMMM dd yyyy"
    let date = Date(timeIntervalSince1970:interval)
    return formater.string(from: date)
}

class StoryDetailCell: UITableViewCell {
    @IBOutlet weak var imgStory: UIImageView!
    @IBOutlet weak var imgStatus: UIImageView!
    @IBOutlet weak var lbTitle: UILabel!
    @IBOutlet weak var lbTime: UILabel!
    
    var cellDBStory:DBStory?
    
    func setCellIndexPath(_ index:IndexPath,modelView:StoriesListViewModel) -> SignalProducer<IndexPath,WebErrors>
    {
        
        lbTime.text = "";
        lbTitle.text = "  \n  ";
        
        
        let signal = modelView.getStorySignal(index: index)
            .take(during: self.reactive.lifetime)
            .take(until: self.reactive.prepareForReuse)
            .doNext {[weak self] (dbStory) in
                
                self?.cellDBStory = dbStory;

                if let title = dbStory.title{
                    self?.lbTitle.text = title;
                }else {
                    self?.lbTitle.text = "  \n  ";
                }
                
                
                if let time = dbStory.time.value{
                    self?.lbTime.text = getTimeFromInterval(time);
                }else{
                    self?.lbTime.text = "";
                }
                
                
            }.flatMap(.latest) { (_) -> SignalProducer<IndexPath,WebErrors> in
                return SignalProducer(value:index)
        }
        
        
        return signal
    }
    
    
    
    
    
}
