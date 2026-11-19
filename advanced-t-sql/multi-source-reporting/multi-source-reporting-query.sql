SET ANSI_NULL_DFLT_ON ON;
SET ANSI_NULLS ON;
SET ANSI_PADDING ON;
SET ANSI_WARNINGS ON;
SET ARITHABORT ON;
SET CONCAT_NULL_YIELDS_NULL ON;
SET QUOTED_IDENTIFIER ON;
SET XACT_ABORT ON;
SET NOEXEC OFF;

/*
Purpose:
	Combine outbound communication records with physical-delivery exceptions,
	address-correction results, and email-validation results.

Concepts Demonstrated:
	- Variable declarations
	- Common table expressions (CTEs)
	- INNER JOIN and LEFT OUTER JOIN
	- Correlated OUTER APPLY
	- TOP with deterministic ORDER BY
	- Optional search parameters
	- Index-friendly date-range predicates
	- Cross-database querying
	- Collation handling
	- Derived delivery-status calculations

Portfolio Note:
	This query is based on a real-world reporting scenario. Database, schema,
	table, column, customer, vendor, and business-specific names have been
	replaced with generic equivalents. No production data is included.

Assumptions:
	- ScheduledDate represents the intended communication date.
	- ImportDate is used when ScheduledDate is unavailable.
	- Each OUTER APPLY returns at most one supplemental result.
	- An address-correction match indicates unsuccessful delivery only when
	  no replacement address was provided.
*/

DECLARE 
	@SearchYear INT = 2026,
	@AccountName VARCHAR(250) = 'Example Account',
	@LastPullDate DATE = NULL
	;

WITH CommunicationScope AS (
	SELECT
		CommunicationRecord.EntityId,
		CommunicationRecord.GivenName,
		CommunicationRecord.FamilyName,
		CommunicationRecord.CampaignId,
		CommunicationRecord.DocumentName,
		CommunicationRecord.AccountName,
		CommunicationRecord.ScheduledDate,
		COALESCE(CommunicationRecord.ScheduledDate, CAST(CommunicationFile.ImportDate AS DATE)) AS CommunicationDate,
		CommunicationFile.SourceFileName,
		CommunicationFile.ImportDate,
		MessageTemplate.ReportingCategory,
		MessageTemplate.ReportingDescription
	FROM PortfolioMessaging.messaging.CommunicationRecord
		INNER JOIN PortfolioMessaging.messaging.CommunicationFile
			ON CommunicationFile.CommunicationFileId = CommunicationRecord.CommunicationFileId
		LEFT OUTER JOIN PortfolioReference.dbo.MessageTemplate
			ON MessageTemplate.TemplateName = CommunicationRecord.DocumentName
	WHERE
		(
			(
				CommunicationRecord.ScheduledDate IS NOT NULL
				AND CommunicationRecord.ScheduledDate >= DATEFROMPARTS(@SearchYear, 1, 1)
				AND CommunicationRecord.ScheduledDate < DATEFROMPARTS(@SearchYear + 1, 1, 1)
			)
			OR
			(
				CommunicationRecord.ScheduledDate IS NULL
				AND CommunicationFile.ImportDate >= DATEFROMPARTS(@SearchYear, 1, 1)
				AND CommunicationFile.ImportDate < DATEFROMPARTS(@SearchYear + 1, 1, 1)
			)
		)
		AND (
			NULLIF(@AccountName, '') IS NULL
			OR CommunicationRecord.AccountName LIKE @AccountName + '%'
		)
		AND (
			@LastPullDate IS NULL
			OR CommunicationFile.ImportDate >= @LastPullDate
		)
	)

SELECT
	CommunicationScope.EntityId,
	CommunicationScope.GivenName,
	CommunicationScope.FamilyName,
	CommunicationScope.CampaignId,
	CommunicationScope.DocumentName,
	CommunicationScope.AccountName,
	CommunicationScope.ScheduledDate,
	CommunicationScope.CommunicationDate,
	CommunicationScope.SourceFileName,
	CommunicationScope.ImportDate AS CommunicationImportDate,
	CommunicationScope.ReportingCategory,
	CommunicationScope.ReportingDescription,

	DeliveryException.ExceptionDescription,
	DeliveryException.WasDelivered AS DeliveryExceptionWasDelivered,
	DeliveryException.ImportDate AS DeliveryExceptionImportDate,

	AddressCorrection.MoveEffectiveDate,
	AddressCorrection.MatchDescription AS AddressMatchDescription,
	AddressCorrection.NewAddressProvided,
	AddressCorrection.ImportDate AS AddressCorrectionImportDate,

	EmailValidation.EmailAddress,
	EmailValidation.IsValid AS EmailIsValid,
	EmailValidation.ValidationDescription AS EmailValidationDescription,
	EmailValidation.ValidationDateTime,

	CASE
		WHEN DeliveryException.WasDelivered = 0
			THEN CAST(0 AS BIT)
		WHEN AddressCorrection.MatchDescription IS NOT NULL
			AND AddressCorrection.NewAddressProvided = 0
			THEN CAST(0 AS BIT)
		WHEN EmailValidation.IsValid = 0
			THEN CAST(0 AS BIT)
		ELSE CAST(1 AS BIT)
	END AS WasSuccessfullyDelivered

FROM CommunicationScope
	/* Physical Delivery Exception */
	OUTER APPLY (
			SELECT TOP 1
				ExceptionCode.ExceptionDescription,
				ExceptionCode.WasDelivered,
				DeliveryException.ImportDate
			FROM PortfolioDelivery.dbo.DeliveryException
				INNER JOIN PortfolioDelivery.dbo.ExceptionCode
					ON ExceptionCode.ExceptionCode = DeliveryException.ExceptionCode
			WHERE
				DeliveryException.EntityId = CommunicationScope.EntityId
				AND DeliveryException.DocumentName = CommunicationScope.DocumentName COLLATE Latin1_General_100_CI_AS_KS_WS_SC
				AND DeliveryException.ImportDate >= DATEADD(WEEK, -3, CommunicationScope.CommunicationDate)
				AND DeliveryException.ImportDate < DATEADD(DAY, 3, CommunicationScope.CommunicationDate)
			ORDER BY
				DeliveryException.ImportDate ASC,
				DeliveryException.DeliveryExceptionId ASC
			) AS DeliveryException
	/* Address Correction */
	OUTER APPLY (
			SELECT TOP 1
				AddressRecord.MoveEffectiveDate,
				MatchFlag.MatchDescription,
				MatchFlag.NewAddressProvided,
				AddressRecord.ImportDate
			FROM PortfolioDelivery.address.AddressFile
				INNER JOIN PortfolioDelivery.address.AddressRecord
					ON AddressRecord.AddressFileId = AddressFile.AddressFileId
				INNER JOIN PortfolioDelivery.address.MatchFlag
					ON MatchFlag.MatchFlagCode = AddressRecord.MatchFlagCode
			WHERE
				AddressRecord.EntityId = CommunicationScope.EntityId
				AND AddressRecord.ImportDate >= DATEADD(DAY, -2, CommunicationScope.CommunicationDate)
				AND AddressRecord.ImportDate < DATEADD(DAY, 3, CommunicationScope.CommunicationDate)
			ORDER BY
				AddressRecord.ImportDate ASC,
				AddressRecord.AddressRecordId ASC
			) AS AddressCorrection
	/* Email Validation */
	OUTER APPLY (
			SELECT TOP 1
				EmailResult.EmailAddress,
				ValidationCode.IsValid,
				ValidationCode.ValidationDescription,
				COALESCE(EmailResult.UpdatedDateTime, EmailResult.CreatedDateTime) AS ValidationDateTime
			FROM PortfolioDelivery.validation.EmailResult
				INNER JOIN PortfolioDelivery.validation.ValidationCode
					ON ValidationCode.ValidationCodeId = EmailResult.ValidationCodeId
			WHERE
				ValidationCode.IsValid = 0
				AND EmailResult.EntityId = CommunicationScope.EntityId
				AND COALESCE(EmailResult.UpdatedDateTime, EmailResult.CreatedDateTime) >= DATEADD(DAY, -2, CommunicationScope.CommunicationDate)
				AND COALESCE(EmailResult.UpdatedDateTime, EmailResult.CreatedDateTime) < DATEADD(DAY, 3, CommunicationScope.CommunicationDate)
			ORDER BY
				COALESCE(EmailResult.UpdatedDateTime, EmailResult.CreatedDateTime) DESC,
				EmailResult.EmailResultId DESC
			) AS EmailValidation
ORDER BY
	CommunicationScope.CommunicationDate DESC,
	CommunicationScope.EntityId,
	CommunicationScope.CampaignId;