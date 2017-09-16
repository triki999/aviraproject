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

struct StorieList
{
//    [
//    15263460
//    15263448
//    15263438
//    15263431]
    
    let ids: [Int];
}


extension StorieList : Decodable
{
    static func decode(_ json: JSON) -> Decoded<StorieList>
    {
        
        let val = [Int].decode(json)
        switch val{
        case .failure(let err):
            return Decoded.failure(err)
            
        case .success(let val):
            return Decoded.success(StorieList(ids: val))
        }
        
    }
}



struct Storie
{
    let by: String;
    let descendants: Int;
    let id: Int;
    let score: String;
    let time: Int;
    let title: String;
    let type: String;
    let url: String;
    
    
    
    //    by: "rl3"
    //    descendants: 0
    //    id: 10900279
    //    score: 3
    //    time: 1452762088
    //    title: "Ann Caracristi, who cracked codes, and the glass ceiling, at NSA, dies at 94"
    //    type: "story"
    //    url: "https://www.washingtonpost.com/national/ann-caracristi-who-excelled-at-code-breaking-and-management-dies-at-94/2016/01/11/b8187468-b80d-11e5-b682-4bb4dd403c7d_story.html"
}


extension Storie : Decodable
{
    public static func decode(_ json: JSON) -> Decoded<Storie>
    {
        
        return curry(Storie.init)
            <^> json <| "by"
            <*> json <| "descendants"
            <*> json <| "id"
            <*> json <| "score"
            <*> json <| "time"
            <*> json <| "title"
            <*> json <| "type"
            <*> json <| "url"
        
    }
}
