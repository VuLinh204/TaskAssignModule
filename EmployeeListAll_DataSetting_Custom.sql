USE Paradise_Beta_Tai2
GO
if object_id('[dbo].[EmployeeListAll_DataSetting_Custom]') is null
	EXEC ('CREATE PROCEDURE [dbo].[EmployeeListAll_DataSetting_Custom] as select 1')
GO

ALTER PROCEDURE [dbo].[EmployeeListAll_DataSetting_Custom]
    @LoginID INT = 3,
    @LanguageID VARCHAR(5) = 'VN',
    @zxc123 NVARCHAR(150) = '',
    @TempTableAPIName NVARCHAR(150) = ''
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @storeImgName NVARCHAR(200) = N'paradisefile_sp_GetFileAPI';
    DECLARE @sql NVARCHAR(MAX);

    IF LEN(@TempTableAPIName) = 0
    BEGIN
        -- SELECT trực tiếp
        SET @sql = N'
            SELECT
                e.EmployeeID,
                e.FullName,
                @storeImgName AS storeImgName,
                dbo.fn_GetStringParamImageByEmployeeID(e.EmployeeID) AS paramImg
            FROM tblEmployee e
            WHERE e.EmployeeID IN (
                SELECT EmployeeID FROM tmpEmployeeTree WHERE LoginID = 3
            )';
    END
    ELSE
    BEGIN
        -- Đưa vào bảng tạm API → phải dùng QUOTENAME để tránh SQL injection
        SET @sql = N'
            SELECT
                e.EmployeeID,
                e.FullName,
                @storeImgName AS storeImgName,
                dbo.fn_GetStringParamImageByEmployeeID(e.EmployeeID) AS paramImg
            INTO ' + QUOTENAME(@TempTableAPIName) + N'
            FROM tblEmployee e
            WHERE e.EmployeeID IN (
                SELECT EmployeeID FROM tmpEmployeeTree
            )';
    END

    EXEC sp_executesql
        @sql,
        N'@LoginID INT, @storeImgName NVARCHAR(200)',
        @LoginID = @LoginID,
        @storeImgName = @storeImgName;
END
GO

EmployeeListAll_DataSetting_Custom