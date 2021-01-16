CREATE TABLE dbo.TacviewData
(
	TacviewDataId 				INTEGER IDENTITY(1,1)	NOT NULL
	, PilotIdentifier			UNIQUEIDENTIFIER		NULL
	, ISOtime					DATETIME				NULL
	, Unixtime					INTEGER					NULL
	, Longitude					DECIMAL(10,7)			NULL
	, Latitude					DECIMAL(10,7)			NULL
	, Altitude					DECIMAL(7,2)			NULL
	, Roll						DECIMAL(4,1)			NULL
	, Pitch						DECIMAL(4,1)			NULL
	, Yaw						DECIMAL(4,1)			NULL
	, Throttle					DECIMAL(3,2)			NULL
	, AircraftName				NVARCHAR(50)			NULL
	--, Pilot [AJ] Normalisation - Don't duplicate data unless it's a foreign key
	, Registration				NVARCHAR(10)			NULL
	, ASL						DECIMAL(16,8)			NULL
	, AGL						DECIMAL(16,8)			NULL
	, AOA						DECIMAL(16,8)			NULL
	, G							DECIMAL(16,15)			NULL
	, LatG						DECIMAL(18,17)			NULL
	, LonG						DECIMAL(18,17)			NULL
	, Ek						DECIMAL(16,13)			NULL
	, Ep						DECIMAL(16,13)			NULL
	, DateInserted				DATETIME				NULL CONSTRAINT DF_TacviewData_DateInserted DEFAULT GETDATE()
	, CONSTRAINT PK_TacviewData_TacviewDataId PRIMARY KEY (TacviewDataId)
)
