//
//  Router+RxSwift.swift
//
//  Created by Tadeas Kriz on 18/03/16.
//

import SwiftKit
import RxSwift
import SwiftKitStaging
import SwiftyJSON
import Alamofire

open typealias Response = SwiftKit.Response

open enum RouterError: Error {
    case invalidStatusCode(EmptyResponse)
    case requestError(Error, EmptyResponse)
    case authenticationError
    case unknownError
}

/// Extension that adds support basic types - for requests with no input and output and no output
open extension Router {
    fileprivate func observeRequest<T>(_ block: @escaping (@escaping (Response<T>) -> Void) -> Cancellable) -> Observable<Result<T, RouterError>> {
        return Observable.create { observer in
            let cancelable = block { response in
                if let error = response.error {
                    observer.onNext(.failure(.requestError(error, response.emptyCopy())))
                } else if response.statusCode?.isSuccess == false {
                    observer.onNext(.failure(.invalidStatusCode(response.emptyCopy())))
                } else {
                    observer.onNext(.success(response.output))
                }
                observer.onCompleted()
            }

            return Disposables.create {
                cancelable.cancel()
            }
        }
    }

    fileprivate func observeRequest<T>(_ block: @escaping (@escaping (Response<T?>) -> Void) -> Cancellable) -> Observable<Result<T, RouterError>> {
        return observeRequest(block).map { (result: Result<T?, RouterError>) in
            switch result {
            case .success(let maybeValue):
                if let value = maybeValue {
                    return .success(value)
                } else {
                    return .failure(.unknownError)
                }
            case .failure(let error):
                return .failure(error)
            }
        }
    }

    /**
     Performs request with no input data nor output data

     :param: endpoint The target Endpoint of the API
     :param: callback A callback that will be executed when the request is completed.
     :returns: Cancellable
     */
    open func rx_request<ENDPOINT: Endpoint>(endpoint: ENDPOINT) -> Observable<Result<Void, RouterError>>
        where ENDPOINT.Input == Void, ENDPOINT.Output == Void
    {
        return observeRequest {
            self.request(endpoint, callback: $0)
        }
    }

    /**
     Performs a request with no input data and a single String output.

     :param: endpoint The target Endpoint of the API
     :param: callback A callback that will be executed when the requests is completed.
     */
    open func rx_request<ENDPOINT: Endpoint>(endpoint: ENDPOINT) -> Observable<Result<String, RouterError>>
        where ENDPOINT.Input == Void, ENDPOINT.Output == String
    {
        return observeRequest {
            self.request(endpoint, callback: $0)
        }
    }

    open func rx_request<ENDPOINT: Endpoint>(endpoint: ENDPOINT) -> Observable<Result<[String], RouterError>>
        where ENDPOINT.Input == Void, ENDPOINT.Output == [String]
    {
        return observeRequest {
            self.request(endpoint, callback: $0)
        }
    }

    /**
     Performs request with no output data

     :param: endpoint The target Endpoint of the API
     :param: input The array of strings that will be filled to the Endpoint
     :param: callback The callback that is executed when request succeeds or fails
     :returns: Cancellable
     */
    open func rx_request<ENDPOINT: Endpoint>(endpoint: ENDPOINT, input: [String]) -> Observable<Result<Void, RouterError>>
        where ENDPOINT.Input == [String], ENDPOINT.Output == Void
    {
        return observeRequest {
            self.request(endpoint, input: input, callback: $0)
        }
    }
}

/// Extension that adds support for Serializable input and Deserializable output parameters
open extension Router {

    /**
     Performs request with Serializable input and no output

     :param: endpoint The target Endpoint of the API
     :param: input The Serializable that will be filled to the Endpoint
     :param: callback The callback that is executed when request succeeds or fails
     :returns: Cancellable
     */
    open func rx_request<IN, ENDPOINT>(endpoint: ENDPOINT, input: IN) -> Observable<Result<Void, RouterError>>
        where IN: Serializable, ENDPOINT: Endpoint, ENDPOINT.Input == IN, ENDPOINT.Output == Void
    {
        return observeRequest {
            self.request(endpoint, input: input, callback: $0)
        }
    }

    /**
     Performs request with input of array of Serializables and no output

     :param: endpoint The target Endpoint of the API
     :param: input The input array of Serializables that will be filled to the Endpoint
     :param: callback The callback that is executed when request succeeds or fails
     :returns: Cancellable
     */
    open func rx_request<IN, ENDPOINT>(endpoint: ENDPOINT, input: [IN]) -> Observable<Result<Void, RouterError>>
        where IN: Serializable, ENDPOINT: Endpoint, ENDPOINT.Input == [IN], ENDPOINT.Output == Void
    {
        return observeRequest {
            self.request(endpoint, input: input, callback: $0)
        }
    }

    /**
     Performs request with no input and Deserializable output

     :param: endpoint The target Endpoint of the API
     :param: callback The callback with Deserializable parameter
     :returns: Cancellable
     */
    open func rx_request<OUT, ENDPOINT>(endpoint: ENDPOINT) -> Observable<Result<OUT, RouterError>>
        where OUT: Deserializable, ENDPOINT: Endpoint, ENDPOINT.Input == Void, ENDPOINT.Output == OUT
    {
        return observeRequest {
            self.request(endpoint, callback: $0)
        }
    }

    /**
     Performs request with no input and output of Deserializable array

     :param: endpoint The target Endpoint of the API
     :param: callback The callback with Deserializable array parameter
     :returns: Cancellable
     */
    open func rx_request<OUT, ENDPOINT>(endpoint: ENDPOINT) -> Observable<Result<[OUT], RouterError>>
        where OUT: Deserializable, ENDPOINT: Endpoint, ENDPOINT.Input == Void, ENDPOINT.Output == [OUT]
    {
        return observeRequest {
            self.request(endpoint, callback: $0)
        }
    }

    /**
     Performs request with Serializable input and Deserializable output

     :param: endpoint The target Endpoint of the API
     :param: input The Serializable input
     :param: callback The callback with Deserializable parameter
     :returns: Cancellable
     */
    open func rx_request<IN, OUT, ENDPOINT>(endpoint: ENDPOINT, input: ENDPOINT.Input) -> Observable<Result<OUT, RouterError>>
        where IN: Serializable, OUT: Deserializable, ENDPOINT: Endpoint, ENDPOINT.Input == IN, ENDPOINT.Output == OUT
    {
        return observeRequest {
            self.request(endpoint, input: input, callback: $0)
        }
    }

    /**
     Performs request with input of Serializable array and Deserializable output

     :param: endpoint The target Endpoint of the API
     :param: input The input of Serializable array
     :param: callback The callback with Deserializable parameter
     :returns: Cancellable
     */
    open func rx_request<IN, OUT, ENDPOINT>(endpoint: ENDPOINT, input: ENDPOINT.Input) -> Observable<Result<OUT, RouterError>>
        where IN: Serializable, OUT: Deserializable, ENDPOINT: Endpoint, ENDPOINT.Input == [IN], ENDPOINT.Output == OUT
    {
        return observeRequest {
            self.request(endpoint, input: input, callback: $0)
        }
    }

    /**
     Performs request with Serializable input and output of Deserializable array

     :param: endpoint The target Endpoint of the API
     :param: input The Serializable input
     :param: callback The callback with Deserializable array parameter
     :returns: Cancellable
     */
    open func rx_request<IN, OUT, ENDPOINT>(endpoint: ENDPOINT, input: ENDPOINT.Input) -> Observable<Result<[OUT], RouterError>>
        where IN: Serializable, OUT: Deserializable, ENDPOINT: Endpoint, ENDPOINT.Input == IN, ENDPOINT.Output == [OUT]
    {
        return observeRequest {
            self.request(endpoint, input: input, callback: $0)
        }
    }

    /**
     Performs request with Serializable array input and Deserializable output

     :param: endpoint The target Endpoint of the API
     :param: input The input of Serializable array
     :param: callback The callback with Deserializable arrayparameter
     :returns: Cancellable
     */
    open func rx_request<IN, OUT, ENDPOINT>(endpoint: ENDPOINT, input: ENDPOINT.Input) -> Observable<Result<[OUT], RouterError>>
        where IN: Serializable, OUT: Deserializable, ENDPOINT: Endpoint, ENDPOINT.Input == [IN], ENDPOINT.Output == [OUT]
    {
        return observeRequest {
            self.request(endpoint, input: input, callback: $0)
        }
    }

    /**
     Performs request with input of String array and Deserializable output

     :param: endpoint The target Endpoint of the API
     :param: input The input of String array
     :param: callback The Response with Deserializable parameter
     :returns: Cancellable
     */
    open func rx_request<OUT, ENDPOINT>(endpoint: ENDPOINT, input: [String]) -> Observable<Result<OUT, RouterError>>
        where OUT: Deserializable, ENDPOINT: Endpoint, ENDPOINT.Input == [String], ENDPOINT.Output == OUT
    {
        return observeRequest {
            self.request(endpoint, input: input, callback: $0)
        }
    }

    /**
     Performs request with input of String array and Deserializable array output

     :param: endpoint The target Endpoint of the API
     :param: input The input of String array
     :param: callback The Response with Deserializable array parameter
     :returns: Cancellable
     */
    open func rx_request<OUT, ENDPOINT>(endpoint: ENDPOINT, input: ENDPOINT.Input) -> Observable<Result<[OUT], RouterError>>
        where OUT: Deserializable, ENDPOINT: Endpoint, ENDPOINT.Input == [String], ENDPOINT.Output == [OUT]
    {
        return observeRequest {
            self.request(endpoint, input: input, callback: $0)
        }
    }
}

/// Extension of Router tha adds JSON support
open extension Router {

    /**
     Performs request with input of JSON and output of JSON

     :param: input The input of JSON
     :param: callback The Response with parameter of JSON
     :returns: Cancellable
     */
    open func rx_request<ENDPOINT>(endpoint: ENDPOINT, input: JSON) -> Observable<Result<JSON, RouterError>>
        where ENDPOINT: Endpoint, ENDPOINT.Input == JSON, ENDPOINT.Output == JSON
    {
        return observeRequest {
            self.request(endpoint, input: input, callback: $0)
        }
    }
}
