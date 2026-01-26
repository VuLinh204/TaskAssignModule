tblTask
ColumnName	DataType	MaxLength	IsNullable
TaskID	bigint	NULL	NO
TaskName	nvarchar	500	NO
PositionID	varchar	50	YES
Status	tinyint	NULL	YES
KPIPerDay	decimal	NULL	YES
Unit	nvarchar	50	YES
DepartmentID	varchar	50	YES

tblTask_AssignHistory
ColumnName	DataType	MaxLength	IsNullable
HistoryID	bigint	NULL	NO
HeaderID	int	NULL	YES
EmployeeID	varchar	-1	YES
TaskID	bigint	NULL	YES
ActualKPI	decimal	NULL	YES
Progress	int	NULL	YES
Status	int	NULL	YES
StartDate	datetime	NULL	YES
AssignPriority	tinyint	NULL	YES
CommittedHours	float	NULL	YES
EndDate	datetime	NULL	YES
Description	nvarchar	-1	YES

tblTask_AssignHeader
ColumnName	DataType	MaxLength	IsNullable
HeaderID	int	NULL	NO
HeaderTitle	nvarchar	255	YES
StartDate	datetime	NULL	YES
PersonInCharge	varchar	100	YES
Note	nvarchar	500	YES
CommittedHours	float	NULL	YES
TaskParentID	int	NULL	YES
MainPersonInCharge	varchar	100	YES

tblTask_Template
ColumnName	DataType	MaxLength	IsNullable
ParentTaskID	bigint	NULL	YES
ChildTaskID	bigint	NULL	YES

