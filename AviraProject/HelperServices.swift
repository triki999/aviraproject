//
//  HelperServices.swift
//  AviraProject
//
//  Created by andrei on 9/16/17.
//  Copyright © 2017 andrei. All rights reserved.
//

import Foundation
import ReactiveSwift


class HelperServices
{
    
    private static let topStoryUrl = "https://hacker-news.firebaseio.com/v0/topstories.json";
    private static let newStoryUrl = "https://hacker-news.firebaseio.com/v0/newstories.json";
    
    
    public static func getTopStories() -> SignalProducer<StoriesList,WebErrors>
    {
        let signal:SignalProducer<StoriesList,WebErrors> = MainService.get(url: topStoryUrl)
        return signal;
    }
    
    public static func getNewStories() -> SignalProducer<StoriesList,WebErrors>
    {
        let signal:SignalProducer<StoriesList,WebErrors> = MainService.get(url: newStoryUrl)
        return signal;
    }
    
    
    public static func getStoryDetails(storyId:Int) -> SignalProducer<Story,WebErrors>
    {
        let storyUrl = "https://hacker-news.firebaseio.com/v0/item/\(storyId).json";
        let signal:SignalProducer<Story,WebErrors> = MainService.get(url: storyUrl)
        return signal;
        
    }
}
