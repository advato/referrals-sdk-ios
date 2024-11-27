

import Foundation

typealias SuccessResult<T> = (T) -> Void
typealias ErrorResult = (Error) -> Void

protocol APIClient {
    func send<R: Decodable>(
        provider: RequestProvider,
        onSuccess: @escaping SuccessResult<R>,
        onError: ErrorResult?
    ) -> Cancellable?
}
