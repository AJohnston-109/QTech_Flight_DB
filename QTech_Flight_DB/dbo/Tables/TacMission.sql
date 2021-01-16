CREATE TABLE dbo.TacMission
(
	TacMissionId				INTEGER	 IDENTITY(1,1)	NOT NULL
	, TacFlightRecordingId		INTEGER					NOT NULL
	, Title						NVARCHAR(50)				NULL
	, Category					NVARCHAR(50)				NULL
	, MissionTime				NVARCHAR(50)				NULL --TODO, convert to datetime format via datetimeformat function xml giving me wierd format. 
	, Duration					DECIMAL(6,2)				NULL
	, Comments					NVARCHAR(200)				NULL
	, DateInserted				DATETIME					NULL CONSTRAINT DF_TacMission_DateInserted DEFAULT GETDATE()
	, CONSTRAINT PK_TacMission_TacMissionId PRIMARY KEY (TacMissionId)
)
