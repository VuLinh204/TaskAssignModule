USE Paradise_Beta_Tai2
GO
IF OBJECT_ID('[dbo].[sp_Task_TaskDetail_html]') IS NULL
    EXEC ('CREATE PROCEDURE [dbo].[sp_Task_TaskDetail_html] AS SELECT 1')
GO

ALTER PROCEDURE [dbo].[sp_Task_TaskDetail_html]
    @LoginID    INT = 59,
    @LanguageID VARCHAR(2) = 'VN',
    @isWeb      INT = 1,
    @TaskID     INT = NULL
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @html NVARCHAR(MAX);
    SET @html = N'
    <style>
        :root {
            --task-primary: #2E7D32;
            --task-primary-hover: #1c975e;
            --border-color: #e8eaed;
            --text-primary: #1a1a1a;
            --text-secondary: #676879;
            --text-muted: #87909e;
            --bg-white: #ffffff;
            --bg-light: #f8f9fa;
            --shadow-sm: 0 1px 3px rgba(0, 0, 0, 0.02);
            --shadow-md: 0 4px 16px rgba(0, 0, 0, 0.08);
            --radius-md: 8px;
            --radius-lg: 12px;
        }

        #sp_Task_TaskDetail_html {
            max-width: 1400px;
            margin: 0 auto;
            padding: 24px;
            background: var(--bg-light);
            min-height: 100vh;
            font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif;
        }

        .detail-header { display: flex; align-items: center; gap: 16px; margin-bottom: 24px; padding: 20px; background: white; border-radius: var(--radius-lg); box-shadow: var(--shadow-sm); }
        .btn-back { padding: 10px 18px; border: 1px solid var(--border-color); border-radius: var(--radius-md); background: white; cursor: pointer; display: flex; align-items: center; gap: 8px; transition: all 0.2s; font-weight: 600; }
        .btn-back:hover { background: var(--task-primary); color: white; border-color: var(--task-primary); transform: translateX(-4px); }
        .task-title-section { flex: 1; display: flex; flex-direction: column; gap: 8px; }
        .task-title-edit { font-size: 28px; font-weight: 700; color: var(--text-primary); line-height: 1.2; }
        .task-meta-quick { display: flex; gap: 16px; align-items: center; font-size: 13px; color: var(--text-secondary); }
        .task-meta-quick > span { display: flex; align-items: center; gap: 4px; }
        .detail-actions { display: flex; gap: 8px; align-items: center; }
        .btn-action { padding: 10px 16px; border-radius: var(--radius-md); border: 1px solid var(--border-color); background: white; cursor: pointer; transition: all 0.2s; font-weight: 600; display: flex; align-items: center; gap: 8px; }
        .btn-action:hover { background: var(--task-primary); color: white; border-color: var(--task-primary); }

        .detail-body { display: grid; grid-template-columns: 1fr 380px; gap: 24px; }
        .main-content { display: flex; flex-direction: column; gap: 24px; }
        .detail-section { background: white; border: 1px solid var(--border-color); border-radius: var(--radius-lg); padding: 24px; box-shadow: var(--shadow-sm); }
        .section-title { font-size: 18px; font-weight: 700; margin-bottom: 20px; color: var(--text-primary); display: flex; align-items: center; gap: 10px; padding-bottom: 12px; border-bottom: 2px solid var(--border-color); }
        .meta-grid { display: grid; grid-template-columns: repeat(2, 1fr); gap: 20px; }
        .meta-item { display: flex; flex-direction: column; gap: 8px; padding: 12px; background: var(--bg-light); border-radius: var(--radius-md); }
        .meta-label { font-size: 11px; font-weight: 700; color: var(--text-secondary); text-transform: uppercase; letter-spacing: 0.5px; }
        .meta-value { font-size: 15px; color: var(--text-primary); font-weight: 600; }

        .kpi-section { display: flex; justify-content: space-between; align-items: center; padding: 24px; background: linear-gradient(135deg, #e8f5e9 0%, #f1f8e9 100%); border-radius: var(--radius-lg); border: 2px solid var(--task-primary); }
        .kpi-display { display: flex; flex-direction: column; gap: 8px; }
        .kpi-current { font-size: 48px; font-weight: 800; color: var(--task-primary); line-height: 1; }
        .kpi-target { font-size: 14px; color: var(--text-secondary); font-weight: 600; }
        .kpi-progress-bar { height: 8px; background: rgba(255,255,255,0.5); border-radius: 4px; overflow: hidden; margin-top: 8px; }
        .kpi-progress-fill { height: 100%; background: var(--task-primary); transition: width 0.6s cubic-bezier(0.4, 0, 0.2, 1); }
        .kpi-input-group { display: flex; gap: 12px; align-items: center; }

        .sidebar { display: flex; flex-direction: column; gap: 24px; }

        @media (max-width: 1024px) { .detail-body { grid-template-columns: 1fr; } }
        @media (max-width: 768px) { 
            #sp_Task_TaskDetail_html { padding: 12px; } 
            .meta-grid { grid-template-columns: 1fr; } 
            .kpi-section { flex-direction: column; align-items: flex-start; gap: 16px; } 
            .task-title-edit { font-size: 20px; } 
        }
    </style>

    <div id="sp_Task_TaskDetail_html">
        <div class="detail-header">
            <button class="btn-back" id="btnBack">
                <i class="bi bi-arrow-left"></i> Quay lại
            </button>
            <div class="task-title-section">
                <div id="detailTaskName" style="font-size:28px;font-weight:700;"></div>
                <div class="task-meta-quick">
                    <span><i class="bi bi-hash"></i><span id="quickTaskID">-</span></span>
                    <span><i class="bi bi-calendar3"></i><span id="quickCreatedDate">-</span></span>
                    <span><i class="bi bi-person"></i><span id="quickCreatedBy">-</span></span>
                </div>
            </div>
            <div class="detail-actions">
                <div id="statusControlWrapper" style="min-width:180px;"></div>
                <button class="btn-action" id="btnRefreshDetail" title="Tải lại">
                    <i class="bi bi-arrow-clockwise"></i>
                </button>
            </div>
        </div>

        <div class="detail-body">
            <div class="main-content">
                <!-- Meta Info -->
                <div class="detail-section">
                    <div class="section-title"><i class="bi bi-info-circle-fill"></i> Thông tin chi tiết</div>
                    <div class="meta-grid">
                        <div class="meta-item">
                            <div class="meta-label">Độ ưu tiên</div>
                            <div class="meta-value" id="priorityField"></div>
                        </div>
                        <div class="meta-item">
                            <div class="meta-label">Ngày bắt đầu</div>
                            <div class="meta-value" id="startDateField"></div>
                        </div>
                        <div class="meta-item">
                            <div class="meta-label">Hạn hoàn thành</div>
                            <div class="meta-value" id="dueDateField"></div>
                        </div>
                        <div class="meta-item">
                            <div class="meta-label">Thời gian cam kết</div>
                            <div class="meta-value" id="committedHoursField"></div>
                        </div>
                        <div class="meta-item">
                            <div class="meta-label">Người yêu cầu</div>
                            <div class="meta-value" id="requestedByField"></div>
                        </div>
                        <div class="meta-item">
                            <div class="meta-label">Chịu trách nhiệm chính</div>
                            <div class="meta-value" id="mainResponsibleField"></div>
                        </div>
                    </div>
                </div>

                <!-- Description -->
                <div class="detail-section">
                    <div class="section-title"><i class="bi bi-file-text-fill"></i> Mô tả công việc</div>
                    <div id="detailDescription" style="min-height:120px;"></div>
                </div>

                <!-- KPI Section -->
                <div class="detail-section">
                    <div class="section-title"><i class="bi bi-graph-up-arrow"></i> Tiến độ KPI</div>
                    <div class="kpi-section">
                        <div class="kpi-display">
                            <div class="kpi-current" id="kpiCurrent">0</div>
                            <div class="kpi-target" id="kpiTarget">Target: 0</div>
                            <div style="display:flex;justify-content:space-between;margin-bottom:4px;">
                                <span style="font-size:12px;font-weight:600;color:var(--text-secondary);">Hoàn thành:</span>
                                <span style="font-size:12px;font-weight:700;color:var(--task-primary);" id="kpiPercent">0%</span>
                            </div>
                            <div class="kpi-progress-bar">
                                <div class="kpi-progress-fill" id="kpiProgressFill" style="width:0%"></div>
                            </div>
                        </div>
                        <div class="kpi-input-group">
                            <div id="txtUpdateKPI" style="width:160px;"></div>
                            <button class="btn-action" id="btnUpdateKPI"><i class="bi bi-check-lg"></i> Cập nhật</button>
                        </div>
                    </div>
                </div>

                <!-- Subtasks -->
                <div class="detail-section" style="min-height:500px;">
                    <div class="section-title"><i class="bi bi-list-check"></i> Công việc con</div>
                    <div id="SubtasksGrid" style="height:calc(100% - 40px);"></div>
                </div>
            </div>

            <div class="sidebar">
                <!-- Assignees -->
                <div class="detail-section">
                    <div class="section-title"><i class="bi bi-people-fill"></i> Người thực hiện</div>
                    <div id="assigneeContainer" style="min-height:80px;"></div>
                </div>

                <!-- Comments -->
                <div class="detail-section" style="min-height:500px;">
                    <div class="section-title"><i class="bi bi-chat-dots-fill"></i> Bình luận</div>
                    <div id="CommentsGrid" style="height:calc(100% - 40px);"></div>
                </div>
            </div>
        </div>
    </div>
        
   
    <script>
        (() => {
            let currentRecordID
            let DataSource = []
            '
+(select loadUI from tblCommonControlType_Signed where ID = 281)
+(select loadUI from tblCommonControlType_Signed where ID = 282)
+(select loadUI from tblCommonControlType_Signed where ID = 283)
+(select loadUI from tblCommonControlType_Signed where ID = 284)
+(select loadUI from tblCommonControlType_Signed where ID = 285)
+(select loadUI from tblCommonControlType_Signed where ID = 286)
+(select loadUI from tblCommonControlType_Signed where ID = 287)
+(select loadUI from tblCommonControlType_Signed where ID = 288)
+(select loadUI from tblCommonControlType_Signed where ID = 289)
+(select loadUI from tblCommonControlType_Signed where ID = 290)
+(select loadUI from tblCommonControlType_Signed where ID = 291) +N'

            function ReloadData() {
                AjaxHPAParadise({
                    data: {
                        name: "sp_Task_GetDetail",
                        param: []
                    },
                    success: function (res) {
                        const json = typeof res === "string" ? JSON.parse(res) : res
                        const results = (json.data && json.data[0]) || []

                        if (0=== 1) {
                            Instance7DF00C507683491887B95CA71078A190.option("dataSource", results)
                        } else {
                            const obj = results[0]
                            currentRecordID = obj.TaskID || currentRecordID
                            DataSource = results
                            '
+(select loadData from tblCommonControlType_Signed where ID = 281)
+(select loadData from tblCommonControlType_Signed where ID = 282)
+(select loadData from tblCommonControlType_Signed where ID = 283)
+(select loadData from tblCommonControlType_Signed where ID = 284)
+(select loadData from tblCommonControlType_Signed where ID = 285)
+(select loadData from tblCommonControlType_Signed where ID = 286)
+(select loadData from tblCommonControlType_Signed where ID = 287)
+(select loadData from tblCommonControlType_Signed where ID = 288)
+(select loadData from tblCommonControlType_Signed where ID = 289)
+(select loadData from tblCommonControlType_Signed where ID = 290)
+(select loadData from tblCommonControlType_Signed where ID = 291) +N'
                        }
                    }
                })
            }
            sp_Task_TaskDetail_html.ReloadData = ReloadData
            ReloadData()
        })();
    </script>
	';
	SELECT @html AS html;
END
GO

EXEC sp_GenerateHTMLScript 'sp_Task_TaskDetail_html'