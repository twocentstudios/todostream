////////////////////////////////////////////////////////////////////////////
//
// Copyright 2014 Realm Inc.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//
////////////////////////////////////////////////////////////////////////////

import Foundation
import Realm
import Realm.Private

/**
Migration block used to migrate a Realm.

- parameter migration: `Migration` object used to perform the migration. The
                       migration object allows you to enumerate and alter any
                       existing objects which require migration.
- parameter oldSchemaVersion: The schema version of the `Realm` being migrated.
*/
public typealias MigrationBlock = (migration: Migration, oldSchemaVersion: UInt64) -> Void

/// Object class used during migrations.
public typealias MigrationObject = DynamicObject

/**
Provides both the old and new versions of an object in this Realm. Object properties can only be
accessed using subscripting.

- parameter oldObject: Object in original `Realm` (read-only).
- parameter newObject: Object in migrated `Realm` (read-write).
*/
public typealias MigrationObjectEnumerateBlock = (oldObject: MigrationObject?, newObject: MigrationObject?) -> Void

/**
Specify a schema version and an associated migration block which is applied when
opening the default Realm with an old schema version.

Before you can open an existing `Realm` which has a different on-disk schema
from the schema defined in your object interfaces, you must provide a migration
block which converts from the disk schema to your current object schema. At the
minimum your migration block must initialize any properties which were added to
existing objects without defaults and ensure uniqueness if a primary key
property is added to an existing object.

You should call this method before accessing any `Realm` instances which
require migration. After registering your migration block, Realm will call your
block automatically as needed.

- warning: Unsuccessful migrations will throw exceptions when the migration block is applied.
           This will happen in the following cases:

           - The given `schemaVersion` is lower than the target Realm's current schema version.
           - A new property without a default was added to an object and not initialized
             during the migration. You are required to either supply a default value or to
             manually populate added properties during a migration.

- parameter version: The current schema version.
- parameter block:   The block which migrates the Realm to the current version.
*/
@available(*, deprecated=1, message="Use Realm(configuration:error:)")
public func setDefaultRealmSchemaVersion(schemaVersion: UInt64, migrationBlock: MigrationBlock) {
    RLMRealmSetSchemaVersionForPath(schemaVersion, Realm.Configuration.defaultConfiguration.path, accessorMigrationBlock(migrationBlock))
}

/**
Specify a schema version and an associated migration block which is applied when
opening a Realm at the specified path with an old schema version.

Before you can open an existing `Realm` which has a different on-disk schema
from the schema defined in your object interfaces, you must provide a migration
block which converts from the disk schema to your current object schema. At the
minimum your migration block must initialize any properties which were added to
existing objects without defaults and ensure uniqueness if a primary key
property is added to an existing object.

You should call this method before accessing any `Realm` instances which
require migration. After registering your migration block, Realm will call your
block automatically as needed.

- parameter version:   The current schema version.
- parameter realmPath: The path of the Realms to migrate.
- parameter block:     The block which migrates the Realm to the current version.
*/
@available(*, deprecated=1, message="Use Realm(configuration:error:)")
public func setSchemaVersion(schemaVersion: UInt64, realmPath: String, migrationBlock: MigrationBlock) {
    RLMRealmSetSchemaVersionForPath(schemaVersion, realmPath, accessorMigrationBlock(migrationBlock))
}

/**
Get the schema version for a Realm at a given path.
- parameter realmPath:     Path to a Realm file.
- parameter encryptionKey: Optional 64-byte encryption key for encrypted Realms.
- parameter error:         If an error occurs, upon return contains an `NSError` object
                           that describes the problem. If you are not interested in
                           possible errors, omit the argument, or pass in `nil`.

- returns: The version of the Realm at `realmPath` or `nil` if the version cannot be read.
*/
public func schemaVersionAtPath(realmPath: String, encryptionKey: NSData? = nil, error: NSErrorPointer = nil) -> UInt64? {
    let version = RLMRealm.schemaVersionAtPath(realmPath, encryptionKey: encryptionKey, error: error)
    if version == RLMNotVersioned {
        return nil
    }
    return version
}

/**
Performs the registered migration block on a Realm at the given path.

This method is called automatically when opening a Realm for the first time and does
not need to be called explicitly. You can choose to call this method to control
exactly when and how migrations are performed.

- parameter path:          The path of the Realm to migrate.
- parameter encryptionKey: Optional 64-byte encryption key for encrypted Realms.
                           If the Realms at the given path are not encrypted, omit the argument or pass
                           in `nil`.

- returns: `nil` if the migration was successful, or an `NSError` object that describes the problem
           that occured otherwise.
*/
@available(*, deprecated=1, message="Use migrateRealm(configuration:)")
public func migrateRealm(path: String, encryptionKey: NSData? = nil) -> NSError? {
    let configuration = RLMRealmConfiguration.defaultConfiguration()
    configuration.path = path
    configuration.encryptionKey = encryptionKey
    configuration.schemaVersion = UInt64(RLMRealmSchemaVersionForPath(path))
    configuration.migrationBlock = RLMRealmMigrationBlockForPath(path)
    return RLMRealm.migrateRealm(configuration)
}

/**
Performs the configuration's migration block on the Realm created by the given
configuration.

This method is called automatically when opening a Realm for the first time and does
not need to be called explicitly. You can choose to call this method to control
exactly when and how migrations are performed.

- parameter configuration: The Realm.Configuration used to create the Realm to be
                           migrated, and containing the schema version and migration
                           block used to perform the migration.

- returns: `nil` if the migration was successful, or an `NSError` object that describes the problem
           that occured otherwise.
*/
public func migrateRealm(configuration: Realm.Configuration = Realm.Configuration.defaultConfiguration) -> NSError? {
    return RLMRealm.migrateRealm(configuration.rlmConfiguration)
}


/**
`Migration` is the object passed into a user-defined `MigrationBlock` when updating the version
of a `Realm` instance.

This object provides access to the previous and current `Schema`s for this migration.
*/
public final class Migration {

    // MARK: Properties

    /// The migration's old `Schema`, describing the `Realm` before applying a migration.
    public var oldSchema: Schema { return Schema(rlmMigration.oldSchema) }

    /// The migration's new `Schema`, describing the `Realm` after applying a migration.
    public var newSchema: Schema { return Schema(rlmMigration.newSchema) }

    internal var rlmMigration: RLMMigration

    // MARK: Altering Objects During a Migration

    /**
    Enumerates objects of a given type in this Realm, providing both the old and new versions of
    each object. Object properties can be accessed using subscripting.

    - parameter objectClassName: The name of the `Object` class to enumerate.
    - parameter block:           The block providing both the old and new versions of an object in this Realm.
    */
    public func enumerate(objectClassName: String, _ block: MigrationObjectEnumerateBlock) {
        rlmMigration.enumerateObjects(objectClassName) {
            block(oldObject: unsafeBitCast($0, MigrationObject.self), newObject: unsafeBitCast($1, MigrationObject.self))
        }
    }

    /**
    Create an `Object` of type `className` in the Realm being migrated.

    - parameter className: The name of the `Object` class to create.
    - parameter value:     The object used to populate the new `Object`. This can be any key/value coding
                           compliant object, or a JSON object such as those returned from the methods in
                           `NSJSONSerialization`, or an `Array` with one object for each persisted
                           property. An exception will be thrown if any required properties are not
                           present and no default is set.

    - returns: The created object.
    */
    public func create(className: String, value: AnyObject = [:]) -> MigrationObject {
        return unsafeBitCast(rlmMigration.createObject(className, withValue: value), MigrationObject.self)
    }

    /**
    Delete an object from a Realm during a migration. This can be called within
    `enumerate(_:block:)`.

    - parameter object: Object to be deleted from the Realm being migrated.
    */
    public func delete(object: MigrationObject) {
        RLMDeleteObjectFromRealm(object, RLMObjectBaseRealm(object))
    }

    /**
    Deletes the data for the class with the given name.
    This deletes all objects of the given class, and if the Object subclass no longer exists in your program,
    cleans up any remaining metadata for the class in the Realm file.

    - parameter objectClassName: The name of the Object class to delete.

    - returns: `true` if there was any data to delete.
    */
    public func deleteData(objectClassName: String) -> Bool {
        return rlmMigration.deleteDataForClassName(objectClassName)
    }

    private init(_ rlmMigration: RLMMigration) {
        self.rlmMigration = rlmMigration
    }
}


// MARK: Private Helpers

internal func accessorMigrationBlock(migrationBlock: MigrationBlock) -> RLMMigrationBlock {
    return { migration, oldVersion in
        // set all accessor classes to MigrationObject
        for objectSchema in migration.oldSchema.objectSchema {
            if let objectSchema = objectSchema as? RLMObjectSchema {
                objectSchema.accessorClass = MigrationObject.self
                // isSwiftClass is always `false` for object schema generated
                // from the table, but we need to pretend it's from a swift class
                // (even if it isn't) for the accessors to be initialized correctly.
                objectSchema.isSwiftClass = true
            }
        }
        for objectSchema in migration.newSchema.objectSchema {
            if let objectSchema = objectSchema as? RLMObjectSchema {
                objectSchema.accessorClass = MigrationObject.self
            }
        }

        // run migration
        migrationBlock(migration: Migration(migration), oldSchemaVersion: oldVersion)
    }
}
