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
        --task-primary: #2e7d32;
        --task-primary-light: #1c975eff;
        --task-primary-hover: #1c975e;
        --sts-todo: #dfe1e6;
        --sts-doing: #deebff;
        --sts-done: #e3fcef;
        --sts-todo-text: #42526e;
        --sts-doing-text: #0747a6;
        --sts-done-text: #006644;
        --danger-color: #e53935;
        --warning-color: #fb8c00;
        --success-color: #00c875;
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
        box-shadow: 0 1px 4px rgba(0, 0, 0, 0.04);
        border: 1px solid rgba(0, 0, 0, 0.04);
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
        background: linear-gradient(
            90deg,
            var(--task-primary),
            var(--task-primary-hover)
        );
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
        background: linear-gradient(
            90deg,
            transparent,
            rgba(255, 255, 255, 0.3),
            transparent
        );
        animation: shimmer 2s infinite;
    }
    @keyframes shimmer {
        0% {
            transform: translateX(-100%);
        }
        100% {
            transform: translateX(100%);
        }
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
        box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
        transition: all var(--transition-base);
    }
    #sp_Task_MyWork_html .employee-avatar:first-child {
        margin-left: 0;
    }
    #sp_Task_MyWork_html .employee-avatar:hover {
        transform: translateY(-2px) scale(1.1);
        box-shadow: 0 4px 8px rgba(0, 0, 0, 0.15);
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
        0%,
        100% {
            opacity: 1;
        }
        50% {
            opacity: 0.5;
        }
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
                    <i class="bi bi-table"></i> Grid </button>
                <button class="view-btn" id="viewKanban">
                    <i class="bi bi-kanban"></i> Kanban </button>
            </div>
            <button class="btn-assign" id="btnAssign">
                <i class="bi bi-plus-circle-fill"></i> Giao việc </button>
            <button class="btn-refresh" id="btnRefresh">
                <i class="bi bi-arrow-clockwise"></i> Tải lại </button>
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
                        <i class="bi bi-circle-fill" style="font-size:10px;color:#9ca3af;"></i> Chưa làm
                    </div>
                    <div class="column-count" id="count-todo">0</div>
                </div>
                <div id="tasks-todo"></div>
            </div>
            <div class="kanban-column">
                <div class="column-header">
                    <div class="column-title">
                        <i class="bi bi-circle-fill" style="font-size:10px;color:#0747a6;"></i> Đang làm
                    </div>
                    <div class="column-count" id="count-doing">0</div>
                </div>
                <div id="tasks-doing"></div>
            </div>
            <div class="kanban-column">
                <div class="column-header">
                    <div class="column-title">
                        <i class="bi bi-circle-fill" style="font-size:10px;color:#006644;"></i> Hoàn thành
                    </div>
                    <div class="column-count" id="count-done">0</div>
                </div>
                <div id="tasks-done"></div>
            </div>
        </div>
    </div>
</div>
<script>
    (function() {
        "use strict";
        // =====================================================================
        // CONTROL SYSTEM - Lấy từ sptblCommonControlType_Signed_Linh
        // =====================================================================

        // Global variables for controls
        let TaskNameControl, TaskNameKey;
        let AssignPriorityControl, AssignPriorityKey;
        let StatusCodeControl, StatusCodeKey;
        let AssignedToEmployeeIDsControl, AssignedToEmployeeIDsKey;
        let TagsControl, TagsKey;
        let MyStartDateControl, MyStartDateKey;
        let DueDateControl, DueDateKey;
        let ProgressPctControl, ProgressPctKey;

        // Action popup for text controls
        let actionPopupInstance = null;
        let currentField = null;
        let currentFieldId = null;
        let saveCallback = null;
        let cancelCallback = null;

        function initActionPopup() {
            if (actionPopupInstance) return actionPopupInstance;

            actionPopupInstance = $(`<div id="actionPopupGlobal">`).appendTo("body").dxPopup({
                width: "auto",
                height: "auto",
                showTitle: false,
                visible: false,
                dragEnabled: false,
                hideOnOutsideClick: false,
                showCloseButton: false,
                shading: false,
                position: {
                    at: "bottom right",
                    my: "top right",
                    collision: "fit flip",
                    offset: "0 4"
                },
                contentTemplate: function() {
                    return $(`<div class="d-flex" style="gap: .5rem; padding: 8px 12px;">`).append(
                        $("<div>").dxButton({
                            icon: "check",
                            hint: "Lưu",
                            stylingMode: "contained",
                            type: "success",
                            width: 28,
                            height: 28,
                            elementAttr: {
                                style: "border-radius: 6px !important;"
                            },
                            onClick: async function() {
                                if (saveCallback) await saveCallback();
                                actionPopupInstance.hide();
                            }
                        }),
                        $("<div>").dxButton({
                            icon: "close",
                            hint: "Hủy",
                            stylingMode: "outlined",
                            type: "normal",
                            width: 28,
                            height: 28,
                            elementAttr: {
                                style: "border-radius: 6px !important;"
                            },
                            onClick: function() {
                                if (cancelCallback) cancelCallback();
                                actionPopupInstance.hide();
                            }
                        })
                    );
                },
                onHiding: function() {
                    currentField = currentFieldId = saveCallback = cancelCallback = null;
                }
            }).dxPopup("instance");

            return actionPopupInstance;
        }

        function showActionPopup(target, fieldId, onSave, onCancel) {
            const popup = initActionPopup();
            if (currentFieldId && currentFieldId !== fieldId && cancelCallback) {
                cancelCallback();
            }
            saveCallback = onSave;
            cancelCallback = onCancel;
            currentField = target;
            currentFieldId = fieldId;
            popup.option("position.of", target);
            popup.show();
        }

        // =====================================================================
        // CONTROL: TaskName (hpaControlText - AutoSave với popup)
        // =====================================================================
        function loadUI_TaskName() {
            if ($("#TaskNameDiv_Container").length === 0) {
                $("<div>", {
                    id: "TaskNameDiv_Container"
                }).appendTo("body");
            }

            let TaskNameInstance, TaskNameOriginalValue, TaskNameIsEditing = false;

            const $container = $("#TaskNameDiv_Container");

            TaskNameInstance = $("<div>").appendTo($container).dxTextBox({
                value: TaskNameOriginalValue || "",
                width: "100%",
                inputAttr: {
                    class: "form-control form-control-sm",
                    style: "font-size: 14px; max-height: 100%;"
                },
                onFocusIn: function(e) {
                    if (TaskNameIsEditing) return;
                    TaskNameIsEditing = true;
                    TaskNameOriginalValue = TaskNameInstance.option("value");
                    $(e.element).find("input").css("border", "1px solid #1c975e");
                    showActionPopup($container, "TaskName",
                        async () => {
                                await saveValueTaskName();
                                exitEditTaskName();
                            },
                            () => exitEditTaskName(true)
                    );
                    setTimeout(() => {
                        $(document).on("click.editmodeTaskName", function(ev) {
                            const $t = $(ev.target);
                            if (!$t.closest($container).length &&
                                !$t.closest(".dx-popup-wrapper").length &&
                                !$t.closest(".dx-texteditor").length) {
                                exitEditTaskName(true);
                            }
                        });
                    }, 100);
                },
                onFocusOut: function(e) {
                    $(e.element).find("input").css("border", "");
                },
                onKeyDown: function(e) {
                    if (!TaskNameIsEditing) return;
                    if (e.event.key === "Enter") {
                        e.event.preventDefault();
                        saveValueTaskName().then(() => exitEditTaskName());
                    }
                    if (e.event.key === "Escape") {
                        e.event.preventDefault();
                        exitEditTaskName(true);
                    }
                }
            }).dxTextBox("instance");

            function exitEditTaskName(cancel = false) {
                if (!TaskNameIsEditing) return;
                TaskNameIsEditing = false;
                $(document).off("click.editmodeTaskName");
                if (cancel) {
                    TaskNameInstance.option("value", TaskNameOriginalValue);
                } else {
                    TaskNameOriginalValue = TaskNameInstance.option("value");
                }
            }

            async function saveValueTaskName() {
                const newVal = TaskNameInstance.option("value");
                if (newVal === TaskNameOriginalValue) return;
                try {
                    await saveFunction(
                        JSON.stringify([-99218308, ["TaskName"],
                            [newVal]
                        ]),
                        [
                            [TaskNameKey.TaskID], "TaskID"
                        ]
                    );
                    TaskNameOriginalValue = newVal;
                    uiManager.showAlert({
                        type: "success",
                        message: "Lưu thành công"
                    });
                } catch (err) {
                    uiManager.showAlert({
                        type: "error",
                        message: "Có lỗi xảy ra khi lưu"
                    });
                }
            }

            return {
                setValue: val => {
                    TaskNameOriginalValue = val;
                    if (TaskNameInstance) TaskNameInstance.option("value", val);
                },
                getValue: () => TaskNameInstance ? TaskNameInstance.option("value") : TaskNameOriginalValue
            };
        }

        // =====================================================================
        // CONTROL: AssignPriority (hpaControlSelectBox - AutoSave)
        // =====================================================================
        function loadUI_AssignPriority() {
            if ($("#AssignPriorityDiv_Container").length === 0) {
                $("<div>", {
                    id: "AssignPriorityDiv_Container"
                }).appendTo("body");
            }

            let AssignPriorityInstance, AssignPriorityOriginalValue = null;

            const $container = $("#AssignPriorityDiv_Container");

            // DataSource cho priority
            const priorityDataSource = [{
                    ID: 1,
                    Name: "Cao",
                    Text: "Cao"
                },
                {
                    ID: 2,
                    Name: "Trung bình",
                    Text: "Trung bình"
                },
                {
                    ID: 3,
                    Name: "Thấp",
                    Text: "Thấp"
                }
            ];

            const customStore = new DevExpress.data.CustomStore({
                key: "ID",
                byKey: function(key) {
                    const item = priorityDataSource.find(i => i.ID === key);
                    return $.Deferred().resolve(item || null).promise();
                },
                load: function(loadOptions) {
                    return priorityDataSource;
                }
            });

            AssignPriorityInstance = $("<div>").appendTo($container).dxSelectBox({
                dataSource: customStore,
                valueExpr: "ID",
                displayExpr: "Name",
                placeholder: "Chọn...",
                searchEnabled: false,
                showClearButton: true,
                stylingMode: "outlined",
                onValueChanged: async function(e) {
                    if (e.value !== AssignPriorityOriginalValue) {
                        await saveAssignPriorityValue(e.value);
                    }
                }
            }).dxSelectBox("instance");

            async function saveAssignPriorityValue(newValue) {
                if (newValue === AssignPriorityOriginalValue) return;

                try {
                    const dataJSON = JSON.stringify([-99218308, ["AssignPriority"],
                        [newValue || ""]
                    ]);
                    let idValues = [
                        [AssignPriorityKey.TaskID], "TaskID"
                    ];

                    await saveFunction(dataJSON, idValues);
                    AssignPriorityOriginalValue = newValue;

                    uiManager.showAlert({
                        type: "success",
                        message: "Lưu thành công"
                    });
                } catch (err) {
                    console.error("Save error:", err);
                    AssignPriorityInstance.option("value", AssignPriorityOriginalValue);
                    uiManager.showAlert({
                        type: "error",
                        message: "Có lỗi xảy ra khi lưu"
                    });
                }
            }

            return {
                setValue: function(val) {
                    AssignPriorityOriginalValue = val;
                    if (AssignPriorityInstance) {
                        AssignPriorityInstance.option("value", val);
                    }
                },
                getValue: function() {
                    return AssignPriorityInstance ? AssignPriorityInstance.option("value") : AssignPriorityOriginalValue;
                }
            };
        }

        // =====================================================================
        // CONTROL: StatusCode (hpaControlSelectBox - AutoSave)
        // =====================================================================
        function loadUI_StatusCode() {
            if ($("#StatusDiv_Container").length === 0) {
                $("<div>", {
                    id: "StatusDiv_Container"
                }).appendTo("body");
            }

            let StatusCodeInstance, StatusCodeOriginalValue = null;

            const $container = $("#StatusDiv_Container");

            // DataSource cho status
            const statusDataSource = [{
                    ID: 1,
                    Name: "Chưa làm",
                    Text: "Chưa làm"
                },
                {
                    ID: 2,
                    Name: "Đang làm",
                    Text: "Đang làm"
                },
                {
                    ID: 3,
                    Name: "Hoàn thành",
                    Text: "Hoàn thành"
                }
            ];

            const customStore = new DevExpress.data.CustomStore({
                key: "ID",
                byKey: function(key) {
                    const item = statusDataSource.find(i => i.ID === key);
                    return $.Deferred().resolve(item || null).promise();
                },
                load: function(loadOptions) {
                    return statusDataSource;
                }
            });

            StatusCodeInstance = $("<div>").appendTo($container).dxSelectBox({
                dataSource: customStore,
                valueExpr: "ID",
                displayExpr: "Name",
                placeholder: "Chọn...",
                searchEnabled: false,
                showClearButton: true,
                stylingMode: "outlined",
                onValueChanged: async function(e) {
                    if (e.value !== StatusCodeOriginalValue) {
                        await saveStatusCodeValue(e.value);
                    }
                }
            }).dxSelectBox("instance");

            async function saveStatusCodeValue(newValue) {
                if (newValue === StatusCodeOriginalValue) return;

                try {
                    const dataJSON = JSON.stringify([-99218308, ["StatusCode"],
                        [newValue || ""]
                    ]);
                    let idValues = [
                        [StatusCodeKey.TaskID], "TaskID"
                    ];

                    await saveFunction(dataJSON, idValues);
                    StatusCodeOriginalValue = newValue;

                    uiManager.showAlert({
                        type: "success",
                        message: "Lưu thành công"
                    });

                    // Reload grid to update statistics
                    loadTasks();
                } catch (err) {
                    console.error("Save error:", err);
                    StatusCodeInstance.option("value", StatusCodeOriginalValue);
                    uiManager.showAlert({
                        type: "error",
                        message: "Có lỗi xảy ra khi lưu"
                    });
                }
            }

            return {
                setValue: function(val) {
                    StatusCodeOriginalValue = val;
                    if (StatusCodeInstance) {
                        StatusCodeInstance.option("value", val);
                    }
                },
                getValue: function() {
                    return StatusCodeInstance ? StatusCodeInstance.option("value") : StatusCodeOriginalValue;
                }
            };
        }

        // =====================================================================
        // CONTROL: AssignedToEmployeeIDs (hpaControlSelectEmployee)
        // =====================================================================
        function loadUI_EmployeeID() {
            if ($("#EmployeeIDDiv_Container").length === 0) {
                $("<div>", {
                    id: "EmployeeIDDiv_Container"
                }).appendTo("body");
            }

            let EmployeeIDInstance;
            let EmployeeIDSelectedIds = [];
            let EmployeeIDSelectedIdsOriginal = [];
            const EmployeeID_MAX_VISIBLE = 3;
            let EmployeeIDAvatarCache = {};

            const $container = $("#EmployeeIDDiv_Container");

            // Helper functions
            function getInitials(name) {
                if (!name) return "??";
                const words = name.trim().split(/\s+/);
                if (words.length >= 2) {
                    return (words[0][0] + words[words.length - 1][0]).toUpperCase();
                }
                return name.substring(0, 2).toUpperCase();
            }

            function getColorForId(id) {
                const colors = [{
                        bg: "#e3f2fd",
                        text: "#1976d2"
                    },
                    {
                        bg: "#f3e5f5",
                        text: "#7b1fa2"
                    },
                    {
                        bg: "#e8f5e9",
                        text: "#388e3c"
                    },
                    {
                        bg: "#fff3e0",
                        text: "#f57c00"
                    },
                    {
                        bg: "#fce4ec",
                        text: "#c2185b"
                    }
                ];
                return colors[id % colors.length];
            }

            // Render display box (simplified - no images for now)
            function renderDisplayBox() {
                $container.empty();
                const $wrapper = $("<div>").css({
                    border: "1px solid #dee2e6",
                    borderRadius: "4px",
                    padding: "8px 12px",
                    backgroundColor: "#fff",
                    cursor: "pointer",
                    minHeight: "42px",
                    display: "flex",
                    alignItems: "center"
                });

                if (EmployeeIDSelectedIds.length === 0) {
                    $wrapper.append(
                        $("<span>").addClass("text-muted").html(
                            "<i class=\"bi bi-person-plus me-1\"></i>Chọn nhân viên..."
                        )
                    );
                } else {
                    const $avatarGroup = $("<div>").css({
                        display: "flex",
                        alignItems: "center"
                    });

                    const displayIds = EmployeeIDSelectedIds.slice(0, EmployeeID_MAX_VISIBLE);

                    // Note: EmployeeDataSource should be loaded globally
                    displayIds.forEach((id, index) => {
                        const item = window.EmployeeDataSource ? window.EmployeeDataSource.find(e => e.ID === id) : null;
                        if (!item) return;

                        const initials = getInitials(item.Name || item.FullName || "");
                        const color = getColorForId(item.ID);

                        const $chip = $("<div>").css({
                            display: "inline-flex",
                            alignItems: "center",
                            justifyContent: "center",
                            width: "32px",
                            height: "32px",
                            borderRadius: "50%",
                            border: "2px solid #fff",
                            boxShadow: "0 2px 4px rgba(0,0,0,0.1)",
                            marginLeft: index === 0 ? "0" : "-8px",
                            zIndex: EmployeeID_MAX_VISIBLE - index,
                            transition: "transform 0.2s ease",
                            background: color.bg,
                            color: color.text,
                            fontWeight: "600",
                            fontSize: "12px"
                        }).text(initials).attr("title", item.Name || item.FullName || "");

                        $chip.hover(
                            function() {
                                $(this).css("transform", "translateY(-2px) scale(1.05)");
                            },
                            function() {
                                $(this).css("transform", "translateY(0) scale(1)");
                            }
                        );

                        $avatarGroup.append($chip);
                    });

                    if (EmployeeIDSelectedIds.length > EmployeeID_MAX_VISIBLE) {
                        const remaining = EmployeeIDSelectedIds.length - EmployeeID_MAX_VISIBLE;
                        const $badge = $("<div>").css({
                            display: "inline-flex",
                            alignItems: "center",
                            justifyContent: "center",
                            width: "32px",
                            height: "32px",
                            borderRadius: "50%",
                            border: "2px solid #fff",
                            background: "#6c757d",
                            color: "#fff",
                            fontWeight: "600",
                            fontSize: "12px",
                            boxShadow: "0 2px 4px rgba(0,0,0,0.1)",
                            marginLeft: "-8px",
                            zIndex: "0"
                        }).text(`+${remaining}`).attr("title", `Còn ${remaining} người nữa`);

                        $avatarGroup.append($badge);
                    }

                    $wrapper.append($avatarGroup);
                }

                $container.append($wrapper);
                $wrapper.off("click").on("click", function() {
                    popup.show();
                });
            }

            const uniqueId = "EmployeeID_" + Date.now();
            const popup = $("<div>").attr("id", uniqueId + "_popup").appendTo($container).dxPopup({
                width: 750,
                height: 600,
                showTitle: true,
                title: "Chọn nhân viên",
                dragEnabled: true,
                closeOnOutsideClick: true,
                showCloseButton: true,
                toolbarItems: [{
                    widget: "dxButton",
                    location: "after",
                    toolbar: "bottom",
                    options: {
                        text: "Xác nhận",
                        type: "success",
                        onClick: async function() {
                            try {
                                await saveEmployeeIDValue();
                                popup.hide();
                            } catch (err) {
                                console.error("Save error:", err);
                            }
                        }
                    }
                }],
                contentTemplate: function() {
                    return $("<div>").attr("id", uniqueId + "_grid");
                },
                onShown: function() {
                    const gridContainer = $(`#${uniqueId}_grid`);
                    gridContainer.dxDataGrid({
                        dataSource: window.EmployeeDataSource || [],
                        keyExpr: "ID",
                        selection: {
                            mode: "multiple",
                            showCheckBoxesMode: "always"
                        },
                        selectedRowKeys: EmployeeIDSelectedIds,
                        columns: [{
                                caption: "Ảnh",
                                width: 70,
                                alignment: "center",
                                cellTemplate: function(container, options) {
                                    const item = options.data;
                                    const initials = getInitials(item.Name || item.FullName || "");
                                    const color = getColorForId(item.ID);

                                    container.append(
                                        $("<div>").addClass("d-flex align-items-center justify-content-center border").css({
                                            width: "40px",
                                            height: "40px",
                                            borderRadius: "50%",
                                            background: color.bg,
                                            color: color.text,
                                            fontWeight: 600,
                                            fontSize: "14px",
                                            boxShadow: "0 2px 4px rgba(0,0,0,0.1)"
                                        }).text(initials)
                                    );
                                }
                            },
                            {
                                dataField: "Name",
                                caption: "Họ tên",
                                width: 200,
                                cellTemplate: function(container, options) {
                                    const item = options.data;
                                    container.append(
                                        $("<div>").append(
                                            $("<div>").addClass("fw-semibold").text(item.Name || item.FullName || ""),
                                            $("<div>").addClass("small text-muted").text(item.Position || "")
                                        )
                                    );
                                }
                            },
                            {
                                dataField: "Email",
                                caption: "Email",
                                width: 200
                            }
                        ],
                        showBorders: true,
                        showRowLines: true,
                        rowAlternationEnabled: true,
                        hoverStateEnabled: true,
                        searchPanel: {
                            visible: true,
                            placeholder: "Tìm kiếm..."
                        },
                        paging: {
                            pageSize: 10
                        },
                        onSelectionChanged: function(e) {
                            EmployeeIDSelectedIds = e.selectedRowKeys || [];
                        }
                    });
                },
                onHidden: function() {
                    renderDisplayBox();
                }
            }).dxPopup("instance");

            async function saveEmployeeIDValue() {
                const originalStr = EmployeeIDSelectedIdsOriginal.slice().sort().join(",");
                const currentStr = EmployeeIDSelectedIds.slice().sort().join(",");

                if (originalStr === currentStr) return;

                try {
                    const dataJSON = JSON.stringify([-99218308, ["AssignedToEmployeeIDs"],
                        [EmployeeIDSelectedIds.join(",")]
                    ]);
                    const idValues = [
                        [AssignedToEmployeeIDsKey.TaskID], "TaskID"
                    ];

                    await saveFunction(dataJSON, idValues);
                    EmployeeIDSelectedIdsOriginal = [...EmployeeIDSelectedIds];

                    uiManager.showAlert({
                        type: "success",
                        message: "Lưu thành công"
                    });

                    // Reload to update display
                    loadTasks();
                } catch (err) {
                    console.error("Save error:", err);
                    uiManager.showAlert({
                        type: "error",
                        message: "Có lỗi xảy ra khi lưu"
                    });
                    throw err;
                }
            }

            EmployeeIDInstance = {
                renderDisplay: renderDisplayBox,
                popup: popup
            };
            renderDisplayBox();

            return {
                setValue: function(val) {
                    if (typeof val === "string" && val.trim() !== "") {
                        EmployeeIDSelectedIds = val.split(",").map(v => {
                            const num = parseInt(v);
                            return isNaN(num) ? v : num;
                        });
                    } else if (Array.isArray(val)) {
                        EmployeeIDSelectedIds = val;
                    } else {
                        EmployeeIDSelectedIds = [];
                    }
                    EmployeeIDSelectedIdsOriginal = [...EmployeeIDSelectedIds];
                    if (EmployeeIDInstance) {
                        EmployeeIDInstance.renderDisplay();
                    }
                },
                getValue: function() {
                    return EmployeeIDSelectedIds;
                }
            };
        }

        // =====================================================================
        // CONTROL: Tags (hpaControlTagBox - AutoSave)
        // =====================================================================
        function loadUI_Tags() {
            if ($("#TagsDiv_Container").length === 0) {
                $("<div>", {
                    id: "TagsDiv_Container"
                }).appendTo("body");
            }
            let TagsInstance, TagsOriginalValue = [];
            const $container = $("#TagsDiv_Container");

            // Dữ liệu mẫu hoặc từ window.TagsDataSource
            const tagsDataSource = window.TagsDataSource || [{
                    ID: 1,
                    Name: "Khẩn cấp",
                    Icon: "exclamation-circle"
                },
                {
                    ID: 2,
                    Name: "Quan trọng",
                    Icon: "star"
                },
                {
                    ID: 3,
                    Name: "Backend",
                    Icon: "server"
                },
                {
                    ID: 4,
                    Name: "Frontend",
                    Icon: "display"
                },
                {
                    ID: 5,
                    Name: "Bug",
                    Icon: "bug"
                }
            ];

            const customStore = new DevExpress.data.CustomStore({
                key: "ID",
                load: function(loadOptions) {
                    const searchValue = loadOptions.searchValue || "";
                    let filteredData = tagsDataSource;
                    if (searchValue) {
                        const lower = searchValue.toLowerCase();
                        filteredData = tagsDataSource.filter(item =>
                            item.Name.toLowerCase().includes(lower)
                        );
                        // Không hỗ trợ "add new" trong grid → bỏ phần add_new để đơn giản
                    }
                    return filteredData;
                }
            });

            TagsInstance = $("<div>").appendTo($container).dxTagBox({
                dataSource: customStore,
                valueExpr: "ID",
                displayExpr: "Name",
                placeholder: "Chọn nhãn...",
                searchEnabled: true, // ✅ BẬT SEARCH
                showClearButton: true,
                showSelectionControls: true,
                applyValueMode: "useButtons",
                stylingMode: "outlined",
                multiline: false,
                searchMode: "contains",
                itemTemplate: function(data) {
                    return $("<div>").addClass("d-flex align-items-center gap-2").append(
                        $("<i>").addClass("bi bi-" + (data.Icon || "tag")).css("color", "#0d6efd"),
                        $("<span>").text(data.Name)
                    );
                },
                tagTemplate: function(data) {
                    return $("<div>").addClass("d-flex align-items-center gap-1").append(
                        $("<i>").addClass("bi bi-" + (data.Icon || "tag")).css("font-size", "10px"),
                        $("<span>").text(data.Name)
                    );
                },
                onValueChanged: async function(e) {
                    const values = e.value || [];
                    if (JSON.stringify(values.sort()) !== JSON.stringify(TagsOriginalValue.sort())) {
                        try {
                            const dataJSON = JSON.stringify([-99218308, ["Tags"],
                                [values.join(",")]
                            ]);
                            const idValues = [
                                [TagsKey.TaskID], "TaskID"
                            ];
                            await saveFunction(dataJSON, idValues);
                            TagsOriginalValue = values;
                            uiManager.showAlert({
                                type: "success",
                                message: "Lưu nhãn"
                            });
                        } catch (err) {
                            uiManager.showAlert({
                                type: "error",
                                message: "Lỗi lưu nhãn"
                            });
                        }
                    }
                }
            }).dxTagBox("instance");

            return {
                setValue: function(val) {
                    if (typeof val === "string") {
                        TagsOriginalValue = val ? val.split(",").map(v => parseInt(v) || v) : [];
                    } else if (Array.isArray(val)) {
                        TagsOriginalValue = val;
                    } else {
                        TagsOriginalValue = [];
                    }
                    if (TagsInstance) TagsInstance.option("value", TagsOriginalValue);
                },
                getValue: function() {
                    return TagsInstance ? TagsInstance.option("value") : TagsOriginalValue;
                }
            };
        }

        // =====================================================================
        // MAIN APPLICATION CODE
        // =====================================================================

        var allTasks = [];
        var taskGridInstance = null;
        var currentView = "grid";

        // Load employee data globally
        window.EmployeeDataSource = [];

        function loadEmployeeData() {
            AjaxHPAParadise({
                data: {
                    name: "sp_Employee_GetAll",
                    param: []
                },
                success: function(response) {
                    try {
                        var res = JSON.parse(response);
                        window.EmployeeDataSource = res.data[0] || [];
                    } catch (e) {
                        console.error("Error loading employee data:", e);
                    }
                },
                error: function(error) {
                    console.error("Ajax error loading employees:", error);
                }
            });
        }

        $(document).ready(function() {
            loadEmployeeData();
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

                // ===== ROW DRAGGING =====
                rowDragging: {
                    allowReordering: true,
                    showDragIcons: true,
                    dropFeedbackMode: "indicate",
                    onReorder: function(e) {
                        var visibleRows = e.component.getVisibleRows();
                        var toIndex = e.toIndex;
                        var fromIndex = visibleRows.findIndex(function(row) {
                            return row.data.TaskID === e.itemData.TaskID;
                        });
                        var tasksCopy = allTasks.slice();
                        var movedTask = tasksCopy.splice(fromIndex, 1)[0];
                        tasksCopy.splice(toIndex, 0, movedTask);
                        allTasks = tasksCopy;
                        saveTaskOrder(e.itemData, toIndex);
                        e.component.option("dataSource", allTasks);
                    }
                },

                // ===== TOOLBAR =====
                toolbar: {
                    items: [{
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

                // ===== SELECTION =====
                selection: {
                    mode: "multiple",
                    showCheckBoxesMode: "onClick",
                    allowSelectAll: true
                },

                // ===== PAGING =====
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

                // ===== GROUPING =====
                grouping: {
                    autoExpandAll: true,
                    contextMenuEnabled: true
                },
                groupPanel: {
                    visible: true,
                    emptyPanelText: "Kéo cột vào đây để nhóm theo tiêu chí"
                },

                // ===== FILTERING =====
                filterRow: {
                    visible: false,
                    applyFilter: "auto"
                },
                searchPanel: {
                    visible: true,
                    width: 240,
                    placeholder: "Tìm kiếm công việc..."
                },
                headerFilter: {
                    visible: true
                },

                // ===== COLUMN CHOOSER =====
                columnChooser: {
                    enabled: true,
                    mode: "select",
                    title: "Chọn cột hiển thị"
                },

                // ===== EXPORT =====
                export: {
                    enabled: true,
                    fileName: "CongViecCuaToi",
                    allowExportSelectedData: true
                },

                // ===== STATE STORING =====
                stateStoring: {
                    enabled: true,
                    type: "localStorage",
                    storageKey: "taskGridState"
                },

                // ===== SORTING & SCROLLING =====
                sorting: {
                    mode: "multiple"
                },
                scrolling: {
                    mode: "virtual",
                    rowRenderingMode: "virtual",
                    showScrollbar: "onHover"
                },
                columnFixing: {
                    enabled: true
                },

                // ===== COLUMNS CONFIGURATION =====
                columns: [
                    // ===== DRAG HANDLE =====
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
                    // ===== TASK ID =====
                    {
                        dataField: "TaskID",
                        caption: "ID",
                        width: 80,
                        alignment: "center",
                        allowEditing: false,
                        fixed: false,
                        sortOrder: "desc"
                    },
                    // ===== GROUP ID =====
                    {
                        dataField: "GroupID",
                        caption: "Nhóm",
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
                    // ===== PARENT TASK ID =====
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
                    // ===== TASK NAME (INLINE EDIT) =====
                    {
                        dataField: "TaskName",
                        caption: "Tên công việc",
                        minWidth: 250,
                        cellTemplate: function(container, options) {
                            var task = options.data;
                            var taskID = task.TaskID;
                            var containerId = "TaskNameDiv_" + taskID;
                            var $wrapper = $("<div>")
                                .attr("id", containerId)
                                .data("record", task)
                                .css({
                                    width: "100%",
                                    minHeight: "40px",
                                    cursor: "pointer"
                                });
                            var $displayDiv = $("<div>").addClass("task-name-cell");
                            $("<div>").addClass("task-name-title").text(task.TaskName).appendTo($displayDiv);
                            var $meta = $("<div>").addClass("task-name-meta");
                            if (task.CommentCount > 0) {
                                $("<span>").addClass("task-comment-badge")
                                    .html(`<i class="bi bi-chat-dots"></i> ${task.CommentCount} bình luận`)
                                    .appendTo($meta);
                            }
                            $("<span>").text("#" + taskID).appendTo($meta);
                            if (task.ParentTaskName) {
                                $("<span>").html(`<i class="bi bi-diagram-3"></i> ${task.ParentTaskName}`)
                                    .appendTo($meta);
                            }
                            $meta.appendTo($displayDiv);
                            $wrapper.append($displayDiv);
                            var textBoxInstance = null;
                            var $controlContainer = null;
                            var isEditing = false;
                            var originalValue = task.TaskName;
                            var animationFrameId = null;
                            var lastPosition = null;

                            function updatePopupPosition() {
                                if (!actionPopupInstance || !actionPopupInstance.option("visible") || !textBoxInstance) {
                                    return;
                                }
                                try {
                                    var $inputElement = $(textBoxInstance.element());
                                    if (!$inputElement.is('':visible'')) {
                                        return;
                                    }
                                    var rect = $inputElement[0].getBoundingClientRect();
                                    var currentPosition = {
                                        top: rect.top,
                                        left: rect.left,
                                        width: rect.width,
                                        height: rect.height
                                    };
                                    if (!lastPosition ||
                                        lastPosition.top !== currentPosition.top ||
                                        lastPosition.left !== currentPosition.left) {
                                        actionPopupInstance.option("position", {
                                            at: "bottom right",
                                            my: "top right",
                                            of: $inputElement,
                                            collision: "fit flip",
                                            offset: "0 4"
                                        });
                                        lastPosition = currentPosition;
                                    }
                                } catch (e) {
                                    // Ignore errors
                                }
                            }

                            function positionUpdateLoop() {
                                if (isEditing && textBoxInstance) {
                                    updatePopupPosition();
                                    animationFrameId = requestAnimationFrame(positionUpdateLoop);
                                }
                            }

                            function startPositionUpdates() {
                                if (animationFrameId) {
                                    cancelAnimationFrame(animationFrameId);
                                }
                                lastPosition = null;
                                positionUpdateLoop();
                            }

                            function stopPositionUpdates() {
                                if (animationFrameId) {
                                    cancelAnimationFrame(animationFrameId);
                                    animationFrameId = null;
                                }
                                lastPosition = null;
                            }

                            function exitEditMode(cancel) {
                                if (!isEditing) return;
                                isEditing = false;
                                stopPositionUpdates();
                                if (actionPopupInstance && actionPopupInstance.option("visible")) {
                                    actionPopupInstance.hide();
                                }
                                $(document).off("click.editTaskName" + taskID);
                                if (cancel) {
                                    if (textBoxInstance) {
                                        textBoxInstance.option("value", originalValue);
                                    }
                                    $displayDiv.find(".task-name-title").text(originalValue);
                                    task.TaskName = originalValue;
                                } else {
                                    if (textBoxInstance) {
                                        var newValue = textBoxInstance.option("value");
                                        originalValue = newValue;
                                        task.TaskName = newValue;
                                        $displayDiv.find(".task-name-title").text(newValue);
                                    }
                                }
                                if ($controlContainer) {
                                    $controlContainer.hide();
                                }
                                $displayDiv.show();
                            }

                            $wrapper.on("click", function(e) {
                                e.stopPropagation();
                                if (isEditing) return;
                                isEditing = true;
                                $displayDiv.hide();
                                if (!$controlContainer || !$controlContainer.length) {
                                    $controlContainer = $("<div>").css({
                                        width: "100%"
                                    });
                                    $wrapper.append($controlContainer);
                                    textBoxInstance = $controlContainer.dxTextBox({
                                        value: originalValue,
                                        width: "100%",
                                        inputAttr: {
                                            class: "form-control form-control-sm",
                                            style: "font-size: 14px;"
                                        },
                                        onFocusIn: function(e) {
                                            $(e.element).find("input").css("border", "1px solid #1c975e");
                                        },
                                        onFocusOut: function(e) {
                                            $(e.element).find("input").css("border", "");
                                        },
                                        onKeyDown: function(e) {
                                            if (e.event.key === "Enter") {
                                                e.event.preventDefault();
                                                saveValue();
                                            }
                                            if (e.event.key === "Escape") {
                                                e.event.preventDefault();
                                                exitEditMode(true);
                                            }
                                        }
                                    }).dxTextBox("instance");
                                } else {
                                    $controlContainer.show();
                                    if (textBoxInstance) {
                                        textBoxInstance.option("value", originalValue);
                                    }
                                }

                                setTimeout(function() {
                                    if (textBoxInstance) {
                                        var $inputElement = $(textBoxInstance.element());
                                        showActionPopup($inputElement, "TaskName_" + taskID,
                                            async () => {
                                                    await saveValue();
                                                },
                                                () => {
                                                    exitEditMode(true);
                                                }
                                        );
                                        startPositionUpdates();
                                    }
                                }, 100);

                                setTimeout(() => {
                                    $(document).on("click.editTaskName" + taskID, function(ev) {
                                        var $t = $(ev.target);
                                        if (!$t.closest($wrapper).length &&
                                            !$t.closest(".dx-popup-wrapper").length &&
                                            !$t.closest(".dx-texteditor").length) {
                                            exitEditMode(true);
                                        }
                                    });
                                }, 150);

                                setTimeout(() => {
                                    if (textBoxInstance) {
                                        textBoxInstance.focus();
                                    }
                                }, 120);
                            });

                            async function saveValue() {
                                if (!textBoxInstance) {
                                    exitEditMode(false);
                                    return;
                                }
                                var newVal = textBoxInstance.option("value");
                                if (newVal === originalValue) {
                                    exitEditMode(false);
                                    return;
                                }
                                try {
                                    await saveFunction(
                                        JSON.stringify([-99218308, ["TaskName"],
                                            [newVal]
                                        ]),
                                        [
                                            [taskID], "TaskID"
                                        ]
                                    );
                                    originalValue = newVal;
                                    task.TaskName = newVal;
                                    $displayDiv.find(".task-name-title").text(newVal);
                                    uiManager.showAlert({
                                        type: "success",
                                        message: "Lưu thành công"
                                    });
                                    exitEditMode(false);
                                } catch (err) {
                                    uiManager.showAlert({
                                        type: "error",
                                        message: "Có lỗi xảy ra khi lưu"
                                    });
                                }
                            }

                            container.append($wrapper);
                        }
                    },
                    // ===== ASSIGN PRIORITY (INLINE EDIT) =====
                    {
                        dataField: "AssignPriority",
                        caption: "Ưu tiên",
                        width: 100,
                        alignment: "center",
                        cellTemplate: function(container, options) {
                            const task = options.data;
                            const taskID = task.TaskID;
                            const containerId = "PriorityDiv_" + taskID;
                            const $wrapper = $("<div>").attr("id", containerId).css({ width: "100%", cursor: "pointer" });

                            const priority = options.value || 3;
                            const prioMap = {
                                1: { text: "Cao", icon: "bi-flag-fill", colorClass: "text-danger" },
                                2: { text: "Trung bình", icon: "bi-flag", colorClass: "text-warning" },
                                3: { text: "Thấp", icon: "bi-flag", colorClass: "text-secondary" }
                            };
                            const info = prioMap[priority] || prioMap[3];

                            const $icon = $(`<i class="${info.icon} ${info.colorClass}" style="font-size:18px;" title="${info.text}"></i>`);
                            $wrapper.append($icon);

                            let isEditing = false;
                            let originalPrio = priority;

                            $wrapper.on("click", function(e) {
                                e.stopPropagation();
                                if (isEditing) return;
                                isEditing = true;
                                $icon.hide();

                                const $controlContainer = $("<div>").css({ width: "100%" });
                                $wrapper.append($controlContainer);

                                const prioDataSource = Object.keys(prioMap).map(k => ({
                                    ID: parseInt(k),
                                    Name: prioMap[k].text,
                                    Icon: prioMap[k].icon,
                                    ColorClass: prioMap[k].colorClass
                                }));

                                $controlContainer.dxSelectBox({
                                    dataSource: prioDataSource,
                                    valueExpr: "ID",
                                    displayExpr: "Name",
                                    value: priority,
                                    searchEnabled: true,
                                    showClearButton: true,
                                    width: "100%",
                                    dropDownOptions: {
                                        width: 200,
                                        maxHeight: 300,
                                        container: "#sp_Task_MyWork_html",
                                        position: { my: "top left", at: "bottom left", of: $wrapper, offset: "0 4", collision: "flip fit" }
                                    },
                                    itemTemplate: function(data) {
                                        return $("<div class=`d-flex align-items-center gap-2 px-2 py-1`>")
                                            .append(
                                                $(`<i class="${data.Icon} ${data.ColorClass}" style="font-size:16px;"></i>`),
                                                $("<span class=''fw-normal''>").text(data.Name)
                                            );
                                    },
                                    onValueChanged: async function(e) {
                                        if (e.value !== originalPrio) {
                                            try {
                                                await saveFunction(
                                                    JSON.stringify([-99218308, ["AssignPriority"], [e.value]]),
                                                    [[taskID], "TaskID"]
                                                );
                                                task.AssignPriority = e.value;
                                                originalPrio = e.value;
                                                const newInfo = prioMap[e.value] || prioMap[3];
                                                $icon.removeClass().addClass(newInfo.icon + " " + newInfo.colorClass).attr("title", newInfo.text);
                                                uiManager.showAlert({ type: "success", message: "Lưu ưu tiên" });
                                            } catch (err) {
                                                uiManager.showAlert({ type: "error", message: "Lỗi lưu ưu tiên" });
                                            }
                                        }
                                        exitEditMode(false);
                                    },
                                    onInitialized: function(e) {
                                        setTimeout(() => e.component.open(), 100);
                                    }
                                });

                                setTimeout(() => {
                                    $(document).on("click.outsidePrio" + taskID, function(ev) {
                                        if (!$(ev.target).closest($wrapper).length && !$(ev.target).closest(".dx-selectbox").length) {
                                            exitEditMode(true);
                                        }
                                    });
                                }, 150);

                                function exitEditMode(cancel) {
                                    isEditing = false;
                                    $(document).off("click.outsidePrio" + taskID);
                                    $controlContainer.remove();
                                    if (cancel) {
                                        const rollback = prioMap[originalPrio] || prioMap[3];
                                        $icon.removeClass().addClass(rollback.icon + " " + rollback.colorClass).attr("title", rollback.text);
                                    }
                                    $icon.show();
                                }
                            });

                            container.append($wrapper);
                        }
                    },
                    // ===== NGƯỜI THỰC HIỆN (CLICK TO OPEN POPUP) =====
                    {
                        dataField: "AssignedToEmployeeIDs",
                        caption: "Người thực hiện",
                        width: 200,
                        allowSorting: false,
                        cellTemplate: function(container, options) {
                            var task = options.data;
                            var taskID = task.TaskID;
                            var id = "EmployeeIDDiv_" + taskID;
                            var controlDiv = $("<div>").attr("id", id).data("record", task).on("click", function(e) {
                                e.stopPropagation();
                                AssignedToEmployeeIDsControl = loadUI_EmployeeID();
                                AssignedToEmployeeIDsControl.setValue(task.AssignedToEmployeeIDs);
                                AssignedToEmployeeIDsKey = {
                                    TaskID: task.TaskID
                                };
                            });
                            var empIds = task.AssignedToEmployeeIDs ? task.AssignedToEmployeeIDs.split(",") : [];
                            var empNames = task.AssignedToName ? task.AssignedToName.split(",") : [];
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
                            controlDiv.append(empDiv);
                            container.append(controlDiv);
                        }
                    },
                    // ===== TIẾN ĐỘ (READ ONLY) =====
                    {
                        dataField: "ProgressPct",
                        caption: "Tiến độ",
                        width: 200,
                        alignment: "left",
                        sortOrder: "desc",
                        cellTemplate: function(container, options) {
                            var task = options.data;
                            var taskID = task.TaskID;
                            var id = "ProgressDiv_" + taskID;
                            var controlDiv = $("<div>").attr("id", id).data("record", task);
                            var progress = options.value || 0;
                            var displayText = "";
                            if (task.TargetKPI > 0) {
                                displayText = (task.ActualKPI || 0) + "/" + task.TargetKPI;
                            } else if (task.TotalSubtasks > 0) {
                                displayText = (task.CompletedSubtasks || 0) + "/" + task.TotalSubtasks;
                            }
                            var div = $("<div>").addClass("progress-cell");
                            if (displayText) {
                                $("<div>").addClass("progress-info").text(displayText).appendTo(div);
                            }
                            var barContainer = $("<div>").addClass("progress-bar-container");
                            $("<div>").addClass("progress-bar-fill")
                                .css("width", Math.min(progress, 100) + "%")
                                .appendTo(barContainer);
                            barContainer.appendTo(div);
                            $("<div>").addClass("progress-text").text(progress + "%").appendTo(div);
                            controlDiv.append(div);
                            container.append(controlDiv);
                        }
                    },
                    // ===== TRẠNG THÁI (INLINE EDIT) =====
                    {
                        dataField: "StatusCode",
                        caption: "Trạng thái",
                        width: 140,
                        alignment: "center",
                        cellTemplate: function(container, options) {
                            const task = options.data;
                            const taskID = task.TaskID;
                            const containerId = "StatusDiv_" + taskID;
                            const $wrapper = $("<div>")
                                .attr("id", containerId)
                                .data("record", task)
                                .css({ width: "100%", cursor: "pointer" });

                            const status = options.value || 1;
                            const statusMap = {
                                1: { text: "Chưa làm", bg: "bg-light", textClass: "text-secondary", dotColor: "#6c757d" },
                                2: { text: "Đang làm", bg: "bg-info", textClass: "text-white", dotColor: "#ffffff" },
                                3: { text: "Hoàn thành", bg: "bg-success", textClass: "text-white", dotColor: "#ffffff" }
                            };
                            const info = statusMap[status] || statusMap[1];

                            // Badge dùng Bootstrap + inline style
                            const $badge = $(`<span class="badge ${info.bg} ${info.textClass} px-2 py-1 fw-semibold rounded-pill d-inline-flex align-items-center gap-1" style="font-size:12px;">`)
                                .append(
                                    $("<span>").css({
                                        display: "inline-block",
                                        width: "6px",
                                        height: "6px",
                                        borderRadius: "50%",
                                        backgroundColor: info.dotColor
                                    }),
                                    $("<span>").text(info.text)
                                );
                            $wrapper.append($badge);

                            let isEditing = false;
                            let originalStatus = status;

                            $wrapper.on("click", function(e) {
                                e.stopPropagation();
                                if (isEditing) return;
                                isEditing = true;
                                $badge.hide();

                                const $controlContainer = $("<div>").css({ width: "100%" });
                                $wrapper.append($controlContainer);

                                const statusDataSource = Object.keys(statusMap).map(k => ({
                                    ID: parseInt(k),
                                    Name: statusMap[k].text,
                                    DotColor: statusMap[k].dotColor,
                                    BadgeClass: statusMap[k].bg + " " + statusMap[k].textClass
                                }));

                                $controlContainer.dxSelectBox({
                                    dataSource: statusDataSource,
                                    valueExpr: "ID",
                                    displayExpr: "Name",
                                    value: status,
                                    searchEnabled: true,
                                    showClearButton: true,
                                    width: "100%",
                                    // Popup nổi, rộng tự động
                                    dropDownOptions: {
                                        width: 220,
                                        maxHeight: 300,
                                        container: "#sp_Task_MyWork_html",
                                        position: { my: "top left", at: "bottom left", of: $wrapper, offset: "0 4", collision: "flip fit" }
                                    },
                                    itemTemplate: function(data) {
                                        return $("<div class=`d-flex align-items-center gap-2 px-2 py-1`>")
                                            .append(
                                                $("<span>").css({
                                                    display: "inline-block",
                                                    width: "8px",
                                                    height: "8px",
                                                    borderRadius: "50%",
                                                    backgroundColor: data.DotColor
                                                }),
                                                $("<span class=''fw-normal''>").text(data.Name)
                                            );
                                    },
                                    onValueChanged: async function(e) {
                                        if (e.value !== originalStatus) {
                                            try {
                                                await saveFunction(
                                                    JSON.stringify([-99218308, ["StatusCode"], [e.value]]),
                                                    [[taskID], "TaskID"]
                                                );
                                                task.StatusCode = e.value;
                                                originalStatus = e.value;
                                                const newInfo = statusMap[e.value] || statusMap[1];
                                                $badge.empty().append(
                                                    $("<span>").css({
                                                        display: "inline-block",
                                                        width: "6px",
                                                        height: "6px",
                                                        borderRadius: "50%",
                                                        backgroundColor: newInfo.dotColor
                                                    }),
                                                    $("<span>").text(newInfo.text)
                                                ).attr("class", `badge ${newInfo.bg} ${newInfo.textClass} px-2 py-1 fw-semibold rounded-pill d-inline-flex align-items-center gap-1`);
                                                uiManager.showAlert({ type: "success", message: "Lưu trạng thái" });
                                                loadTasks();
                                            } catch (err) {
                                                uiManager.showAlert({ type: "error", message: "Lỗi lưu trạng thái" });
                                            }
                                        }
                                        exitEditMode(false);
                                    },
                                    onInitialized: function(e) {
                                        setTimeout(() => e.component.open(), 100);
                                    }
                                });

                                setTimeout(() => {
                                    $(document).on("click.outsideStatus" + taskID, function(ev) {
                                        if (!$(ev.target).closest($wrapper).length && !$(ev.target).closest(".dx-selectbox").length) {
                                            exitEditMode(true);
                                        }
                                    });
                                }, 150);

                                function exitEditMode(cancel) {
                                    isEditing = false;
                                    $(document).off("click.outsideStatus" + taskID);
                                    $controlContainer.remove();
                                    if (cancel) {
                                        const rollback = statusMap[originalStatus] || statusMap[1];
                                        $badge.empty().append(
                                            $("<span>").css({
                                                display: "inline-block",
                                                width: "6px",
                                                height: "6px",
                                                borderRadius: "50%",
                                                backgroundColor: rollback.dotColor
                                            }),
                                            $("<span>").text(rollback.text)
                                        ).attr("class", `badge ${rollback.bg} ${rollback.textClass} px-2 py-1 fw-semibold rounded-pill d-inline-flex align-items-center gap-1`);
                                    }
                                    $badge.show();
                                }
                            });

                            container.append($wrapper);
                        }
                    },
                    // ===== NGÀY BẮT ĐẦU =====
                    {
                        dataField: "MyStartDate",
                        caption: "Ngày bắt đầu",
                        width: 130,
                        dataType: "date",
                        format: "dd/MM/yyyy",
                        alignment: "center",
                        cellTemplate: function(container, options) {
                            container.text(formatSimpleDate(options.value) || "-");
                        }
                    },
                    // ===== HẠN HOÀN THÀNH =====
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
                                $("<i>").addClass("bi bi-exclamation-triangle-fill").appendTo(dateDiv);
                            }
                            $("<span>").text(dateStr || "-").appendTo(dateDiv);
                            container.append(dateDiv);
                        }
                    },
                    // ===== TRẠNG THÁI HẠN =====
                    {
                        dataField: "IsOverdue",
                        caption: "Trạng thái hạn",
                        width: 120,
                        alignment: "center",
                        allowEditing: false,
                        cellTemplate: function(container, options) {
                            var text = options.value === 1 ? "Quá hạn" : "Đúng hạn";
                            $("<span>").text(text).appendTo(container);
                        }
                    },
                    // ===== NHÃN (CLICK TO OPEN) =====
                    {
                        dataField: "Tags",
                        caption: "Nhãn",
                        width: 180,
                        cellTemplate: function(container, options) {
                            const task = options.data;
                            const taskID = task.TaskID;
                            const containerId = "TagsCell_" + taskID;
                            const $wrapper = $("<div>").attr("id", containerId).css({
                                width: "100%",
                                cursor: "pointer"
                            });

                            // Render tags as compact badges
                            const tagText = options.value || "";
                            const tagIds = tagText ? tagText.split(",").map(Number) : [];
                            const tagsMap = {
                                1: {
                                    name: "Khẩn cấp",
                                    icon: "exclamation-circle",
                                    color: "#dc3545"
                                },
                                2: {
                                    name: "Quan trọng",
                                    icon: "star",
                                    color: "#ffc107"
                                },
                                3: {
                                    name: "Backend",
                                    icon: "server",
                                    color: "#198754"
                                },
                                4: {
                                    name: "Frontend",
                                    icon: "display",
                                    color: "#0dcaf0"
                                },
                                5: {
                                    name: "Bug",
                                    icon: "bug",
                                    color: "#6c757d"
                                }
                            };

                            const $tagContainer = $("<div>").css({
                                display: "flex",
                                gap: "4px",
                                flexWrap: "wrap"
                            });

                            if (tagIds.length === 0) {
                                $tagContainer.append($("<span>").css({
                                    color: "#adb5bd",
                                    fontSize: "12px"
                                }).text("–"));
                            } else {
                                tagIds.slice(0, 3).forEach(id => {
                                    const tag = tagsMap[id];
                                    if (tag) {
                                        const $badge = $("<span>").css({
                                            fontSize: "11px",
                                            padding: "2px 6px",
                                            borderRadius: "4px",
                                            backgroundColor: tag.color + "20",
                                            color: tag.color,
                                            display: "inline-flex",
                                            alignItems: "center",
                                            gap: "4px"
                                        }).html(`<i class="bi bi-${tag.icon}" style="font-size:10px"></i> ${tag.name}`);
                                        $tagContainer.append($badge);
                                    }
                                });
                                if (tagIds.length > 3) {
                                    $tagContainer.append($("<span>").css({
                                        fontSize: "11px",
                                        color: "#6c757d"
                                    }).text(`+${tagIds.length - 3}`));
                                }
                            }

                            $wrapper.append($tagContainer);
                            container.append($wrapper);

                            // Không cho phép edit inline vì TagBox chiếm nhiều không gian → giữ nguyên hành vi cũ (mở popup toàn cục)
                            // → Giữ nguyên như hiện tại hoặc kích hoạt popup khi click
                            $wrapper.on("click", function(e) {
                                e.stopPropagation();
                                TagsControl = loadUI_Tags();
                                TagsControl.setValue(task.Tags);
                                TagsKey = {
                                    TaskID: taskID
                                };
                            });
                        }
                    },
                    // ===== THAO TÁC =====
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

                // ===== SUMMARY =====
                summary: {
                    totalItems: [{
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
                    groupItems: [{
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

                // ===== MASTER DETAIL =====
                masterDetail: {
                    enabled: false
                },

                // ===== EVENT HANDLERS =====
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
                onContextMenuPreparing: function(e) {
                    if (e.row && e.row.rowType === "data") {
                        e.items = [{
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
                            {
                                beginGroup: true
                            },
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
                            {
                                beginGroup: true
                            },
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
                    e.toolbarOptions.items.unshift({
                        location: "after",
                        widget: "dxButton",
                        options: {
                            icon: "refresh",
                            hint: "Tải lại dữ liệu",
                            onClick: function() {
                                loadTasks();
                            }
                        }
                    });
                }
            }).dxDataGrid("instance");
        }

        // ===== HELPER FUNCTIONS =====

        /**
        * Format date to dd/MM/yyyy
        */
        function formatSimpleDate(dateString) {
            if (!dateString) return "";
            var d = new Date(dateString);
            if (isNaN(d.getTime())) return "";
            var day = ("0" + d.getDate()).slice(-2);
            var month = ("0" + (d.getMonth() + 1)).slice(-2);
            var year = d.getFullYear();
            return day + "/" + month + "/" + year;
        }

        /**
        * Get initials from full name
        */
        function getInitials(fullName) {
            if (!fullName) return "??";
            var name = String(fullName).replace(/\s+/g, " ").trim();
            if (!name) return "??";
            var parts = name.split(" ").filter(function(p) {
                return p.length > 0;
            });
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

        /**
        * Save function for all controls
        */
        async function saveFunction(dataJSON, idValues) {
            return new Promise((resolve, reject) => {
                try {
                    const data = JSON.parse(dataJSON);
                    const spCode = data[0];
                    const columnNames = data[1];
                    const columnValues = data[2];

                    const idColumn = idValues[0][0];
                    const idFieldName = idValues[1];

                    var params = [
                        "LoginID", LoginID,
                        "LanguageID", LanguageID,
                        "TableName", "tblTask",
                        "ColumnName", columnNames[0],
                        "IDColumnName", idFieldName,
                        "ColumnValue", columnValues[0],
                        "ID_Value", idColumn
                    ];

                    AjaxHPAParadise({
                        data: {
                            name: "sp_Common_SaveDataTable",
                            param: params
                        },
                        success: function(response) {
                            try {
                                const result = typeof response === "string" ? JSON.parse(response) : response;
                                resolve(result);
                            } catch (e) {
                                resolve({
                                    success: true
                                });
                            }
                        },
                        error: function(err) {
                            console.error("Save error:", err);
                            reject(err);
                        }
                    });
                } catch (e) {
                    console.error("Parse error:", e);
                    reject(e);
                }
            });
        }

        /**
        * Show action popup (Save/Cancel buttons)
        */
        function showActionPopup(target, fieldId, onSave, onCancel) {
            const popup = initActionPopup();
            if (currentFieldId && currentFieldId !== fieldId && cancelCallback) {
                cancelCallback();
            }
            saveCallback = onSave;
            cancelCallback = onCancel;
            currentField = target;
            currentFieldId = fieldId;
            popup.option("position.of", target);
            popup.show();
        }

        /**
        * Initialize action popup (singleton)
        */
        function initActionPopup() {
            if (actionPopupInstance) return actionPopupInstance;

            actionPopupInstance = $(`<div id="actionPopupGlobal">`).appendTo("body").dxPopup({
                width: "auto",
                height: "auto",
                showTitle: false,
                visible: false,
                dragEnabled: false,
                hideOnOutsideClick: false,
                showCloseButton: false,
                shading: false,
                position: {
                    at: "bottom right",
                    my: "top right",
                    collision: "fit flip",
                    offset: "0 4"
                },
                contentTemplate: function() {
                    return $(`<div class="d-flex" style="gap: .5rem; padding: 8px 12px;">`).append(
                        $("<div>").dxButton({
                            icon: "check",
                            hint: "Lưu",
                            stylingMode: "contained",
                            type: "success",
                            width: 28,
                            height: 28,
                            elementAttr: {
                                style: "border-radius: 6px !important;"
                            },
                            onClick: async function() {
                                if (saveCallback) await saveCallback();
                                actionPopupInstance.hide();
                            }
                        }),
                        $("<div>").dxButton({
                            icon: "close",
                            hint: "Hủy",
                            stylingMode: "outlined",
                            type: "normal",
                            width: 28,
                            height: 28,
                            elementAttr: {
                                style: "border-radius: 6px !important;"
                            },
                            onClick: function() {
                                if (cancelCallback) cancelCallback();
                                actionPopupInstance.hide();
                            }
                        })
                    );
                },
                onHiding: function() {
                    currentField = currentFieldId = saveCallback = cancelCallback = null;
                }
            }).dxPopup("instance");

            return actionPopupInstance;
        }

        // ===== CRUD OPERATIONS =====

        /**
        * Load tasks from server
        */
        function loadTasks() {
            AjaxHPAParadise({
                data: {
                    name: "sp_Task_GetMyTasks",
                    param: ["LoginID", LoginID]
                },
                success: function(response) {
                    try {
                        var res = JSON.parse(response);
                        allTasks = res.data[0] || [];
                        taskGridInstance.option("dataSource", allTasks);
                        taskGridInstance.columnOption("GroupID", {
                            groupIndex: 0
                        });
                        updateStatistics();
                        taskGridInstance.endCustomLoading();
                    } catch (e) {
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

        /**
        * Save task order after drag and drop
        */
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

        /**
        * Update task status
        */
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

        /**
        * Delete task
        */
        function deleteTask(taskID) {
            AjaxHPAParadise({
                data: {
                    name: "sp_Task_Delete",
                    param: [
                        "TaskID", taskID,
                        "LoginID", LoginID
                    ]
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

        /**
        * Update statistics cards
        */
        function updateStatistics() {
            var parentTasks = allTasks.filter(function(t) {
                return t.ParentTaskID === null;
            });

            var todoCount = parentTasks.filter(function(t) {
                return t.StatusCode == 1;
            }).length;

            var doingCount = parentTasks.filter(function(t) {
                return t.StatusCode == 2;
            }).length;

            var doneCount = parentTasks.filter(function(t) {
                return t.StatusCode == 3;
            }).length;

            var overdueCount = parentTasks.filter(function(t) {
                return t.IsOverdue == 1;
            }).length;

            $("#stat-todo").text(todoCount);
            $("#stat-doing").text(doingCount);
            $("#stat-done").text(doneCount);
            $("#stat-overdue").text(overdueCount);
        }

        /**
        * Open task detail popup/modal
        */
        function openTaskDetail(taskID) {
            var task = allTasks.find(function(t) {
                return t.TaskID === taskID;
            });

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

        function loadTasks() {
            AjaxHPAParadise({
                data: {
                    name: "sp_Task_GetMyTasks",
                    param: ["LoginID", LoginID]
                },
                success: function(response) {
                    try {
                        var res = JSON.parse(response);
                        allTasks = res.data[0] || [];
                        taskGridInstance.option("dataSource", allTasks);
                        taskGridInstance.columnOption("GroupID", {
                            groupIndex: 0
                        });
                        updateStatistics();
                        taskGridInstance.endCustomLoading();
                    } catch (e) {
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
                    param: ["TaskID", taskID, "LoginID", LoginID, "NewStatus", newStatus]
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
            var parentTasks = allTasks.filter(function(t) {
                return t.ParentTaskID === null;
            });
            var todoCount = parentTasks.filter(function(t) {
                return t.StatusCode == 1;
            }).length;
            var doingCount = parentTasks.filter(function(t) {
                return t.StatusCode == 2;
            }).length;
            var doneCount = parentTasks.filter(function(t) {
                return t.StatusCode == 3;
            }).length;
            var overdueCount = parentTasks.filter(function(t) {
                return t.IsOverdue == 1;
            }).length;

            $("#stat-todo").text(todoCount);
            $("#stat-doing").text(doingCount);
            $("#stat-done").text(doneCount);
            $("#stat-overdue").text(overdueCount);
        }

        function openTaskDetail(taskID) {
            var task = allTasks.find(function(t) {
                return t.TaskID === taskID;
            });
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

        function renderKanbanView(data) {
            var allVisibleTasks = data.filter(function(t) {
                return t.ParentTaskID === null;
            });
            var todoTasks = allVisibleTasks.filter(function(t) {
                return t.StatusCode == 1;
            });
            var doingTasks = allVisibleTasks.filter(function(t) {
                return t.StatusCode == 2;
            });
            var doneTasks = allVisibleTasks.filter(function(t) {
                return t.StatusCode == 3;
            });

            $("#count-todo").text(todoTasks.length);
            $("#count-doing").text(doingTasks.length);
            $("#count-done").text(doneTasks.length);

            renderTaskCards("#tasks-todo", todoTasks);
            renderTaskCards("#tasks-doing", doingTasks);
            renderTaskCards("#tasks-done", doneTasks);
        }

        function renderTaskCards(container, tasks) {
            if (tasks.length === 0) {
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
                            <div class="task-title" title="${(t.TaskName || "").replace(/" /g, "&quot;" )}">${t.TaskName}</div>
                            <div class="task-sub"> ${t.CommentCount > 0 ? ` <span>
                                    <i class="bi bi-chat-dots"></i> ${t.CommentCount} </span>` : ""} <span class="text-muted">#${t.TaskID}</span>
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
                        <div class="row-meta"> ${dateRange ? ` <span class="date-range ${dateClass}">${dateRange}</span>` : ""} ${t.IsOverdue ? ` <small class="text-danger mt-1 fw-bold">
                                <i class="bi bi-exclamation-triangle-fill"></i> Quá hạn </small>` : ""} </div>
                    </div>
                `;
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
            if (!dateString) return "";
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
            var parts = name.split(" ").filter(function(p) {
                return p.length > 0;
            });
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

        // Global saveFunction for controls
        async function saveFunction(dataJSON, idValues) {
            return new Promise((resolve, reject) => {
                try {
                    const data = JSON.parse(dataJSON);
                    const spCode = data[0];
                    const columnNames = data[1];
                    const columnValues = data[2];

                    const idColumn = idValues[0][0];
                    const idFieldName = idValues[1];

                    var params = [
                        "LoginID", LoginID,
                        "LanguageID", LanguageID,
                        "TableName", "tblTask",
                        "ColumnName", columnNames[0],
                        "IDColumnName", idFieldName,
                        "ColumnValue", columnValues[0],
                        "ID_Value", idColumn
                    ];

                    AjaxHPAParadise({
                        data: {
                            name: "sp_Common_SaveDataTable",
                            param: params
                        },
                        success: function(response) {
                            try {
                                const result = typeof response === "string" ? JSON.parse(response) : response;
                                resolve(result);
                            } catch (e) {
                                resolve({
                                    success: true
                                });
                            }
                        },
                        error: function(err) {
                            console.error("Save error:", err);
                            reject(err);
                        }
                    });
                } catch (e) {
                    console.error("Parse error:", e);
                    reject(e);
                }
            });
        }

        window.taskGridInstance = taskGridInstance;
    })();
</script>
';
SELECT @html AS html;
END
GO

-- =====================================================================
-- EXEC sp_GenerateHTMLScript để tạo file HTML từ stored procedure
-- =====================================================================
EXEC sp_GenerateHTMLScript 'sp_Task_MyWork_html'
GO