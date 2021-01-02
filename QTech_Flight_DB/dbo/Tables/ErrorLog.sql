CREATE TABLE dbo.ErrorLog
(
	ErrorLogId			INTEGER IDENTITY(1,1) NOT NULL 
	, ErrorNumber		INTEGER NULL
	, ErrorSeverity		INTEGER NULL
	, ErrorState		INTEGER NULL
	, ErrorProcedure	NVARCHAR(100)
	, ErrorLine			INTEGER NULL
	, ErrorMessage		NVARCHAR(4000)
	, ErrorDate			DATETIME
	, CONSTRAINT PK_ErrorLogId PRIMARY KEY (ErrorLogId)
)
