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

public typealias Result = Alamofire.Result
public typealias Response = SwiftKit.Response

public enum RouterError: ErrorType {
    case InvalidStatusCode(EmptyResponse)
    case RequestError(ErrorType, EmptyResponse)
    case AuthenticationError
    case UnknownError
}

/// Extension that adds support basic types - for requests with no input and output and no output
public extension Router {
    private func observeRequest<T>(block: (Response<T> -> Void) -> Cancellable) -> Observable<Result<T, RouterError>> {
        return Observable.create { observer in
            let cancelable = block { response in
                if let error = response.error {
                    observer.onNext(.Failure(.RequestError(error, response.emptyCopy())))
                } else if response.statusCode?.isSuccess == false {
                    observer.onNext(.Failure(.InvalidStatusCode(response.emptyCopy())))
                } else {
                    observer.onNext(.Success(response.output))
                }
                observer.onCompleted()
            }

            return AnonymousDisposable {
                cancelable.cancel()
            }
        }
    }

    private func observeRequest<T>(block: (Response<T?> -> Void) -> Cancellable) -> Observable<Result<T, RouterError>> {
        return observeRequest(block).map { (result: Result<T?, RouterError>) in
            switch result {
            case .Success(let maybeValue):
                if let value = maybeValue {
                    return .Success(value)
                } else {
                    return .Failure(.UnknownError)
                }
            case .Failure(let error):
                return .Failure(error)
            }
        }
    }

    /**
     Performs request with no input data nor output data

     :param: endpoint The target Endpoint of the API
     :param: callback A callback that will be executed when the request is completed.
     :returns: Cancellable
     */
    public func rx_request<ENDPOINT: Endpoint
        where ENDPOINT.Input == Void, ENDPOINT.Output == Void>
        (endpoint: ENDPOINT) -> Observable<Result<Void, RouterError>>
    {
        return observeRequest(curry(request)(endpoint))
    }

    /**
     Performs a request with no input data and a single String output.

     :param: endpoint The target Endpoint of the API
     :param: callback A callback that will be executed when the requests is completed.
     */
    public func rx_request<ENDPOINT: Endpoint
        where ENDPOINT.Input == Void, ENDPOINT.Output == String>
        (endpoint: ENDPOINT) -> Observable<Result<String, RouterError>>
    {
        return observeRequest(curry(request)(endpoint))
    }

    public func rx_request<ENDPOINT: Endpoint
        where ENDPOINT.Input == Void, ENDPOINT.Output == [String]>
        (endpoint: ENDPOINT) -> Observable<Result<[String], RouterError>>
    {
        return observeRequest(curry(request)(endpoint))
    }

    /**
     Performs request with no output data

     :param: endpoint The target Endpoint of the API
     :param: input The array of strings that will be filled to the Endpoint
     :param: callback The callback that is executed when request succeeds or fails
     :returns: Cancellable
     */
    public func rx_request<ENDPOINT: Endpoint
        where ENDPOINT.Input == [String], ENDPOINT.Output == Void>
        (endpoint: ENDPOINT, input: [String]) -> Observable<Result<Void, RouterError>>
    {
        return observeRequest(curry(request)(endpoint)(input))
    }
}

/// Extension that adds support for Serializable input and Deserializable output parameters
public extension Router {

    /**
     Performs request with Serializable input and no output

     :param: endpoint The target Endpoint of the API
     :param: input The Serializable that will be filled to the Endpoint
     :param: callback The callback that is executed when request succeeds or fails
     :returns: Cancellable
     */
    public func rx_request<IN: Serializable, ENDPOINT: Endpoint
        where ENDPOINT.Input == IN, ENDPOINT.Output == Void>
        (endpoint: ENDPOINT, input: IN) -> Observable<Result<Void, RouterError>>
    {
        return observeRequest(curry(request)(endpoint)(input))
    }

    /**
     Performs request with input of array of Serializables and no output

     :param: endpoint The target Endpoint of the API
     :param: input The input array of Serializables that will be filled to the Endpoint
     :param: callback The callback that is executed when request succeeds or fails
     :returns: Cancellable
     */
    public func rx_request<IN: Serializable, ENDPOINT: Endpoint
        where ENDPOINT.Input == [IN], ENDPOINT.Output == Void>
        (endpoint: ENDPOINT, input: [IN]) -> Observable<Result<Void, RouterError>>
    {
        return observeRequest(curry(request)(endpoint)(input))
    }

    /**
     Performs request with no input and Deserializable output

     :param: endpoint The target Endpoint of the API
     :param: callback The callback with Deserializable parameter
     :returns: Cancellable
     */
    public func rx_request<OUT: Deserializable, ENDPOINT: Endpoint
        where ENDPOINT.Input == Void, ENDPOINT.Output == OUT>
        (endpoint: ENDPOINT) -> Observable<Result<OUT, RouterError>>
    {
        return observeRequest(curry(request)(endpoint))
    }

    /**
     Performs request with no input and output of Deserializable array

     :param: endpoint The target Endpoint of the API
     :param: callback The callback with Deserializable array parameter
     :returns: Cancellable
     */
    public func rx_request<OUT: Deserializable, ENDPOINT: Endpoint
        where ENDPOINT.Input == Void, ENDPOINT.Output == [OUT]>
        (endpoint: ENDPOINT) -> Observable<Result<[OUT], RouterError>>
    {
        return observeRequest(curry(request)(endpoint))
    }

    /**
     Performs request with Serializable input and Deserializable output

     :param: endpoint The target Endpoint of the API
     :param: input The Serializable input
     :param: callback The callback with Deserializable parameter
     :returns: Cancellable
     */
    public func rx_request<IN: Serializable, OUT: Deserializable, ENDPOINT: Endpoint
        where ENDPOINT.Input == IN, ENDPOINT.Output == OUT>
        (endpoint: ENDPOINT, input: ENDPOINT.Input) -> Observable<Result<OUT, RouterError>>
    {
        return observeRequest(curry(request)(endpoint)(input))
    }

    /**
     Performs request with input of Serializable array and Deserializable output

     :param: endpoint The target Endpoint of the API
     :param: input The input of Serializable array
     :param: callback The callback with Deserializable parameter
     :returns: Cancellable
     */
    public func rx_request<IN: Serializable, OUT: Deserializable, ENDPOINT: Endpoint
        where ENDPOINT.Input == [IN], ENDPOINT.Output == OUT>
        (endpoint: ENDPOINT, input: ENDPOINT.Input) -> Observable<Result<OUT, RouterError>>
    {
        return observeRequest(curry(request)(endpoint)(input))
    }

    /**
     Performs request with Serializable input and output of Deserializable array

     :param: endpoint The target Endpoint of the API
     :param: input The Serializable input
     :param: callback The callback with Deserializable array parameter
     :returns: Cancellable
     */
    public func rx_request<IN: Serializable, OUT: Deserializable, ENDPOINT: Endpoint
        where ENDPOINT.Input == IN, ENDPOINT.Output == [OUT]>
        (endpoint: ENDPOINT, input: ENDPOINT.Input) -> Observable<Result<[OUT], RouterError>>
    {
        return observeRequest(curry(request)(endpoint)(input))
    }

    /**
     Performs request with Serializable array input and Deserializable output

     :param: endpoint The target Endpoint of the API
     :param: input The input of Serializable array
     :param: callback The callback with Deserializable arrayparameter
     :returns: Cancellable
     */
    public func rx_request<IN: Serializable, OUT: Deserializable, ENDPOINT: Endpoint
        where ENDPOINT.Input == [IN], ENDPOINT.Output == [OUT]>
        (endpoint: ENDPOINT, input: ENDPOINT.Input) -> Observable<Result<[OUT], RouterError>>
    {
        return observeRequest(curry(request)(endpoint)(input))
    }

    /**
     Performs request with input of String array and Deserializable output

     :param: endpoint The target Endpoint of the API
     :param: input The input of String array
     :param: callback The Response with Deserializable parameter
     :returns: Cancellable
     */
    public func rx_request<OUT: Deserializable, ENDPOINT: Endpoint
        where ENDPOINT.Input == [String], ENDPOINT.Output == OUT>
        (endpoint: ENDPOINT, input: [String]) -> Observable<Result<OUT, RouterError>>
    {
        return observeRequest(curry(request)(endpoint)(input))
    }

    /**
     Performs request with input of String array and Deserializable array output

     :param: endpoint The target Endpoint of the API
     :param: input The input of String array
     :param: callback The Response with Deserializable array parameter
     :returns: Cancellable
     */
    public func rx_request<OUT: Deserializable, ENDPOINT: Endpoint
        where ENDPOINT.Input == [String], ENDPOINT.Output == [OUT]>
        (endpoint: ENDPOINT, input: ENDPOINT.Input) -> Observable<Result<[OUT], RouterError>>
    {
        return observeRequest(curry(request)(endpoint)(input))
    }
}

/// Extension of Router tha adds JSON support
public extension Router {

    /**
     Performs request with input of JSON and output of JSON

     :param: input The input of JSON
     :param: callback The Response with parameter of JSON
     :returns: Cancellable
     */
    public func rx_request<ENDPOINT: Endpoint
        where ENDPOINT.Input == JSON, ENDPOINT.Output == JSON>
        (endpoint: ENDPOINT, input: JSON) -> Observable<Result<JSON, RouterError>>
    {
        return observeRequest(curry(request)(endpoint)(input))
    }
}
