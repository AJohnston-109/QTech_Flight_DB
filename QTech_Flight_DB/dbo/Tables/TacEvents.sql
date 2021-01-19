
CREATE TABLE dbo.TacEvents
(
	TacEventsId					INTEGER	 IDENTITY(1,1)	NOT NULL 
	, TacFlightRecordingId		INTEGER					NOT NULL
	, PilotIdentifier			UNIQUEIDENTIFIER			NULL
	, [Time]					DECIMAL(6,2)			NULL
	, Longtitude				DECIMAL(10,7)			NULL
	, Latitude					DECIMAL(10,7)			NULL
	, Altitude					DECIMAL(7,2)			NULL
	, PrimaryObject				INTEGER					NULL
	, [Type]					NVARCHAR(30)			NULL
	, Registration				NVARCHAR(20)			NULL
	, Squawk					INTEGER					NULL
	, [Name]					NVARCHAR(30)			NULL
	, Pilot						NVARCHAR(30)			NULL
	, [Action]					NVARCHAR(30)			NULL
	, DateInserted				DATETIME				NULL CONSTRAINT DF_TacEvents_DateInserted DEFAULT GETDATE()
	, CONSTRAINT PK_TacEvents_TacEventsId PRIMARY KEY (TacEventsId)
)
