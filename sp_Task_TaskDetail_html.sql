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
            max-width: 1200px;
            margin: 0 auto;
            padding: 20px;
        }

        #sp_Task_TaskDetail_html .detail-header {
            display: flex;
            align-items: center;
            gap: 16px;
            margin-bottom: 24px;
            padding-bottom: 16px;
            border-bottom: 2px solid var(--border-color);
        }

        #sp_Task_TaskDetail_html .btn-back {
            padding: 8px 16px;
            border: 1px solid var(--border-color);
            border-radius: var(--radius-md);
            background: white;
            cursor: pointer;
            display: flex;
            align-items: center;
            gap: 8px;
            transition: all 0.2s;
        }

        #sp_Task_TaskDetail_html .btn-back:hover {
            background: var(--bg-light);
            border-color: var(--task-primary);
        }

        #sp_Task_TaskDetail_html .task-title-edit {
            flex: 1;
            font-size: 24px;
            font-weight: 700;
            color: var(--text-primary);
        }

        #sp_Task_TaskDetail_html .detail-actions {
            display: flex;
            gap: 8px;
        }

        #sp_Task_TaskDetail_html .btn-action {
            padding: 8px 16px;
            border-radius: var(--radius-md);
            border: 1px solid var(--border-color);
            background: white;
            cursor: pointer;
            transition: all 0.2s;
        }

        #sp_Task_TaskDetail_html .btn-action:hover {
            background: var(--bg-light);
        }

        #sp_Task_TaskDetail_html .detail-body {
            display: grid;
            grid-template-columns: 1fr 320px;
            gap: 24px;
        }

        #sp_Task_TaskDetail_html .main-content {
            display: flex;
            flex-direction: column;
            gap: 20px;
        }

        #sp_Task_TaskDetail_html .detail-section {
            background: white;
            border: 1px solid var(--border-color);
            border-radius: var(--radius-lg);
            padding: 20px;
        }

        #sp_Task_TaskDetail_html .section-title {
            font-size: 16px;
            font-weight: 700;
            margin-bottom: 16px;
            color: var(--text-primary);
            display: flex;
            align-items: center;
            gap: 8px;
        }

        #sp_Task_TaskDetail_html .meta-grid {
            display: grid;
            grid-template-columns: repeat(2, 1fr);
            gap: 16px;
        }

        #sp_Task_TaskDetail_html .meta-item {
            display: flex;
            flex-direction: column;
            gap: 4px;
        }

        #sp_Task_TaskDetail_html .meta-label {
            font-size: 12px;
            font-weight: 600;
            color: var(--text-secondary);
            text-transform: uppercase;
        }

        #sp_Task_TaskDetail_html .meta-value {
            font-size: 14px;
            color: var(--text-primary);
        }

        #sp_Task_TaskDetail_html .kpi-section {
            display: flex;
            justify-content: space-between;
            align-items: center;
            padding: 16px;
            background: var(--bg-light);
            border-radius: var(--radius-md);
            margin-bottom: 16px;
        }

        #sp_Task_TaskDetail_html .kpi-display {
            display: flex;
            flex-direction: column;
            gap: 4px;
        }

        #sp_Task_TaskDetail_html .kpi-current {
            font-size: 32px;
            font-weight: 700;
            color: var(--task-primary);
        }

        #sp_Task_TaskDetail_html .kpi-target {
            font-size: 13px;
            color: var(--text-secondary);
        }

        #sp_Task_TaskDetail_html .kpi-input-group {
            display: flex;
            gap: 8px;
        }

        #sp_Task_TaskDetail_html .kpi-input-group input {
            padding: 8px 12px;
            border: 1px solid var(--border-color);
            border-radius: var(--radius-md);
            width: 120px;
        }

        #sp_Task_TaskDetail_html .kpi-input-group button {
            padding: 8px 16px;
            background: var(--task-primary);
            color: white;
            border: none;
            border-radius: var(--radius-md);
            cursor: pointer;
        }

        #sp_Task_TaskDetail_html .subtask-table {
            width: 100%;
            border-collapse: collapse;
        }

        #sp_Task_TaskDetail_html .subtask-table th,
        #sp_Task_TaskDetail_html .subtask-table td {
            padding: 12px;
            text-align: left;
            border-bottom: 1px solid var(--border-color);
        }

        #sp_Task_TaskDetail_html .subtask-table th {
            background: var(--bg-light);
            font-weight: 600;
            font-size: 13px;
            color: var(--text-secondary);
        }

        #sp_Task_TaskDetail_html .sidebar {
            display: flex;
            flex-direction: column;
            gap: 20px;
        }

        #sp_Task_TaskDetail_html .comment-item {
            padding: 12px;
            background: var(--bg-light);
            border-radius: var(--radius-md);
            margin-bottom: 8px;
        }

        #sp_Task_TaskDetail_html .comment-header {
            display: flex;
            justify-content: space-between;
            margin-bottom: 8px;
        }

        #sp_Task_TaskDetail_html .comment-author {
            font-weight: 600;
            font-size: 13px;
        }

        #sp_Task_TaskDetail_html .comment-date {
            font-size: 12px;
            color: var(--text-secondary);
        }

        @media (max-width: 768px) {
            #sp_Task_TaskDetail_html .detail-body {
                grid-template-columns: 1fr;
            }
        }
    </style>

    <div id="sp_Task_TaskDetail_html">
        <div class="detail-header">
            <button class="btn-back" id="btnBack">
                <i class="bi bi-arrow-left"></i> Quay lại
            </button>
            <div class="task-title-edit" id="detailTaskName">Loading...</div>
            <div class="detail-actions">
                <div id="status-control-wrapper"></div>
                <button class="btn-action" id="btnRefreshDetail">
                    <i class="bi bi-arrow-clockwise"></i>
                </button>
            </div>
        </div>

        <div class="detail-body">
            <div class="main-content">
                <!-- Meta Info -->
                <div class="detail-section">
                    <div class="section-title">
                        <i class="bi bi-info-circle"></i> Thông tin
                    </div>
                    <div class="meta-grid" id="metaGrid"></div>
                </div>

                <!-- Description -->
                <div class="detail-section">
                    <div class="section-title">
                        <i class="bi bi-file-text"></i> Mô tả
                    </div>
                    <div id="detailDescription">Chưa có mô tả</div>
                </div>

                <!-- KPI Section -->
                <div class="detail-section">
                    <div class="section-title">
                        <i class="bi bi-graph-up"></i> Tiến độ KPI
                    </div>
                    <div class="kpi-section">
                        <div class="kpi-display">
                            <div class="kpi-current" id="kpiCurrent">0</div>
                            <div class="kpi-target" id="kpiTarget">Target: 0</div>
                        </div>
                        <div class="kpi-input-group">
                            <input type="number" id="txtUpdateKPI" placeholder="Nhập KPI">
                            <button id="btnUpdateKPI">
                                <i class="bi bi-check-lg"></i> Cập nhật
                            </button>
                        </div>
                    </div>
                </div>

                <!-- Subtasks -->
                <div class="detail-section">
                    <div class="section-title">
                        <i class="bi bi-list-check"></i> Công việc con
                    </div>
                    <table class="subtask-table" id="subtaskTable">
                        <thead>
                            <tr>
                                <th>Tên công việc</th>
                                <th>Người thực hiện</th>
                                <th>Tiến độ</th>
                                <th>Trạng thái</th>
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
                        <i class="bi bi-people"></i> Người thực hiện
                    </div>
                    <div id="assigneeContainer"></div>
                </div>

                <!-- Comments -->
                <div class="detail-section">
                    <div class="section-title">
                        <i class="bi bi-chat-dots"></i> Bình luận
                    </div>
                    <div id="commentsContainer"></div>
                </div>
            </div>
        </div>
    </div>

    <script>
        (function() {
            "use strict";
            
            var currentTaskID = null;
            var taskData = null;

            // Accept parameters passed by caller via window.sp_Task_TaskDetail_html
            try {
                if (window.sp_Task_TaskDetail_html && typeof window.sp_Task_TaskDetail_html === "object") {
                    if (window.sp_Task_TaskDetail_html.TaskID) currentTaskID = window.sp_Task_TaskDetail_html.TaskID;
                    if (window.sp_Task_TaskDetail_html.TaskData) taskData = window.sp_Task_TaskDetail_html.TaskData;
                } else if (window.sp_Task_TaskDetail_param && window.sp_Task_TaskDetail_param.TaskID) {
                    currentTaskID = window.sp_Task_TaskDetail_param.TaskID;
                }
            } catch (e) {}

            // Expose a loader so parent/caller can push full task payload (including comments/attachments/subtasks)
            window.hpaTaskDetail_load = function(payload) {
                if (!payload) return;
                try {
                    taskData = payload;
                    if (payload.TaskID) currentTaskID = payload.TaskID;
                    // Render available pieces
                    if (typeof renderTaskDetail === "function") renderTaskDetail(taskData);
                    if (payload.AssignHistory && typeof renderAssignHistory === "function") renderAssignHistory(payload.AssignHistory);
                    if (payload.Comments && typeof renderComments === "function") renderComments(payload.Comments);
                    if (payload.Subtasks && typeof renderSubtasks === "function") renderSubtasks(payload.Subtasks);
                    if (typeof initializeControls === "function") initializeControls();
                } catch (err) { console.error("hpaTaskDetail_load error", err); }
            };

            $(document).ready(function() {
                attachHandlers();

                // If caller provided full TaskData, render immediately without extra AJAX
                if (taskData) {
                    try {
                        renderTaskDetail(taskData);
                        if (taskData.AssignHistory) renderAssignHistory(taskData.AssignHistory);
                        if (taskData.Comments) renderComments(taskData.Comments);
                        if (taskData.Subtasks) renderSubtasks(taskData.Subtasks);
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
            }

            function loadTaskDetail() {
                if (!currentTaskID) return;

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

                            renderTaskDetail(taskData);
                            renderAssignHistory(assignHistory);
                            renderComments(comments);
                            renderSubtasks(subtasks);

                            initializeControls();
                        } catch(e) {
                            console.error("Error parsing task detail:", e);
                        }
                    }
                });
            }

            function renderTaskDetail(task) {
                $("#detailTaskName").text(task.TaskName || "Untitled Task");
                $("#detailDescription").text(task.Description || "Chưa có mô tả");

                // Meta Grid
                var metaHtml = `
                    <div class="meta-item">
                        <div class="meta-label">Mã công việc</div>
                        <div class="meta-value">#${task.TaskID}</div>
                    </div>
                    <div class="meta-item">
                        <div class="meta-label">Độ ưu tiên</div>
                        <div class="meta-value" id="priorityField">
                            ${task.Priority == 1 ? "Cao" : task.Priority == 2 ? "Trung bình" : "Thấp"}
                        </div>
                    </div>
                    <div class="meta-item">
                        <div class="meta-label">Ngày bắt đầu</div>
                        <div class="meta-value" id="startDateField">
                            ${formatDate(task.AssignStartDate)}
                        </div>
                    </div>
                    <div class="meta-item">
                        <div class="meta-label">Hạn hoàn thành</div>
                        <div class="meta-value" id="dueDateField">
                            ${formatDate(task.AssignStartDate)}
                        </div>
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

                // KPI
                $("#kpiCurrent").text(task.ActualKPI || 0);
                $("#kpiTarget").text(`Target: ${task.KPIPerDay || 0} ${task.Unit || ""}`);
            }

            function renderAssignHistory(history) {
                if (!history || history.length === 0) return;

                var assigneeIds = history.map(h => h.EmployeeID).filter(Boolean);
                
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
                            idValue: history[0].HistoryID
                        });
                    }
                }, 100);
            }

            function renderComments(comments) {
                if (!comments || comments.length === 0) {
                    $("#commentsContainer").html(`<p class="text-muted">Chưa có bình luận</p>`);
                    return;
                }

                var html = comments.map(function(c) {
                    return `
                        <div class="comment-item">
                            <div class="comment-header">
                                <span class="comment-author">${c.EmployeeName || "Unknown"}</span>
                                <span class="comment-date">${formatDate(c.CreatedDate)}</span>
                            </div>
                            <div class="comment-content">${c.Content || ""}</div>
                        </div>
                    `;
                }).join("");

                $("#commentsContainer").html(html);
            }

            function renderSubtasks(subtasks) {
                if (!subtasks || subtasks.length === 0) {
                    $("#subtaskTableBody").html(`<tr><td colspan="4" class="text-center text-muted">Không có công việc con</td></tr>`);
                    return;
                }

                var html = subtasks.map(function(st) {
                    var statusClass = st.SubtaskStatusCode == 3 ? "sts-3" : st.SubtaskStatusCode == 2 ? "sts-2" : "sts-1";
                    var statusText = st.SubtaskStatusCode == 3 ? "Hoàn thành" : st.SubtaskStatusCode == 2 ? "Đang làm" : "Chưa làm";

                    return `
                        <tr>
                            <td>${st.ChildTaskName || "Untitled"}</td>
                            <td>${st.AssignedToEmployeeName || "-"}</td>
                            <td>${st.SubtaskProgress || 0}%</td>
                            <td><span class="badge-sts ${statusClass}">${statusText}</span></td>
                        </tr>
                    `;
                }).join("");

                $("#subtaskTableBody").html(html);
            }

            function initializeControls() {
                // Initialize editable controls
                if (typeof hpaControlEditableRow === "function") {
                    hpaControlEditableRow("#detailTaskName", {
                        type: "input",
                        tableName: "tblTask",
                        columnName: "TaskName",
                        idColumnName: "TaskID",
                        idValue: currentTaskID
                    });

                    hpaControlEditableRow("#detailDescription", {
                        type: "textarea",
                        tableName: "tblTask",
                        columnName: "Description",
                        idColumnName: "TaskID",
                        idValue: currentTaskID
                    });
                }

                // Initialize status control
                if (typeof hpaControlField === "function" && taskData) {
                    hpaControlField("#status-control-wrapper", {
                        type: "select",
                        options: [
                            { value: 1, text: "Chưa làm" },
                            { value: 2, text: "Đang làm" },
                            { value: 3, text: "Hoàn thành" }
                        ],
                        selected: taskData.StatusCode || 1,
                        onChange: function(newVal) {
                            updateTaskStatus(newVal);
                        }
                    });
                }

                // Initialize date controls
                if (typeof hpaControlDateBox === "function" && taskData) {
                    hpaControlDateBox("#startDateField", {
                        type: "date",
                        field: "StartDate",
                        tableName: "tblTask_AssignHistory",
                        idColumnName: "TaskID",
                        idValue: currentTaskID
                    });

                    hpaControlDateBox("#dueDateField", {
                        type: "date",
                        field: "EndDate",
                        tableName: "tblTask_AssignHistory",
                        idColumnName: "TaskID",
                        idValue: currentTaskID
                    });
                }
            }

            function updateKPI() {
                var kpiVal = $("#txtUpdateKPI").val();
                if (!kpiVal) {
                    uiManager.showAlert({ type: "warning", message: "Vui lòng nhập giá trị KPI" });
                    return;
                }

                AjaxHPAParadise({
                    data: {
                        name: "sp_Task_UpdateKPI",
                        param: [
                            "TaskID", currentTaskID,
                            "LoginID", LoginID,
                            "ActualKPI", kpiVal,
                            "Note", ""
                        ]
                    },
                    success: function() {
                        uiManager.showAlert({ type: "success", message: "Cập nhật KPI thành công!" });
                        loadTaskDetail();
                        $("#txtUpdateKPI").val("");
                    }
                });
            }

            function updateTaskStatus(newStatus) {
                AjaxHPAParadise({
                    data: {
                        name: "sp_Common_SaveDataTable",
                        param: [
                            "TaskID", currentTaskID,
                            "LoginID", LoginID,
                            "NewStatus", newStatus
                        ]
                    },
                    success: function() {
                        uiManager.showAlert({ type: "success", message: "Cập nhật trạng thái thành công!" });
                        loadTaskDetail();
                    }
                });
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

        })();
    </script>
    ';
    SELECT @html AS html;
END
GO

EXEC sp_GenerateHTMLScript 'sp_Task_TaskDetail_html'