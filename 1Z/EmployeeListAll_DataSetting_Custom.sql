
USE Paradise_Beta_Tai2
GO
IF OBJECT_ID('[dbo].[EmployeeListAll_DataSetting_Custom]') IS NULL
    EXEC ('CREATE PROCEDURE [dbo].[EmployeeListAll_DataSetting_Custom] AS SELECT 1');
GO

ALTER PROCEDURE [dbo].[EmployeeListAll_DataSetting_Custom]
    @LoginID INT = 3,
    @LanguageID VARCHAR(5) = 'VN',
    @TempTableAPIName NVARCHAR(150) = ''
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @storeImgName NVARCHAR(200) = N'paradisefile_sp_GetFileAPI';
    DECLARE @sql NVARCHAR(MAX);

    -- Không dùng SelectedIds nữa → chỉ còn 2 nhánh:
    -- 1. SELECT trực tiếp
    -- 2. SELECT INTO bảng tạm

    IF LEN(ISNULL(@TempTableAPIName, '')) = 0
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
                SELECT EmployeeID 
                FROM tmpEmployeeTree 
                WHERE LoginID = @LoginID
            )';
    END
    ELSE
    BEGIN
        -- SELECT INTO bảng tạm
        SET @sql = N'
            SELECT
                e.EmployeeID,
                e.FullName,
                @storeImgName AS storeImgName,
                dbo.fn_GetStringParamImageByEmployeeID(e.EmployeeID) AS paramImg
            INTO ' + QUOTENAME(@TempTableAPIName) + N'
            FROM tblEmployee e
            WHERE e.EmployeeID IN (
                SELECT EmployeeID 
                FROM tmpEmployeeTree 
                WHERE LoginID = @LoginID
            )';
    END

    EXEC sp_executesql
        @sql,
        N'@LoginID INT, @storeImgName NVARCHAR(200)',
        @LoginID = @LoginID,
        @storeImgName = @storeImgName;
END
GO
