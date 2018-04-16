/// Encodes `Encodable` instances to `application/x-www-form-urlencoded` data.
///
///     print(user) /// User
///     let data = try FormURLEncoder().encode(user)
///     print(data) /// Data
public final class URLEncodedFormEncoder: DataEncoder {
    /// Create a new `FormURLEncoder`.
    public init() {}

    /// Encodes the supplied `Encodable` object to `Data`.
    ///
    ///     print(user) /// User
    ///     let data = try FormURLEncoder().encode(user)
    ///     print(data) /// Data
    ///
    /// - parameters:
    ///     - encodable: Generic `Encodable` object (`E`) to encode.
    /// - returns: Encoded `Data`
    /// - throws: Any error that may occur while attempting to encode the specified type.
    public func encode<E>(_ encodable: E) throws -> Data where E: Encodable {
        let partialData = PartialFormURLEncodedData(
            data: .dictionary([:])
        )
        let encoder = _FormURLEncoder(
            partialData: partialData,
            codingPath: []
        )
        try encodable.encode(to: encoder)
        let serializer = URLEncodedFormSerializer()
        guard case .dictionary(let dict) = partialData.data else {
            throw URLEncodedFormError(
                identifier: "invalidTopLevel",
                reason: "form-urlencoded requires a top level dictionary"
            )
        }
        return try serializer.serialize(dict)
    }
}

/// MARK: Private

/// Internal form urlencoded encoder.
/// See FormURLEncoder for the public encoder.
final class _FormURLEncoder: Encoder {
    /// See Encoder.userInfo
    let userInfo: [CodingUserInfoKey: Any]

    /// See Encoder.codingPath
    let codingPath: [CodingKey]

    /// The data being decoded
    var partialData: PartialFormURLEncodedData

    /// Creates a new form url-encoded encoder
    init(partialData: PartialFormURLEncodedData, codingPath: [CodingKey]) {
        self.partialData = partialData
        self.codingPath = codingPath
        self.userInfo = [:]
    }

    /// See Encoder.container
    func container<Key>(keyedBy type: Key.Type) -> KeyedEncodingContainer<Key>
        where Key: CodingKey
    {
        let container = FormURLKeyedEncoder<Key>(partialData: partialData, codingPath: codingPath)
        return .init(container)
    }

    /// See Encoder.unkeyedContainer
    func unkeyedContainer() -> UnkeyedEncodingContainer {
        return FormURLUnkeyedEncoder(partialData: partialData, codingPath: codingPath)
    }

    /// See Encoder.singleValueContainer
    func singleValueContainer() -> SingleValueEncodingContainer {
        return FormURLSingleValueEncoder(partialData: partialData, codingPath: codingPath)
    }
}
