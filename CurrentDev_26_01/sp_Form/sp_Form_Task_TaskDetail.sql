GO
if object_id('[dbo].[sp_Task_TaskDetail_html]') is null
	EXEC ('CREATE PROCEDURE [dbo].[sp_Task_TaskDetail_html] as select 1')
GO

ALTER PROCEDURE [dbo].[sp_Task_TaskDetail_html]
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
            --shadow-sm: 0 1px 3px rgba(0, 0, 0, 0.02);
            --shadow-md: 0 4px 16px rgba(0, 0, 0, 0.08);
            --radius-md: 8px;
            --radius-lg: 12px;
        }

        #sp_Task_TaskDetail_html {
            max-width: 1400px;
            margin: 0 auto;
            padding: 24px;
            min-height: 100vh;
        }

        /* Header */
        #sp_Task_TaskDetail_html .detail-header {
            display: flex;
            align-items: center;
            gap: 16px;
            margin-bottom: 24px;
            padding: 20px;
            border-radius: var(--radius-lg);
            box-shadow: var(--shadow-sm);
        }

        #sp_Task_TaskDetail_html .task-title-section {
            flex: 1;
            display: flex;
            flex-direction: column;
            gap: 8px;
        }

        #sp_Task_TaskDetail_html .task-title-edit {
            font-size: 24px;
            font-weight: 700;
        }

        #sp_Task_TaskDetail_html .task-meta-quick {
            display: flex;
            gap: 16px;
            align-items: center;
            font-size: 14px;
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
            backdrop-filter: blur(50px);
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
            display: flex;
            align-items: center;
            gap: 10px;
            padding-bottom: 12px;
            border-bottom: 2px solid var(--border-color);
        }

        #sp_Task_TaskDetail_html .section-title i {
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
            border-radius: var(--radius-md);
            transition: all 0.2s;
        }

        #sp_Task_TaskDetail_html .meta-item:hover {
            box-shadow: var(--shadow-sm);
            transform: translateY(-2px);
        }

        #sp_Task_TaskDetail_html .meta-label {
            font-size: 11px;
            font-weight: 700;
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
            height: 100%;
            color: var(--task-primary);
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

        /* Sidebar */
        #sp_Task_TaskDetail_html .sidebar {
            display: flex;
            flex-direction: column;
            width: 100% !important;
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

            #sp_Task_TaskDetail_html .meta-grid {
                gap: 0;
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

        @media (max-width: 480px) {
            #sp_Task_TaskDetail_html .detail-header {
                flex-direction: column;
                align-items: flex-start;
                gap: 16px;
            }

            #sp_Task_TaskDetail_html .detail-actions {
                width: 100%;
                justify-content: flex-start;
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
            <div class="task-title-section">
                <div class="task-title-edit" id="PE1CCC4EC88E74587B8D01E069D9ABB21"></div>
                <div class="task-meta-quick">
                    <span class="gap-0"><i class="bi bi-hash"></i><span id="quickTaskID">-</span></span>
                    <span><i class="bi bi-calendar3"></i><span id="quickAssignStartDate">-</span></span>
                </div>
            </div>
            <div class="detail-actions">
                <div id="P3B5482B87A2E40BF959B1AA29B9EEFAA"></div>
            </div>
        </div>

        <div class="detail-body">
            <div class="main-content">
                <!-- Meta Info -->
                <div class="detail-section">
                    <div class="section-title">
                        <i class="bi bi-info-circle-fill"></i> Thông tin chi tiết
                    </div>
                    <div class="meta-grid" id="metaGrid">
                        <div class="meta-item">
                            <div class="meta-label">Độ ưu tiên</div>
                            <div class="meta-value" id="P3EADA94D60434DD48FBF2698DA4A7AD8"></div>
                        </div>
                        <div class="meta-item">
                            <div class="meta-label">Ngày bắt đầu</div>
                            <div class="meta-value" id="P417F08A8153847B892016E69D54F6F24"></div>
                        </div>
                        <div class="meta-item">
                            <div class="meta-label">Ngày hoàn thành</div>
                            <div class="meta-value" id="PFBDC7DA84569445DB49174801233F2C0"></div>
                        </div>
                        <div class="meta-item">
                            <div class="meta-label">Thời gian cam kết(h)</div>
                            <div class="meta-value" id="P85BC10A6D7414028A711C1635C73D1AE"></div>
                        </div>
                        <div class="meta-item">
                            <div class="meta-label">Người yêu cầu</div>
                            <div class="meta-value" id="P15492C5F9E894314B45430B6E5570CB2"></div>
                        </div>
                        <div class="meta-item">
                            <div class="meta-label">Chịu trách nhiệm chính</div>
                            <div class="meta-value" id="P73A515F07EA347E9A7521EDB79206CD9"></div>
                        </div>
                    </div>
                </div>

                <!-- Description -->
                <div class="detail-section">
                    <div class="section-title">
                        <i class="bi bi-file-text-fill"></i> Mô tả công việc
                    </div>
                    <div id="PA138923BF2734D64AE81616178380420" style="min-height:60px;line-height:1.6;"></div>
                </div>

                <!-- KPI Section -->
                <div class="detail-section">
                    <div class="section-title">
                        <i class="bi bi-graph-up-arrow"></i> Tiến độ KPI
                    </div>
                    <div class="kpi-section">
                        <div class="kpi-display">
                            <div class="kpi-current" id="P03BF9B69192E4913A055661D191CF71C"></div>
                            <div class="kpi-target" id="kpiTarget">
                                <span style="font-size:12px;font-weight:600;color:var(--text-secondary);">Target: </span>
                                <span style="font-size:12px;font-weight:700;color:var(--task-primary);" id="kpiTarget"></span>
                            </div>
                            <div class="kpi-value" id="kpiValue">0</div>
                            <div class="kpi-progress">
                                <div style="display:flex;justify-content:space-between;margin-bottom:4px;">
                                    <span style="font-size:12px;font-weight:600;color:var(--text-secondary);">Hoàn thành:</span>
                                    <span style="font-size:12px;font-weight:700;color:var(--task-primary);" id="kpiPercent"></span>
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
            </div>

            <div class="sidebar">
                <!-- Assignees -->
                <div class="detail-section">
                    <div class="section-title">
                        <i class="bi bi-people-fill"></i> Người thực hiện
                    </div>
                    <div id="PDAABC1BEBBEB4EEEAD346668733FB16E"></div>
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

            window["DataSource_Status"] = [
                { ID: 1, Name: "Pending" },
                { ID: 2, Name: "Doing" },
                { ID: 3, Name: "Done" }
            ];

            window["DataSource_AssignPriority"] = [
                { ID: 1, Name: "Bình thường" },
                { ID: 2, Name: "Quan trọng" },
                { ID: 3, Name: "Khẩn cấp" }
            ];

            // Accept parameters from caller
            if (window.sp_Task_TaskDetail_param && typeof window.sp_Task_TaskDetail_param === "object") {
                if (window.sp_Task_TaskDetail_param.TaskID) currentTaskID = window.sp_Task_TaskDetail_param.TaskID;
            } else if (window.sp_Task_TaskDetail_param && window.sp_Task_TaskDetail_param.TaskID) {
                currentTaskID = window.sp_Task_TaskDetail_param.TaskID;
            }

            attachHandlers();

            function attachHandlers() {
                $("#btnUpdateKPI").on("click", updateKPI);
                $("#btnAddComment").on("click", addComment);
            }

            function renderTaskDetail(task) {
                if (!task) return;
                
                $("#quickTaskID").text(task.TaskID || "-");
                $("#quickAssignStartDate").text(formatToDDMMYYYY(task.StartDate) || "-");

                // KPI Display - display-only elements
                const actualKPI = parseFloat(task.ActualKPI) || 0;
                const targetKPI = parseFloat(task.TargetKPI) || parseFloat(task.KPIPerDay) || 0;
                const kpiPercent = targetKPI > 0 ? Math.round((actualKPI / targetKPI) * 100) : 0;

                $("#kpiTarget").text(`Target: ${targetKPI} ${task.Unit || ""}`);
                $("#kpiPercent").text(kpiPercent + "%");
                $("#kpiProgressFill").css("width", Math.min(kpiPercent, 100) + "%");
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
                                <span class="comment-author" id=""></span>
                                <span class="comment-date" id=""></span>
                            </div>
                            <div class="comment-content">${escapeHtml(c.Content || c.CommentText || "")}</div>
                        </div>
                    `;
                }).join("");

                $("#commentsContainer").html(html);
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
                        <div class="attachment-item">
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

                // Use the buildTimelineHtml function
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

            function initFileDropzone() {
                // File dropzone is handled by loadUI from tblCommonControlType_Signed
                // No need for manual initialization here
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

            function escapeHtml(str) {
                if (str === null || str === undefined) return "";
                return String(str)
                    .replace(/&/g, "&amp;")
                    .replace(/</g, "&lt;")
                    .replace(/>/g, "&gt;")
                    .replace(/""/g, "&quot;")
                    .replace(/"/g, "&#039;");
            }

            // Build timeline HTML
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
            
            let DataSource = []
            
            // Load DataSource: EmployeeListAll_DataSetting_Custom
            if ("EmployeeListAll_DataSetting_Custom" && "EmployeeListAll_DataSetting_Custom".trim() !== "") {
                loadDataSourceCommon("EmployeeID", "EmployeeListAll_DataSetting_Custom", function(data) {
                    // Data được shared qua callback
                });
            }
        
            function loadDataSourceCommon(columnName, dataSourceSP, onSuccessCallback) {
                if (!columnName || !dataSourceSP || dataSourceSP.trim() === "") {
                    console.warn("[loadDataSourceCommon] Missing columnName or dataSourceSP");
                    return;
                }

                const dataSourceKey = "DataSource_" + columnName;
                // Sử dụng format: columnNameDataSourceLoaded để tương thích với code hiện tại
                const loadedKey = columnName + "DataSourceLoaded";

                // Kiểm tra nếu đã load rồi thì không load lại
                if (window[loadedKey] === true) {
                    if (typeof onSuccessCallback === "function") {
                        onSuccessCallback(window[dataSourceKey] || []);
                    }
                    return;
                }

                // Kiểm tra nếu đang load thì đợi
                if (window[loadedKey] === "loading") {
                    // Đợi một chút rồi thử lại
                    setTimeout(function() {
                        loadDataSourceCommon(columnName, dataSourceSP, onSuccessCallback);
                    }, 100);
                    return;
                }

                // Đánh dấu đang load để tránh load trùng lặp
                window[loadedKey] = "loading";

                AjaxHPAParadise({
                    data: {
                        name: dataSourceSP,
                        param: ["LoginID", LoginID, "LanguageID", LanguageID]
                    },
                    success: function(res) {
                        const json = typeof res === "string" ? JSON.parse(res) : res;
                        window[dataSourceKey] = (json.data && json.data[0]) || [];
                        window[loadedKey] = true;

                        // Gọi callback nếu có
                        if (typeof onSuccessCallback === "function") {
                            onSuccessCallback(window[dataSourceKey]);
                        }

                        // Tự động cập nhật control nếu có method setDataSource hoặc option
                        // Thử nhiều format tên instance để tương thích
                        const instanceVariants = [
                            "Instance" + columnName.charAt(0).toUpperCase() + columnName.slice(1) + "PE1CCC4EC88E74587B8D01E069D9ABB21",
                            "Instance" + columnName + "PE1CCC4EC88E74587B8D01E069D9ABB21",
                            "instance" + columnName.charAt(0).toUpperCase() + columnName.slice(1) + "PE1CCC4EC88E74587B8D01E069D9ABB21"
                        ];

                        for (let i = 0; i < instanceVariants.length; i++) {
                            const instanceKey = instanceVariants[i];
                            if (window[instanceKey]) {
                                const instanceObj = window[instanceKey];

                                // Kiểm tra nếu đây là dxDataGrid
                                if (typeof instanceObj.dxDataGrid === "function" || instanceObj.option && instanceObj.option("dataSource") !== undefined) {
                                    try {
                                        // Nếu là Grid, apply dynamic config
                                        const gridConfigFn = window["getGridConfig_" + columnName.charAt(0).toUpperCase() + columnName.slice(1)];
                                        if (typeof gridConfigFn === "function") {
                                            const gridConfig = gridConfigFn(window[dataSourceKey]);
                                            instanceObj.option("remoteOperations", gridConfig.remoteOperations);
                                            instanceObj.option("paging.pageSize", gridConfig.pageSize);
                                            instanceObj.option("pager.allowedPageSizes", gridConfig.allowedPageSizes);
                                        }

                                        instanceObj.option("dataSource", window[dataSourceKey]);
                                        break;
                                    } catch(e) {
                                        console.warn("[LoadDataSourceCommon] Grid config error:", e);
                                        // Fallback: just set data source
                                        instanceObj.option("dataSource", window[dataSourceKey]);
                        break;
                                    }
                                } else if (typeof instanceObj.setDataSource === "function") {
                                    instanceObj.setDataSource(window[dataSourceKey]);
                                    break;
                                } else if (typeof instanceObj.option === "function") {
                                    try {
                                        instanceObj.option("dataSource", window[dataSourceKey]);
                                        break;
                                    } catch(e) {
                                        // Continue to next variant
                                    }
                                }
                            }
                        }
                    },
                    error: function(err) {
                        console.error("[loadDataSourceCommon] Failed to load datasource for", columnName, ":", err);
                        window[loadedKey] = false;
                        if (typeof onSuccessCallback === "function") {
                            onSuccessCallback([]);
                        }
                    }
                });
            }
        
                
            // ValidationEngine utility for validation messages
            window.ValidationEngine = window.ValidationEngine || {};
            window.ValidationEngine.getRequiredMessage = function(displayName) {
                return "Không được để trống " + (displayName || "trường này");
            };
    
            '
            +(select loadUI from tblCommonControlType_Signed where UID = 'PE1CCC4EC88E74587B8D01E069D9ABB21')
            +(select loadUI from tblCommonControlType_Signed where UID = 'P3B5482B87A2E40BF959B1AA29B9EEFAA')
            +(select loadUI from tblCommonControlType_Signed where UID = 'P3EADA94D60434DD48FBF2698DA4A7AD8')
            +(select loadUI from tblCommonControlType_Signed where UID = 'P417F08A8153847B892016E69D54F6F24')
            +(select loadUI from tblCommonControlType_Signed where UID = 'PFBDC7DA84569445DB49174801233F2C0')
            +(select loadUI from tblCommonControlType_Signed where UID = 'P85BC10A6D7414028A711C1635C73D1AE')
            +(select loadUI from tblCommonControlType_Signed where UID = 'P15492C5F9E894314B45430B6E5570CB2')
            +(select loadUI from tblCommonControlType_Signed where UID = 'P73A515F07EA347E9A7521EDB79206CD9')
            +(select loadUI from tblCommonControlType_Signed where UID = 'P03BF9B69192E4913A055661D191CF71C')
            +(select loadUI from tblCommonControlType_Signed where UID = 'PDAABC1BEBBEB4EEEAD346668733FB16E')
            +(select loadUI from tblCommonControlType_Signed where UID = 'PA138923BF2734D64AE81616178380420') +N'
             window.currentRecordID_HistoryID = null; window.currentRecordID_TaskID = null;
            

            function ReloadData() {
                AjaxHPAParadise({
                    data: {
                        name: "sp_Task_GetDetail",
                        param: ["TaskID", window.sp_Task_TaskDetail_param.TaskID]
                    },
                    success: function (res) {
                        const json = typeof res === "string" ? JSON.parse(res) : res;
                        const results = Array.isArray(json?.data?.[0])
                            ? json.data[0]
                            : (json?.data?.[0] ? [json.data[0]] : []);

                        const obj = results.length === 1 ? results[0] : (results[0] || null);

                        
                         if (obj) { window.currentRecordID_HistoryID = (obj.HistoryID !== undefined && obj.HistoryID !== null) ? obj.HistoryID : window.currentRecordID_HistoryID; } if (obj) { window.currentRecordID_TaskID = (obj.TaskID !== undefined && obj.TaskID !== null) ? obj.TaskID : window.currentRecordID_TaskID; }
                        DataSource = results;
                        '
                        +(select loadData from tblCommonControlType_Signed where UID = 'PE1CCC4EC88E74587B8D01E069D9ABB21')
                        +(select loadData from tblCommonControlType_Signed where UID = 'P3B5482B87A2E40BF959B1AA29B9EEFAA')
                        +(select loadData from tblCommonControlType_Signed where UID = 'P3EADA94D60434DD48FBF2698DA4A7AD8')
                        +(select loadData from tblCommonControlType_Signed where UID = 'P417F08A8153847B892016E69D54F6F24')
                        +(select loadData from tblCommonControlType_Signed where UID = 'PFBDC7DA84569445DB49174801233F2C0')
                        +(select loadData from tblCommonControlType_Signed where UID = 'P85BC10A6D7414028A711C1635C73D1AE')
                        +(select loadData from tblCommonControlType_Signed where UID = 'P15492C5F9E894314B45430B6E5570CB2')
                        +(select loadData from tblCommonControlType_Signed where UID = 'P73A515F07EA347E9A7521EDB79206CD9')
                        +(select loadData from tblCommonControlType_Signed where UID = 'P03BF9B69192E4913A055661D191CF71C')
                        +(select loadData from tblCommonControlType_Signed where UID = 'PDAABC1BEBBEB4EEEAD346668733FB16E')
                        +(select loadData from tblCommonControlType_Signed where UID = 'PA138923BF2734D64AE81616178380420') +N'
                    }
                })
            }
            ReloadData()
        })();
    </script>
    ';
    SELECT @html AS html;
    --EXEC sp_GenerateHTMLScript 'sp_Task_TaskDetail_html'
END
GO

EXEC sptblCommonControlType_Signed 'sp_Task_TaskDetail_html'
EXEC sp_GenerateHTMLScript_new'sp_Task_TaskDetail_html'