--Begin script: sp_Task_GetListChildCandidate
USE Paradise_Beta_Tai2
GO
if object_id('[dbo].[sp_Task_GetListChildCandidate]') is null
	EXEC ('CREATE PROCEDURE [dbo].[sp_Task_GetListChildCandidate] as select 1')
GO

ALTER PROCEDURE [dbo].[sp_Task_GetListChildCandidate]
    @LoginID INT = 59,
    @ParentTaskID BIGINT = 9
AS
BEGIN
    SET NOCOUNT ON;

    -------------------------------------------------------------
    -- Lấy EmployeeID thực từ LoginID
    -------------------------------------------------------------
    DECLARE @EmployeeID VARCHAR(20);

    SELECT @EmployeeID = EmployeeID
    FROM tblSC_Login
    WHERE LoginID = @LoginID;


    -------------------------------------------------------------
    -- LẤY TASK ỨNG VIÊN (KHÔNG HỀ CÓ ASSIGN HISTORY)
    -------------------------------------------------------------
    SELECT
        T.TaskID AS value,
        T.TaskName + ' (ID: ' + CAST(T.TaskID AS VARCHAR(20)) + ')' AS text
    FROM tblTask T
	
    WHERE
        T.Status = 1

        -- LOẠI toàn bộ task xuất hiện trong tblTask_AssignHistory
        AND NOT EXISTS (
            SELECT 1
            FROM tblTask_AssignHistory AH
            WHERE AH.TaskID = T.TaskID
        )

        -- Không phải task cha của bất kỳ task nào
        AND NOT EXISTS (
            SELECT 1
            FROM tblTask_Template TT
            WHERE TT.ParentTaskID = T.TaskID
        )

        -- ❌ Không phải task con của bất kỳ task nào
        AND NOT EXISTS (
            SELECT 1
            FROM tblTask_Template TT
            WHERE TT.ChildTaskID = T.TaskID
        )

        -- ❌ Không phải task con của ParentTaskID hiện tại
        AND NOT EXISTS (
            SELECT 1
            FROM tblTask_Template TT
            WHERE TT.ParentTaskID = @ParentTaskID
              AND TT.ChildTaskID = T.TaskID
        )

        -- ❌ Không lấy chính task cha
        AND T.TaskID <> @ParentTaskID

    ORDER BY T.TaskName;
END
GO
--Begin script: sp_Task_GetListForParent
USE Paradise_Beta_Tai2
GO
if object_id('[dbo].[sp_Task_GetListForParent]') is null
	EXEC ('CREATE PROCEDURE [dbo].[sp_Task_GetListForParent] as select 1')
GO
ALTER PROCEDURE [dbo].[sp_Task_GetListForParent]
    @Keyword NVARCHAR(100) = '',
    @LoginID INT = 59
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @Like NVARCHAR(102) = '%' + TRIM(@Keyword) + '%';

    SELECT TOP 50
        T.TaskID AS value,
        T.TaskName + ' (ID: ' + CAST(T.TaskID AS VARCHAR(20)) + ')' AS text
    FROM tblTask T
    WHERE T.Status = 1
      AND (T.TaskName LIKE @Like OR CAST(T.TaskID AS VARCHAR) LIKE @Like)
      AND (
            -- Cho phép chọn task đã có subtask (làm cha)
            EXISTS (SELECT 1 FROM tblTask_Template TT WHERE TT.ParentTaskID = T.TaskID)
            OR
            -- Hoặc task chưa có con nào
            NOT EXISTS (SELECT 1 FROM tblTask_Template TT WHERE TT.ChildTaskID = T.TaskID)
          )
    ORDER BY
        CASE WHEN T.TaskName LIKE @Like + '%' THEN 0 ELSE 1 END,
        T.TaskName
END
GO
--Begin script: sp_Task_GetAssignmentSetup
USE Paradise_Beta_Tai2
GO
if object_id('[dbo].[sp_Task_GetAssignmentSetup]') is null
	EXEC ('CREATE PROCEDURE [dbo].[sp_Task_GetAssignmentSetup] as select 1')
GO
ALTER PROCEDURE [dbo].[sp_Task_GetAssignmentSetup]
    @LoginID INT = 59,
    @LanguageID VARCHAR(2) = 'VN',
    @ParentTaskID BIGINT = NULL
AS
BEGIN
    -- Chỉ trả về danh sách công việc có thể làm cha
    SELECT
        T.TaskID,
        T.TaskName,
        '' AS Description,
        (SELECT COUNT(*) FROM tblTask_Template WHERE ParentTaskID = T.TaskID) AS ChildCount,
        CASE WHEN EXISTS(SELECT 1 FROM tblTask_Template WHERE ParentTaskID = T.TaskID) THEN 1 ELSE 0 END AS HasChildren
    FROM tblTask T
    WHERE T.Status = 1
      AND T.TaskID <> ISNULL(@ParentTaskID, -1) -- Loại bỏ chính nó nếu có truyền @ParentTaskID
    ORDER BY T.TaskID DESC;
END
GO
--Begin script: sp_Task_GetMyTasks
USE Paradise_Beta_Tai2
GO
if object_id('[dbo].[sp_Task_GetMyTasks]') is null
	EXEC ('CREATE PROCEDURE [dbo].[sp_Task_GetMyTasks] as select 1')
GO

ALTER PROCEDURE [dbo].[sp_Task_GetMyTasks]
    @LoginID INT = 59,
    @LanguageID VARCHAR(2) = 'VN'
AS
BEGIN
    SET NOCOUNT ON;

    -- Lấy EmployeeID của người login
    DECLARE @EmployeeID VARCHAR(20)
    SELECT @EmployeeID = EmployeeID
    FROM tblSC_Login
    WHERE LoginID = @LoginID

    IF @EmployeeID IS NULL
    BEGIN
        SELECT CAST(NULL AS BIGINT) AS TaskID, N'' AS TaskName WHERE 1 = 0
        RETURN
    END

    -- Populate assign history (nếu có)
    EXEC dbo.sp_Task_PopulateAssignHistoryForLogin @LoginID = @LoginID

    -------------------------------------------------------------------------
    -- Result set 1: Headers with tasks
    -------------------------------------------------------------------------
    SELECT DISTINCT
        H.TaskParentID,
        H.HeaderTitle,
        H.StartDate,
        H.PersonInCharge,
        ISNULL((
            SELECT COUNT(*)
            FROM tblTask_AssignHistory ah
            WHERE ah.TaskParentID = H.TaskParentID
              AND ',' + ah.EmployeeID + ',' LIKE '%,' + @EmployeeID + ',%'
        ),0) AS TasksCountForEmployee,
        ISNULL((SELECT COUNT(*) FROM tblTask_AssignHistory ah WHERE ah.TaskParentID = H.TaskParentID),0) AS TotalTasksInHeader,
        CAST(AVG(CAST(ISNULL(AH.Progress,0) AS FLOAT)) AS INT) AS AvgProgress,
        SUM(CASE WHEN ISNULL(AH.Status,N'Pending')=N'Done' THEN 1 ELSE 0 END) AS CompletedTasks,
        MAX(CASE WHEN AH.EndDate < GETDATE() AND ISNULL(AH.Status,N'Pending')!=N'Done' THEN 1 ELSE 0 END) AS IsOverdue
    FROM tblTask_AssignHistory AH
    INNER JOIN tblTask_AssignHeader H ON AH.TaskParentID = H.TaskParentID
    WHERE ',' + AH.EmployeeID + ',' LIKE '%,' + @EmployeeID + ',%'
    GROUP BY H.TaskParentID, H.HeaderTitle, H.StartDate, H.PersonInCharge
    ORDER BY H.StartDate DESC

    -------------------------------------------------------------------------
    -- Result set 2: Child tasks belonging to headers
    -------------------------------------------------------------------------
    SELECT
        H.TaskParentID,
        T.TaskID,
        T.TaskName,
        T.PositionID,
        T.Unit,
        ISNULL(T.KPIPerDay,0) AS TargetKPI,
        ISNULL(AH.ActualKPI,0) AS ActualKPI,
        ISNULL(AH.Progress,0) AS Progress,
        CASE
            WHEN ISNULL(T.KPIPerDay,0) > 0 THEN CAST(ISNULL(AH.ActualKPI,0)*100.0/T.KPIPerDay AS INT)
            WHEN EXISTS (SELECT 1 FROM tblTask_Template TT WHERE TT.ParentTaskID=T.TaskID) THEN
                ISNULL((
                    SELECT CAST(COUNT(CASE WHEN ch.Status=N'Done' THEN 1 END)*100.0/NULLIF(COUNT(*),0) AS INT)
                    FROM tblTask_Template tt_inner
                    INNER JOIN tblTask_AssignHistory ch ON ch.TaskID=tt_inner.ChildTaskID
                    WHERE tt_inner.ParentTaskID=T.TaskID
                      AND ',' + ch.EmployeeID + ',' LIKE '%,' + @EmployeeID + ',%'
                ),0)
            ELSE ISNULL(AH.Progress,0)
        END AS ProgressPct,
        ISNULL(AH.Status,N'Pending') AS AssignStatus,
        CASE
            WHEN ISNULL(AH.Status,N'Pending')=N'Pending' THEN 1
            WHEN ISNULL(AH.Status,N'Pending')=N'Doing'   THEN 2
            WHEN ISNULL(AH.Status,N'Pending')=N'Done'    THEN 3
            ELSE 1
        END AS StatusCode,
        AH.StartDate AS AssignedDate,
        AH.StartDate AS MyStartDate,
        AH.EndDate AS DueDate,
        CASE WHEN AH.EndDate IS NOT NULL AND AH.EndDate<GETDATE() AND ISNULL(AH.Status,N'Pending')!=N'Done' THEN 1 ELSE 0 END AS IsOverdue,
        CASE WHEN EXISTS (SELECT 1 FROM tblTask_Template TT WHERE TT.ParentTaskID=T.TaskID) THEN 1 ELSE 0 END AS HasSubtasks,
        ISNULL((SELECT COUNT(*) FROM tblTask_Comment C WHERE C.TaskID=T.TaskID),0) AS CommentCount,
        ISNULL((SELECT COUNT(*) FROM tblTask_Attachment A WHERE A.TaskID=T.TaskID),0) AS AttachmentCount,
        ISNULL(AH.AssignPriority,T.Priority) AS AssignPriority,
        -- Multi-assignee CSV
        ISNULL((
            SELECT STUFF((
                SELECT ',' + ISNULL(AH2.EmployeeID,'')
                FROM tblTask_AssignHistory AH2
                WHERE AH2.TaskID=T.TaskID AND AH2.TaskParentID=AH.TaskParentID
                FOR XML PATH('')
            ),1,1,'')
        ),'') AS AssignedToEmployeeIDs,
        (SELECT ParentTaskID FROM tblTask_Template WHERE ChildTaskID=T.TaskID) AS ParentTaskID
    FROM tblTask_AssignHistory AH
    INNER JOIN tblTask T ON T.TaskID = AH.TaskID
    INNER JOIN tblTask_AssignHeader H ON H.TaskParentID = AH.TaskParentID
    WHERE ',' + AH.EmployeeID + ',' LIKE '%,' + @EmployeeID + ',%'
      AND T.Status=1
    ORDER BY H.StartDate DESC, T.TaskName

    -------------------------------------------------------------------------
    -- Result set 3: Standalone tasks (no header)
    -------------------------------------------------------------------------
    SELECT
        T.TaskID,
        T.TaskName,
        T.PositionID,
        T.Unit,
        ISNULL(T.KPIPerDay,0) AS TargetKPI,
        ISNULL(H.ActualKPI,0) AS ActualKPI,
        ISNULL(H.Progress,0) AS Progress,
        CASE
            WHEN ISNULL(T.KPIPerDay,0) > 0 THEN CAST(ISNULL(H.ActualKPI,0)*100.0/T.KPIPerDay AS INT)
            WHEN EXISTS (SELECT 1 FROM tblTask_Template TT WHERE TT.ParentTaskID=T.TaskID) THEN
                ISNULL((
                    SELECT CAST(COUNT(CASE WHEN ch.Status=N'Done' THEN 1 END)*100.0/NULLIF(COUNT(*),0) AS INT)
                    FROM tblTask_Template tt_inner
                    INNER JOIN tblTask_AssignHistory ch ON ch.TaskID=tt_inner.ChildTaskID
                    WHERE tt_inner.ParentTaskID=T.TaskID
                      AND ',' + ch.EmployeeID + ',' LIKE '%,' + @EmployeeID + ',%'
                ),0)
            ELSE ISNULL(H.Progress,0)
        END AS ProgressPct,
        ISNULL(H.Status,N'Pending') AS AssignStatus,
        CASE
            WHEN ISNULL(H.Status,N'Pending')=N'Pending' THEN 1
            WHEN ISNULL(H.Status,N'Pending')=N'Doing'   THEN 2
            WHEN ISNULL(H.Status,N'Pending')=N'Done'    THEN 3
            ELSE 1
        END AS StatusCode,
        H.StartDate AS AssignedDate,
        H.StartDate AS MyStartDate,
        H.EndDate AS DueDate,
        CASE WHEN H.EndDate IS NOT NULL AND H.EndDate<GETDATE() AND ISNULL(H.Status,N'Pending')!=N'Done' THEN 1 ELSE 0 END AS IsOverdue,
        CASE WHEN EXISTS (SELECT 1 FROM tblTask_Template TT WHERE TT.ParentTaskID=T.TaskID) THEN 1 ELSE 0 END AS HasSubtasks,
        ISNULL((SELECT COUNT(*) FROM tblTask_Comment C WHERE C.TaskID=T.TaskID),0) AS CommentCount,
        ISNULL((SELECT COUNT(*) FROM tblTask_Attachment A WHERE A.TaskID=T.TaskID),0) AS AttachmentCount,
        ISNULL(H.AssignPriority,T.Priority) AS AssignPriority,
        -- Multi-assignee CSV
        ISNULL((
            SELECT STUFF((
                SELECT ',' + ISNULL(H2.EmployeeID,'')
                FROM tblTask_AssignHistory H2
                WHERE H2.TaskID=T.TaskID AND H2.TaskParentID IS NULL
                FOR XML PATH('')
            ),1,1,'')
        ),'') AS AssignedToEmployeeIDs,
        (SELECT ParentTaskID FROM tblTask_Template WHERE ChildTaskID=T.TaskID) AS ParentTaskID
    FROM tblTask_AssignHistory H
    INNER JOIN tblTask T ON T.TaskID = H.TaskID
        WHERE ',' + H.EmployeeID + ',' LIKE '%,' + @EmployeeID + ',%'
            AND T.Status=1
            AND H.TaskParentID IS NULL
    ORDER BY IsOverdue DESC, ISNULL(H.EndDate,'9999-12-31') ASC, T.TaskName
END
GO
--Begin script: sp_Task_GetDetail
USE Paradise_Beta_Tai2
GO
if object_id('[dbo].[sp_Task_GetDetail]') is null
	EXEC ('CREATE PROCEDURE [dbo].[sp_Task_GetDetail] as select 1')
GO

ALTER PROCEDURE [dbo].[sp_Task_GetDetail]
    @TaskID BIGINT = 10,
    @LoginID INT = 59
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @EmployeeID VARCHAR(20);
    SELECT @EmployeeID = EmployeeID FROM tblSC_Login WHERE LoginID = @LoginID;

    -- 1. Task chính
        SELECT
			T.*,
			CASE WHEN EXISTS(SELECT 1 FROM tblTask_Template WHERE ParentTaskID = @TaskID)
				THEN 1 ELSE 0
			END AS HasSubtasks,

			(SELECT ParentTaskID
			 FROM tblTask_Template
			 WHERE ChildTaskID = @TaskID) AS BelongsToParent,
            AH.TaskParentID,
            CASE
                WHEN AH.TaskParentID IS NOT NULL THEN AH.StartDate
                ELSE NULL
            END AS AssignStartDate,

            -- ⭐ Nếu có TaskParentID thì lấy CommittedHours từ tblTask_AssignHeader
            CASE
                WHEN AH.TaskParentID IS NOT NULL THEN H.CommittedHours
                ELSE NULL
            END AS CommittedHours,

			H.PersonInCharge AS RequestedBy,
			H.HeaderTitle,

			ISNULL(
				(SELECT TOP 1 FullName
				 FROM dbo.fn_vtblEmployeeList_Bydate(CAST(GETDATE() AS DATE), '-1', NULL)
				 WHERE EmployeeID = H.PersonInCharge),
				H.PersonInCharge
			) AS RequestedByName,

            ISNULL(
                CASE
                    WHEN AH.TaskParentID IS NOT NULL THEN
                        (SELECT TOP 1 MainAH.EmployeeID
                         FROM tblTask_AssignHistory MainAH
                         INNER JOIN tblTask_Template TT ON TT.ChildTaskID = @TaskID
                         WHERE MainAH.TaskParentID = AH.TaskParentID
                           AND MainAH.TaskID = TT.ParentTaskID)
                    ELSE AH.EmployeeID
                END,
                AH.EmployeeID
            ) AS MainResponsibleID,

                    ISNULL(
                        (SELECT TOP 1 FullName
                         FROM dbo.fn_vtblEmployeeList_Bydate(CAST(GETDATE() AS DATE), '-1', NULL)
                         WHERE EmployeeID =
                        ISNULL(
                            CASE WHEN AH.TaskParentID IS NOT NULL THEN
                                (SELECT TOP 1 MainAH.EmployeeID
                                 FROM tblTask_AssignHistory MainAH
                                 INNER JOIN tblTask_Template TT ON TT.ChildTaskID = @TaskID
                                 WHERE MainAH.TaskParentID = AH.TaskParentID
                                   AND MainAH.TaskID = TT.ParentTaskID)
                            ELSE AH.EmployeeID END,
                            AH.EmployeeID
                        )
                    ),
                    @EmployeeID
                ) AS MainResponsibleName

		FROM tblTask T
        LEFT JOIN tblTask_AssignHistory AH
            ON AH.TaskID = T.TaskID AND AH.EmployeeID = @EmployeeID
        LEFT JOIN tblTask_AssignHeader H
            ON H.TaskParentID = AH.TaskParentID
		WHERE T.TaskID = @TaskID
		ORDER BY AH.StartDate DESC;

    -- 2. Assign history
    SELECT
        AH.HistoryID,
        AH.TaskParentID,
        AH.EmployeeID,
        AH.StartDate,
        AH.EndDate,
        AH.ActualKPI,
        AH.Progress,
        AH.Status,
        ISNULL(
            (SELECT TOP 1 FullName
             FROM dbo.fn_vtblEmployeeList_Bydate(CAST(GETDATE() AS DATE), '-1', NULL)
             WHERE EmployeeID = AH.EmployeeID),
            AH.EmployeeID
        ) AS EmployeeName
    FROM tblTask_AssignHistory AH
    WHERE AH.TaskID = @TaskID
    ORDER BY AH.StartDate DESC, AH.HistoryID DESC;

    -- 3. Comments
    SELECT
        C.CommentID,
        C.EmployeeID,
        C.Content,
        C.CreatedDate,
        ISNULL(
            (SELECT TOP 1 FullName
             FROM dbo.fn_vtblEmployeeList_Bydate(CAST(GETDATE() AS DATE), '-1', NULL)
             WHERE EmployeeID = C.EmployeeID),
            C.EmployeeID
        ) AS EmployeeName
    FROM tblTask_Comment C
    WHERE C.TaskID = @TaskID
    ORDER BY C.CreatedDate DESC;

    -- 4. Attachments
    SELECT
        A.AttachID,
        A.FileName,
        A.FilePath,
        A.UploadedBy,
        A.UploadedDate,
        ISNULL(
            (SELECT TOP 1 FullName FROM dbo.fn_vtblEmployeeList_Bydate(CAST(GETDATE() AS DATE), '-1', NULL)
             WHERE EmployeeID = A.UploadedBy),
            A.UploadedBy
        ) AS UploadedByName
    FROM tblTask_Attachment A
    WHERE A.TaskID = @TaskID
    ORDER BY A.UploadedDate DESC;

-- 5. Subtasks
        SELECT
        TT.ChildTaskID,
        T.TaskName AS ChildTaskName,
        ISNULL(T.KPIPerDay, 0) AS DefaultKPI,
        T.Unit,
        ISNULL(T.Priority, 3) AS Priority,
        H.EmployeeID AS AssignedToEmployeeID,
        H.StartDate AS SubtaskStartDate,
        H.EndDate AS SubtaskEndDate,
        ISNULL(H.ActualKPI, 0) AS SubtaskActualKPI,
        ISNULL(H.Progress, 0) AS SubtaskProgress,
        CASE
            WHEN H.Status = N'Done' THEN 3
            WHEN H.Status = N'Doing' THEN 2
            ELSE 1
        END AS SubtaskStatusCode,
        H.Status,
        Emp.FullName AS AssignedToEmployeeName
    FROM tblTask_Template TT
    INNER JOIN tblTask T ON TT.ChildTaskID = T.TaskID
    LEFT JOIN tblTask_AssignHistory H
        ON H.TaskID = TT.ChildTaskID
       AND H.EmployeeID = @EmployeeID
    LEFT JOIN dbo.fn_vtblEmployeeList_Bydate(CAST(GETDATE() AS DATE), '-1', NULL) Emp
        ON Emp.EmployeeID = H.EmployeeID
    WHERE TT.ParentTaskID = @TaskID
    ORDER BY ISNULL(H.SortOrder, 999999), TT.ChildTaskID;

    -- 6. List task khả dụng
    SELECT
        T.TaskID,
        T.TaskName,
        ISNULL(T.KPIPerDay, 0) AS DefaultKPI,
        T.Unit,
        ISNULL(T.Priority, 3) AS Priority,
        CASE WHEN T.PositionID IS NOT NULL THEN 1 ELSE 0 END AS IsFixed
    FROM tblTask T
    WHERE T.Status = 1
      AND T.TaskID != @TaskID
      AND T.PositionID IS NULL
      AND NOT EXISTS (SELECT 1 FROM tblTask_Template TT WHERE TT.ChildTaskID = T.TaskID)
      AND NOT EXISTS (SELECT 1 FROM tblTask_Template TT WHERE TT.ParentTaskID = T.TaskID)
      AND NOT EXISTS (
          SELECT 1 FROM tblTask_AssignHistory H
          WHERE H.TaskID = T.TaskID AND H.TaskParentID IS NULL
      )
    ORDER BY T.TaskName;
END
GO
--Begin script: sp_Task_UpdateSubtaskOrder
USE Paradise_Beta_Tai2
GO
if object_id('[dbo].[sp_Task_UpdateSubtaskOrder]') is null
	EXEC ('CREATE PROCEDURE [dbo].[sp_Task_UpdateSubtaskOrder] as select 1')
GO
ALTER PROCEDURE [dbo].[sp_Task_UpdateSubtaskOrder]
    @ParentTaskID BIGINT,
    @OrderedChildIDs VARCHAR(MAX),
    @LoginID INT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @EmployeeID VARCHAR(20);
    SELECT @EmployeeID = EmployeeID FROM tblSC_Login WHERE LoginID = @LoginID;

    -- Kiểm tra task cha
    IF NOT EXISTS (SELECT 1 FROM tblTask WHERE TaskID = @ParentTaskID)
    BEGIN
        SELECT 0 AS Success, N'Task cha không tồn tại!' AS ErrorMessage;
        RETURN;
    END

    -- Lấy TaskParentID (task này thuộc parent-task group mà user đang làm)
    DECLARE @TaskParentID INT;
    SELECT @TaskParentID = TaskParentID
    FROM tblTask_AssignHistory
    WHERE TaskID = @ParentTaskID AND EmployeeID = @EmployeeID;

    -- Bảng tạm phân thứ tự mới
    DECLARE @Temp TABLE (ChildID BIGINT, SortOrder INT IDENTITY(1,1));

    INSERT INTO @Temp (ChildID)
    SELECT CAST(value AS BIGINT)
    FROM STRING_SPLIT(@OrderedChildIDs, ',')
    WHERE ISNUMERIC(value) = 1;

    -- Cập nhật SortOrder theo HeaderID + user hiện tại
    UPDATE AH
    SET AH.SortOrder = T.SortOrder
    FROM tblTask_AssignHistory AH
    INNER JOIN @Temp T ON AH.TaskID = T.ChildID
        WHERE AH.EmployeeID = @EmployeeID
            AND AH.TaskParentID = @TaskParentID;

    SELECT 1 AS Success, N'Cập nhật thứ tự thành công!';
END
GO
--Begin script: sp_Task_GetDetailedTemplate
USE Paradise_Beta_Tai2
GO
if object_id('[dbo].[sp_Task_GetDetailedTemplate]') is null
	EXEC ('CREATE PROCEDURE [dbo].[sp_Task_GetDetailedTemplate] as select 1')
GO
--Begin script: sp_Task_GetDetailedTemplate
ALTER PROCEDURE [dbo].[sp_Task_GetDetailedTemplate]
    @ParentTaskID BIGINT
AS
BEGIN
    SELECT
        T.TaskID AS ChildTaskID,
        T.TaskName AS ChildTaskName,
        ISNULL(T.KPIPerDay, 0) AS DefaultKPI,
        T.Unit,
        ISNULL(T.Priority, 3) AS Priority,
        0 AS IsNew
    FROM tblTask_Template TMP
    INNER JOIN tblTask T ON TMP.ChildTaskID = T.TaskID
    WHERE TMP.ParentTaskID = @ParentTaskID
    ORDER BY T.TaskID;
END
GO
--Begin script: sp_Task_UpdateMainTaskOrder
USE Paradise_Beta_Tai2
GO
if object_id('[dbo].[sp_Task_UpdateMainTaskOrder]') is null
	EXEC ('CREATE PROCEDURE [dbo].[sp_Task_UpdateMainTaskOrder] as select 1')
GO

-- Tạo lại SP (phiên bản hoàn chỉnh + xử lý HeaderID = NULL đúng cách)
ALTER PROCEDURE [dbo].[sp_Task_UpdateMainTaskOrder]
    @LoginID INT,
    @TaskParentID INT = NULL,                    -- NULL = task standalone (không thuộc parent header nào)
    @OrderedTaskIDs VARCHAR(MAX)             -- "15,8,27,4"
AS
BEGIN
    SET NOCOUNT ON;

	DECLARE @EmployeeID VARCHAR(20);
	SELECT @EmployeeID = EmployeeID
	FROM tblSC_Login
	WHERE LoginID = @LoginID;

    -- Bảng tạm lưu thứ tự mới
    DECLARE @Temp TABLE (TaskID BIGINT, NewOrder INT IDENTITY(1,1))

    INSERT INTO @Temp (TaskID)
    SELECT CAST(LTRIM(RTRIM(value)) AS BIGINT)
    FROM STRING_SPLIT(@OrderedTaskIDs, ',')
    WHERE LTRIM(RTRIM(value)) <> ''
      AND ISNUMERIC(LTRIM(RTRIM(value))) = 1

    -- Cập nhật SortOrder theo thứ tự người dùng kéo thả
    UPDATE AH
    SET AH.SortOrder = T.NewOrder
    FROM tblTask_AssignHistory AH
    INNER JOIN @Temp T ON AH.TaskID = T.TaskID
        WHERE AH.EmployeeID = @EmployeeID
            AND (
                        (@TaskParentID IS NULL AND AH.TaskParentID IS NULL)
                        OR
                        (AH.TaskParentID = @TaskParentID)
                    )

    -- Đảm bảo các task còn lại (không có trong danh sách kéo thả) có SortOrder lớn (đẩy xuống dưới)
    UPDATE tblTask_AssignHistory
    SET SortOrder = 999999
        WHERE EmployeeID = @EmployeeID
            AND (
                        (@TaskParentID IS NULL AND TaskParentID IS NULL)
                        OR
                        (TaskParentID = @TaskParentID)
                    )
      AND TaskID NOT IN (SELECT TaskID FROM @Temp)
      AND (SortOrder IS NULL OR SortOrder = 999999)

    SELECT 1 AS Success, N'Đã lưu thứ tự công việc thành công!' AS Message
END
GO
--Begin script: sp_Task_UpdateSubtaskAssignees
USE Paradise_Beta_Tai2
GO
if object_id('[dbo].[sp_Task_UpdateSubtaskAssignees]') is null
	EXEC ('CREATE PROCEDURE [dbo].[sp_Task_UpdateSubtaskAssignees] as select 1')
GO
ALTER PROCEDURE [dbo].[sp_Task_UpdateSubtaskAssignees]
    @ChildTaskID BIGINT,
    @EmployeeIDs VARCHAR(MAX),
    @LoginID INT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @RequestEmployeeID VARCHAR(20);
    SELECT @RequestEmployeeID = EmployeeID FROM tblSC_Login WHERE LoginID = @LoginID;

    -- Xác định TaskParentID nếu có (ưu tiên header có giá trị TaskParentID)
    DECLARE @ExistingHeaderID INT = NULL;
    SELECT TOP 1 @ExistingHeaderID = TaskParentID
    FROM tblTask_AssignHistory
    WHERE TaskID = @ChildTaskID AND TaskParentID IS NOT NULL
    ORDER BY StartDate DESC;

    -- Xóa các bản ghi assign hiện tại cho task này trong header tương ứng (hoặc standalone)
    DELETE FROM tblTask_AssignHistory
    WHERE TaskID = @ChildTaskID
      AND (
            (@ExistingHeaderID IS NULL AND TaskParentID IS NULL)
            OR (TaskParentID = @ExistingHeaderID)
          );

    -- Nếu không có employee nào truyền lên thì chỉ xoá và trả về
    IF LTRIM(RTRIM(ISNULL(@EmployeeIDs,''))) = ''
    BEGIN
        SELECT 1 AS Success, N'Đã xóa người phụ trách hiện có; không có nhân viên mới được cung cấp.' AS Message;
        RETURN;
    END

    -- Tách danh sách EmployeeIDs và chèn từng dòng riêng
    DECLARE @Emp TABLE (EmployeeID VARCHAR(50));
    INSERT INTO @Emp(EmployeeID)
    SELECT LTRIM(RTRIM(value)) FROM STRING_SPLIT(@EmployeeIDs, ',') WHERE LTRIM(RTRIM(value)) <> '';

    INSERT INTO tblTask_AssignHistory (
        TaskParentID, EmployeeID, TaskID, StartDate, EndDate, Status, Progress, ActualKPI, CommittedHours
    )
    SELECT
        @ExistingHeaderID,
        EmployeeID,
        @ChildTaskID,
        GETDATE(),
        DATEADD(DAY, 1, GETDATE()),
        N'Pending',
        0,
        0,
        NULL
    FROM @Emp;

    SELECT 1 AS Success, N'Cập nhật người phụ trách thành công.' AS Message;
END
GO
--Begin script: sp_Task_AssignWithDetails
USE Paradise_Beta_Tai2
GO
if object_id('[dbo].[sp_Task_AssignWithDetails]') is null
	EXEC ('CREATE PROCEDURE [dbo].[sp_Task_AssignWithDetails] as select 1')
GO
ALTER PROCEDURE [dbo].[sp_Task_AssignWithDetails]
    @ParentTaskID BIGINT,
    @MainResponsibleID VARCHAR(20),
    @AssignmentDetails NVARCHAR(MAX), -- JSON: [{ ChildTaskID, EmployeeIDs: [...], Notes, Priority }]
    @AssignmentDate DATE,              -- Chỉ cần 1 ngày
    @AssignedBy INT,
    @AssignmentDueDate DATE = NULL,    -- Optional due date provided by client
    @CommittedHours FLOAT = NULL,      -- Optional committed hours (float)
    @ConfirmUpdate BIT = 0
AS
BEGIN
    SET NOCOUNT ON;

    -- 1. Lấy thông tin người giao việc
    DECLARE @AssignedEmployeeID VARCHAR(20);
    SELECT @AssignedEmployeeID = EmployeeID FROM tblSC_Login WHERE LoginID = @AssignedBy;
    IF @AssignedEmployeeID IS NULL
    BEGIN
        SELECT 0 AS Success, N'Người giao việc không hợp lệ!' AS ErrorMessage;
        RETURN;
    END

    -- 2. Lấy tên task cha
    DECLARE @ParentTaskName NVARCHAR(500);
    SELECT @ParentTaskName = TaskName FROM tblTask WHERE TaskID = @ParentTaskID;
    IF @ParentTaskName IS NULL
    BEGIN
        SELECT 0 AS Success, N'Task cha không tồn tại!' AS ErrorMessage;
        RETURN;
    END

    -- 3. Tính StartDate / EndDate. Prefer @AssignmentDueDate if provided, else use @AssignmentDate
    DECLARE @StartDate DATETIME;
    DECLARE @EndDate DATETIME;
    -- date used for duplicate-check (either due date or assignment date)
    DECLARE @AssignmentCheckDate DATE = COALESCE(@AssignmentDueDate, @AssignmentDate);
    IF @AssignmentDueDate IS NOT NULL
    BEGIN
        SET @StartDate = DATEADD(SECOND, 1, CAST(@AssignmentDueDate AS DATETIME));
        SET @EndDate = DATEADD(SECOND, -1, DATEADD(DAY, 1, CAST(@AssignmentDueDate AS DATETIME)));
    END
    ELSE
    BEGIN
        SET @StartDate = DATEADD(SECOND, 1, CAST(@AssignmentDate AS DATETIME));
        SET @EndDate = DATEADD(SECOND, -1, DATEADD(DAY, 1, CAST(@AssignmentDate AS DATETIME)));
    END

    -- 4. Kiểm tra trùng task cha
        DECLARE @ExistingMainAssign INT;
        SELECT @ExistingMainAssign = COUNT(*)
        FROM tblTask_AssignHistory
        WHERE TaskID = @ParentTaskID
            AND EmployeeID = @MainResponsibleID
            AND CAST(StartDate AS DATE) = @AssignmentCheckDate;

    IF @ExistingMainAssign > 0 AND @ConfirmUpdate = 0
    BEGIN
        SELECT 0 AS Success,
               N' Nhân viên ' + @MainResponsibleID + N' đã được giao task này trong ngày ' +
               CONVERT(VARCHAR(10), @AssignmentDate, 103) + N'. Bạn có muốn CẬP NHẬT?' AS ErrorMessage,
               'DUPLICATE_ASSIGNMENT' AS ErrorType;
        RETURN;
    END

    -- 5. Tạo hoặc cập nhật Header
    DECLARE @NewHeaderID INT;

    IF @ExistingMainAssign > 0 AND @ConfirmUpdate = 1
    BEGIN
                SELECT TOP 1 @NewHeaderID = TaskParentID
                FROM tblTask_AssignHistory
                WHERE TaskID = @ParentTaskID
                    AND EmployeeID = @MainResponsibleID
                ORDER BY StartDate DESC;

                UPDATE tblTask_AssignHistory
                SET StartDate = @StartDate, EndDate = @EndDate, Status = N'Pending', Progress = 0, CommittedHours = @CommittedHours
                WHERE TaskParentID = @NewHeaderID;
                -- Also update header's StartDate and CommittedHours so header reflects chosen dates/hours
                UPDATE tblTask_AssignHeader
                SET StartDate = @StartDate, CommittedHours = @CommittedHours
                WHERE TaskParentID = @NewHeaderID;
    END
    ELSE
    BEGIN
        INSERT INTO tblTask_AssignHeader (HeaderTitle, StartDate, PersonInCharge, Note, TaskParentID, CommittedHours)
        VALUES (@ParentTaskName, @StartDate, @AssignedEmployeeID, NULL, @ParentTaskID, @CommittedHours);
        SET @NewHeaderID = SCOPE_IDENTITY();
    END

    -- 6. XỬ LÝ TASK CON TỪ JSON
    IF ISJSON(@AssignmentDetails) = 0 OR @AssignmentDetails IS NULL OR @AssignmentDetails = ''
    BEGIN
        -- Không có task con → thêm Task cha vào lịch sử và trả về thành công
        INSERT INTO tblTask_AssignHistory (TaskParentID, EmployeeID, TaskID, StartDate, EndDate, Status, Progress, CommittedHours)
        VALUES (@ParentTaskID, @MainResponsibleID, @ParentTaskID, @StartDate, @EndDate, N'Pending', 0, @CommittedHours);

        SELECT 1 AS Success, N'Giao việc thành công!' AS Message, @NewHeaderID AS TaskParentID;
        RETURN;
    END

    -- Bảng tạm để chứa task con và nhiều người
    CREATE TABLE #ParsedDetails (
        ChildTaskID BIGINT,
        EmployeeID VARCHAR(20),
        Notes NVARCHAR(500),
        Priority INT
    );

    -- Parse JSON: hỗ trợ mảng EmployeeIDs
    INSERT INTO #ParsedDetails (ChildTaskID, EmployeeID, Notes, Priority)
    SELECT
        ChildTaskID,
        emp.[value] AS EmployeeID,
        Notes,
        ISNULL(Priority, 3) AS Priority
    FROM OPENJSON(@AssignmentDetails) WITH (
        ChildTaskID BIGINT '$.ChildTaskID',
        EmployeeIDs NVARCHAR(MAX) '$.EmployeeIDs' AS JSON,
        Notes NVARCHAR(500) '$.Notes',
        Priority INT '$.Priority'
    )
    OUTER APPLY OPENJSON(EmployeeIDs) AS emp;

    -- Bảng tạm chứa danh sách ChildTaskID (hỗ trợ các dạng JSON khác: array of numbers, or objects without EmployeeIDs)
    CREATE TABLE #ChildList (ChildTaskID BIGINT);

    -- 1) Lấy ChildTaskID từ các object có trường ChildTaskID
    INSERT INTO #ChildList (ChildTaskID)
    SELECT DISTINCT ChildTaskID
    FROM OPENJSON(@AssignmentDetails) WITH (
        ChildTaskID BIGINT '$.ChildTaskID'
    )
    WHERE ChildTaskID IS NOT NULL;

    -- 2) Nếu JSON là mảng số: [10,11,12]
    INSERT INTO #ChildList (ChildTaskID)
    SELECT DISTINCT TRY_CAST([value] AS BIGINT)
    FROM OPENJSON(@AssignmentDetails)
    WHERE TRY_CAST([value] AS BIGINT) IS NOT NULL
      AND TRY_CAST([value] AS BIGINT) NOT IN (SELECT ChildTaskID FROM #ChildList);

    -- 7. Kiểm tra task con cố định (không cho phép)
    IF EXISTS (
        SELECT 1
        FROM (
            SELECT ChildTaskID FROM #ParsedDetails
            UNION
            SELECT ChildTaskID FROM #ChildList
        ) PD
        INNER JOIN tblTask T ON T.TaskID = PD.ChildTaskID
        WHERE NULLIF(LTRIM(RTRIM(T.PositionID)), '') IS NOT NULL
    )
    BEGIN
        SELECT 0 AS Success, N'Không thể giao task con cố định theo chức vụ!' AS ErrorMessage;
        DROP TABLE #ParsedDetails;
        DROP TABLE #ChildList;
        RETURN;
    END

    -- 8. Insert vào lịch sử
    -- a) Nếu có hàng parsed với EmployeeID -> chèn theo #ParsedDetails (mỗi người 1 dòng)
    IF EXISTS (SELECT 1 FROM #ParsedDetails WHERE EmployeeID IS NOT NULL AND LTRIM(RTRIM(EmployeeID)) != '')
    BEGIN
        INSERT INTO tblTask_AssignHistory (
            TaskParentID, EmployeeID, TaskID, StartDate, EndDate, Status, Progress, AssignPriority, CommittedHours
        )
        SELECT
            @NewHeaderID,
            EmployeeID,
            ChildTaskID,
            @StartDate,
            @EndDate,
            N'Pending',
            0,
            Priority,
            @CommittedHours
        FROM #ParsedDetails
        WHERE EmployeeID IS NOT NULL AND LTRIM(RTRIM(EmployeeID)) != '';
    END
    -- b) Nếu không có EmployeeID nhưng có danh sách ChildTaskID -> chèn các child với MainResponsibleID
    ELSE IF EXISTS (SELECT 1 FROM #ChildList)
    BEGIN
        INSERT INTO tblTask_AssignHistory (
            TaskParentID, EmployeeID, TaskID, StartDate, EndDate, Status, Progress, AssignPriority, CommittedHours
        )
        SELECT
            @NewHeaderID,
            @MainResponsibleID,
            CL.ChildTaskID,
            @StartDate,
            @EndDate,
            N'Pending',
            0,
            ISNULL((SELECT TOP 1 Priority FROM tblTask WHERE TaskID = CL.ChildTaskID), 3),
            @CommittedHours
        FROM (SELECT DISTINCT ChildTaskID FROM #ChildList) CL;
    END
    -- c) Nếu không có gì cả -> chèn Task cha
    ELSE
    BEGIN
        INSERT INTO tblTask_AssignHistory (TaskParentID, EmployeeID, TaskID, StartDate, EndDate, Status, Progress, CommittedHours)
        VALUES (@ParentTaskID, @MainResponsibleID, @ParentTaskID, @StartDate, @EndDate, N'Pending', 0, @CommittedHours);
    END

    DROP TABLE #ParsedDetails;
    DROP TABLE #ChildList;

    -- 9. Trả kết quả
    SELECT 1 AS Success, N'Giao việc thành công!' AS Message, @NewHeaderID AS TaskParentID;
END
GO
--Begin script: sp_Task_GetAssignHistoryForTaskAndEmployee
USE Paradise_Beta_Tai2
GO
if object_id('[dbo].[sp_Task_GetAssignHistoryForTaskAndEmployee]') is null
	EXEC ('CREATE PROCEDURE [dbo].[sp_Task_GetAssignHistoryForTaskAndEmployee] as select 1')
GO
ALTER PROCEDURE [dbo].[sp_Task_GetAssignHistoryForTaskAndEmployee]
    @TaskIDs NVARCHAR(MAX), -- comma-separated TaskIDs (e.g. '10,11,12')
    @EmployeeID VARCHAR(20)
AS
BEGIN
    SET NOCOUNT ON;

    -- Return latest assign-history row for each TaskID provided (for the given employee)
    -- Parse CSV TaskIDs using STRING_SPLIT and OUTER APPLY to fetch TOP 1 per TaskID
    ;WITH TaskList AS (
        SELECT DISTINCT TRY_CAST(value AS BIGINT) AS TaskID
        FROM STRING_SPLIT(ISNULL(@TaskIDs, ''), ',')
        WHERE TRY_CAST(value AS BIGINT) IS NOT NULL
    )
    SELECT
        tl.TaskID,
        h.HistoryID,
        h.TaskParentID,
        h.EmployeeID,
        ISNULL(h.ActualKPI, 0) AS ActualKPI,
        h.StartDate,
        h.EndDate,
        ISNULL(h.Progress, 0) AS Progress,
        ISNULL(h.AssignPriority, 3) AS AssignPriority,
        ISNULL(h.Status, N'Pending') AS Status
    FROM TaskList tl
    OUTER APPLY (
        SELECT TOP 1 * FROM tblTask_AssignHistory ah
        WHERE ah.TaskID = tl.TaskID AND ah.EmployeeID = @EmployeeID
        ORDER BY ah.StartDate DESC, ah.HistoryID DESC
    ) h;
END
GO
--Begin script: sp_Task_UpdateName
USE Paradise_Beta_Tai2
GO
if object_id('[dbo].[sp_Task_UpdateName]') is null
	EXEC ('CREATE PROCEDURE [dbo].[sp_Task_UpdateName] as select 1')
GO
ALTER PROCEDURE [dbo].[sp_Task_UpdateName]
    @TaskID BIGINT,
    @NewName NVARCHAR(500),
    @LoginID INT = NULL
AS
BEGIN
    SET NOCOUNT ON;
    IF @TaskID IS NULL OR LTRIM(RTRIM(ISNULL(@NewName,''))) = ''
    BEGIN
        SELECT 0 AS Success, N'Invalid parameters' AS Message;
        RETURN;
    END

    BEGIN TRY
        -- Optional: permission check (if LoginID provided)
        IF @LoginID IS NOT NULL
        BEGIN
            DECLARE @EmpIDCheck VARCHAR(20) = (SELECT EmployeeID FROM tblSC_Login WHERE LoginID = @LoginID);
            -- If you have role/permission table, check here. Currently just ensure Login exists.
            IF @EmpIDCheck IS NULL
            BEGIN
                SELECT 0 AS Success, N'Người thực hiện không hợp lệ' AS Message; RETURN;
            END
        END

        UPDATE dbo.tblTask
        SET TaskName = @NewName
        WHERE TaskID = @TaskID;

        IF @@ROWCOUNT = 0
        BEGIN
            SELECT 0 AS Success, N'Task không tồn tại' AS Message; RETURN;
        END

        SELECT 1 AS Success, N'Cập nhật tên công việc thành công' AS Message;
    END TRY
    BEGIN CATCH
        SELECT 0 AS Success, ERROR_MESSAGE() AS Message;
    END CATCH
END
GO
--Begin script: sp_Task_SaveTaskRelations
USE Paradise_Beta_Tai2
GO
if object_id('[dbo].[sp_Task_SaveTaskRelations]') is null
	EXEC ('CREATE PROCEDURE [dbo].[sp_Task_SaveTaskRelations] as select 1')
GO

ALTER PROCEDURE [dbo].[sp_Task_SaveTaskRelations]
    @ParentTaskID INT = 9,
    @ChildTaskIDs VARCHAR(MAX) = '10,11,12,13,14,15'-- Chuỗi dạng '1,2,3'
AS
BEGIN
    SET NOCOUNT ON;

    -- BƯỚC 1: Tạo bảng tạm chứa danh sách ChildTaskID muốn thêm
    DECLARE @TempChildTasks TABLE (ChildTaskID BIGINT);

    IF @ChildTaskIDs IS NOT NULL AND LTRIM(RTRIM(@ChildTaskIDs)) <> ''
    BEGIN
        INSERT INTO @TempChildTasks (ChildTaskID)
        SELECT CAST(value AS BIGINT)
        FROM STRING_SPLIT(@ChildTaskIDs, ',')
        WHERE LTRIM(RTRIM(value)) <> '';
    END

    -- BƯỚC 2: KIỂM TRA ĐIỀU KIỆN CẤM DUY NHẤT: Task con có PositionID (task cố định theo chức vụ)
    DECLARE @InvalidFixedTasks TABLE (
        TaskID BIGINT,
        TaskName NVARCHAR(500),
        PositionID VARCHAR(50),
        Reason NVARCHAR(200)
    );

    INSERT INTO @InvalidFixedTasks (TaskID, TaskName, PositionID, Reason)
    SELECT
        T.TaskID,
        T.TaskName,
        T.PositionID,
        N'Task cố định theo chức vụ: ' + ISNULL(T.PositionID, '')
    FROM tblTask T
    INNER JOIN @TempChildTasks TCT ON T.TaskID = TCT.ChildTaskID
    WHERE NULLIF(LTRIM(RTRIM(T.PositionID)), '') IS NOT NULL;

    -- NẾU CÓ VI PHẠM → TRẢ VỀ LỖI
    IF EXISTS (SELECT 1 FROM @InvalidFixedTasks)
    BEGIN
        DECLARE @ErrorMessage NVARCHAR(MAX) = N'';

        SELECT @ErrorMessage = @ErrorMessage +
            N' [' + TaskName + N'] - ' + Reason + CHAR(13) + CHAR(10)
        FROM @InvalidFixedTasks;

        SET @ErrorMessage =
            N' KHÔNG THỂ THÊM TASK CON!' + CHAR(13) + CHAR(10) +
            N'Các task sau KHÔNG được phép làm task con:' + CHAR(13) + CHAR(10) + CHAR(13) + CHAR(10) +
            @ErrorMessage + CHAR(13) + CHAR(10) +
            N' Lý do: Task cố định theo chức vụ sẽ bị trùng lặp nếu làm task con.';

        SELECT
            0 AS Success,
            @ErrorMessage AS ErrorMessage,
            TaskID,
            TaskName,
            Reason
        FROM @InvalidFixedTasks;

        RETURN;
    END

    -- BƯỚC 3: XÓA QUAN HỆ CŨ
    DELETE FROM tblTask_Template WHERE ParentTaskID = @ParentTaskID;

    -- BƯỚC 4: THÊM QUAN HỆ MỚI (Nếu có)
    IF EXISTS (SELECT 1 FROM @TempChildTasks)
    BEGIN
        INSERT INTO tblTask_Template (ParentTaskID, ChildTaskID)
        SELECT @ParentTaskID, ChildTaskID
        FROM @TempChildTasks;
    END

    -- BƯỚC 5: TRẢ VỀ KẾT QUẢ THÀNH CÔNG
    SELECT
        1 AS Success,
        N'Lưu quan hệ task con thành công!' AS Message,
        @ParentTaskID AS ParentTaskID,
        (SELECT COUNT(*) FROM @TempChildTasks) AS TotalChildren;
END
GO
--Begin script: sp_Task_GetAllTasks
USE Paradise_Beta_Tai2
GO
if object_id('[dbo].[sp_Task_GetAllTasks]') is null
	EXEC ('CREATE PROCEDURE [dbo].[sp_Task_GetAllTasks] as select 1')
GO
ALTER PROCEDURE [dbo].[sp_Task_GetAllTasks]
    @LoginID INT = 59
AS
BEGIN
    SELECT
        T.TaskID,
        T.TaskName,
        T.PositionID AS PositionID,
        STUFF((
            SELECT ', ' + P.PositionName
            FROM STRING_SPLIT(T.PositionID, ',') S
            INNER JOIN dbo.tblPosition P ON P.PositionID = S.value
            FOR XML PATH(''), TYPE
        ).value('.', 'nvarchar(max)'), 1, 2, '') AS PositionNames,
        ISNULL(T.KPIPerDay, 0) AS DefaultKPI,
        T.Unit,
        ISNULL(T.Priority, 0) AS Priority,
        T.Status,
        '' AS Description,
        -- 👇 Trả về ParentTaskID thực tế từ tblTask_Template (nếu có)
        TT.ParentTaskID,
        CASE
            WHEN TT.ParentTaskID IS NOT NULL THEN (SELECT TaskName FROM tblTask WHERE TaskID = TT.ParentTaskID)
            ELSE NULL
        END AS ParentTaskName
    FROM tblTask T
    LEFT JOIN tblTask_Template TT ON TT.ChildTaskID = T.TaskID
    WHERE T.Status != 5
    ORDER BY T.TaskID DESC
END
GO
--Begin script: sp_Task_SaveTask
USE Paradise_Beta_Tai2
GO
if object_id('[dbo].[sp_Task_SaveTask]') is null
	EXEC ('CREATE PROCEDURE [dbo].[sp_Task_SaveTask] as select 1')
GO

ALTER PROCEDURE [dbo].[sp_Task_SaveTask]
    @TaskID      BIGINT OUTPUT,  -- OUTPUT parameter để trả về ID
    @TaskName    NVARCHAR(500),
    @Description NVARCHAR(MAX) = NULL,
    @PositionID  VARCHAR(200),
    @DefaultKPI  DECIMAL(8,2),
    @Unit        NVARCHAR(50),
    @Status      TINYINT,
    @Priority    TINYINT = NULL
AS
BEGIN
    SET NOCOUNT ON;

    -- KIỂM TRA ĐÚNG: TaskID = 0 hoặc NULL = TẠO MỚI
    IF @TaskID = 0 OR @TaskID IS NULL
    BEGIN
        -- TẠO MỚI TASK
        INSERT INTO tblTask (
            TaskName,
            PositionID,
            KPIPerDay,
            Unit,
            Status,
            Priority
        )
        VALUES (
            @TaskName,
            @PositionID,
            @DefaultKPI,
            @Unit,
            @Status,
            ISNULL(@Priority, 3)  -- Mặc định priority = 3 (Thấp)
        );

        -- LẤY ID MỚI VÀ GÁN VÀO OUTPUT PARAMETER
        SET @TaskID = SCOPE_IDENTITY();

        -- TRẢ VỀ TaskID mới cho client
        SELECT @TaskID AS TaskID, 'Created' AS Action;
    END
    ELSE
    BEGIN
        -- CẬP NHẬT TASK HIỆN CÓ
        UPDATE tblTask
        SET
            TaskName = @TaskName,
            PositionID = @PositionID,
            KPIPerDay = @DefaultKPI,
            Unit = @Unit,
            Status = @Status,
            Priority = ISNULL(@Priority, Priority)
        WHERE TaskID = @TaskID;

        -- TRẢ VỀ TaskID đã cập nhật
        SELECT @TaskID AS TaskID, 'Updated' AS Action;
    END
END
GO
--Begin script: sp_Task_PopulateAssignHistoryForLogin
USE Paradise_Beta_Tai2
GO
if object_id('[dbo].[sp_Task_PopulateAssignHistoryForLogin]') is null
	EXEC ('CREATE PROCEDURE [dbo].[sp_Task_PopulateAssignHistoryForLogin] as select 1')
GO

ALTER PROCEDURE [dbo].[sp_Task_PopulateAssignHistoryForLogin]
    @LoginID INT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @EmployeeID VARCHAR(20)
    DECLARE @CurrentPositions VARCHAR(500)
    DECLARE @Today DATE = CAST(GETDATE() AS DATE)
    -- Thêm biến cho StartDate và EndDate với giờ cụ thể
    DECLARE @StartDateTime DATETIME
    DECLARE @EndDateTime DATETIME

    SELECT @EmployeeID = EmployeeID
    FROM tblSC_Login
    WHERE LoginID = @LoginID

    IF @EmployeeID IS NULL RETURN

    SELECT TOP 1 @CurrentPositions = PositionID
    FROM dbo.fn_vtblEmployeeList_Bydate(@Today, '-1', NULL)
    WHERE EmployeeID = @EmployeeID

    IF @CurrentPositions IS NULL OR LTRIM(RTRIM(@CurrentPositions)) = '' RETURN

    -- Thiết lập thời gian bắt đầu: 00:00:01 và kết thúc: 23:59:59
    SET @StartDateTime = CAST(CAST(@Today AS VARCHAR(10)) + ' 00:00:01' AS DATETIME)
    SET @EndDateTime = CAST(CAST(@Today AS VARCHAR(10)) + ' 23:59:59' AS DATETIME)

    DECLARE @PosPattern VARCHAR(502) = '%,' + REPLACE(@CurrentPositions, ' ', '') + ',%'

        -- Chỉ giao task CỐ ĐỊNH (PositionID IS NOT NULL)
        -- VÀ LUÔN tạo mới mỗi ngày (không kiểm tra tồn tại trong ngày)
        INSERT INTO tblTask_AssignHistory (
            TaskParentID, EmployeeID, TaskID, StartDate, EndDate, Status, Progress, ActualKPI, CommittedHours
        )
        SELECT
                NULL,
                @EmployeeID,
                T.TaskID,
                @StartDateTime,  -- Sử dụng datetime với giờ 00:00:01
                @EndDateTime,    -- Sử dụng datetime với giờ 23:59:59
                N'Pending',
                0,
                0,
                NULL
        FROM tblTask T
        WHERE T.Status = 1
            AND T.PositionID IS NOT NULL
            AND ',' + REPLACE(T.PositionID, ' ', '') + ',' LIKE @PosPattern
            AND NOT EXISTS (
                        -- Đảm bảo không giao TRÙNG trong CÙNG NGÀY
                        SELECT 1
                        FROM tblTask_AssignHistory H
                        WHERE H.TaskID = T.TaskID
                            AND H.EmployeeID = @EmployeeID
                            AND CAST(H.StartDate AS DATE) = @Today
            )
END
GO
--Begin script: sp_Task_UpdateKPI
USE Paradise_Beta_Tai2
GO
if object_id('[dbo].[sp_Task_UpdateKPI]') is null
	EXEC ('CREATE PROCEDURE [dbo].[sp_Task_UpdateKPI] as select 1')
GO
ALTER PROCEDURE [dbo].[sp_Task_UpdateKPI]
    @TaskID     BIGINT,
    @LoginID    INT,
    @ActualKPI  DECIMAL(18,2),
    @Note       NVARCHAR(MAX) = ''
AS
BEGIN
    DECLARE @EmployeeID VARCHAR(20);
    SELECT @EmployeeID = EmployeeID FROM tblSC_Login WHERE LoginID = @LoginID;

    DECLARE @Target DECIMAL(18,2) = (SELECT ISNULL(KPIPerDay, 0) FROM tblTask WHERE TaskID = @TaskID);
    DECLARE @NewProgress INT = 0;
    IF @Target > 0 SET @NewProgress = CAST((@ActualKPI / @Target) * 100 AS INT);

    MERGE tblTask_AssignHistory AS target
    USING (SELECT @TaskID AS TaskID, @EmployeeID AS EmployeeID) AS source
    ON (target.TaskID = source.TaskID AND target.EmployeeID = source.EmployeeID)
    WHEN MATCHED THEN
        UPDATE SET
            ActualKPI = @ActualKPI,
            Progress = @NewProgress,
            -- ❌ XÓA DÒNG NÀY → KHÔNG TỰ ĐỘNG ĐỔI TRẠNG THÁI
            -- Status = N'Đang làm',
            EndDate = GETDATE()
    WHEN NOT MATCHED THEN
        INSERT (TaskID, EmployeeID, ActualKPI, Progress, Status, EndDate)
        VALUES (@TaskID, @EmployeeID, @ActualKPI, @NewProgress, N'Pending', GETDATE());

    IF @Note <> ''
    BEGIN
        INSERT INTO tblTask_Comment (TaskID, EmployeeID, Content, CreatedDate)
        VALUES (@TaskID, @EmployeeID, @Note, GETDATE());
    END
END
GO
--Begin script: sp_Task_UpdateStatus
USE Paradise_Beta_Tai2
GO
if object_id('[dbo].[sp_Task_UpdateStatus]') is null
	EXEC ('CREATE PROCEDURE [dbo].[sp_Task_UpdateStatus] as select 1')
GO

-- 4. Sửa sp_Task_UpdateStatus: CHỈ cập nhật AssignHistory, KHÔNG cập nhật tblTask.Status
ALTER PROCEDURE [dbo].[sp_Task_UpdateStatus]
    @TaskID BIGINT,
    @LoginID INT,
    @NewStatus INT -- 1, 2, 3
AS
BEGIN
    DECLARE @StatusText NVARCHAR(50) = CASE
        WHEN @NewStatus = 1 THEN N'Pending'
        WHEN @NewStatus = 2 THEN N'Doing'
        WHEN @NewStatus = 3 THEN N'Done'
        ELSE N'Pending'
    END;

    DECLARE @EmployeeID VARCHAR(20);
    SELECT @EmployeeID = EmployeeID FROM tblSC_Login WHERE LoginID = @LoginID;

    UPDATE tblTask_AssignHistory
    SET Status = @StatusText
    WHERE TaskID = @TaskID AND EmployeeID = @EmployeeID;
END
GO
--Begin script: sp_Task_UpdateTaskStatus
USE Paradise_Beta_Tai2
GO
if object_id('[dbo].[sp_Task_UpdateTaskStatus]') is null
	EXEC ('CREATE PROCEDURE [dbo].[sp_Task_UpdateTaskStatus] as select 1')
GO

ALTER PROCEDURE [dbo].[sp_Task_UpdateTaskStatus]
    @TaskID BIGINT,
    @NewStatus TINYINT
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE tblTask
    SET Status = @NewStatus
    WHERE TaskID = @TaskID;

    -- Also update in AssignHistory if exists
    UPDATE tblTask_AssignHistory
    SET Status = CASE @NewStatus
        WHEN 1 THEN N'Chưa làm'
        WHEN 2 THEN N'Đang làm'
        WHEN 3 THEN N'Hoàn thành'
        ELSE N'Chưa làm'
    END
    WHERE TaskID = @TaskID;
END
GO
--Begin script: sp_Task_UpdateField
USE Paradise_Beta_Tai2
GO
if object_id('[dbo].[sp_Task_UpdateField]') is null
	EXEC ('CREATE PROCEDURE [dbo].[sp_Task_UpdateField] as select 1')
GO

ALTER PROCEDURE [dbo].[sp_Task_UpdateField]
    @TaskID BIGINT,
    @TaskName NVARCHAR(500) = NULL,
    @PositionID VARCHAR(200) = NULL,
    @DefaultKPI DECIMAL(8,2) = NULL,
    @Unit NVARCHAR(50) = NULL,
    @Priority TINYINT = NULL
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE tblTask
    SET
        TaskName = ISNULL(@TaskName, TaskName),
        KPIPerDay = ISNULL(@DefaultKPI, KPIPerDay),
        Unit = ISNULL(@Unit, Unit),
        Priority = ISNULL(@Priority, Priority)
    WHERE TaskID = @TaskID;

    -- If PositionID provided, update single-column PositionID in tblTask
    IF @PositionID IS NOT NULL
    BEGIN
        UPDATE tblTask SET PositionID = @PositionID WHERE TaskID = @TaskID;
    END
END
GO
--Begin script: sp_Task_DeleteTask
USE Paradise_Beta_Tai2
GO
if object_id('[dbo].[sp_Task_DeleteTask]') is null
	EXEC ('CREATE PROCEDURE [dbo].[sp_Task_DeleteTask] as select 1')
GO

-- 4. Xóa công việc (Soft Delete)
ALTER PROCEDURE [dbo].[sp_Task_DeleteTask]
    @TaskID BIGINT
AS
BEGIN
    -- Xóa quan hệ cha con trước
    DELETE FROM tblTask_Template WHERE ParentTaskID = @TaskID OR ChildTaskID = @TaskID;

    -- Cập nhật trạng thái thành 5 (Xóa) hoặc DELETE hẳn tùy bạn
    DELETE FROM tblTask WHERE TaskID = @TaskID;
END
GO
--Begin script: sp_Task_GetPositions
USE Paradise_Beta_Tai2
GO
if object_id('[dbo].[sp_Task_GetPositions]') is null
	EXEC ('CREATE PROCEDURE [dbo].[sp_Task_GetPositions] as select 1')
GO

-- 1. Lấy danh sách chức vụ (Dùng cho dropdown Position)
ALTER PROCEDURE [dbo].[sp_Task_GetPositions]
    @LoginID INT = NULL
AS
BEGIN
    -- Lấy dữ liệu vị trí từ bảng `tblPosition`
    -- Yêu cầu: bảng `tblPosition` phải tồn tại với các cột `PositionID`, `PositionName`, `Status`
    IF OBJECT_ID('dbo.tblPosition') IS NOT NULL
    BEGIN
        SELECT PositionID, PositionName
        FROM dbo.tblPosition
        ORDER BY PositionName;
    END
    ELSE
    BEGIN
        -- Fallback: nếu không có bảng tblPosition, lấy distinct từ tblTask như trước
        SELECT DISTINCT
            PositionID,
            PositionID AS PositionName,
            1 AS Status
        FROM tblTask WHERE PositionID IS NOT NULL
        ORDER BY PositionID;
    END
END
GO
--Begin script: sp_Task_GetTaskRelations
USE Paradise_Beta_Tai2
GO
if object_id('[dbo].[sp_Task_GetTaskRelations]') is null
	EXEC ('CREATE PROCEDURE [dbo].[sp_Task_GetTaskRelations] as select 1')
GO

-- 5. Lấy danh sách Task con (Relations)
ALTER PROCEDURE [dbo].[sp_Task_GetTaskRelations]
    @ParentTaskID BIGINT = 5
AS
BEGIN
    SELECT ChildTaskID
    FROM tblTask_Template
    WHERE ParentTaskID = @ParentTaskID;
END
GO