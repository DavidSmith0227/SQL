# SQL Server Portfolio

A collection of SQL Server and T-SQL projects demonstrating database development, performance tuning, advanced querying, schema design, and practical problem solving.

The projects range from foundational SQL assessment exercises to examples based on real-world development and performance scenarios.

> Production-derived examples have been recreated or sanitized using synthetic database, schema, table, column, customer, and business-specific names. No proprietary data is included.

## Featured Projects

### 🚀 Performance Tuning
[`advanced-TSQL/performance-tuning`](./advanced-TSQL/performance-tuning/)

A SQL Server performance-tuning case study focused on improving access to frequently queried JSON attributes.

**Demonstrates:**
- Execution-plan analysis
- JSON_VALUE
- Computed columns
- Datatype conversion
- Nonclustered indexes
- Index design and query-performance considerations

---

### 🔗 Multi-Source Reporting
[`advanced-TSQL/multi-source-reporting`](./advanced-TSQL/multi-source-reporting/)

A complex reporting query that combines communication, delivery, address-correction, and validation data from multiple sources.

**Demonstrates:**
- Common Table Expressions (CTEs)
- INNER and LEFT OUTER JOINs
- Correlated OUTER APPLY
- TOP with deterministic ORDER BY
- Optional parameters
- Date-range filtering
- Cross-database querying
- Collation handling
- Derived business logic

---

### 🕒 Temporal Configuration Schema
[`advanced-TSQL/temporal-configuration-table`](./advanced-TSQL/temporal-configuration-table/)

A configuration schema deployment with a corresponding rollback script.

**Demonstrates:**
- Relational schema design
- Primary and foreign keys
- Unique and default constraints
- Seed data
- System-versioned temporal tables
- Temporal history tables
- Transactions
- TRY/CATCH and THROW
- Deployment and rollback planning

---

### 🔄 Configuration Sync Procedure
[`advanced-TSQL/configuration-sync-procedure`](./advanced-TSQL/configuration-sync-procedure/)

A stored procedure that identifies missing configuration records and synchronizes them from a reference data source.

**Demonstrates:**
- Stored procedures
- CTEs
- Anti-join patterns
- INSERT...SELECT
- Cross-schema queries
- Set-based synchronization

---

### 📝 SQL Interview Assessment
[`interview-assessment`](./interview-assessment/)

A self-contained SQL assessment originally designed to evaluate foundational SQL development skills.

Includes:
- Database schema
- Sample data
- Assessment questions
- Complete solutions
- Reviewer guide

The project demonstrates practical knowledge of relational design, DDL, joins, filtering, aggregation, and general T-SQL problem solving.

## Additional Resources

### SQL Snippets
[`_snippets`](./_snippets/)

Reusable SQL Server/SSMS snippets for common development patterns, including:

- CTEs
- Index creation
- ROW_NUMBER
- Temporary bulk-load patterns

## Repository Structure

```text
SQL/
├── advanced-TSQL/
│   ├── configuration-sync-procedure/
│   ├── multi-source-reporting/
│   ├── performance-tuning/
│   └── temporal-configuration-table/
│
├── interview-assessment/
│
├── _snippets/
│
└── README.md