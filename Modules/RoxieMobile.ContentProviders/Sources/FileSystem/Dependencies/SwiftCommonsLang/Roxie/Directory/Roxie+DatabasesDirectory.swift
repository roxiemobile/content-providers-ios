// ----------------------------------------------------------------------------
//
//  Roxie+DatabasesDirectory.swift
//
//  @author     Alexander Bragin <bragin-av@roxiemobile.com>
//  @copyright  Copyright (c) 2022, Roxie Mobile Ltd. All rights reserved.
//  @link       https://www.roxiemobile.com/
//
// ----------------------------------------------------------------------------

import Foundation
import SwiftCommonsExtensions
import SwiftCommonsLang
import SwiftCommonsLogging

// ----------------------------------------------------------------------------

extension Roxie {

// MARK: - Properties

    /// Returns the databases directory for the current user.
    public static var databasesDirectory: URL? {
        Directory.databases
    }

// MARK: - Private Methods

    private static func getOrCreateDirectory(_ pathComponent: String) -> URL? {

        let dstURL: URL? = Roxie.documentsDirectory?.appendingPathComponent(pathComponent)
        let fm = FileManager.default

        // Create directory if not exists
        if let dstPath = dstURL?.path, let dstURL = dstURL {

            if !fm.fileExists(atPath: dstPath) {
                do {
                    try fm.createDirectory(atPath: dstPath, withIntermediateDirectories: true, attributes: nil)
                }
                catch {
                    Logger.e(Roxie.self, "Failed to create directory at path: \(dstPath)", error)
                }
            }
            FileManager.roxie_excludeFromBackup(at: dstURL)
        }

        return dstURL
    }

// MARK: - Constants

    private enum Directory {

        /// The databases directory for the current user.
        static let databases: URL? = Roxie.getOrCreateDirectory("Databases")
    }
}
