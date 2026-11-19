# Multi-Source Reporting Query

A T-SQL reporting example that consolidates communication, delivery, address-correction, and validation information from multiple data sources.

## Scenario

Related information is maintained by several independent systems. The reporting requirement is to locate the most relevant supplemental record for each communication and derive a consolidated delivery result.

## Concepts Demonstrated

- Common Table Expressions (CTEs)
- INNER JOIN and LEFT OUTER JOIN
- Correlated OUTER APPLY
- TOP with deterministic ORDER BY
- Variable declarations
- Optional parameters
- Date-range filtering
- Cross-database queries
- Collation handling
- CASE expressions
- Derived business logic

## Query Design

The query first establishes the set of communications that meet the requested account and date criteria.

Correlated OUTER APPLY operations then locate the most relevant:

- Physical-delivery exception
- Address-correction result
- Email-validation result

Each lookup uses TOP (1) with deterministic ordering to prevent multiple supplemental records from multiplying rows in the final result.

A final CASE expression combines those results into a single delivery-status value.

## Performance Considerations

Date filtering uses range predicates rather than applying functions directly to primary date-filter columns where practical.

The query also uses prefix matching rather than a leading wildcard for the optional account-name search.

## Portfolio Note

This query is based on a real-world reporting scenario. Organization, infrastructure, customer, vendor, and business-specific identifiers have been replaced with synthetic equivalents.

The referenced databases and objects are intentionally synthetic, so this file represents the query design rather than a standalone executable project.