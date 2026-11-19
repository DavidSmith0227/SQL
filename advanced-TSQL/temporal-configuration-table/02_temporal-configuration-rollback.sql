SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
SET XACT_ABORT ON;

/*
Purpose:
	Roll back the portfolio configuration-schema deployment.

Warning:
	This script permanently removes the current and historical data created by
	the matching deployment script. Run only when a full rollback is intended.
*/

BEGIN TRY
	BEGIN TRANSACTION;

	IF OBJECT_ID(N'Configuration.NotificationConfiguration', N'U') IS NOT NULL
	BEGIN
		IF EXISTS
			(
			SELECT 1
			FROM sys.tables
			WHERE object_id = OBJECT_ID(N'Configuration.NotificationConfiguration')
				AND temporal_type = 2
			)
			ALTER TABLE Configuration.NotificationConfiguration
				SET (SYSTEM_VERSIONING = OFF);

			DROP TABLE Configuration.NotificationConfiguration;
	END;

	DROP TABLE IF EXISTS Configuration.NotificationConfigurationHistory;

	IF OBJECT_ID(N'Configuration.AccountResourceConfiguration', N'U') IS NOT NULL
	BEGIN
		IF EXISTS
			(
			SELECT 1
			FROM sys.tables
			WHERE object_id = OBJECT_ID(N'Configuration.AccountResourceConfiguration')
				AND temporal_type = 2
			)
			ALTER TABLE Configuration.AccountResourceConfiguration
				SET (SYSTEM_VERSIONING = OFF);

			DROP TABLE Configuration.AccountResourceConfiguration;
	END;

	DROP TABLE IF EXISTS Configuration.AccountResourceConfigurationHistory;
	DROP TABLE IF EXISTS Configuration.ResourceRelation;
	DROP TABLE IF EXISTS Configuration.Configuration;
	DROP TABLE IF EXISTS Configuration.Resource;
	DROP TABLE IF EXISTS Configuration.ActionType;
	DROP TABLE IF EXISTS Configuration.ResourceType;
	DROP TABLE IF EXISTS Configuration.AccountSegment;

	IF SCHEMA_ID(N'Configuration') IS NOT NULL
		EXEC sys.sp_executesql N'DROP SCHEMA Configuration;';

	COMMIT TRANSACTION;
END TRY
BEGIN CATCH
	IF @@TRANCOUNT > 0
		ROLLBACK TRANSACTION;

	THROW;
END CATCH;