/*
    -- Author:      Anthony Johnston
    -- Create date: 31/12/2020
    -- Description: stored procedure to INSERT / UPDATE Flight Data into PARENT base table
    ***************************       CHANGE HISTORY (Reverse Chronological)      ***************************
    *
	*	[AJ] 16/01/2021 -	Added TRANSACTIONS / TRANSACTION save points
    *********************************************************************************************************/

CREATE PROCEDURE dbo.usp_MergeFlightData
(
	@FlightDataId			INTEGER = NULL
	, @ScenarioId			INTEGER
	, @UserIdentifier		UNIQUEIDENTIFIER
	, @Start_Timestamp		DECIMAL(8,4)	=	NULL 
	, @Duration				DECIMAL(5,1)	=	NULL 
	, @Start_Frame_Index	INTEGER			=	NULL 
	, @End_Frame_Index		INTEGER			=	NULL 
	, @Norm_Pos_X			DECIMAL(16,15)	=	NULL 
	, @Norm_Pos_Y			DECIMAL(16,15)	=	NULL 
	, @Dispersion			DECIMAL(16,15)	=	NULL 
	, @Confidence			DECIMAL(6,5)	=	NULL 
	--, @Method				NVARCHAR(5)		=	NULL -- not required as default in place - always 'Pupil'
	, @Gaze_Point_3d_X		DECIMAl(15,12)	=	NULL 
	, @Gaze_Point_3d_Y		DECIMAL(15,12)	=	NULL 
	, @Gaze_Point_3d_Z		DECIMAL(15,12)	=	NULL 
	--Nested SP usp_MergeTacviewData
	, @TacviewDataId 			INTEGER = NULL
	, @PilotIdentifier			UNIQUEIDENTIFIER	=	NULL
	, @Pilot					NVARCHAR(50)		=	NULL	
	, @ISOtime					DATETIME			=	NULL
	, @Unixtime					INTEGER				=	NULL
	, @Longitude				DECIMAL(10,7)		=	NULL
	, @Latitude					DECIMAL(10,7)		=	NULL
	, @Altitude					DECIMAL(7,2)		=	NULL
	, @Roll						DECIMAL(4,1)		=	NULL
	, @Pitch					DECIMAL(4,1)		=	NULL
	, @Yaw						DECIMAL(4,1)		=	NULL
	, @Throttle					DECIMAL(3,2)		=	NULL
	, @AircraftName				NVARCHAR(50)		=	NULL
	, @Registration				NVARCHAR(10)		=	NULL
	, @ASL						DECIMAL(16,8)		=	NULL
	, @AGL						DECIMAL(16,8)		=	NULL
	, @AOA						DECIMAL(16,8)		=	NULL
	, @G						DECIMAL(16,15)		=	NULL
	, @LatG						DECIMAL(18,17)		=	NULL
	, @LonG						DECIMAL(18,17)		=	NULL
	, @Ek						DECIMAL(16,13)		=	NULL
	, @Ep						DECIMAL(16,13)		=	NULL
)
AS
BEGIN

SET NOCOUNT ON
	/*DECLARE Variables*/
	DECLARE @err_message NVARCHAR(250)
	DECLARE @error INTEGER
	DECLARE @return INTEGER
	DECLARE @UserName	NVARCHAR(100)
	DECLARE @TranCount	BIT = 0
	--DECLARE @PilotIdentifier	UNIQUEIDENTIFIER	=	NULL

BEGIN TRY
IF @@TRANCOUNT = 0
BEGIN
	BEGIN TRANSACTION
	SET @TranCount = 1
END
ELSE SAVE TRANSACTION usp_MergeFlightDataTran

	IF @PilotIdentifier IS NULL
	BEGIN
		SET @PilotIdentifier = (SELECT MAX(PilotIdentifier) 
								FROM dbo.TacviewData
								WHERE ISOtime = @ISOtime
								AND Unixtime = @Unixtime)
	END
	IF NOT EXISTS (SELECT * FROM dbo.Pilots
					WHERE Pilot = @Pilot)
	BEGIN
		INSERT INTO dbo.Pilots		(PilotIdentifier
									, Pilot)
		SELECT						@PilotIdentifier
									, @Pilot
	END
	SET @UserName = (SELECT MAX(UserName)
					FROM dbo.Users 
					WHERE UserIdentifier = @UserIdentifier)
	IF (@UserName IS NULL OR @UserName = '')
	BEGIN		
		SET @error = -1
		SET @err_message = N'No matching user in User Table. Quitting as we cannot proceed';
        EXEC usp_GetErrorInfo @error = @error, @Procedure = 'usp_MergeFlightData', @err_message = @err_message;
		SELECT @return AS ReturnCode, @err_message AS errMessage;
		RETURN;		
	END;
	
	IF @FlightDataId IS NOT NULL --This is an UPDATE -- TODO - should the INSERT / UPDATE parameter be The Primary Key FlightDataId or UserIdentifier??
	BEGIN
		IF EXISTS (SELECT 1 
					FROM dbo.FlightData 
					WHERE FlightDataId = @FlightDataId)
		BEGIN
			SET			@return = @FlightDataId
			UPDATE F
			SET		UserIdentifier = @UserIdentifier
					, Start_Timestamp = @Start_Timestamp
					, Duration = @Duration
					, Start_Frame_Index = @Start_Frame_Index
					, End_Frame_Index = @End_Frame_Index
					, Norm_Pos_X = @Norm_Pos_X
					, Norm_Pos_Y = @Norm_Pos_Y
					, Dispersion = @Dispersion
					, Confidence = @Confidence					
					, Gaze_Point_3d_X = @Gaze_Point_3d_X
					, Gaze_Point_3d_Y = @Gaze_Point_3d_Y
					, Gaze_Point_3d_Z = @Gaze_Point_3d_Z
			FROM dbo.FlightData F
			WHERE FlightDataId = @FlightDataId
		END
	END
	ELSE --This is a new row
	BEGIN
	IF NOT EXISTS (SELECT 1 
					FROM dbo.FlightData 
					WHERE FlightDataId = @FlightDataId)
		BEGIN
			INSERT INTO dbo.FlightData (ScenarioId
										, UserIdentifier
										, Start_timestamp
										, Duration
										, Start_Frame_Index
										, End_Frame_Index
										, Norm_Pos_X
										, Norm_Pos_Y
										, Dispersion
										, Confidence										
										, Gaze_Point_3d_X
										, Gaze_Point_3d_Y
										, Gaze_Point_3d_Z)
			SELECT						@ScenarioId
										, @UserIdentifier
										, @Start_timestamp
										, @Duration
										, @Start_Frame_Index
										, @End_Frame_Index
										, @Norm_Pos_X
										, @Norm_Pos_Y
										, @Dispersion
										, @Confidence										
										, @Gaze_Point_3d_X
										, @Gaze_Point_3d_Y
										, @Gaze_Point_3d_Z

			SET @return = SCOPE_IDENTITY()	
			SET @FlightDataId = @return
		END;
	END;
	-- For front end use
	SELECT @return AS ReturnCode, @err_message AS errMessage

	IF @TranCount=1
	COMMIT TRANSACTION

	--Nested SPs
	IF @ScenarioId = 1
	BEGIN
		EXEC usp_MergeTakeOffData  @FlightDataId = @FlightDataId, @ScenarioId = @ScenarioId, @UserIdentifier = @UserIdentifier
	, @Start_Timestamp = @Start_Timestamp, @Duration = @Duration, @Start_Frame_Index = @Start_Frame_Index
	, @End_Frame_Index	= @End_Frame_Index, @Norm_Pos_X = @Norm_Pos_X, @Norm_Pos_Y = @Norm_Pos_Y, @Dispersion = @Dispersion, 
	@Confidence = @Confidence, @Gaze_Point_3d_X = @Gaze_Point_3d_X, @Gaze_Point_3d_Y = @Gaze_Point_3d_Y, @Gaze_Point_3d_Z = @Gaze_Point_3d_Z
	END
	ELSE IF  @ScenarioId = 2
	BEGIN
		EXEC usp_MergeLandingData  @FlightDataId = @FlightDataId, @ScenarioId = @ScenarioId, @UserIdentifier = @UserIdentifier
	, @Start_Timestamp = @Start_Timestamp, @Duration = @Duration, @Start_Frame_Index = @Start_Frame_Index
	, @End_Frame_Index	= @End_Frame_Index, @Norm_Pos_X = @Norm_Pos_X, @Norm_Pos_Y = @Norm_Pos_Y, @Dispersion = @Dispersion, 
	@Confidence = @Confidence, @Gaze_Point_3d_X = @Gaze_Point_3d_X, @Gaze_Point_3d_Y = @Gaze_Point_3d_Y, @Gaze_Point_3d_Z = @Gaze_Point_3d_Z
	END
	ELSE IF  @ScenarioId = 3
	BEGIN
		EXEC usp_MergeTurbulenceData  @FlightDataId = @FlightDataId, @ScenarioId = @ScenarioId, @UserIdentifier = @UserIdentifier
	, @Start_Timestamp = @Start_Timestamp, @Duration = @Duration, @Start_Frame_Index = @Start_Frame_Index
	, @End_Frame_Index	= @End_Frame_Index, @Norm_Pos_X = @Norm_Pos_X, @Norm_Pos_Y = @Norm_Pos_Y, @Dispersion = @Dispersion, 
	@Confidence = @Confidence, @Gaze_Point_3d_X = @Gaze_Point_3d_X, @Gaze_Point_3d_Y = @Gaze_Point_3d_Y, @Gaze_Point_3d_Z = @Gaze_Point_3d_Z
	END
	ELSE IF  @ScenarioId = 4
	BEGIN
		EXEC usp_MergeBirdStrikeData  @FlightDataId = @FlightDataId, @ScenarioId = @ScenarioId, @UserIdentifier = @UserIdentifier
	, @Start_Timestamp = @Start_Timestamp, @Duration = @Duration, @Start_Frame_Index = @Start_Frame_Index
	, @End_Frame_Index	= @End_Frame_Index, @Norm_Pos_X = @Norm_Pos_X, @Norm_Pos_Y = @Norm_Pos_Y, @Dispersion = @Dispersion, 
	@Confidence = @Confidence, @Gaze_Point_3d_X = @Gaze_Point_3d_X, @Gaze_Point_3d_Y = @Gaze_Point_3d_Y, @Gaze_Point_3d_Z = @Gaze_Point_3d_Z
	END
	ELSE 
	BEGIN
		EXEC usp_MergeEngineFailureData  @FlightDataId = @FlightDataId, @ScenarioId = @ScenarioId, @UserIdentifier = @UserIdentifier
	, @Start_Timestamp = @Start_Timestamp, @Duration = @Duration, @Start_Frame_Index = @Start_Frame_Index
	, @End_Frame_Index	= @End_Frame_Index, @Norm_Pos_X = @Norm_Pos_X, @Norm_Pos_Y = @Norm_Pos_Y, @Dispersion = @Dispersion, 
	@Confidence = @Confidence, @Gaze_Point_3d_X = @Gaze_Point_3d_X, @Gaze_Point_3d_Y = @Gaze_Point_3d_Y, @Gaze_Point_3d_Z = @Gaze_Point_3d_Z
	END
	--Nested SPs tacview export
	EXEC usp_MergeTacviewData  @TacviewDataId 	= @TacviewDataId, @PilotIdentifier	=	@PilotIdentifier, @Pilot	=	@Pilot	
	, @ISOtime		=	@ISOtime, @Unixtime		=	@Unixtime, @Longitude=	@Longitude, @Latitude	=	@Latitude, @Altitude	=	@Altitude
	, @Roll		=	@Roll, @Pitch	=	@Pitch, @Yaw	=	@Yaw, @Throttle		=	@Throttle, @AircraftName		=	@AircraftName
	, @Registration		=	@Registration, @ASL =	@ASL, @AGL =	@AGL, @AOA	=	@AOA, @G	=	@G, @LatG	=	@LatG, @LonG	=	@LonG
	, @Ek	=	@Ek, @Ep	= @Ep
		
	
END TRY	

BEGIN CATCH
	
	EXEC usp_GetErrorInfo @error = @error, @err_message = @err_message;
	IF @TranCount=1
		ROLLBACK
	ELSE
		ROLLBACK TRANSACTION usp_MergeFlightDataTran

END CATCH
END
GO

--GRANT EXECUTE ON OBJECT::dbo.usp_MergeFlightData TO [NTUser] AS [dbo];
--GO

--GRANT EXECUTE ON OBJECT::dbo.usp_MergeFlightData TO [SAUser] AS [dbo];
--GO