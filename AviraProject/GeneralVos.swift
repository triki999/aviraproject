//
//  GeneralVos.swift
//  AviraProject
//
//  Created by andrei on 9/16/17.
//  Copyright © 2017 andrei. All rights reserved.
//

import Foundation
import Argo
import Runes
import Curry

struct StoriesList
{
//    [
//    15263460
//    15263448
//    15263438
//    15263431]
    
    let ids: [Int];
}


extension StoriesList : Decodable
{
    static func decode(_ json: JSON) -> Decoded<StoriesList>
    {
        
        let val = [Int].decode(json)
        switch val{
        case .failure(let err):
            return Decoded.failure(err)
            
        case .success(let val):
            return Decoded.success(StoriesList(ids: val))
        }
        
    }
}



struct Story
{
    let id: Int;
    let time: Int?;
    let title: String?;
    let url: String?;
    
  
    
    //    by: "rl3"
    //    descendants: 0
    //    id: 10900279
    //    score: 3
    //    time: 1452762088
    //    title: "Ann Caracristi, who cracked codes, and the glass ceiling, at NSA, dies at 94"
    //    type: "story"
    //    url: "https://www.washingtonpost.com/national/ann-caracristi-who-excelled-at-code-breaking-and-management-dies-at-94/2016/01/11/b8187468-b80d-11e5-b682-4bb4dd403c7d_story.html"
}


extension Story : Decodable
{
    public static func decode(_ json: JSON) -> Decoded<Story>
    {
        
        let val = curry(Story.init)
            <^> json <| "id"
            <*> json <|? "time"
            <*> json <|? "title"
            <*> json <|? "url"
        
        return val;
    }
}
