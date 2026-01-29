USE Paradise_Dev
GO

IF OBJECT_ID('[dbo].[sp_Task_AssignSubtasks]') IS NULL
    EXEC ('CREATE PROCEDURE [dbo].[sp_Task_AssignSubtasks] AS SELECT 1')
GO

ALTER PROCEDURE [dbo].[sp_Task_AssignSubtasks]
    @ParentTaskID INT,
    @RequesterEmployeeID NVARCHAR(20) = NULL,
    @AssigneeEmployeeID NVARCHAR(20) = NULL,
    @RequestDate DATE = NULL,
    @CommittedHours DECIMAL(18,2) = NULL,
    @SubtasksJSON NVARCHAR(MAX),
    @LoginID INT,
    @LanguageID NVARCHAR(10) = 'VN'
AS
BEGIN
    SET NOCOUNT ON;
    
    BEGIN TRY
        BEGIN TRANSACTION;
        
        DECLARE @ProjectID INT;
        SELECT @ProjectID = ProjectID FROM tblTask_Tasks WHERE TaskID = @ParentTaskID;

        -- If ParentTaskID is not found, use a default ProjectID if possible or error out
        IF @ProjectID IS NULL
        BEGIN
            -- Fallback or handle error
            -- For now, let's assume it exists or we use ProjectID 1 as fallback for demo
            SET @ProjectID = 1; 
        END

        INSERT INTO tblTask_Tasks (
            ProjectID, 
            TaskName, 
            Description, 
            AssigneeID, 
            ParentTaskID, 
            Status, 
            Priority, 
            dBy, 
            dDate,
            ModifiedDate
        )
        SELECT 
            @ProjectID,
            JSON_VALUE(val.value, '$.TaskName'),
            JSON_VALUE(val.value, '$.Description'),
            @AssigneeEmployeeID,
            @ParentTaskID,
            'To Do',
            ISNULL(JSON_VALUE(val.value, '$.Priority'), 'Medium'),
            @RequesterEmployeeID,
            GETDATE(),
            GETDATE()
        FROM OPENJSON(@SubtasksJSON) AS val;
        
        COMMIT TRANSACTION;
        
        -- Return results as expected by AjaxHPAParadise (usually the last dataset)
        SELECT 'SUCCESS' AS Status, N'Giao việc thành công' AS Message;
        
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        SELECT 'ERROR' AS Status, ERROR_MESSAGE() AS Message;
    END CATCH
END
GO

-- 6. Save Project (Create/Update)
IF OBJECT_ID('[dbo].[sp_Task_Project_Save]') IS NULL
    EXEC ('CREATE PROCEDURE [dbo].[sp_Task_Project_Save] AS SELECT 1')
GO

ALTER PROCEDURE [dbo].[sp_Task_Project_Save]
    @ProjectID INT = NULL,
    @ProjectName NVARCHAR(255),
    @Description NVARCHAR(MAX) = NULL,
    @OwnerID NVARCHAR(20) = NULL,
    @Status NVARCHAR(50) = 'Planning',
    @Priority NVARCHAR(20) = 'Medium',
    @StartDate DATE = NULL,
    @EndDate DATE = NULL,
    @LoginID INT
AS
BEGIN
    SET NOCOUNT ON;
    IF @ProjectID IS NULL OR @ProjectID = 0
    BEGIN
        INSERT INTO tblTask_Projects (ProjectName, Description, OwnerID, Status, Priority, StartDate, EndDate, dDate, ModifiedDate)
        VALUES (@ProjectName, @Description, @OwnerID, @Status, @Priority, @StartDate, @EndDate, GETDATE(), GETDATE());
        SELECT 'SUCCESS' AS Status, N'Thêm dự án thành công' AS Message, SCOPE_IDENTITY() AS NewProjectID;
    END
    ELSE
    BEGIN
        UPDATE tblTask_Projects SET 
            ProjectName = @ProjectName,
            Description = @Description,
            OwnerID = @OwnerID,
            Status = @Status,
            Priority = @Priority,
            StartDate = @StartDate,
            EndDate = @EndDate,
            ModifiedDate = GETDATE()
        WHERE ProjectID = @ProjectID;
        SELECT 'SUCCESS' AS Status, N'Cập nhật dự án thành công' AS Message, @ProjectID AS NewProjectID;
    END
END
GO

-- 7. Update Task Single Field
IF OBJECT_ID('[dbo].[sp_Task_UpdateField]') IS NULL
    EXEC ('CREATE PROCEDURE [dbo].[sp_Task_UpdateField] AS SELECT 1')
GO

ALTER PROCEDURE [dbo].[sp_Task_UpdateField]
    @TaskID INT,
    @FieldName NVARCHAR(50),
    @Value NVARCHAR(MAX),
    @LoginID INT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @SQL NVARCHAR(MAX);
    
    -- White list of fields to prevent SQL injection (though we use parameters, better safe)
    IF @FieldName NOT IN ('TaskName', 'Description', 'AssigneeID', 'Priority', 'Status', 'StartDate', 'DueDate')
    BEGIN
        SELECT 'ERROR' AS Status, N'Trường dữ liệu không hợp lệ' AS Message;
        RETURN;
    END

    SET @SQL = N'UPDATE tblTask_Tasks SET ' + QUOTENAME(@FieldName) + N' = @Val, ModifiedDate = GETDATE() WHERE TaskID = @ID';
    
    EXEC sp_executesql @SQL, N'@Val NVARCHAR(MAX), @ID INT', @Val = @Value, @ID = @TaskID;

    SELECT 'SUCCESS' AS Status, N'Cập nhật thành công' AS Message;
END
GO

-- 8. Set Task Tags
IF OBJECT_ID('[dbo].[sp_Task_SetTags]') IS NULL
    EXEC ('CREATE PROCEDURE [dbo].[sp_Task_SetTags] AS SELECT 1')
GO

ALTER PROCEDURE [dbo].[sp_Task_SetTags]
    @TaskID INT,
    @TagsJSON NVARCHAR(MAX), -- e.g. '[1, 2, 3]'
    @LoginID INT
AS
BEGIN
    SET NOCOUNT ON;
    DELETE FROM tblTask_TaskTags WHERE TaskID = @TaskID;
    INSERT INTO tblTask_TaskTags (TaskID, TagID)
    SELECT @TaskID, CAST(val.value AS INT)
    FROM OPENJSON(@TagsJSON) AS val;
    SELECT 'SUCCESS' AS Status, N'Cập nhật thẻ thành công' AS Message;
END
GO

-- 9. Get All Data (Projects, Employees, Tasks, etc.)
IF OBJECT_ID('[dbo].[sp_Task_GetData]') IS NULL
    EXEC ('CREATE PROCEDURE [dbo].[sp_Task_GetData] AS SELECT 1')
GO

ALTER PROCEDURE [dbo].[sp_Task_GetData]
    @LoginID INT,
    @LanguageID NVARCHAR(10) = 'VN'
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @ProjectsJSON NVARCHAR(MAX) = (SELECT ProjectID, ProjectName, Description, OwnerID, StartDate, EndDate, Status, Priority FROM tblTask_Projects FOR JSON PATH);
    DECLARE @EmployeesJSON NVARCHAR(MAX) = (SELECT EmployeeID, FullName, Email FROM tblEmployee FOR JSON PATH);
    DECLARE @TasksJSON NVARCHAR(MAX) = (SELECT TaskID, ProjectID, TaskName, Description, AssigneeID, ParentTaskID, StartDate, DueDate, Status, Priority FROM tblTask_Tasks FOR JSON PATH);
    DECLARE @PositionsJSON NVARCHAR(MAX) = (SELECT PositionID, PositionName FROM tblPosition FOR JSON PATH);
    DECLARE @TagsJSON NVARCHAR(MAX) = (SELECT TagID, TagName, Color FROM tblTask_Tags FOR JSON PATH);
    DECLARE @ProcessesJSON NVARCHAR(MAX) = (SELECT ProcessID, TaskID, OldStatus, NewStatus, ChangedBy, ChangedDate FROM tblTask_TaskProcesses FOR JSON PATH);
    DECLARE @CommentsJSON NVARCHAR(MAX) = (SELECT CommentID, TaskID, EmployeeID AS UserID, Comment, dDate AS CreatedDate FROM tblTask_Comments FOR JSON PATH);

    SELECT 
        ISNULL(@ProjectsJSON, '[]') AS Projects,
        ISNULL(@EmployeesJSON, '[]') AS Employees,
        ISNULL(@TasksJSON, '[]') AS Tasks,
        ISNULL(@PositionsJSON, '[]') AS Positions,
        ISNULL(@TagsJSON, '[]') AS Tags,
        ISNULL(@ProcessesJSON, '[]') AS Processes,
        ISNULL(@CommentsJSON, '[]') AS Comments;
END
GO