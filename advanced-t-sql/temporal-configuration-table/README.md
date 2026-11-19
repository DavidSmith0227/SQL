# Temporal Configuration Schema

A SQL Server schema deployment demonstrating relational configuration design and system-versioned temporal tables.

The project includes both the deployment and its corresponding rollback.

## Files

### 01_temporal-configuration-deploy.sql

Creates the configuration schema and related database objects.

Demonstrates:

- Schema creation
- Primary keys
- Foreign keys
- Unique constraints
- Default constraints
- IDENTITY columns
- Seed data
- System-versioned temporal tables
- Explicit history tables
- Transactions
- TRY/CATCH error handling
- XACT_ABORT

### 02_temporal-configuration-rollback.sql

Provides the corresponding rollback path.

The script:

1. Detects temporal tables.
2. Disables SYSTEM_VERSIONING.
3. Removes current tables.
4. Removes temporal history tables.
5. Drops dependent objects in dependency-safe order.
6. Removes the configuration schema.

## Why Temporal Tables?

Configuration values can change over time while historical values may still be important for troubleshooting, auditing, or understanding previous application behavior.

SQL Server system-versioned temporal tables provide a built-in mechanism for maintaining previous row versions without requiring application code to manually maintain a separate audit table.

## Deployment Design

The deployment is wrapped in an explicit transaction with TRY/CATCH handling.

If an error occurs during deployment:

1. The transaction is rolled back.
2. THROW returns the original SQL Server error to the caller.

A separate rollback script is included to demonstrate how the complete deployment can be deliberately reversed after a successful deployment.

## Portfolio Note

This project is a synthetic recreation of a real-world database deployment pattern. All organization, application, infrastructure, customer, and business-specific identifiers have been removed.