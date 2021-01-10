
/*
    -- Author:      Anthony Johnston
    -- Create date: 07/01/2021
    -- Description: stored procedure to 'Shred' the XML from Server into the various "Tac" tables	
    ***************************       CHANGE HISTORY (Reverse Chronological)      ***************************
    *
	*	
    *********************************************************************************************************/
CREATE PROCEDURE dbo.usp_XmlShred
(
	@Xml		XML	
)
AS
BEGIN

DECLARE @XmlToShred  TABLE 
(
	XmlId							INTEGER IDENTITY(1,1) NOT NULL PRIMARY KEY

	--TacFlightRecording table
	, XmlSource						NVARCHAR(50) NULL 
	, XmlRecorder					NVARCHAR(50) NULL 
	, XmlRecordingTime				NVARCHAR(50) NULL
	, XmlAuthor						NVARCHAR(50) NULL 	

	--TacMission Table
	, XmlTitle						NVARCHAR(50) NULL
	, XmlCategory					NVARCHAR(50) NULL	
	, XmlMissionTime				NVARCHAR(50) NULL
	, XmlDuration					NVARCHAR(50) NULL
	, XmlComments					NVARCHAR(200) NULL

	--TacEvents table
	, XmlTime					DECIMAL(6,2) NULL
	, XmlLongtitude				DECIMAL(10,7) NULL
	, XmlLatitude				DECIMAL(10,7) NULL
	, XmlAltitude				DECIMAL(7,2) NULL
	, XmlPrimaryObject			INTEGER	NULL
	, XmlType					NVARCHAR(30) NULL
	, XmlRegistration			NVARCHAR(20) NULL
	, XmlSquawk					INTEGER	NULL
	, XmlName					NVARCHAR(30) NULL
	, XmlPilot					NVARCHAR(30) NULL
	, XmlAction					NVARCHAR(30) NULL	
)

DECLARE @XMLD	XML
SET @XMLD = @Xml
INSERT INTO  @XmlToShred
		--TacFlightRecording table
SELECT TacviewDebriefing.FlightRecording.value('(Source)[1]', 'NVARCHAR(50)') AS [Source]
		, TacviewDebriefing.FlightRecording.value('(Recorder)[1]', 'NVARCHAR(50)') AS Recorder
		, TacviewDebriefing.FlightRecording.value('(RecordingTime)[1]', 'NVARCHAR(50)') AS RecordingTime
		, TacviewDebriefing.FlightRecording.value('(Author)[1]', 'NVARCHAR(50)') AS Author  

		--TacMission Table
		, TacviewDebriefing.FlightRecording.value('(Title)[1]', 'NVARCHAR(50)') AS Title
		, TacviewDebriefing.FlightRecording.value('(Category)[1]', 'NVARCHAR(50)') AS Category
		, TacviewDebriefing.FlightRecording.value('(MissionTime)[1]', 'NVARCHAR(50)') AS MissionTime
		, TacviewDebriefing.FlightRecording.value('(Duration)[1]', 'NVARCHAR(50)') AS Duration
		, TacviewDebriefing.FlightRecording.value('(Comments)[1]', 'NVARCHAR(50)') AS Comments

		--TacEvents table
		, TacviewDebriefing.FlightRecording.value('(Time)[1]', 'DECIMAL(6,2)') AS [Time]
		, TacviewDebriefing.FlightRecording.value('(Longtitude)[1]', 'DECIMAL(10,7)') AS Longtitude
		, TacviewDebriefing.FlightRecording.value('(Latitude)[1]', 'DECIMAL(10,7)') AS Latitude
		, TacviewDebriefing.FlightRecording.value('(Altitude)[1]', 'DECIMAL(7,2)') AS Altitude
		, TacviewDebriefing.FlightRecording.value('(PrimaryObject)[1]', 'INT') AS PrimaryObject
		, TacviewDebriefing.FlightRecording.value('(Type)[1]', 'NVARCHAR(50)') AS [Type]
		, TacviewDebriefing.FlightRecording.value('(Registration)[1]', 'NVARCHAR(50)') AS Registration
		, TacviewDebriefing.FlightRecording.value('(Squawk)[1]', 'INT') AS Squawk
		, TacviewDebriefing.FlightRecording.value('(Name)[1]', 'NVARCHAR(50)') AS [Name]
		, TacviewDebriefing.FlightRecording.value('(Pilot)[1]', 'NVARCHAR(50)') AS Pilot
		, TacviewDebriefing.FlightRecording.value('(Action)[1]', 'NVARCHAR(50)') AS [Action]
FROM @XMLD.nodes('TacviewDebriefing/FlightRecording') AS TacviewDebriefing(FlightRecording)
	
	--For Testing Purposes
	SELECT * FROM @XmlToShred
	
	--SET IDENTITY_INSERT dbo.TacFlightRecording ON
	INSERT INTO dbo.TacFlightRecording ([Source], Recorder, RecordingTime, Author)
	SELECT DISTINCT XmlSource
					, XmlRecorder
					, XmlRecordingTime
					, XmlAuthor
	FROM	@XmlToShred
	--SET IDENTITY_INSERT dbo.TacFlightRecording OFF

	--Need to insert the newly created Id from parent table TacFlightRecording as a foreign key in the rest of the tables
	--As this is not part of the XML, we have to do it this way:
	DECLARE @TacFlightRecordingId INTEGER
	SET @TacFlightRecordingId = (SELECT TacFlightRecordingId
								FROM dbo.TacFlightRecording T
								INNER JOIN @XmlToShred X ON X.XmlSource = T.[Source] AND T.Recorder = X.XmlRecorder
								WHERE T.[Source] = X.XmlSource
								AND T.Recorder = X.XmlRecorder)

	INSERT INTO dbo.TacMission (TacFlightRecordingId, Title, Category, MissionTime, Duration, Comments)
	SELECT DISTINCT		@TacFlightRecordingId
						, XmlTitle
						, XmlCategory
						, XmlMissionTime
						, XmlDuration
						, XmlComments
	FROM	@XmlToShred

	INSERT INTO dbo.TacEvents (TacFlightRecordingId, [Time], Longtitude, Latitude, Altitude, PrimaryObject, [Type], Registration
							, Squawk, [Name], Pilot, [Action])
	SELECT DISTINCT  @TacFlightRecordingId
					, XmlTime
					, XmlLongtitude
					, XmlLatitude
					, XmlAltitude
					, XmlPrimaryObject
					, XmlType
					, XmlRegistration
					, XmlSquawk	
					, XmlName
					, XmlPilot
					, XmlAction	
	FROM	@XmlToShred

END