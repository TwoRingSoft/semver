//
//  SemanticVersion.swift
//  Vrsnr
//
//  Created by Andrew McKnight on 6/28/16.
//  Copyright © 2016 Two Ring Software. All rights reserved.
//

import Foundation
// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}


public typealias SemanticVersionBumpOptions = VersionBumpOptions

public enum SemanticVersionRevision: SemanticVersionBumpOptions {

    case major
    case minor
    case patch

    public var name: String {
        switch self {
        case .major:
            return "major"
        case .minor:
            return "minor"
        case .patch:
            return "patch"
        }
    }

}

public struct SemanticVersion {

    let major: UInt
    let minor: UInt
    let patch: UInt

    let buildMetadata: String?
    let prereleaseIdentifier: String?

    public init(major: UInt, minor: UInt, patch: UInt, buildMetadata: String?, prereleaseIdentifier: String?) {
        self.major = major
        self.minor = minor
        self.patch = patch
        self.buildMetadata = buildMetadata
        self.prereleaseIdentifier = prereleaseIdentifier
    }

}

extension SemanticVersion: Equatable {}

public func ==(lhs: SemanticVersion, rhs: SemanticVersion) -> Bool {
    return lhs.major == rhs.major && lhs.minor == rhs.minor && lhs.patch == rhs.patch && lhs.buildMetadata == rhs.buildMetadata && lhs.prereleaseIdentifier == rhs.prereleaseIdentifier
}

extension SemanticVersion: Comparable {}

public func <(lhs: SemanticVersion, rhs: SemanticVersion) -> Bool {
    return lhs.major < rhs.major && lhs.minor < rhs.minor && lhs.patch < rhs.patch && lhs.prereleaseIdentifier < rhs.buildMetadata && lhs.buildMetadata < rhs.buildMetadata
}

extension SemanticVersion: Version {

    public static var statictype: VersionType {
        get {
            return .Semantic
        }
    }

    public var type: VersionType {
        get {
            return .Semantic
        }
    }

    public func nextVersion(_ options: VersionBumpOptions, prereleaseIdentifier: String?, buildMetadata: String?) -> SemanticVersion {
        let bumpMajor = options == SemanticVersionRevision.major.rawValue
        let bumpMinor = options == SemanticVersionRevision.minor.rawValue
        let bumpPatch = options == SemanticVersionRevision.patch.rawValue
        let major = self.major + (bumpMajor ? 1 : 0)
        let minor = bumpMajor ? 0 : self.minor + (bumpMinor ? 1 : 0)
        let patch = bumpMajor || bumpMinor ? 0 : self.patch + (bumpPatch ? 1 : 0)
        return SemanticVersion(major: major, minor: minor, patch: patch, buildMetadata: buildMetadata, prereleaseIdentifier: prereleaseIdentifier)
    }

    public static func parseFromString(_ string: String) throws -> SemanticVersion {
        if string == "$(CURRENT_PROJECT_VERSION)" {
            throw NSError(domain: errorDomain, code: Int(ErrorCode.dynamicVersionFound.rawValue), userInfo: [NSLocalizedDescriptionKey: "Dynamic value found: \(string). Rerun this script pointed at the file that defines CURRENT_PROJECT_VERSION, with the appropriate --key."])
        }

        let definitionComponents = string.components(separatedBy: CharacterSet(charactersIn: "-+"))
        if definitionComponents.count < 1 || definitionComponents.count > 3 {
            throw NSError(domain: errorDomain, code: ErrorCode.malformedVersionValue.valueAsInt(), userInfo: [NSLocalizedDescriptionKey: "Malformed definition (“\(string)”). Expecting M.m.p[-<prereleaseID>[+<metadata>]]. M, m and p may only contain numerals, and neither <prereleaseID> nor <metadata> may contain '-' or '+' characters."])
        }

        let versionComponents = definitionComponents[0].components(separatedBy: ".")
        if versionComponents.count < 1 || versionComponents.count > 3 {
            throw NSError(domain: errorDomain, code: Int(ErrorCode.malformedVersionValue.rawValue), userInfo: [NSLocalizedDescriptionKey: "Malformed definition (“\(string)”). Expecting M[.m[.p[-<prereleaseID>[+<metadata>]]]]. <prereleaseID> and <metadata> may not contain '-' or '+' characters."])
        }

        let numberFormatter = NumberFormatter()

        let major = numberFormatter.number(from: versionComponents[0])?.uintValue ?? 0
        var minor: UInt = 0
        var patch: UInt = 0
        if versionComponents.count > 1 {
            minor = numberFormatter.number(from: versionComponents[1])?.uintValue ?? 0
        }
        if versionComponents.count > 2 {
            patch = numberFormatter.number(from: versionComponents[2])?.uintValue ?? 0
        }

        let suffixes = getPrereleaseIdentifierAndBuildMetadata(string)

        return SemanticVersion(major: major, minor: minor, patch: patch, buildMetadata: suffixes.buildMetadata, prereleaseIdentifier: suffixes.prereleaseIdentifier)
    }

}

extension SemanticVersion: CustomStringConvertible {

    public var description: String {
        var string = "\(major).\(minor).\(patch)"
        if let prereleaseID = self.prereleaseIdentifier {
            string.append("-\(prereleaseID)")
        }
        if let metadata = self.buildMetadata {
            string.append("+\(metadata)")
        }
        return string
    }
    
}
