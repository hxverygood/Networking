//
//  HSInterface.swift
//  Test_Moya
//
//  Created by hoomsun on 2017/6/19.
//  Copyright © 2017年 hoomsun. All rights reserved.
//

import UIKit
//import Moya
import Alamofire

class HSInterface: NSObject {
    public var name = ""
    
    
    /// json数据接口
    ///
    /// - Parameters:
    ///   - apiName: 接口名
    ///   - params: 参数
    ///   - completion: 回调
    public class func HX_POST(apiName: String, params: Dictionary<String, String>?, completion: @escaping (Int, String?, Any?, Error?, Int, Bool) -> Void) {

        DataService.sharedInstance.sendRequest(with: apiName, params: params) { (model) in
            var data: Any? = nil
            var errInfo: String = ""
            
            if let dict = model.apiModel?.dataDictionary {
                data = dict
            } else if let array = model.apiModel?.dataArray {
                data = array
            } else {
                data = model.apiModel?.data
            }
            errInfo = (model.apiModel?.errorInfo)!
            
            let errCode: DataServiceStatus = model.localErrorCode!
            
            switch errCode {
            case .networkError:
                errInfo = "网络连接异常"
            case .requestFaild:
                errInfo = "网络请求异常"
            case .requestParamsBadFormat:
                errInfo = "请求参数错误"
            case .responseBadFormat:
                errInfo = "数据格式错误"
            case .responseServerError:
                errInfo = model.localErrorDescription!
            default:
                break
            }
            
            completion(model.apiModel!.errorCode!, errInfo, data, nil, errCode.rawValue, model.success)
        }
    }
    
    
    
    /// 数据传输接口
    ///
    /// - Parameters:
    ///   - apiName: 接口名
    ///   - params: 参数
    ///   - datas: 数据
    ///   - mimeType: 数据类型
    ///   - completion: 回调
    public class func HX_POST(apiName: String, params: Dictionary<String, String>?, data: Data, mimeType: String, completion: @escaping (Int, String?, Any?, Error?, Int, Bool) -> Void) {
        DataService.sharedInstance.sendDataRequest(with: apiName, params: params, data: data, mimeType: mimeType) { (model) in
            var data: Any? = nil
            var errInfo: String = ""
            
            if let dict = model.apiModel?.dataDictionary {
                data = dict
            } else if let array = model.apiModel?.dataArray {
                data = array
            } else {
                data = model.apiModel?.data
            }
            errInfo = (model.apiModel?.errorInfo)!
            
            let errCode: DataServiceStatus = model.localErrorCode!
            
            switch errCode {
            case .networkError:
                errInfo = "网络连接异常"
            case .requestFaild:
                errInfo = "网络请求异常"
            case .requestParamsBadFormat:
                errInfo = "请求参数错误"
            case .responseBadFormat:
                errInfo = "数据格式错误"
            case .responseServerError:
                errInfo = model.localErrorDescription!
            default:
                break
            }
            
            completion(model.apiModel!.errorCode!, errInfo, data, nil, errCode.rawValue, model.success)
        }
    }
}
