SET NOCOUNT ON

declare @rowcount int;

print 'Scenario Static data'

--Table Variable to insert into base tables with
DECLARE @ScenarioTemp TABLE 
(
	ScenarioDescription		NVARCHAR(50)	
)

INSERT INTO  @ScenarioTemp	(ScenarioDescription)
			
VALUES							('Takeoff')
								,('Landing')
								,('Extreme Turbulance')
								,('Bird Strike')
								,('Engine Failure')

IF NOT EXISTS  (SELECT * 
				FROM dbo.Scenario)
BEGIN
	INSERT INTO dbo.Scenario		(ScenarioDescription)
	SELECT	ST.ScenarioDescription
	FROM @ScenarioTemp ST
	LEFT JOIN dbo.Scenario SC
	ON ST.ScenarioDescription = SC.ScenarioDescription
	WHERE SC.ScenarioDescription IS NULL
END