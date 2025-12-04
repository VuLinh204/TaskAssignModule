USE Paradise_Beta_Tai2
GO

-----------------------------------------
-- 1. tblTask
-----------------------------------------
IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE name='tblTask' AND schema_id = SCHEMA_ID('dbo'))
BEGIN
    CREATE TABLE dbo.tblTask (
		TaskID         BIGINT IDENTITY(1,1) PRIMARY KEY,
		TaskName       NVARCHAR(500) NOT NULL,
		PositionID     VARCHAR(50) NULL,           -- NULL = đột xuất
        Status         TINYINT NOT NULL DEFAULT 1, -- 1=Chưa làm, 2=Đang làm, 3=Hoàn thành
		Priority       TINYINT NULL,
		KPIPerDay      DECIMAL(8,2) NULL,          -- Bao nhiêu đơn/khách/hợp đồng... mỗi ngày công (VD: 2.0 = 1 ngày làm được 2 đơn)
		Unit           NVARCHAR(50) NULL,          -- "đơn", "khách", "cuộc gọi", "triệu", "hợp đồng"...
    );
END
GO

-- Migration: switch header linking to use TaskID (non-destructive migration)
-- 1) Add TaskID column to tblTask_AssignHeader (will be used to reference Parent TaskID)
IF COL_LENGTH('dbo.tblTask_AssignHeader','TaskID') IS NULL
BEGIN
    ALTER TABLE dbo.tblTask_AssignHeader ADD TaskID BIGINT NULL;
END

-- 2) In tblTask_AssignHistory: replace EndDate (datetime) with CommittedHours (float) as requested
IF COL_LENGTH('dbo.tblTask_AssignHistory','CommittedHours') IS NULL
BEGIN
    ALTER TABLE dbo.tblTask_AssignHistory ADD CommittedHours FLOAT NULL;
END

-- Ensure EndDate exists (keep start/end dates for history) — do NOT drop it
IF COL_LENGTH('dbo.tblTask_AssignHistory','EndDate') IS NULL
BEGIN
    ALTER TABLE dbo.tblTask_AssignHistory ADD EndDate DATETIME NULL;
END


-----------------------------------------
-- 2. tblTask_Template
-----------------------------------------
IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE name='tblTask_Template')
BEGIN
    CREATE TABLE dbo.tblTask_Template (
        ParentTaskID BIGINT,
        ChildTaskID  BIGINT,
        SortOrder    INT,
    );
END
GO

-----------------------------------------
-- 3. tblTask_AssignHeader
-----------------------------------------
IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE name='tblTask_AssignHeader')
BEGIN
    CREATE TABLE dbo.tblTask_AssignHeader (
        HeaderID       INT IDENTITY(1,1) PRIMARY KEY,
        HeaderTitle    NVARCHAR(255),
        StartDate      DATETIME,
        PersonInCharge VARCHAR(100),
        Note           NVARCHAR(500),
        CommittedHours FLOAT NULL -- Thời gian cam kết hoàn thành (giờ)
    );
END
GO

-----------------------------------------
-- 4. tblTask_AssignHistory
-----------------------------------------
IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE name='tblTask_AssignHistory')
BEGIN
    CREATE TABLE dbo.tblTask_AssignHistory (
        HistoryID   BIGINT IDENTITY(1,1) PRIMARY KEY,
        HeaderID    INT,
        EmployeeID  VARCHAR(20),
        TaskID      BIGINT,
        ActualKPI   DECIMAL(18,2),
        StartDate   DATETIME,
        EndDate     DATETIME,
        Progress    INT,
        AssignPriority    TINYINT,
        Status      NVARCHAR(50)
    );
END
GO

-- Safe rename: rename columns using sp_rename when appropriate so other scripts can reference the new names immediately.
-- 1) tblTask_AssignHeader: rename `TaskID` -> `TaskParentID` if TaskParentID doesn't exist but TaskID does
IF COL_LENGTH('dbo.tblTask_AssignHeader','TaskParentID') IS NULL AND COL_LENGTH('dbo.tblTask_AssignHeader','TaskID') IS NOT NULL
BEGIN
    EXEC sp_rename 'dbo.tblTask_AssignHeader.TaskID', 'TaskParentID', 'COLUMN';
END

-- 2) tblTask_AssignHistory: rename `HeaderID` -> `TaskParentID` if TaskParentID missing and HeaderID exists
IF COL_LENGTH('dbo.tblTask_AssignHistory','TaskParentID') IS NULL AND COL_LENGTH('dbo.tblTask_AssignHistory','HeaderID') IS NOT NULL
BEGIN
    EXEC sp_rename 'dbo.tblTask_AssignHistory.HeaderID', 'TaskParentID', 'COLUMN';
END

-- 3) Ensure CommittedHours exists in both tables (non-destructive)
IF COL_LENGTH('dbo.tblTask_AssignHeader','CommittedHours') IS NULL
BEGIN
    ALTER TABLE dbo.tblTask_AssignHeader ADD CommittedHours FLOAT NULL;
END

IF COL_LENGTH('dbo.tblTask_AssignHistory','CommittedHours') IS NULL
BEGIN
    ALTER TABLE dbo.tblTask_AssignHistory ADD CommittedHours FLOAT NULL;
END


-----------------------------------------
-- 5. tblTask_Comment
-----------------------------------------
IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE name='tblTask_Comment')
BEGIN
    CREATE TABLE dbo.tblTask_Comment (
        CommentID   BIGINT IDENTITY(1,1) PRIMARY KEY,
        TaskID      BIGINT,
        EmployeeID  VARCHAR(20),
        Content     NVARCHAR(MAX),
        ParentID    BIGINT,
        CreatedDate DATETIME
    );
END
GO

-----------------------------------------
-- 6. tblTask_Attachment
-----------------------------------------
IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE name='tblTask_Attachment')
BEGIN
    CREATE TABLE dbo.tblTask_Attachment (
        AttachID     BIGINT IDENTITY(1,1) PRIMARY KEY,
        TaskID       BIGINT,
        FileName     NVARCHAR(255),
        FilePath     NVARCHAR(1000),
        UploadedBy   VARCHAR(20),
        UploadedDate DATETIME
    );
END
GO
