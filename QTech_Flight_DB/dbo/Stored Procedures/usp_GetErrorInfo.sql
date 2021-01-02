/*
    -- Author:      Anthony Johnston
    -- Create date: 31/12/2020
    -- Description: Stored procedure to log to ErrorLog table in Validation and catch sections of Merge SPs
    ***************************       CHANGE HISTORY (Reverse Chronological)      ***************************
    *
	*	
    *********************************************************************************************************/
CREATE PROCEDURE usp_GetErrorInfo  
(
	@error			INTEGER = NULL,
	@Procedure		NVARCHAR(50) = NULL,
	@err_message	NVARCHAR(250) = NULL
)
AS  
BEGIN
	IF @err_message IS NOT NULL
	BEGIN
		INSERT INTO dbo.ErrorLog (ErrorNumber, ErrorSeverity, ErrorProcedure,  ErrorMessage, ErrorDate)
		SELECT @error, 16,  @Procedure, @err_message, GETDATE()
	END
	ELSE 
	BEGIN		
		INSERT into dbo.ErrorLog (ErrorNumber, ErrorSeverity, ErrorState, ErrorProcedure, ErrorLine, ErrorMessage, ErrorDate)
		SELECT ERROR_NUMBER(), ERROR_SEVERITY(), ERROR_STATE(), ERROR_PROCEDURE(), ERROR_LINE(), ERROR_MESSAGE(), GETDATE()
	END

	DECLARE @line INT=ERROR_LINE(), @sev INT=ERROR_SEVERITY()
	DECLARE	@msg NVARCHAR(4000) 
	DECLARE @OrigMsg NVARCHAR(4000) ='Orignal SQL Server Error: ' + CAST(ERROR_NUMBER() AS VARCHAR)+N' '+ISNULL(ERROR_MESSAGE(), '')+N'!';
	
	IF @err_message IS NULL
	BEGIN
		IF ERROR_NUMBER() = 547
		BEGIN
			SET @msg = 'The requested data insert is invalid as no matching data in parent table. See rest of error message for more details (Below)' + CHAR(13) + @OrigMsg
			RAISERROR(@msg, @sev, @line) WITH NOWAIT;
		END
		ELSE IF ERROR_NUMBER() = 2627
		BEGIN 
			SET @msg =  'Data entered in this Name field must be unique - Name already Exists. See rest of error message for more details (Below)' + CHAR(13) + @OrigMsg
			RAISERROR(@msg, @sev, @line) WITH NOWAIT;
		END
		ELSE IF ERROR_NUMBER() = 245
		BEGIN 
			SET @msg =  'Data type entered in this field is invalid	 See rest of error message for more details	(Below)' + CHAR(13) + @OrigMsg
			RAISERROR(@msg, @sev, @line) WITH NOWAIT;
		END	
		ELSE IF ERROR_NUMBER() = 127
		BEGIN 
			SET @msg =  'Cannot use negative numbers to bring back X number of rows: ' + CHAR(13) + @OrigMsg
			RAISERROR(@msg, @sev, @line) WITH NOWAIT;
		END	
		ELSE 
		BEGIN
			SET @msg = 'Error not handled - error information in Orignal SQL Server Error (Below)' + CHAR(13) + @OrigMsg
			RAISERROR(@msg, @sev, @line) WITH NOWAIT;
		END
	END;
END
GO  

--GRANT EXECUTE ON OBJECT::dbo.usp_GetErrorInfo TO [NTUser] AS [dbo];
--GO

--GRANT EXECUTE ON OBJECT::dbo.usp_GetErrorInfo TO [SAUser] AS [dbo];
--GO
