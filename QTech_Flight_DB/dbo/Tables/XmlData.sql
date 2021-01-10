
CREATE TABLE dbo.XmlData
(
	XmlDataId		INT IDENTITY(1,1)	NOT NULL 
	, XmlDocument	XML					NULL
	, LoadedDateTime DATETIME			NULL
	, CONSTRAINT PK_XmlData_XmlDataId PRIMARY KEY (XmlDataId)
)
