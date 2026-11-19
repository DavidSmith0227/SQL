SET NOEXEC OFF;
SET ANSI_NULL_DFLT_ON ON;
SET ANSI_NULLS ON;
SET ANSI_PADDING ON;
SET ANSI_WARNINGS ON;
SET ARITHABORT ON;
SET CONCAT_NULL_YIELDS_NULL ON;
SET QUOTED_IDENTIFIER ON;
SET XACT_ABORT ON;


/*USE ?;*/

/******************************************************************************
Object:      [dbo].[entityDocument]
Description: Recreate the [documentName] and [entityName] computed columns as
             VARCHAR(300) instead of VARCHAR(MAX).
			 enabling categoryId as a column.
			 add nonclustered indexes to improve performance.
Notes:
    - Columns remain intentionally non-persisted computed columns
    - Values longer than 300 characters are intentionally truncated.
    - The underlying JSON stored in [documentMetadataJSON] is not modified.
    - Any indexes or schema-bound objects dependent on these columns must be
      removed before this script and recreated afterward.

******************************************************************************/

GO
    ALTER TABLE [dbo].[entityDocument]
        DROP COLUMN IF EXISTS
            [documentName],
            [entityName],
			[processDate],
			[categoryId]
			;

    ALTER TABLE [dbo].[entityDocument]
        ADD
            [documentName] AS
				TRIM((CONVERT(
						VARCHAR(300),
						LEFT(JSON_VALUE([documentMetadataJSON], '$.documentname'),300)
						))
				) PERSISTED,
            [entityName] AS
				TRIM((CONVERT(
						VARCHAR(300),
						LEFT(JSON_VALUE([documentMetadataJSON], '$.entityname'),300)
						))
				) PERSISTED,
				[processDate] AS
				(
					CASE
						WHEN ISJSON([documentMetadataJSON]) = 1
						THEN
							COALESCE
							(
								-- ISO format: yyyy-mm-dd
								TRY_CONVERT
								(
									DATE,
									JSON_VALUE([documentMetadataJSON], '$.processDate'),
									126
								),

								-- US format: mm/dd/yyyy
								TRY_CONVERT
								(
									DATE,
									JSON_VALUE([documentMetadataJSON], '$.processDate'),
									101
								),

								-- Unix epoch milliseconds
								CASE
									WHEN TRY_CONVERT
										 (
											 BIGINT,
											 JSON_VALUE([documentMetadataJSON], '$.processDate')
										 ) IS NOT NULL
									THEN DATEADD
										 (
											 DAY,
											 TRY_CONVERT
											 (
												 BIGINT,
												 JSON_VALUE([documentMetadataJSON], '$.processDate')
											 ) / 86400000,
											 CONVERT(date, '19700101', 112)
										 )
								END
							)
					END
				) PERSISTED,
			[categoryId] AS TRY_CONVERT(INT, JSON_VALUE([documentMetadataJSON], '$.categoryId')) PERSISTED
			;
GO


/* Create separate nonclustered indexes for targeted lookups. */
/* ================================================================= */
	DROP INDEX IF EXISTS [IX_entityDocument_entityId] ON [dbo].[entityDocument]
	GO

	CREATE NONCLUSTERED INDEX [IX_entityDocument_entityId] ON [dbo].[entityDocument]
	(
	 [entityId] ASC
	)
	INCLUDE([documentId],[documentMetadataJSON],[processDate]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
	GO


/* ================================================================= */
	DROP INDEX IF EXISTS [IX_entityDocument_entityName] ON [dbo].[entityDocument]
	GO

	CREATE NONCLUSTERED INDEX [IX_entityDocument_entityName]
	ON [dbo].[entityDocument] ([entityName] ASC);

	GO

/* ================================================================= */
	DROP INDEX IF EXISTS [IX_entityDocument_processDate] ON [dbo].[entityDocument]
	GO

	CREATE NONCLUSTERED INDEX [IX_entityDocument_processDate]
	ON [dbo].[entityDocument] ([processDate])
		INCLUDE([categoryId])
	GO



