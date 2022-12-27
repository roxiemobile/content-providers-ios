// ----------------------------------------------------------------------------
//
//  DatabaseHelperZip.swift
//
//  @author     Alexander Bragin <bragin-av@roxiemobile.com>
//  @copyright  Copyright (c) 2016, Roxie Mobile Ltd. All rights reserved.
//  @link       https://www.roxiemobile.com/
//
// ----------------------------------------------------------------------------

import Foundation
import SwiftCommonsExtensions
import SwiftCommonsLang
import SwiftCommonsLogging
import ZIPFoundation

// ----------------------------------------------------------------------------

/// A helper class to manage database creation and version management.
public class DatabaseHelperZip: DatabaseHelper {

// MARK: - Construction

    /// Create a helper object to create, open, and/or manage a database.
    ///
    /// - Parameters:
    ///   - name: The name of the database file, or `nil` for an in-memory database.
    ///   - version: The version number of the database (starting at 1);
    ///     if the database is older, `upgradeDatabase` will be used to upgrade the database;
    ///     if the database is newer, `downgradeDatabase` will be used to downgrade the database.
    ///   - readonly: The flag to open the database for reading only.
    ///   - delegate: The delegate of the database open helper.
    ///
    public override init(name: String?, version: Int, readonly: Bool = false, delegate: DatabaseOpenDelegate? = nil) {
        super.init(name: name, version: version, readonly: readonly, delegate: delegate)
    }

// MARK: - Methods

    internal override func unpackDatabaseTemplate(databaseName: String, assetPath: URL) -> URL? {
        var path: URL?

        // Copy template file from application assets to the temporary directory
        if let tmpPath = makeTemplatePath(databaseName: databaseName) {

            // Remove previous template file
            FileManager.roxie_removeItem(at: tmpPath)

            // Unzip database template file from the assets
            if let archive = Archive(url: assetPath, accessMode: .read),
               let entry = archive[databaseName] {

                do {
                    _ = try archive.extract(entry, to: tmpPath, skipCRC32: true)
                    path = tmpPath
                }
                catch {
                    let message = "Failed to extract ‘\(databaseName)’ from archive ‘\(assetPath.path)’."
                    Logger.w(Roxie.typeName(of: self), message, error)
                }
            }
        }
        else {
            Roxie.fatalError("Could not make temporary path for database ‘\(databaseName)’.")
        }

        return path
    }
}
