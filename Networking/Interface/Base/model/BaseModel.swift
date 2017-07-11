//
//  BaseModel.swift
//  Test_Moya
//
//  Created by hoomsun on 2017/6/19.
//  Copyright © 2017年 hoomsun. All rights reserved.
//

import Foundation
import ObjectMapper

class ResponseModel: Mappable {
    var data: Any?
    var errorCode: Int?
    var errorInfo: String?
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        data <- map["data"]
        errorCode <- map["errorCode"]
        errorInfo <- map["errorInfo"]
        
    }
}
