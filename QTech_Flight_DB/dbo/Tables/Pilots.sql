CREATE TABLE dbo.Pilots
(
	PilotId				INTEGER IDENTITY(1,1)		NOT NULL
	, PilotIdentifier	UNIQUEIDENTIFIER			NULL CONSTRAINT DF_Pilots_PilotIdentifier DEFAULT NEWID()
	, Pilot				NVARCHAR(50)				NULL
	, DateInserted		DATETIME					NULL CONSTRAINT DF_Pilots_DateInserted DEFAULT GETDATE()
	, CONSTRAINT PK_Pilots_PilotId PRIMARY KEY (PilotId)
	
)
