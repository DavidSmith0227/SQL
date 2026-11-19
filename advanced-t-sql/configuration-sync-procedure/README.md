# Configuration Sync Procedure

A stored procedure that synchronizes reference data with a configuration table by identifying and inserting missing records.

## Scenario

A configuration table must contain a corresponding record for each qualifying segment maintained by a separate reference data source.

Rather than recreating configuration data, the procedure identifies source records that do not yet have a matching configuration record and inserts only the missing values.

## Concepts Demonstrated

- Stored procedures
- Common Table Expressions (CTEs)
- INNER JOIN
- LEFT OUTER JOIN
- Anti-join pattern
- INSERT...SELECT
- SET NOCOUNT ON
- Cross-schema data access

## Implementation

The procedure:

1. Identifies qualifying source segments.
2. Compares them against existing configuration records.
3. Filters the result to segments without a matching configuration.
4. Inserts only the missing records.

## Portfolio Note

This example is based on a real-world synchronization pattern. Database, schema, table, column, environment, and business-specific names have been replaced with generic equivalents.