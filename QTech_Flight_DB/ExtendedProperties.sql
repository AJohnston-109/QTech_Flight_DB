/*
[AJ]:[16 JAN 2021] - 1.0.00.004	-	Added TRANSACTIONS / TRANSACTION save points, checking for external TRANSACTIONS - more robust.
									Added DateInserted column along with Default constraint GETDATE() so we know when the data was inserted. 
									Linked all the relevant SPs together Starting with usp_MergeFlightData executing child SPs within,
									passing parameters to the child SPs by defining child parameters in parent SP so can be executed all at once. 
[AJ]:[07 JAN 2021] - 1.0.00.003	-	Created XmlData to insert Xml from tacview exports as one large xml column
									Created tables to then house this data with prefix "Tac" and an Id running through each to associate with any given export file.
[AJ]:[03 JAN 2021] - 1.0.00.002	-	Scenarios table created to house the ScenarioDescription for each scenario
									Static Data script added to add scenario data alonside generated Identity Ids
									PostDeployment script added to execute static data scripts
									Child Tables Added (TakeOffData, LandingData, TurbulenceData, BirdStrikeData, EngineFailureData)
									Stored procedures added to insert data from FlightData into child tables - Different procedure called 
									based on what ScenarioId is passed into parent Stored Procedure
[AJ]:[31 DEC 2020] - 1.0.00.001	-	Baseline
*/

EXECUTE [sys].[sp_addextendedproperty] @name = N'Edition', @value = 'QTech';
GO

EXECUTE [sys].[sp_addextendedproperty] @name = N'ScriptDate', @value = '16 JAN 2021';
GO

EXECUTE [sys].[sp_addextendedproperty] @name = N'Version', @value = '1.0.00.004';
GO
