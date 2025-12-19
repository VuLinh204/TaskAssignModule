USE Paradise_Beta_Tai2
GO
if object_id('[dbo].[sp_Task_TaskDetail_html]') is null
	EXEC ('CREATE PROCEDURE [dbo].[sp_Task_TaskDetail_html] as select 1')
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
        }

        /* Header */
        #sp_Task_TaskDetail_html .detail-header {
            display: flex;
            align-items: center;
            gap: 16px;
            margin-bottom: 24px;
            padding: 20px;
            background: white;
            border-radius: var(--radius-lg);
            box-shadow: var(--shadow-sm);
        }

        #sp_Task_TaskDetail_html .btn-back {
            padding: 10px 18px;
            border: 1px solid var(--border-color);
            border-radius: var(--radius-md);
            background: white;
            cursor: pointer;
            display: flex;
            align-items: center;
            gap: 8px;
            transition: all 0.2s;
            font-weight: 600;
        }

        #sp_Task_TaskDetail_html .btn-back:hover {
            background: var(--task-primary);
            color: white;
            border-color: var(--task-primary);
            transform: translateX(-4px);
        }

        #sp_Task_TaskDetail_html .task-title-section {
            flex: 1;
            display: flex;
            flex-direction: column;
            gap: 8px;
        }

        #sp_Task_TaskDetail_html .task-title-edit {
            font-size: 28px;
            font-weight: 700;
            color: var(--text-primary);
            line-height: 1.2;
        }

        #sp_Task_TaskDetail_html .task-meta-quick {
            display: flex;
            gap: 16px;
            align-items: center;
            font-size: 13px;
            color: var(--text-secondary);
        }

        #sp_Task_TaskDetail_html .task-meta-quick > span {
            display: flex;
            align-items: center;
            gap: 4px;
        }

        #sp_Task_TaskDetail_html .detail-actions {
            display: flex;
            gap: 8px;
            align-items: center;
        }

        #sp_Task_TaskDetail_html .btn-action {
            padding: 10px 16px;
            border-radius: var(--radius-md);
            border: 1px solid var(--border-color);
            background: white;
            cursor: pointer;
            transition: all 0.2s;
            font-weight: 600;
            display: flex;
            align-items: center;
            gap: 8px;
        }

        #sp_Task_TaskDetail_html .btn-action:hover {
            background: var(--task-primary);
            color: white;
            border-color: var(--task-primary);
        }

        #sp_Task_TaskDetail_html .btn-action.btn-save {
            background: var(--task-primary);
            color: white;
            border-color: var(--task-primary);
        }

        #sp_Task_TaskDetail_html .btn-action.btn-save:hover {
            background: var(--task-primary-hover);
        }

        /* Body Grid */
        #sp_Task_TaskDetail_html .detail-body {
            display: grid;
            grid-template-columns: 1fr 380px;
            gap: 24px;
        }

        #sp_Task_TaskDetail_html .main-content {
            display: flex;
            flex-direction: column;
            gap: 24px;
        }

        #sp_Task_TaskDetail_html .detail-section {
            background: white;
            border: 1px solid var(--border-color);
            border-radius: var(--radius-lg);
            padding: 24px;
            box-shadow: var(--shadow-sm);
            transition: box-shadow 0.2s;
        }

        #sp_Task_TaskDetail_html .detail-section:hover {
            box-shadow: var(--shadow-md);
        }

        #sp_Task_TaskDetail_html .section-title {
            font-size: 18px;
            font-weight: 700;
            margin-bottom: 20px;
            color: var(--text-primary);
            display: flex;
            align-items: center;
            gap: 10px;
            padding-bottom: 12px;
            border-bottom: 2px solid var(--border-color);
        }

        #sp_Task_TaskDetail_html .section-title i {
            color: var(--task-primary);
            font-size: 20px;
        }

        /* Meta Grid */
        #sp_Task_TaskDetail_html .meta-grid {
            display: grid;
            grid-template-columns: repeat(2, 1fr);
            gap: 20px;
        }

        #sp_Task_TaskDetail_html .meta-item {
            display: flex;
            flex-direction: column;
            gap: 8px;
            padding: 12px;
            background: var(--bg-light);
            border-radius: var(--radius-md);
            transition: all 0.2s;
        }

        #sp_Task_TaskDetail_html .meta-item:hover {
            background: #e8f5e9;
            transform: translateY(-2px);
        }

        #sp_Task_TaskDetail_html .meta-label {
            font-size: 11px;
            font-weight: 700;
            color: var(--text-secondary);
            text-transform: uppercase;
            letter-spacing: 0.5px;
        }

        #sp_Task_TaskDetail_html .meta-value {
            font-size: 15px;
            color: var(--text-primary);
            font-weight: 600;
        }

        /* KPI Section */
        #sp_Task_TaskDetail_html .kpi-section {
            display: flex;
            justify-content: space-between;
            align-items: center;
            padding: 24px;
            background: linear-gradient(135deg, #e8f5e9 0%, #f1f8e9 100%);
            border-radius: var(--radius-lg);
            border: 2px solid var(--task-primary);
        }

        #sp_Task_TaskDetail_html .kpi-display {
            display: flex;
            flex-direction: column;
            gap: 8px;
        }

        #sp_Task_TaskDetail_html .kpi-current {
            font-size: 48px;
            font-weight: 800;
            color: var(--task-primary);
            line-height: 1;
        }

        #sp_Task_TaskDetail_html .kpi-target {
            font-size: 14px;
            color: var(--text-secondary);
            font-weight: 600;
        }

        #sp_Task_TaskDetail_html .kpi-progress {
            margin-top: 12px;
        }

        #sp_Task_TaskDetail_html .kpi-progress-bar {
            height: 8px;
            background: rgba(255,255,255,0.5);
            border-radius: 4px;
            overflow: hidden;
            margin-top: 8px;
        }

        #sp_Task_TaskDetail_html .kpi-progress-fill {
            height: 100%;
            background: var(--task-primary);
            transition: width 0.6s cubic-bezier(0.4, 0, 0.2, 1);
        }

        #sp_Task_TaskDetail_html .kpi-input-group {
            display: flex;
            gap: 12px;
            align-items: center;
        }

        #sp_Task_TaskDetail_html .kpi-input-group input {
            padding: 12px 16px;
            border: 2px solid var(--border-color);
            border-radius: var(--radius-md);
            width: 140px;
            font-size: 16px;
            font-weight: 600;
            transition: all 0.2s;
        }

        #sp_Task_TaskDetail_html .kpi-input-group input:focus {
            border-color: var(--task-primary);
            box-shadow: 0 0 0 4px rgba(46, 125, 50, 0.1);
            outline: none;
        }

        #sp_Task_TaskDetail_html .kpi-input-group button {
            padding: 12px 24px;
            background: var(--task-primary);
            color: white;
            border: none;
            border-radius: var(--radius-md);
            cursor: pointer;
            font-weight: 700;
            transition: all 0.2s;
            display: flex;
            align-items: center;
            gap: 8px;
        }

        #sp_Task_TaskDetail_html .kpi-input-group button:hover {
            background: var(--task-primary-hover);
            transform: translateY(-2px);
            box-shadow: 0 4px 12px rgba(46, 125, 50, 0.3);
        }

        /* Subtasks Table */
        #sp_Task_TaskDetail_html .subtask-table {
            width: 100%;
            border-collapse: collapse;
        }

        #sp_Task_TaskDetail_html .subtask-table th,
        #sp_Task_TaskDetail_html .subtask-table td {
            padding: 14px 12px;
            text-align: left;
            border-bottom: 1px solid var(--border-color);
        }

        #sp_Task_TaskDetail_html .subtask-table th {
            background: var(--bg-light);
            font-weight: 700;
            font-size: 12px;
            color: var(--text-secondary);
            text-transform: uppercase;
            letter-spacing: 0.5px;
        }

        #sp_Task_TaskDetail_html .subtask-table tbody tr {
            transition: background 0.2s;
            cursor: pointer;
        }

        #sp_Task_TaskDetail_html .subtask-table tbody tr:hover {
            background: #f8fdf9;
        }

        #sp_Task_TaskDetail_html .badge-sts {
            padding: 4px 10px;
            border-radius: 12px;
            font-size: 11px;
            font-weight: 700;
            text-transform: uppercase;
        }

        #sp_Task_TaskDetail_html .sts-1 {
            background: #dfe1e6;
            color: #42526e;
        }

        #sp_Task_TaskDetail_html .sts-2 {
            background: #deebff;
            color: #0747a6;
        }

        #sp_Task_TaskDetail_html .sts-3 {
            background: #e3fcef;
            color: #006644;
        }

        /* Sidebar */
        #sp_Task_TaskDetail_html .sidebar {
            display: flex;
            flex-direction: column;
            gap: 24px;
        }

        #sp_Task_TaskDetail_html .sidebar .detail-section {
            position: sticky;
            top: 24px;
        }

        /* Comments */
        #sp_Task_TaskDetail_html .comments-list {
            max-height: 400px;
            overflow-y: auto;
            padding-right: 8px;
        }

        #sp_Task_TaskDetail_html .comment-item {
            padding: 14px;
            background: var(--bg-light);
            border-radius: var(--radius-md);
            margin-bottom: 12px;
            transition: all 0.2s;
            border-left: 3px solid transparent;
        }

        #sp_Task_TaskDetail_html .comment-item:hover {
            background: #e8f5e9;
            border-left-color: var(--task-primary);
            transform: translateX(4px);
        }

        #sp_Task_TaskDetail_html .comment-header {
            display: flex;
            justify-content: space-between;
            margin-bottom: 10px;
        }

        #sp_Task_TaskDetail_html .comment-author {
            font-weight: 700;
            font-size: 13px;
            color: var(--text-primary);
        }

        #sp_Task_TaskDetail_html .comment-date {
            font-size: 11px;
            color: var(--text-secondary);
        }

        #sp_Task_TaskDetail_html .comment-content {
            font-size: 14px;
            color: var(--text-primary);
            line-height: 1.6;
        }

        #sp_Task_TaskDetail_html .comment-input-group {
            margin-top: 16px;
            display: flex;
            gap: 8px;
        }

        #sp_Task_TaskDetail_html .comment-input-group textarea {
            flex: 1;
            padding: 12px;
            border: 1px solid var(--border-color);
            border-radius: var(--radius-md);
            resize: vertical;
            min-height: 80px;
            font-size: 14px;
        }

        #sp_Task_TaskDetail_html .comment-input-group button {
            padding: 12px 20px;
            background: var(--task-primary);
            color: white;
            border: none;
            border-radius: var(--radius-md);
            cursor: pointer;
            font-weight: 600;
            align-self: flex-start;
        }

        /* Attachments */
        #sp_Task_TaskDetail_html .attachment-list {
            display: grid;
            grid-template-columns: repeat(2, 1fr);
            gap: 12px;
        }

        #sp_Task_TaskDetail_html .attachment-item {
            padding: 12px;
            background: var(--bg-light);
            border-radius: var(--radius-md);
            display: flex;
            align-items: center;
            gap: 10px;
            cursor: pointer;
            transition: all 0.2s;
        }

        #sp_Task_TaskDetail_html .attachment-item:hover {
            background: #e8f5e9;
            transform: translateY(-2px);
        }

        #sp_Task_TaskDetail_html .attachment-icon {
            font-size: 24px;
            color: var(--task-primary);
        }

        #sp_Task_TaskDetail_html .attachment-name {
            font-size: 13px;
            font-weight: 600;
            overflow: hidden;
            text-overflow: ellipsis;
            white-space: nowrap;
        }

        /* Timeline */
        #sp_Task_TaskDetail_html .timeline-container {
            padding: 16px 0;
        }

        /* Responsive */
        @media (max-width: 1024px) {
            #sp_Task_TaskDetail_html .detail-body {
                grid-template-columns: 1fr;
            }

            #sp_Task_TaskDetail_html .sidebar .detail-section {
                position: static;
            }
        }

        @media (max-width: 768px) {
            #sp_Task_TaskDetail_html {
                padding: 12px;
            }

            #sp_Task_TaskDetail_html .meta-grid {
                grid-template-columns: 1fr;
            }

            #sp_Task_TaskDetail_html .kpi-section {
                flex-direction: column;
                align-items: flex-start;
                gap: 16px;
            }

            #sp_Task_TaskDetail_html .task-title-edit {
                font-size: 20px;
            }
        }

        /* Loading State */
        #sp_Task_TaskDetail_html .loading-skeleton {
            background: linear-gradient(90deg, #f0f0f0 25%, #e0e0e0 50%, #f0f0f0 75%);
            background-size: 200% 100%;
            animation: loading 1.5s infinite;
            border-radius: 4px;
        }

        @keyframes loading {
            0% { background-position: 200% 0; }
            100% { background-position: -200% 0; }
        }
    </style>

    <div id="sp_Task_TaskDetail_html">
        <div class="detail-header">
            <button class="btn-back" id="btnBack">
                <i class="bi bi-arrow-left"></i> Quay lại
            </button>
            <div class="task-title-section">
                <div class="task-title-edit" id="detailTaskName">Loading...</div>
                <div class="task-meta-quick">
                    <span><i class="bi bi-hash"></i><span id="quickTaskID">-</span></span>
                    <span><i class="bi bi-calendar3"></i><span id="quickCreatedDate">-</span></span>
                    <span><i class="bi bi-person"></i><span id="quickCreatedBy">-</span></span>
                </div>
            </div>
            <div class="detail-actions">
                <div id="status-control-wrapper"></div>
                <button class="btn-action" id="btnRefreshDetail" title="Tải lại">
                    <i class="bi bi-arrow-clockwise"></i>
                </button>
            </div>
        </div>

        <div class="detail-body">
            <div class="main-content">
                <!-- Meta Info -->
                <div class="detail-section">
                    <div class="section-title">
                        <i class="bi bi-info-circle-fill"></i> Thông tin chi tiết
                    </div>
                    <div class="meta-grid" id="metaGrid"></div>
                </div>

                <!-- Description -->
                <div class="detail-section">
                    <div class="section-title">
                        <i class="bi bi-file-text-fill"></i> Mô tả công việc
                    </div>
                    <div id="detailDescription" style="min-height:60px;line-height:1.6;color:var(--text-primary);">Chưa có mô tả</div>
                </div>

                <!-- KPI Section -->
                <div class="detail-section">
                    <div class="section-title">
                        <i class="bi bi-graph-up-arrow"></i> Tiến độ KPI
                    </div>
                    <div class="kpi-section">
                        <div class="kpi-display">
                            <div class="kpi-current" id="kpiCurrent">0</div>
                            <div class="kpi-target" id="kpiTarget">Target: 0</div>
                            <div class="kpi-progress">
                                <div style="display:flex;justify-content:space-between;margin-bottom:4px;">
                                    <span style="font-size:12px;font-weight:600;color:var(--text-secondary);">Hoàn thành:</span>
                                    <span style="font-size:12px;font-weight:700;color:var(--task-primary);" id="kpiPercent">0%</span>
                                </div>
                                <div class="kpi-progress-bar">
                                    <div class="kpi-progress-fill" id="kpiProgressFill" style="width:0%"></div>
                                </div>
                            </div>
                        </div>
                        <div class="kpi-input-group">
                            <input type="number" id="txtUpdateKPI" placeholder="Nhập KPI" step="0.01">
                            <button id="btnUpdateKPI">
                                <i class="bi bi-check-lg"></i> Cập nhật
                            </button>
                        </div>
                    </div>
                </div>

                <!-- Timeline -->
                <div class="detail-section">
                    <div class="section-title">
                        <i class="bi bi-clock-history"></i> Lịch trình thực hiện
                    </div>
                    <div id="timelineContainer" class="timeline-container"></div>
                </div>

                <!-- Subtasks -->
                <div class="detail-section">
                    <div class="section-title">
                        <i class="bi bi-list-check"></i> Công việc con
                        <span style="margin-left:auto;font-size:13px;font-weight:600;color:var(--task-primary);" id="subtaskCount">0</span>
                    </div>
                    <table class="subtask-table" id="subtaskTable">
                        <thead>
                            <tr>
                                <th style="width:35%">Tên công việc</th>
                                <th style="width:25%">Người thực hiện</th>
                                <th style="width:15%">Tiến độ</th>
                                <th style="width:15%">Trạng thái</th>
                                <th style="width:10%">Thao tác</th>
                            </tr>
                        </thead>
                        <tbody id="subtaskTableBody"></tbody>
                    </table>
                </div>
            </div>

            <div class="sidebar">
                <!-- Assignees -->
                <div class="detail-section">
                    <div class="section-title">
                        <i class="bi bi-people-fill"></i> Người thực hiện
                    </div>
                    <div id="assigneeContainer"></div>
                </div>

                <!-- Attachments -->
                <div class="detail-section">
                    <div class="section-title">
                        <i class="bi bi-paperclip"></i> File đính kèm
                        <span style="margin-left:auto;font-size:13px;font-weight:600;color:var(--task-primary);" id="attachmentCount">0</span>
                    </div>
                    <div id="attachmentsContainer"></div>
                    <div id="fileDropzoneContainer" style="margin-top:16px;"></div>
                </div>

                <!-- Comments -->
                <div class="detail-section">
                    <div class="section-title">
                        <i class="bi bi-chat-dots-fill"></i> Bình luận
                        <span style="margin-left:auto;font-size:13px;font-weight:600;color:var(--task-primary);" id="commentCount">0</span>
                    </div>
                    <div class="comments-list" id="commentsContainer"></div>
                    <div class="comment-input-group">
                        <textarea id="txtNewComment" placeholder="Nhập bình luận..."></textarea>
                        <button id="btnAddComment">
                            <i class="bi bi-send-fill"></i>
                        </button>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <script>
        (function() {
            "use strict";

            var currentTaskID = null;
            var taskData = null;

            // Accept parameters from caller
            try {
                if (window.sp_Task_TaskDetail_html && typeof window.sp_Task_TaskDetail_html === "object") {
                    if (window.sp_Task_TaskDetail_html.TaskID) currentTaskID = window.sp_Task_TaskDetail_html.TaskID;
                    if (window.sp_Task_TaskDetail_html.TaskData) taskData = window.sp_Task_TaskDetail_html.TaskData;
                } else if (window.sp_Task_TaskDetail_param && window.sp_Task_TaskDetail_param.TaskID) {
                    currentTaskID = window.sp_Task_TaskDetail_param.TaskID;
                }
            } catch (e) {}

            // Global loader function
            window.hpaTaskDetail_load = function(payload) {
                if (!payload) return;
                try {
                    taskData = payload;
                    if (payload.TaskID) currentTaskID = payload.TaskID;
                    renderTaskDetail(taskData);
                    if (payload.AssignHistory) renderAssignHistory(payload.AssignHistory);
                    if (payload.Comments) renderComments(payload.Comments);
                    if (payload.Subtasks) renderSubtasks(payload.Subtasks);
                    if (payload.Attachments) renderAttachments(payload.Attachments);
                    if (payload.Timeline) renderTimeline(payload.Timeline);
                    initializeControls();
                } catch (err) { console.error("hpaTaskDetail_load error", err); }
            };

            $(document).ready(function() {
                attachHandlers();

                if (taskData) {
                    try {
                        renderTaskDetail(taskData);
                        if (taskData.AssignHistory) renderAssignHistory(taskData.AssignHistory);
                        if (taskData.Comments) renderComments(taskData.Comments);
                        if (taskData.Subtasks) renderSubtasks(taskData.Subtasks);
                        if (taskData.Attachments) renderAttachments(taskData.Attachments);
                        if (taskData.Timeline) renderTimeline(taskData.Timeline);
                        initializeControls();
                    } catch (e) { console.error(e); }
                    return;
                }

                if (currentTaskID > 0) {
                    loadTaskDetail();
                }
            });

            function attachHandlers() {
                $("#btnBack").on("click", function() {
                    if (typeof CloseThisTabNoConfirm !== "undefined") {
                        CloseThisTabNoConfirm();
                    } else {
                        history.back();
                    }
                });

                $("#btnRefreshDetail").on("click", loadTaskDetail);
                $("#btnUpdateKPI").on("click", updateKPI);
                $("#btnAddComment").on("click", addComment);
            }

            function loadTaskDetail() {
                if (!currentTaskID) return;

                showLoading();

                AjaxHPAParadise({
                    data: {
                        name: "sp_Task_GetDetail",
                        param: ["TaskID", currentTaskID, "LoginID", LoginID]
                    },
                    success: function(response) {
                        try {
                            var res = JSON.parse(response);
                            taskData = res.data[0][0];
                            var assignHistory = res.data[1] || [];
                            var comments = res.data[2] || [];
                            var attachments = res.data[3] || [];
                            var subtasks = res.data[4] || [];
                            var timeline = res.data[5] || [];

                            renderTaskDetail(taskData);
                            renderAssignHistory(assignHistory);
                            renderComments(comments);
                            renderAttachments(attachments);
                            renderSubtasks(subtasks);
                            renderTimeline(timeline);

                            initializeControls();
                            hideLoading();
                        } catch(e) {
                            console.error("Error parsing task detail:", e);
                            hideLoading();
                        }
                    },
                    error: function() {
                        hideLoading();
                        uiManager.showAlert({ type: "error", message: "Không thể tải thông tin công việc" });
                    }
                });
            }

            function renderTaskDetail(task) {
                if (!task) return;

                $("#detailTaskName").text(task.TaskName || "Untitled Task");
                $("#detailDescription").text(task.Description || "Chưa có mô tả");

                // Quick meta
                $("#quickTaskID").text(task.TaskID || "-");
                $("#quickCreatedDate").text(formatDate(task.CreatedDate));
                $("#quickCreatedBy").text(task.CreatedByName || "-");

                // Meta Grid với hpaControl
                var metaHtml = `
                    <div class="meta-item">
                        <div class="meta-label">Độ ưu tiên</div>
                        <div class="meta-value" id="priorityField"></div>
                    </div>
                    <div class="meta-item">
                        <div class="meta-label">Ngày bắt đầu</div>
                        <div class="meta-value" id="startDateField">${formatDate(task.StartDate)}</div>
                    </div>
                    <div class="meta-item">
                        <div class="meta-label">Hạn hoàn thành</div>
                        <div class="meta-value" id="dueDateField">${formatDate(task.DueDate)}</div>
                    </div>
                    <div class="meta-item">
                        <div class="meta-label">Thời gian cam kết</div>
                        <div class="meta-value" id="committedHoursField">${task.CommittedHours || 0} giờ</div>
                    </div>
                    <div class="meta-item">
                        <div class="meta-label">Người yêu cầu</div>
                        <div class="meta-value">${task.RequestedByName || "-"}</div>
                    </div>
                    <div class="meta-item">
                        <div class="meta-label">Chịu trách nhiệm chính</div>
                        <div class="meta-value">${task.MainResponsibleName || "-"}</div>
                    </div>
                `;
                $("#metaGrid").html(metaHtml);

                // KPI Display
                var actualKPI = parseFloat(task.ActualKPI) || 0;
                var targetKPI = parseFloat(task.TargetKPI) || parseFloat(task.KPIPerDay) || 0;
                var kpiPercent = targetKPI > 0 ? Math.round((actualKPI / targetKPI) * 100) : 0;

                $("#kpiCurrent").text(actualKPI);
                $("#kpiTarget").text(`Target: ${targetKPI} ${task.Unit || ""}`);
                $("#kpiPercent").text(kpiPercent + "%");
                $("#kpiProgressFill").css("width", Math.min(kpiPercent, 100) + "%");
            }

            function renderAssignHistory(history) {
                if (!history || history.length === 0) {
                    $("#assigneeContainer").html(`<p class="text-muted" style="text-align:center;padding:20px;">Chưa có người thực hiện</p>`);
                    return;
                }

                var assigneeIds = history.map(h => h.EmployeeID).filter(Boolean);
                var historyId = history[0] && history[0].HistoryID;

                setTimeout(function() {
                    if (typeof hpaControlEmployeeSelector === "function") {
                        hpaControlEmployeeSelector("#assigneeContainer", {
                            selectedIds: assigneeIds,
                            ajaxListName: "EmployeeListAll_DataSetting_Custom",
                            showAvatar: true,
                            multi: true,
                            tableName: "tblTask_AssignHistory",
                            columnName: "EmployeeID",
                            idColumnName: "HistoryID",
                            idValue: historyId,
                            onChange: function(newIds) {
                                console.log("Assignees updated:", newIds);
                            }
                        });
                    }
                }, 100);
            }

            function renderComments(comments) {
                if (!comments || comments.length === 0) {
                    $("#commentsContainer").html(`<p class="text-muted" style="text-align:center;padding:20px;">Chưa có bình luận</p>`);
                    $("#commentCount").text("0");
                    return;
                }

                $("#commentCount").text(comments.length);

                var html = comments.map(function(c) {
                    return `
                        <div class="comment-item">
                            <div class="comment-header">
                                <span class="comment-author">${escapeHtml(c.EmployeeName || c.CreatedByName || "Unknown")}</span>
                                <span class="comment-date">${formatDateTime(c.CreatedDate || c.CommentDate)}</span>
                            </div>
                            <div class="comment-content">${escapeHtml(c.Content || c.CommentText || "")}</div>
                        </div>
                 `;
                }).join("");

                $("#commentsContainer").html(html);
            }

            function renderSubtasks(subtasks) {
                if (!subtasks || subtasks.length === 0) {
                    $("#subtaskTableBody").html(`<tr><td colspan="5" style="text-align:center;padding:40px;color:var(--text-muted);">Không có công việc con</td></tr>`);
                    $("#subtaskCount").text("0");
                    return;
                }

                $("#subtaskCount").text(subtasks.length);

                var html = subtasks.map(function(st) {
                    var statusCode = st.SubtaskStatusCode || st.StatusCode || 1;
                    var statusClass = statusCode == 3 ? "sts-3" : statusCode == 2 ? "sts-2" : "sts-1";
                    var statusText = statusCode == 3 ? "Hoàn thành" : statusCode == 2 ? "Đang làm" : "Chưa làm";
                    var progress = st.SubtaskProgress || st.ProgressPct || 0;

                    return `
                        <tr data-subtask-id="${st.ChildTaskID || st.TaskID}">
                            <td style="font-weight:600;">${escapeHtml(st.ChildTaskName || st.TaskName || "Untitled")}</td>
                            <td>${escapeHtml(st.AssignedToEmployeeName || st.AssignedToName || "-")}</td>
                            <td>
                                <div style="display:flex;align-items:center;gap:8px;">
                                    <div style="flex:1;height:6px;background:#e0e0e0;border-radius:3px;overflow:hidden;">
                                        <div style="height:100%;background:var(--task-primary);width:${Math.min(progress, 100)}%;transition:width 0.3s;"></div>
                                    </div>
                                    <span style="font-size:12px;font-weight:700;color:var(--task-primary);">${progress}%</span>
                                </div>
                            </td>
                            <td><span class="badge-sts ${statusClass}">${statusText}</span></td>
                            <td>
                                <button class="btn-action" style="padding:6px 12px;font-size:12px;" onclick="openSubtaskDetail(${st.ChildTaskID || st.TaskID})">
                                    <i class="bi bi-box-arrow-up-right"></i>
                                </button>
                            </td>
                        </tr>
                    `;
                }).join("");

                $("#subtaskTableBody").html(html);
            }

            function renderAttachments(attachments) {
                if (!attachments || attachments.length === 0) {
                    $("#attachmentsContainer").html(`<p class="text-muted" style="text-align:center;padding:20px;">Chưa có file đính kèm</p>`);
                    $("#attachmentCount").text("0");

                    // Initialize file dropzone
                    initFileDropzone();
                    return;
                }

                $("#attachmentCount").text(attachments.length);

                var html = `<div class="attachment-list">`;
                attachments.forEach(function(att) {
                    var fileName = att.FileName || att.Name || "Unknown";
                    var fileUrl = att.Url || att.UrlFile || att.FilePath || "#";
                    var ext = fileName.split(".").pop().toLowerCase();

                    var iconClass = "bi-file-earmark";
                    if (["jpg", "jpeg", "png", "gif"].includes(ext)) iconClass = "bi-file-image";
                    else if (ext === "pdf") iconClass = "bi-file-pdf";
                    else if (["doc", "docx"].includes(ext)) iconClass = "bi-file-word";
                    else if (["xls", "xlsx"].includes(ext)) iconClass = "bi-file-excel";

                    html += `
                        <div class="attachment-item" onclick="window.open("${fileUrl}", "_blank")">
                            <i class="bi ${iconClass} attachment-icon"></i>
                            <div class="attachment-name" title="${escapeHtml(fileName)}">${escapeHtml(fileName)}</div>
                        </div>
                    `;
                });
                html += "</div>";

                $("#attachmentsContainer").html(html);

                // Initialize file dropzone
                initFileDropzone();
            }

            function renderTimeline(timeline) {
                if (!timeline || timeline.length === 0) {
                    $("#timelineContainer").html(`<p class="text-muted" style="text-align:center;padding:20px;">Chưa có lịch trình</p>`);
                    return;
                }

                // Use the buildTimelineHtml function from MyWork
                try {
                    var entries = timeline.map(function(t) {
                        return {
                            start: t.StartDate || t.AssignStartDate || t.MyStartDate,
                            end: t.EndDate || t.DueDate,
                            label: t.EmployeeName || t.AssignedToName || "",
                            progress: t.Progress || 0
                        };
                    });

                    var timelineHtml = buildTimelineHtml(entries);
                    $("#timelineContainer").html(timelineHtml);
                } catch(e) {
                    console.error("Error rendering timeline:", e);
                    $("#timelineContainer").html(`<p class="text-muted">Không thể hiển thị lịch trình</p>`);
                }
            }

            function initializeControls() {
                if (!taskData) return;

                // Task Name - Editable
                if (typeof hpaControlEditableRow === "function") {
                    hpaControlEditableRow("#detailTaskName", {
                        type: "input",
                        tableName: "tblTask",
                        columnName: "TaskName",
                        idColumnName: "TaskID",
                        idValue: currentTaskID,
                        silent: true,
                        onSave: function(newValue) {
                            taskData.TaskName = newValue;
                            uiManager.showAlert({ type: "success", message: "Đã cập nhật tên công việc" });
                        }
                    });

                    // Description - Editable
                    hpaControlEditableRow("#detailDescription", {
                        type: "textarea",
                        tableName: "tblTask",
                        columnName: "Description",
                        idColumnName: "TaskID",
                        idValue: currentTaskID,
                        silent: true,
                        onSave: function(newValue) {
                            taskData.Description = newValue;
                            uiManager.showAlert({ type: "success", message: "Đã cập nhật mô tả" });
                        }
                    });

                    // Committed Hours - Editable Number
                    hpaControlEditableNumber("#committedHoursField", {
                        type: "NumberFlo",
                        tableName: "tblTask_AssignHistory",
                        columnName: "CommittedHours",
                        idColumnName: "TaskID",
                        idValue: currentTaskID,
                        silent: true,
                        onSave: function(newValue) {
                            uiManager.showAlert({ type: "success", message: "Đã cập nhật thời gian cam kết" });
                        }
                    });
                }

                // Priority - Field Control
                if (typeof hpaControlField === "function") {
                    hpaControlField("#priorityField", {
                        type: "select",
                        options: [
                            { value: 1, text: "Cao" },
                            { value: 2, text: "Trung bình" },
                            { value: 3, text: "Thấp" }
                        ],
                        selected: taskData.Priority || taskData.AssignPriority || 3,
                        searchable: false,
                        tableName: "tblTask_AssignHistory",
                        columnName: "AssignPriority",
                        idColumnName: "TaskID",
                        idValue: currentTaskID,
                        silent: true,
                        onChange: function(newValue) {
                            taskData.Priority = newValue;
                            uiManager.showAlert({ type: "success", message: "Đã cập nhật độ ưu tiên" });
                        }
                    });
                }

                // Status - Field Control in Header
                if (typeof hpaControlField === "function") {
                    hpaControlField("#status-control-wrapper", {
                        type: "select",
                        options: [
                            { value: 1, text: "Chưa làm" },
                            { value: 2, text: "Đang làm" },
                            { value: 3, text: "Hoàn thành" }
                        ],
                        selected: taskData.StatusCode || 1,
                        searchable: false,
                        silent: true,
                        onChange: function(newVal) {
                            updateTaskStatus(newVal);
                        }
                    });
                }

                // Date Controls
                if (typeof hpaControlDateBox === "function") {
                    hpaControlDateBox("#startDateField", {
                        type: "date",
                        field: "StartDate",
                        tableName: "tblTask_AssignHistory",
                        idColumnName: "TaskID",
                        idValue: currentTaskID,
                        silent: true,
                        onSave: function(newValue) {
                            uiManager.showAlert({ type: "success", message: "Đã cập nhật ngày bắt đầu" });
                        }
                    });

                    hpaControlDateBox("#dueDateField", {
                        type: "date",
                        field: "EndDate",
                        tableName: "tblTask_AssignHistory",
                        idColumnName: "TaskID",
                        idValue: currentTaskID,
                        silent: true,
                        onSave: function(newValue) {
                            uiManager.showAlert({ type: "success", message: "Đã cập nhật hạn hoàn thành" });
                        }
                    });
                }
            }

            function initFileDropzone() {
                if (typeof hpaControlFileDropzone === "function") {
                    hpaControlFileDropzone("#fileDropzoneContainer", {
                        tableName: "tblTask",
                        columnName: "Attachments",
                        idColumnName: "TaskID",
                        idValue: currentTaskID,
                        allowedExtensions: [".pdf", ".doc", ".docx", ".xls", ".xlsx", ".jpg", ".jpeg", ".png", ".zip"],
                        width: "100%",
                        height: "120px",
                        currentValue: taskData && taskData.Attachments ? taskData.Attachments : [],
                        silent: true,
                        onUploadSuccess: function() {
                            loadTaskDetail();
                        }
                    });
                }
            }

            function updateKPI() {
                var kpiVal = $("#txtUpdateKPI").val();
                if (!kpiVal || parseFloat(kpiVal) < 0) {
                    uiManager.showAlert({ type: "warning", message: "Vui lòng nhập giá trị KPI hợp lệ" });
                    return;
                }

                AjaxHPAParadise({
                    data: {
                        name: "sp_Task_UpdateKPI",
                        param: [
                            "TaskID", currentTaskID,
                            "LoginID", LoginID,
                            "ActualKPI", parseFloat(kpiVal),
                            "Note", ""
                        ]
                    },
                    success: function() {
                        uiManager.showAlert({ type: "success", message: "Cập nhật KPI thành công!" });
                        loadTaskDetail();
                        $("#txtUpdateKPI").val("");
                    },
                    error: function() {
                        uiManager.showAlert({ type: "error", message: "Cập nhật KPI thất bại!" });
                    }
                });
            }

            function updateTaskStatus(newStatus) {
                AjaxHPAParadise({
                    data: {
                        name: "sp_Task_UpdateStatus",
                        param: [
                            "TaskID", currentTaskID,
                            "LoginID", LoginID,
                            "NewStatus", newStatus
                        ]
                    },
                    success: function() {
                        uiManager.showAlert({ type: "success", message: "Cập nhật trạng thái thành công!" });
                        if (taskData) taskData.StatusCode = newStatus;
                    },
                    error: function() {
                        uiManager.showAlert({ type: "error", message: "Cập nhật trạng thái thất bại!" });
                    }
                });
            }

            function addComment() {
                var content = $("#txtNewComment").val().trim();
                if (!content) {
                    uiManager.showAlert({ type: "warning", message: "Vui lòng nhập nội dung bình luận" });
                    return;
                }

                AjaxHPAParadise({
                    data: {
                        name: "sp_Task_AddComment",
                        param: [
                            "TaskID", currentTaskID,
                            "LoginID", LoginID,
                            "Content", content
                        ]
                    },
                    success: function() {
                        uiManager.showAlert({ type: "success", message: "Đã thêm bình luận" });
                        $("#txtNewComment").val("");
                        loadTaskDetail();
                    },
                    error: function() {
                        uiManager.showAlert({ type: "error", message: "Thêm bình luận thất bại!" });
                    }
                });
            }

            function showLoading() {
                $(".detail-section").addClass("loading-skeleton");
            }

            function hideLoading() {
                $(".detail-section").removeClass("loading-skeleton");
            }

            function formatDate(dateStr) {
                if (!dateStr) return "-";
                var d = new Date(dateStr);
                if (isNaN(d.getTime())) return "-";
                var day = ("0" + d.getDate()).slice(-2);
                var month = ("0" + (d.getMonth() + 1)).slice(-2);
                var year = d.getFullYear();
                return day + "/" + month + "/" + year;
            }

            function formatDateTime(dateStr) {
                if (!dateStr) return "-";
                var d = new Date(dateStr);
                if (isNaN(d.getTime())) return "-";
                var day = ("0" + d.getDate()).slice(-2);
                var month = ("0" + (d.getMonth() + 1)).slice(-2);
                var year = d.getFullYear();
                var hours = ("0" + d.getHours()).slice(-2);
                var minutes = ("0" + d.getMinutes()).slice(-2);
                return day + "/" + month + "/" + year + " " + hours + ":" + minutes;
            }

            function escapeHtml(str) {
                if (str === null || str === undefined) return "";
                return String(str)
                    .replace(/&/g, "&amp;")
                    .replace(/</g, "&lt;")
                    .replace(/>/g, "&gt;")
                    .replace(/""/g, "&quot;")
                    .replace(/"/g, "&#039;");
            }

            // Build timeline HTML (simplified version from MyWork)
            function buildTimelineHtml(entries) {
                if (!entries || entries.length === 0) return `<div class="text-muted" style="padding:8px;text-align:center;font-size:12px;">Chưa có lịch trình</div>`;

                var norm = entries.map(function(e){
                    if (!e) return null;
                    return {
                        start: new Date(e.start),
                        end: new Date(e.end || e.start),
                        label: e.label || "",
                        progress: e.progress || 0
                    };
                }).filter(function(e) { return e && e.start && !isNaN(e.start.getTime()); });

                if (norm.length === 0) return `<div class="text-muted" style="padding:8px;text-align:center;font-size:12px;">Chưa có lịch trình</div>`;

                var minStart = norm[0].start;
                var maxEnd = norm[0].end;

                norm.forEach(function(e){
                    if (e.start < minStart) minStart = e.start;
                    if (e.end > maxEnd) maxEnd = e.end;
                });

                var rangeMs = Math.max(1, maxEnd - minStart);
                var rangeDays = Math.ceil(rangeMs / (24*3600*1000));
                var today = new Date();
                today.setHours(0, 0, 0, 0);

                var colors = ["#FFD700", "#4169E1", "#FF6347", "#32CD32", "#9370DB", "#FF8C00", "#20B2AA", "#DC143C"];

                var html = `<div class="timeline-gantt" style="width:100%;overflow-x:auto;padding:8px 0;">`;
                html += `<div style="min-width:400px;max-width:600px;">`;

                norm.forEach(function(en, idx){
                    var s = en.start;
                    var e = en.end || en.start;

                    var startTxt = ("0"+s.getDate()).slice(-2) + "/" + ("0"+(s.getMonth()+1)).slice(-2);
                    var endTxt = ("0"+e.getDate()).slice(-2) + "/" + ("0"+(e.getMonth()+1)).slice(-2);

                    var startDay = Math.floor((s - minStart) / (24*3600*1000));
                    var endDay = Math.ceil((e - minStart) / (24*3600*1000));
                    var duration = Math.max(1, endDay - startDay);

                    var leftPct = (startDay / rangeDays) * 100;
                    var widthPct = (duration / rangeDays) * 100;

                    var barColor = colors[idx % colors.length];
                    var isOverdue = e < today;
                    if (isOverdue) barColor = "#E53935";

                    var safeLabel = escapeHtml(en.label || "");
                    var barId = "timeline-bar-" + idx;

                    html += `<div class="timeline-gantt-row" style="margin-bottom:3px;position:relative;height:32px;">`;

                    html += `<div id="${barId}"
                        style="position:absolute;
                               left:${leftPct}%;
                               width:${widthPct}%;
                               height:28px;
                               background:${barColor};
                               border-radius:4px;
        display:flex;
                               align-items:center;
                               justify-content:center;
                               color:white;
                               font-size:10px;
                               font-weight:600;
                               cursor:pointer;
                               transition:all 0.2s ease;
                               box-shadow:0 1px 3px rgba(0,0,0,0.1);"
                        title="${safeLabel} (${startTxt} - ${endTxt})">`;

                    html += `<div style="display:flex;flex-direction:column;align-items:center;padding:0 6px;text-align:center;">`;
                    html += `<span style="font-size:9px;opacity:0.95;">${safeLabel}</span>`;
                    html += `<span style="font-size:8px;margin-top:1px;">${startTxt} - ${endTxt}</span>`;
                    html += `</div>`;

                    html += `</div>`;
                    html += `</div>`;
                });

                html += `</div></div>`;

                return html;
            }

            // Global function to open subtask detail
            window.openSubtaskDetail = function(subtaskId) {
                if (!subtaskId) return;

                if (typeof openFormParam === "function") {
                    openFormParam("sp_Task_TaskDetail", {
                        TaskID: subtaskId,
                        LoginID: LoginID,
                        LanguageID: LanguageID
                    });
                }
            };

        })();
    </script>
    ';
    SELECT @html AS html;
END
GO

EXEC sp_GenerateHTMLScript 'sp_Task_TaskDetail_html'