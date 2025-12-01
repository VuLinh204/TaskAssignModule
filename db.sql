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
