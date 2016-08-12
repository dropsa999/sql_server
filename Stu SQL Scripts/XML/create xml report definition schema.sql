IF EXISTS (SELECT * FROM sys.xml_schema_collections WHERE [name] = 'RDLDefinition')   
	DROP XML SCHEMA COLLECTION RDLDefinition 
GO 
DECLARE @rdlSchema XML

SET @rdlSchema =
	(
		SELECT * FROM OPENROWSET(BULK '\\aksqlsvr04\BULK\ReportDefinition.xsd', SINGLE_CLOB) AS xmlData
	)
	
CREATE XML SCHEMA COLLECTION RDLDefinition AS @rdlSchema 
GO