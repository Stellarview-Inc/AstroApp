//
//  AstroAppAPI+Standard.swift
//
//
//  Created by Tristan Chay on 30/7/23.
//

import Foundation

public protocol AstroAppGettable: AstroAppAPIProtocol {
    associatedtype GetPathParameters: StringCodable
    associatedtype GetQueryParameters: StringCodable
    associatedtype GetRequestData: Codable
    associatedtype GetResponseData: Decodable
    static var apiGettable: String { get }
    static func get(
        params: GetPathParameters,
        query: GetQueryParameters,
        data: GetRequestData,
        completion: @escaping (Result<GetResponseData, Error>) -> Void
    )
}

public protocol AstroAppUpdatable: AstroAppAPIProtocol {
    associatedtype UpdatePathParameters: StringCodable
    associatedtype UpdateQueryParameters: StringCodable
    associatedtype UpdateRequestData: Codable
    associatedtype UpdateResponseData: Decodable
    static var apiUpdatable: String { get }
    static func update(
        params: UpdatePathParameters,
        query: UpdateQueryParameters,
        data: UpdateRequestData,
        completion: @escaping (Result<UpdateResponseData, Error>) -> Void
    )
}
