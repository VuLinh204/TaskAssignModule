USE Paradise_Beta_Tai2
GO
IF OBJECT_ID('[dbo].[EmployeeListAll_DataSetting_Custom]') IS NULL
    EXEC ('CREATE PROCEDURE [dbo].[EmployeeListAll_DataSetting_Custom] AS SELECT 1');
GO

ALTER PROCEDURE [dbo].[EmployeeListAll_DataSetting_Custom]
    @LoginID INT = 3,
    @LanguageID VARCHAR(5) = 'VN',
    @SelectedIds NVARCHAR(150) = '',
    @TempTableAPIName NVARCHAR(150) = ''
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @storeImgName NVARCHAR(200) = N'paradisefile_sp_GetFileAPI';
    DECLARE @sql NVARCHAR(MAX);

    IF LEN(ISNULL(@TempTableAPIName, '')) = 0
    BEGIN
        -- SELECT trực tiếp
        IF LEN(ISNULL(@SelectedIds, '')) > 0
        BEGIN
            -- Dùng trực tiếp EmployeeID dạng varchar, KHÔNG CAST
            SET @sql = N'
                SELECT
                    e.EmployeeID,
                    e.FullName,
                    @storeImgName AS storeImgName,
                    dbo.fn_GetStringParamImageByEmployeeID(e.EmployeeID) AS paramImg
                FROM tblEmployee e
                WHERE e.EmployeeID IN (
                    SELECT Items
                    FROM SplitString(@SelectedIds, '','')
                    WHERE ISNULL(Items, '''') <> ''''
                )';
        END
        ELSE
        BEGIN
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
    END
    ELSE
    BEGIN
        -- Ghi dữ liệu vào bảng tạm
        IF LEN(ISNULL(@SelectedIds, '')) > 0
        BEGIN
            SET @sql = N'
                SELECT
                    e.EmployeeID,
                    e.FullName,
                    @storeImgName AS storeImgName,
                    dbo.fn_GetStringParamImageByEmployeeID(e.EmployeeID) AS paramImg
                INTO ' + QUOTENAME(@TempTableAPIName) + N'
                FROM tblEmployee e
                WHERE e.EmployeeID IN (
                    SELECT Items
                    FROM SplitString(@SelectedIds, '','')
                    WHERE ISNULL(Items, '''') <> ''''
                )';
        END
        ELSE
        BEGIN
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
                )';
        END
    END

    EXEC sp_executesql
        @sql,
        N'@LoginID INT, @storeImgName NVARCHAR(200), @SelectedIds NVARCHAR(150)',
        @LoginID = @LoginID,
        @storeImgName = @storeImgName,
        @SelectedIds = @SelectedIds;
END
GO
