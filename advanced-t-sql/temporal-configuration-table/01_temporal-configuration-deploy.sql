SET ANSI_NULLS ON;
SET ANSI_PADDING ON;
SET ANSI_WARNINGS ON;
SET ARITHABORT ON;
SET CONCAT_NULL_YIELDS_NULL ON;
SET QUOTED_IDENTIFIER ON;
SET XACT_ABORT ON;

/*
Purpose:
	Create a portfolio-safe configuration schema that demonstrates relational
	design, named constraints, seed data, and system-versioned temporal tables.

Portfolio Note:
	This is a synthetic example based on a real-world schema deployment pattern.
	All organization, server, database, customer, work-item, and business-specific
	identifiers have been replaced. No production data is included.
*/

BEGIN TRY
	BEGIN TRANSACTION;

	IF SCHEMA_ID(N'Configuration') IS NULL
		EXEC sys.sp_executesql N'CREATE SCHEMA Configuration AUTHORIZATION dbo;';

	CREATE TABLE Configuration.AccountSegment
		(
		accountSegmentId INT IDENTITY(1,1) NOT NULL,
		accountSegmentName VARCHAR(200) NOT NULL,
		accountSegmentGuid UNIQUEIDENTIFIER NOT NULL,
		isDefaultSegment BIT NOT NULL CONSTRAINT DF_AccountSegment_isDefaultSegment DEFAULT 0,
		CONSTRAINT PK_AccountSegment PRIMARY KEY (accountSegmentId),
		CONSTRAINT UQ_AccountSegment_accountSegmentGuid UNIQUE (accountSegmentGuid)
		);

	CREATE TABLE Configuration.ResourceType
		(
		resourceTypeId INT IDENTITY(1,1) NOT NULL,
		resourceTypeName VARCHAR(200) NOT NULL,
		CONSTRAINT PK_ResourceType PRIMARY KEY (resourceTypeId),
		CONSTRAINT UQ_ResourceType_resourceTypeName UNIQUE (resourceTypeName)
		);

	CREATE TABLE Configuration.ActionType
		(
		actionTypeId INT IDENTITY(1,1) NOT NULL,
		actionTypeName VARCHAR(200) NOT NULL,
		CONSTRAINT PK_ActionType PRIMARY KEY (actionTypeId),
		CONSTRAINT UQ_ActionType_actionTypeName UNIQUE (actionTypeName)
		);

	CREATE TABLE Configuration.Resource
		(
		resourceId INT IDENTITY(1,1) NOT NULL,
		resourceName VARCHAR(200) NOT NULL,
		resourceTypeId INT NULL,
		actionTypeId INT NULL,
		CONSTRAINT PK_Resource PRIMARY KEY (resourceId),
		CONSTRAINT UQ_Resource_resourceName UNIQUE (resourceName),
		CONSTRAINT FK_Resource_ResourceType FOREIGN KEY (resourceTypeId)
			REFERENCES Configuration.ResourceType (resourceTypeId),
		CONSTRAINT FK_Resource_ActionType FOREIGN KEY (actionTypeId)
			REFERENCES Configuration.ActionType (actionTypeId)
		);

	SET IDENTITY_INSERT Configuration.Resource ON;

	INSERT INTO Configuration.Resource (resourceId, resourceName)
	VALUES
		(1, 'Standard Resource'),
		(2, 'Custom Resource');

	SET IDENTITY_INSERT Configuration.Resource OFF;


	CREATE TABLE Configuration.Configuration
		(
		configurationId INT IDENTITY(1,1) NOT NULL,
		implementationCode CHAR(15) NULL,
		accountSegmentGuid UNIQUEIDENTIFIER NOT NULL,
		CONSTRAINT PK_Configuration PRIMARY KEY (configurationId),
		CONSTRAINT UQ_Configuration_accountSegmentGuid UNIQUE (accountSegmentGuid),
		CONSTRAINT FK_Configuration_AccountSegment FOREIGN KEY (accountSegmentGuid)
			REFERENCES Configuration.AccountSegment (accountSegmentGuid)
		);

	CREATE TABLE Configuration.AccountResourceConfiguration
		(
		configurationId INT NOT NULL,
		introductoryResourceId INT NULL,
		initialResourceId INT NULL,
		ongoingResourceId INT NULL,
		followUpResourceId INT NULL,
		effectiveDate DATE NULL,
		enableShortTermFollowUp BIT NOT NULL
			CONSTRAINT DF_AccountResourceConfiguration_enableShortTermFollowUp DEFAULT 0,
		enableLongTermFollowUp BIT NOT NULL
			CONSTRAINT DF_AccountResourceConfiguration_enableLongTermFollowUp DEFAULT 0,
		validFrom DATETIME2(0) GENERATED ALWAYS AS ROW START HIDDEN NOT NULL
			CONSTRAINT DF_AccountResourceConfiguration_validFrom DEFAULT SYSUTCDATETIME(),
		validTo DATETIME2(0) GENERATED ALWAYS AS ROW END HIDDEN NOT NULL
			CONSTRAINT DF_AccountResourceConfiguration_validTo
			DEFAULT CONVERT(DATETIME2(0), '9999-12-31 23:59:59'),
		PERIOD FOR SYSTEM_TIME (validFrom, validTo),
		CONSTRAINT PK_AccountResourceConfiguration PRIMARY KEY (configurationId),
		CONSTRAINT FK_AccountResourceConfiguration_Configuration FOREIGN KEY (configurationId)
			REFERENCES Configuration.Configuration (configurationId),
		CONSTRAINT FK_AccountResourceConfiguration_IntroductoryResource FOREIGN KEY (introductoryResourceId)
			REFERENCES Configuration.Resource (resourceId),
		CONSTRAINT FK_AccountResourceConfiguration_InitialResource FOREIGN KEY (initialResourceId)
			REFERENCES Configuration.Resource (resourceId),
		CONSTRAINT FK_AccountResourceConfiguration_OngoingResource FOREIGN KEY (ongoingResourceId)
			REFERENCES Configuration.Resource (resourceId),
		CONSTRAINT FK_AccountResourceConfiguration_FollowUpResource FOREIGN KEY (followUpResourceId)
			REFERENCES Configuration.Resource (resourceId)
		)
	WITH
		(
		SYSTEM_VERSIONING = ON
			(
			HISTORY_TABLE = Configuration.AccountResourceConfigurationHistory,
			DATA_CONSISTENCY_CHECK = ON
			)
		);

	CREATE TABLE Configuration.NotificationConfiguration
		(
		configurationId INT NOT NULL,
		disableWelcomeNotification BIT NOT NULL
			CONSTRAINT DF_NotificationConfiguration_disableWelcomeNotification DEFAULT 0,
		disableReminderNotification BIT NOT NULL
			CONSTRAINT DF_NotificationConfiguration_disableReminderNotification DEFAULT 0,
		disableFollowUpNotification BIT NOT NULL
			CONSTRAINT DF_NotificationConfiguration_disableFollowUpNotification DEFAULT 0,
		validFrom DATETIME2(0) GENERATED ALWAYS AS ROW START HIDDEN NOT NULL
			CONSTRAINT DF_NotificationConfiguration_validFrom DEFAULT SYSUTCDATETIME(),
		validTo DATETIME2(0) GENERATED ALWAYS AS ROW END HIDDEN NOT NULL
			CONSTRAINT DF_NotificationConfiguration_validTo
			DEFAULT CONVERT(DATETIME2(0), '9999-12-31 23:59:59'),
		PERIOD FOR SYSTEM_TIME (validFrom, validTo),
		CONSTRAINT PK_NotificationConfiguration PRIMARY KEY (configurationId),
		CONSTRAINT FK_NotificationConfiguration_Configuration FOREIGN KEY (configurationId)
			REFERENCES Configuration.Configuration (configurationId)
		)
	WITH
		(
		SYSTEM_VERSIONING = ON
			(
			HISTORY_TABLE = Configuration.NotificationConfigurationHistory,
			DATA_CONSISTENCY_CHECK = ON
			)
		);

	CREATE TABLE Configuration.ResourceRelation
		(
		resourceRelationId INT IDENTITY(1,1) NOT NULL,
		relationName VARCHAR(100) NOT NULL,
		CONSTRAINT PK_ResourceRelation PRIMARY KEY (resourceRelationId),
		CONSTRAINT UQ_ResourceRelation_relationName UNIQUE (relationName)
		);

	COMMIT TRANSACTION;
END TRY
BEGIN CATCH
	IF @@TRANCOUNT > 0
		ROLLBACK TRANSACTION;

	THROW;
END CATCH;