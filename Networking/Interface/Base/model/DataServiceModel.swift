//
//  DataServiceCompletionModel.swift
//  Test_Moya
//
//  Created by hoomsun on 2017/6/22.
//  Copyright © 2017年 hoomsun. All rights reserved.
//

import Foundation
import ObjectMapper

class DataServiceCompletionModel: NSObject {
    var apiName: String = ""
    var apiModel: DataServiceResponseModel?
    /// 接口返回的对象，经过转换后的模型
    /// 可以是模型对象，或者模型数组对象
    var transformedModel: AnyObject?
    
    /// 本地状态码
    var localErrorCode: DataServiceStatus?
    /// 本地错误信息描述，无错误为空字符串
    var localErrorDescription: String?
    var data: AnyObject?
    /// 存放访问数据过程中的错误信息
    var errorArray: Array<Error>?
    /// 接口状态是否成功，只有本地和远程都正确时，才视为成功
    var success: Bool {
        get {
            if (self.apiModel == nil) {
                return false
            }
            
            // 如果有错误代码
            if (self.apiModel?.errorCode != 0) {
                return false;
            }
            
            // 如果接口状态OK
            if (self.localErrorCode != .ok) {
                return false;
            }
            return true;
        }
    }
    
    override init() {}
}


class DataServiceResponseModel: Mappable {
    var data: AnyObject?
    var errorCode: Int?
    var errorInfo: String?
    
    var dataDictionary: Dictionary<String, String>?
    var dataArray: Array<Any>?
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        data <- map["data"]
        errorCode <- map["errorCode"]
        errorInfo <- map["errorInfo"]
    }
}
