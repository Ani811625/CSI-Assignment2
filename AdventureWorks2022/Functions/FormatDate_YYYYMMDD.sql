CREATE FUNCTION dbo.fn_FormatDate_YYYYMMDD (@InputDate DATETIME)
RETURNS VARCHAR(8)
AS
BEGIN
    RETURN CAST(YEAR(@InputDate) AS VARCHAR) +
           RIGHT('0' + CAST(MONTH(@InputDate) AS VARCHAR), 2) +
           RIGHT('0' + CAST(DAY(@InputDate) AS VARCHAR), 2)
END
