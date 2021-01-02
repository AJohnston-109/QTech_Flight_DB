/*
    -- Author:      Anthony Johnston
    -- Create date: 02/01/2021
    -- Description: stored procedure to DELETE Flight Data
    ***************************       CHANGE HISTORY (Reverse Chronological)      ***************************
    *
	*	
    *********************************************************************************************************/

CREATE PROCEDURE dbo.usp_DeleteFlightData
(
	@UserIdentifier			UNIQUEIDENTIFIER = NULL
	, @FlightDataId			INTEGER = NULL
)
AS 
BEGIN
DECLARE @err_message NVARCHAR(250)
DECLARE @error INTEGER

BEGIN TRY
IF @FlightDataId IS NULL AND @UserIdentifier IS NULL
	BEGIN
			SET @error = -2;
            SET @err_message=N'No FlightDataId or UserIdentifier given. Quitting as we cannot proceed';
            EXEC usp_GetErrorInfo @error=@error, @Procedure='usp_DeleteFlightData', @err_message=@err_message;
            SELECT @err_message AS ErrorMessage
			RETURN; -- do not process any more. quit  
	END;
IF EXISTS (SELECT 1
			FROM dbo.FlightData
			WHERE UserIdentifier = @UserIdentifier)
BEGIN
	DELETE 
	FROM dbo.FlightData 
	WHERE (UserIdentifier = @UserIdentifier OR @UserIdentifier IS NULL)
	OR (FlightDataId = @FlightDataId OR @FlightDataId IS NULL)
END

END TRY	

BEGIN CATCH
		
		EXEC usp_GetErrorInfo @error = @error, @err_message = @err_message;
       
END CATCH
END