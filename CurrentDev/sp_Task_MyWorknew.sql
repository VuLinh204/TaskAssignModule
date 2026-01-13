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
        padding-bottom: 50px;
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
    /* Empty State */
    #sp_Task_MyWork_html .empty-state {
        text-align: center;
        padding: 60px 20px;
        color: var(--text-muted);
    }
    #sp_Task_MyWork_html .empty-state i {
        font-size: 64px;
        color: var(--border-color);
        margin-bottom: 16px;
        opacity: 0.5;
    }
    #sp_Task_MyWork_html .empty-state p {
        margin: 0;
        font-size: 14px;
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
    /* Responsive */
    @media (max-width: 768px) {
        #sp_Task_MyWork_html {
            padding: 12px;
            padding-bottom: 50px;
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
    @media (max-width: 480px) {
        #sp_Task_MyWork_html {
            padding: 8px;
            padding-bottom: 50px;
        }
        #sp_Task_MyWork_html .h-title {
            font-size: 18px;
        }
        #sp_Task_MyWork_html .cu-header {
            flex-direction: column;
            gap: 12px !important;
        }
        #sp_Task_MyWork_html .header-actions {
            width: 100%;
            flex-direction: column;
        }
        #sp_Task_MyWork_html .view-switcher {
            width: 100%;
        }
        #sp_Task_MyWork_html .view-btn {
            flex: 1;
            justify-content: center;
            padding: 10px 8px;
            font-size: 12px;
        }
        #sp_Task_MyWork_html .btn-assign,
        #sp_Task_MyWork_html .btn-refresh {
            width: 100%;
            justify-content: center;
            padding: 12px;
            font-size: 13px;
        }
        #sp_Task_MyWork_html .stats-row {
            display: none !important;
            flex-wrap: wrap;
            gap: 8px;
        }
        #sp_Task_MyWork_html .stat-card {
            flex: 1 1 calc(50% - 8px);
            min-width: 110px;
            padding: 10px 12px;
        }
        #sp_Task_MyWork_html .stat-card::before {
            height: 30px;
            width: 3px;
        }
        #sp_Task_MyWork_html .stat-label-task {
            font-size: 10px;
        }
        #sp_Task_MyWork_html .stat-value {
            font-size: 20px;
        }
        #sp_Task_MyWork_html .table {
            font-size: 12px;
        }
        #sp_Task_MyWork_html .table td {
            padding: 8px;
        }
        #sp_Task_MyWork_html .employee-avatar {
            width: 28px;
            height: 28px;
            font-size: 10px;
        }
        #sp_Task_MyWork_html .task-name-title {
            font-size: 13px;
        }
        #sp_Task_MyWork_html .task-name-meta {
            font-size: 11px;
            gap: 8px;
        }
        #sp_Task_MyWork_html .action-btn {
            padding: 4px 8px;
            font-size: 12px;
        }
        #sp_Task_MyWork_html .kanban-board {
            grid-template-columns: 1fr;
            gap: 12px;
        }
        #sp_Task_MyWork_html .kanban-column {
            min-height: 300px;
            padding: 12px;
        }
        #sp_Task_MyWork_html .column-title {
            font-size: 14px;
        }
        #sp_Task_MyWork_html .kanban-board .cu-row {
            padding: 10px;
            margin-bottom: 10px;
        }
        #sp_Task_MyWork_html .kanban-board .task-title {
            font-size: 13px;
        }
        #sp_Task_MyWork_html .kanban-board .task-sub {
            font-size: 11px;
            gap: 8px;
        }
        #sp_Task_MyWork_html .assign-row {
            grid-template-columns: 1fr;
            gap: 12px;
        }
        #sp_Task_MyWork_html .assign-container {
            padding: 16px;
            max-height: 80vh;
        }
        #sp_Task_MyWork_html .step-header {
            flex-direction: column;
            gap: 12px;
        }
        #sp_Task_MyWork_html .form-label {
            font-size: 12px;
        }
        #sp_Task_MyWork_html .form-control,
        #sp_Task_MyWork_html .form-select {
            font-size: 13px;
            min-height: 40px;
        }
        #sp_Task_MyWork_html .modal-dialog {
            margin: 8px;
        }
        #sp_Task_MyWork_html .modal-content {
            border-radius: 12px;
        }
        #sp_Task_MyWork_html .progress-cell {
            flex-direction: column;
            gap: 6px;
        }
        #sp_Task_MyWork_html .progress-info {
            width: 100%;
        }
        #sp_Task_MyWork_html .progress-bar-container {
            width: 100%;
        }
        #sp_Task_MyWork_html .progress-text {
            min-width: auto;
            text-align: left;
        }
    }
    @media (max-width: 1200px) {
        #sp_Task_MyWork_html .kanban-board {
            grid-template-columns: 1fr;
        }
    }

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
        overflow: auto;
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
    }
    #sp_Task_MyWork_html .assign-row {
        display: grid;
        grid-template-columns: repeat(2, 1fr);
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

    /* ===== MODAL FIX STYLES ===== */
    #sp_Task_MyWork_html .modal-header {
        border-bottom: 2px solid var(--border-color);
        padding: 16px 24px;
    }

    #sp_Task_MyWork_html .modal-title {
        font-weight: 700;
        font-size: 18px;
        display: flex;
        align-items: center;
        gap: 10px;
    }

    #sp_Task_MyWork_html .modal-title i {
        font-size: 20px;
    }

    #sp_Task_MyWork_html .assign-container {
        padding: 24px 32px;
        max-height: 60vh;
        overflow: auto;
    }

    #sp_Task_MyWork_html .assign-step {
        margin-bottom: 28px;
        padding-bottom: 20px;
        border-bottom: 1px solid var(--border-color);
    }

    #sp_Task_MyWork_html .assign-step:last-of-type {
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
        font-size: 18px;
    }

    #sp_Task_MyWork_html .step-title {
        font-size: 16px;
        font-weight: 600;
        color: var(--text-primary);
        padding-top: 8px;
    }

    #sp_Task_MyWork_html .assign-row {
        display: grid;
        grid-template-columns: repeat(2, 1fr);
        gap: 16px;
        align-items: start;
    }

    #sp_Task_MyWork_html .form-group {
        margin-bottom: 0;
        display: flex;
        flex-direction: column;
    }

    #sp_Task_MyWork_html .form-label {
        font-weight: 600;
        margin-bottom: 8px;
        font-size: 13px;
        color: var(--text-primary);
    }

    #sp_Task_MyWork_html .form-control,
    #sp_Task_MyWork_html .form-select {
        border-radius: 8px;
        border: 1.5px solid var(--border-color);
        padding: 10px 12px;
        font-size: 13px;
        transition: all var(--transition-base);
    }

    #sp_Task_MyWork_html .form-control:focus,
    #sp_Task_MyWork_html .form-select:focus {
        border-color: var(--task-primary);
        box-shadow: 0 0 0 3px rgba(46, 125, 50, 0.1);
        outline: none;
    }

    #sp_Task_MyWork_html #subtask-assign-container {
        display: grid;
        gap: 12px;
        overflow-y: auto;
        padding: 12px 0;
    }

    #sp_Task_MyWork_html .modal-footer {
        border-top: 1px solid var(--border-color);
        padding: 16px 24px;
        display: flex;
        gap: 12px;
        justify-content: flex-end;
    }

    #sp_Task_MyWork_html .modal-footer .btn {
        padding: 10px 20px;
        border-radius: 8px;
        font-weight: 600;
        border: none;
        cursor: pointer;
        transition: all var(--transition-base);
        display: inline-flex;
        align-items: center;
        gap: 8px;
    }

    #sp_Task_MyWork_html .modal-footer .btn-secondary:hover {
        transform: translateY(-2px);
    }

    #sp_Task_MyWork_html .modal-footer .btn-success:hover {
        transform: translateY(-2px);
        box-shadow: var(--shadow-hover);
    }

    #sp_Task_MyWork_html .empty-state {
        text-align: center;
        padding: 40px 20px;
        color: var(--text-muted);
        grid-column: 1 / -1;
    }

    #sp_Task_MyWork_html .empty-state i {
        font-size: 48px;
        color: var(--border-color);
        margin-bottom: 12px;
        opacity: 0.5;
    }

    /* ===== TEMP SUBTASK FORM RESPONSIVE STYLES ===== */
    #sp_Task_MyWork_html #temp-subtasks {
        width: 100%;
    }

    #sp_Task_MyWork_html #temp-subtasks > div {
        padding: 20px;
        background: var(--bg-light);
        border-radius: 8px;
        border: 1px solid var(--border-color);
    }

    #sp_Task_MyWork_html #temp-subtasks .subtask-header {
        font-weight: 600;
        margin-bottom: 20px;
        color: var(--text-primary);
        display: flex;
        align-items: center;
        gap: 8px;
    }

    #sp_Task_MyWork_html #temp-subtasks .subtask-header i {
        color: var(--task-primary);
        font-size: 18px;
    }

    #sp_Task_MyWork_html .empty-state p {
        margin: 0;
        font-size: 13px;
    }

    @media (max-width: 992px) {
        #sp_Task_MyWork_html .assign-row {
            grid-template-columns: 1fr;
        }
    }

    @media (max-width: 768px) {
        #sp_Task_MyWork_html .assign-container {
            padding: 16px 20px;
            max-height: 70vh;
        }

        #sp_Task_MyWork_html .assign-row {
            grid-template-columns: 1fr;
            gap: 12px;
        }

        #sp_Task_MyWork_html .step-header {
            gap: 12px;
        }

        #sp_Task_MyWork_html .modal-header {
            padding: 12px 16px;
        }

        #sp_Task_MyWork_html .modal-footer {
            padding: 12px 16px;
            flex-direction: column;
        }

        #sp_Task_MyWork_html .modal-footer .btn {
            width: 100%;
            justify-content: center;
        }
    }

    /* Desktop: 2-3 cột */
    @media (min-width: 1024px) {
        #sp_Task_MyWork_html #temp-subtasks > div > div:nth-of-type(1) {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 16px;
            margin-bottom: 20px;
        }

        #sp_Task_MyWork_html #temp-subtasks > div > div:nth-of-type(2) {
            display: grid;
            grid-template-columns: 1fr 1fr 1fr;
            gap: 16px;
            margin-bottom: 20px;
        }

        #sp_Task_MyWork_html #temp-subtasks > div > div:nth-of-type(3) {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 16px;
            margin-bottom: 20px;
        }
    }

    /* Tablet: 1-2 cột */
    @media (max-width: 1023px) and (min-width: 768px) {
        #sp_Task_MyWork_html #temp-subtasks > div > div:nth-of-type(1) {
            display: grid;
            grid-template-columns: 1fr;
            gap: 12px;
            margin-bottom: 16px;
        }

        #sp_Task_MyWork_html #temp-subtasks > div > div:nth-of-type(2) {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 12px;
            margin-bottom: 16px;
        }

        #sp_Task_MyWork_html #temp-subtasks > div > div:nth-of-type(3) {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 12px;
            margin-bottom: 16px;
        }
    }

    /* Mobile: 1 cột */
    @media (max-width: 767px) {
        #sp_Task_MyWork_html #temp-subtasks > div {
            padding: 16px 12px;
        }

        #sp_Task_MyWork_html #temp-subtasks .subtask-header {
            margin-bottom: 16px;
            font-size: 15px;
        }

        #sp_Task_MyWork_html #temp-subtasks .subtask-header i {
            font-size: 16px;
        }

        #sp_Task_MyWork_html #temp-subtasks > div > div:nth-of-type(1),
        #sp_Task_MyWork_html #temp-subtasks > div > div:nth-of-type(2),
        #sp_Task_MyWork_html #temp-subtasks > div > div:nth-of-type(3) {
            display: grid;
            grid-template-columns: 1fr;
            gap: 10px;
            margin-bottom: 12px;
        }

        #sp_Task_MyWork_html #temp-subtasks .form-group {
            margin-bottom: 0;
        }

        #sp_Task_MyWork_html #temp-subtasks .form-label {
            font-size: 12px;
            margin-bottom: 6px;
        }

        #sp_Task_MyWork_html #temp-subtasks .form-control,
        #sp_Task_MyWork_html #temp-subtasks .form-select {
            font-size: 13px;
            padding: 8px 10px;
            min-height: 40px;
        }

        #sp_Task_MyWork_html #temp-subtasks > div > div:last-of-type {
            display: flex;
            flex-direction: column;
            gap: 8px;
            margin-bottom: 0;
        }

        #sp_Task_MyWork_html #temp-subtasks > div > div:last-of-type button {
            width: 100%;
            padding: 12px;
            font-size: 13px;
        }

        #sp_Task_MyWork_html #temp-subtasks small.text-muted {
            font-size: 11px;
        }
    }

    /* Extra small devices (max 480px) */
    @media (max-width: 480px) {
        #sp_Task_MyWork_html #temp-subtasks > div {
            padding: 12px 10px;
        }

        #sp_Task_MyWork_html #temp-subtasks .subtask-header {
            margin-bottom: 12px;
            font-size: 14px;
            gap: 6px;
        }

        #sp_Task_MyWork_html #temp-subtasks .form-label {
            font-size: 11px;
            margin-bottom: 4px;
        }

        #sp_Task_MyWork_html #temp-subtasks .form-control,
        #sp_Task_MyWork_html #temp-subtasks .form-select {
            font-size: 12px;
            padding: 6px 8px;
            min-height: 36px;
        }

        #sp_Task_MyWork_html #temp-subtasks > div > div:last-of-type {
            margin-top: 10px;
        }

        #sp_Task_MyWork_html #temp-subtasks > div > div:last-of-type button {
            padding: 10px;
            font-size: 12px;
        }

        #sp_Task_MyWork_html #temp-subtasks > div > div:last-of-type button i {
            font-size: 12px;
        }
    }
</style>
<div id="sp_Task_MyWork_html">
    <div class="cu-header d-flex justify-content-between align-items-center mb-4 gap-2 flex-wrap">
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
        <div class="header-actions d-flex align-items-center gap-2 flex-wrap">
            <div class="view-switcher">
                <button class="view-btn active" id="viewGrid">
                    <i class="bi bi-table"></i> Grid </button>
                <button class="view-btn" id="viewKanban">
                    <i class="bi bi-kanban"></i> Kanban </button>
            </div>
            <button class="btn-assign" id="btnAssign">
                <i class="bi bi-plus-circle-fill"></i> Giao việc </button>
        </div>
    </div>

    <!-- DevExtreme SuperGrid (Grid View) -->
    <div id="gridMyWork"></div>
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
    <!-- Modal Giao việc -->
    <div class="modal fade" id="mdlAssign" tabindex="-1" aria-labelledby="mdlAssignLabel" aria-hidden="true">
        <div class="modal-dialog modal-dialog-centered modal-lg">
            <div class="modal-content">
                <div class="modal-header">
                    <h5 class="modal-title" id="mdlAssignLabel">
                        <i class="bi bi-person-check-fill"></i> Giao việc
                    </h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                </div>
                <div class="assign-container">
                    <!-- Step 1: Thiết lập chung -->
                    <div class="assign-step">
                        <div class="step-header">
                            <div class="step-number">1</div>
                            <div class="step-title">Thiết lập chung</div>
                        </div>
                        <div class="assign-row">
                            <div class="form-group">
                                <label class="form-label">Công việc chính (Task cha)</label>
                                <div id="P8117471F96C44E2D8886F4484DC46071"></div>
                            </div>
                            <div class="form-group">
                                <label class="form-label">Người yêu cầu</label>
                                <div id="P92FE9B82A6A24C5DB844EB0566E6A3F3"></div>
                            </div>
                            <div class="form-group">
                                <label class="form-label">Người phụ trách chính</label>
                                <div id="PC4F17A30AF044F629C214E4FB871E188"></div>
                            </div>
                            <div class="form-group">
                                <label class="form-label">Ngày yêu cầu</label>
                                <div id="P23DF6626AD7948EEAF6894A9AD476B3C"></div>
                            </div>
                            <div class="form-group">
                                <label class="form-label">Hạn hoàn thành</label>
                                <div id="PF41DAB7E9FCA43409877B4D646C428C5"></div>
                            </div>
                        </div>
                    </div>
                    <!-- Step 2: Phân bổ chi tiết -->
                    <div class="assign-step">
                        <div class="step-header">
                            <div class="step-number">2</div>
                            <div class="step-title">Phân bổ chi tiết (Subtasks)</div>
                            <div style="margin-left:auto; display:flex; gap:8px; align-items:center;">
                                <button class="text-success" style="border: none;" id="P8117471F96C44E2D8886F4484DC46072" title="Thêm task con"><i class="bi bi-plus-lg fs-4"></i></button>
                            </div>
                        </div>
                        <div id="subtask-assign-container" style="overflow-x: auto; display: none;">
                            <div id="gridSubtaskAssign" style="height: 100%;"></div>
                        </div>
                    </div>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Đóng</button>
                <button type="button" class="btn btn-success" id="btnSubmitAssignment">
                        <i class="bi bi-send-fill"></i> Xác nhận
                    </button>
                </div>
            </div>
        </div>
    </div>
</div>
<script>
    (function() {
        "use strict";

        var allTasks = [];
        var currentView = "grid";

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

        attachEventHandlers();

        function openDetailTaskID(taskID) {
            console.log("Open Task Detail for TaskID:", taskID);
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

        function attachEventHandlers() {
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
                $("#gridMyWork").show();
                $("#taskGrid").show();
            });

            $("#viewKanban").on("click", function() {
                //$(".view-btn").removeClass("active");
                // $(this).addClass("active");
                // currentView = "kanban";
                // $("#gridMyWork").hide();
                // $("#taskGrid").hide();
                // if (!$("#kanban-view").length) {
                //     uiManager.showAlert({
                //         type: "info",
                //         message: "Chức năng Kanban chưa được khởi tạo"
                //     });
                // } else {
                //     $("#kanban-view").show();
                //     renderKanbanView(allTasks);
                // }

                uiManager.showAlert({
                   type: "info",
                   message: "Chức năng Kanban chưa được khởi tạo"
                });
            });
        }

            let currentTemplate = [];
            let currentChildTasks = [];
            let tasks = [];
            let selectedParentTaskID = null;
            let lastSelectedParentID = null; // Lưu task cha được chọn lần cuối

            function renderAssignSubtasks() {
                // Map data để phù hợp với Grid columns
                const gridData = currentTemplate.map((item, idx) => ({
                    TaskID: item.TaskID || idx,
                    IsSelected: true, // Default checked
                    TaskName: item.TaskName,
                    AssignedEmployeeIDs: [],
                    StartDate: new Date(),
                    EndDate: new Date(),
                    Priority: 1, // Default: Thấp
                    Note: "",
                    DefaultKPI: item.DefaultKPI || 0,
                    Unit: item.Unit || ""
                }));

                // Load data vào Grid
                window.InstancegridSubtaskAssign.option("dataSource", gridData);
            }

            function fetchAssignTemplate(pid) {
                // Ngăn gọi lại nếu cùng task cha được chọn
                if (lastSelectedParentID === pid) {
                    console.log("[fetchAssignTemplate] Task cha " + pid + " đã được chọn, bỏ qua");
                    return;
                }
                
                lastSelectedParentID = pid;
                selectedParentTaskID = pid;
                
                AjaxHPAParadise({
                        data: {
                        name: "sp_Task_GetDetailedTemplate",
                        param: ["ParentTaskID", pid]
                    },
                    success: function(res) {
                        currentTemplate = JSON.parse(res).data[0] || [];
                        fetchChildTasks(pid, function(childTasks) {
                            currentChildTasks = childTasks || [];
                            
                            // Nếu có task con hoặc template, hiển thị grid
                            if (currentTemplate.length > 0 || childTasks.length > 0) {
                                renderAssignSubtasks();
                                // Hiển thị grid container
                                $("#subtask-assign-container").show();
                                console.log("✓ Grid subtasks đã hiển thị với " + (childTasks.length > 0 ? childTasks.length : "template") + " dữ liệu");
                            } else {
                                // Nếu không có task con và không có template, ẩn grid
                                $("#subtask-assign-container").hide();
                                console.log("Grid subtasks ẩn - không có dữ liệu task con");
                            }
                        });
                    }
                });
            }

            function renderTempSubtasksUI(pid) {
                fetchChildTasks(pid, function(childTasks) {

                    // danh sách TaskID đã là child
                    var existingChildIds = childTasks.map(c => String(c.TaskID));

                    var candidateChilds = tasks.filter(function(t) {
                        return String(t.TaskID) !== String(pid)               // không phải chính nó
                            && !existingChildIds.includes(String(t.TaskID)); // chưa là child
                    });

                    var childOpts =
                        `<option value="">-- Chọn hàng từ danh sách --</option>` +
                        candidateChilds.map(function(t) {
                            return `<option value="${t.TaskID}">${escapeHtml(t.TaskName)}</option>`;
                        }).join("");

                        var html = `
                        <div id="temp-subtasks">
                            <div style="padding: 20px; background: var(--bg-light); border-radius: 8px; border: 1px solid var(--border-color);">
                                <div class="subtask-header" style="margin-bottom: 20px;">
                                    <i class="bi bi-plus-circle" style="color: var(--task-primary); font-size: 18px;"></i>
                                    <span>Thêm hàng con tạm thời</span>
                                </div>
                                
                                <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 16px; margin-bottom: 20px;">
                                    <div class="form-group">
                                        <label class="form-label">Chọn hàng hiện có</label>
                                        <select class="form-select" id="tempChildSelect" onchange="handleSelectTempChild(this.value)">
                                            ${childOpts}
                                        </select>
                                        <small class="text-muted d-block mt-2">Hoặc tạo hàng mới bên dưới</small>
                                    </div>
                                    
                                    <div class="form-group">
                                        <label class="form-label">Tên hàng mới</label>
                                        <input type="text" class="form-control" id="tempTaskName" placeholder="Nhập tên hàng..." />
                                    </div>
                                </div>

                                <div style="display: grid; grid-template-columns: 1fr 1fr 1fr; gap: 16px; margin-bottom: 20px;">
                                    <div class="form-group">
                                        <label class="form-label">Người thực hiện</label>
                                        <div id="tempTaskAssignee"></div>
                                    </div>
                                    
                                    <div class="form-group">
                                        <label class="form-label">Bắt đầu</label>
                                        <input type="datetime-local" class="form-control" id="tempTaskFrom" />
                                    </div>
                                    
                                    <div class="form-group">
                                        <label class="form-label">Kết thúc</label>
                                        <input type="datetime-local" class="form-control" id="tempTaskTo" />
                                    </div>
                                </div>

                                <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 16px; margin-bottom: 20px;">
                                    <div class="form-group">
                                        <label class="form-label">Ưu tiên</label>
                                        <select class="form-select" id="tempTaskPriority">
                                            <option value="1" selected>Cao</option>
                                            <option value="2">Trung bình</option>
                                            <option value="3">Thấp</option>
                                        </select>
                                    </div>
                                    
                                    <div class="form-group">
                                        <label class="form-label">Ghi chú</label>
                                        <input type="text" class="form-control" id="tempTaskNote" placeholder="Ghi chú thêm..." />
                                    </div>
                                </div>

                                <div style="display: flex; gap: 10px; justify-content: flex-end;">
                                    <button type="button" class="btn btn-secondary" onclick="clearTempForm()">
                                        <i class="bi bi-x-circle"></i> Hủy
                                    </button>
                                    <button type="button" class="btn btn-primary" onclick="addTempSubtask(${pid})">
                                        <i class="bi bi-check-circle"></i> Thêm hàng
                                    </button>
                                </div>
                            </div>
                        </div>`;

                    $("#subtask-assign-container").html(html);

                    // Khởi tạo Employee Selector cho temp form
                    setTimeout(() => {
                        // Khởi tạo control Employee Selector
                    }, 100);
                });
            }

            function handleSelectTempChild(taskId) {
                if (taskId) {
                    var selectedTask = tasks.find(t => String(t.TaskID) === String(taskId));
                    if (selectedTask) {
                        $("#tempTaskName").val(escapeHtml(selectedTask.TaskName));
                    }
                }
            }

            function clearTempForm() {
                $("#tempChildSelect").val("");
                $("#tempTaskName").val("");
                $("#tempTaskAssignee").data("selected", []).html("");
                $("#tempTaskFrom").val("");
                $("#tempTaskTo").val("");
                $("#tempTaskNote").val("");
                $("#tempTaskPriority").val("3");
            }

            function addTempSubtask(parentId) {
                var taskName = $("#tempTaskName").val().trim();
                var assigneeIds = ($("#tempTaskAssignee").data("selected") || []).join(",");
                var fromDate = $("#tempTaskFrom").val();
                var toDate = $("#tempTaskTo").val();
                var note = $("#tempTaskNote").val().trim();
                var priority = $("#tempTaskPriority").val();
                var selectedTaskId = $("#tempChildSelect").val();

                if (!taskName && !selectedTaskId) {
                    alert("Vui lòng nhập tên hàng hoặc chọn hàng từ danh sách");
                    return;
                }

                if (selectedTaskId) {
                    taskName = tasks.find(t => String(t.TaskID) === String(selectedTaskId))?.TaskName || taskName;
                }

                console.log("[addTempSubtask] Data:", {
                    parentId: parentId,
                    taskName: taskName,
                    assigneeIds: assigneeIds,
                    fromDate: fromDate,
                    toDate: toDate,
                    note: note,
                    priority: priority,
                    selectedTaskId: selectedTaskId
                });

                // TODO: Gọi API để lưu hàng tạm
                // AjaxHPAParadise({
                //     data: {
                //         name: "sp_Task_CreateTempSubtask",
                //         param: [...]
                //     },
                //     success: function() {
                //         alert("Thêm hàng thành công");
                //         clearTempForm();
                //         // Reload modal
                //     }
                // });
            }

            function fetchChildTasks(pid, cb) {
                AjaxHPAParadise({
                    data: {
                        name: "sp_Task_GetTaskRelations",
                        param: ["ParentTaskID", pid]
                    },
                    success: function(res) {
                        try {
                            var rows = JSON.parse(res).data[0] || [];
                            var ids = rows.map(function(r) { return r.TaskID; });
                            var childTasks = tasks.filter(function(t) { return ids.indexOf(t.TaskID) !== -1; });
                            cb(childTasks);
                        } catch(e) {
                            cb([]);
                        }
                    },
                    error: function() { cb([]); }
              });
            }

            window.onSelectBoxChanged_TaskName = function(value, instance, e) {
                console.log("Selected template TaskID:", value);
                if (value) {
                    fetchAssignTemplate(value);
                }
            };

            // ==================== SUBMIT ASSIGNMENT ====================
            $("#btnSubmitAssignment").off("click").on("click", async function() {
                try {
                    // 1. Get parent task ID from form control P8117471F96C44E2D8886F4484DC46071
                    const parentTaskControl = window.Instance_TaskName;
                    const parentTaskID = parentTaskControl ? parentTaskControl.option("value") : null;
                    
                    if (!parentTaskID) {
                        uiManager.showAlert({ type: "warning", message: "Vui lòng chọn công việc chính" });
                        return;
                    }

                    // 2. Get requester and assignee from form controls
                    const requesterControl = window.Instance_RequestEmployeeID;
                    const assigneeControl = window.Instance_AssigneeEmployeeID;
                    
                    const requesterID = requesterControl ? requesterControl.option("value") : null;
                    const assigneeID = assigneeControl ? assigneeControl.option("value") : null;

                    // 3. Get dates from form controls
                    const requestDateControl = window.Instance_RequestDate;
                    const deadlineControl = window.Instance_DeadlineDate;
                    
                    const requestDate = requestDateControl ? requestDateControl.option("value") : null;
                    const deadlineDate = deadlineControl ? deadlineControl.option("value") : null;

                    // 4. Collect grid data from InstancegridSubtaskAssign
                    let subtasks = [];
                    if (window.InstancegridSubtaskAssign) {
                        try {
                            const gridData = window.InstancegridSubtaskAssign.option("dataSource") || [];
                            subtasks = gridData.map(row => ({
                                ChildTaskName: row.ChildTaskName || "",
                                AssignedEmployeeIDs: row.AssignedEmployeeIDs || "",
                                StartDate: row.StartDate ? new Date(row.StartDate).toISOString() : null,
                                EndDate: row.EndDate ? new Date(row.EndDate).toISOString() : null,
                                Priority: row.Priority || 1,
                                Note: row.Note || ""
                            }));
                            console.log("[Submit] Subtasks to send:", subtasks);
                        } catch (gridErr) {
                            console.warn("[Submit] Error collecting grid data:", gridErr);
                            subtasks = [];
                        }
                    }

                    // 5. Prepare payload
                    const payload = {
                        ParentTaskID: parentTaskID,
                        RequesterEmployeeID: requesterID,
                        AssigneeEmployeeID: assigneeID,
                        RequestDate: requestDate,
                        DeadlineDate: deadlineDate,
                        Subtasks: subtasks,
                        LoginID: LoginID,
                        LanguageID: LanguageID
                    };

                    console.log("[Submit] Full assignment payload:", JSON.stringify(payload, null, 2));

                    // 6. Send to API
                    AjaxHPAParadise({
                        data: {
                            name: "sp_Task_AssignSubtasks", // Change to your actual API name
                            param: [
                                "ParentTaskID", payload.ParentTaskID,
                                "RequesterEmployeeID", payload.RequesterEmployeeID || null,
                                "AssigneeEmployeeID", payload.AssigneeEmployeeID || null,
                                "RequestDate", payload.RequestDate || null,
                                "DeadlineDate", payload.DeadlineDate || null,
                                "SubtasksJSON", JSON.stringify(payload.Subtasks),
                                "LoginID", LoginID,
                                "LanguageID", LanguageID
                            ]
                        },
                        success: function(res) {
                            const json = typeof res === "string" ? JSON.parse(res) : res;
                            const errors = json.data?.[json.data.length - 1] || [];
                            
                            if (errors.length > 0 && errors[0].Status === "ERROR") {
                                uiManager.showAlert({ 
                                    type: "error", 
                                    message: errors[0].Message || "Giao việc thất bại"
                                });
                            } else {
                                uiManager.showAlert({ 
                                    type: "success", 
                                    message: "Giao việc thành công"
                                });
                                // Close modal after success
                                $("#mdlAssign").modal("hide");
                                // Reload task list
                                ReloadData();
                            }
                        },
                        error: function(err) {
                            console.error("[Submit] API Error:", err);
                            uiManager.showAlert({ 
                                type: "error", 
                                message: "Có lỗi khi giao việc: " + (err.statusText || "Unknown error")
                            });
                        }
                    });
                } catch (err) {
                    console.error("[Submit] Unexpected error:", err);
                    uiManager.showAlert({ 
                        type: "error", 
                        message: "Có lỗi bất ngờ: " + err.message
                    });
                }
            });

            // Gắn event modal một lần duy nhất khi trang load
            var modalInitialized = false;
            
            $("#mdlAssign").off("shown.bs.modal").on("shown.bs.modal", function() {
                if (modalInitialized) {
                    return; // Nếu đã khởi tạo, không khởi tạo lại
                }
                
                modalInitialized = true;
                console.log("✓ Modal được mở, khởi tạo event handlers");
                
                // Xóa event cũ của selectbox Task cha trước khi gắn mới
                $(document).off("change.parentTaskSelect", "#P8117471F96C44E2D8886F4484DC46071 input, #P8117471F96C44E2D8886F4484DC46071 select");
                
                // Gắn event change cho Task cha
                $(document).on("change.parentTaskSelect", "#P8117471F96C44E2D8886F4484DC46071 input, #P8117471F96C44E2D8886F4484DC46071 select", function() {
                    var selectedValue = $(this).val() || $("#P8117471F96C44E2D8886F4484DC46071").data("selected");
                    if (selectedValue) {
                        console.log("[Modal] Parent Task selected:", selectedValue);
                        fetchAssignTemplate(selectedValue);
                    }
                });
            });
            
            // Reset flag khi modal đóng để cho phép khởi tạo lại nếu cần
            $("#mdlAssign").off("hidden.bs.modal").on("hidden.bs.modal", function() {
                modalInitialized = false;
                lastSelectedParentID = null; // Reset task cha được chọn
                // Xóa event change khi modal đóng
                $(document).off("change.parentTaskSelect");
                console.log("✓ Modal đã đóng, reset flag");
            });

            function escapeHtml(str) {
                if (!str) return "";
                return String(str)
                    .replace(/&/g, "&amp;")
                    .replace(/</g, "&lt;")
                    .replace(/>/g, "&gt;")
                    .replace(/""/g, "&quot;")
                    .replace(/"/g, "&#039;");
            }

        let DataSource = []
        '
        +(select loadUI from tblCommonControlType_Signed where UID = 'P547D4239B38445CEB3E2550006434E45')
        +(select loadUI from tblCommonControlType_Signed where UID = 'PA07A58E6AC22406BBC0B8FA698E2EC60')
        +(select loadUI from tblCommonControlType_Signed where UID = 'P8117471F96C44E2D8886F4484DC46071')
        +(select loadUI from tblCommonControlType_Signed where UID = 'P92FE9B82A6A24C5DB844EB0566E6A3F3')
        +(select loadUI from tblCommonControlType_Signed where UID = 'PC4F17A30AF044F629C214E4FB871E188')
        +(select loadUI from tblCommonControlType_Signed where UID = 'P23DF6626AD7948EEAF6894A9AD476B3C')
        +(select loadUI from tblCommonControlType_Signed where UID = 'PF41DAB7E9FCA43409877B4D646C428C5') +N'

        let currentRecordID_HeaderID; let currentRecordID_HistoryID; let currentRecordID_TaskID;

        function ReloadData() {
            AjaxHPAParadise({
                data: {
                    name: "sp_Task_GetMyTasks",
                    param: []
                },
                success: function (res) {
                    const json = typeof res === "string" ? JSON.parse(res) : res;

                    // Chuẩn hóa: results LUÔN là array
                    const results = Array.isArray(json?.data?.[0])
                        ? json.data[0]
                        : (json?.data?.[0] ? [json.data[0]] : []);

                        const obj = results[0] || null;

                        currentRecordID_HeaderID = obj.HeaderID || currentRecordID_HeaderID; currentRecordID_HistoryID = obj.HistoryID || currentRecordID_HistoryID; currentRecordID_TaskID = obj.TaskID || currentRecordID_TaskID;

                        DataSource = results;

                        InstancegridMyWork.option("dataSource", results);
                        '
                        +(select loadData from tblCommonControlType_Signed where UID = 'P547D4239B38445CEB3E2550006434E45')
                        +(select loadData from tblCommonControlType_Signed where UID = 'PA07A58E6AC22406BBC0B8FA698E2EC60')
                        +(select loadData from tblCommonControlType_Signed where UID = 'P8117471F96C44E2D8886F4484DC46071')
                        +(select loadData from tblCommonControlType_Signed where UID = 'P92FE9B82A6A24C5DB844EB0566E6A3F3')
                        +(select loadData from tblCommonControlType_Signed where UID = 'PC4F17A30AF044F629C214E4FB871E188')
                        +(select loadData from tblCommonControlType_Signed where UID = 'P23DF6626AD7948EEAF6894A9AD476B3C')
                        +(select loadData from tblCommonControlType_Signed where UID = 'PF41DAB7E9FCA43409877B4D646C428C5') +N'
                    }
                }
            })
        }
        sp_Task_MyWork_html.ReloadData = ReloadData
        ReloadData()
  })();
</script>
';
SELECT @html AS html;
END
GO
EXEC sp_GenerateHTMLScript 'sp_Task_MyWork_html'
