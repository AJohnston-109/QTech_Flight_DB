/*
    -- Author:      Anthony Johnston
    -- Create date: 11/01/2021
    -- Description: stored procedure to INSERT / UPDATE Data from Tacview into table
    ***************************       CHANGE HISTORY (Reverse Chronological)      ***************************
    *
	*	[AJ] 16/01/2021 -	Added TRANSACTIONS / TRANSACTION save points
	*********************************************************************************************************/
CREATE PROCEDURE dbo.usp_MergeTacviewData
(
	@TacviewDataId 				INTEGER = NULL
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

BEGIN TRY
IF @@TRANCOUNT = 0
BEGIN
	BEGIN TRANSACTION
	SET @TranCount = 1
END
ELSE SAVE TRANSACTION usp_MergeTacviewDataTran

	IF @TacviewDataId IS NULL 
	BEGIN
		INSERT INTO dbo.TacviewData (ISOtime
									, PilotIdentifier
									, Unixtime
									, Longitude
									, Latitude	
									, Altitude
									, Roll
									, Pitch
									, Yaw
									, Throttle
									, AircraftName	
									, Registration
									, ASL
									, AGL
									, AOA
									, G
									, LatG
									, LonG
									, Ek
									, Ep)
		SELECT						@ISOtime
									, NEWID() 
									, @Unixtime
									, @Longitude
									, @Latitude	
									, @Altitude
									, @Roll
									, @Pitch
									, @Yaw
									, @Throttle
									, @AircraftName	
									, @Registration
									, @ASL
									, @AGL
									, @AOA
									, @G
									, @LatG
									, @LonG
									, @Ek
									, @Ep	
	END
	ELSE
	BEGIN
		UPDATE T 
			SET						ISOtime = @ISOtime
									--, PilotIdentifier = @PilotIdentifier
									, Unixtime = @Unixtime
									, Longitude = @Longitude
									, Latitude = @Latitude
									, Altitude = @Altitude
									, Roll = @Roll
									, Pitch = @Pitch
									, Yaw = @Yaw
									, Throttle = @Throttle
									, AircraftName = @AircraftName
									, Registration = @Registration
									, ASL = @ASL
									, AGL = @AGL
									, AOA = @AOA
									, G = @G
									, LatG = @LatG
									, LonG = @LonG
									, Ek = @Ek
									, Ep = @Ep
			FROM dbo.TacviewData 	T
			WHERE TacviewDataId = @TacviewDataId
		
	END;
	
	-- For front end use
	SELECT @return AS ReturnCode, @err_message AS errMessage
		
	IF @TranCount=1
	COMMIT TRANSACTION

END TRY	

BEGIN CATCH
	
	EXEC usp_GetErrorInfo @error = @error, @err_message = @err_message;
	IF @TranCount=1
		ROLLBACK
	ELSE
	ROLLBACK TRANSACTION usp_MergeTacviewDataTran

END CATCH
END
GO
