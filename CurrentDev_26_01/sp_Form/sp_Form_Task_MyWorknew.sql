USE Paradise_Dev
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

    .dx-popup-content-scrollable {
        overflow: hidden
    }

    /* === BASE LAYOUT === */
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

    /* === STATS ROW === */
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
        content: '';
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

    /* === BUTTONS & SWITCHER === */
    #sp_Task_MyWork_html .btn-refresh,
    #sp_Task_MyWork_html .btn-assign,
    #sp_Task_MyWork_html .view-btn {
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
    #sp_Task_MyWork_html .btn-assign {
        background: var(--task-primary);
        color: white;
        border: none;
    }
    #sp_Task_MyWork_html .btn-refresh:hover {
        border-color: var(--task-primary);
        color: var(--task-primary);
        transform: translateY(-2px);
        box-shadow: var(--shadow-sm);
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
        background: transparent;
        border: none;
    }
    #sp_Task_MyWork_html .view-btn:hover:not(.active) {
        opacity: 0.8;
    }
    #sp_Task_MyWork_html .view-btn.active {
        background: var(--task-primary);
        color: white;
        box-shadow: var(--shadow-sm);
    }

    /* === EMPTY STATE === */
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

    /* === BADGES & ICONS === */
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

    /* === PROGRESS BAR === */
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
        content: '';
        position: absolute;
        top: 0;
        left: 0;
        right: 0;
        bottom: 0;
        background: linear-gradient(90deg, transparent, rgba(255, 255, 255, 0.3), transparent);
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

    /* === AVATARS & TASK CELLS === */
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

    /* === DATE & ACTION === */
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

    /* === TABLE & KANBAN === */
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

    /* === MODAL: GIAO VIỆC === */
    #sp_Task_MyWork_html .modal {
        z-index: 1055 !important;
        overflow: hidden;
    }
    #sp_Task_MyWork_html .modal.fade.show {
        display: flex !important;
        align-items: center;
        justify-content: center;
    }
    #sp_Task_MyWork_html .modal-dialog {
        max-width: 1000px;
        margin: 0 auto !important;
        max-height: 80vh;
        pointer-events: auto;
        -webkit-user-drag: none;
        user-drag: none;
    }
    #sp_Task_MyWork_html .modal-content {
        position: relative;
        max-height: 80vh;
        width: 1000px;
        overflow-y: auto;
        border-radius: 12px;
    }
    #sp_Task_MyWork_html .modal-backdrop {
        background-color: rgba(0, 0, 0, 0.7) !important;
        backdrop-filter: blur(8px);
        -webkit-backdrop-filter: blur(8px);
        z-index: 1050 !important;
    }
    #sp_Task_MyWork_html .modal-backdrop.show {
        opacity: 0.7 !important;
    }
    #sp_Task_MyWork_html .modal-header {
        z-Index: 10;
        position: sticky;
        top: 0;
        left: 0;
        right: 0;
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

    /* === ASSIGN FORM === */
    #sp_Task_MyWork_html .assign-container {
        padding: 24px 32px;
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

    /* === TEMP SUBTASK FORM === */
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
    #sp_Task_MyWork_html #temp-subtasks small.text-muted {
        font-size: 11px;
    }

    /* === FILTER BUTTONS === */
    #sp_Task_MyWork_html .filter-button-group {
        display: flex;
        gap: 10px;
        flex-wrap: wrap;
        align-items: center;
    }
    #sp_Task_MyWork_html .filter-btn {
        padding: 10px 16px;
        border-radius: 8px;
        border: 1.5px solid var(--border-color);
        background: white;
        cursor: pointer;
        transition: all var(--transition-base);
        font-weight: 600;
        font-size: 13px;
        display: inline-flex;
        align-items: center;
        gap: 6px;
        white-space: nowrap;
    }
    #sp_Task_MyWork_html .filter-btn:hover {
        border-color: var(--task-primary);
        color: var(--task-primary);
        transform: translateY(-2px);
        box-shadow: var(--shadow-sm);
    }
    #sp_Task_MyWork_html .filter-btn.active {
        background: var(--task-primary);
        color: white;
        border-color: var(--task-primary);
        box-shadow: var(--shadow-hover);
    }
    #sp_Task_MyWork_html .filter-btn.active:hover {
        background: var(--task-primary-hover);
        border-color: var(--task-primary-hover);
    }

    /* === RESPONSIVE === */
    @media (max-width: 1200px) {
        #sp_Task_MyWork_html .kanban-board {
            grid-template-columns: 1fr;
        }
    }
    @media (max-width: 992px) {
        #sp_Task_MyWork_html .assign-row {
            grid-template-columns: 1fr;
        }
    }
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
        #sp_Task_MyWork_html .kanban-board,
        #sp_Task_MyWork_html .kanban-column {
            gap: 12px;
            min-height: 300px;
        }
        #sp_Task_MyWork_html .assign-container {
            padding: 16px 20px;
        }
        #sp_Task_MyWork_html .assign-row {
            grid-template-columns: 1fr;
            gap: 12px;
        }
        #sp_Task_MyWork_html .step-header {
            gap: 12px;
        }
        #sp_Task_MyWork_html .modal-header,
        #sp_Task_MyWork_html .modal-footer {
            padding: 12px 16px;
        }
        #sp_Task_MyWork_html .modal-footer {
            flex-direction: column;
        }
        #sp_Task_MyWork_html .modal-footer .btn {
            width: 100%;
            justify-content: center;
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
        #sp_Task_MyWork_html .header-actions,
        #sp_Task_MyWork_html .view-switcher,
        #sp_Task_MyWork_html .btn-assign,
        #sp_Task_MyWork_html .btn-refresh {
            width: 100%;
            flex-direction: column;
            justify-content: center;
            padding: 12px;
            font-size: 13px;
        }
        #sp_Task_MyWork_html .stats-row {
            display: none !important;
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
        #sp_Task_MyWork_html #temp-subtasks > div > div:last-of-type button {
            padding: 10px;
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
            <div class="filter-button-group">
                <button class="filter-btn active" id="filterAll" data-filter="all">
                    <i class="bi bi-funnel"></i> Tất cả
                </button>
                <button class="filter-btn" id="filterTodo" data-filter="todo">
                    <i class="bi bi-circle-fill" style="font-size: 10px; color: #42526e;"></i> Chưa làm
                </button>
                <button class="filter-btn" id="filterDoing" data-filter="doing">
                    <i class="bi bi-circle-fill" style="font-size: 10px; color: #0747a6;"></i> Đang làm
                </button>
                <button class="filter-btn" id="filterOverdue" data-filter="overdue">
                    <i class="bi bi-exclamation-circle-fill" style="color: #e53935;"></i> Quá hạn
                </button>
            </div>
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
    <div class="modal fade" id="mdlAssign" tabindex="-1" aria-labelledby="mdlAssignLabel">
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
                                <div id="P777C87EE29F94C29A6EAABD16E31FDDC"></div>
                            </div>
                            <div class="form-group">
                                <label class="form-label">Người yêu cầu</label>
                                <div id="P2920410F91DB42948640CF1ABBDEE649"></div>
                            </div>
        <div class="form-group">
                                <label class="form-label">Người phụ trách chính</label>
                                <div id="PC98E2DFA331343BBAE22882BE3825C1A"></div>
                            </div>
                            <div class="form-group">
                                <label class="form-label">Ngày yêu cầu</label>
                                <div id="P02E6F18645BA47648567B32773A1B7B4"></div>
                            </div>
                            <div class="form-group">
                                <label class="form-label">Hạn hoàn thành</label>
                                <div id="P27C40759D9C94453AB9B2DFBCD661AE3"></div>
                            </div>
                        </div>
                    </div>
                    <!-- Step 2: Phân bổ chi tiết -->
                    <div class="assign-step" id="subtask-assign-step" style="display: none;">
                        <div class="step-header">
                            <div class="step-number">2</div>
                            <div class="step-title">Phân bổ chi tiết (Subtasks)</div>
                            <div style="margin-left:auto; display:flex; gap:8px; align-items:center;">
                                <button class="text-success" style="border: none;" id="P8117471F96C44E2D8886F4484DC46072" title="Thêm task con"><i class="bi bi-plus-lg fs-4"></i></button>
                            </div>
                        </div>
                        <div id="subtask-assign-container">
                            <div class="empty-state" id="emptySubtaskAssign">
                                <i class="bi bi-arrow-up-circle"></i>
                                <p>Vui lòng chọn Công việc chính ở trên</p>
                            </div>
                            <div id="gridSubtaskAssign" style="height: 100%; display: none;"></div>
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
        var modalInitialized = false;
        var currentFilter = "all"; // Lưu filter hiện tại

        let currentTemplate = [];
        let currentChildTasks = [];
        let tasks = [];
        let selectedParentTaskID = null;
        let lastSelectedParentID = null; // Lưu task cha được chọn lần cuối

        // Khai báo datasource cho trạng thái và độ ưu tiên cho control
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

        function openDetailTaskID(taskID) {
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
            // Event handler cho filter buttons
            $(".filter-btn").on("click", function() {
                $(".filter-btn").removeClass("active");
                $(this).addClass("active");
                const filterType = $(this).data("filter");
                applyFilter(filterType);
            });

            // Event handler cho search input - lưu vào localStorage
            setTimeout(function() {
                const gridInstance = InstancegridMyWorkPDB2DB35885F14803A9A52961A7871972;
                if (gridInstance) {
                    gridInstance.on("optionChanged", function(e) {
                        if (e.name === "searchPanel") {
                            const searchText = gridInstance.option("searchPanel.text") || "";
                            saveSearchState(searchText);
                        }
                    });
                }
            }, 500);

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
                uiManager.showAlert({
                   type: "info",
                   message: "Chức năng Kanban chưa được khởi tạo"
                });
            });

            window.onSelectBoxChanged_TaskName = function(value, instance, e) {
                if (value) {
                    $("#subtask-assign-step").show();
                    // Reset grid before loading new data
                    const gridInstance = InstancegridSubtaskAssignP870C076FA1FD48DDBDEDE2C2435B4DA9;
                    if (gridInstance) {
                        gridInstance.option("dataSource", []);
                    }
                    fetchAssignTemplate(value);
                } else {
                    $("#subtask-assign-step").hide();
                }
            };

            // Nút thêm task con mới (Manual entry)
            $("#P8117471F96C44E2D8886F4484DC46072").off("click").on("click", function() {
                const gridInstance = InstancegridSubtaskAssignP870C076FA1FD48DDBDEDE2C2435B4DA9;
                if (gridInstance) {
                    const ds = gridInstance.option("dataSource") || [];
                    ds.push({
                        TaskID: 0,
                        IsSelected: true,
                        TaskName: "",
                        AssignedEmployeeIDs: [],
                        StartDate: new Date(),
                        EndDate: new Date(),
                        Priority: 1,
                        Note: ""
                    });
                    gridInstance.option("dataSource", ds);
                    gridInstance.repaint();
                }
            });

            // Nút xác nhận giao việc
            $("#btnSubmitAssignment").off("click").on("click", async function() {
                try {
                    const parentTaskID = InstanceTaskNameP777C87EE29F94C29A6EAABD16E31FDDC ? InstanceTaskNameP777C87EE29F94C29A6EAABD16E31FDDC.option("value") : null;
                    if (!parentTaskID) {
                        uiManager.showAlert({ type: "warning", message: "Vui lòng chọn công việc chính" });
                        return;
                    }

                    const requesterID = InstancePersonInChargeP2920410F91DB42948640CF1ABBDEE649 ? InstancePersonInChargeP2920410F91DB42948640CF1ABBDEE649.option("value") : null;
                    const assigneeID = InstanceMainPersonInChargePC98E2DFA331343BBAE22882BE3825C1A ? InstanceMainPersonInChargePC98E2DFA331343BBAE22882BE3825C1A.option("value") : null;
                    const requestDate = InstanceStartDateP02E6F18645BA47648567B32773A1B7B4 ? InstanceStartDateP02E6F18645BA47648567B32773A1B7B4.option("value") : null;
                    const committedHours = InstanceCommittedHoursP27C40759D9C94453AB9B2DFBCD661AE3 ? InstanceCommittedHoursP27C40759D9C94453AB9B2DFBCD661AE3.option("value") : null;

                    let subtasks = [];
                    const gridInstance = InstancegridSubtaskAssignP870C076FA1FD48DDBDEDE2C2435B4DA9;
                    if (gridInstance) {
                        const gridData = gridInstance.option("dataSource") || [];
                        subtasks = gridData.filter(r => r.IsSelected).map(row => ({
                            TaskID: row.TaskID || 0,
                            TaskName: row.TaskName || "",
                            AssignedEmployeeIDs: Array.isArray(row.AssignedEmployeeIDs) ? row.AssignedEmployeeIDs.join(",") : (row.AssignedEmployeeIDs || ""),
                            StartDate: row.StartDate ? new Date(row.StartDate).toISOString() : null,
                            EndDate: row.EndDate ? new Date(row.EndDate).toISOString() : null,
                            Priority: row.Priority || 1,
                            Note: row.Note || ""
                        }));
                    }

                    AjaxHPAParadise({
                        data: {
                            name: "sp_Task_AssignSubtasks",
                            param: [
                                "ParentTaskID", parentTaskID,
                                "RequesterEmployeeID", requesterID || null,
                                "AssigneeEmployeeID", assigneeID || null,
                                "RequestDate", requestDate || null,
                                "CommittedHours", committedHours || null,
                                "SubtasksJSON", JSON.stringify(subtasks),
                                "LoginID", LoginID,
                                "LanguageID", LanguageID
                            ]
                        },
                        success: function(res) {
                            const json = typeof res === "string" ? JSON.parse(res) : res;
                            const errors = json.data?.[json.data.length - 1] || [];
                            if (errors.length > 0 && errors[0].Status === "ERROR") {
                                uiManager.showAlert({ type: "error", message: errors[0].Message || "Giao việc thất bại" });
                            } else {
                                uiManager.showAlert({ type: "success", message: "Giao việc thành công" });
                                $("#mdlAssign").modal("hide");
                                ReloadData();
                            }
                        }
                    });
                } catch (err) {
                    console.error(err);
                    uiManager.showAlert({ type: "error", message: "Có lỗi: " + err.message });
                }
            });
        }

        function renderAssignSubtasks() {
            // Combine template and existing child tasks
            const uniqueTasks = [];
            const taskIds = new Set();

            [...currentTemplate, ...currentChildTasks].forEach(t => {
                const id = t.TaskID || 0;
                if (id === 0 || !taskIds.has(id)) {
                    uniqueTasks.push(t);
                    if (id !== 0) taskIds.add(id);
                }
            });

            const gridData = uniqueTasks.map((item, idx) => ({
                TaskID: item.TaskID || 0,
                IsSelected: true,
                TaskName: item.TaskName,
                AssignedEmployeeIDs: item.AssignedEmployeeIDs ? (Array.isArray(item.AssignedEmployeeIDs) ? item.AssignedEmployeeIDs : item.AssignedEmployeeIDs.split(",")) : [],
                StartDate: item.StartDate || new Date(),
                EndDate: item.EndDate || new Date(),
                Priority: item.Priority || 1,
                Note: item.Note || "",
                DefaultKPI: item.DefaultKPI || 0,
                Unit: item.Unit || ""
            }));

            const gridInstance = InstancegridSubtaskAssignP870C076FA1FD48DDBDEDE2C2435B4DA9;
            if (gridInstance) {
                gridInstance.option("dataSource", gridData);
            }
        }

        function fetchAssignTemplate(pid) {
            if (lastSelectedParentID === pid) return;
            lastSelectedParentID = pid;
            selectedParentTaskID = pid;

            // Fetch template first
            AjaxHPAParadise({
                data: {
                    name: "sp_Task_GetDetailedTemplate",
                    param: ["ParentTaskID", pid]
                },
                success: function(res) {
                    const json = typeof res === "string" ? JSON.parse(res) : res;
                    currentTemplate = json.data[0] || [];
                    
                    // Then fetch existing child tasks to supplement
                    fetchChildTasks(pid, function(childTasks) {
                        currentChildTasks = childTasks || [];
                        
                        // Combine or show unique set
                        if (currentTemplate.length > 0 || currentChildTasks.length > 0) {
                            renderAssignSubtasks();
                            $("#gridSubtaskAssign").show();
                            $("#emptySubtaskAssign").hide();
                        } else {
                            $("#gridSubtaskAssign").hide();
                            $("#emptySubtaskAssign").show();
                        }
                    });
                }
            });
        }

        function fetchChildTasks(pid, cb) {
            AjaxHPAParadise({
                data: {
                    name: "sp_Task_GetTaskRelations",
                    param: ["ParentTaskID", pid]
                },
                success: function(res) {
                    try {
                        const json = typeof res === "string" ? JSON.parse(res) : res;
                        const rows = json.data[0] || [];
                        cb(rows);
                    } catch(e) {
                        cb([]);
                    }
                },
                error: function() { cb([]); }
            });
        }

        // Phần xử lý control
        let DataSource = []

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

        // ValidationEngine utility for validation messages
        window.ValidationEngine = window.ValidationEngine || {};
        window.ValidationEngine.getRequiredMessage = function(displayName) {
            return "không được để trống " + (displayName || "trường này");
        };

        '
        +(select loadUI from tblCommonControlType_Signed where UID = 'PDB2DB35885F14803A9A52961A7871972')
        +(select loadUI from tblCommonControlType_Signed where UID = 'P870C076FA1FD48DDBDEDE2C2435B4DA9')
        +(select loadUI from tblCommonControlType_Signed where UID = 'P777C87EE29F94C29A6EAABD16E31FDDC')
        +(select loadUI from tblCommonControlType_Signed where UID = 'P2920410F91DB42948640CF1ABBDEE649')
        +(select loadUI from tblCommonControlType_Signed where UID = 'PC98E2DFA331343BBAE22882BE3825C1A')
        +(select loadUI from tblCommonControlType_Signed where UID = 'P02E6F18645BA47648567B32773A1B7B4')
        +(select loadUI from tblCommonControlType_Signed where UID = 'P27C40759D9C94453AB9B2DFBCD661AE3') +N'
        window.currentRecordID_HeaderID = null; window.currentRecordID_HistoryID = null; window.currentRecordID_TaskID = null;

        // =============== GRID COLUMN CONFIG PERSISTENCE ===============
        function saveGridColumnConfig(gridId, columns) {
            const menuId = getActiveMenuId();
            if (!menuId) {
                console.warn("Không lấy được menuId");
                return;
            }

            if (!gridId) {
                console.warn("gridId không hợp lệ");
                return;
            }

            const visibleColumns = columns
                .filter(col =>
                    col.visible !== false &&
                    col.dataField &&
                    col.dataField !== "rowIndex" &&
                    typeof col.dataField === "string"
                )
                .map(col => col.dataField);

            const columnOrder = columns
                .filter(col =>
                    col.dataField &&
                    col.dataField !== "rowIndex" &&
                    typeof col.dataField === "string"
                )
                .map(col => col.dataField);

            const config = { visibleColumns, columnOrder };

            console.log("[SaveConfig]", {
                menuId,
                gridId,
                config
            });

            AjaxHPAParadise({
                data: {
                    name: "sp_SaveGridColumnConfig",
                    param: [
                        "LoginID", LoginID,
                        "MenuID", menuId,
                        "GridID", gridId,
                        "ColumnConfigJson", JSON.stringify(config)
                    ]
                }
            });
        }

        function getActiveMenuId() {
            const activeTab = $(".nav-link.active");
            const tabId = activeTab.filter("button").attr("id");
            return tabId ? tabId.split("-").pop() : null;
        }

        function loadGridColumnConfig(gridId, callback) {
            const menuId = getActiveMenuId();
            if (!menuId) {
                console.warn("Không lấy được menuId");
                if (typeof callback === "function") callback({});
                return;
            }

            AjaxHPAParadise({
                data: {
                    name: "sp_GetGridColumnConfig",
                    param: [
                        "LoginID", LoginID,
                        "MenuID", menuId,
                        "GridID", gridId
                    ]
                },
                async: false,
                success: function (res) {
                    let config = {};

                    const json = typeof res === "string" ? JSON.parse(res) : res;

                    if (
                        json &&
                        json.data &&
                        json.data[0] &&
                        json.data[0][0] &&
                        json.data[0][0].ColumnConfigJson
                    ) {
                        const raw = json.data[0][0].ColumnConfigJson;
                        config = typeof raw === "string" ? JSON.parse(raw) : raw;
                    }

                    if (typeof callback === "function") {
                        callback(config);
                    }
                }
            });
        }

        // =============== FILTER STATE - LOCALSTORAGE ONLY ===============
        function saveGridFilterState(tableName, gridInstance) {
            try {
                const filterValue = gridInstance.getCombinedFilter();
                const searchValue = gridInstance.option("searchPanel.text") || "";

                // Lấy filter của từng cột
                const columnFilters = {};
                const columns = gridInstance.option("columns");

                columns.forEach(col => {
                    if (col.dataField && col.filterValue !== undefined) {
                        columnFilters[col.dataField] = {
                            filterValue: col.filterValue,
                            filterType: col.filterType || "include",
                            selectedFilterOperation: col.selectedFilterOperation
                        };
                    }
                });

                const filterState = {
                    combinedFilter: filterValue,
                    searchText: searchValue,
                    columnFilters: columnFilters,
                    timestamp: new Date().getTime()
                };

                // CHỈ LƯU VÀO LOCALSTORAGE
                localStorage.setItem("GridFilter_" + tableName + "_" + LoginID, JSON.stringify(filterState));
            } catch(e) {
                console.error("[SaveFilterState] Error:", e);
            }
        }

        function loadGridFilterState(tableName, gridInstance) {
            try {
                const storageKey = "GridFilter_" + tableName + "_" + LoginID;
                const savedState = localStorage.getItem(storageKey);

                if (!savedState) {
                    return null;
                }

                const filterState = JSON.parse(savedState);

                return filterState;
            } catch(e) {
                console.error("[LoadFilterState] Error:", e);
                return null;
            }
        }

        function applyGridFilterState(gridInstance, filterState) {

            if (!filterState) return;

            try {
                gridInstance.beginUpdate();

                // 1. Apply search text
                if (filterState.searchText) {
                    gridInstance.option("searchPanel.text", filterState.searchText);
                }

                // 2. Apply column filters
                if (filterState.columnFilters) {
                    Object.keys(filterState.columnFilters).forEach(dataField => {
                        const colFilter = filterState.columnFilters[dataField];
                        const colIndex = gridInstance.columnOption(dataField, "index");

                        if (colIndex !== undefined) {
                            gridInstance.columnOption(dataField, "filterValue", colFilter.filterValue);
                            if (colFilter.filterType) {
                                gridInstance.columnOption(dataField, "filterType", colFilter.filterType);
                            }
                            if (colFilter.selectedFilterOperation) {
                                gridInstance.columnOption(dataField, "selectedFilterOperation", colFilter.selectedFilterOperation);
                            }
                        }
                    });
                }

                // 3. Apply combined filter (fallback)
                if (filterState.combinedFilter && !filterState.columnFilters) {
                    gridInstance.option("filterValue", filterState.combinedFilter);
                }

                gridInstance.endUpdate();

            } catch(e) {
                console.error("[ApplyFilterState] Error:", e);
            }
        }

        function clearGridFilterState(tableName) {
            try {
                const storageKey = "GridFilter_" + tableName + "_" + LoginID;
                localStorage.removeItem(storageKey);
            } catch(e) {
                console.error("[ClearFilterState] Error:", e);
            }
        }

        // =============== ROW ORDER PERSISTENCE ===============
        function saveGridRowOrder(gridInstance, tableName, pkColumn) {
            const dataSource = gridInstance.option("dataSource");
            const rowOrderArray = dataSource.map(item => item[pkColumn]);

            AjaxHPAParadise({
                data: {
                    name: "sp_SaveGridRowOrder",
                    param: [
                        "LoginID", LoginID,
                        "TableName", tableName,
                        "RowOrderJson", JSON.stringify(rowOrderArray)
                    ]
                },
                success: function(res) {},
                error: function(err) {
                    console.error("[SaveRowOrder] Error:", err);
                }
            });
        }

        function loadGridRowOrder(tableName, dataSource, pkColumn, callback) {
            AjaxHPAParadise({
                data: {
                    name: "sp_GetGridRowOrder",
                    param: ["LoginID", LoginID, "TableName", tableName]
                },
                async: false,
                success: function(res) {
                    try {
                        const json = typeof res === "string" ? JSON.parse(res) : res;
                        const rowOrderJson = json.data[0][0].RowOrderJson;

                        if (rowOrderJson && rowOrderJson !== "[]") {
                            const savedOrder = JSON.parse(rowOrderJson);

                            const dataMap = {};
                            dataSource.forEach(item => {
                                dataMap[item[pkColumn]] = item;
                            });

         const sortedData = [];
                            savedOrder.forEach(id => {
                                if (dataMap[id]) {
                                    sortedData.push(dataMap[id]);
                          delete dataMap[id];
                                }
                            });

              Object.values(dataMap).forEach(item => {
                                sortedData.push(item);
                            });

                            if (typeof callback === "function") {
                                callback(sortedData);
                            }
                        } else {
                            if (typeof callback === "function") {
                                callback(dataSource);
                            }
                        }
                    } catch (e) {
                        if (typeof callback === "function") {
                            callback(dataSource);
                        }
                    }
                },
                error: function(err) {
                    console.error("[LoadRowOrder] Error:", err);
                    if (typeof callback === "function") {
                        callback(dataSource);
                    }
                }
            });
        }

        // =============== MYWORK FILTER STATE PERSISTENCE ===============
        function saveFilterState(filterType) {
            try {
                localStorage.setItem("MyWork_Filter_" + LoginID, filterType);
            } catch (e) {
                console.error("[SaveFilterState] Error:", e);
            }
        }

        function loadFilterState() {
            try {
                const saved = localStorage.getItem("MyWork_Filter_" + LoginID);
                if (saved) {
                    return saved;
                }
            } catch (e) {
                console.error("[LoadFilterState] Error:", e);
            }
            return "all";
        }

        function applyFilter(filterType) {
            currentFilter = filterType;
            const gridInstance = InstancegridMyWorkPDB2DB35885F14803A9A52961A7871972;

            if (!gridInstance) return;

            let filteredData = allTasks;

            if (filterType === "todo") {
                filteredData = allTasks.filter(task => task.Status === 1);
            } else if (filterType === "doing") {
                filteredData = allTasks.filter(task => task.Status === 2);
            } else if (filterType === "overdue") {
                // Filter tasks that are overdue (có deadline < hôm nay và status !== 3 (Done))
                const today = new Date();
                today.setHours(0, 0, 0, 0);
                filteredData = allTasks.filter(task => {
                    if (task.Status === 3) return false; // Exclude done tasks
                    const deadlineDate = new Date(task.DeadlineDate);
                    return deadlineDate < today;
                });
            }
            // else filterType === "all" -> show all tasks

            gridInstance.option("dataSource", filteredData);

            // Lưu filter vào localStorage
            saveFilterState(filterType);
        }

        function restoreFilterState() {
            const savedFilter = loadFilterState();
            currentFilter = savedFilter;

            // Cập nhật UI button
            $(".filter-btn").removeClass("active");
            $(`.filter-btn[data-filter="${savedFilter}"]`).addClass("active");

            // Áp dụng filter
            applyFilter(savedFilter);
        }

        function ReloadData() {
            AjaxHPAParadise({
                data: {
                    name: "sp_Task_GetMyTasks",
                    param: []
                },
                success: function (res) {
                    const json = typeof res === "string" ? JSON.parse(res) : res;
                    const results = Array.isArray(json?.data?.[0])
                        ? json.data[0]
                        : (json?.data?.[0] ? [json.data[0]] : []);

                    const obj = results.length === 1 ? results[0] : (results[0] || null);

                    const gridInstancegridMyWork = InstancegridMyWorkPDB2DB35885F14803A9A52961A7871972;
                    const gridConfiggridMyWork = getGridConfig_gridMyWork(results);

                    loadGridRowOrder(
                        "sp_Task_MyWork_html",
                        results,
                        "TaskID",
                        function(sortedData) {
                            // Clear search panel khi reload
                            gridInstancegridMyWork.option("searchPanel.text", "");

                            gridInstancegridMyWork.beginUpdate();
                            gridInstancegridMyWork.option("scrolling", {
                                mode: "standard",
                                showScrollbar: "onHover"
                            });
                            gridInstancegridMyWork.option("remoteOperations", false);
                            gridInstancegridMyWork.option("paging.enabled", true);
                            gridInstancegridMyWork.option("paging.pageSize", gridConfiggridMyWork.pageSize);
                            gridInstancegridMyWork.option("pager.allowedPageSizes", gridConfiggridMyWork.allowedPageSizes);
                            gridInstancegridMyWork.pageIndex(0);
                            gridInstancegridMyWork.option("dataSource", sortedData);
                            gridInstancegridMyWork.endUpdate();

                            // RESTORE FILTER STATE T? LOCALSTORAGE (n?u không skip)
                            setTimeout(function() {
                                if (window._SkipRestoreFilter) {
                                    window._SkipRestoreFilter = false;
                                    return;
                                }
                                const savedFilter = loadGridFilterState("sp_Task_MyWork_html", gridInstancegridMyWork);
                                if (savedFilter) {
                                    applyGridFilterState(gridInstancegridMyWork, savedFilter);
                        }
                            }, 100);
                        }
                    );

                    const gridInstancegridSubtaskAssign = InstancegridSubtaskAssignP870C076FA1FD48DDBDEDE2C2435B4DA9;
                    const gridConfiggridSubtaskAssign = getGridConfig_gridSubtaskAssign(results);

                    loadGridRowOrder(
                        "sp_Task_MyWork_html",
                        results,
                        "TaskID",
                        function(sortedData) {
                            // Clear search panel khi reload
                            gridInstancegridSubtaskAssign.option("searchPanel.text", "");

                            gridInstancegridSubtaskAssign.beginUpdate();
                            gridInstancegridSubtaskAssign.option("scrolling", {
                                mode: "standard",
                                showScrollbar: "onHover"
                            });
                            gridInstancegridSubtaskAssign.option("remoteOperations", false);
                            gridInstancegridSubtaskAssign.option("paging.enabled", true);
                            gridInstancegridSubtaskAssign.option("paging.pageSize", gridConfiggridSubtaskAssign.pageSize);
                            gridInstancegridSubtaskAssign.option("pager.allowedPageSizes", gridConfiggridSubtaskAssign.allowedPageSizes);
                            gridInstancegridSubtaskAssign.pageIndex(0);
                            gridInstancegridSubtaskAssign.option("dataSource", []);
                            gridInstancegridSubtaskAssign.endUpdate();

                            // RESTORE FILTER STATE T? LOCALSTORAGE (n?u không skip)
                            setTimeout(function() {
                                if (window._SkipRestoreFilter) {
                                    window._SkipRestoreFilter = false;
                                    return;
                                }
                                const savedFilter = loadGridFilterState("sp_Task_MyWork_html", gridInstancegridSubtaskAssign);
                                if (savedFilter) {
                                    applyGridFilterState(gridInstancegridSubtaskAssign, savedFilter);
                                }
                            }, 100);
                        }
                    );

                    if (obj) { window.currentRecordID_HeaderID = (obj.HeaderID !== undefined && obj.HeaderID !== null) ? obj.HeaderID : window.currentRecordID_HeaderID; } if (obj) { window.currentRecordID_HistoryID = (obj.HistoryID !== undefined && obj.HistoryID !== null) ? obj.HistoryID : window.currentRecordID_HistoryID; } if (obj) { window.currentRecordID_TaskID = (obj.TaskID !== undefined && obj.TaskID !== null) ? obj.TaskID : window.currentRecordID_TaskID; }
                    DataSource = results;
                    allTasks = results;

                    // Restore filter và search sau khi set allTasks
                    if(restoreFilterState){
                        restoreFilterState();
                    }
                    '
                    +(select loadData from tblCommonControlType_Signed where UID = 'PDB2DB35885F14803A9A52961A7871972')
                    +(select loadData from tblCommonControlType_Signed where UID = 'P870C076FA1FD48DDBDEDE2C2435B4DA9')
                    +(select loadData from tblCommonControlType_Signed where UID = 'P777C87EE29F94C29A6EAABD16E31FDDC')
                    +(select loadData from tblCommonControlType_Signed where UID = 'P2920410F91DB42948640CF1ABBDEE649')
                    +(select loadData from tblCommonControlType_Signed where UID = 'PC98E2DFA331343BBAE22882BE3825C1A')
                    +(select loadData from tblCommonControlType_Signed where UID = 'P02E6F18645BA47648567B32773A1B7B4')
                    +(select loadData from tblCommonControlType_Signed where UID = 'P27C40759D9C94453AB9B2DFBCD661AE3') +N'
                }
            })
        }
        ReloadData()
        attachEventHandlers();
    })();
</script>
';
SELECT @html AS html;
END
GO