

import Foundation

final class Network: APIClient {
    func send<R>(
        provider: any RequestProvider,
        onSuccess: @escaping SuccessResult<R>,
        onError: ErrorResult? = nil
    ) -> (any Cancellable)? where R : Decodable {
        var request: URLRequest?
        do {
            request = try provider.asURLRequest()
        } catch {
            Logger.error(NetworkError.badRequest.localizedDescription)
            onError?(error)
        }
        guard let request else {
            onError?(NetworkError.badRequest)
            Logger.error(NetworkError.badRequest.localizedDescription)
            return nil
        }
        let task = NetworkConfiguration.default.activeSession.dataTask(with: request) {
            data, response, error in
            
            guard let urlResponse = response as? HTTPURLResponse else {
                let error = NetworkError.invalidResponse(reason: .missingResponseInfo)
                Logger.debugResponse(response: nil, error: error, responseData: nil)
                onError?(error)
                return
            }
            guard let data = data else {
                let error = NetworkError.invalidResponse(reason: .missingResponseInfo)
                Logger.debugResponse(response: urlResponse, error: error, responseData: nil)
                onError?(error)
                return
            }
            
            if urlResponse.statusCode == 401 {
                Logger.debugResponse(response: urlResponse, error: NetworkError.unauthorised, responseData: data)
                onError?(NetworkError.unauthorised)
                return
            }
            
            guard (200..<300).contains(urlResponse.statusCode) else {
                do {
                    let error = try JSONDecoder().decode(ErrorResponse.self, from: data)
                    Logger.debugResponse(response: urlResponse, error: error.message, responseData: data)
                    onError?(error.message)
                } catch {
                    Logger.debugResponse(response: urlResponse, error: error, responseData: data)
                    onError?(error)
                }
                return
            }
            
            do {
                let parsedResponse = try JSONDecoder().decode(R.self, from: data)
                Logger.debugResponse(response: urlResponse, error: nil, responseData: data)
                onSuccess(parsedResponse)
            } catch {
                let _error = NetworkError.responseDecodingFailed(reason: .invalidResponseData(error: error))
                Logger.debugResponse(response: urlResponse, error: _error, responseData: data)
                onError?(_error)
            }
        }
        
        task.resume()
        return task
    }
}
