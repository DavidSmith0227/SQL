SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO

/*
Purpose:
	Identify active segments that do not yet have a corresponding
	configuration record and add the missing records.

Portfolio Note:
	This procedure is based on a real-world synchronization scenario.
	Database, schema, table, column, environment, and business-specific
	names have been replaced with generic equivalents.
*/

CREATE OR ALTER PROCEDURE Configuration.SyncMissingSegmentConfigurations
AS
	BEGIN
		SET NOCOUNT ON;

		WITH SegmentsToAdd AS (
			SELECT
				Segment.segmentName,
				Segment.segmentGuid
			FROM ReferenceData.dbo.Segment
				INNER JOIN ReferenceData.dbo.Program
					ON Program.programId = Segment.programId
					AND Program.programTypeId IN (1, 2)
				LEFT OUTER JOIN Configuration.SegmentConfiguration
					ON SegmentConfiguration.segmentGuid = Segment.segmentGuid
			WHERE
				SegmentConfiguration.segmentGuid IS NULL
			)

		INSERT INTO Configuration.SegmentConfiguration
			(
			segmentName,
			segmentGuid
			)
		SELECT
			SegmentsToAdd.segmentName,
			SegmentsToAdd.segmentGuid
		FROM SegmentsToAdd;
	END;
GO