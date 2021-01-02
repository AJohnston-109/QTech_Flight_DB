
/*
    -- Author:      Anthony Johnston
    -- Create date: 31/12/2020
    -- Description: stored procedure to Merge data into Users Table
    ***************************       CHANGE HISTORY (Reverse Chronological)      ***************************
    *
	*	
    *********************************************************************************************************/

CREATE PROCEDURE dbo.usp_MergeUsers
(
	@UserId				INTEGER = NULL
	--, @UserIdentifier	UNIQUEIDENTIFIER --Not Required as default "NEWID()" already in effect.
	, @UserName			NVARCHAR(50)
	, @Password			NVARCHAR(50)
	, @Email			NVARCHAR(50)
)
AS
BEGIN
	SET NOCOUNT ON
	DECLARE @err_message NVARCHAR(250)
	DECLARE @error INTEGER
	DECLARE @return INTEGER
BEGIN TRY

	IF @UserId IS NOT NULL --This is an UPDATE
	BEGIN
		IF EXISTS (SELECT 1 FROM dbo.Users WHERE UserId = @UserId)
		BEGIN
			SET			@return = @UserId
			UPDATE U
			SET			UserName = @UserName
						, [Password] = @Password
						, Email = @Email
			FROM dbo.Users 	U
			WHERE UserId = @UserId	
		END	
	END;
	ELSE -- this is a new User
	BEGIN
		IF NOT EXISTS (SELECT 1 FROM dbo.Users WHERE UserId = @UserId)
		BEGIN
			INSERT INTO dbo.Users (UserName	
									, [Password]
									, Email)
			SELECT					@UserName	
									, @Password
									, @Email	
			SET @return = SCOPE_IDENTITY()
			Set @UserId = @return
		END
	END

	SELECT @return AS ReturnCode, @err_message AS errMessage

END TRY
BEGIN CATCH
	
	EXEC usp_GetErrorInfo @error = @error, @err_message = @err_message;
    
END CATCH
END