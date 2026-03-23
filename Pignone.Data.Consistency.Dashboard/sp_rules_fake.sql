CREATE OR ALTER PROCEDURE sp_rule_fake
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @TotalRows INT = (ABS(CHECKSUM(NEWID())) % 50) + 1;

    DECLARE @Types TABLE (IdentifierType VARCHAR(50));
    INSERT INTO @Types (IdentifierType)
    VALUES 
        ('CPF'),
        ('Matricula'),
        ('OrderId'),
        ('CustomerId'),
        ('Email'),
        ('Phone'),
        ('AccountNumber');

    ;WITH Numbers AS (
        SELECT TOP (@TotalRows)
            ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS N
        FROM sys.objects
    )
    SELECT 
        T.IdentifierType,
        CASE T.IdentifierType
            WHEN 'CPF' THEN 
                RIGHT('00000000000' + CAST(ABS(CHECKSUM(NEWID())) % 100000000000 AS VARCHAR), 11)
            WHEN 'Matricula' THEN 
                'MAT' + CAST(ABS(CHECKSUM(NEWID())) % 100000 AS VARCHAR)
            WHEN 'OrderId' THEN 
                'ORD' + CAST(ABS(CHECKSUM(NEWID())) % 1000000 AS VARCHAR)
            WHEN 'CustomerId' THEN 
                'CUST' + CAST(ABS(CHECKSUM(NEWID())) % 1000000 AS VARCHAR)
            WHEN 'Email' THEN 
                'user' + CAST(ABS(CHECKSUM(NEWID())) % 10000 AS VARCHAR) + '@mail.com'
            WHEN 'Phone' THEN 
                '+55' + CAST(ABS(CHECKSUM(NEWID())) % 10000000000 AS VARCHAR)
            WHEN 'AccountNumber' THEN 
                CAST(ABS(CHECKSUM(NEWID())) % 100000000 AS VARCHAR)
            ELSE 
                CAST(NEWID() AS VARCHAR)
        END AS Identifier
    FROM Numbers N
    CROSS APPLY (
        SELECT TOP 1 IdentifierType 
        FROM @Types 
        ORDER BY NEWID()
    ) T;
END
GO