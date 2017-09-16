//
//  StoriesModel.swift
//  AviraProject
//
//  Created by andrei on 9/16/17.
//  Copyright © 2017 andrei. All rights reserved.
//

import Foundation
import ReactiveSwift

class StorieModel
{
    enum StoryType
    {
        case new, top
    }
    
    public static let  instance:StorieModel = StorieModel()

    private init()
    {
        
    }
    
    
    public func getStoriesDetailList(type:StorieModel.StoryType) -> SignalProducer<[Story],WebErrors>
    {
        
        var storyListSignal:SignalProducer<StoriesList,WebErrors>!
        
        switch type
        {
            case .new:
                storyListSignal = HelperServices.getNewStories()
            break;
            
            case .top:
                storyListSignal = HelperServices.getTopStories()
            break;
        }
        
        
        let sigg = storyListSignal.flatMap(.latest) { (storiesList) -> SignalProducer<[Story],WebErrors> in
            
            let storyDetailsProducers = storiesList.ids.map({ (storyId) -> SignalProducer<Story,WebErrors> in
                return HelperServices.getStoryDetails(storyId: storyId)
            })
            
            let sig =  SignalProducer(storyDetailsProducers).flatMap(.concat, transform: { (signal) -> SignalProducer<Story,WebErrors> in
                return signal
            })
            
            return sig.collect()
        }

        return sigg
    }
    
    
    
}
