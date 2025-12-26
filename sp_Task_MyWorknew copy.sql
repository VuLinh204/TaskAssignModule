USE Paradise_Beta_Tai2
GO
if object_id('[dbo].[sp_Task_MyWork_html]') is null
	EXEC ('CREATE PROCEDURE [dbo].[sp_Task_MyWork_html] as select 1')
GO

ALTER PROCEDURE [dbo].[sp_Task_MyWork_html]
    @LoginID    INT = 3,
    @LanguageID VARCHAR(2) = 'VN',
    @isWeb      INT = 1
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @html NVARCHAR(MAX);
    SET @html = N'
    <style>
        :root {
            --task-primary: #2E7D32;
            --task-primary-light: #1c975eff;
            --task-primary-hover: #1c975e;
            --sts-todo: #dfe1e6;
            --sts-doing: #deebff;
            --sts-done: #e3fcef;
            --sts-todo-text: #42526e;
            --sts-doing-text: #0747a6;
            --sts-done-text: #006644;
            --danger-color: #E53935;
            --warning-color: #FB8C00;
            --success-color: #00C875;
            --border-color: #e8eaed;
            --text-primary: #1a1a1a;
            --text-secondary: #676879;
            --text-muted: #87909e;
            --bg-white: #ffffff;
            --bg-light: #f8f9fa;
            --bg-lighter: #f0f2f5;
            --shadow-sm: 0 1px 3px rgba(0, 0, 0, 0.02);
            --shadow-md: 0 4px 16px rgba(0, 0, 0, 0.08);
            --shadow-lg: 0 10px 40px rgba(0, 0, 0, 0.15);
            --shadow-hover: 0 6px 20px rgba(46, 125, 50, 0.3);
            --transition-base: 0.2s ease;
        }

        #sp_Task_MyWork_html {
            padding: 20px;
        }

        #sp_Task_MyWork_html .h-title {
            font-weight: 700;
            font-size: clamp(20px, 5vw, 28px);
        }

        #sp_Task_MyWork_html .h-title i {
            color: var(--task-primary);
            font-size: 1.2em;
        }

        /* Stats Row */
        #sp_Task_MyWork_html .stats-row {
            gap: 10px;
            margin-bottom: 20px;
        }

        #sp_Task_MyWork_html .stats-row .stat-card {
            padding: 12px 16px;
            border-radius: 10px;
            min-width: 120px;
            display: flex;
            align-items: center;
            gap: 12px;
            box-shadow: 0 1px 4px rgba(0,0,0,0.04);
            border: 1px solid rgba(0,0,0,0.04);
            background: white;
            transition: all var(--transition-base);
        }

        #sp_Task_MyWork_html .stats-row .stat-card:hover {
            transform: translateY(-2px);
            box-shadow: var(--shadow-md);
        }

        #sp_Task_MyWork_html .stat-card::before {
            content: "";
            width: 4px;
            height: 40px;
            border-radius: 4px;
        }

        #sp_Task_MyWork_html .stat-card.todo::before {
            background: var(--sts-todo-text);
        }

        #sp_Task_MyWork_html .stat-card.doing::before {
            background: var(--sts-doing-text);
        }

        #sp_Task_MyWork_html .stat-card.done::before {
            background: var(--success-color);
        }

        #sp_Task_MyWork_html .stat-card.overdue::before {
            background: var(--danger-color);
        }

        #sp_Task_MyWork_html .stat-card .stat-label-task {
            font-size: 12px;
            font-weight: 600;
            text-transform: uppercase;
            margin: 0;
            color: var(--text-secondary);
            letter-spacing: 0.5px;
        }

        #sp_Task_MyWork_html .stat-card .stat-value {
            font-size: 24px;
            font-weight: 800;
            margin-left: auto;
        }

        #sp_Task_MyWork_html .stat-card.todo .stat-value {
            color: var(--sts-todo-text);
        }

        #sp_Task_MyWork_html .stat-card.doing .stat-value {
            color: var(--sts-doing-text);
        }

        #sp_Task_MyWork_html .stat-card.done .stat-value {
            color: var(--success-color);
        }

        #sp_Task_MyWork_html .stat-card.overdue .stat-value {
            color: var(--danger-color);
        }

        /* Buttons */
        #sp_Task_MyWork_html .btn-refresh {
            border: 1.5px solid var(--border-color);
            padding: 10px 16px;
            border-radius: 8px;
            cursor: pointer;
            transition: all var(--transition-base);
            font-weight: 600;
            display: inline-flex;
            align-items: center;
            gap: 8px;
            font-size: 14px;
            white-space: nowrap;
            background: white;
        }

        #sp_Task_MyWork_html .btn-refresh:hover {
            border-color: var(--task-primary);
            color: var(--task-primary);
            transform: translateY(-2px);
            box-shadow: var(--shadow-sm);
        }

        #sp_Task_MyWork_html .btn-assign {
            background: var(--task-primary);
            color: white;
            border: none;
            padding: 10px 20px;
            border-radius: 8px;
            font-weight: 600;
            cursor: pointer;
            transition: all var(--transition-base);
            display: inline-flex;
            align-items: center;
            gap: 8px;
            font-size: 14px;
            white-space: nowrap;
        }

        #sp_Task_MyWork_html .btn-assign:hover {
            background: var(--task-primary-hover);
            transform: translateY(-2px);
            box-shadow: var(--shadow-hover);
        }

        #sp_Task_MyWork_html .view-switcher {
            display: flex;
            gap: 8px;
            padding: 4px;
            border-radius: 10px;
            border: 1px solid var(--border-color);
            box-shadow: var(--shadow-sm);
            background: white;
        }

        #sp_Task_MyWork_html .view-btn {
            padding: 8px 16px;
            border-radius: 6px;
            border: none;
            background: transparent;
            cursor: pointer;
            font-weight: 600;
            font-size: 13px;
            transition: all var(--transition-base);
            display: flex;
            align-items: center;
            gap: 8px;
            white-space: nowrap;
        }

        #sp_Task_MyWork_html .view-btn:hover:not(.active) {
            opacity: 0.8;
        }

        #sp_Task_MyWork_html .view-btn.active {
            background: var(--task-primary);
            color: white;
            box-shadow: var(--shadow-sm);
        }

        /* DevExtreme Grid Custom Styles */
        #sp_Task_MyWork_html .dx-datagrid {
            border-radius: 12px;
            overflow: hidden;
            box-shadow: var(--shadow-sm);
            border: 1px solid var(--border-color);
        }

        #sp_Task_MyWork_html .dx-datagrid-headers {
            background: var(--bg-lighter);
            font-weight: 600;
            color: var(--text-secondary);
        }

        #sp_Task_MyWork_html .dx-datagrid-headers .dx-datagrid-text-content {
            font-size: 13px;
            text-transform: uppercase;
            letter-spacing: 0.3px;
        }

        #sp_Task_MyWork_html .dx-datagrid-rowsview .dx-row {
            border-bottom: 1px solid var(--bg-lighter);
        }

        #sp_Task_MyWork_html .dx-datagrid-rowsview .dx-row:hover {
            background-color: rgba(46, 125, 50, 0.05);
        }

        #sp_Task_MyWork_html .dx-datagrid-rowsview .dx-data-row.dx-row-focused {
            background-color: rgba(46, 125, 50, 0.1);
        }

        #sp_Task_MyWork_html .dx-datagrid-rowsview .dx-selection.dx-row {
            background-color: rgba(46, 125, 50, 0.08);
        }

        /* Priority Icons */
        #sp_Task_MyWork_html .priority-icon {
            font-size: 18px;
            transition: transform var(--transition-base);
        }

        #sp_Task_MyWork_html .priority-icon:hover {
            transform: scale(1.2);
        }

        #sp_Task_MyWork_html .prio-1 {
            color: var(--danger-color);
        }

        #sp_Task_MyWork_html .prio-2 {
            color: var(--warning-color);
        }

        #sp_Task_MyWork_html .prio-3 {
            color: #9e9e9e;
        }

        /* Status Badge */
        #sp_Task_MyWork_html .badge-sts {
            padding: 6px 14px;
            border-radius: 8px;
            font-size: 11px;
            font-weight: 700;
            text-transform: uppercase;
            display: inline-block;
            letter-spacing: 0.5px;
            transition: all var(--transition-base);
        }

        #sp_Task_MyWork_html .badge-sts:hover {
            transform: scale(1.05);
            box-shadow: var(--shadow-sm);
        }

        #sp_Task_MyWork_html .sts-1 {
            background: var(--sts-todo);
            color: var(--sts-todo-text);
        }

        #sp_Task_MyWork_html .sts-2 {
            background: var(--sts-doing);
            color: var(--sts-doing-text);
        }

        #sp_Task_MyWork_html .sts-3 {
            background: var(--sts-done);
            color: var(--sts-done-text);
        }

        /* Progress Bar */
        #sp_Task_MyWork_html .progress-cell {
            display: flex;
            align-items: center;
            gap: 8px;
            width: 100%;
        }

        #sp_Task_MyWork_html .progress-info {
            font-size: 11px;
            color: var(--text-muted);
            white-space: nowrap;
            min-width: 60px;
        }

        #sp_Task_MyWork_html .progress-bar-container {
            flex: 1;
            height: 8px;
            background: var(--bg-lighter);
            border-radius: 4px;
            overflow: hidden;
            position: relative;
        }

        #sp_Task_MyWork_html .progress-bar-fill {
            height: 100%;
            background: linear-gradient(90deg, var(--task-primary), var(--task-primary-hover));
            border-radius: 4px;
            transition: width 0.6s cubic-bezier(0.4, 0, 0.2, 1);
            position: relative;
            overflow: hidden;
        }

        #sp_Task_MyWork_html .progress-bar-fill::after {
            content: "";
            position: absolute;
            top: 0;
            left: 0;
            right: 0;
            bottom: 0;
            background: linear-gradient(90deg, transparent, rgba(255,255,255,0.3), transparent);
            animation: shimmer 2s infinite;
        }

        @keyframes shimmer {
            0% { transform: translateX(-100%); }
            100% { transform: translateX(100%); }
        }

        #sp_Task_MyWork_html .progress-text {
            font-size: 13px;
            font-weight: 700;
            min-width: 45px;
            text-align: right;
            color: var(--task-primary);
        }

        /* Drag handle */
        #sp_Task_MyWork_html .drag-handle {
            cursor: grab;
            color: var(--text-muted);
            font-size: 18px;
            padding: 4px;
            transition: all var(--transition-base);
        }

        #sp_Task_MyWork_html .drag-handle:hover {
            color: var(--task-primary);
            transform: scale(1.1);
        }

        #sp_Task_MyWork_html .drag-handle:active {
            cursor: grabbing;
        }

        /* Employee avatars */
        #sp_Task_MyWork_html .employee-list {
            display: flex;
            align-items: center;
            gap: 4px;
        }

        #sp_Task_MyWork_html .employee-avatar {
            width: 32px;
            height: 32px;
            border-radius: 50%;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 12px;
            font-weight: 700;
            color: white;
            border: 2px solid white;
            margin-left: -8px;
            box-shadow: 0 2px 4px rgba(0,0,0,0.1);
            transition: all var(--transition-base);
        }

        #sp_Task_MyWork_html .employee-avatar:first-child {
            margin-left: 0;
        }

        #sp_Task_MyWork_html .employee-avatar:hover {
            transform: translateY(-2px) scale(1.1);
            box-shadow: 0 4px 8px rgba(0,0,0,0.15);
            z-index: 10;
        }

        #sp_Task_MyWork_html .employee-more {
            background: #e2e8f0;
            color: var(--text-secondary);
        }

        /* Drag preview */
        #sp_Task_MyWork_html .dx-sortable-dragging {
            opacity: 0.5;
            box-shadow: var(--shadow-lg);
        }

        #sp_Task_MyWork_html .dx-sortable-placeholder {
            background-color: rgba(46, 125, 50, 0.1);
            border: 2px dashed var(--task-primary);
            border-radius: 8px;
        }

        /* Task name cell */
        #sp_Task_MyWork_html .task-name-cell {
            display: flex;
            flex-direction: column;
            gap: 4px;
        }

        #sp_Task_MyWork_html .task-name-title {
            font-weight: 600;
            color: var(--text-primary);
            line-height: 1.4;
        }

        #sp_Task_MyWork_html .task-name-meta {
            display: flex;
            align-items: center;
            gap: 12px;
            font-size: 12px;
            color: var(--text-muted);
        }

        #sp_Task_MyWork_html .task-comment-badge {
            display: flex;
            align-items: center;
            gap: 4px;
        }

        /* Date cell */
        #sp_Task_MyWork_html .date-cell {
            display: flex;
            align-items: center;
            gap: 6px;
            font-size: 13px;
        }

        #sp_Task_MyWork_html .date-cell.overdue {
            color: var(--danger-color);
            font-weight: 700;
        }

        #sp_Task_MyWork_html .date-cell.overdue i {
            animation: pulse 2s infinite;
        }

        @keyframes pulse {
            0%, 100% { opacity: 1; }
            50% { opacity: 0.5; }
        }

        /* Action button */
        #sp_Task_MyWork_html .action-btn {
            padding: 6px 12px;
            border-radius: 6px;
            border: 1px solid var(--border-color);
            background: white;
            cursor: pointer;
            transition: all var(--transition-base);
            display: inline-flex;
            align-items: center;
            gap: 6px;
            font-size: 13px;
        }

        #sp_Task_MyWork_html .action-btn:hover {
            border-color: var(--task-primary);
            color: var(--task-primary);
            transform: translateY(-1px);
            box-shadow: var(--shadow-sm);
        }

        /* Master detail */
        #sp_Task_MyWork_html .dx-master-detail-cell {
            padding: 16px;
            background: var(--bg-light);
        }

        #sp_Task_MyWork_html .subtask-header {
            font-weight: 600;
            margin-bottom: 12px;
            color: var(--text-primary);
            display: flex;
            align-items: center;
            gap: 8px;
        }

        #sp_Task_MyWork_html .table {
            background: white;
            border: 1px solid var(--border-color);
            border-radius: 8px;
            overflow: hidden;
        }

        #sp_Task_MyWork_html .table thead {
            background-color: var(--bg-lighter);
            font-weight: 600;
            text-transform: uppercase;
            font-size: 12px;
            letter-spacing: 0.3px;
        }

        #sp_Task_MyWork_html .table tbody tr {
            border-bottom: 1px solid var(--bg-lighter);
            transition: background-color var(--transition-base);
        }

        #sp_Task_MyWork_html .table tbody tr:hover {
            background-color: rgba(46, 125, 50, 0.02);
        }

        #sp_Task_MyWork_html .table td {
            padding: 10px 12px;
            vertical-align: middle;
            color: var(--text-secondary);
        }

        #sp_Task_MyWork_html .table .badge-sts {
            font-size: 10px;
        }

        /* Loading */
        #sp_Task_MyWork_html .dx-loadpanel-content {
            border-radius: 12px;
            box-shadow: var(--shadow-lg);
        }

        /* Toolbar */
        #sp_Task_MyWork_html .dx-toolbar {
            background: transparent;
            border: none;
            padding: 0;
        }

        /* Filter row */
        #sp_Task_MyWork_html .dx-editor-cell .dx-texteditor {
            border-radius: 6px;
        }

        /* Pager */
        #sp_Task_MyWork_html .dx-pager {
            background: transparent;
            border: none;
            padding: 12px 0;
        }

        /* Context menu */
        #sp_Task_MyWork_html .dx-context-menu .dx-menu-item-content {
            padding: 8px 16px;
        }

        /* Responsive */
        @media (max-width: 768px) {
            #sp_Task_MyWork_html {
                padding: 12px;
            }

            #sp_Task_MyWork_html .h-title {
                font-size: 20px;
            }

            #sp_Task_MyWork_html .stats-row {
                flex-wrap: wrap;
            }

            #sp_Task_MyWork_html .stat-card {
                flex: 1 1 calc(50% - 10px);
                min-width: 140px;
            }
        }

        /* ===== KANBAN BOARD STYLES ===== */
        #sp_Task_MyWork_html .kanban-board {
            display: grid;
            grid-template-columns: repeat(3, 1fr);
            gap: 20px;
            margin-top: 20px;
        }

        #sp_Task_MyWork_html .kanban-column {
            border-radius: 12px;
            padding: 16px;
            min-height: 500px;
            border: 1px solid var(--border-color);
            box-shadow: var(--shadow-sm);
            background: var(--bg-white);
        }

        #sp_Task_MyWork_html .column-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 16px;
            padding-bottom: 12px;
            border-bottom: 2px solid var(--bg-lighter);
        }

        #sp_Task_MyWork_html .column-title {
            font-weight: 700;
            font-size: 15px;
            display: flex;
            align-items: center;
            gap: 8px;
        }

        #sp_Task_MyWork_html .column-count {
            background: var(--bg-lighter);
            padding: 4px 10px;
            border-radius: 12px;
            font-size: 12px;
            font-weight: 700;
            color: var(--text-secondary);
            min-width: 28px;
            text-align: center;
        }

        #sp_Task_MyWork_html .kanban-board .cu-row {
            margin-bottom: 12px;
            border-radius: 8px;
            border: 1px solid var(--border-color);
            max-height: none;
            background: var(--bg-white);
            padding: 12px;
            display: flex;
            flex-direction: column;
            gap: 8px;
            cursor: pointer;
            transition: all var(--transition-base);
        }

        #sp_Task_MyWork_html .kanban-board .cu-row:hover {
            box-shadow: var(--shadow-md);
            transform: translateY(-2px);
            border-color: var(--task-primary);
        }

        #sp_Task_MyWork_html .kanban-board .task-row .task-title {
            font-weight: 600;
            margin: 0;
        }

        #sp_Task_MyWork_html .kanban-board .task-row .task-sub {
            display: flex;
            gap: 12px;
            font-size: 12px;
            margin: 4px 0;
        }

        #sp_Task_MyWork_html .kanban-board .task-row .row-kpi {
            margin-top: 8px;
        }

        /* ===== ASSIGN MODAL STYLES ===== */
        #sp_Task_MyWork_html .assign-modal .modal-dialog {
            max-width: 1000px;
        }

        #sp_Task_MyWork_html .assign-container {
            padding: 24px 32px;
            max-height: 70vh;
            overflow-y: auto;
        }

        #sp_Task_MyWork_html .assign-step {
            margin-bottom: 28px;
            padding-bottom: 20px;
            border-bottom: 1px solid var(--border-color);
        }

        #sp_Task_MyWork_html .assign-step:last-child {
            border-bottom: none;
            margin-bottom: 0;
        }

        #sp_Task_MyWork_html .step-header {
            display: flex;
            align-items: flex-start;
            gap: 16px;
            margin-bottom: 18px;
        }

        #sp_Task_MyWork_html .step-number {
            width: 40px;
            height: 40px;
            border-radius: 50%;
            background: var(--task-primary);
            color: white;
            display: flex;
            align-items: center;
            justify-content: center;
            font-weight: 700;
            flex-shrink: 0;
            box-shadow: 0 2px 8px rgba(46, 125, 50, 0.2);
        }

        #sp_Task_MyWork_html .step-title {
            font-size: 16px;
            font-weight: 600;
            color: var(--text-primary);
        }

        #sp_Task_MyWork_html .assign-row {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 16px;
            align-items: start;
        }

        #sp_Task_MyWork_html .form-group {
            margin-bottom: 0;
        }

        #sp_Task_MyWork_html .form-label {
            font-weight: 600;
            margin-bottom: 8px;
            font-size: 13px;
        }

        #sp_Task_MyWork_html .form-control,
        #sp_Task_MyWork_html .form-select {
            border-radius: 8px;
            border: 1.5px solid var(--border-color);
            padding: 10px 12px;
            font-size: 13px;
        }

        #sp_Task_MyWork_html .form-control:focus,
        #sp_Task_MyWork_html .form-select:focus {
            border-color: var(--task-primary);
            box-shadow: 0 0 0 3px rgba(46, 125, 50, 0.1);
            outline: none;
        }

        #sp_Task_MyWork_html .search-select {
            position: relative;
        }

        #sp_Task_MyWork_html .search-select .form-select.d-none {
            display: none !important;
        }

        /* ===== MODAL STYLES ===== */
        #sp_Task_MyWork_html .modal-backdrop {
            background-color: rgba(0, 0, 0, 0.7) !important;
            backdrop-filter: blur(8px);
            -webkit-backdrop-filter: blur(8px);
        }

        #sp_Task_MyWork_html .modal-backdrop.show {
            opacity: 0.7 !important;
        }

        #sp_Task_MyWork_html .modal {
            z-index: 1055 !important;
        }

        #sp_Task_MyWork_html .modal-backdrop {
            z-index: 1050 !important;
        }

        @media (max-width: 992px) {
            #sp_Task_MyWork_html .assign-row {
                grid-template-columns: 1fr;
            }
        }

        @media (max-width: 1200px) {
            #sp_Task_MyWork_html .kanban-board {
                grid-template-columns: 1fr;
            }
        }

        @media (max-width: 768px) {
            #sp_Task_MyWork_html .kanban-board {
                grid-template-columns: 1fr;
                gap: 12px;
            }

            #sp_Task_MyWork_html .kanban-column {
                min-height: 300px;
            }
        }
    </style>

    <div id="sp_Task_MyWork_html">
        <div class="cu-header d-flex justify-content-between align-items-center mb-4 gap-2 flex-wrap">
            <div class="h-title m-0 gap-3 d-flex align-items-center">
                <i class="bi bi-check-circle-fill"></i>Công việc của tôi
            </div>
            <div class="header-actions d-flex align-items-center gap-2 flex-wrap">
                <div class="view-switcher">
                    <button class="view-btn active" id="viewGrid">
                        <i class="bi bi-table"></i> Grid
                    </button>
                    <button class="view-btn" id="viewKanban">
                        <i class="bi bi-kanban"></i> Kanban
                    </button>
                </div>
                <button class="btn-assign" id="btnAssign">
                    <i class="bi bi-plus-circle-fill"></i> Giao việc
                </button>
                <button class="btn-refresh" id="btnRefresh">
                    <i class="bi bi-arrow-clockwise"></i> Tải lại
                </button>
            </div>
        </div>

        <!-- Statistics -->
        <div class="stats-row d-flex align-items-center flex-wrap" id="stats-container">
            <div class="stat-card todo">
                <div class="stat-label-task">Chưa làm</div>
                <div class="stat-value" id="stat-todo">0</div>
            </div>
            <div class="stat-card doing">
                <div class="stat-label-task">Đang làm</div>
                <div class="stat-value" id="stat-doing">0</div>
            </div>
            <div class="stat-card done">
                <div class="stat-label-task">Hoàn thành</div>
                <div class="stat-value" id="stat-done">0</div>
            </div>
            <div class="stat-card overdue">
                <div class="stat-label-task">Quá hạn</div>
                <div class="stat-value" id="stat-overdue">0</div>
            </div>
        </div>

        <!-- DevExtreme DataGrid (Grid View) -->
        <div id="taskGrid"></div>

        <!-- Kanban View -->
        <div id="kanban-view" style="display:none;">
            <div class="kanban-board">
                <div class="kanban-column">
                    <div class="column-header">
                        <div class="column-title">
                            <i class="bi bi-circle-fill" style="font-size:10px;color:#9ca3af;"></i>
                            Chưa làm
                        </div>
                        <div class="column-count" id="count-todo">0</div>
                    </div>
                    <div id="tasks-todo"></div>
                </div>
                <div class="kanban-column">
                    <div class="column-header">
                        <div class="column-title">
                            <i class="bi bi-circle-fill" style="font-size:10px;color:#0747a6;"></i>
                            Đang làm
                        </div>
                        <div class="column-count" id="count-doing">0</div>
                    </div>
                    <div id="tasks-doing"></div>
                </div>
                <div class="kanban-column">
                    <div class="column-header">
                        <div class="column-title">
                            <i class="bi bi-circle-fill" style="font-size:10px;color:#006644;"></i>
                            Hoàn thành
                        </div>
                        <div class="column-count" id="count-done">0</div>
                    </div>
                    <div id="tasks-done"></div>
                </div>
            </div>
        </div>

        <!-- Assign Modal -->
        <div class="modal fade assign-modal" id="mdlAssign" tabindex="-1">
            <div class="modal-dialog modal-dialog-centered" style="max-width:1000px;">
                <div class="modal-content">
                    <div class="modal-header">
                        <h5 class="modal-title"><i class="bi bi-person-plus-fill"></i> Giao việc</h5>
                        <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                    </div>
                    <div class="modal-body assign-container">
                        <div class="assign-step">
                            <div class="step-header">
                                <div class="step-number">1</div>
                                <div>
                                    <div class="step-title">Chọn công việc</div>
                                    <small class="text-muted">Tìm công việc bạn muốn giao</small>
                                </div>
                            </div>
                            <div class="assign-row">
                                <div class="search-select">
                                    <div id="parentTaskSearch" style="width:100%;"></div>
                                    <select id="parentTaskSelect" class="form-select d-none"></select>
                                </div>
                            </div>
                        </div>
                        <div class="assign-step">
                            <div class="step-header">
                                <div class="step-number">2</div>
                                <div>
                                    <div class="step-title">Chọn người nhận</div>
                                    <small class="text-muted">Ai sẽ thực hiện công việc</small>
                                </div>
                            </div>
                            <div class="assign-row">
                                <div class="search-select">
                                    <div id="assigneeSearch" style="width:100%;"></div>
                                </div>
                            </div>
                        </div>
                        <div class="assign-step">
                            <div class="step-header">
                                <div class="step-number">3</div>
                                <div>
                                    <div class="step-title">Thiết lập ưu tiên và hạn</div>
                                    <small class="text-muted">Độ ưu tiên và ngày hạn</small>
                                </div>
                            </div>
                            <div class="assign-row">
                                <div class="form-group">
                                    <label class="form-label">Độ ưu tiên</label>
                                    <select id="prioritySelect" class="form-select">
                                        <option value="1">Cao</option>
                                        <option value="2" selected>Trung bình</option>
                                        <option value="3">Thấp</option>
                                    </select>
                                </div>
                                <div class="form-group">
                                    <label class="form-label">Hạn chót</label>
                                    <input type="date" id="dueDateInput" class="form-control">
                                </div>
                            </div>
                        </div>
                    </div>
                    <div class="modal-footer">
                        <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Hủy</button>
                        <button type="button" class="btn btn-primary" id="btnSaveAssign">Giao việc</button>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <script>
        (function() {
            "use strict";

            var allTasks = [];
            var taskGridInstance = null;
            var currentView = "grid";

            $(document).ready(function() {
                initializeGrid();
                loadTasks();
                attachEventHandlers();
            });

            function initializeGrid() {
                taskGridInstance = $("#taskGrid").dxDataGrid({
                    dataSource: [],
          keyExpr: "TaskID",
                    showBorders: true,
                    showRowLines: true,
                    showColumnLines: false,
                    rowAlternationEnabled: false,
                    hoverStateEnabled: true,
                    columnAutoWidth: true,
                    allowColumnReordering: true,
                    allowColumnResizing: true,
                    columnResizingMode: "widget",
                    wordWrapEnabled: true,

                    // Enable drag and drop
                    rowDragging: {
                        allowReordering: true,
                        showDragIcons: true,
                        dropFeedbackMode: "indicate",
                        onDragChange: function(e) {
                            var visibleRows = e.component.getVisibleRows();
                            var sourceData = e.itemData;
                            var targetData = visibleRows[e.toIndex].data;
                        },
                        onReorder: function(e) {
                            var visibleRows = e.component.getVisibleRows();
                            var toIndex = e.toIndex;
                            var fromIndex = visibleRows.findIndex(function(row) {
                                return row.data.TaskID === e.itemData.TaskID;
                            });

                            // Update data source
                            var tasksCopy = allTasks.slice();
                            var movedTask = tasksCopy.splice(fromIndex, 1)[0];
                            tasksCopy.splice(toIndex, 0, movedTask);
                            allTasks = tasksCopy;

                            // Save new order to server
                            saveTaskOrder(e.itemData, toIndex);

                            // Refresh grid
                            e.component.option("dataSource", allTasks);
                        },
                        onAdd: function(e) {
                            console.log("Task added", e);
                        },
                        onRemove: function(e) {
                            console.log("Task removed", e);
                        },
                        dragTemplate: function(dragInfo, containerElement) {
                            var task = dragInfo.itemData;
                            var dragElement = $("<div>").css({
                                padding: "12px 16px",
                                background: "white",
                                border: "2px solid var(--task-primary)",
                                borderRadius: "8px",
                                boxShadow: "var(--shadow-lg)",
                                maxWidth: "300px",
                                display: "flex",
                                alignItems: "center",
                                gap: "12px"
                            });

                            $("<i>").addClass("bi bi-grip-vertical").css({
                                color: "var(--task-primary)",
                                fontSize: "18px"
                            }).appendTo(dragElement);

                            $("<div>").css({
                                fontWeight: "600",
                                color: "var(--text-primary)",
                                overflow: "hidden",
                                textOverflow: "ellipsis",
                                whiteSpace: "nowrap"
                            }).text(task.TaskName).appendTo(dragElement);

                            $(containerElement).append(dragElement);
                        }
                    },

                    // Toolbar
                    toolbar: {
                        items: [
                            {
                                location: "before",
                                template: function() {
        return $("<div>").css({
                                        fontWeight: "600",
                                        fontSize: "14px",
                                        color: "var(--text-secondary)"
                                    }).text("Danh sách công việc");
                                }
                            },
                            "groupPanel",
                            "exportButton",
                            "columnChooserButton",
                            "searchPanel"
                        ]
                    },

                    // Selection
                    selection: {
                        mode: "multiple",
                        showCheckBoxesMode: "onClick",
                        allowSelectAll: true
                    },

                    // Paging
                    paging: {
                        enabled: true,
                        pageSize: 50
                    },

                    pager: {
                        visible: true,
                        allowedPageSizes: [10, 20, 50, 100],
                        showPageSizeSelector: true,
                        showInfo: true,
                        showNavigationButtons: true
                    },

                    // Grouping
                    grouping: {
                        autoExpandAll: true,
                        contextMenuEnabled: true
                    },

                    groupPanel: {
                        visible: true,
                        emptyPanelText: "Kéo cột vào đây để nhóm theo tiêu chí"
                    },

                    // Filtering
                    filterRow: {
                        visible: true,
                        applyFilter: "auto"
                    },

                    searchPanel: {
                        visible: true,
                        width: 240,
                        placeholder: "Tìm kiếm công việc..."
                    },

                    // Header filter
                    headerFilter: {
                        visible: true
                    },

                    // Column chooser
                    columnChooser: {
                        enabled: true,
                        mode: "select",
                        title: "Chọn cột hiển thị"
                    },

                    // Export
                    export: {
                        enabled: true,
                        fileName: "CongViecCuaToi",
                        allowExportSelectedData: true
                    },

                    // State storing
                    stateStoring: {
                        enabled: true,
                        type: "localStorage",
                        storageKey: "taskGridState"
                    },

                    // Sorting
                    sorting: {
                        mode: "multiple"
                    },

                    // Scrolling
                    scrolling: {
                        mode: "virtual",
                        rowRenderingMode: "virtual",
                        showScrollbar: "onHover"
                    },

                    // Column fixing
                    columnFixing: {
                        enabled: true
                    },

                    // Columns
                    columns: [
                        {
                            type: "drag",
                            width: 50,
                            allowReordering: false,
                            allowGrouping: false,
                            allowSorting: false,
                            allowFiltering: false,
                            allowExporting: false,
                            fixed: true,
                            fixedPosition: "left",
                            cellTemplate: function(container, options) {
                                $("<i>").addClass("bi bi-grip-vertical drag-handle")
                                    .attr("title", "Kéo để sắp xếp")
                                    .appendTo(container);
                            }
                        },
                        {
                            dataField: "TaskID",
                            caption: "ID",
                            width: 80,
                            alignment: "center",
                            allowEditing: false,
                            fixed: false,
                            sortOrder: "desc"
                        },
                        {
                            dataField: "GroupID",
                            caption: "Nhóm (Task cha)",
                            width: 120,
                            alignment: "center",
                            allowGrouping: true,
                            allowFiltering: true,
                            visible: true,
                            cellTemplate: function(container, options) {
                                var groupId = options.value;
                                if (groupId === null || groupId === undefined) {
                                    $("<span>").css("color", "var(--text-muted)").text("-").appendTo(container);
                                } else {
                                    $("<span>").text("#" + groupId).appendTo(container);
                                }
                            }
                        },
                        {
                            dataField: "ParentTaskID",
                            caption: "Task cha",
                            width: 100,
                            alignment: "center",
                            allowGrouping: false,
                            allowFiltering: true,
                            visible: true,
                            cellTemplate: function(container, options) {
                                var parentId = options.value;
                                if (parentId === null || parentId === undefined) {
                                    $("<span>").css({
                                        color: "var(--success-color)",
                                        fontWeight: "600"
                                    }).text("Parent").appendTo(container);
                                } else {
                                    $("<span>").css({
                                        color: "var(--text-secondary)"
                                    }).text("Child").appendTo(container);
                                }
                            }
                        },
                        {
                            dataField: "TaskName",
                            caption: "Tên công việc",
                            minWidth: 250,
                            fixed: false,
                            cellTemplate: function(container, options) {
                                var task = options.data;
                                var div = $("<div>").addClass("task-name-cell");

                                $("<div>").addClass("task-name-title")
                                    .text(task.TaskName)
                                    .appendTo(div);

                                var meta = $("<div>").addClass("task-name-meta");

                                if (task.CommentCount > 0) {
                                    $("<span>").addClass("task-comment-badge")
                                        .html(`<i class="bi bi-chat-dots"></i> ${task.CommentCount} bình luận`)
                                        .appendTo(meta);
                                }

                                $("<span>").text("#" + task.TaskID).appendTo(meta);

                                if (task.ParentTaskName) {
                                  $("<span>").html(`<i class="bi bi-diagram-3"></i> ${task.ParentTaskName}`)
                                        .appendTo(meta);
                                }

                                meta.appendTo(div);
                                div.appendTo(container);
                            }
                        },
                        {
                            dataField: "AssignPriority",
                            caption: "Ưu tiên",
                            width: 100,
                            alignment: "center",
                            allowHeaderFiltering: true,
                            headerFilter: {
                                dataSource: [
                                    { value: 1, text: "Cao" },
                                    { value: 2, text: "Trung bình" },
                                    { value: 3, text: "Thấp" }
                                ]
                            },
                            cellTemplate: function(container, options) {
                                var priority = options.value || 3;
                                var prioClass = "prio-" + priority;
                                var prioText = priority === 1 ? "Cao" : priority === 2 ? "Trung bình" : "Thấp";

                                $("<i>").addClass("bi bi-flag-fill priority-icon " + prioClass)
                                    .attr("title", prioText)
                                    .appendTo(container);
                            }
                        },
                        {
                            dataField: "AssignedToEmployeeIDs",
                            caption: "Người thực hiện",
                            width: 200,
                            allowSorting: false,
                            cellTemplate: function(container, options) {
                                var task = options.data;
                                var empIds = task.AssignedToEmployeeIDs ?
                                    task.AssignedToEmployeeIDs.split(",") : [];
                                var empNames = task.AssignedToName ?
                                    task.AssignedToName.split(",") : [];

                                var empDiv = $("<div>").addClass("employee-list");

                                var maxVisible = 3;
                                empNames.slice(0, maxVisible).forEach(function(name, idx) {
                                    var initials = getInitials(name.trim());
                                    var colors = [
                                        "linear-gradient(135deg, #667eea 0%, #764ba2 100%)",
                                        "linear-gradient(135deg, #f093fb 0%, #f5576c 100%)",
                                        "linear-gradient(135deg, #4facfe 0%, #00f2fe 100%)",
                                        "linear-gradient(135deg, #43e97b 0%, #38f9d7 100%)",
                                        "linear-gradient(135deg, #fa709a 0%, #fee140 100%)"
                                    ];

                                    $("<div>").addClass("employee-avatar")
                                        .attr("title", name.trim())
                                        .css("background", colors[idx % colors.length])
                                        .text(initials)
                                     .appendTo(empDiv);
                                });

                                if (empNames.length > maxVisible) {
                                    $("<div>").addClass("employee-avatar employee-more")
                                        .attr("title", empNames.slice(maxVisible).join(", "))
                                        .text("+" + (empNames.length - maxVisible))
                                        .appendTo(empDiv);
                                }

                    if (empNames.length === 0) {
                                    $("<span>").css({
                                        fontSize: "12px",
                                        color: "var(--text-muted)",
                                        fontStyle: "italic"
                                    }).text("Chưa gán").appendTo(empDiv);
                                }

                                empDiv.appendTo(container);
                            }
                        },
                        {
                            dataField: "ProgressPct",
                            caption: "Tiến độ",
                            width: 200,
                            alignment: "left",
                            sortOrder: "desc",
                            cellTemplate: function(container, options) {
                                var progress = options.value || 0;
                                var task = options.data;

                                var displayText = "";
                                if (task.TargetKPI > 0) {
                                    displayText = (task.ActualKPI || 0) + "/" + task.TargetKPI;
                                } else if (task.TotalSubtasks > 0) {
                                    displayText = (task.CompletedSubtasks || 0) + "/" + task.TotalSubtasks;
                                }

                                var div = $("<div>").addClass("progress-cell");

                                if (displayText) {
                                    $("<div>").addClass("progress-info")
                                        .text(displayText)
                                        .appendTo(div);
                                }

                                var barContainer = $("<div>").addClass("progress-bar-container");
                                $("<div>").addClass("progress-bar-fill")
                                    .css("width", Math.min(progress, 100) + "%")
                                    .appendTo(barContainer);

                                barContainer.appendTo(div);

                                $("<div>").addClass("progress-text")
                                    .text(progress + "%")
                                    .appendTo(div);

                                div.appendTo(container);
                            }
                        },
                        {
                            dataField: "StatusCode",
                            caption: "Trạng thái",
                            width: 140,
                            alignment: "center",
                            allowHeaderFiltering: true,
                            headerFilter: {
                                dataSource: [
                                    { value: 1, text: "Chưa làm" },
                                    { value: 2, text: "Đang làm" },
                                    { value: 3, text: "Hoàn thành" }
                                ]
                            },
         cellTemplate: function(container, options) {
                                var status = options.value || 1;
                                var statusClass = "sts-" + status;
                                var statusText = status === 1 ? "Chưa làm" :
                                                 status === 2 ? "Đang làm" : "Hoàn thành";

                                $("<span>").addClass("badge-sts " + statusClass)
                                    .text(statusText)
                                    .appendTo(container);
                            }
                        },
                        {
                            dataField: "MyStartDate",
                            caption: "Ngày bắt đầu",
                            width: 130,
                            dataType: "date",
                            format: "dd/MM/yyyy",
                            alignment: "center"
                        },
                        {
                            dataField: "DueDate",
                            caption: "Hạn hoàn thành",
                            width: 140,
                            dataType: "date",
                            format: "dd/MM/yyyy",
                            alignment: "center",
                            cellTemplate: function(container, options) {
                                var task = options.data;
                                var dateStr = formatSimpleDate(options.value);

                                var dateDiv = $("<div>").addClass("date-cell");

                                if (task.IsOverdue === 1) {
                                    dateDiv.addClass("overdue");
                                    $("<i>").addClass("bi bi-exclamation-triangle-fill")
                                        .appendTo(dateDiv);
                                }

                                $("<span>").text(dateStr || "-").appendTo(dateDiv);

                                dateDiv.appendTo(container);
                            }
                        },
                        {
                            caption: "Thao tác",
                            width: 120,
                            alignment: "center",
                            allowExporting: false,
                            allowSorting: false,
                            allowFiltering: false,
                            allowGrouping: false,
                            cellTemplate: function(container, options) {
                                $("<button>").addClass("action-btn")
                                    .html(`<i class="bi bi-box-arrow-up-right"></i> Chi tiết`)
                                    .attr("title", "Xem chi tiết công việc")
                                    .on("click", function(e) {
                                        e.stopPropagation();
                                        openTaskDetail(options.data.TaskID);
                                    })
                                    .appendTo(container);
                            }
                        }
                    ],

                    // Summary
                    summary: {
                        totalItems: [
                            {
                                column: "TaskID",
                                summaryType: "count",
                                displayFormat: "Tổng: {0} công việc"
                            },
                            {
                                column: "ProgressPct",
                                summaryType: "avg",
                                valueFormat: "fixedPoint",
                                precision: 1,
                                displayFormat: "TB: {0}%"
                          }
                        ],
                        groupItems: [
                            {
                                column: "TaskID",
                                summaryType: "count",
                                displayFormat: "{0} việc"
                            },
                            {
                                column: "ProgressPct",
                                summaryType: "avg",
                                valueFormat: "fixedPoint",
                                precision: 1,
                                displayFormat: "TB: {0}%"
                            }
                        ]
                    },

                    // Master-detail disabled (only 2 levels: parent-child)
                    masterDetail: {
                        enabled: false
                    },

                    // Events
                    onRowPrepared: function(e) {
                        if (e.rowType === "data") {
          if (e.data.IsOverdue === 1) {
                                e.rowElement.css("background-color", "rgba(229, 57, 53, 0.03)");
                            }

                            if (e.data.StatusCode === 3) {
                                e.rowElement.css("opacity", "0.7");
                            }
                        }
                    },

                    onCellPrepared: function(e) {
                        if (e.rowType === "data" && e.column.command === "drag") {
                            e.cellElement.css({
                                cursor: "grab",
                                userSelect: "none"
                            });
                        }
                    },

                    onContextMenuPreparing: function(e) {
                        if (e.row && e.row.rowType === "data") {
                            e.items = [
                                {
                                    text: "Xem chi tiết",
                                    icon: "info",
                                    onItemClick: function() {
                                        openTaskDetail(e.row.data.TaskID);
                                    }
                                },
                                {
                                    text: "Chỉnh sửa",
                                    icon: "edit",
                                    onItemClick: function() {
                                        console.log("Edit task:", e.row.data.TaskID);
                                    }
                                },
                                { beginGroup: true },
                                {
                                    text: "Đánh dấu hoàn thành",
                                    icon: "check",
                                    disabled: e.row.data.StatusCode === 3,
                                    onItemClick: function() {
                                        updateTaskStatus(e.row.data.TaskID, 3);
                                    }
                                },
                                {
                                    text: "Đánh dấu đang làm",
                                    icon: "runner",
                                    disabled: e.row.data.StatusCode === 2,
                                    onItemClick: function() {
                                        updateTaskStatus(e.row.data.TaskID, 2);
                                    }
                                },
                                { beginGroup: true },
                                {
                                    text: "Xóa",
                                    icon: "trash",
                                    onItemClick: function() {
                                        if (confirm("Bạn có chắc chắn muốn xóa công việc này?")) {
                                            deleteTask(e.row.data.TaskID);
                                        }
                                    }
                                }
                            ];
                        }
                    },

                    onRowClick: function(e) {
                        if (e.rowType === "data" && e.column && e.column.type !== "drag" && e.column.caption !== "Thao tác") {
                            var hasSubtasks = e.data.HasSubtasks || (e.data.TotalSubtasks && e.data.TotalSubtasks > 0);
                            if (hasSubtasks) {
                                if (e.component.isRowExpanded(e.key)) {
                                    e.component.collapseRow(e.key);
                                } else {
                                    e.component.expandRow(e.key);
                                }
                            }
                        }
                    },

                    onRowDblClick: function(e) {
                   if (e.rowType === "data") {
                            openTaskDetail(e.data.TaskID);
                        }
                    },

                    onToolbarPreparing: function(e) {
                        e.toolbarOptions.items.unshift(
                            {
                                location: "after",
                                widget: "dxButton",
                                options: {
                                    icon: "refresh",
                                    hint: "Tải lại dữ liệu",
                                    onClick: function() {
                                        loadTasks();
                                    }
                                }
                            }
                        );
                    }
                }).dxDataGrid("instance");
            }

            function loadTasks() {
                AjaxHPAParadise({
                    data: {
                        name: "sp_Task_GetMyTasks",
                        param: ["LoginID", LoginID]
                    },
                    success: function(response) {
                        try {
                            var res = JSON.parse(response);
                            // Chỉ có 1 result set duy nhất
                            allTasks = res.data[0] || [];

                            taskGridInstance.option("dataSource", allTasks);

                            // Tự động group theo GroupID để hiển thị parent-child
                            taskGridInstance.columnOption("GroupID", { groupIndex: 0 });

                            updateStatistics();

                            taskGridInstance.endCustomLoading();
                        } catch(e) {
                            console.error("Error loading tasks:", e);
                            uiManager.showAlert({
                                type: "error",
                                message: "Lỗi khi tải dữ liệu công việc"
                            });
                        }
                    },
                    error: function(error) {
                        console.error("Ajax error:", error);
                        uiManager.showAlert({
                            type: "error",
                            message: "Không thể kết nối đến server"
                        });
                    }
                });
            }

            function loadSubtasks(parentTaskID) {
                return new Promise(function(resolve, reject) {
                    AjaxHPAParadise({
                        data: {
                            name: "sp_Task_GetTaskRelations",
                            param: ["ParentTaskID", parentTaskID]
                     },
                        success: function(res) {
                            try {
                                var data = JSON.parse(res).data[0] || [];
                                resolve(data);
                            } catch(e) {
                                reject(e);
                            }
                        },
                        error: function(error) {
                            reject(error);
                        }
                    });
                });
            }

            function saveTaskOrder(task, newIndex) {
                if (!task.HistoryID) {
                    console.warn("No HistoryID found for task:", task);
                    return;
                }

                AjaxHPAParadise({
                    data: {
                        name: "sp_Common_SaveDataTable",
                        param: [
                            "LoginID", LoginID,
                            "LanguageID", "VN",
                            "TableName", "tblTask_AssignHistory",
                            "ColumnName", "SortOrder",
                            "IDColumnName", "HistoryID",
                            "ColumnValue", newIndex + 1,
                            "ID_Value", task.HistoryID
                        ]
                    },
                    success: function(res) {
                        console.log("Task order saved successfully");
                        uiManager.showAlert({
                            type: "success",
                            message: "Đã lưu thứ tự mới"
                        });
                    },
                    error: function(error) {
                        console.error("Error saving task order:", error);
                        uiManager.showAlert({
                            type: "error",
                            message: "Không thể lưu thứ tự"
                        });
                    }
                });
            }

            function updateTaskStatus(taskID, newStatus) {
                AjaxHPAParadise({
                    data: {
                        name: "sp_Task_UpdateStatus",
                        param: [
                            "TaskID", taskID,
                            "LoginID", LoginID,
                            "NewStatus", newStatus
                        ]
                    },
                    success: function() {
                        uiManager.showAlert({
                            type: "success",
                            message: "Đã cập nhật trạng thái"
                        });
                        loadTasks();
                    },
                    error: function() {
                        uiManager.showAlert({
                            type: "error",
                            message: "Không thể cập nhật trạng thái"
                        });
                    }
                });
            }

            function deleteTask(taskID) {
                AjaxHPAParadise({
                    data: {
                        name: "sp_Task_Delete",
                        param: ["TaskID", taskID, "LoginID", LoginID]
                    },
                    success: function() {
                        uiManager.showAlert({
                            type: "success",
                            message: "Đã xóa công việc"
                        });
                        loadTasks();
                    },
                    error: function() {
                        uiManager.showAlert({
                            type: "error",
                            message: "Không thể xóa công việc"
                        });
                    }
                });
            }

            function updateStatistics() {
                // Chỉ tính task cha (ParentTaskID === null) trong thống kê, không tính task con
                var parentTasks = allTasks.filter(function(t) { return t.ParentTaskID === null; });

                var todoCount = parentTasks.filter(function(t) { return t.StatusCode == 1; }).length;
                var doingCount = parentTasks.filter(function(t) { return t.StatusCode == 2; }).length;
                var doneCount = parentTasks.filter(function(t) { return t.StatusCode == 3; }).length;
                var overdueCount = parentTasks.filter(function(t) { return t.IsOverdue == 1; }).length;

                $("#stat-todo").text(todoCount);
                $("#stat-doing").text(doingCount);
                $("#stat-done").text(doneCount);
                $("#stat-overdue").text(overdueCount);
            }

            function openTaskDetail(taskID) {
                var task = allTasks.find(function(t) { return t.TaskID === taskID; });

                if (!task) {
                    uiManager.showAlert({
                        type: "error",
                        message: "Không tìm thấy công việc"
                    });
                    return;
                }

                try {
                    window.sp_Task_TaskDetail_html = window.sp_Task_TaskDetail_html || {};
                    window.sp_Task_TaskDetail_html.TaskID = taskID;
                    window.sp_Task_TaskDetail_html.TaskData = task;
                } catch (e) {
                    console.warn("Could not set task detail data:", e);
                }

                if (["Android", "iOS"].includes(getMobileOperatingSystem())) {
                    OpenFormParamMobile("sp_Task_TaskDetail", {
                        TaskID: taskID,
                        LoginID: LoginID,
                        LanguageID: LanguageID
                    });
                } else {
                    openFormParam("sp_Task_TaskDetail", {
                        TaskID: taskID,
                        LoginID: LoginID,
                        LanguageID: LanguageID
                    });
                }
            }

            // ===== NEW FUNCTIONS - KANBAN & TIMELINE =====

            function escapeHtml(str) {
                if (str === null || str === undefined) return "";
                return String(str)
                    .replace(/&/g, "&amp;")
                    .replace(/</g, "&lt;")
                    .replace(/>/g, "&gt;")
                    .replace(/""/g, "&quot;")
                    .replace(/"/g, "&#39;");
            }

            function buildTimelineHtml(entries) {
                if (!entries || entries.length === 0) return `<div class="text-muted">Không có lịch</div>`;
                var norm = (entries||[]).map(function(e){
                    if (!e) return null;
                    if (e.start && e.end) return { start: new Date(e.start), end: new Date(e.end), label: e.label||e.EmployeeName||"" };
                    if (e.dt) return { start: new Date(e.dt), end: new Date(e.dt), label: e.label||"" };
                    if (typeof e === "string" || typeof e === "number") { var d=new Date(e); return { start:d, end:d, label: "" }; }
                    return null;
                }).filter(Boolean);

                if (norm.length === 0) return `<div class="text-muted">Không có lịch</div>`;

                var minStart = norm.reduce((min,e)=> e.start < min ? e.start : min, norm[0].start);
                var maxEnd = norm.reduce((max,e)=> e.end > max ? e.end : max, norm[0].end);
                var rangeMs = Math.max(1, maxEnd - minStart);

                var html = `<div class="timeline-table" style="overflow:auto;">`;
                html += `<table style="width:100%;border-collapse:collapse;font-size:13px;">
                            <thead><tr><th style="text-align:left;padding:6px 8px">Người</th><th style="padding:6px 8px">Bắt đầu</th><th style="padding:6px 8px">Kết thúc</th><th style="padding:6px 8px">Thời gian</th><th style="padding:6px 8px">Lịch</th></tr></thead><tbody>`;

                norm.forEach(function(en){
                    var s = en.start; var e = en.end;
                    if (!s || isNaN(s.getTime())) s = minStart;
                    if (!e || isNaN(e.getTime())) e = s;
                    var durDays = Math.max(1, Math.ceil((e - s)/(24*3600*1000)) + 1);
                    var startTxt = ("0"+s.getDate()).slice(-2) + "/" + ("0"+(s.getMonth()+1)).slice(-2);
                    var endTxt = ("0"+e.getDate()).slice(-2) + "/" + ("0"+(e.getMonth()+1)).slice(-2);

                    var leftPct = ((s - minStart) / rangeMs) * 100;
                    var widthPct = ((e - s) / rangeMs) * 100;
                    if (widthPct < 1) widthPct = 1;

                    var safeLabel = escapeHtml(en.label || "");

                    html += `<tr style="border-bottom:1px solid var(--bg-lighter)">`;
                    html += `<td style="padding:6px 8px;vertical-align:middle">${safeLabel}</td>`;
                    html += `<td style="padding:6px 8px;vertical-align:middle">${startTxt}</td>`;
                    html += `<td style="padding:6px 8px;vertical-align:middle">${endTxt}</td>`;
                    html += `<td style="padding:6px 8px;vertical-align:middle">${durDays} ngày</td>`;
                    html += `<td style="padding:6px 8px;vertical-align:middle;min-width:200px;max-width:520px;">
                                <div style="position:relative;height:28px;background:var(--bg-lighter);border-radius:6px;overflow:hidden;">
                                    <div style="position:absolute;left:${leftPct}%;width:${widthPct}%;top:3px;bottom:3px;background:linear-gradient(90deg,var(--task-primary),var(--task-primary-hover));border-radius:6px;display:flex;align-items:center;padding:2px 8px;color:#fff;font-weight:600;">${safeLabel} (${durDays}d)</div>
                                </div>
                              </td>`;
                    html += `</tr>`;
                });

                html += `</tbody></table></div>`;
                return html;
            }

            function populateTimelineForTask(t) {
                try {
                    var timelineContainerId = `timeline-container-${t.TaskID}`;
                    var $el = $(`#${timelineContainerId}`);
                    if (!$el.length) return;

                    var raw = t.Schedule || t.AssignHistory || t.ScheduleEntries || t.Timeline || [];
                    try {
                        if (typeof raw === "string" && raw.trim() !== "") {
                            try { raw = JSON.parse(raw); } catch(e) {
                                raw = raw.split(/[,;|]/).map(s=>({ Date: s.trim(), Label: "" }));
                            }
                        }
                    } catch(e) { raw = []; }
                    if (!Array.isArray(raw)) raw = [raw];

                    var entries = [];
                    raw.forEach(function(e){
                        if (!e) return;
                        if (typeof e === "string" || typeof e === "number") { entries.push({ dt: new Date(e), label: ""}); return; }
                        var d = e.ScheduleDate || e.AssignDate || e.Date || e.StartDate || e.DateTime || e.ActionDate || e.MyStartDate || e.DueDate || e.DateString || e.DateTimeString || null;
                        if (!d && e.date) d = e.date;
                        var label = e.EmployeeName || e.FullName || e.UserName || e.Label || e.Description || e.Action || e.Note || e.Title || "";
                        if (d) entries.push({ dt: new Date(d), label: label });
                    });

                    if (entries.length === 0) {
                        if (t.MyStartDate) entries.push({ dt: new Date(t.MyStartDate), label: "Start" });
                        if (t.DueDate) entries.push({ dt: new Date(t.DueDate), label: "Due" });
                    }

                    $el.html(buildTimelineHtml(entries));
                } catch(e) {}
            }

            function renderKanbanView(data) {
                // Chỉ lấy task cha (ParentTaskID === null) để hiển thị trong Kanban
                var allVisibleTasks = data.filter(function(t) { return t.ParentTaskID === null; });

                var todoTasks = allVisibleTasks.filter(function(t) { return t.StatusCode == 1; });
                var doingTasks = allVisibleTasks.filter(function(t) { return t.StatusCode == 2; });
                var doneTasks = allVisibleTasks.filter(function(t) { return t.StatusCode == 3; });

                $("#count-todo").text(todoTasks.length);
                $("#count-doing").text(doingTasks.length);
                $("#count-done").text(doneTasks.length);

                renderTaskCards("#tasks-todo", todoTasks);
                renderTaskCards("#tasks-doing", doingTasks);
                renderTaskCards("#tasks-done", doneTasks);
            }

            function renderTaskCards(container, tasks) {
                if(tasks.length === 0) {
                    $(container).html(`<div class="empty-state"><i class="bi bi-inbox"></i><p>Không có công việc</p></div>`);
                    return;
                }
                var html = tasks.map(function(t) {
                    var prioClass = "prio-" + (t.AssignPriority || 3);
                    var startStr = formatSimpleDate(t.MyStartDate);
                    var dueStr = formatSimpleDate(t.DueDate);
                    var dateRange = (startStr || dueStr) ? (startStr + " - " + dueStr) : "";
                    var dateClass = t.IsOverdue ? "overdue" : "";
                    var kpiDisplayText = "";
                    if (t.TargetKPI > 0) {
                        kpiDisplayText = `${t.ActualKPI} / ${t.TargetKPI} ${t.Unit || ""}`;
                    } else if (t.TotalSubtasks > 0) {
                        kpiDisplayText = `${t.CompletedSubtasks || 0} / ${t.TotalSubtasks} task`;
                    } else {
                        kpiDisplayText = "Chưa có tiến độ";
                    }
                    return `
                    <div class="cu-row task-row" data-recordid="${t.TaskID}" data-historyid="${t.HistoryID || ""}">
                        <div class="row-check">
                            <i class="bi bi-flag-fill priority-icon ${prioClass}"></i>
                        </div>
                        <div class="row-main">
                            <div class="task-title" title="${escapeHtml(t.TaskName)}">${t.TaskName}</div>
                            <div class="task-sub">
                                ${t.CommentCount > 0 ? `<span><i class="bi bi-chat-dots"></i> ${t.CommentCount}</span>` : ""}
                                <span class="text-muted">#${t.TaskID}</span>
                            </div>
                        </div>
                        <div class="row-kpi">
                            <div class="kpi-text">
                                <span>${kpiDisplayText}</span>
                            <strong style="color: var(--task-primary)">${t.ProgressPct}%</strong>
                            </div>
                            <div class="kpi-bar-bg">
                                <div class="kpi-bar-fill" style="width: ${Math.min(t.ProgressPct, 100)}%"></div>
                            </div>
                        </div>
                        <div class="row-meta">
                            ${dateRange ? `<span class="date-range ${dateClass}">${dateRange}</span>` : ""}
                            ${t.IsOverdue ? `<small class="text-danger mt-1 fw-bold"><i class="bi bi-exclamation-triangle-fill"></i> Quá hạn</small>` : ""}
                        </div>
                    </div>`;
          }).join("");
                $(container).html(html);
            }

            function attachEventHandlers() {
                $("#btnRefresh").on("click", function() {
                    if (currentView === "grid") {
                        taskGridInstance.beginCustomLoading();
                    }
                    loadTasks();
                });

                $("#btnAssign").on("click", function() {
                    if ($("#mdlAssign").length) {
                        $("#mdlAssign").modal("show");
                    }
                });

                $("#viewGrid").on("click", function() {
                    $(".view-btn").removeClass("active");
                    $(this).addClass("active");
                    currentView = "grid";
                    $("#kanban-view").hide();
                    $("#taskGrid").show();
                });

                $("#viewKanban").on("click", function() {
                    $(".view-btn").removeClass("active");
                    $(this).addClass("active");
                    currentView = "kanban";
                    $("#taskGrid").hide();
                    if (!$("#kanban-view").length) {
                        uiManager.showAlert({
                            type: "info",
                            message: "Chức năng Kanban chưa được khởi tạo"
                        });
                    } else {
                        $("#kanban-view").show();
                        renderKanbanView(allTasks);
                    }
                });
            }

            function formatSimpleDate(dateString) {
                if(!dateString) return "";
                var d = new Date(dateString);
                if (isNaN(d.getTime())) return "";
                var day = ("0" + d.getDate()).slice(-2);
                var month = ("0" + (d.getMonth() + 1)).slice(-2);
                var year = d.getFullYear();
                return day + "/" + month + "/" + year;
            }

            function getInitials(fullName) {
                if (!fullName) return "??";
                var name = String(fullName).replace(/\s+/g, " ").trim();
                if (!name) return "??";

                var parts = name.split(" ").filter(function(p) { return p.length > 0; });

                if (parts.length === 0) {
                    return "??";
                } else if (parts.length === 1) {
                    return parts[0].slice(0, 2).toUpperCase();
                } else {
                    var first = parts[0].charAt(0) || "";
                    var last = parts[parts.length - 1].charAt(0) || "";
                    return (first + last).toUpperCase();
                }
            }

            window.taskGridInstance = taskGridInstance;
        })();
    </script>
    ';
    SELECT @html AS html;
END
GO


EXEC sp_GenerateHTMLScript 'sp_Task_MyWork_html'