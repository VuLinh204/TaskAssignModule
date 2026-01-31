USE Paradise_Dev
GO
if object_id('[dbo].[sp_Task_TaskList_html]') is null
	EXEC ('CREATE PROCEDURE [dbo].[sp_Task_TaskList_html] as select 1')
GO
ALTER PROCEDURE [dbo].[sp_Task_TaskList_html]
@LoginID    INT = 3,
@LanguageID VARCHAR(2) = 'VN',
@isWeb      INT = 1
AS
BEGIN
SET NOCOUNT ON;
DECLARE @html NVARCHAR(MAX);
SET @html = N'
    <style>
        .modal {
            top: 40px;
        }
        
        /* Status breadcrumb - modern refined style */
        #sp_Task_TaskList_html .status-steps {
            display: flex;
            background: #fdfdfd;
            border-radius: 10px;
            padding: 2px 5px;
            gap: 2px;
            border: 1px solid #e9ecef;
            box-shadow: inset 0 1px 2px rgba(0, 0, 0, 0.03);
        }

        #sp_Task_TaskList_html .status-step {
            flex: 1;
            padding: 10px 16px;
            font-size: 0.8rem;
            font-weight: 600;
            text-transform: uppercase;
            letter-spacing: 0.05em;
            text-align: center;
            border-radius: 8px;
            cursor: pointer;
            transition: all 0.25s cubic-bezier(0.4, 0, 0.2, 1);
            position: relative;
            color: #adb5bd;
            background: transparent;
            border: none;
            display: flex;
            align-items: center;
            justify-content: center;
            gap: 6px;
            white-space: nowrap;
        }

        #sp_Task_TaskList_html .status-step:hover {
            color: var(--bs-success);
            background: rgba(25, 135, 84, 0.05);
        }

        #sp_Task_TaskList_html .status-step.active {
            background: var(--bs-success);
            color: white !important;
            box-shadow: 0 4px 12px rgba(25, 135, 84, 0.25);
            transform: scale(1.02);
            z-index: 2;
        }

        #sp_Task_TaskList_html .status-step.completed {
            color: var(--bs-success);
            background: rgba(25, 135, 84, 0.08);
        }

        #sp_Task_TaskList_html .status-step:not(:last-child)::after {
            content: "\F285";
            font-family: "bootstrap-icons";
            margin-left: auto;
            font-size: 0.9rem;
            opacity: 0.2;
            transition: opacity 0.2s;
        }

        #sp_Task_TaskList_html .status-step.active::after,
        #sp_Task_TaskList_html .status-step.completed::after {
            opacity: 0.6;
            color: inherit;
        }

        /* Activity Timeline - Modernized */
        #sp_Task_TaskList_html .activity-panel {
            background: #f8f9fa;
            border-left: 1px solid #dee2e6;
            display: flex;
            flex-direction: column;
            height: 100%;
        }

        #sp_Task_TaskList_html .timeline-section {
            padding: 1.5rem;
            overflow-y: auto;
            flex-grow: 1;
        }

        #sp_Task_TaskList_html .timeline-item {
            position: relative;
            padding-left: 24px;
            margin-bottom: 1.5rem;
        }

        #sp_Task_TaskList_html .timeline-item::before {
            content: "";
            position: absolute;
            left: 0;
            top: 4px;
            width: 10px;
            height: 10px;
            border-radius: 50%;
            background: var(--bs-success);
            border: 2px solid white;
            box-shadow: 0 0 0 2px rgba(25, 135, 84, 0.2);
            z-index: 1;
        }

        #sp_Task_TaskList_html .timeline-item::after {
            content: "";
            position: absolute;
            left: 4px;
            top: 14px;
            bottom: -20px;
            width: 2px;
            background: #dee2e6;
        }

        #sp_Task_TaskList_html .timeline-item:last-child::after {
            display: none;
        }

        #sp_Task_TaskList_html .timeline-date-separator {
            display: flex;
            align-items: center;
            text-align: center;
            margin: 1.5rem 0;
            color: #6c757d;
            font-size: 0.75rem;
            font-weight: 600;
            text-transform: uppercase;
            letter-spacing: 0.5px;
        }

        #sp_Task_TaskList_html .timeline-date-separator::before,
        #sp_Task_TaskList_html .timeline-date-separator::after {
            content: "";
            flex: 1;
            border-bottom: 1px solid #dee2e6;
        }

        #sp_Task_TaskList_html .timeline-date-separator:not(:empty)::before {
            margin-right: 1rem;
        }

        #sp_Task_TaskList_html .timeline-date-separator:not(:empty)::after {
            margin-left: 1rem;
        }

        #sp_Task_TaskList_html .timeline-date-separator.today {
            color: var(--bs-danger);
        }

        /* Nav Tabs Custom */
        #sp_Task_TaskList_html .nav-tabs-custom {
            border-bottom: 2px solid #dee2e6;
            margin-bottom: 1.5rem;
        }

        #sp_Task_TaskList_html .nav-tabs-custom .nav-link {
            border: none;
            color: #6c757d;
            font-weight: 500;
            padding: 0.75rem 1.25rem;
            position: relative;
            transition: all 0.2s;
        }

        #sp_Task_TaskList_html .nav-tabs-custom .nav-link:hover {
            color: var(--bs-success);
        }

        #sp_Task_TaskList_html .nav-tabs-custom .nav-link.active {
            color: var(--bs-success);
            background: transparent;
        }

        #sp_Task_TaskList_html .nav-tabs-custom .nav-link.active::after {
            content: "";
            position: absolute;
            bottom: -2px;
            left: 0;
            right: 0;
            height: 2px;
            background: var(--bs-success);
        }

        /* Re-adding missing components colors */
        #sp_Task_TaskList_html .view-btn {
            border: none;
        }

        #sp_Task_TaskList_html .view-btn.active {
            background-color: var(--bs-success) !important;
            color: white !important;
        }

        #sp_Task_TaskList_html .task-card:hover {
            border-color: var(--bs-success) !important;
            box-shadow: 0 4px 12px rgba(0, 0, 0, 0.1);
        }

        /* Modal Layout */
        #sp_Task_TaskList_html .task-modal-header {
            padding: 1rem 1.5rem;
            border-bottom: 1px solid #dee2e6;
        }

        #sp_Task_TaskList_html .task-modal-body {
            padding: 0;
            display: flex;
            overflow: hidden;
            height: 75vh;
        }

        #sp_Task_TaskList_html .main-task-content {
            flex: 1;
            padding: 1.5rem;
            overflow-y: auto;
        }

        #sp_Task_TaskList_html .comment-box {
            background: white;
            border: 1px solid #dee2e6;
            border-radius: 8px;
            padding: 0.5rem;
            transition: border-color 0.2s;
        }

        #sp_Task_TaskList_html .comment-box:focus-within {
            border-color: var(--bs-success);
        }

        #sp_Task_TaskList_html .comment-avatar {
            width: 32px;
            height: 32px;
            border-radius: 50%;
            background: #e7f1ff;
            color: var(--bs-success);
            display: flex;
            align-items: center;
            justify-content: center;
            font-weight: 600;
            font-size: 0.8rem;
        }

        #sp_Task_TaskList_html .btn-primary {
            background-color: var(--bs-success);
            border-color: var(--bs-success);
        }

        #sp_Task_TaskList_html .btn-primary:hover {
            background-color: #157347;
            border-color: #146c43;
        }

        /* Interactive elements cursor */
        #sp_Task_TaskList_html .cursor-pointer,
        #sp_Task_TaskList_html .status-step,
        #sp_Task_TaskList_html .nav-link,
        #sp_Task_TaskList_html .editable-field,
        #sp_Task_TaskList_html .timeline-item,
        #sp_Task_TaskList_html .list-group-item-action,
        #sp_Task_TaskList_html .btn-link,
        #sp_Task_TaskList_html .badge[onclick],
        #sp_Task_TaskList_html .view-subtasks-card-btn,
        #sp_Task_TaskList_html .view-details-card-btn,
        #sp_Task_TaskList_html .subtask-action-btn {
            cursor: pointer !important;
        }

        /* Back Button Style */
        #sp_Task_TaskList_html .btn-back {
            display: inline-flex;
            align-items: center;
            gap: 6px;
            padding: 4px 12px;
            font-size: 0.8rem;
            font-weight: 500;
            color: #495057;
            text-decoration: none;
            border: 1px solid #dee2e6;
            border-radius: 6px;
            background: white;
            transition: all 0.2s cubic-bezier(0.4, 0, 0.2, 1);
            margin-right: 12px;
            box-shadow: 0 1px 2px rgba(0, 0, 0, 0.05);
        }

        #sp_Task_TaskList_html .btn-back:hover {
            background-color: #f8f9fa;
            color: var(--bs-success);
            border-color: var(--bs-success);
            box-shadow: 0 2px 4px rgba(0, 0, 0, 0.08);
            transform: translateY(-1px);
        }

        #sp_Task_TaskList_html .btn-back i {
            font-size: 0.9rem;
        }

        /* Subtask action buttons in modal */
        #sp_Task_TaskList_html .subtask-actions {
            opacity: 0;
            transition: opacity 0.2s;
        }

        #sp_Task_TaskList_html .list-group-item:hover .subtask-actions {
            opacity: 1;
        }

        #sp_Task_TaskList_html .subtask-action-btn {
            padding: 4px 8px;
            border-radius: 4px;
            color: #6c757d;
            transition: all 0.2s;
            border: none;
            background: transparent;
        }

        #sp_Task_TaskList_html .subtask-action-btn:hover {
            background: rgba(0, 0, 0, 0.05);
        }

        #sp_Task_TaskList_html .subtask-action-btn.view:hover {
            color: var(--bs-success);
        }

        #sp_Task_TaskList_html .subtask-action-btn.delete:hover {
            color: var(--bs-danger);
        }

        /* Card meta buttons styling */
        #sp_Task_TaskList_html .view-subtasks-card-btn,
        #sp_Task_TaskList_html .view-details-card-btn {
            background: #f8f9fa;
            border: 1px solid #e9ecef;
            border-radius: 4px;
            padding: 4px 8px;
            font-size: 0.75rem;
            color: #6c757d;
            display: flex;
            align-items: center;
            gap: 4px;
            transition: all 0.2s;
        }

        #sp_Task_TaskList_html .view-subtasks-card-btn:hover,
        #sp_Task_TaskList_html .view-details-card-btn:hover {
            border-color: var(--bs-success);
            color: var(--bs-success);
            background: white;
        }

        #sp_Task_TaskList_html .parent-link-badge {
            font-size: 0.7rem;
            text-transform: uppercase;
            letter-spacing: 0.5px;
            padding: 4px 8px;
            background: #f8f9fa;
            color: #6c757d;
            border: 1px solid #dee2e6;
            border-radius: 4px;
            text-decoration: none;
            display: inline-flex;
            align-items: center;
            gap: 4px;
        }

        #sp_Task_TaskList_html .parent-link-badge:hover {
            background: #e9ecef;
            color: var(--bs-success);
            border-color: var(--bs-success);
        }
        /* Custom Modal System */
        .custom-modal-overlay {
            position: fixed;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            background: rgba(0, 0, 0, 0.4);
            backdrop-filter: blur(4px);
            z-index: 1050;
            display: none;
            justify-content: center;
            align-items: center;
            opacity: 0;
            transition: opacity 0.3s ease;
        }

        .custom-modal-overlay.active {
            display: flex;
            opacity: 1;
        }

        .custom-modal-container {
            backdrop-filter: blur(50px);
            border-radius: 16px;
            box-shadow: 0 25px 50px -12px rgba(0, 0, 0, 0.25);
            width: 100%;
            max-width: 600px;
            max-height: 90vh;
            display: flex;
            flex-direction: column;
            transform: scale(0.95);
            opacity: 0;
            transition: all 0.3s cubic-bezier(0.16, 1, 0.3, 1);
            overflow: hidden;
            margin: 1rem;
        }

        .custom-modal-container.large {
            max-width: 90vw;
        }

        .custom-modal-overlay.active .custom-modal-container {
            transform: scale(1);
            opacity: 1;
        }

        .custom-modal-header {
            padding: 1.5rem;
            border-bottom: 1px solid #f1f5f9;
            display: flex;
            justify-content: space-between;
            align-items: flex-start;
            backdrop-filter: blur(50px);
        }

        .custom-modal-title {
            font-size: 1.25rem;
            font-weight: 700;
            margin: 0;
            line-height: 1.4;
        }

        .custom-modal-close {
            background: transparent;
            border: none;
            color: #94a3b8;
            cursor: pointer;
            padding: 0.5rem;
            border-radius: 50%;
            transition: all 0.2s;
            display: flex;
            align-items: center;
            justify-content: center;
        }

        .custom-modal-close:hover {
            color: #ef4444;
        }

        .custom-modal-body {
            padding: 1.5rem;
            overflow-y: auto;
            flex-grow: 1;
            /* Scrollbar styling */
            scrollbar-width: thin;
            scrollbar-color: #cbd5e1 transparent;
        }

        .custom-modal-body::-webkit-scrollbar {
            width: 6px;
        }

        .custom-modal-body::-webkit-scrollbar-thumb {
            background-color: #cbd5e1;
            border-radius: 3px;
        }

        .custom-modal-footer {
            padding: 1.25rem 1.5rem;
            background: #f8fafc;
            border-top: 1px solid #f1f5f9;
            display: flex;
            justify-content: flex-end;
            gap: 1rem;
        }

        /* Form Elements Enhancement for Modals */
        .custom-form-group {
            margin-bottom: 1.25rem;
        }

        .custom-form-label {
            display: block;
            margin-bottom: 0.5rem;
            font-weight: 500;
            color: #475569;
            font-size: 0.875rem;
        }

        .custom-input, .custom-select, .custom-textarea {
            width: 100%;
            padding: 0.75rem 1rem;
            border-radius: 0.5rem;
            border: 1px solid #e2e8f0;
            color: #1e293b;
            font-size: 0.95rem;
            transition: all 0.2s;
            outline: none;
        }

        .custom-input:focus, .custom-select:focus, .custom-textarea:focus {
            border-color: #0f172a; /* Dark Highlight */
            box-shadow: 0 0 0 2px rgba(15, 23, 42, 0.1);
        }
        
        .custom-btn {
            padding: 0.6rem 1.2rem;
            border-radius: 0.5rem;
            font-weight: 600;
            cursor: pointer;
            transition: all 0.2s;
            border: none;
            font-size: 0.9rem;
        }

        .custom-btn-secondary {
            background: #fff;
            border: 1px solid #e2e8f0;
            color: #64748b;
        }

        .custom-btn-secondary:hover {
            background: #f8fafc;
            color: #475569;
            border-color: #cbd5e1;
        }

        .custom-btn-primary {
            background: #0f172a; /* Slate 900 */
            color: #fff;
        }

        .custom-btn-primary:hover {
            background: #1e293b; /* Slate 800 */
            transform: translateY(-1px);
            box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1);
        }
    </style>
    <div id="sp_Task_TaskList_html">
        <div class="d-flex flex-column vh-100 overflow-hidden">
            <div class="flex-grow-1 overflow-hidden d-flex">
                <!-- Main Content Area -->
                <main class="flex-grow-1 p-md-4 d-flex flex-column overflow-hidden" style="padding-top: 2rem;">
                    <div id="mode-switcher" class="nav-tabs-custom d-flex gap-3 mb-3">
                        <button class="nav-link active" data-mode="projects">Projects</button>
                        <button class="nav-link" data-mode="templates">Templates Library</button>
                        <button class="nav-link" data-mode="timeline">Overall Timeline</button>
                    </div>
                    <div id="main-header" class="mb-3 d-flex justify-content-between align-items-center">
                        <div id="breadcrumb" class="small text-muted mb-2" style="min-height: 20px;"></div>
                        <div class="d-flex justify-content-between align-items-center">
                            <div id="view-switcher" class="d-flex align-items-center gap-2 rounded"
                                style="background-color: rgba(203,213,225,.5);">
                                <!-- View switcher buttons will be inserted here -->
                            </div>
                        </div>
                    </div>

                    <div id="view-container" class="flex-grow-1 overflow-auto">
                        <!-- Active view will be rendered here -->
                    </div>
                </main>
            </div>

            <!-- Custom Task Details Modal -->
            <div id="task-modal" class="custom-modal-overlay">
                <div class="custom-modal-container large bg-body">
                    <div class="custom-modal-header">
                        <div class="flex-grow-1">
                            <h5 id="modal-task-name" class="custom-modal-title editable-field" data-field="TaskName">Task Details</h5>
                            <div id="task-nav-bar" class="d-flex gap-2 mt-2 flex-wrap"></div>
                        </div>
                        <div class="d-flex gap-2 align-items-center">
                            <button id="delete-task-btn" class="custom-btn custom-btn-secondary" type="button" title="Delete Task">
                                <i class="bi bi-trash text-danger"></i>
                            </button>
                            <button type="button" class="custom-modal-close" onclick="closeModal(''task-modal'')">
                                <i class="bi bi-x-lg"></i>
                            </button>
                        </div>
                    </div>
                    <div id="modal-content" class="custom-modal-body"></div>
                </div>
            </div>

            <!-- Custom Create/Edit Task Modal -->
            <div id="create-task-modal" class="custom-modal-overlay">
                <div class="custom-modal-container">
                    <form id="create-task-form">
                        <div class="custom-modal-header">
                            <h5 id="create-modal-title" class="custom-modal-title">Create New Task</h5>
                            <button type="button" class="custom-modal-close" onclick="closeModal(''create-task-modal'')">
                                <i class="bi bi-x-lg"></i>
                            </button>
                        </div>
                        <div class="custom-modal-body">
                            <div class="custom-form-group">
                                <label class="custom-form-label" for="create-task-name">Task Name</label>
                                <input type="text" class="custom-input" id="create-task-name" placeholder="Enter task name" required>
                            </div>
                            <div class="custom-form-group">
                                <label class="custom-form-label" for="create-task-desc">Description</label>
                                <textarea class="custom-textarea" id="create-task-desc" placeholder="Enter description" rows="4"></textarea>
                            </div>
                            <div class="row g-3">
                                <div class="col-md-6">
                                    <div class="custom-form-group mb-0">
                                        <label class="custom-form-label">Assignee</label>
                                        <select id="create-task-assignee" class="custom-select" required>
                                            <option value="">Select Assignee</option>
                                        </select>
                                    </div>
                                </div>
                                <div class="col-md-6">
                                    <div class="custom-form-group mb-0">
                                        <label class="custom-form-label">Priority</label>
                                        <select id="create-task-priority" class="custom-select">
                                            <option>Low</option>
                                            <option selected>Medium</option>
                                            <option>High</option>
                                        </select>
                                    </div>
                                </div>
                            </div>
                        </div>
                        <div class="custom-modal-footer">
                            <button type="button" class="custom-btn custom-btn-secondary" onclick="closeModal(''create-task-modal'')">Cancel</button>
                            <button type="submit" class="custom-btn custom-btn-primary">Save Task</button>
                        </div>
                    </form>
                </div>
            </div>

            <!-- Custom Add Project Modal -->
            <div id="add-project-modal" class="custom-modal-overlay">
                <div class="custom-modal-container">
                    <form id="add-project-form">
                        <div class="custom-modal-header">
                            <h5 class="custom-modal-title">Add New Project</h5>
                            <button type="button" class="custom-modal-close" onclick="closeModal(''add-project-modal'')">
                                <i class="bi bi-x-lg"></i>
                            </button>
                        </div>
                        <div class="custom-modal-body">
                            <div class="custom-form-group">
                                <label class="custom-form-label" for="add-project-name">Project Name</label>
                                <input type="text" class="custom-input" id="add-project-name" placeholder="Enter project name" required>
                            </div>
                        </div>
                        <div class="custom-modal-footer">
                            <button type="button" class="custom-btn custom-btn-secondary" onclick="closeModal(''add-project-modal'')">Cancel</button>
                            <button type="submit" class="custom-btn custom-btn-primary">Create Project</button>
                        </div>
                    </form>
                </div>
            </div>

            <!-- Custom Assignment Modal -->
            <div id="mdlAssign" class="custom-modal-overlay">
                <div class="custom-modal-container large bg-body">
                    <div class="custom-modal-header">
                        <h5 class="custom-modal-title">Giao việc bổ sung</h5>
                        <button type="button" class="custom-modal-close" onclick="closeModal(''mdlAssign'')">
                            <i class="bi bi-x-lg"></i>
                        </button>
                    </div>
                    <div class="custom-modal-body">
                        <div class="row g-3 mb-3">
                            <div class="col-12">
                                <label class="custom-form-label">Chọn từ mẫu (Template)</label>
                                <select id="assign-template" class="custom-select" onchange="loadSubtasksFromTemplate(this.value)">
                                    <option value="">-- Không dùng mẫu --</option>
                                </select>
                            </div>
                            <div class="col-md-6">
                                <label class="custom-form-label">Người giao</label>
                                <select id="assign-requester" class="custom-select">
                                </select>
                            </div>
                            <div class="col-md-6">
                                <label class="custom-form-label">Người thực hiện</label>
                                <select id="assign-assignee" class="custom-select">
                                </select>
                            </div>
                            <div class="col-md-6">
                                <label class="custom-form-label">Ngày yêu cầu</label>
                                <input type="date" id="assign-date" class="custom-input">
                            </div>
                            <div class="col-md-6">
                                <label class="custom-form-label">Giờ cam kết</label>
                                <input type="number" id="assign-hours" class="custom-input" step="0.5">
                            </div>
                        </div>
                        <div class="mb-3">
                            <h6 class="font-weight-bold mb-2">Danh sách việc phụ</h6>
                            <div id="assign-subtasks-list" class="list-group mb-2 custom-list-group">
                            </div>
                            <div class="d-flex gap-2">
                                <input type="text" id="assign-new-task-name" class="custom-input" placeholder="Tên việc phụ...">
                                <button class="custom-btn custom-btn-secondary" type="button" id="btn-add-assign-subtask">Thêm</button>
                            </div>
                        </div>
                    </div>
                    <div class="custom-modal-footer">
                        <button type="button" class="custom-btn custom-btn-secondary" onclick="closeModal(''mdlAssign'')">Đóng</button>
                        <button type="button" class="custom-btn custom-btn-primary" id="btn-submit-assignment">Hoàn tất giao việc</button>
                    </div>
                </div>
            </div>
        </div>

        <!-- data.js -->
        <script>
            (function () {
                "use strict";
                const LoginID = window.LoginID;
                const LanguageID = window.LanguageID;

                // --- DATABASE DATA (State) ---
                let projects_Linh = [];
                let employees_Linh = [];
                let tasks = [];
                let positions_Linh = [];
                let tags_Linh = [];
                let taskProcesses_Linh = [];
                let comments_Linh = [];
                let templates_Linh = [];
                let DataSource = [];

                window.DataSource_Status = [{ID:0, Name:"To Do"},{ID:1, Name:"In Progress"},{ID:2, Name:"Testing"},{ID:3, Name:"Done"}]

                function fetchData(callback) {
                    AjaxHPAParadise({
                        data: {
                            name: "sp_Task_GetData",
                            param: ["LoginID", LoginID, "LanguageID", LanguageID]
                        },
                        success: (res) => {
                            const data = (typeof res === "string" ? JSON.parse(res) : res).data?.[0]?.[0] || {};
                            projects_Linh = typeof data.Projects === "string" ? JSON.parse(data.Projects) : (data.Projects || []);
                            employees_Linh = typeof data.Employees === "string" ? JSON.parse(data.Employees) : (data.Employees || []);
                            tasks = typeof data.Tasks === "string" ? JSON.parse(data.Tasks) : (data.Tasks || []);
                            positions_Linh = typeof data.Positions === "string" ? JSON.parse(data.Positions) : (data.Positions || []);
                            tags_Linh = typeof data.Tags === "string" ? JSON.parse(data.Tags) : (data.Tags || []);
                            taskProcesses_Linh = typeof data.Processes === "string" ? JSON.parse(data.Processes) : (data.Processes || []);
                            comments_Linh = typeof data.Comments === "string" ? JSON.parse(data.Comments) : (data.Comments || []);
                            templates_Linh = typeof data.Templates === "string" ? JSON.parse(data.Templates) : (data.Templates || []);
                            if (callback) callback(res);
                            else render();
                        }
                    });
                }

                function ReloadData() {
                    fetchData(handleResultReload);
                }

                // --- STATE MANAGEMENT ---
                let navigationStack = [];
                let currentViewMode = "list";
                let currentAppMode = "projects"; // "projects", "templates", "timeline"
                let draggedTaskId = null;
                const KANBAN_STATUSES = ["To Do", "In Progress", "Testing", "Done"];
                const PRIORITY_OPTIONS = ["Low", "Medium", "High"];
                let currentEditingTaskId = null;
                let currentAssignParentTaskId = null;
                let assignSubtasks = [];

                // Bootstrap Modal instances removed (replaced by custom modals)

                // --- DOM ELEMENT REFERENCES ---
                const breadcrumbEl = document.getElementById("breadcrumb");
                const viewSwitcherEl = document.getElementById("view-switcher");
                const viewContainerEl = document.getElementById("view-container");

                // Modals
                const taskModalEl = document.getElementById("task-modal");
                const modalTaskNameEl = document.getElementById("modal-task-name");
                const modalContentEl = document.getElementById("modal-content");
                const deleteTaskBtn = document.getElementById("delete-task-btn");

                const createTaskModalEl = document.getElementById("create-task-modal");
                const createTaskForm = document.getElementById("create-task-form");
                const createModalTitleEl = document.getElementById("create-modal-title");

                const addProjectModalEl = document.getElementById("add-project-modal");
                const addProjectForm = document.getElementById("add-project-form");
                const modeSwitcherEl = document.getElementById("mode-switcher");

                // --- UTILITY FUNCTIONS ---
                const findEmployee = (id) => employees_Linh.find((e) => e.EmployeeID === id) || { FullName: "Unassigned" };

                const getPriorityClass = (priority) => {
                    switch (priority) {
                        case "High": return "priority-high";
                        case "Medium": return "priority-medium";
                        case "Low": return "priority-low";
                        default: return "bg-secondary-subtle";
                    }
                };

                const hasSubtasks = (taskId) => tasks.some((t) => t.ParentTaskID === taskId);

                function formatDate(dateString) {
                    const date = new Date(dateString);
                    const now = new Date();
                    const diff = now - date;
                    const minutes = Math.floor(diff / 60000);
                    const hours = Math.floor(diff / 3600000);
                    const days = Math.floor(diff / 86400000);

                    if (minutes < 1) return "Just now";
                    if (minutes < 60) return `${minutes}m ago`;
                    if (hours < 24) return `${hours}h ago`;
                    if (days < 7) return `${days}d ago`;
                    return date.toLocaleDateString();
                }

                function render() {
                    const context = navigationStack[navigationStack.length - 1];
                    updateModeSwitcher();
                    renderBreadcrumb();
                    renderViewSwitcher();

                    if (currentAppMode === "templates") {
                        if (!context) {
                            renderTemplatesView();
                        } else if (context.type === "template") {
                            const template = templates_Linh.find(t => t.TemplateID === context.id);
                            if (template) {
                                renderTemplateDetail(template);
                            }
                        }
                        return;
                    }

                    if (currentAppMode === "timeline") {
                        renderOverallTimeline();
                        return;
                    }

                    if (!context) {
                        renderProjectsView(projects_Linh);
                        return;
                    }

                    if (context.type === "project") {
                        const project = projects_Linh.find((p) => p.ProjectID === context.id);
                        if (!project) return;
                        renderProjectDetail(project);
                        return;
                    }

                    if (context.type === "task") {
                        const task = tasks.find((t) => t.TaskID === context.id);
                        if (!task) return;
                        const itemsToRender = tasks.filter((t) => t.ParentTaskID === context.id);

                        switch (currentViewMode) {
                            case "list":
                                renderListView(itemsToRender);
                                break;
                            case "chart":
                                renderChartView(itemsToRender);
                                break;
                            case "kanban":
                            default:
                                renderKanbanView(itemsToRender);
                                break;
                        }
                    }
                }

                function updateModeSwitcher() {
                    if (modeSwitcherEl) {
                        modeSwitcherEl.querySelectorAll(".nav-link").forEach(btn => {
                            btn.classList.toggle("active", btn.dataset.mode === currentAppMode);
                        });
                    }
                }

                // --- BREADCRUMB & VIEW SWITCHER ---
                function renderBreadcrumb() {
                    breadcrumbEl.innerHTML = "";

                    // Show Back Button if we are deep in the navigation (at least one project or task selected)
                    if (navigationStack.length > 0) {
                        const backBtn = document.createElement("button");
                        backBtn.className = "btn-back cursor-pointer";
                        backBtn.innerHTML = `<i class="bi bi-arrow-left-short"></i> Back`;
                        backBtn.onclick = () => {
                            navigationStack.pop();
                            render();
                        };
                        breadcrumbEl.appendChild(backBtn);
                    }

                    const rootCrumb = document.createElement("span");
                    rootCrumb.className = "cursor-pointer text-decoration-underline";
                    rootCrumb.textContent = currentAppMode === "templates" ? "Templates Library" : "Projects";
                    rootCrumb.addEventListener("click", () => {
                        navigationStack = [];
                        render();
                    });
                    breadcrumbEl.appendChild(rootCrumb);

                    navigationStack.forEach((item, index) => {
                        const separator = document.createElement("span");
                        separator.className = "mx-2";
                        separator.textContent = "/";
                        breadcrumbEl.appendChild(separator);

                        let name = "";
                        if (item.type === "project") {
                            name = projects_Linh.find((p) => p.ProjectID === item.id)?.ProjectName;
                        } else if (item.type === "task") {
                            name = tasks.find((t) => t.TaskID === item.id)?.TaskName;
                        } else if (item.type === "template") {
                            name = templates_Linh.find((t) => t.TemplateID === item.id)?.TemplateName;
                        }

                        const crumb = document.createElement("span");
                        crumb.className = "cursor-pointer text-decoration-underline";
                        crumb.textContent = name;
                        crumb.addEventListener("click", () => {
                            navigationStack = navigationStack.slice(0, index + 1);
                            render();
                        });
                        breadcrumbEl.appendChild(crumb);
                    });
                }

                function renderViewSwitcher() {
                    viewSwitcherEl.innerHTML = "";

                    ["kanban", "list", "chart"].forEach((view) => {
                        const btn = document.createElement("button");
                        btn.className = `view-btn px-3 py-2 rounded text-capitalize ${currentViewMode === view ? "active" : ""
                            }`;

                        // tạo span bọc text
                        const span = document.createElement("span");
                        span.textContent = view.charAt(0).toUpperCase() + view.slice(1);

                        btn.appendChild(span);

                        btn.addEventListener("click", () => {
                            currentViewMode = view;
                            render();
                        });

                        viewSwitcherEl.appendChild(btn);
                    });
                }

                // --- PROJECTS VIEW RENDERERS ---
                function renderProjectsView(projectsToRender) {
                    const headerHtml = `
                            <div class="d-flex justify-content-between align-items-center mb-3">
                                <h5 class="mb-0">All Projects (${projectsToRender.length})</h5>
                                <button id="add-project-btn-inline" class="btn btn-success no-print">
                                    <i class="bi bi-plus-lg"></i> New Project
                                </button>
                            </div>
                        `;

                    switch (currentViewMode) {
                        case "list":
                            viewContainerEl.innerHTML = headerHtml;
                            const listWrapper = document.createElement("div");
                            viewContainerEl.appendChild(listWrapper);
                            renderProjectsList(projectsToRender, listWrapper);
                            break;
                        case "chart":
                            viewContainerEl.innerHTML = headerHtml;
                            const chartWrapper = document.createElement("div");
                            viewContainerEl.appendChild(chartWrapper);
                            renderProjectsChart(projectsToRender, chartWrapper);
                            break;
                        case "kanban":
                        default:
                            viewContainerEl.innerHTML = headerHtml;
                            const gridWrapper = document.createElement("div");
                            viewContainerEl.appendChild(gridWrapper);
                            renderProjectsGrid(projectsToRender, gridWrapper);
                            break;
                    }

                    const addBtn = document.getElementById("add-project-btn-inline");
                    if (addBtn) {
                        addBtn.addEventListener("click", openAddProjectModal);
                    }
                }

                function renderProjectsGrid(projectsToRender, targetEl = viewContainerEl) {
                    let grid = document.createElement("div");
                    grid.className = "row row-cols-1 row-cols-sm-2 row-cols-md-3 g-3";

                    if (projectsToRender.length === 0) {
                        targetEl.innerHTML += `<div class="text-center text-muted py-5">No projects yet. Create your first project!</div>`;
                        return;
                    }

                    projectsToRender.forEach((project) => {
                        const col = document.createElement("div");
                        col.className = "col";
                        col.appendChild(createProjectCard(project));
                        grid.appendChild(col);
                    });
                    targetEl.appendChild(grid);
                }

                function renderProjectsList(projectsToRender, targetEl = viewContainerEl) {
                    let listHtml = `
                            <div class="table-responsive">
                                <table class="table table-hover">
                                    <thead>
                                        <tr>
                                            <th>Project Name</th>
                                            <th>Owner</th>
                                            <th>Start Date</th>
                                            <th>End Date</th>
                                            <th>Status</th>
                                            <th>Priority</th>
                                        </tr>
                                    </thead>
                                    <tbody id="project-list-tbody"></tbody>
                                </table>
                            </div>
                        `;
                    targetEl.innerHTML = listHtml;
                    const tbody = targetEl.querySelector("#project-list-tbody");

                    if (projectsToRender.length === 0) {
                        tbody.innerHTML = `<tr><td colspan="6" class="text-center text-muted">No projects to display.</td></tr>`;
                        return;
                    }

                    projectsToRender.forEach((project) => {
                        const row = document.createElement("tr");
                        row.className = "cursor-pointer";
                        row.innerHTML = `
                                <td class="fw-semibold">${project.ProjectName}</td>
                                <td class="text-muted">${findEmployee(project.OwnerID)?.FullName || "N/A"}</td>
                                <td class="text-muted">${project.StartDate || "N/A"}</td>
                                <td class="text-muted">${project.EndDate || "N/A"}</td>
                                <td><span class="badge bg-secondary">${project.Status || "N/A"}</span></td>
                                <td><span class="badge ${getPriorityClass(project.Priority)}">${project.Priority || "N/A"}</span></td>
                            `;
                        row.addEventListener("click", () => {
                            navigationStack = [{ type: "project", id: project.ProjectID }];
                            render();
                        });
                        tbody.appendChild(row);
                    });
                }

                // --- TEMPLATE VIEWS ---
                function renderTemplatesView() {
                    const templates = templates_Linh;
                    viewContainerEl.innerHTML = `
                        <div class="d-flex justify-content-between align-items-center mb-4">
                            <h4 class="mb-0">Task Template Library</h4>
                            <div class="d-flex gap-2">
                                <button class="btn btn-outline-primary btn-sm" onclick="ReloadData()">
                                    <i class="bi bi-arrow-clockwise"></i> Refresh
                                </button>
                                <button class="btn btn-primary btn-sm" onclick="openCreateTemplateModal()">
                                    <i class="bi bi-plus-lg"></i> Create Template
                                </button>
                            </div>
                        </div>
                        <div class="row row-cols-1 row-cols-md-3 g-4" id="template-grid"></div>
                    `;
                    
                    const grid = document.getElementById("template-grid");
                    if (templates.length === 0) {
                        grid.innerHTML = `<div class="col-12 text-center text-muted py-5">
                            <div class="mb-3"><i class="bi bi-box-seam fs-1 opacity-25"></i></div>
                            No templates found. Create one to standardize your workflow!
                        </div>`;
                        return;
                    }

                    templates.forEach(t => {
                        const col = document.createElement("div");
                        col.className = "col";
                        const subtasksCount = (typeof t.Subtasks === "string" ? JSON.parse(t.Subtasks) : (t.Subtasks || [])).length;
                        col.innerHTML = `
                            <div class="card h-100 shadow-sm border-0 bg-light-subtle hover-transform">
                                <div class="card-body">
                                    <div class="d-flex justify-content-between align-items-start mb-2">
                                        <span class="badge bg-primary-subtle text-primary">${t.Category || "General"}</span>
                                        <div class="dropdown">
                                            <button class="btn btn-link link-dark p-0" data-bs-toggle="dropdown"><i class="bi bi-three-dots-vertical"></i></button>
                                            <ul class="dropdown-menu dropdown-menu-end">
                                                <li><a class="dropdown-item" href="#" onclick="event.preventDefault(); openCreateTemplateModal(${t.TemplateID})">Edit Template</a></li>
                                                <li><a class="dropdown-item text-danger" href="#" onclick="event.preventDefault(); deleteTemplate(${t.TemplateID})">Delete</a></li>
                                            </ul>
                                        </div>
                                    </div>
                                    <h5 class="card-title fw-bold">${t.TemplateName}</h5>
                                    <div class="card-text text-muted small mb-4">${t.Description || "No description provided."}</div>
                                    <div class="d-flex justify-content-between align-items-center mt-auto pt-3 border-top">
                                        <span class="text-muted small"><i class="bi bi-list-task me-1"></i> ${subtasksCount} steps</span>
                                        <button class="btn btn-sm btn-success rounded-pill px-3" onclick="navigationStack.push({type:''template'', id:${t.TemplateID}}); render();">
                                            View Content
                                        </button>
                                    </div>
                                </div>
                            </div>
                        `;
                        grid.appendChild(col);
                    });
                }

                function renderProjectsChart(projectsToRender, targetEl = viewContainerEl) {
                    // Calculate date range: previous month, current month, next month
                    const today = new Date();
                    const startDate = new Date(today.getFullYear(), today.getMonth() - 1, 1);
                    const endDate = new Date(today.getFullYear(), today.getMonth() + 2, 0);

                    // Generate weekdays only
                    const weekdays = [];
                    const currentDate = new Date(startDate);
                    while (currentDate <= endDate) {
                        const dayOfWeek = currentDate.getDay();
                        if (dayOfWeek !== 0 && dayOfWeek !== 6) {
                            weekdays.push(new Date(currentDate));
                        }
                        currentDate.setDate(currentDate.getDate() + 1);
                    }

                    const totalDays = weekdays.length;
                    const monthNames = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"];

                    // Build header
                    let headerHtml = `<div class="d-flex" style="min-width: fit-content;">`;
                    let currentMonth = -1;

                    weekdays.forEach((date, index) => {
                        const month = date.getMonth();
                        const day = date.getDate();
                        const isFirstOfMonth = index === 0 || weekdays[index - 1].getMonth() !== month;

                        headerHtml += `<div class="text-center small border-end px-1" style="width: 35px;">
                                ${isFirstOfMonth ? `<div class="fw-bold text-primary" style="font-size: 0.7rem;">${monthNames[month]}</div>` : ""}
                                <div style="font-size: 0.75rem;">${day}</div>
                            </div>`;
                    });
                    headerHtml += "</div>";

                    let rowsHtml = "";
                    projectsToRender.forEach((project) => {
                        if (!project.StartDate || !project.EndDate) return;

                        const pStart = new Date(project.StartDate);
                        const pEnd = new Date(project.EndDate);

                        let startPos = -1;
                        let endPos = -1;

                        for (let i = 0; i < weekdays.length; i++) {
                            const weekday = weekdays[i];
                            if (weekday >= pStart && startPos === -1) {
                                startPos = i;
                            }
                            if (weekday <= pEnd) {
                                endPos = i;
                            }
                        }

                        if (startPos === -1 || endPos === -1 || startPos > endPos) return;

                        const startPercent = (startPos / totalDays) * 100;
                        const widthPercent = ((endPos - startPos + 1) / totalDays) * 100;

                        rowsHtml += `
                                <div class="d-flex align-items-center border-bottom py-2 cursor-pointer" data-project-id="${project.ProjectID}">
                                    <div style="width: 200px; min-width: 200px;" class="text-truncate pe-2">${project.ProjectName}</div>
                                    <div class="flex-grow-1 position-relative" style="height: 28px; min-width: ${totalDays * 35}px;">
                                        <div class="chart-bar position-absolute" style="left: ${startPercent}%; width: ${widthPercent}%;" title="${project.ProjectName} (${project.StartDate} - ${project.EndDate})"></div>
                                    </div>
                                </div>
                            `;
                    });

                    if (rowsHtml === "") {
                        rowsHtml = `<div class="text-center text-muted py-4">No projects with valid dates to display in chart</div>`;
                    }

                    targetEl.innerHTML = `
                            <div class="overflow-auto">
                                <div style="min-width: fit-content;">
                                    <div class="d-flex align-items-center bg-body-secondary border-bottom sticky-top" style="top: 0; z-index: 10;">
                                        <div style="width: 200px; min-width: 200px; padding: 1rem;" class="fw-bold bg-body-secondary">Project</div>
                                        <div class="flex-grow-1 bg-body-secondary">${headerHtml}</div>
                                    </div>
                                    ${rowsHtml}
                                </div>
                            </div>
                        `;

                    // Add click listeners
                    targetEl.querySelectorAll("[data-project-id]").forEach(row => {
                        row.addEventListener("click", () => {
                            const projectId = parseInt(row.dataset.projectId);
                            navigationStack = [{ type: "project", id: projectId }];
                            render();
                        });
                    });
                }

                function createProjectCard(project) {
                    const taskCount = tasks.filter((t) => t.ProjectID === project.ProjectID && !t.ParentTaskID).length;
                    const card = document.createElement("div");
                    card.className = "card project-card h-100 border";
                    card.dataset.projectId = project.ProjectID;
                    card.innerHTML = `
                            <div class="card-body">
                                <div class="d-flex justify-content-between align-items-start mb-2">
                                    <h5 class="card-title mb-0">${project.ProjectName}</h5>
                                    <span class="badge ${getPriorityClass(project.Priority)}">${project.Priority || "N/A"}</span>
                                </div>
                                <div class="card-text text-muted small">${project.Description || "No description"}</div>
                            </div>
                            <div class="card-footer bg-transparent d-flex justify-content-between align-items-center">
                                <small class="text-muted">${taskCount} tasks</small>
                                <span class="badge bg-secondary">${project.Status || "N/A"}</span>
                            </div>
                        `;
                    card.addEventListener("click", () => {
                        navigationStack = [{ type: "project", id: project.ProjectID }];
                        render();
                    });
                    return card;
                }

                // --- PROJECT DETAIL PAGE ---
                function renderProjectDetail(project) {
                    const projectTasks = tasks.filter((t) => t.ProjectID === project.ProjectID && (t.ParentTaskID === null || t.ParentTaskID === undefined || t.ParentTaskID === 0));
                    const detailHtml = `
                            <div class="mb-4">
                                <div class="card border mb-3">
                                    <div class="card-body">
                                        <div class="d-flex justify-content-between align-items-start mb-3">
                                            <div>
                                                <h3 class="mb-2">
                                                    <!-- TODO: Add ProjectName -->
                                                    <div id="P794C2F8348554BF6B8EB236EC6F3A215"></div> 
                                                    <span class="badge ${getPriorityClass(project.Priority)}">${project.Priority || "N/A"}</span>
                                                </h3>
                                                <div class="text-muted small">${project.Description || "No description provided."}</div>
                                            </div>
                                        </div>
                                        <div class="row g-3">
                                            <div class="col-md-3">
                                                <small class="text-muted d-block">Owner</small>
                                                <!-- TODO: Add Owner -->
                                                <div id="PCDF4A5D2F59249DD9446C029B7849322"></div>
                                                <span class="fw-medium">${findEmployee(project.OwnerID).FullName}</span>
                                            </div>
                                            <div class="col-md-3">
                                                <small class="text-muted d-block">Start Date</small>
                                                <!-- TODO: Add StartDate -->
                                                <div id="P40385F4F923B4BB4A6D20DC9AE6850B6"></div>
                                            </div>
                                            <div class="col-md-3">
                                                <small class="text-muted d-block">End Date</small>
                                                <!-- TODO: Add EndDate -->
                                                <div id="P5CE9880C159C4472A986171C034CF295"></div>
                                            </div>
                                            <div class="col-md-3">
                                                <small class="text-muted d-block">Status</small>
                                                <!-- TODO: Add Status -->
                                                <div id="P8A441B97BF684EBBA615B484D92A4850"></div>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                                <div class="d-flex justify-content-between align-items-center mb-3">
                                    <h5 class="mb-0">Tasks (${projectTasks.length})</h5>
                                </div>
                                <div id="project-tasks-area"></div>
                            </div>
                        `;
                    viewContainerEl.innerHTML = detailHtml;
                    const tasksArea = document.getElementById("project-tasks-area");

                    switch (currentViewMode) {
                        case "list":
                            renderListView(projectTasks, tasksArea);
                            break;
                        case "chart":
                            renderChartView(projectTasks, tasksArea);
                            break;
                        case "kanban":
                        default:
                            renderKanbanView(projectTasks, tasksArea);
                            break;
                    }
                }

                // --- TASK VIEW RENDERERS ---
                function renderKanbanView(tasksToRender, targetEl = viewContainerEl) {
                    targetEl.innerHTML = `<div id="kanban-board" class="d-flex gap-3 kanban-board overflow-auto"></div>`;
                    const kanbanBoardEl = targetEl.querySelector("#kanban-board");

                    KANBAN_STATUSES.forEach((status) => {
                        const column = document.createElement("div");
                        column.className = "kanban-column rounded flex-shrink-0";
                        column.style.width = "280px";
                        column.style.padding = "1rem";
                        column.dataset.status = status;
                        column.innerHTML = `
                                <div class="column-header d-flex justify-content-between align-items-center">
                                    <h6 class="fw-bold mb-0">${status}</h6>
                                    <button class="btn btn-sm column-add-btn" data-status="${status}">
                                        <i class="bi bi-plus-lg"></i>
                                    </button>
                                </div>
                                <div class="task-container d-flex flex-column gap-2"></div>
                            `;
                        kanbanBoardEl.appendChild(column);
                    });

                    tasksToRender.forEach((task) => {
                        const column = kanbanBoardEl.querySelector(`.kanban-column[data-status="${task.Status}"] .task-container`);
                        if (column) column.appendChild(createTaskCard(task));
                    });

                    // Add event listeners for column add buttons
                    kanbanBoardEl.querySelectorAll(".column-add-btn").forEach(btn => {
                        btn.addEventListener("click", (e) => {
                            e.stopPropagation();
                            const status = btn.dataset.status;
                            openCreateTaskModal({ defaultStatus: status });
                        });
                    });

                    addDragAndDropListeners();
                }

                function renderListView(tasksToRender, targetEl = viewContainerEl) {
                    let listHtml = `
                    <div class="table-responsive">
                        <table class="table table-hover">
                            <thead>
                                <tr>
                                    <th>Task Name</th>
                                    <th>Assignee</th>
                                    <th>Due Date</th>
                                    <th>Priority</th>
                                    <th style="width: 150px;">Actions</th>
                                </tr>
                            </thead>
                            <tbody id="list-container"></tbody>
                        </table>
                    </div>
                    `;
                    
                    targetEl.innerHTML = listHtml;
                    const listContainerEl = targetEl.querySelector("#list-container");
                    
                    if (tasksToRender.length === 0) {
                        listContainerEl.innerHTML = `
                            <tr>
                                <td colspan="5" class="text-center py-5">
                                    <div class="mb-3">
                                        <i class="bi bi-check2-square" style="font-size: 3rem; color: #dee2e6;"></i>
                                    </div>
                                    <div class="text-muted small mb-3">No tasks to display</div>
                                    <button id="add-task-btn-empty" class="btn btn-success">
                                        <i class="bi bi-plus-lg"></i> Add Task
                                    </button>
                                </td>
                            </tr>
                        `;
                        
                        // Thêm event listener cho nút Add Task
                        const addTaskBtn = document.getElementById("add-task-btn-empty");
                        if (addTaskBtn) {
                            addTaskBtn.addEventListener("click", () => {
                                const context = navigationStack[navigationStack.length - 1];
                                if (context && context.type === "project") {
                                    openCreateTaskModal();
                                } else if (context && context.type === "task") {
                                    openCreateTaskModal({ parentTaskId: context.id });
                                }
                            });
                        }
                        
                        return;
                    }
                    
                    tasksToRender.forEach((task) => {
                        const row = document.createElement("tr");
                        row.className = "cursor-pointer";
                        const subtaskIcon = hasSubtasks(task.TaskID) ? `<i class="bi bi-diagram-3 me-2"></i>` : "";
                        const subtaskCount = tasks.filter((t) => t.ParentTaskID === task.TaskID).length;
                        const hasSubtasksFlag = subtaskCount > 0;
                        row.innerHTML = `
                            <td class="fw-semibold">${subtaskIcon}${task.TaskName}</td>
                            <td class="text-muted">${findEmployee(task.AssigneeID).FullName}</td>
                            <td class="text-muted">${task.DueDate || "N/A"}</td>
                            <td><span class="badge ${getPriorityClass(task.Priority)}">${task.Priority}</span></td>
                            <td>
                                <div class="d-flex gap-2">
                                    ${hasSubtasksFlag ? `
                                        <button class="view-subtasks-card-btn" data-task-id="${task.TaskID}" title="View ${subtaskCount} subtask${subtaskCount > 1 ? "s" : ""}">
                                            <i class="bi bi-diagram-3"></i>
                                            <span>${subtaskCount}</span>
                                        </button>
                                    ` : ""}
                                    <button class="view-details-card-btn" data-task-id="${task.TaskID}" title="View details">
                                        <i class="bi bi-eye"></i>
                                    </button>
                                </div>
                            </td>
                        `;
                        
                        // Click on row (not buttons) opens details
                        row.addEventListener("click", (e) => {
                            if (!e.target.closest("button")) {
                                openTaskModal(task.TaskID);
                            }
                        });
                        
                        listContainerEl.appendChild(row);
                        
                        // View subtasks button click
                        const subtasksBtn = row.querySelector(".view-subtasks-card-btn");
                        if (subtasksBtn) {
                            subtasksBtn.addEventListener("click", (e) => {
                                e.stopPropagation();
                                navigationStack.push({ type: "task", id: task.TaskID });
                                render();
                            });
                        }
                        
                        // View details button click
                        const detailsBtn = row.querySelector(".view-details-card-btn");
                        if (detailsBtn) {
                            detailsBtn.addEventListener("click", (e) => {
                                e.stopPropagation();
                                openTaskModal(task.TaskID);
                            });
                        }
                    });
                }

                function renderChartView(tasksToRender, targetEl = viewContainerEl) {
                    // Calculate date range: previous month, current month, next month
                    const today = new Date();
                    const startDate = new Date(today.getFullYear(), today.getMonth() - 1, 1); // Start of previous month
                    const endDate = new Date(today.getFullYear(), today.getMonth() + 2, 0); // End of next month

                    // Generate weekdays only
                    const weekdays = [];
                    const currentDate = new Date(startDate);
                    while (currentDate <= endDate) {
                        const dayOfWeek = currentDate.getDay();
                        // Skip Saturday (6) and Sunday (0)
                        if (dayOfWeek !== 0 && dayOfWeek !== 6) {
                            weekdays.push(new Date(currentDate));
                        }
                        currentDate.setDate(currentDate.getDate() + 1);
                    }

                    const totalDays = weekdays.length;
                    const monthNames = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"];

                    // Build header with month names and dates
                    let headerHtml = `<div class="d-flex" style="min-width: fit-content;">`;
                    let currentMonth = -1;
                    let monthSpan = 0;

                    weekdays.forEach((date, index) => {
                        const month = date.getMonth();
                        const day = date.getDate();

                        if (month !== currentMonth) {
                            if (currentMonth !== -1 && monthSpan > 0) {
                                // Close previous month span
                            }
                            currentMonth = month;
                            monthSpan = 1;
                        } else {
                            monthSpan++;
                        }

                        const isFirstOfMonth = index === 0 || weekdays[index - 1].getMonth() !== month;
                        headerHtml += `<div class="text-center small border-end px-1" style="width: 35px;">
                                ${isFirstOfMonth ? `<div class="fw-bold text-primary" style="font-size: 0.7rem;">${monthNames[month]}</div>` : ""}
                                <div style="font-size: 0.75rem;">${day}</div>
                            </div>`;
                    });
                    headerHtml += "</div>";

                    let rowsHtml = "";
                    tasksToRender.forEach((task) => {
                        if (!task.StartDate || !task.DueDate) return;

                        const taskStart = new Date(task.StartDate);
                        const taskEnd = new Date(task.DueDate);

                        // Find start and end positions in weekdays array
                        let startPos = -1;
                        let endPos = -1;

                        for (let i = 0; i < weekdays.length; i++) {
                            const weekday = weekdays[i];
                            if (weekday >= taskStart && startPos === -1) {
                                startPos = i;
                            }
                            if (weekday <= taskEnd) {
                                endPos = i;
                            }
                        }

                        if (startPos === -1 || endPos === -1 || startPos > endPos) return;

                        const startPercent = (startPos / totalDays) * 100;
                        const widthPercent = ((endPos - startPos + 1) / totalDays) * 100;

                        rowsHtml += `
                                <div class="d-flex align-items-center border-bottom py-2">
                                    <div style="width: 200px; min-width: 200px;" class="text-truncate pe-2">${task.TaskName}</div>
                                    <div class="flex-grow-1 position-relative" style="height: 28px; min-width: ${totalDays * 35}px;">
                                        <div class="chart-bar position-absolute" style="left: ${startPercent}%; width: ${widthPercent}%;" title="${task.TaskName} (${task.StartDate} - ${task.DueDate})"></div>
                                    </div>
                                </div>
                            `;
                    });

                    if (rowsHtml === "") {
                        rowsHtml = `<div class="text-center text-muted py-4">No tasks with valid dates to display in chart</div>`;
                    }

                    targetEl.innerHTML = `
                            <div class="overflow-auto">
                                <div style="min-width: fit-content;">
                                    <div class="d-flex align-items-center bg-body-secondary border-bottom sticky-top" style="top: 0; z-index: 10;">
                                        <div style="width: 200px; min-width: 200px; padding: 1rem;" class="fw-bold bg-body-secondary">Task</div>
                                        <div class="flex-grow-1 bg-body-secondary">${headerHtml}</div>
                                    </div>
                                    ${rowsHtml}
                                </div>
                            </div>
                        `;
                }

                // --- TASK CARD & MODALS ---
                function createTaskCard(task) {
                    const card = document.createElement("div");
                    card.className = "card task-card border";
                    card.dataset.taskId = task.TaskID;
                    card.draggable = true;

                    const subtaskCount = tasks.filter((t) => t.ParentTaskID === task.TaskID).length;
                    const hasSubtasksFlag = subtaskCount > 0;

                    card.innerHTML = `
                            <div class="card-body">
                                <div class="task-card-header">
                                    <h6 class="task-card-title">${task.TaskName}</h6>
                                    <span class="badge ${getPriorityClass(task.Priority)}">${task.Priority}</span>
                                </div>

                                <div class="task-card-footer">
                                    <div class="task-card-assignee">
                                        <i class="bi bi-person"></i>
                                        <span>${findEmployee(task.AssigneeID).FullName}</span>
                                    </div>
                                    <div class="task-card-meta d-flex gap-2">
                                        ${hasSubtasksFlag ? `
                                            <button class="view-subtasks-card-btn" data-task-id="${task.TaskID}" title="View ${subtaskCount} subtask${subtaskCount > 1 ? "s" : ""}">
                                                <i class="bi bi-diagram-3"></i>
                                                <span>${subtaskCount}</span>
                                            </button>
                                        ` : ""}
                                        <button class="view-details-card-btn" data-task-id="${task.TaskID}" title="View details">
                                            <i class="bi bi-eye"></i>
                                        </button>
                                    </div>
                                </div>
                            </div>
                        `;

                    // View subtasks button click
                    const subtasksBtn = card.querySelector(".view-subtasks-card-btn");
                    if (subtasksBtn) {
                        subtasksBtn.addEventListener("click", (e) => {
                            e.stopPropagation();
                            navigationStack.push({ type: "task", id: task.TaskID });
                            render();
                        });
                    }

                    // View details button click
                    const detailsBtn = card.querySelector(".view-details-card-btn");
                    if (detailsBtn) {
                        detailsBtn.addEventListener("click", (e) => {
                            e.stopPropagation();
                            openTaskModal(task.TaskID);
                        });
                    }

                    // Card click (now does nothing, all interactions through buttons)
                    card.addEventListener("click", (e) => {
                        // Click on card body (not buttons) also opens details
                        if (!e.target.closest("button")) {
                            openTaskModal(task.TaskID);
                        }
                    });

                    return card;
                }

                window.openTaskModal = openTaskModal;
                window.changeTaskStatus = changeTaskStatus;
                window.handleDeleteTask = handleDeleteTask;
                window.openCreateTaskModal = openCreateTaskModal;
                window.showPriorityDropdown = showPriorityDropdown;
                window.showAssigneeDropdown = showAssigneeDropdown;

                function openModal(modalId) {
                    const modal = document.getElementById(modalId);
                    if (modal) {
                        modal.classList.add("active");
                    }
                }

                function closeModal(modalId) {
                    const modal = document.getElementById(modalId);
                    if (modal) {
                        modal.classList.remove("active");
                    }
                }
                
                // Allow closing by clicking outside the container
                document.querySelectorAll(''.custom-modal-overlay'').forEach(overlay => {
                    overlay.addEventListener(''click'', (e) => {
                        if (e.target === overlay) {
                            overlay.classList.remove(''active'');
                        }
                    });
                });

                window.openModal = openModal;
                window.closeModal = closeModal;

                // --- MODAL OPENERS ---
                function openTaskModal(taskId) {
                    const task = tasks.find((t) => t.TaskID === taskId);
                    if (!task) return;

                    currentEditingTaskId = taskId;

                    // Update contents...
                    const modalHeader = taskModalEl.querySelector(".custom-modal-header");
                    
                    const parentTask = task.ParentTaskID ? tasks.find(t => t.TaskID === task.ParentTaskID) : null;
                    const parentLinkHtml = parentTask ? `
                        <a href="#" class="parent-link-badge mb-2" onclick="event.preventDefault(); openTaskModal(${parentTask.TaskID})">
                            <i class="bi bi-arrow-up-circle"></i> Parent: ${parentTask.TaskName}
                        </a>
                    ` : "";

                    // Re-inject dynamic header content (keeping the close button static structure if possible, but here we replace innerHTML mostly)
                    // Note: We need to preserve the Close button or re-add it.
                    // Lets rewrite the header content carefully.
                    modalHeader.innerHTML = `
                        <div class="flex-grow-1">
                            ${parentLinkHtml}
                            <div class="d-flex align-items-center gap-3">
                                <h5 id="modal-task-name" class="custom-modal-title editable-field mb-0" data-field="TaskName" data-task-id="${taskId}">${task.TaskName}</h5>
                                <span class="badge ${getPriorityClass(task.Priority)} rounded-pill cursor-pointer" onclick="showPriorityDropdown(this, ${JSON.stringify(task).replace(/""/g, "&quot;")})">${task.Priority}</span>
                            </div>
                            <div class="status-steps mt-3">
                                ${KANBAN_STATUSES.map(status => `
                                    <button class="status-step ${task.Status === status ? ''active'' : ''''} ${KANBAN_STATUSES.indexOf(task.Status) > KANBAN_STATUSES.indexOf(status) ? ''completed'' : ''''}" onclick="changeTaskStatus(${taskId}, ''${status}'')">
                                        ${status}
                                    </button>
                                `).join("")}
                            </div>
                        </div>
                        <div class="d-flex gap-2 align-items-center">
                            <button id="delete-task-btn" class="custom-modal-close text-danger" title="Delete task">
                                <i class="bi bi-trash"></i>
                            </button>
                            <button type="button" class="custom-modal-close" onclick="closeModal(''task-modal'')">
                                <i class="bi bi-x-lg"></i>
                            </button>
                        </div>
                    `;

                    document.getElementById("delete-task-btn").addEventListener("click", () => handleDeleteTask(taskId));

                    const modalBody = taskModalEl.querySelector("#modal-content");
                    modalBody.innerHTML = `
                        <div class="row g-4">
                            <div class="col-md-7 border-end">
                                <div class="row g-3 mb-4">
                                    <div class="col-md-6">
                                        <label class="custom-form-label text-muted">ASSIGNEE</label>
                                        <!-- TODO: Add Assignee -->
                                        <div id="P8D081E689C8B4072AFE480737FBCF0E8"></div>
                                    </div>
                                    <div class="col-md-6">
                                        <label class="custom-form-label text-muted">DUE DATE</label>
                                        <div id="P5AA042EE89064CD3A87E1731D091AEB7"></div>
                                    </div>
                                </div>
                                <div class="mb-4">
                                    <label class="custom-form-label text-muted">DESCRIPTION</label>
                                    <div id="PE163B877AF934B69A8B09C828BD02C86"></div>
                                </div>
                                <div>
                                    ${renderSubtasksHtml(taskId)}
                                </div>
                            </div>
                            <div class="col-md-5">
                                <h6 class="fw-bold mb-3">Activity</h6>
                                <div class="mb-3">
                                    <textarea id="new-comment-input" class="custom-textarea" placeholder="Write a comment..." rows="2"></textarea>
                                    <div class="d-flex justify-content-end mt-2">
                                        <button id="add-comment-btn" class="custom-btn custom-btn-primary btn-sm">Post</button>
                                    </div>
                                </div>
                                <div class="timeline-section" style="max-height: 400px; overflow-y: auto;">
                                    ${renderActivityTimeline(taskId)}
                                </div>
                            </div>
                        </div>
                    `;

                    document.getElementById("add-comment-btn").addEventListener("click", () => {
                        const input = document.getElementById("new-comment-input");
                        addComment(taskId, input.value.trim());
                        input.value = "";
                    });

                    setupInlineEditing();
                    openModal(''task-modal'');
                }

                function openCreateTaskModal({ parentTaskId = null, editTaskId = null, defaultStatus = "To Do" } = {}) {
                    const context = navigationStack[navigationStack.length - 1];
                    if (!context && !editTaskId) { // Allow edit without context if strict
                         // Actually mostly we need context for ProjectID if new
                    }
                    
                    if (!context && !editTaskId) {
                         // Default to first project if exists or error
                         if (projects_Linh.length > 0) {
                             // Context is implicitly project 0?
                         } else {
                             alert("Please select a project first!");
                             return;
                         }
                    }

                    createTaskForm.reset();
                    createTaskForm.dataset.parentTaskId = parentTaskId || "";
                    createTaskForm.dataset.editTaskId = editTaskId || "";
                    createTaskForm.dataset.defaultStatus = defaultStatus;

                    const assigneeSelect = document.getElementById("create-task-assignee");
                    assigneeSelect.innerHTML = `<option value="">Select Assignee</option>`;
                    employees_Linh.forEach((emp) => {
                        const option = document.createElement("option");
                        option.value = emp.EmployeeID;
                        option.textContent = emp.FullName;
                        assigneeSelect.appendChild(option);
                    });

                    if (editTaskId) {
                        createModalTitleEl.textContent = "Edit Task";
                        const task = tasks.find((t) => t.TaskID === editTaskId);
                        document.getElementById("create-task-name").value = task.TaskName;
                        document.getElementById("create-task-desc").value = task.Description;
                        assigneeSelect.value = task.AssigneeID;
                        document.getElementById("create-task-priority").value = task.Priority;
                    } else {
                        createModalTitleEl.textContent = parentTaskId ? "Create New Subtask" : "Create New Task";
                    }

                    openModal(''create-task-modal'');
                }

                function openAddProjectModal() {
                    addProjectForm.reset();
                    openModal(''add-project-modal'');
                }
                
                // Override Batch Modal Opener
                 window.openAssignModal = function(parentId) {
                    currentAssignParentTaskId = parentId;
                    assignSubtasks = [];
                    
                    const requesterSelect = document.getElementById("assign-requester");
                    const assigneeSelect = document.getElementById("assign-assignee");
                    const templateSelect = document.getElementById("assign-template");
                    
                    requesterSelect.innerHTML = employees_Linh.map(e => `<option value="${e.EmployeeID}">${e.FullName}</option>`).join("");
                    assigneeSelect.innerHTML = employees_Linh.map(e => `<option value="${e.EmployeeID}">${e.FullName}</option>`).join("");
                    
                    if (templateSelect) {
                        templateSelect.innerHTML = `<option value="">-- Không dùng mẫu --</option>` + 
                            templates_Linh.map(t => `<option value="${t.TemplateID}">${t.TemplateName}</option>`).join("");
                        templateSelect.value = "";
                    }

                    const currentEmpID = employees_Linh.find(e => parseInt(e.EmployeeID) === LoginID)?.EmployeeID;
                    if (currentEmpID) requesterSelect.value = currentEmpID;
                    
                    document.getElementById("assign-date").value = new Date().toISOString().split("T")[0];
                    document.getElementById("assign-hours").value = "1.0";
                    document.getElementById("assign-new-task-name").value = "";
                    
                    renderAssignSubtasks();
                    openModal(''mdlAssign'');
                };

                // Remove Bootstrap Initialization

                function changeTaskStatus(taskId, newStatus) {
                    AjaxHPAParadise({
                        data: {
                            name: "sp_Task_UpdateStatus",
                            param: ["TaskID", taskId, "NewStatus", newStatus, "LoginID", LoginID]
                        },
                        success: (res) => {
                            const data = (typeof res === "string" ? JSON.parse(res) : res).data?.[0]?.[0] || {};
                            if (data.Status !== "SUCCESS") return;

                            const task = tasks.find(t => t.TaskID == taskId);
                            if (task) task.Status = newStatus;

                            if (typeof uiManager !== "undefined") {
                                uiManager.showAlert({ type: "success", message: "Cập nhật trạng thái thành công" });
                            }

                            const modal = document.getElementById("task-modal");
                            if (modal?.classList.contains("active") && currentEditingTaskId === taskId) {
                                const statusStepsContainer = modal.querySelector(".status-steps");
                                if (statusStepsContainer) {
                                    const buttons = statusStepsContainer.querySelectorAll(".status-step");
                                    buttons.forEach((button, index) => {
                                        button.classList.remove("active", "completed");
                                        if (newStatus === KANBAN_STATUSES[index]) {
                                            button.classList.add("active");
                                        }
                                        if (KANBAN_STATUSES.indexOf(newStatus) > index) {
                                            button.classList.add("completed");
                                        }
                                    });
                                }
                            }
                        }
                    });
                }

                function addComment(taskId, text, isSystem = false) {
                    if (!text.trim()) return;
                    AjaxHPAParadise({
                        data: { name: "sp_Task_AddComment", param: ["TaskID", taskId, "Comment", text, "LoginID", LoginID] },
                        success: (res) => {
                            ReloadData();
                        }
                    });
                }

                // --- BATCH ASSIGNMENT FUNCTIONS ---
                window.openAssignModal = function(parentId) {
                    currentAssignParentTaskId = parentId;
                    assignSubtasks = [];
                    
                    const requesterSelect = document.getElementById("assign-requester");
                    const assigneeSelect = document.getElementById("assign-assignee");
                    const templateSelect = document.getElementById("assign-template");
                    
                    requesterSelect.innerHTML = employees_Linh.map(e => `<option value="${e.EmployeeID}">${e.FullName}</option>`).join("");
                    assigneeSelect.innerHTML = employees_Linh.map(e => `<option value="${e.EmployeeID}">${e.FullName}</option>`).join("");
                    
                    if (templateSelect) {
                        templateSelect.innerHTML = `<option value="">-- Không dùng mẫu --</option>` + 
                            templates_Linh.map(t => `<option value="${t.TemplateID}">${t.TemplateName}</option>`).join("");
                        templateSelect.value = "";
                    }

                    // Set default requester to LoginID if matches
                    const currentEmpID = employees_Linh.find(e => parseInt(e.EmployeeID) === LoginID)?.EmployeeID;
                    if (currentEmpID) requesterSelect.value = currentEmpID;
                    
                    document.getElementById("assign-date").value = new Date().toISOString().split("T")[0];
                    document.getElementById("assign-hours").value = "1.0";
                    document.getElementById("assign-new-task-name").value = "";
                    
                    renderAssignSubtasks();
                    new bootstrap.Modal(document.getElementById("mdlAssign")).show();
                };

                window.loadSubtasksFromTemplate = function(templateId) {
                    if (!templateId) {
                        assignSubtasks = [];
                        renderAssignSubtasks();
                        return;
                    }

                    const template = templates_Linh.find(t => t.TemplateID == templateId);
                    if (!template) return;

                    const subs = typeof template.Subtasks === "string" ? JSON.parse(template.Subtasks) : (template.Subtasks || []);
                    
                    // Clear existing and load template tasks
                    assignSubtasks = [];
                    subs.forEach(s => {
                        assignSubtasks.push({
                            TaskName: s.TaskName,
                            Description: s.Description,
                            Priority: "Medium"
                        });
                    });
                    
                    renderAssignSubtasks();
                };

                function addAssignSubtaskRow() {
                    const input = document.getElementById("assign-new-task-name");
                    const name = input.value.trim();
                    if (!name) return;
                    
                    assignSubtasks.push({ TaskName: name, Description: "" });
                    input.value = "";
                    renderAssignSubtasks();
                }

                function renderAssignSubtasks() {
                    const list = document.getElementById("assign-subtasks-list");
                    if (assignSubtasks.length === 0) {
                        list.innerHTML = `<div class="text-center text-muted small" style="padding: 2rem;">No subtasks added yet.</div>`;
                        return;
                    }
                    
                    list.innerHTML = assignSubtasks.map((st, index) => `
                        <div class="list-group-item d-flex justify-content-between align-items-center">
                            <span>${st.TaskName}</span>
                            <button class="btn btn-link text-danger p-0" onclick="removeAssignSubtask(${index})">
                                <i class="bi bi-x-circle"></i>
                            </button>
                        </div>
                    `).join("");
                }

                window.removeAssignSubtask = function(index) {
                    assignSubtasks.splice(index, 1);
                    renderAssignSubtasks();
                };

                function submitTaskAssignment() {
                    if (assignSubtasks.length === 0) {
                        alert("Vui lòng thêm ít nhất một việc phụ");
                        return;
                    }

                    const requesterID = document.getElementById("assign-requester").value;
                    const assigneeID = document.getElementById("assign-assignee").value;
                    const requestDate = document.getElementById("assign-date").value;
                    const committedHours = document.getElementById("assign-hours").value;

                    AjaxHPAParadise({
                        data: {
                            name: "sp_Task_AssignSubtasks",
                            param: [
                                "ParentTaskID", currentAssignParentTaskId,
                                "RequesterEmployeeID", requesterID || null,
                                "AssigneeEmployeeID", assigneeID || null,
                                "RequestDate", requestDate || null,
                                "CommittedHours", committedHours || null,
                                "SubtasksJSON", JSON.stringify(assignSubtasks),
                                "LoginID", LoginID,
                                "LanguageID", LanguageID
                            ]
                        },
                        success: function(res) {
                            const json = typeof res === "string" ? JSON.parse(res) : res;
                            const errors = json.data?.[json.data.length - 1] || [];
                            if (errors.length > 0 && errors[0].Status === "ERROR") {
                                if (typeof uiManager !== "undefined") uiManager.showAlert({ type: "error", message: errors[0].Message || "Giao việc thất bại" });
                            } else {
                                if (typeof uiManager !== "undefined") uiManager.showAlert({ type: "success", message: "Giao việc thành công" });
                                const modal = bootstrap.Modal.getInstance(document.getElementById("mdlAssign"));
                                if (modal) modal.hide();
                                ReloadData();
                            }
                        }
                    });
                }

                function renderSubtasksHtml(taskId) {
                    const subtasks = tasks.filter(t => t.ParentTaskID === taskId);
                    
                    let html = `
                        <div class="d-flex justify-content-between align-items-center mb-2 px-3">
                            <h6 class="mb-0">Subtasks (${subtasks.length})</h6>
                            <button class="btn btn-sm btn-outline-primary" onclick="openAssignModal(${taskId})">
                                <i class="bi bi-person-plus"></i> Batch Assign
                            </button>
                        </div>
                    `;

                    if (subtasks.length === 0) {
                        html += `<div class="text-center text-muted small">No subtasks found.</div>`;
                        return html;
                    }

                    html += subtasks.map(st => `
                        <div class="list-group-item list-group-item-action d-flex align-items-center justify-content-between py-3">
                            <div class="d-flex align-items-center gap-3 cursor-pointer flex-grow-1" onclick="openTaskModal(${st.TaskID})">
                                <i class="bi bi-check2-circle text-muted"></i>
                                <span class="${st.Status === "Done" ? "text-decoration-line-through text-muted" : ""}">${st.TaskName}</span>
                            </div>
                            <div class="d-flex align-items-center gap-3">
                                <div class="d-flex align-items-center gap-2">
                                    <span class="badge ${getPriorityClass(st.Priority)} rounded-pill" style="font-size: 0.65rem;">${st.Priority}</span>
                                    <span class="badge bg-secondary-subtle text-secondary rounded-pill" style="font-size: 0.65rem;">${st.Status}</span>
                                </div>
                                <div class="subtask-actions d-flex gap-1">
                                    <button class="btn btn-link subtask-action-btn view p-0 cursor-pointer" title="View Details" onclick="openTaskModal(${st.TaskID})">
                                        <i class="bi bi-eye"></i>
                                    </button>
                                    <button class="btn btn-link subtask-action-btn delete p-0 cursor-pointer" title="Delete Subtask" onclick="handleDeleteTask(${st.TaskID})">
                                        <i class="bi bi-trash"></i>
                                    </button>
                                </div>
                            </div>
                        </div>
                    `).join("");
                    
                    return html;
                }

                function renderActivityTimeline(taskId) {
                    const processes = taskProcesses_Linh.filter(p => p.TaskID === taskId).map(p => ({
                        type: "status",
                        date: new Date(p.ChangedDate),
                        content: `Changed status from **${p.OldStatus}** to **${p.NewStatus}**`,
                        user: findEmployee(p.ChangedBy).FullName
                    }));

                    const comments = comments_Linh.filter(c => c.TaskID === taskId).map(c => ({
                        type: "comment",
                        date: new Date(c.CreatedDate),
                        content: c.Comment,
                        user: findEmployee(c.UserID).FullName,
                        isSystem: c.IsSystem
                    }));

                    const allEvents = [...processes, ...comments].sort((a, b) => b.date - a.date);

                    if (allEvents.length === 0) return `<div class="text-center text-muted small mt-4">No activity yet.</div>`;

                    let html = "";
                    let lastDateStr = "";
                    const today = new Date().toLocaleDateString();

                    allEvents.forEach(event => {
                        const dateStr = event.date.toLocaleDateString();
                        if (dateStr !== lastDateStr) {
                            const label = dateStr === today ? "Today" : dateStr;
                            html += `<div class="timeline-date-separator ${dateStr === today ? "today" : ""}">${label}</div>`;
                            lastDateStr = dateStr;
                        }

                        const timeStr = event.date.toLocaleTimeString([], { hour: "2-digit", minute: "2-digit" });

                        html += `
                            <div class="timeline-item">
                                <div class="d-flex justify-content-between align-items-center mb-1">
                                    <span class="fw-bold small">${event.user}</span>
                                    <span class="text-muted" style="font-size: 0.7rem;">${timeStr}</span>
                                </div>
                                <div class="small ${event.isSystem ? "text-body italic" : "text-body"}">${event.content.replace(/\*\*(.*?)\*\*/g, "<b>$1</b>")}</div>
                            </div>
                        `;
                    });

                    return html;
                }

                function setupInlineEditing() {
                    const editableFields = document.querySelectorAll(".editable-field");

                    editableFields.forEach((field) => {
                        field.addEventListener("click", function (e) {
                            e.stopPropagation();
                            const fieldName = this.dataset.field;
                            const taskId = parseInt(this.dataset.taskId || currentEditingTaskId);
                            const task = tasks.find((t) => t.TaskID === taskId);

                            if (!task) return;

                            if (fieldName === "Status") {
                                // showStatusDropdown(this, task); // Status is now handled by breadcrumbs
                            } else if (fieldName === "Priority") {
                                showPriorityDropdown(this, task);
                            } else if (fieldName === "AssigneeID") {
                                showAssigneeDropdown(this, task);
                            } else if (fieldName === "Description" || fieldName === "TaskName") {
                                showTextEditor(this, task, fieldName);
                            }
                        });
                    });
                }

                function showStatusDropdown(element, task) {
                    const rect = element.getBoundingClientRect();
                    const dropdown = document.createElement("div");
                    dropdown.className = "dropdown-menu show";
                    dropdown.style.position = "fixed";
                    dropdown.style.left = rect.left + "px";
                    dropdown.style.top = rect.bottom + 5 + "px";
                    dropdown.style.zIndex = "9999";

                    KANBAN_STATUSES.forEach((status) => {
                        const option = document.createElement("a");
                        option.className = "dropdown-item";
                        option.textContent = status;
                        option.href = "#";
                        option.addEventListener("click", (e) => {
                            e.preventDefault();
                            const oldStatus = task.Status;
                            task.Status = status;

                            taskProcesses_Linh.push({
                                ProcessID: getNextProcessId(),
                                TaskID: task.TaskID,
                                OldStatus: oldStatus,
                                NewStatus: status,
                                ChangedBy: 1,
                                ChangedDate: new Date().toISOString(),
                            });

                            dropdown.remove();
                            openTaskModal(task.TaskID);
                            render();
                        });
                        dropdown.appendChild(option);
                    });

                    document.body.appendChild(dropdown);

                    setTimeout(() => {
                        document.addEventListener("click", function closeDropdown(e) {
                            if (!dropdown.contains(e.target)) {
                                dropdown.remove();
                                document.removeEventListener("click", closeDropdown);
                            }
                        });
                    }, 0);
                }

                function showPriorityDropdown(element, task) {
                    const rect = element.getBoundingClientRect();
                    const dropdown = document.createElement("div");
                    dropdown.className = "dropdown-menu show";
                    dropdown.style.position = "fixed";
                    dropdown.style.left = rect.left + "px";
                    dropdown.style.top = rect.bottom + 5 + "px";
                    dropdown.style.zIndex = "9999";

                    PRIORITY_OPTIONS.forEach((priority) => {
                        const option = document.createElement("a");
                        option.className = "dropdown-item";
                        option.innerHTML = `<span class="badge ${getPriorityClass(priority)}">${priority}</span>`;
                        option.href = "#";
                        option.addEventListener("click", (e) => {
                            e.preventDefault();
                            AjaxHPAParadise({
                                data: { name: "sp_Task_UpdateField", param: ["TaskID", task.TaskID, "FieldName", "Priority", "Value", priority, "LoginID", LoginID] },
                                success: (res) => {
                                    dropdown.remove();
                                    ReloadData();
                                }
                            });
                        });
                        dropdown.appendChild(option);
                    });

                    document.body.appendChild(dropdown);

                    setTimeout(() => {
                        document.addEventListener("click", function closeDropdown(e) {
                            if (!dropdown.contains(e.target)) {
                                dropdown.remove();
                                document.removeEventListener("click", closeDropdown);
                            }
                        });
                    }, 0);
                }

                function showAssigneeDropdown(element, task) {
                    const rect = element.getBoundingClientRect();
                    const dropdown = document.createElement("div");
                    dropdown.className = "dropdown-menu show";
                    dropdown.style.position = "fixed";
                    dropdown.style.left = rect.left + "px";
                    dropdown.style.top = rect.bottom + 5 + "px";
                    dropdown.style.maxHeight = "200px";
                    dropdown.style.overflowY = "auto";
                    dropdown.style.zIndex = "9999";

                    employees_Linh.forEach((emp) => {
                        const option = document.createElement("a");
                        option.className = "dropdown-item";
                        option.textContent = emp.FullName;
                        option.href = "#";
                        option.addEventListener("click", (e) => {
                            e.preventDefault();
                            AjaxHPAParadise({
                                data: { name: "sp_Task_UpdateField", param: ["TaskID", task.TaskID, "FieldName", "AssigneeID", "Value", emp.EmployeeID, "LoginID", LoginID] },
                                success: (res) => {
                                    dropdown.remove();
                                    ReloadData();
                                }
                            });
                        });
                        dropdown.appendChild(option);
                    });

                    document.body.appendChild(dropdown);

                    setTimeout(() => {
                        document.addEventListener("click", function closeDropdown(e) {
                            if (!dropdown.contains(e.target)) {
                                dropdown.remove();
                                document.removeEventListener("click", closeDropdown);
                            }
                        });
                    }, 0);
                }

                function showTextEditor(element, task, fieldName) {
                    const currentValue = task[fieldName] || "";
                    const isDescription = fieldName === "Description";

                    element.classList.add("editing");

                    const editor = document.createElement(isDescription ? "textarea" : "input");
                    editor.value = currentValue === "Click to add description..." ? "" : currentValue;
                    editor.className = "form-control form-control-sm";

                    if (isDescription) {
                        editor.rows = 4;
                    }

                    element.textContent = "";
                    element.appendChild(editor);
                    editor.focus();

                    const saveEdit = () => {
                        const newValue = editor.value.trim();
                        if (newValue === currentValue) {
                            element.classList.remove("editing");
                            openTaskModal(task.TaskID);
                            return;
                        }

                        AjaxHPAParadise({
                            data: { name: "sp_Task_UpdateField", param: ["TaskID", task.TaskID, "FieldName", fieldName, "Value", newValue, "LoginID", LoginID] },
                            success: (res) => {
                                element.classList.remove("editing");
                                ReloadData();
                            }
                        });
                    };

                    editor.addEventListener("blur", saveEdit);
                    editor.addEventListener("keydown", (e) => {
                        if (e.key === "Enter" && !isDescription) {
                            e.preventDefault();
                            saveEdit();
                        }
                        if (e.key === "Escape") {
                            element.classList.remove("editing");
                            openTaskModal(task.TaskID);
                        }
                    });
                }

                // --- EVENT HANDLERS ---
                function handleCreateOrUpdateTask(e) {
                    e.preventDefault();
                    const context = navigationStack[0];
                    const editTaskId = createTaskForm.dataset.editTaskId ? parseInt(createTaskForm.dataset.editTaskId) : 0;
                    const parentTaskId = createTaskForm.dataset.parentTaskId ? parseInt(createTaskForm.dataset.parentTaskId) : null;
                    const defaultStatus = createTaskForm.dataset.defaultStatus || "To Do";

                    AjaxHPAParadise({
                        data: {
                            name: "sp_Task_Save",
                            param: [
                                "TaskID", editTaskId,
                                "ProjectID", context.id,
                                "TaskName", document.getElementById("create-task-name").value,
                                "Description", document.getElementById("create-task-desc").value,
                                "AssigneeID", document.getElementById("create-task-assignee").value,
                                "Priority", document.getElementById("create-task-priority").value,
                                "Status", defaultStatus,
                                "ParentTaskID", parentTaskId,
                                "LoginID", LoginID
                            ]
                        },
                        success: (res) => {
                            closeModal(''create-task-modal'');
                            if (typeof uiManager !== "undefined") uiManager.showAlert({ type: "success", message: "Lưu công việc thành công" });
                            ReloadData();
                        }
                    });
                }

                function handleDeleteTask(taskId) {
                    if (!confirm("Are you sure you want to delete this task and all its subtasks? This action cannot be undone.")) return;
                    AjaxHPAParadise({
                        data: { name: "sp_Task_Delete", param: ["TaskID", taskId, "LoginID", LoginID] },
                        success: (res) => {
                            closeModal(''task-modal'');
                            if (typeof uiManager !== "undefined") uiManager.showAlert({ type: "success", message: "Xóa công việc thành công" });
                            ReloadData();
                        }
                    });
                }

                function handleCreateProject(e) {
                    e.preventDefault();
                    const newProjectName = document.getElementById("add-project-name").value;
                    if (!newProjectName) return;

                    AjaxHPAParadise({
                        data: {
                            name: "sp_Task_Project_Save",
                            param: [
                                "ProjectName", newProjectName,
                                "LoginID", LoginID
                            ]
                        },
                        success: (res) => {
                            closeModal(''add-project-modal'');
                            if (typeof uiManager !== "undefined") uiManager.showAlert({ type: "success", message: "Thêm dự án thành công" });
                            ReloadData();
                        }
                    });
                }

                function addDragAndDropListeners() {
                    const cards = document.querySelectorAll(".task-card");
                    const columns = document.querySelectorAll(".kanban-column");

                    cards.forEach((card) => {
                        card.addEventListener("dragstart", () => {
                            draggedTaskId = parseInt(card.dataset.taskId);
                            card.classList.add("dragging");
                        });
                        card.addEventListener("dragend", () => {
                            card.classList.remove("dragging");
                            draggedTaskId = null;
                        });
                    });

                    columns.forEach((column) => {
                        column.addEventListener("dragover", (e) => {
                            e.preventDefault();
                            column.classList.add("drag-over");
                        });
                        column.addEventListener("dragleave", () => {
                            column.classList.remove("drag-over");
                        });
                        column.addEventListener("drop", (e) => {
                            e.preventDefault();
                            column.classList.remove("drag-over");
                            const newStatus = column.dataset.status;
                            const task = tasks.find((t) => t.TaskID === draggedTaskId);
                            if (task && task.Status !== newStatus) {
                                const oldStatus = task.Status;
                                task.Status = newStatus;
                                taskProcesses_Linh.push({
                                    ProcessID: getNextProcessId(),
                                    TaskID: draggedTaskId,
                                    OldStatus: oldStatus,
                                    NewStatus: newStatus,
                                    ChangedBy: 1,
                                    ChangedDate: new Date().toISOString(),
                                });
                                render();
                            }
                        });
                    });
                }

                function renderTemplateDetail(template) {
                    const subtasks = typeof template.Subtasks === "string" ? JSON.parse(template.Subtasks) : (template.Subtasks || []);
                    viewContainerEl.innerHTML = `
                        <div class="row">
                            <div class="col-md-4">
                                <div class="card border-0 shadow-sm mb-4">
                                    <div class="card-body">
                                        <h6 class="text-muted small text-uppercase fw-bold mb-3">Template Info</h6>
                                        <div class="mb-3">
                                            <label class="small text-muted d-block">Name</label>
                                            <div class="fw-bold fs-5">${template.TemplateName}</div>
                                        </div>
                                        <div class="mb-3">
                                            <label class="small text-muted d-block">Category</label>
                                            <span class="badge bg-primary-subtle text-primary">${template.Category || "N/A"}</span>
                                        </div>
                                        <div class="mb-3">
                                            <label class="small text-muted d-block">Est. Days</label>
                                            <div class="fw-bold">${template.EstDays} days</div>
                                        </div>
                                        <div>
                                            <label class="small text-muted d-block">Description</label>
                                            <div class="text-muted small">${template.Description || "N/A"}</div>
                                        </div>
                                        <div class="mt-4 pt-3 border-top">
                                            <button class="btn btn-primary w-100" onclick="openCreateTemplateModal(${template.TemplateID})">
                                                <i class="bi bi-pencil"></i> Edit Template
                                            </button>
                                        </div>
                                    </div>
                                </div>
                            </div>
                            <div class="col-md-8">
                                <div class="card border-0 shadow-sm">
                                    <div class="card-header bg-white border-0 py-3">
                                        <h6 class="mb-0 fw-bold">Steps Workflow</h6>
                                    </div>
                                    <div class="card-body p-0">
                                        <div class="list-group list-group-flush">
                                            ${subtasks.sort((a,b) => a.Order - b.Order).map((s, idx) => `
                                                <div class="list-group-item py-3">
                                                    <div class="d-flex gap-3">
                                                        <div class="flex-shrink-0">
                                                            <div class="bg-primary-subtle text-primary rounded-circle d-flex align-items-center justify-content-center fw-bold" style="width: 32px; height:32px;">
                                                                ${idx + 1}
                                                            </div>
                                                        </div>
                                                        <div class="flex-grow-1">
                                                            <div class="d-flex justify-content-between">
                                                                <h6 class="mb-1 fw-bold">${s.TaskName}</h6>
                                                                <span class="badge border">${s.EstHours}h</span>
                                                            </div>
                                                            <div class="text-muted small mb-0">${s.Description || "No description"}</div>
                                                            <div class="mt-1">
                                                                ${s.IsRequired ? ''<span class="badge bg-danger-subtle text-danger" style="font-size:0.65rem;">Required</span>'' : ''''}
                                                                <span class="text-muted small" style="font-size:0.65rem;">Default Role: ${s.DefaultRole || "None"}</span>
                                                            </div>
                                                        </div>
                                                    </div>
                                                </div>
                                            `).join("")}
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>
                    `;
                }

                function renderOverallTimeline() {
                    viewContainerEl.innerHTML = `
                        <div class="card border-0 shadow-sm">
                            <div class="card-body">
                                <h5 class="fw-bold mb-4">Portfolio Gantt Chart</h5>
                                <div id="overall-chart-container" class="overflow-auto" style="min-height: 400px;"></div>
                            </div>
                        </div>
                    `;
                    const chartWrapper = document.getElementById("overall-chart-container");
                    renderProjectsChart(projects_Linh, chartWrapper);
                }

                window.openCreateTemplateModal = function(templateId = null) {
                    alert("Chức năng tạo template đang được hoàn thiện. Vui lòng sử dụng template có sẵn.");
                };

                // --- INITIALIZATION ---
                addProjectForm.addEventListener("submit", handleCreateProject);
                createTaskForm.addEventListener("submit", handleCreateOrUpdateTask);
                
                // Note: deleteTaskBtn listener is attached dynamically in openTaskModal because the button is re-rendered.

                document.getElementById("btn-add-assign-subtask").addEventListener("click", addAssignSubtaskRow);
                document.getElementById("btn-submit-assignment").addEventListener("click", submitTaskAssignment);

                modeSwitcherEl.addEventListener("click", (e) => {
                    const btn = e.target.closest(".nav-link");
                    if (btn) {
                        currentAppMode = btn.dataset.mode;
                        navigationStack = []; // Reset navigation when changing mode
                        render();
                    }
                });
            
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

                    return new Promise((resolve, reject) => {
                        AjaxHPAParadise({
                            data: {
                                name: dataSourceSP,
                                param: ["LoginID", LoginID, "LanguageID", LanguageID]
                            },
                            success: function (res) {
                                const json = typeof res === "string" ? JSON.parse(res) : res;

                                window[dataSourceKey] = (json.data && json.data[0]) || [];
                                window[loadedKey] = true;

                                // Ưu tiên lấy từ json response (nếu API trả về explicit)
                                // Sau đó mới fallback query dataSchema
                                let idField = json.valueExpr;
                                let nameField = json.displayExpr;

                                if (!idField || !nameField) {
                                    if (json.dataSchema && json.dataSchema[0]) {
                                        const schema = json.dataSchema[0];
                                        if (!idField) idField = schema[0]?.name;
                                        if (!nameField) nameField = schema[1]?.name;
                                    }
                                }

                                window["DataSourceIDField_" + columnName]   = idField || "ID";
                                window["DataSourceNameField_" + columnName] = nameField || "Name";

                                const data = window[dataSourceKey];

                                // callback trước
                                if (typeof onSuccessCallback === "function") {
                                    onSuccessCallback(data, json);
                                }

                                // resolve sau
                                resolve(data);
                            },
                            error: function (err) {
                                console.error("[loadDataSourceCommon] Failed to load datasource for", columnName, ":", err);
                                window[loadedKey] = false;

                                if (typeof onSuccessCallback === "function") {
                                    onSuccessCallback([]);
                                }

                                reject(err);
                            }
                        });
                    });
                }

                // Start with data fetching
                fetchData((res) => {
                    // If no projects exist, open add project modal
                    handleResultReload(res);
                    if (projects_Linh.length === 0) openAddProjectModal();
                    else render();
                });

                '
                +(select loadUI from tblCommonControlType_Signed where UID = 'P794C2F8348554BF6B8EB236EC6F3A215')
                +(select loadUI from tblCommonControlType_Signed where UID = 'PCDF4A5D2F59249DD9446C029B7849322')
                +(select loadUI from tblCommonControlType_Signed where UID = 'P40385F4F923B4BB4A6D20DC9AE6850B6')
                +(select loadUI from tblCommonControlType_Signed where UID = 'P5CE9880C159C4472A986171C034CF295')
                +(select loadUI from tblCommonControlType_Signed where UID = 'P8A441B97BF684EBBA615B484D92A4850')
                +(select loadUI from tblCommonControlType_Signed where UID = 'P8D081E689C8B4072AFE480737FBCF0E8')
                +(select loadUI from tblCommonControlType_Signed where UID = 'P5AA042EE89064CD3A87E1731D091AEB7')
                +(select loadUI from tblCommonControlType_Signed where UID = 'PE163B877AF934B69A8B09C828BD02C86') +N'
                window.currentRecordID_ProjectID = null; window.currentRecordID_TaskID = null;
            
                function handleResultReload(res) {
                    const json = typeof res === "string" ? JSON.parse(res) : res;
                    const results = Array.isArray(json?.data?.[0])
                        ? json.data[0]
                        : (json?.data?.[0] ? [json.data[0]] : []);

                    const obj = results.length === 1 ? results[0] : (results[0] || null);
                    console.log(obj);

                    if (obj) { window.currentRecordID_ProjectID = (obj.ProjectID !== undefined && obj.ProjectID !== null) ? obj.ProjectID : window.currentRecordID_ProjectID; } if (obj) { window.currentRecordID_TaskID = (obj.TaskID !== undefined && obj.TaskID !== null) ? obj.TaskID : window.currentRecordID_TaskID; }
                    DataSource = results;
                    '
                    +(select loadData from tblCommonControlType_Signed where UID = 'P794C2F8348554BF6B8EB236EC6F3A215')
                    +(select loadData from tblCommonControlType_Signed where UID = 'PCDF4A5D2F59249DD9446C029B7849322')
                    +(select loadData from tblCommonControlType_Signed where UID = 'P40385F4F923B4BB4A6D20DC9AE6850B6')
                    +(select loadData from tblCommonControlType_Signed where UID = 'P5CE9880C159C4472A986171C034CF295')
                    +(select loadData from tblCommonControlType_Signed where UID = 'P8A441B97BF684EBBA615B484D92A4850')
                    +(select loadData from tblCommonControlType_Signed where UID = 'P8D081E689C8B4072AFE480737FBCF0E8')
                    +(select loadData from tblCommonControlType_Signed where UID = 'P5AA042EE89064CD3A87E1731D091AEB7')
                    +(select loadData from tblCommonControlType_Signed where UID = 'PE163B877AF934B69A8B09C828BD02C86') +N'
                }
            })();
        </script>
    </div>
';
SELECT @html AS html;
--EXEC sp_GenerateHTMLScript_new 'sp_Task_TaskList_html'
END
GO
EXEC sp_GenerateHTMLScript_new 'sp_Task_TaskList_html'