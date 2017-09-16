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

class StoryDetailCell: UITableViewCell {
    @IBOutlet weak var imgStory: UIImageView!
    @IBOutlet weak var imgStatus: UIImageView!
    @IBOutlet weak var lbTitle: UILabel!

    
    
    func setCellIndexPath(_ index:IndexPath,modelView:StoriesListViewModel)
    {
  
        modelView.getStorySignal(index: index)
            .take(during: self.reactive.lifetime)
            .take(until: self.reactive.prepareForReuse).doNext { (dbStory) in
                
                //todo
                print(dbStory)
                
            }.startWithCompleted {
                
        }
        
    }
    


    
}
