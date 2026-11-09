//
//  RazerDeviceCatalog.swift
//  RazerMacOS
//
//  Created by Garrett Butchko.
//

import Foundation
import LoggingKit

public struct RazerDeviceDefinition: Identifiable, Sendable {
    public let id: String
    public let name: String
    public let productId: UInt16
    public let productIdHex: String
    public let mainType: RazerDeviceType
    public let imageURL: String?
    public let maxDpi: Int
    public let missingFeatures: [String]

    public init(
        name: String,
        productIdHex: String,
        productId: UInt16,
        mainType: RazerDeviceType,
        imageURL: String? = nil,
        maxDpi: Int = 16000,
        missingFeatures: [String] = []
    ) {
        self.id = productIdHex.lowercased()
        self.name = name
        self.productIdHex = productIdHex
        self.productId = productId
        self.mainType = mainType
        self.imageURL = imageURL
        self.maxDpi = maxDpi
        self.missingFeatures = missingFeatures
    }
}

public final class RazerDeviceCatalog: @unchecked Sendable {
    public static let shared = RazerDeviceCatalog()

    private var devicesByProductId: [UInt16: RazerDeviceDefinition] = [:]
    public private(set) var allDevices: [RazerDeviceDefinition] = []

    private init() {
        loadCatalog()
    }

    public func definition(for productId: UInt16) -> RazerDeviceDefinition? {
        devicesByProductId[productId]
    }

    public func name(for productId: UInt16) -> String {
        devicesByProductId[productId]?.name ?? String(format: "Razer Device (0x%04X)", productId)
    }

    public func type(for productId: UInt16) -> RazerDeviceType {
        devicesByProductId[productId]?.mainType ?? .other
    }

    private func loadCatalog() {
        var loaded: [RazerDeviceDefinition] = []

        // Try reading from bundle resources or local directory
        let bundle = Bundle.main
        var resourceURLs = bundle.urls(forResourcesWithExtension: "json", subdirectory: "devices") ?? []
        
        // Fallback to checking directly in filesystem if running during development
        if resourceURLs.isEmpty {
            let directDir = URL(fileURLWithPath: "/Users/garrettbutchko/Documents/Projects/razer-macos/RazerMacOS/Resources/devices")
            if let urls = try? FileManager.default.contentsOfDirectory(at: directDir, includingPropertiesForKeys: nil) {
                resourceURLs = urls.filter { $0.pathExtension == "json" }
            }
        }

        for fileURL in resourceURLs {
            guard let data = try? Data(contentsOf: fileURL),
                  let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                  let name = json["name"] as? String,
                  let pIdStr = json["productId"] as? String else {
                continue
            }

            let hexClean = pIdStr.replacingOccurrences(of: "0x", with: "")
            guard let rawPid = UInt16(hexClean, radix: 16) else { continue }

            let rawType = (json["mainType"] as? String) ?? "other"
            let type = RazerDeviceType(rawValue: rawType.lowercased()) ?? .other
            let imageURL = json["image"] as? String
            let missing = (json["featuresMissing"] as? [String]) ?? []

            var maxDpi = 16000
            if let configList = json["featuresConfig"] as? [[String: Any]] {
                for item in configList {
                    if let dpiConf = item["dpi"] as? [String: Any],
                       let max = dpiConf["max"] as? Int {
                        maxDpi = max
                    }
                }
            }

            let def = RazerDeviceDefinition(
                name: name,
                productIdHex: pIdStr,
                productId: rawPid,
                mainType: type,
                imageURL: imageURL,
                maxDpi: maxDpi,
                missingFeatures: missing
            )

            loaded.append(def)
            devicesByProductId[rawPid] = def
        }

        // Sort alphabetically by name
        self.allDevices = loaded.sorted { $0.name < $1.name }
        AppLogger.info("Loaded \(self.allDevices.count) Razer hardware profiles into catalog.", tag: "Catalog")
    }
}
