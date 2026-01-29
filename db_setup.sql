USE Paradise_Dev
GO

-- 1. Table Projects
IF OBJECT_ID('tblTask_Projects', 'U') IS NULL
BEGIN
    CREATE TABLE tblTask_Projects (
        ProjectID INT IDENTITY(1,1) PRIMARY KEY,
        ProjectName NVARCHAR(255) NOT NULL,
        Description NVARCHAR(MAX),
        OwnerID NVARCHAR(20),
        StartDate DATE,
        EndDate DATE,
        Status NVARCHAR(50),
        Priority NVARCHAR(20),
        dDate DATETIME DEFAULT GETDATE(),
        ModifiedDate DATETIME DEFAULT GETDATE()
    );
END
GO

-- 2. Table Tags
IF OBJECT_ID('tblTask_Tags', 'U') IS NULL
BEGIN
    CREATE TABLE tblTask_Tags (
        TagID INT IDENTITY(1,1) PRIMARY KEY,
        TagName NVARCHAR(50) NOT NULL,
        Color NVARCHAR(20) DEFAULT '#6c757d'
    );
END
GO

-- 3. Table Tasks
IF OBJECT_ID('tblTask_Tasks', 'U') IS NULL
BEGIN
    CREATE TABLE tblTask_Tasks (
        TaskID INT IDENTITY(1,1) PRIMARY KEY,
        ProjectID INT NOT NULL,
        TaskName NVARCHAR(255) NOT NULL,
        Description NVARCHAR(MAX),
        AssigneeID NVARCHAR(20),
        dBy NVARCHAR(20),
        ParentTaskID INT,
        StartDate DATE,
        DueDate DATE,
        Status NVARCHAR(50),
        Priority NVARCHAR(20),
        dDate DATETIME DEFAULT GETDATE(),
        ModifiedDate DATETIME DEFAULT GETDATE()
    );
END
GO

-- 4. Table Task - Tag mapping
IF OBJECT_ID('tblTask_TaskTags', 'U') IS NULL
BEGIN
    CREATE TABLE tblTask_TaskTags (
        TaskID INT NOT NULL,
        TagID INT NOT NULL,
        PRIMARY KEY (TaskID, TagID)
    );
END
GO

-- 5. Table Task Processes (History)
IF OBJECT_ID('tblTask_TaskProcesses', 'U') IS NULL
BEGIN
    CREATE TABLE tblTask_TaskProcesses (
        ProcessID INT IDENTITY(1,1) PRIMARY KEY,
        TaskID INT NOT NULL,
        OldStatus NVARCHAR(50) NOT NULL,
        NewStatus NVARCHAR(50) NOT NULL,
        ChangedBy NVARCHAR(20) NOT NULL,
        ChangedDate DATETIME DEFAULT GETDATE()
    );
END
GO

-- 6. Table Comments
IF OBJECT_ID('tblTask_Comments', 'U') IS NULL
BEGIN
    CREATE TABLE tblTask_Comments (
        CommentID INT IDENTITY(1,1) PRIMARY KEY,
        TaskID INT NOT NULL,
        EmployeeID NVARCHAR(20) NOT NULL,
        Comment NVARCHAR(MAX) NOT NULL,
        dDate DATETIME DEFAULT GETDATE()
    );
END
GO

-- SEED DATA (Exclude Employees and Positions as they already exist)
IF NOT EXISTS (SELECT 1 FROM tblTask_Projects)
BEGIN
    -- Note: OwnerID '001' is used as a placeholder. Ensure this matches an existing employee ID.
    INSERT INTO tblTask_Projects (ProjectName, Description, OwnerID, StartDate, EndDate, Status, Priority) VALUES
    (N'Phoenix Project', N'A major overhaul of the legacy system.', '001', '2024-01-01', '2024-12-31', 'In Progress', 'High'),
    (N'Mobile App Launch', N'Develop and launch the new mobile application.', '001', '2024-03-01', '2024-09-30', 'On Track', 'High'),
    (N'Marketing Website', N'Redesign the company marketing website.', '001', '2024-05-01', '2024-08-01', 'Completed', 'Medium');
END

IF NOT EXISTS (SELECT 1 FROM tblTask_Tags)
BEGIN
    INSERT INTO tblTask_Tags (TagName, Color) VALUES 
    (N'Bug', '#ef4444'), (N'Feature', '#3b82f6'), (N'UI', '#a855f7'), (N'Backend', '#f97316');
END
GO
