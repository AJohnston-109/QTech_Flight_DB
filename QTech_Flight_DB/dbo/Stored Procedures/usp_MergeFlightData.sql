/*
    -- Author:      Anthony Johnston
    -- Create date: 31/12/2020
    -- Description: stored procedure to INSERT / UPDATE Flight Data into base table
    ***************************       CHANGE HISTORY (Reverse Chronological)      ***************************
    *
	*	
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
)
AS
BEGIN
SET NOCOUNT ON
	/*DECLARE Variables*/
	DECLARE @err_message NVARCHAR(250)
	DECLARE @error INTEGER
	DECLARE @return INTEGER
	DECLARE @UserName	NVARCHAR(100)

BEGIN TRY
	SET @UserName = (SELECT UserName 
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

	IF (@ScenarioId = 1)
	BEGIN
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
				INSERT INTO dbo.TakeOff (Start_timestamp
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
				SELECT						@Start_timestamp
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
	END;
	-- For front end use
	SELECT @return AS ReturnCode, @err_message AS errMessage
		
END TRY	

BEGIN CATCH

	EXEC usp_GetErrorInfo @error = @error, @err_message = @err_message;

END CATCH
END
GO

--GRANT EXECUTE ON OBJECT::dbo.usp_MergeFlightData TO [NTUser] AS [dbo];
--GO

--GRANT EXECUTE ON OBJECT::dbo.usp_MergeFlightData TO [SAUser] AS [dbo];
--GO