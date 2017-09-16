//
//  ReadLaterViewModel.swift
//  AviraProject
//
//  Created by andrei on 9/16/17.
//  Copyright © 2017 andrei. All rights reserved.
//

import Foundation
import RealmSwift
import ReactiveCocoa
import ReactiveSwift


class ReadLaterViewModel
{
    
    var stories:[DBStory]?
    
    private let model = StorieModel.instance
    
    
    private let token = Lifetime.Token()
    public var lifetime: Lifetime {
        return Lifetime(token)
    }
    
   

    
    func getAllReadLaterStories() -> SignalProducer<Bool,WebErrors>
    {
        let signal = model.getAllReadLaterStories().doNext {[weak self] (stories) in
            self?.stories = stories;
        }.flatMap(.latest) { (_) -> SignalProducer<Bool,WebErrors> in
            return SignalProducer(value:true)
        }
        
        return signal;
    }
//
//
//    
//    func getStorySignal(index:IndexPath) ->SignalProducer<DBStory, WebErrors>
//    {
//        
//    }

}
