// The Swift Programming Language
// https://docs.swift.org/swift-book

public enum AstroAppAPI: AstroAppAPIProtocol {
    public enum AASpreadsheets: AstroAppAPIProtocol {}
}

public protocol AstroAppAPIProtocol {}

/// Like Codable but to `[String: String]`
public protocol StringCodable {
    func stringDictionaryEncoded() -> [String: String]
}

public struct VoidStringCodable: StringCodable, Codable {
    public init() {}
    public func stringDictionaryEncoded() -> [String : String] { [:] }
}
