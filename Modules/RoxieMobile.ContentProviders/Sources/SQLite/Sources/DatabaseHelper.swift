// ----------------------------------------------------------------------------
//
//  DatabaseHelper.swift
//
//  @author     Alexander Bragin <bragin-av@roxiemobile.com>
//  @copyright  Copyright (c) 2016, Roxie Mobile Ltd. All rights reserved.
//  @link       https://www.roxiemobile.com/
//
// ----------------------------------------------------------------------------
// swiftlint:disable file_length type_body_length
// ----------------------------------------------------------------------------

import ContentProvidersFileSystem
import CryptoKit
import Foundation
import GRDB
import SwiftCommonsConcurrent
import SwiftCommonsLang
import SwiftCommonsLogging

// ----------------------------------------------------------------------------

// A helper class to manage database creation and version management.
// @link https://github.com/android/platform_frameworks_base/blob/master/core/java/android/database/sqlite/SQLiteOpenHelper.java
// swiftlint:disable:previous line_length

// ----------------------------------------------------------------------------

/// A helper class to manage database creation and version management.
public class DatabaseHelper {

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
    public init(name: String?, version: Int, readonly: Bool = false, delegate: DatabaseOpenDelegate? = nil) {
        self.databaseQueue = openOrCreateDatabase(
            databaseName: name,
            version: version,
            readonly: readonly,
            delegate: delegate
        )
    }

    private init() {
        // Do nothing
    }

    deinit {
        self.databaseQueue = nil
    }

// MARK: - Properties

    /// The database queue.
    public final private(set) var databaseQueue: DatabaseQueue?

    /// Gets or sets the UserVersion pragma for the current database.
    public var userVersion: Int {
        get {
            let version = try? self.databaseQueue?.read({ db -> Int? in
                try Int.fetchOne(db, sql: "PRAGMA user_version;")
            })
            return version ?? -1
        }
        set {
            do {
                try self.databaseQueue?.write({ db in
                    try db.execute(sql: "PRAGMA user_version = \(newValue);")
                })
            }
            catch {
                Logger.e(Roxie.typeName(of: self), "Failed to set user-version integer.", error)
            }
        }
    }

// MARK: - Methods

    /// Checks if database file exists and integrity check of the entire database was successful.
    public static func isValidDatabase(databaseName: String?, delegate: DatabaseOpenDelegate? = nil) -> Bool {
        return DatabaseHelper.shared.validateDatabase(databaseName: databaseName, delegate: delegate)
    }

// MARK: - Internal Methods

    internal func unpackDatabaseTemplate(databaseName: String, assetPath: URL) -> URL? {
        var path: URL?

        // Copy template file from application assets to the temporary directory
        if let tmpPath = makeTemplatePath(databaseName: databaseName) {

            // Remove previous template file
            FileManager.roxie_removeItem(at: tmpPath)

            // Copy new template file
            if FileManager.roxie_copyItem(at: assetPath, to: tmpPath) {
                path = tmpPath
            }
        }
        else {
            Roxie.fatalError("Could not make temporary path for database ‘\(databaseName)’.")
        }

        // Done
        return path
    }

    internal func makeDatabasePath(databaseName: String?) -> URL? {

        let name = sanitizeName(name: databaseName)
        var path: URL?

        // Build path to the database file
        if !name.isEmpty && (name != Inner.InMemoryDatabase) {
            path = Roxie.databasesDirectory?
                .appendingPathComponent((name.md5() as NSString).appendingPathExtension(FileExtension.SQLite)!)
        }

        // Done
        return path
    }

    internal func makeTemplatePath(databaseName: String?) -> URL? {

        let name = sanitizeName(name: databaseName)
        var path: URL?

        // Build path to the template file
        if !name.isEmpty && (name != Inner.InMemoryDatabase) {
            path = Roxie.temporaryDirectory?
                .appendingPathComponent((name.md5() as NSString).appendingPathExtension(FileExtension.SQLite)!)
        }

        // Done
        return path
    }

// MARK: - Private Methods

    private func validateDatabase(databaseName: String?, delegate: DatabaseOpenDelegate? = nil) -> Bool {
        var result = false

        // Check if database file exists
        if let path = makeDatabasePath(databaseName: databaseName), path.roxie_fileExists {

            // Check integrity of database
            let dbQueue = openDatabase(databaseName: databaseName, version: nil, readonly: true, delegate: delegate)
            result = checkDatabaseIntegrity(dbQueue: dbQueue)
        }

        // Done
        return result
    }

    private func openOrCreateDatabase(
        databaseName: String?,
        version: Int,
        readonly: Bool,
        delegate: DatabaseOpenDelegate?
    ) -> DatabaseQueue? {

        // Try to open existing database
        var dbQueue = openDatabase(
            databaseName: databaseName,
            version: version,
            readonly: readonly,
            delegate: delegate
        )

        // Create and open new database
        if (dbQueue == nil) {
            dbQueue = createDatabase(
                databaseName: databaseName,
                version: version,
                readonly: readonly,
                delegate: delegate
            )
        }

        // Done
        return dbQueue
    }

    private func openDatabase(
        // swiftlint:disable:previous function_body_length
        databaseName: String?,
        version: Int?,
        readonly: Bool,
        delegate: DatabaseOpenDelegate?
    ) -> DatabaseQueue? {

        var name: String? = sanitizeName(name: databaseName)
        var dbQueue: DatabaseQueue!

        // Validate database name
        if let dstPath = makeDatabasePath(databaseName: databaseName), dstPath.roxie_fileExists {
            name = dstPath.path
        }
        else if (name != Inner.InMemoryDatabase) {
            name = nil
        }

        // Open on-disk OR in-memory database
        if name.isNotBlank {

            var configuration = Configuration()
            configuration.readonly = readonly

            // Send events to the delegate
            if let delegate = delegate {

                objcTry {
                    // Configure the database before open
                    delegate.configureDatabase(name: databaseName, configuration: &configuration)

                    dbQueue = self.createDatabaseObject(path: name, configuration: configuration)

                    // Migrate database
                    if let newVersion = version {
                        let oldVersion = self.userVersion

                        // Init OR update database if needed
                        if (oldVersion != newVersion) {

                            if dbQueue.configuration.readonly {

                                let errorName = NSExceptionName(rawValue: NSError.DatabaseError.Domain)
                                let errorMessage = "Can't migrate read-only database from version \(oldVersion) to \(newVersion)."
                                // swiftlint:disable:previous line_length

                                NSException(name: errorName, reason: errorMessage, userInfo: nil).raise()
                            }

                            var blockException: NSException?
                            self.runTransaction(dbQueue: dbQueue, kind: .exclusive, block: { _ in

                                var result: Database.TransactionCompletion!
                                var exception: NSException?

                                objcTry {
                                    if (oldVersion < 1) {

                                        delegate.databaseDidCreate(
                                            name: databaseName,
                                            dbQueue: dbQueue
                                        )
                                    }
                                    else if (oldVersion > newVersion) {

                                        delegate.downgradeDatabase(
                                            name: databaseName,
                                            dbQueue: dbQueue,
                                            oldVersion: oldVersion,
                                            newVersion: newVersion
                                        )
                                    }
                                    else {

                                        delegate.upgradeDatabase(
                                            name: databaseName,
                                            dbQueue: dbQueue,
                                            oldVersion: oldVersion,
                                            newVersion: newVersion
                                        )
                                    }

                                    // Update schema version
                                    self.userVersion = newVersion

                                    // Commit transaction on success
                                    result = .commit

                                    // Done
                                }.objcCatch { ex in

                                    // Rollback transaction on error
                                    exception = ex
                                    result = .rollback
                                }

                                // NOTE: Bug fix for block variable
                                blockException = exception

                                if result == .rollback {
                                    throw DatabaseError.failedTransaction
                                }

                                return result
                            })

                            // Re-throw exception if exists
                            blockException?.raise()
                        }
                    }

                    // Database did open successfully
                    delegate.databaseDidOpen(name: databaseName, dbQueue: dbQueue)

                    // Done
                }.objcCatch { ex in

                    // Convert NSException to NSError
                    let error = NSError(code: NSError.DatabaseError.Code.databaseIsInvalid, description: ex.reason)

                    // Could not open OR migrate database
                    delegate.databaseDidOpenWithError(name: databaseName, error: error)
                    dbQueue = nil
                }
            }
            else {
                dbQueue = createDatabaseObject(path: name, configuration: configuration)
            }
        }

        // Done
        return dbQueue
    }

    private func createDatabase(
        databaseName: String?,
        version: Int,
        readonly: Bool,
        delegate: DatabaseOpenDelegate?
    ) -> DatabaseQueue? {

        let name = sanitizeName(name: databaseName)
        var dbQueue: DatabaseQueue?

        // Create on-disk database
        if let dstPath = makeDatabasePath(databaseName: databaseName) {

            // Remove previous database file
            FileManager.roxie_removeItem(at: dstPath)

            // Get path of the database template file from delegate
            if let (path, encryptionKey) = delegate?.databaseWillCreate(name: databaseName),
               (path != nil) && path!.roxie_fileExists {

                // Unpack database template from the assets
                if let tmpPath = unpackDatabaseTemplate(databaseName: databaseName!, assetPath: path!),
                   tmpPath.roxie_fileExists {

                    let path = tmpPath.path

                    var dbQueueUnpacked: DatabaseQueue? = createDatabaseObject(
                        path: path,
                        configuration: Configuration()
                    )

                    if checkDatabaseIntegrity(dbQueue: dbQueueUnpacked) {

                        // Export/copy database template to the "Databases" folder
                        if let key = encryptionKey, !key.isEmpty {

                            // FMDB with SQLCipher Tutorial
                            // @link https://www.guilmo.com/fmdb-with-sqlcipher-tutorial/

                            execute(dbQueue: dbQueueUnpacked,
                                query: "ATTACH DATABASE '\(dstPath.path)' AS `encrypted` KEY '\(key.hex())';")
                            execute(dbQueue: dbQueueUnpacked,
                                query: "SELECT sqlcipher_export('encrypted');")
                            execute(dbQueue: dbQueueUnpacked,
                                query: "DETACH DATABASE `encrypted`;")
                        }
                        else {
                            FileManager.roxie_copyItem(at: tmpPath, to: dstPath)
                        }

                        // Exclude file from back-up to iCloud
                        FileManager.roxie_excludeFromBackup(at: dstPath)
                    }

                    // Release resources
                    dbQueueUnpacked = nil

                    // Remove database template file
                    FileManager.roxie_removeItem(at: tmpPath)
                }
            }

            // Try to open created database
            dbQueue = openDatabase(
                databaseName: databaseName,
                version: version,
                readonly: readonly,
                delegate: delegate
            )

            // Remove corrupted database file
            if (dbQueue == nil) {
                FileManager.roxie_removeItem(at: dstPath)
            }
        }
        // Create in-memory database
        else if (name == Inner.InMemoryDatabase) {

            dbQueue = openDatabase(
                databaseName: name,
                version: version,
                readonly: readonly,
                delegate: delegate
            )
        }

        // Done
        return dbQueue
    }

    private func checkDatabaseIntegrity(dbQueue: DatabaseQueue?) -> Bool {

        let result = try? dbQueue?.read({ db -> String? in
            try String.fetchOne(db, sql: "PRAGMA quick_check;")
        })

        return result?.lowercased() == "ok"
    }

    private func sanitizeName(name: String?) -> String {

        guard let name = name, name.isNotBlank else {
            return Inner.InMemoryDatabase
        }

        return name
    }

    // DEPRECATED: Code refactoring is required
    private func execute(dbQueue: DatabaseQueue?, query: String) {

        guard let dbQueue = dbQueue else {
            return
        }

        do {
            try dbQueue.write({ db in
                try db.execute(sql: query)
            })
        }
        catch {
            Roxie.fatalError("Database query \(query) failed", cause: error)
        }
    }

    // DEPRECATED: Code refactoring is required
    private func createDatabaseObject(path: String?, configuration: Configuration) -> DatabaseQueue {

        guard let path = path else {
            Roxie.fatalError("Can't create database object with nil uri path")
        }

        do {
            return try DatabaseQueue(path: path, configuration: configuration)
        }
        catch {
            Roxie.fatalError("Can't open db at \(path) with readonly \(configuration.readonly)", cause: error)
        }
    }

    // DEPRECATED: Code refactoring is required
    private func runTransaction(
        dbQueue: DatabaseQueue?,
        kind: Database.TransactionKind,
        block: @escaping (Database) throws -> Database.TransactionCompletion
    ) {

        guard let dbQueue = dbQueue else {
            Roxie.fatalError("Can't run transaction on nil database")
        }

        do {
            try dbQueue.inTransaction(kind, block)
        }
        catch {
            Roxie.fatalError("Transaction failed", cause: error)
        }
    }

// MARK: - Constants

    private struct Inner {
        static let InMemoryDatabase = ":memory:"
    }

    private struct FileExtension {
        static let SQLite = "sqlite"
    }

// MARK: - Inner Types

    enum DatabaseError: Error {
        case failedTransaction
    }

// MARK: - Variables

    private static let shared: DatabaseHelper = DatabaseHelper()
}

// ----------------------------------------------------------------------------

extension Data {

// MARK: - Methods

    fileprivate func hex() -> String {
        return self.map { String(format: "%02hhx", $0) }.joined()
    }
}

// ----------------------------------------------------------------------------

extension String {

// MARK: - Methods

    fileprivate func md5() -> String {
        let digest = Insecure.MD5.hash(data: Data(self.utf8))
        return digest.map { String(format: "%02hhx", $0) }.joined()
    }
}
