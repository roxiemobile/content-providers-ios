// ----------------------------------------------------------------------------
//
//  DatabaseOpenDelegate.swift
//
//  @author     Alexander Bragin <bragin-av@roxiemobile.com>
//  @copyright  Copyright (c) 2016, Roxie Mobile Ltd. All rights reserved.
//  @link       https://www.roxiemobile.com/
//
// ----------------------------------------------------------------------------

import Foundation
import GRDB

// ----------------------------------------------------------------------------

/// The interface for the delegate of a database open helper.
public protocol DatabaseOpenDelegate: AnyObject {

// MARK: - Methods

    /// Called when the database will create for the first time.
    ///
    /// - Parameters:
    ///   - name: The name of the database file, or `nil` for an in-memory database.
    ///
    /// - Returns:
    ///   Path of the database template file to use to copy the database or `nil` to create
    ///   the empty database file.
    ///
    func databaseWillCreate(name: String?) -> (assetPath: URL?, encryptionKey: Data?)

    /// Called when the database connection is being configured, to enable features such
    /// as write-ahead logging or foreign key support.
    ///
    /// - Parameters:
    ///   - name: The name of the database file, or `nil` for an in-memory database.
    ///   - configuration: The configuration for a database queue.
    ///
    func configureDatabase(name: String?, configuration: inout Configuration)

    /// Called when the database is created for the first time.
    ///
    /// - Parameters:
    ///   - name: The name of the database file, or `nil` for an in-memory database.
    ///   - dbQueue: The database queue.
    ///
    func databaseDidCreate(name: String?, dbQueue: DatabaseQueue)

    /// Called when the database needs to be upgraded.
    ///
    /// - Parameters:
    ///   - name: The name of the database file, or `nil` for an in-memory database.
    ///   - dbQueue: The database queue.
    ///   - oldVersion: The old database version.
    ///   - newVersion: The new database version.
    ///
    func upgradeDatabase(name: String?, dbQueue: DatabaseQueue, oldVersion: Int, newVersion: Int)

    /// Called when the database needs to be downgraded.
    ///
    /// - Parameters:
    ///   - name: The name of the database file, or `nil` for an in-memory database.
    ///   - dbQueue: The database queue.
    ///   - oldVersion: The old database version.
    ///   - newVersion: The new database version.
    ///
    func downgradeDatabase(name: String?, dbQueue: DatabaseQueue, oldVersion: Int, newVersion: Int)

    /// Called when the database has been opened.
    ///
    /// - Parameters:
    ///   - name: The name of the database file, or `nil` for an in-memory database.
    ///   - dbQueue: The database queue.
    ///
    func databaseDidOpen(name: String?, dbQueue: DatabaseQueue)

    /// Called when the database failed to be opened.
    ///
    /// - Parameters:
    ///   - name: The name of the database file, or `nil` for an in-memory database.
    ///   - error: The error description.
    ///
    func databaseDidOpenWithError(name: String?, error: NSError)
}
