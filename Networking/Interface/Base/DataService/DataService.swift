//
//  DataService.swift
//  Test_Moya
//
//  Created by hoomsun on 2017/6/22.
//  Copyright © 2017年 hoomsun. All rights reserved.
//

import Foundation
import Alamofire
import ObjectMapper


typealias ServiceCompletion = (DataServiceCompletionModel) -> Void


enum DataServiceStatus: Int {
    case unknown = -1
    case ok
    case networkError
    case requestFaild
    case requestParamsBadFormat
    case responseBadFormat
    case responseServerError
}

class DataService: NSObject {
    static let sharedInstance: DataService = { DataService() }()
    fileprivate var apiBaseURLString: String {
        get {
            return kAPIBaseURL
        }
    }
}


// MARK: -
extension DataService {
    
    // MARK: Core Func
    public func sendRequest(with apiName: String,
                            params: Dictionary<String, String>?,
                            completion: @escaping (DataServiceCompletionModel) -> Void) {
        baseSendRequest(apiName: apiName, params: params, data: nil, mimeType: nil) { (model) in
            DispatchQueue.main.async {
                completion(model)
            }
        }
    }
    
    public func sendDataRequest(with apiName: String,
                                params: Dictionary<String, String>?,
                                data: Data?,
                                mimeType: String?,
                                completion: @escaping (DataServiceCompletionModel) -> Void) {
        baseSendRequest(apiName: apiName, params: params, data: data, mimeType: mimeType) { (model) in
            DispatchQueue.main.async {
                completion(model)
            }
        }
    }
    
    private func baseSendRequest(apiName: String, params: Dictionary<String, String>?, data: Data?, mimeType: String?, completion: @escaping (DataServiceCompletionModel) -> Void) {
        
        let urlStr = apiBaseURLString + "/" + apiName
        guard let urlString = urlStr.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else { return }
        let newParams = combinePostParamBody(with: apiName, params: params)
        
        print(message: "\n"+urlString)
        
        if let params = newParams {
            print(message: "\(params)")
        }
        
        let manager = Alamofire.SessionManager.default
        
        #if DEBUG
            manager.session.configuration.timeoutIntervalForRequest = 8.0
        #else
            manager.session.configuration.timeoutIntervalForRequest = 15.0
        #endif
        
        // 如果数据为空，则表示不用上传文件或图片，只是一般的调用数据接口
        if data == nil {
//        if datas == nil || datas?.count == 0 {
            Alamofire.request(urlString, method: .post, parameters: newParams, encoding: URLEncoding.default, headers: [:]).validate(statusCode: 200..<300).responseJSON { (response) in
                print(message: "\napiReturn:")
                print(message: "\(apiName)")
                
                let completionModel: DataServiceCompletionModel = DataServiceCompletionModel()
                
                switch response.result{
                case .success(let value):
                    print(message: "\(value)")
                    completionModel.apiName = apiName
                    completionModel.localErrorCode = .ok
                    let responseModel: DataServiceResponseModel = DataServiceResponseModel(JSON: value as! Dictionary)!
                    completionModel.apiModel = responseModel
                    
                    let data: AnyObject? = responseModel.data
                    if let data = data {
                        if (data.isKind(of: NSDictionary.self)) {
                            let dict = data as! NSDictionary
                            completionModel.apiModel?.dataDictionary = dict as? Dictionary
                        } else if (data.isKind(of: NSArray.self)) {
                            let arr = data as! NSArray
                            completionModel.apiModel?.dataArray = arr as? Array
                        } else {
                            completionModel.data = data
                        }
                    } else {
                        completionModel.data = nil
                    }
                    
                case .failure(let error):
                    print("\(error)")
                    completionModel.apiModel = nil;
                    completionModel.localErrorCode = .unknown;
                    completionModel.localErrorDescription = error.localizedDescription;
                }
                
                DispatchQueue.main.async {
                    completion(completionModel)
                }
            }
        }
        else {
//            Alamofire.upload(multipartFormData: { (multipartFormData) in
//                guard let datas = datas, datas.count > 0 else { return }
//                
//                for data in datas {
//                    let formatter = DateFormatter()
//                    formatter.dateFormat = "yyyyMMddHHmmss"
//                    let str = formatter.string(from: Date())
//                    let imageFileName = str + ".jpg"
//                    multipartFormData.append(data, withName: "file", fileName:imageFileName, mimeType: mimeType ?? "")
//                }
//            }, to: urlString) { (encodingResult) in
//                switch encodingResult {
//                case .success(let upload, _, _):
////                    upload.responseJSON { response in
////                        print(response)
////                    }
//                    upload.responseString(completionHandler: { (response) in
//                        debugPrint(response)
//                    })
//                case .failure(let encodingError):
//                    print(encodingError)
//                }
//            }
            
//            guard let datas = datas, datas.count > 0 else { return }
            guard let data = data else { return }
            
//            for data in datas {
//                let formatter = DateFormatter()
//                formatter.dateFormat = "yyyyMMddHHmmss"
//                let str = formatter.string(from: Date())
//                let imageFileName = str + ".jpg"
//            }
            Alamofire.upload(data, to: urlString).responseString(completionHandler: { (response) in
                debugPrint(response)
            })
        }
    }
}



// MARK: -
extension DataService {
    
    // MARK: Func
    fileprivate func combinePostParamBody(with APIName: String, params: Dictionary<String, String>?) -> Dictionary<String, String>? {
//        guard (params != nil) else {
//            return nil
//        }
        var body = NSMutableDictionary()
        
        if let params = params{
            body = NSMutableDictionary(dictionary: params)
        }
        
        if self.shouldIncludeLoginInfoFor(apiName: APIName) {
            // 增加固定的请求参数，如UUID等
            let user = LoginInfo.savedLoginInfo()
            body["UUID"] = user?.UUID
            body["userId"] = user?.USER_ID;
        }
        return body as? Dictionary<String, String>
    }
    
    fileprivate func shouldIncludeLoginInfoFor(apiName: String) -> Bool {
        let excludeItems: Array<String> = ["financialAdvisor/selectPhotoAndSign.do", "financialAdvisor/updateImg.do"]
        
        guard excludeItems.count>0 else { return false }
        
        if excludeItems.contains(apiName) {
            return true
        } else {
            return false
        }
    }
}
