-- Bảng vị trí/chức vụ
TABLE tblPosition (
    PositionID INT IDENTITY(1,1) PRIMARY KEY,
    PositionName NVARCHAR(100) NOT NULL
);

tblPositionHistory -> 
EmployeeID	PositionID	EffectiveDate	Remark	LeveSalaryID	LoginID	ChangeCurrentDate
001	451	2021-07-09	NULL	NULL	NULL	NULL


-- Bảng nhân viên/người dùng 
TABLE tblEmployee (
    EmployeeID NVARCHAR PRIMARY KEY,
    FullName NVARCHAR(100) NOT NULL,
    Email NVARCHAR(100)
);

========
Cách lấy mã nhân viên hiện tại
DECLARE @EmployeeID VARCHAR(20)
SELECT @EmployeeID = EmployeeID
FROM tblSC_Login
WHERE LoginID = @LoginID


=================
Các bảng chưa có
-- Bảng dự án
 TABLE tblTask_Projects (
    ProjectID INT IDENTITY(1,1) PRIMARY KEY,
    ProjectName NVARCHAR(255) NOT NULL,
    Description NVARCHAR(MAX),
    OwnerID INT,
    StartDate DATE,
    EndDate DATE,
    Status NVARCHAR(50),
    Priority NVARCHAR(20),
    dDate DATETIME,
    ModifiedDate DATETIME
);

-- Bảng thẻ tag
 TABLE tblTask_Tags (
    TagID INT IDENTITY(1,1) PRIMARY KEY,
    TagName NVARCHAR(50) NOT NULL,
    Color NVARCHAR(20) DEFAULT '#6c757d'
);

-- Bảng công việc chính
 TABLE tblTask_Tasks (
    TaskID INT IDENTITY(1,1) PRIMARY KEY,
    ProjectID INT NOT NULL,
    TaskName NVARCHAR(255) NOT NULL,
    Description NVARCHAR(MAX),
    AssigneeID INT,
    dBy INT,
    ParentTaskID INT,
    StartDate DATE,
    DueDate DATE,
    Status NVARCHAR(50),
    Priority NVARCHAR(20),
    dDate DATETIME,
    ModifiedDate DATETIME
);

-- Bảng quan hệ nhiều-nhiều: Task - Tag
 TABLE tblTask_TaskTags (
    TaskID INT NOT NULL,
    TagID INT NOT NULL,
    PRIMARY KEY (TaskID, TagID)
);

-- Bảng lịch sử thay đổi trạng thái công việc
 TABLE tblTask_TaskProcesses (
    ProcessID INT IDENTITY(1,1) PRIMARY KEY,
    TaskID INT NOT NULL,
    OldStatus NVARCHAR(50) NOT NULL,
    NewStatus NVARCHAR(50) NOT NULL,
    ChangedBy INT NOT NULL,
    ChangedDate DATETIME
);

-- Bảng bình luận
TABLE tblTask_Comments (
    CommentID INT IDENTITY(1,1) PRIMARY KEY,
    TaskID INT NOT NULL,
    EmployeeID NVARCHAR NOT NULL,
    Comment NVARCHAR(MAX) NOT NULL,
    dDate DATETIME
);

