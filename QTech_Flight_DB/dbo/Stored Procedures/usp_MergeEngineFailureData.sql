
/*
    -- Author:      Anthony Johnston
    -- Create date: 03/01/2021
    -- Description: stored procedure to INSERT / UPDATE Flight Data into child table
    ***************************       CHANGE HISTORY (Reverse Chronological)      ***************************
    *
	*	[AJ] 16/01/2021 -	Added TRANSACTIONS / TRANSACTION save points, checking for external TRANSACTIONS 
    *********************************************************************************************************/
CREATE PROCEDURE dbo.usp_MergeEngineFailureData 
(
	@EngineFailureDataId	INTEGER = NULL
	, @FlightDataId			INTEGER 
	, @ScenarioId			INTEGER
	, @UserIdentifier		UNIQUEIDENTIFIER
	, @PilotIdentifier		UNIQUEIDENTIFIER
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
	DECLARE @TranCount	BIT = 0

BEGIN TRY
IF @@TRANCOUNT = 0
BEGIN
	BEGIN TRANSACTION
	SET @TranCount = 1
END
ELSE SAVE TRANSACTION usp_MergeEngineFailureDataTran

	IF @EngineFailureDataId IS NULL 
	BEGIN
		INSERT INTO dbo.BirdStrikeData (FlightDataId
									, ScenarioId
									, UserIdentifier
									, Start_Timestamp
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
		SELECT						@FlightDataId
									, @ScenarioId
									, @UserIdentifier
									, @Start_Timestamp
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

		--SET @return = SCOPE_IDENTITY()	
		--SET @FlightDataId = @return
	END;
	
	-- For front end use
	--SELECT @return AS ReturnCode, @err_message AS errMessage
		
	IF @TranCount=1
	COMMIT TRANSACTION

END TRY	

BEGIN CATCH
	
	EXEC usp_GetErrorInfo @error = @error, @err_message = @err_message;
	IF @TranCount=1
		ROLLBACK
	ELSE
	ROLLBACK TRANSACTION usp_MergeEngineFailureDataTran

END CATCH
END
GO
