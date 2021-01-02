/*
    -- Author:      Anthony Johnston
    -- Create date: 31/12/2020
    -- Description: stored procedure to Select Flight Data on a per user basis, or all data if parameter not supplied
    ***************************       CHANGE HISTORY (Reverse Chronological)      ***************************
    *
	*	
    *********************************************************************************************************/
CREATE PROCEDURE dbo.usp_SelectFlightData
	--@UserIdentifier		UNIQUEIDENTIFIER = NULL
	@Username			NVARCHAR(50)	= NULL
	
AS
BEGIN
SET NOCOUNT ON
	DECLARE @err_message NVARCHAR(250)
	DECLARE @error INTEGER
	
	DECLARE @UserIdentifier		UNIQUEIDENTIFIER
	SET @UserIdentifier = (SELECT UserIdentifier 
							FROM dbo.Users
							WHERE UserName = @Username)
BEGIN TRY
	

	SELECT UserIdentifier	
	, Start_timestamp
	, Duration
	, Start_Frame_Index
	, End_Frame_Index
	, Norm_Pos_X
	, Norm_Pos_Y
	, Dispersion
	, Confidence
	, Method
	, Gaze_Point_3d_X
	, Gaze_Point_3d_Y
	, Gaze_Point_3d_Z
	FROM dbo.FlightData
	WHERE UserIdentifier = @UserIdentifier OR @UserIdentifier IS NULL /*By user if parameter supplied - if none supplied, selects all data for all users*/

END TRY
BEGIN CATCH
	
	EXEC usp_GetErrorInfo @error = @error, @err_message = @err_message;
    
END CATCH
END