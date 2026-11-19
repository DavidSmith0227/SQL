# Advanced T-SQL

A collection of practical SQL Server examples based on real-world database development scenarios.

All examples have been sanitized or recreated with synthetic object names and data to remove proprietary information.

## Projects

### Performance Tuning
A SQL Server performance-tuning example demonstrating the use of computed columns, JSON_VALUE, datatype conversion, and targeted nonclustered indexes to improve access to frequently queried values.

[View Performance Tuning](./performance_tuning/)

### Multi-Source Reporting
A reporting query combining data from multiple sources using a CTE, INNER and LEFT OUTER JOINs, correlated OUTER APPLY operations, date-range filtering, and derived business logic.

[View Multi-Source Reporting](./multi-source-reporting/)

### Temporal Configuration
A schema deployment and rollback example demonstrating relational design, primary and foreign keys, constraints, seed data, transactions, error handling, and SQL Server system-versioned temporal tables.

[View Temporal Configuration](./temporal-configuration-table/)

### Configuration Sync Procedure
A stored procedure that identifies missing configuration records and inserts them from a reference data source using a CTE and anti-join pattern.

[View Configuration Sync Procedure](./configuration-sync-procedure/)

## Technologies

- Microsoft SQL Server
- T-SQL
- Common Table Expressions
- OUTER APPLY
- JSON_VALUE
- Computed Columns
- Nonclustered Indexes
- Stored Procedures
- System-Versioned Temporal Tables
- Transactions