--Reference table so we know what ScenarioId equates to - ScenarioId is in all base tables.
CREATE TABLE dbo.Scenario
(
	ScenarioId				INTEGER IDENTITY(1,1) NOT NULL
	, ScenarioDescription	NVARCHAR(50)
	, CONSTRAINT PK_Scenario_ScenarioId PRIMARY KEY (ScenarioId)
)
