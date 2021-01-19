CREATE TABLE dbo.TacFlightRecording
(
	TacFlightRecordingId		INTEGER	 IDENTITY(1,1)	NOT NULL 
	, PilotIdentifier			UNIQUEIDENTIFIER			NULL
	, [Source]					NVARCHAR(50)				NULL
	, Recorder					NVARCHAR(50)				NULL
	, RecordingTime				NVARCHAR(50)				NULL --not datetime for now as is in a weird format that I will have to dataparse
	, Author					NVARCHAR(50)				NULL
	, DateInserted				DATETIME					NULL CONSTRAINT DF_TacFlightRecording_DateInserted DEFAULT GETDATE()
	, CONSTRAINT PK_TacFlightRecording_TacFlightRecordingId PRIMARY KEY (TacFlightRecordingId)

)
