USE Paradise_Dev
GO

IF OBJECT_ID('[dbo].[sp_Task_AssignSubtasks]') IS NULL
    EXEC ('CREATE PROCEDURE [dbo].[sp_Task_AssignSubtasks] AS SELECT 1')
GO

ALTER PROCEDURE [dbo].[sp_Task_AssignSubtasks]
    @ParentTaskID        BIGINT,
    @RequesterEmployeeID VARCHAR(100) = NULL,
    @AssigneeEmployeeID  VARCHAR(100) = NULL,
    @RequestDate         DATETIME     = NULL,
    @CommittedHours      FLOAT        = NULL,
    @SubtasksJSON        NVARCHAR(MAX),
    @LoginID             INT,
    @LanguageID          VARCHAR(2) = 'VN'
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE @HeaderID INT;
    DECLARE @TaskName NVARCHAR(500);

    -- 1. Get Parent Task Name for Header Title
    SELECT @TaskName = TaskName FROM tblTask WHERE TaskID = @ParentTaskID;
    
    BEGIN TRY
        BEGIN TRANSACTION;

        -- 2. Insert into tblTask_AssignHeader
        INSERT INTO tblTask_AssignHeader (
            HeaderTitle,
            StartDate,
            PersonInCharge,
            MainPersonInCharge,
            Note,
            CommittedHours,
            TaskParentID
        )
        VALUES (
            N'Giao việc từ: ' + ISNULL(@TaskName, N'Task #' + CAST(@ParentTaskID AS NVARCHAR(20))),
            @RequestDate,
            @RequesterEmployeeID,
            @AssigneeEmployeeID,
            N'Giao việc tự động từ MyWork UI',
            @CommittedHours,
            @ParentTaskID
        );

        SET @HeaderID = SCOPE_IDENTITY();

        -- 3. Parse JSON into Temp Table for easier processing
        CREATE TABLE #SubtaskData (
            TaskID              BIGINT,
            TaskName            NVARCHAR(500),
            AssignedEmployeeIDs NVARCHAR(MAX),
            StartDate           DATETIME,
            EndDate             DATETIME,
            Priority            TINYINT,
            Note                NVARCHAR(MAX)
        );

        INSERT INTO #SubtaskData
        SELECT * FROM OPENJSON(@SubtasksJSON)
        WITH (
            TaskID              BIGINT         '$.TaskID',
            TaskName            NVARCHAR(500)  '$.TaskName',
            AssignedEmployeeIDs NVARCHAR(MAX)  '$.AssignedEmployeeIDs',
            StartDate           DATETIME       '$.StartDate',
            EndDate             DATETIME       '$.EndDate',
            Priority            TINYINT        '$.Priority',
            Note                NVARCHAR(MAX)  '$.Note'
        );

        -- 4. Handle TaskID = 0 (New tasks)
        -- a. Check if task exists by name
        UPDATE s
        SET s.TaskID = t.TaskID
        FROM #SubtaskData s
        JOIN tblTask t ON t.TaskName = s.TaskName
        WHERE s.TaskID = 0;

        -- b. Create tasks that still don't exist
        INSERT INTO tblTask (TaskName, Status)
        SELECT DISTINCT TaskName, 1
        FROM #SubtaskData
        WHERE TaskID = 0;

        -- c. Update IDs of newly created tasks
        UPDATE s
        SET s.TaskID = t.TaskID
        FROM #SubtaskData s
        JOIN tblTask t ON t.TaskName = s.TaskName
        WHERE s.TaskID = 0;

        -- 5. Link new children to parent template if relationship missing
        INSERT INTO tblTask_Template (ParentTaskID, ChildTaskID)
        SELECT DISTINCT @ParentTaskID, s.TaskID
        FROM #SubtaskData s
        WHERE NOT EXISTS (
            SELECT 1 FROM tblTask_Template 
            WHERE ParentTaskID = @ParentTaskID AND ChildTaskID = s.TaskID
        );

        -- 6. Finally insert into tblTask_AssignHistory
        INSERT INTO tblTask_AssignHistory (
            HeaderID,
            EmployeeID,
            TaskID,
            ActualKPI,
            Progress,
            Status,
            StartDate,
            EndDate,
            AssignPriority,
            CommittedHours,
            Description
        )
        SELECT 
            @HeaderID,
            s.AssignedEmployeeIDs,
            s.TaskID,
            NULL, -- ActualKPI
            0,    -- Progress
            1,    -- Status (To Do)
            s.StartDate,
            s.EndDate,
            s.Priority,
            CASE 
                WHEN s.StartDate IS NOT NULL AND s.EndDate IS NOT NULL 
                THEN DATEDIFF(MINUTE, s.StartDate, s.EndDate) / 60.0 
                ELSE NULL 
            END,
            s.Note
        FROM #SubtaskData s;

        DROP TABLE #SubtaskData;

        COMMIT TRANSACTION;

        -- Return Success
        SELECT 'SUCCESS' AS Status, 'Giao việc thành công' AS Message, @HeaderID AS HeaderID;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        IF OBJECT_ID('tempdb..#SubtaskData') IS NOT NULL DROP TABLE #SubtaskData;
        
        SELECT 'ERROR' AS Status, ERROR_MESSAGE() AS Message;
    END CATCH
END
GO
