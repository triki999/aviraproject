//
//  MainService.swift
//  AviraProject
//
//  Created by andrei on 9/16/17.
//  Copyright © 2017 andrei. All rights reserved.
//

import Foundation
import Alamofire
import ReactiveSwift
import ReactiveAlamofire
import Result
import Argo





class MainService{
    

    public static func get<U:Decodable>(url:String) -> SignalProducer<U, WebErrors> where U == U.DecodedType
    {
        let callSignalProducer = Alamofire.request(url).responseProducer().flatMapError { (resultError) -> SignalProducer<ResponseProducerResult, WebErrors> in
            return SignalProducer(error: WebErrors.AlamoError);
            }.flatMap(.latest) { (value) -> SignalProducer<U,WebErrors> in
                

                guard let d = value.data,let json = try? JSONSerialization.jsonObject(with: d, options: []) else
                {
                    return SignalProducer(error: WebErrors.AlamoError);
                }
                
                let response = U.decode(JSON(json))
                
                switch response{
                case .failure(let error):
                    print(error)
                    return SignalProducer(error: WebErrors.AlamoError);
  
                case .success(let value):
                    return SignalProducer(value:value);
                    
                }
        }
        
        return callSignalProducer.observe(on: UIScheduler());
        
    }
}
