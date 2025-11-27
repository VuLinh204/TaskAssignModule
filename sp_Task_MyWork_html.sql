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
            --radius-sm: 6px;
            --radius-md: 8px;
            --radius-lg: 12px;
            --radius-xl: 16px;
        }
        /* Header */
        #sp_Task_MyWork_html .cu-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 20px;
            gap: 16px;
            flex-wrap: wrap;
        }
        #sp_Task_MyWork_html .h-title {
            margin: 0;
            font-weight: 700;
            font-size: clamp(20px, 5vw, 28px);
            display: flex;
            align-items: center;
            gap: 12px;
        }
        #sp_Task_MyWork_html .h-title i {
            color: var(--task-primary);
            font-size: 1.2em;
        }
        #sp_Task_MyWork_html .header-actions {
            display: flex;
            gap: 12px;
            align-items: center;
            flex-wrap: wrap;
        }
        /* Compact Stats Row: small, tidy cards with icons and reduced padding */
        #sp_Task_MyWork_html .stats-row {
            display: flex;
            gap: 10px;
            margin-bottom: 12px;
            align-items: center;
            flex-wrap: wrap;
        }
        #sp_Task_MyWork_html .stats-row .stat-card {
            padding: 8px 12px;
            border-radius: 10px;
            min-width: 110px;
            display: flex;
            align-items: center;
            gap: 10px;
            box-shadow: 0 1px 4px rgba(0,0,0,0.04);
            border: 1px solid rgba(0,0,0,0.04);
        }
        #sp_Task_MyWork_html .stats-row .stat-card .stat-label {
            font-size: 11px;
            font-weight: 700;
            text-transform: none;
            margin: 0;
            margin-left: 10px;
            white-space: nowrap;
        }
        #sp_Task_MyWork_html .stats-row .stat-card .stat-value {
            font-size: 16px;
            font-weight: 800;
            margin-left: auto;
        }
        /* smaller colored accent bar for compact cards */
        #sp_Task_MyWork_html .stats-row .stat-card::before {
            width: 8px;
            left: 8px;
            top: calc(50% - 8px);
            height: 16px;
            transform: none;
            border-radius: 4px;
        }
        #sp_Task_MyWork_html .stats-row .stat-card.doing::before {
            background: var(--sts-doing);
        }
        #sp_Task_MyWork_html .stats-row .stat-card.todo::before {
            background: var(--sts-todo);
        }
        #sp_Task_MyWork_html .stats-row .stat-card.done::before {
            background: var(--sts-done);
        }
        #sp_Task_MyWork_html .stats-row .stat-card.overdue::before {
            background: var(--danger-color);
        }
        #sp_Task_MyWork_html .stat-card {
            border-radius: var(--radius-lg);
            padding: 20px;
            border: 1px solid var(--border-color);
            transition: all var(--transition-base);
            position: relative;
            overflow: hidden;
        }
        #sp_Task_MyWork_html .stat-card::before {
            content: """";
            position: absolute;
            top: 0;
            left: 0;
            width: 4px;
            height: 100%;
            transform: scaleY(0);
            transition: transform var(--transition-base);
        }
        #sp_Task_MyWork_html .stat-card:hover {
            box-shadow: var(--shadow-md);
            transform: translateY(-4px);
        }
        #sp_Task_MyWork_html .stat-card:hover::before {
            transform: scaleY(1);
        }
        #sp_Task_MyWork_html .stat-label {
            font-size: 12px;
            font-weight: 600;
            margin-bottom: 8px;
            text-transform: uppercase;
            letter-spacing: 0.5px;
        }
        #sp_Task_MyWork_html .stat-value {
            font-size: 36px;
            font-weight: 700;
            line-height: 1;
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
        /* Filters */
        #sp_Task_MyWork_html .filter-section {
            padding: 16px;
            border-radius: var(--radius-lg);
            margin-bottom: 20px;
            border: 1px solid var(--border-color);
            display: flex;
            gap: 12px;
            align-items: center;
            flex-wrap: wrap;
            box-shadow: var(--shadow-sm);
        }
        #sp_Task_MyWork_html .filter-section select {
            padding: 8px 12px;
            border: 1.5px solid var(--border-color);
            border-radius: var(--radius-md);
            font-size: 14px;
            cursor: pointer;
            transition: all var(--transition-base);
            min-width: 180px;
        }
        #sp_Task_MyWork_html .filter-section select:hover {
            border-color: var(--task-primary);
        }
        #sp_Task_MyWork_html .filter-section select:focus {
            border-color: var(--task-primary);
            outline: none;
            box-shadow: 0 0 0 3px rgba(46, 125, 50, 0.1);
        }
        /* View Switcher */
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
            border-radius: var(--radius-sm);
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
        /* Kanban Board */
        #sp_Task_MyWork_html .kanban-board {
            display: grid;
            grid-template-columns: repeat(3, 1fr);
            gap: 20px;
        }
        #sp_Task_MyWork_html .kanban-column {
            border-radius: var(--radius-lg);
            padding: 16px;
            min-height: 500px;
            border: 1px solid var(--border-color);
            box-shadow: var(--shadow-sm);
        }
        #sp_Task_MyWork_html .kanban-board .cu-row {
            margin-bottom: 12px;
            border-radius: var(--radius-md);
            border: 1px solid var(--border-color);
            max-height: none;
        }

        #sp_Task_MyWork_html .kanban-board .cu-row:hover {
            box-shadow: var(--shadow-md);
            transform: translateY(-2px);
            border-color: var(--task-primary);
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
      border-radius: var(--radius-lg);
            font-size: 12px;
            font-weight: 700;
            color: var(--text-secondary);
            min-width: 28px;
            text-align: center;
        }
        /* Task Row (List + Card) */
        #sp_Task_MyWork_html .cu-list {
            border: 1px solid var(--border-color);
            border-radius: var(--radius-lg);
            overflow: hidden;
            box-shadow: var(--shadow-sm);
        }
        #sp_Task_MyWork_html .cu-row {
            display: flex;
            align-items: center;
            padding: 16px 20px;
            border-bottom: 1px solid var(--bg-lighter);
            transition: all var(--transition-base);
            cursor: pointer;
            gap: 2px;
            max-height: 110px;
        }
        /* Make temp-subtask rows visually consistent with other cu-rows */
        #sp_Task_MyWork_html .temp-subtask {
            display: flex;
            align-items: center;
            padding: 16px 20px;
            border-bottom: 1px solid var(--bg-lighter);
            transition: all var(--transition-base);
            cursor: default;
            gap: 12px;
            background: var(--bg-white);
        }
        #sp_Task_MyWork_html .temp-subtask:hover {
            border-color: var(--task-primary);
            box-shadow: var(--shadow-md);
        }
        #sp_Task_MyWork_html .row-check {
            width: 40px;
            display: flex;
            align-items: center;
            justify-content: center;
            flex-shrink: 0;
            gap: 4px;
            position: relative;
        }

        #sp_Task_MyWork_html .row-check .row-drag-handle {
            position: absolute;
            left: -15px;
        }

        #sp_Task_MyWork_html .row-check .priority-icon {
            margin-left: 0;
        }
        #sp_Task_MyWork_html .row-main {
            flex: 1;
            min-width: 0;
        }
        #sp_Task_MyWork_html .row-progress {
            width: 220px;
            flex-shrink: 0;
        }
        #sp_Task_MyWork_html .row-status {
            width: 130px;
            text-align: center;
            flex-shrink: 0;
        }
        /* header row no longer shows row-meta; keep space minimal if needed */
        #sp_Task_MyWork_html .row-meta {
            display: none;
        }
        #sp_Task_MyWork_html .task-title {
            font-size: 15px;
            font-weight: 600;
            display: -webkit-box;
            -webkit-line-clamp: 2;
            -webkit-box-orient: vertical;
            overflow: hidden;
            text-overflow: ellipsis;
        }
        #sp_Task_MyWork_html .task-sub {
            font-size: 13px;
            color: var(--text-muted);
            display: -webkit-box;
            -webkit-line-clamp: 1;
            -webkit-box-orient: vertical;
            overflow: hidden;
            text-overflow: ellipsis;
            gap: 12px;
            align-items: center;
        }
        /* Priority Icon */
        #sp_Task_MyWork_html .priority-icon {
            font-size: 16px;
            transition: transform var(--transition-base);
        }
        #sp_Task_MyWork_html .cu-row:hover .priority-icon {
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
        /* KPI Progress */
        #sp_Task_MyWork_html .kpi-bar-bg {
            height: 8px;
            background: var(--bg-lighter);
            border-radius: 4px;
            overflow: hidden;
            width: 100%;
            margin-top: 6px;
            position: relative;
        }
        #sp_Task_MyWork_html .kpi-bar-fill {
            height: 100%;
            background: linear-gradient(90deg, var(--task-primary), var(--task-primary-hover));
            transition: width 0.6s cubic-bezier(0.4, 0, 0.2, 1);
            border-radius: 4px;
            position: relative;
            overflow: hidden;
        }
        #sp_Task_MyWork_html .kpi-bar-fill::after {
            content: """";
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
        #sp_Task_MyWork_html .kpi-text {
            font-size: 13px;
            display: flex;
            justify-content: space-between;
            font-weight: 600;
            gap: 5px;
        }
        /* Status Badge */
        #sp_Task_MyWork_html .badge-sts {
            padding: 6px 14px;
            border-radius: var(--radius-md);
            font-size: 12px;
            font-weight: 700;
            text-transform: uppercase;
            display: inline-block;
            transition: all var(--transition-base);
            cursor: pointer;
            letter-spacing: 0.3px;
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
        /* Date Display */
        #sp_Task_MyWork_html .date-range {
            font-size: 12px;
            color: var(--text-secondary);
            background: var(--bg-lighter);
            padding: 4px 10px;
            border-radius: var(--radius-sm);
            width: fit-content;
            margin-left: auto;
            font-weight: 600;
            display: inline-flex;
            align-items: center;
            gap: 4px;
        }
        #sp_Task_MyWork_html .overdue {
            color: var(--danger-color);
            background: #ffebee;
            animation: pulse 2s infinite;
        }
        @keyframes pulse {
            0%, 100% { opacity: 1; }
            50% { opacity: 0.7; }
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
        /* Buttons */
        #sp_Task_MyWork_html .btn-refresh {
            border: 1.5px solid var(--border-color);
            padding: 10px 16px;
            border-radius: var(--radius-md);
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
            border-radius: var(--radius-md);
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
        /* Task Detail Modal */
        #sp_Task_MyWork_html .task-detail-modal .modal-dialog {
            max-width: 900px;
        }
        #sp_Task_MyWork_html .task-detail-modal .modal-content {
            border: none;
            border-radius: var(--radius-xl);
            box-shadow: var(--shadow-lg);
            overflow: hidden;
            width: 100% !important;
        }
        #sp_Task_MyWork_html .assign-modal .modal-content {
            border: none;
            border-radius: var(--radius-xl);
            box-shadow: var(--shadow-lg);
            overflow: hidden;
            width: 100% !important;
        }

        #sp_Task_MyWork_html .task-detail-header {
            padding: 32px 40px 24px;
            border-bottom: 1px solid var(--bg-lighter);
        }
        #sp_Task_MyWork_html .task-detail-title {
            font-size: 24px;
            font-weight: 700;
            margin-bottom: 16px;
            line-height: 1.3;
        }
        #sp_Task_MyWork_html .task-detail-meta {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
            gap: 16px;
            font-size: 14px;
        }
        #sp_Task_MyWork_html .meta-row {
            display: flex;
            align-items: center;
            gap: 12px;
        }
        #sp_Task_MyWork_html .meta-label {
            font-weight: 600;
            min-width: 120px;
        }
        #sp_Task_MyWork_html .meta-value {
            font-weight: 500;
        }
        #sp_Task_MyWork_html .task-detail-body {
            padding: 24px 40px;
            max-height: 70vh;
            overflow: auto;
        }
        /* KPI Section */
        #sp_Task_MyWork_html .kpi-section {
            background: linear-gradient(135deg, #f8f9ff 0%, #ffffff 100%);
            border: 2px solid var(--task-primary);
            border-radius: var(--radius-lg);
            padding: 24px;
            margin-bottom: 24px;
            box-shadow: var(--shadow-md);
        }
        #sp_Task_MyWork_html .kpi-display {
            display: flex;
           justify-content: space-between;
            align-items: center;
            margin-bottom: 16px;
            gap: 24px;
        }
        #sp_Task_MyWork_html .kpi-current {
            font-size: 48px;
            font-weight: 700;
            color: var(--task-primary);
            line-height: 1;
        }
        #sp_Task_MyWork_html .kpi-target {
            font-size: 14px;
            color: var(--text-secondary);
            margin-top: 8px;
        }
        #sp_Task_MyWork_html .kpi-target strong {
            color: var(--text-primary);
        }
        #sp_Task_MyWork_html .kpi-progress-bar {
            height: 12px;
            background: var(--bg-lighter);
            border-radius: var(--radius-sm);
            overflow: hidden;
            margin-bottom: 16px;
            position: relative;
        }
        #sp_Task_MyWork_html .kpi-progress-fill {
            height: 100%;
            background: linear-gradient(90deg, var(--task-primary), var(--task-primary-hover));
            transition: width 0.6s cubic-bezier(0.4, 0, 0.2, 1);
        }
        #sp_Task_MyWork_html .kpi-input-group {
            display: flex;
            gap: 12px;
        }
        #sp_Task_MyWork_html .kpi-input-group input {
            flex: 1;
            padding: 12px;
            border: 2px solid var(--border-color);
            border-radius: var(--radius-md);
            font-size: 16px;
            font-weight: 600;
            transition: all var(--transition-base);
        }
        #sp_Task_MyWork_html .kpi-input-group input:focus {
            border-color: var(--task-primary);
            outline: none;
            box-shadow: 0 0 0 3px rgba(46, 125, 50, 0.1);
        }
        #sp_Task_MyWork_html .kpi-input-group button {
            padding: 12px 24px;
            background: var(--task-primary);
            color: white;
            border: none;
            border-radius: var(--radius-md);
            font-weight: 600;
            cursor: pointer;

            transition: all var(--transition-base);
            white-space: nowrap;
            display: flex;
            align-items: center;
            gap: 8px;
        }
        #sp_Task_MyWork_html .kpi-input-group button:hover {
            background: var(--task-primary-hover);
            transform: translateY(-2px);
            box-shadow: var(--shadow-hover);
        }
        /* Comments Section */
        #sp_Task_MyWork_html .comments-section {
            margin-top: 24px;
            border-radius: var(--radius-lg);
            padding: 24px;
        }
        #sp_Task_MyWork_html .section-title {
            font-size: 16px;
            font-weight: 700;
            margin-bottom: 16px;
            display: flex;
            align-items: center;
            gap: 8px;
        }
        #sp_Task_MyWork_html .comment-item {
            padding: 12px;
            background: var(--bg-light);
            border-radius: var(--radius-md);
            margin-bottom: 8px;
            border: 1px solid var(--border-color);
            transition: all var(--transition-base);
        }
        #sp_Task_MyWork_html .comment-item:hover {
            box-shadow: var(--shadow-sm);
            transform: translateX(4px);
        }
        #sp_Task_MyWork_html .comment-header {
            display: flex;
            justify-content: space-between;
            margin-bottom: 8px;
        }
        #sp_Task_MyWork_html .comment-author {
            font-weight: 600;
            font-size: 13px;
            color: var(--text-primary);
        }
        #sp_Task_MyWork_html .comment-date {
            font-size: 12px;
            color: var(--text-secondary);
        }
        #sp_Task_MyWork_html .comment-content {
            font-size: 14px;
            color: var(--text-primary);
            line-height: 1.6;
        }
        /* Assign Modal */
        #sp_Task_MyWork_html .assign-modal .modal-dialog {
            max-width: 1200px;
        }
        #sp_Task_MyWork_html .assign-container {
            padding: 32px;
        }
        #sp_Task_MyWork_html .assign-step {
            margin-bottom: 32px;
        }
        #sp_Task_MyWork_html .step-header {
            display: flex;
            align-items: center;
            gap: 12px;
            margin-bottom: 16px;
        }
        #sp_Task_MyWork_html .step-number {
            width: 36px;
            height: 36px;
            background: var(--task-primary);
            color: white;
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            font-weight: 700;
            font-size: 16px;
            flex-shrink: 0;
        }
        #sp_Task_MyWork_html .step-title {
            font-size: 18px;
            font-weight: 700;
        }
        #sp_Task_MyWork_html .assign-row {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(1fr, 1fr));
            gap: 16px;
        }
        #sp_Task_MyWork_html .subtask-horizontal {
            background: var(--bg-white);
            border: 2px solid var(--border-color);
            border-radius: var(--radius-lg);
            padding: 16px;
            transition: all var(--transition-base);
        }
        #sp_Task_MyWork_html .subtask-horizontal:hover {
            border-color: var(--task-primary);
            box-shadow: var(--shadow-md);
            transform: translateY(-2px);
        }
        #sp_Task_MyWork_html .subtask-name {
            font-weight: 600;
            font-size: 14px;
            margin-bottom: 12px;
            color: var(--text-primary);
            display: -webkit-box;
            -webkit-line-clamp: 1;
            -webkit-box-orient: vertical;
            overflow: hidden;
            text-overflow: ellipsis;
        }
        #sp_Task_MyWork_html .form-group {
            margin-bottom: 12px;
        }
        #sp_Task_MyWork_html .form-label {
            font-size: 12px;
            font-weight: 600;
            margin-bottom: 4px;
            display: block;
        }
        #sp_Task_MyWork_html .form-control,
        #sp_Task_MyWork_html .form-select {
            width: 100%;
            padding: 8px 12px;
            border: 1.5px solid var(--border-color);
            border-radius: var(--radius-sm);
            font-size: 13px;
            transition: all var(--transition-base);
        }
        #sp_Task_MyWork_html .form-control:focus,
        #sp_Task_MyWork_html .form-select:focus {
            border-color: var(--task-primary);
            outline: none;
            box-shadow: 0 0 0 3px rgba(46, 125, 50, 0.1);
        }
        /* Searchable select: consistent sizing and responsive dropdown */
        #sp_Task_MyWork_html .search-select { display: inline-block; vertical-align: middle; }
        #sp_Task_MyWork_html .search-select input.form-control {  width: 320px; min-width:180px; max-width: 100%; height: 40px; padding-right: 12px; }
        #sp_Task_MyWork_html .search-select .search-select-dropdown {  box-sizing: border-box; width: 320px; min-width: 180px; max-width: 100%; border-radius:6px; overflow:auto; backdrop-filter: blur(50px); -webkit-backdrop-filter: blur(50px); }
        #sp_Task_MyWork_html .st-user-dropdown { backdrop-filter: blur(50px); -webkit-backdrop-filter: blur(50px); }
        #sp_Task_MyWork_html .search-select .search-item { padding:8px 12px; cursor:pointer; position:relative; }
        /* Multi-select item visuals */
        #sp_Task_MyWork_html .st-user-dropdown .st-multi-item { position:relative; }
        #sp_Task_MyWork_html .st-user-dropdown .st-multi-item.selected { background: var(--task-primary); color: white; font-weight:700; }
        #sp_Task_MyWork_html .st-user-dropdown .st-multi-item.selected::after {
            content: "\2713"; /* checkmark */
            position: absolute;
            right: 12px;
            top: 50%;
            transform: translateY(-50%);
            color: white;
            font-weight: 700;
        }
        #sp_Task_MyWork_html .search-select .form-select.d-none { display:none !important; }
        #sp_Task_MyWork_html .search-select input.form-control.search-valid { border-color: var(--success-color); box-shadow: 0 0 0 3px rgba(0,200,117,0.08); }
        #sp_Task_MyWork_html .search-select input.form-control.search-invalid { border-color: var(--danger-color); box-shadow: 0 0 0 3px rgba(229,57,53,0.06); }

        /* Selected small icons inside search input (overlapping like Trello) */
        #sp_Task_MyWork_html .search-select { position:relative; }
        #sp_Task_MyWork_html .search-select .st-user-filter { padding-right:110px; }
        #sp_Task_MyWork_html .selected-icons { position:absolute; right:8px; top:50%; transform:translateY(-50%); display:flex; align-items:center; }
        #sp_Task_MyWork_html .icon-chip { width:28px; height:28px; border-radius:50%; background:#f1f5f9; display:flex; align-items:center; justify-content:center; font-size:12px; color:var(--text-primary); border:2px solid #fff; box-shadow:0 1px 0 rgba(0,0,0,0.04); margin-left:-8px; overflow:hidden; }
        #sp_Task_MyWork_html .icon-chip:first-child { margin-left:0; }
        #sp_Task_MyWork_html .icon-more { width:28px; height:28px; border-radius:50%; background:#e6edf3; display:flex; align-items:center; justify-content:center; font-size:12px; color:var(--text-primary); border:2px solid #fff; margin-left:-8px; }
        @media (max-width: 992px) {
            #sp_Task_MyWork_html .search-select input.form-control,
            #sp_Task_MyWork_html .search-select .search-select-dropdown { width: 100%; }
            #sp_Task_MyWork_html .assign-row { grid-template-columns: 1fr; }
        }
        /* Responsive */
        @media (max-width: 1200px) {
            #sp_Task_MyWork_html .kanban-board {
                grid-template-columns: repeat(2, 1fr);
            }
        }
        /* Mobile responsive */
        @media (max-width: 768px) {
            #sp_Task_MyWork_html {
                padding: 12px;
            }

            #sp_Task_MyWork_html .cu-row {
                flex-wrap: wrap;
                padding: 12px;
            }

            #sp_Task_MyWork_html .row-check {
                width: 100%;
                justify-content: flex-start;
                margin-bottom: 8px;
            }

            #sp_Task_MyWork_html .row-main {
                width: 100%;
                margin-bottom: 8px;
            }

            #sp_Task_MyWork_html .row-kpi,
            #sp_Task_MyWork_html .row-status,
            #sp_Task_MyWork_html .row-meta {
                width: 100%;
            }

            #sp_Task_MyWork_html .row-drag-handle {
                position: static;
                margin-right: 8px;
            }

            /* Kanban cards stacking */
            #sp_Task_MyWork_html .kanban-board .cu-row {
                flex-direction: column;
                align-items: flex-start;
            }
        }

        /* Modal Backdrop - Overlay tối */
        .modal-backdrop {
            background-color: rgba(0, 0, 0, 0.7) !important;
            backdrop-filter: blur(8px);
            -webkit-backdrop-filter: blur(8px);
        }

        .modal-backdrop.show {
            opacity: 0.7 !important;
        }

        /* Đảm bảo modal hiển thị đúng z-index */
        #sp_Task_MyWork_html .modal {
            z-index: 1055 !important;
        }

        #sp_Task_MyWork_html .modal-backdrop {
            z-index: 1050 !important;
        }

        /* Status Badge - Không bị block bởi parent click */
        #sp_Task_MyWork_html .badge-toggle-status {
position: relative;
            z-index: 10;
            pointer-events: auto;
        }

        /* Priority Select - Không bị block */
        #sp_Task_MyWork_html .subtask-priority,
        #sp_Task_MyWork_html .st-priority {
            position: relative;
            z-index: 10;
            pointer-events: auto;
        }

        /* Task Detail Modal - Larger and Better */
        #sp_Task_MyWork_html .task-detail-modal .modal-dialog {
            max-width: 1000px;
        }

        /* Attachments Section */
        #sp_Task_MyWork_html .attachments-section {
            margin-top: 24px;
            border-radius: var(--radius-lg);
            padding: 24px;
            border: 1px solid var(--border-color);
        }

        #sp_Task_MyWork_html .attachment-item {
            display: flex;
            align-items: center;
            gap: 12px;
            padding: 12px;
            background: var(--bg-light);
            border-radius: var(--radius-md);
            margin-bottom: 8px;
            border: 1px solid var(--border-color);
            transition: all var(--transition-base);
        }

        #sp_Task_MyWork_html .attachment-item:hover {
            box-shadow: var(--shadow-sm);
            transform: translateX(4px);
            border-color: var(--task-primary);
        }

        #sp_Task_MyWork_html .attachment-icon {
            width: 40px;
            height: 40px;
            display: flex;
            align-items: center;
            justify-content: center;
            background: var(--task-primary);
            color: white;
            border-radius: var(--radius-md);
            font-size: 18px;
        }

        #sp_Task_MyWork_html .attachment-info {
            flex: 1;
            min-width: 0;
        }

        #sp_Task_MyWork_html .attachment-name {
            font-weight: 600;
            font-size: 14px;
            color: var(--text-primary);
            white-space: nowrap;
            overflow: hidden;
            text-overflow: ellipsis;
        }

        #sp_Task_MyWork_html .attachment-meta {
            font-size: 12px;
            color: var(--text-muted);
        }

        #sp_Task_MyWork_html .attachment-actions {
            display: flex;
            gap: 8px;
        }

        #sp_Task_MyWork_html .btn-attachment {
            padding: 6px 12px;
            border-radius: var(--radius-sm);
            border: 1px solid var(--border-color);
            background: white;
            cursor: pointer;
            transition: all var(--transition-base);
            font-size: 13px;
        }

        #sp_Task_MyWork_html .btn-attachment:hover {
            background: var(--task-primary);
            color: white;
            border-color: var(--task-primary);
        }

        #sp_Task_MyWork_html .btn-attachment.delete:hover {
            background: var(--danger-color);
            border-color: var(--danger-color);
        }

        #sp_Task_MyWork_html .upload-area {
            border: 2px dashed var(--border-color);
            border-radius: var(--radius-lg);
            padding: 24px;
            text-align: center;
            cursor: pointer;
            transition: all var(--transition-base);
            margin-top: 16px;
        }

        #sp_Task_MyWork_html .upload-area:hover {
            border-color: var(--task-primary);
            background: var(--bg-lighter);
        }

        #sp_Task_MyWork_html .upload-area.dragging {
            border-color: var(--task-primary);
            background: rgba(46, 125, 50, 0.05);
        }

        /* Status Selector in Detail */
        #sp_Task_MyWork_html .status-selector {
            display: flex;
            gap: 12px;
            padding: 16px;
            border-radius: var(--radius-lg);
            margin-bottom: 24px;
        }

        #sp_Task_MyWork_html .status-option {
            flex: 1;
            padding: 12px;
            border-radius: var(--radius-md);
            border: 2px solid var(--border-color);
            text-align: center;
            cursor: pointer;
            transition: all var(--transition-base);
            font-weight: 600;
        }

        #sp_Task_MyWork_html .status-option:hover {
            transform: translateY(-2px);
       box-shadow: var(--shadow-sm);
        }

        #sp_Task_MyWork_html .status-option.active {
            border-color: var(--task-primary);
            background: var(--task-primary);
            color: white;
        }

        #sp_Task_MyWork_html .status-option.sts-1 { border-color: var(--sts-todo-text); }
        #sp_Task_MyWork_html .status-option.sts-1.active { background: var(--sts-todo); color: var(--sts-todo-text); }

        #sp_Task_MyWork_html .status-option.sts-2 { border-color: var(--sts-doing-text); }
        #sp_Task_MyWork_html .status-option.sts-2.active { background: var(--sts-doing); color: var(--sts-doing-text); }

        #sp_Task_MyWork_html .status-option.sts-3 { border-color: var(--sts-done-text); }
        #sp_Task_MyWork_html .status-option.sts-3.active { background: var(--sts-done); color: var(--sts-done-text); }

        /* Description Section */
        #sp_Task_MyWork_html .description-section {
            margin-top: 24px;
            border-radius: var(--radius-lg);
            padding: 24px;
            border: 1px solid var(--border-color);
        }

        #sp_Task_MyWork_html .description-content {
            min-height: 100px;
            padding: 12px;
            border: 1px solid var(--border-color);
            border-radius: var(--radius-md);
            word-wrap: break-word;
        }

        #sp_Task_MyWork_html .description-edit {
            width: 100%;
            min-height: 120px;
            padding: 12px;
            border: 1.5px solid var(--border-color);
            border-radius: var(--radius-md);
            resize: vertical;
            font-family: inherit;
        }

        #sp_Task_MyWork_html .description-edit:focus {
            border-color: var(--task-primary);
            outline: none;
            box-shadow: 0 0 0 3px rgba(46, 125, 50, 0.1);
        }

        /* Subtask Table in Detail Modal */
        #sp_Task_MyWork_html .subtask-table {
            width: 100%;
            border-collapse: collapse;
            margin-top: 16px;
            background: var(--bg-white);
            border: 1px solid var(--border-color);
            border-radius: var(--radius-md);
            overflow: hidden;
        }
        #sp_Task_MyWork_html .subtask-table th,
        #sp_Task_MyWork_html .subtask-table td {
            padding: 12px;
            text-align: left;
            border: 1px solid var(--bg-lighter);
        }
        #sp_Task_MyWork_html .subtask-table th {
            background: var(--bg-lighter);
            font-weight: 600;
            color: var(--text-secondary);
        }
        #sp_Task_MyWork_html .subtask-table tr:nth-child(even) {
            background: var(--bg-light);
        }
        #sp_Task_MyWork_html .subtask-table .progress-cell {
            width: 120px;
        }
        #sp_Task_MyWork_html .subtask-table .status-cell {
            width: 100px;
        }
        #sp_Task_MyWork_html .subtask-table .priority-cell {
            width: 80px;
        }
        #sp_Task_MyWork_html .subtask-table .assignee-cell {
            width: 150px;
        }
        #sp_Task_MyWork_html .subtask-table .date-cell {
            width: 120px;
        }
        #sp_Task_MyWork_html .subtask-table .badge-sts {
            padding: 4px 8px;
            font-size: 11px;
            font-weight: 600;
            text-transform: uppercase;
            display: inline-block;
            border-radius: var(--radius-sm);
        }
    #sp_Task_MyWork_html .subtask-table .badge-sts.sts-1 {
            background: var(--sts-todo);
            color: var(--sts-todo-text);
        }
        #sp_Task_MyWork_html .subtask-table .badge-sts.sts-2 {
            background: var(--sts-doing);
            color: var(--sts-doing-text);
        }
        #sp_Task_MyWork_html .subtask-table .badge-sts.sts-3 {
            background: var(--sts-done);
            color: var(--sts-done-text);
        }
        #sp_Task_MyWork_html .subtask-table .progress-bar-bg {
            height: 6px;
            background: var(--bg-lighter);
            border-radius: 3px;
            overflow: hidden;
            margin-top: 4px;
        }
        #sp_Task_MyWork_html .subtask-table .progress-bar-fill {
            height: 100%;
            background: linear-gradient(90deg, var(--task-primary), var(--task-primary-hover));
            border-radius: 3px;
        }

        /* Header Row Styles */
        #sp_Task_MyWork_html .header-row {
            background: linear-gradient(135deg, var(--task-primary) 0%, var(--task-primary-light) 100%);
            color: white;
            font-weight: 700;
            cursor: pointer;
            position: relative;
        }

        #sp_Task_MyWork_html .header-row:hover {
            background: linear-gradient(135deg, var(--task-primary) 0%, var(--task-primary-light) 100%);
            box-shadow: var(--shadow-lg);
        }

        #sp_Task_MyWork_html .header-row .expand-icon {
            transition: transform 0.3s ease;
            font-size: 18px;
            margin-right: 8px;
        }

        #sp_Task_MyWork_html .header-row.expanded .expand-icon {
            transform: rotate(90deg);
        }

        #sp_Task_MyWork_html .header-badge {
            background: rgba(255, 255, 255, 0.2);
            padding: 4px 12px;
            border-radius: 12px;
            font-size: 12px;
            margin-left: 8px;
        }

        #sp_Task_MyWork_html .header-meta {
            display: flex;
            gap: 16px;
            align-items: center;
            font-size: 13px;
        }

        #sp_Task_MyWork_html .header-progress {
            background: rgba(255, 255, 255, 0.2);
            padding: 6px 14px;
            border-radius: 16px;
            font-weight: 600;
        }

        /* Subtask Container */
        #sp_Task_MyWork_html .subtask-container {
            display: none;
        }

        #sp_Task_MyWork_html .subtask-container.show {
            display: block;
            animation: slideDown 0.3s ease;
        }

        @keyframes slideDown {
            from {
                opacity: 0;
                transform: translateY(-10px);
            }
            to {
                opacity: 1;
                transform: translateY(0);
            }
        }

        #sp_Task_MyWork_html .subtask-row {
            padding-left: 30px;
        }

        #sp_Task_MyWork_html .subtask-row:hover {
            border-left-color: var(--task-primary);
        }

        /* Subtask table drag and drop */
        #sp_Task_MyWork_html .subtask-row-draggable {
            cursor: move;
            transition: all 0.2s ease;
        }
        #sp_Task_MyWork_html .subtask-row-draggable.dragging {
            opacity: 0.5;
            background: var(--bg-lighter);
        }
        #sp_Task_MyWork_html .subtask-row-draggable.drag-over {
            border-top: 3px solid var(--task-primary);
        }

        /* Thêm vào phần CSS trong stored procedure */
        #sp_Task_MyWork_html .drag-handle {
            cursor: grab;
            color: var(--text-muted);
            user-select: none;
            text-align: center;
            padding: 8px !important;
            font-size: 18px;
        }

        #sp_Task_MyWork_html .drag-handle:hover {
            color: var(--task-primary);
      background: var(--bg-lighter);
        }

        #sp_Task_MyWork_html .drag-handle:active {
            cursor: grabbing;
            color: var(--task-primary);
        }

        #sp_Task_MyWork_html .subtask-row-draggable {
            transition: all 0.2s ease;
            position: relative;
        }

        #sp_Task_MyWork_html .subtask-row-draggable:hover {
            background: var(--bg-light);
        }

        #sp_Task_MyWork_html .subtask-row-draggable.dragging {
            opacity: 0.5;
            background: var(--bg-lighter);
            box-shadow: 0 4px 12px rgba(0,0,0,0.15);
        }

        #sp_Task_MyWork_html .subtask-row-draggable.drag-over {
            border-top: 3px solid var(--task-primary);
        }

        #sp_Task_MyWork_html .subtask-assignee {
            min-height: 60px;
            max-height: 80px;
            overflow-y: auto;
        }

        /* Make table responsive */
        #sp_Task_MyWork_html .subtask-table {
            table-layout: fixed;
        }

        #sp_Task_MyWork_html .subtask-table td {
            vertical-align: middle;
        }

        /* Drag & Drop for List View */
        #sp_Task_MyWork_html .cu-row.draggable {
            cursor: move;
            transition: all 0.2s ease;
        }

        #sp_Task_MyWork_html .cu-row.dragging {
            opacity: 0.5;
            background: var(--bg-lighter);
            box-shadow: 0 8px 24px rgba(0,0,0,0.2);
            transform: scale(0.98);
        }

        #sp_Task_MyWork_html .cu-row.drag-over {
            border-top: 3px solid var(--task-primary);
            background: rgba(46, 125, 50, 0.05);
        }

        #sp_Task_MyWork_html .row-drag-handle {
            cursor: grab;
            color: var(--text-muted);
            font-size: 18px;
            opacity: 0;
            transition: opacity 0.2s ease;
        }

        #sp_Task_MyWork_html .cu-row:hover .row-drag-handle {
            opacity: 1;
        }

        #sp_Task_MyWork_html .row-drag-handle:active {
            cursor: grabbing;
        }

        #sp_Task_MyWork_html .row-drag-handle:hover {
            color: var(--task-primary);
        }
        /* assignee dropdown selection visuals */
        #sp_Task_MyWork_html .row-assignee-item.selected {
            background: rgba(46,125,94,0.06);
        }
        #sp_Task_MyWork_html .row-assignee-item .row-assignee-checkbox {
            width:16px; height:16px;
        }
    </style>
    <div id="sp_Task_MyWork_html">
        <div class="cu-header">
            <div class="h-title"><i class="bi bi-check-circle-fill"></i>Công việc của tôi</div>
            <div class="header-actions">
                <div class="view-switcher">
                    <button class="view-btn active" id="viewListT"><i class="bi bi-list-ul"></i> Danh sách</button>
                    <button class="view-btn" id="viewKanbanT"><i class="bi bi-kanban"></i> Kanban</button>
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
        <div class="stats-row" id="stats-container">
            <div class="stat-card todo">
                <div class="stat-label">Chưa làm</div>
                <div class="stat-value" id="stat-todo">0</div>
            </div>
            <div class="stat-card doing">
                <div class="stat-label">Đang làm</div>
                <div class="stat-value" id="stat-doing">0</div>
            </div>
            <div class="stat-card done">
                <div class="stat-label">Hoàn thành</div>
                <div class="stat-value" id="stat-done">0</div>
            </div>
            <div class="stat-card overdue">
                <div class="stat-label">Quá hạn</div>
                <div class="stat-value" id="stat-overdue">0</div>
            </div>
        </div>
        <!-- Filters -->
        <div class="filter-section">
            <label style="font-weight: 600; font-size: 13px;">Lọc:</label>
            <select id="filterStatus" onchange="filterTasks()">
                <option value="">Tất cả trạng thái</option>
                <option value="1">Chưa làm</option>
                <option value="2">Đang làm</option>
                <option value="3">Hoàn thành</option>
            </select>
            <select id="filterOverdue" onchange="filterTasks()">
                <option value="">Tất cả</option>
                <option value="1">Chỉ quá hạn</option>
            </select>
        </div>
        <!-- Kanban View -->
        <div id="kanban-view">
            <div class="kanban-board">
                <div class="kanban-column">
                    <div class="column-header">
                        <div class="column-title">
                            <i class="bi bi-circle"></i> Chưa làm
                        </div>
                        <span class="column-count" id="count-todo">0</span>
                    </div>
                    <div id="tasks-todo"></div>
                </div>
                <div class="kanban-column">
                    <div class="column-header">
                        <div class="column-title">
                            <i class="bi bi-arrow-repeat"></i> Đang làm
                        </div>
                        <span class="column-count" id="count-doing">0</span>
                    </div>
                    <div id="tasks-doing"></div>
                </div>
                <div class="kanban-column">
                    <div class="column-header">
                        <div class="column-title">
                            <i class="bi bi-check-circle-fill"></i> Hoàn thành
                        </div>
                        <span class="column-count" id="count-done">0</span>
                    </div>
                    <div id="tasks-done"></div>
                </div>
            </div>
        </div>
        <!-- List View -->
        <div id="list-view" style="display:none;">
            <div class="cu-list" id="list-container"></div>
        </div>
        <!-- Task Detail Modal -->
        <div class="modal fade task-detail-modal" id="mdlTaskDetail" tabindex="-1" data-bs-backdrop="static">
            <div class="modal-dialog modal-dialog-centered modal-dialog-scrollable">
                <div class="modal-content">
                    <div class="task-detail-header">
                        <button type="button" class="btn-close float-end" data-bs-dismiss="modal"></button>
                        <div class="task-detail-title" id="detailTaskName">...</div>
                        <div class="task-detail-meta">
                            <div class="meta-row">
                                <span class="meta-label">Người yêu cầu:</span>
                                <span class="meta-value" id="detailCreator">-</span>
                            </div>
                            <div class="meta-row">
                                <span class="meta-label">Trách nhiệm chính:</span>
                                <span class="meta-value" id="detailMainResponsible">-</span>
                            </div>
                            <div class="meta-row">
                                <span class="meta-label">Ngày bắt đầu:</span>
                                <span class="meta-value" id="detailStartDate">-</span>
                            </div>
                            <div class="meta-row">
                                <span class="meta-label">Hạn chót:</span>
                      <span class="meta-value" id="detailDueDate">-</span>
                            </div>
                        </div>
                    </div>
                    <div class="task-detail-body">
                        <!-- Status Selector -->
                        <div class="status-selector">
                            <div class="status-option sts-1" data-status="1" onclick="updateTaskStatus(1)">
                                <i class="bi bi-circle"></i>
                                <div>Chưa làm</div>
                            </div>
                            <div class="status-option sts-2" data-status="2" onclick="updateTaskStatus(2)">
                                <i class="bi bi-arrow-repeat"></i>
                                <div>Đang làm</div>
                            </div>
                            <div class="status-option sts-3" data-status="3" onclick="updateTaskStatus(3)">
                                <i class="bi bi-check-circle-fill"></i>
                                <div>Hoàn thành</div>
                            </div>
                        </div>

                        <!-- KPI Section -->
                        <div class="kpi-section" id="kpiSection">
                            <div class="kpi-display">
                                <div>
                                    <div class="kpi-current" id="detailActualKPI">0</div>
                                    <div class="kpi-target">Mục tiêu: <strong id="detailTargetKPI">100</strong> <span id="detailUnit">đơn</span></div>
                                </div>
                                <div style="text-align: right;">
                                    <div style="font-size: 24px; font-weight: 700; color: var(--task-primary);" id="detailProgressPct">0%</div>
                                    <div style="font-size: 12px; color: #676879;">Tiến độ</div>
                                </div>
                            </div>
                            <div class="kpi-progress-bar">
                                <div class="kpi-progress-fill" id="detailProgressBar" style="width: 0%"></div>
                            </div>
                            <div class="kpi-input-group">
                                <input type="number" id="txtUpdateKPI" placeholder="Nhập KPI mới..." class="form-control">
                                <input type="text" id="txtUpdateNote" placeholder="Ghi chú (tùy chọn)..." class="form-control">
                                <button id="btnUpdateKPI"><i class="bi bi-check-lg"></i> Cập nhật</button>
                            </div>
                        </div>

                        <!-- Description Section -->
                        <div class="description-section">
                            <div class="d-flex justify-content-between align-items-center mb-3">
                                <div class="section-title"><i class="bi bi-file-text"></i> Mô tả chi tiết</div>
                                <button class="btn btn-sm btn-outline-primary" id="btnEditDescription">
                                    <i class="bi bi-pencil"></i> Chỉnh sửa
                                </button>
                            </div>
                            <div id="descriptionDisplay" class="description-content">
                                Chưa có mô tả...
                            </div>
                            <div id="descriptionEdit" style="display:none;">
                                <textarea class="description-edit" id="txtDescription" placeholder="Nhập mô tả chi tiết..."></textarea>
                                <div class="mt-2" style="display:flex; gap:8px; justify-content:flex-end;">
                                    <button class="btn btn-sm btn-white border" id="btnCancelDescription">Hủy</button>
                                    <button class="btn btn-sm btn-cu" id="btnSaveDescription">
                                        <i class="bi bi-check-lg"></i> Lưu
                                    </button>
                                </div>
                            </div>
                        </div>

                        <!-- Attachments Section -->
                        <div class="attachments-section">
                            <div class="d-flex justify-content-between align-items-center mb-3">
                                <div class="section-title"><i class="bi bi-paperclip"></i> Tài liệu đính kèm</div>
                                <button class="btn btn-sm btn-outline-primary" id="btnAddAttachment">
                                    <i class="bi bi-plus-lg"></i> Thêm tài liệu
                                </button>
                            </div>
                            <div id="attachmentsList"></div>

                            <!-- Upload Area -->
                            <div class="upload-area" id="uploadArea" style="display:none;">
                                <i class="bi bi-cloud-upload fs-1 text-primary"></i>
                                <div class="mt-2 fw-bold">Kéo thả file hoặc click để chọn</div>
                                <div class="text-muted small">Hỗ trợ: PDF, DOC, DOCX, XLS, XLSX, JPG, PNG (Max 10MB)</div>
                                <input type="file" id="fileInput" style="display:none;" multiple
                                    accept=".pdf,.doc,.docx,.xls,.xlsx,.jpg,.jpeg,.png">
                            </div>

                            <!-- Add Link -->
                            <div id="linkArea" style="display:none; margin-top:16px;">
                                <div class="form-group">
                                    <label class="form-label">Tên tài liệu</label>
                                    <input type="text" class="form-control" id="txtLinkName" placeholder="VD: Báo cáo tháng 11">
                                </div>
                                <div class="form-group mt-2">
                                    <label class="form-label">URL Link</label>
                                    <input type="url" class="form-control" id="txtLinkURL" placeholder="https://...">
                                </div>
                                <div class="mt-2" style="display:flex; gap:8px; justify-content:flex-end;">
                                    <button class="btn btn-sm btn-white border" id="btnCancelLink">Hủy</button>
                                    <button class="btn btn-sm btn-cu" id="btnSaveLink">
                                        <i class="bi bi-check-lg"></i> Lưu link
                                    </button>
                                </div>
                            </div>
                        </div>

                        <!-- Subtask Table Section -->
                        <div id="subtaskTableContainer" style="display:none; margin-top: 24px; overflow-x:auto;">
                            <div class="section-title"><i class="bi bi-list-task"></i> Chi tiết công việc con</div>
                            <table class="subtask-table" id="subtaskTable">
                                <thead>
                                    <tr>
                                        <th style="width:40px; text-align:center;">
                                            <i class="bi bi-grip-vertical"></i>
                                        </th>
                                        <th>Tên công việc</th>
                                        <th style="width:180px;">Người phụ trách</th>
                                        <th style="width:120px;">Bắt đầu</th>
                                        <th style="width:120px;">Kết thúc</th>
                                        <th class="progress-cell" style="width:120px;">% tiến độ</th>
      <th class="status-cell" style="width:120px;">Trạng thái</th>
                                        <th class="priority-cell" style="width:100px;">Ưu tiên</th>
                                    </tr>
                                </thead>
                                <tbody id="subtaskTableBody">
                                </tbody>
                            </table>
                        </div>

                        <!-- Comments Section -->
                        <div class="comments-section">
                            <div class="section-title"><i class="bi bi-chat-dots"></i> Nhận xét & Ghi chú</div>
                            <div id="commentsList"></div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
        <!-- Assign Modal -->
        <div class="modal fade assign-modal" id="mdlAssign" tabindex="-1">
            <div class="modal-dialog modal-dialog-centered">
                <div class="modal-content">
                    <div class="modal-header">
                        <h5 class="modal-title fw-bold">Giao việc</h5>
                        <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                    </div>
                    <div class="assign-container">
                        <!-- Step 1: Thiết lập chung -->
                        <div class="assign-step">
                            <div class="step-header">
                                <div class="step-number">1</div>
                                <div class="step-title">Thiết lập chung</div>
                            </div>
                            <div class="assign-row" style="grid-template-columns: repeat(2, 1fr);">
                                <div class="form-group">
                                    <label class="form-label">Công việc chính</label>
                                    <div style="display:flex;gap:8px;align-items:center;position:relative;">
                                        <div class="search-select" style="position:relative;">
                                            <input type="text" id="selParentSearch" class="form-control" placeholder="Tìm công việc..." autocomplete="off" />
                                            <div class="search-select-dropdown" id="selParentDropdown" style="position:absolute; z-index:1050; border:1px solid #ddd; max-height:200px; overflow:auto; display:none; width:320px; box-shadow:0 6px 18px rgba(0,0,0,0.08);"></div>
                                            <select class="form-select d-none" id="selParent" style="min-width:260px"></select>
                                        </div>
                                        <button class="btn btn-outline-success py-2" id="btnAddParentOpen" title="Thêm công việc mới">Thêm</button>
                                    </div>
                                </div>
                                <div class="form-group">
                                    <label class="form-label">Người yêu cầu</label>
                                    <div style="display:flex;gap:8px;align-items:center;position:relative;">
                                        <div class="search-select" style="position:relative;">
                                            <input type="text" id="selAssignedBySearch" class="form-control" placeholder="Tìm người yêu cầu..." autocomplete="off" />
                                            <div class="search-select-dropdown" id="selAssignedByDropdown" style="position:absolute; z-index:1050; border:1px solid #ddd; max-height:200px; overflow:auto; display:none; width:320px; box-shadow:0 6px 18px rgba(0,0,0,0.08);"></div>
                                            <select class="form-select d-none" id="selAssignedBy"></select>
                                        </div>
                                    </div>
                                </div>
                                <div class="form-group">
                                    <label class="form-label">Người chịu trách nhiệm chính</label>
                                    <div style="display:flex;gap:8px;align-items:center;position:relative;">
                                        <div class="search-select" style="position:relative;">
                                            <input type="text" id="selMainUserSearch" class="form-control" placeholder="Tìm người chịu trách nhiệm..." autocomplete="off" />
                                            <div class="search-select-dropdown" id="selMainUserDropdown" style="position:absolute; z-index:1050; border:1px solid #ddd; max-height:200px; overflow:auto; display:none; width:320px; box-shadow:0 6px 18px rgba(0,0,0,0.08);"></div>
                                            <select class="form-select d-none" id="selMainUser"></select>
                                        </div>
                                    </div>
                                </div>
                                <div class="form-group">
                                    <label class="form-label">Ngày yêu cầu</label>
                                    <input type="date" class="form-control" id="dDate" />
                                </div>
                            </div>
                        </div>
                        <!-- Step 2: Phân bổ chi tiết -->
                        <div class="assign-step">
                                <div class="step-header">
                                    <div class="step-number">2</div>
                                    <div class="step-title">Phân bổ chi tiết (Subtasks)</div>
                                    <div style="margin-left:auto; display:flex; gap:8px; align-items:center;">
                                        <button class="btn btn-sm btn-outline-primary" id="btnAddTempRow">Thêm hàng</button>
                                        <button class="btn btn-sm btn-outline-secondary" id="btnReloadChecklist">Tải lại checklist</button>
                                    </div>
                                </div>
                            <div id="subtask-assign-container" style="overflow-x: auto;" class="assign-row">
                                <div class="empty-state" style="grid-column: 1 / -1;">
                                    <i class="bi bi-arrow-up-circle"></i>
                                    <p>Vui lòng chọn Công việc chính ở trên</p>
                                </div>
                            </div>
                        </div>
                    </div>
                    <div class="modal-footer">
                        <button type="button" class="btn btn-white border" data-bs-dismiss="modal">Đóng</button>
                        <button type="button" class="btn-assign" id="btnSubmitAssignment">
                            <i class="bi bi-send-fill"></i> Xác nhận giao việc
                        </button>
                    </div>
                </div>
            </div>
        </div>
    </div>
    <script>
        (function(){"use strict";
        var allTasks = [], filteredTasks = [], currentTaskID = 0, currentView = "list";
        var employees = [], tasks = [], headers = [], currentTemplate = [];
        var rowAssigneeMap = {};
        var currentChildTasks = []; // cached child tasks for selected ParentTaskID
        var expandedHeadersState = {};
        var attachmentMode = ""; // "file" or "link"

        // Expose only specific APIs intentionally
        window.toggleHeaderExpand = toggleHeaderExpand;
        window.downloadAttachment = downloadAttachment;
        window.deleteAttachment = deleteAttachment;
        window.updateTaskStatus = updateTaskStatus;
        $(document).ready(function() {
            attachUIHandlers();
            loadTasks();
        });

        function attachUIHandlers() {
            // Static buttons
            $("#btnAssign").on("click", openAssignModal);
            $("#btnRefresh").on("click", loadTasks);
            $("#btnUpdateKPI").on("click", updateKPI);
            $("#btnAddParentOpen").on("click", openAddParentModal);
            $("#btnAddTempRow").on("click", addTempRow);
            $("#btnReloadChecklist").on("click", reloadChecklist);
            $("#btnSubmitAssignment").on("click", submitAssignment);
            // Delegated handlers for dynamic elements
            // Open detail when clicking a row, but ignore clicks on interactive controls (selects, buttons, inputs, assignee widgets, status badges)
            $(document).on("click", ".task-row:not(.header-row)", function(e) {
                var $t = $(e.target);
                if ($t.is("select") || $t.is("input") || $t.is("button") || $t.is("a") || $t.closest(".row-assignee").length || $t.closest(".row-assignee-dropdown").length || $t.closest(".row-priority-select").length || $t.closest(".row-assignee-toggle").length || $t.closest(".row-assignee-item").length || $t.closest(".badge-toggle-status").length || $t.closest(".subtask-toggle-status").length) {
                    return;
                }
                var id = $(this).data("taskid");
                if(id) openTaskDetail(id);
            });
            // Riêng cho header row - không mở detail
            $(document).on("click", ".header-row", function(e) {
                // Chỉ toggle expand, không mở detail
                e.stopPropagation();
                var headerId = $(this).data("headerid");
                if(headerId) toggleHeaderExpand(headerId);
            });
            $(document).on("click", ".badge-toggle-status", function(e) {
                e.stopPropagation();
                e.preventDefault();

                var id = $(this).data("taskid");
                var code = parseInt($(this).data("status")) || 1;

                if(id) {
                    toggleStatus(id, code);
                }
            });
            $(document).on("click", ".btn-temp-remove", function() {
                $(btn).closest(".temp-subtask").remove();
            });
            // Toggle subtask status (in detail table)
            $(document).on("click", ".subtask-toggle-status", function(e) {
                e.stopPropagation();
                var $el = $(this);
                var childId = $el.data("childid");
                var current = Number($el.data("status")) || 0;
                var next = current >= 3 ? 1 : current + 1;
                AjaxHPAParadise({
                    data: {
                        name: "sp_Task_UpdateSubtaskStatus",
                        param: ["ChildTaskID", childId, "LoginID", LoginID, "NewStatus", next]
                    },
                    success: function() { loadSubtasksForDetail(currentTaskID); }
                });
            });
            // Change subtask priority
            $(document).on("change", ".subtask-priority", function(e) {
                e.stopPropagation();

                var $sel = $(this);
                var childId = $sel.data("childid");
                var val = $sel.val();

                AjaxHPAParadise({
                    data: {
                        name: "sp_Task_UpdateField",
                        param: ["TaskID", childId, "Priority", val]
                    },
                    success: function() {
                        showSuccessNotification("Cập nhật độ ưu tiên thành công!", "");
                    },
                    error: function() {
                        alert("Cập nhật độ ưu tiên thất bại!");
                    }
                });
            });
            // Change subtask assignee (multiple select)
            $(document).on("change", ".subtask-assignee", function(e) {
                e.stopPropagation();

                var $sel = $(this);
                var childId = $sel.data("childid");
           var selectedEmployees = $sel.val() || [];

                // Convert array to comma-separated string
                var employeeIds = selectedEmployees.join(",");

                AjaxHPAParadise({
                    data: {
                        name: "sp_Task_UpdateSubtaskAssignees",
                        param: ["ChildTaskID", childId, "EmployeeIDs", employeeIds, "LoginID", LoginID]
                    },
                    success: function() {
                        showSuccessNotification("Cập nhật người phụ trách thành công!", "");
                        loadSubtasksForDetail(currentTaskID);
                    },
                    error: function() {
                        alert("Cập nhật người phụ trách thất bại!");
                    }
                });
            });
            // Create parent modal button may be appended dynamically
            $(document).on("click", "#btnCreateParent", function() {
                createParentFromModal();
            });
            // When hidden parent select changes, hide subtasks if cleared
            $(document).on("change", "#selParent", function() {
                if(!$(this).val()) {
                    $("#subtask-assign-container").html(`<div class="empty-state" style="grid-column: 1 / -1;"><i class="bi bi-inbox"></i><p>Vui lòng chọn Công việc chính ở trên</p></div>`);
                }
            });
            // Thêm event handler cho priority select ở ngoài modal
            $(document).on("change", ".task-row-priority", function(e) {
                e.stopPropagation();

                var $sel = $(this);
                var taskId = $sel.data("taskid");
                var val = $sel.val();

                AjaxHPAParadise({
                    data: {
                        name: "sp_Task_UpdateField",
                        param: ["TaskID", taskId, "Priority", val]
                    },
                    success: function() {
                        showSuccessNotification("Cập nhật độ ưu tiên thành công!", "");
                        // Không reload toàn bộ, chỉ update icon
                        var prioClass = "prio-" + val;
                        $sel.closest(".task-row").find(".priority-icon")
                            .removeClass("prio-1 prio-2 prio-3")
                            .addClass(prioClass);
                    },
                    error: function() {
                        alert("Cập nhật độ ưu tiên thất bại!");
                    }
                });
            });
            // Change priority directly on subtask row
            $(document).on("change", ".row-priority-select", function(e) {
                e.stopPropagation();
                var $sel = $(this);
                var taskId = $sel.data("taskid");
                var val = $sel.val();

                AjaxHPAParadise({
                    data: {
                        name: "sp_Task_UpdateField",
                        param: ["TaskID", taskId, "Priority", val]
                    },
                    success: function() {
                        showSuccessNotification("Cập nhật độ ưu tiên thành công!", "");
                        var prioClass = "prio-" + val;
                        $sel.closest(".task-row").find(".priority-icon")
                            .removeClass("prio-1 prio-2 prio-3")
                            .addClass(prioClass);
                        try {
                            var t = allTasks.find(x => x.TaskID == taskId);
                            if (t) { t.AssignPriority = Number(val); t.Priority = Number(val); }
                        } catch(e) { console.warn(e); }
                    },
                    error: function() { alert("Cập nhật độ ưu tiên thất bại!"); }
                });
            });

            // Row assignee: toggle dropdown, search and select
            $(document).on("click", ".row-assignee-toggle", function(e) {
                e.stopPropagation();
                var $btn = $(this);
                var $wrap = $btn.closest(".row-assignee");
                // close other dropdowns
                $(".row-assignee-dropdown").not($wrap.find(".row-assignee-dropdown")).hide();
                var $dd = $wrap.find(".row-assignee-dropdown");
                var $list = $dd.find(".row-assignee-list");

                // populate list if empty (lazy-load employees if needed)
                var populateList = function() {
                    if ($list.children().length === 0) {
                        // Determine already-assigned employee IDs for this task (if any)
                        var assignedIds = [];
                        try {
                            var tid = $wrap.data("taskid");
                            var t = allTasks.find(function(x){ return String(x.TaskID) === String(tid); });
                            var idsCsv = t && (t.AssignedToEmployeeIDs) ? (t.AssignedToEmployeeIDs) : "";
                            if (idsCsv) assignedIds = String(idsCsv).split(",").map(function(s){ return s.trim(); }).filter(Boolean);
                        } catch (e) { assignedIds = []; }

                        var items = (employees || []).map(function(e){
                            var isSel = assignedIds.indexOf(String(e.EmployeeID)) !== -1;
                            return `<div class="row-assignee-item ${isSel? "selected":""}" data-empid="${e.EmployeeID}" data-empname="${escapeHtml(e.FullName)}" style="padding:8px 10px;cursor:pointer;display:flex;align-items:center;gap:8px;border-bottom:1px solid #f0f2f5;">
                                <div style="width:28px;flex-shrink:0;">
                                   <input type="checkbox" class="row-assignee-checkbox" ${isSel? "checked":""} />
                                </div>
                                <div class="icon-chip" style="width:32px;height:32px;border-radius:50%;background:#f1f5f9;display:flex;align-items:center;justify-content:center;font-size:12px;">${escapeHtml(getInitials(e.FullName))}</div>
                                <div style="flex:1;min-width:0;">
                                    <div style="font-weight:600">${escapeHtml(e.FullName)}</div>
                                    <div style="font-size:12px;color:var(--text-muted)">${escapeHtml(e.EmployeeID)}</div>
                                </div>
                            </div>`;
                        }).join("");

                        // footer with actions
                        var footer = `<div style="padding:8px;border-top:1px solid var(--border-color);display:flex;gap:8px;justify-content:flex-end;">
                            <button type="button" class="btn btn-sm btn-outline-secondary row-assignee-clear">Xóa</button>
                            <button type="button" class="btn btn-sm btn-primary row-assignee-apply">Áp dụng</button>
                        </div>`;

                        $list.html(items + footer);
                    }
                };

                if (!employees || employees.length === 0) {
                    // lazy load employees from backend
                    AjaxHPAParadise({
                        data: { name: "sp_Task_GetAssignmentSetup", param: [] },
                        success: function(res) {
                            try {
                                var data = JSON.parse(res).data;
                                employees = data[2] || [];
                            } catch(e) { console.warn(e); }
                            populateList();
                            $dd.toggle();
                            $dd.find(".row-assignee-search").val("").focus();
                        },
                        error: function() {
                            // fallback: still try to populate empty
                            populateList();
                            $dd.toggle();
                            $dd.find(".row-assignee-search").val("").focus();
                        }
                    });
                } else {
                    populateList();
                    $dd.toggle();
                    $dd.find(".row-assignee-search").val("").focus();
                }
            });

            // Filter assignee list
            $(document).on("input", ".row-assignee-search", function(e){
                e.stopPropagation();
                var q = ($(this).val() || "").toLowerCase();
                var $list = $(this).closest(".row-assignee-dropdown").find(".row-assignee-list");
                $list.children().each(function(){
                    var $it = $(this);
                    var name = ($it.find("div").first().text() || "") + " " + ($it.find("div").last().text() || "");
                    if(name.toLowerCase().indexOf(q) !== -1) $it.show(); else $it.hide();
                });
            });

            // Toggle selection on click (checkbox) inside assignee dropdown
            $(document).on("click", ".row-assignee-item", function(e){
                e.stopPropagation();
                var $it = $(this);
                var $chk = $it.find(".row-assignee-checkbox");
                // toggle
                var now = !$chk.prop("checked");
                $chk.prop("checked", now);
                $it.toggleClass("selected", now);
            });

            // Apply selected assignees for this subtask
            $(document).on("click", ".row-assignee-apply", function(e){
                e.stopPropagation();
                var $btn = $(this);
                var $dd = $btn.closest(".row-assignee-dropdown");
                var $wrap = $dd.closest(".row-assignee");
                var taskId = $wrap.data("taskid");
                var selected = [];
                $dd.find(".row-assignee-item.selected").each(function(){ selected.push($(this).data("empid")); });
                var csv = (selected || []).map(function(x){ return String(x).trim(); }).filter(Boolean).join(",");

                AjaxHPAParadise({
                    data: {
                        name: "sp_Task_UpdateSubtaskAssignees",
                        param: ["ChildTaskID", taskId, "EmployeeIDs", csv, "LoginID", LoginID]
                    },
                    success: function(){
                        showSuccessNotification("Cập nhật người phụ trách thành công!", "");
                        try {
                            var t = allTasks.find(x=>String(x.TaskID) === String(taskId));
                            if (t) {
                                t.AssignedToEmployeeIDs = csv;
                                // build names array from selected items
                                var names = [];
                                $dd.find(".row-assignee-item.selected").each(function(){ names.push($(this).data("empname") || $(this).find("div").eq(1).find("div").first().text()); });
                                t.AssignedToEmployeeNames = names.join(",");
                            }

                            // Refresh icons
                            var icons = buildAssigneeIcons(t || { AssignedToEmployeeIDs: csv, AssignedToEmployeeNames: (t && t.AssignedToEmployeeNames) || "" }, 3);
                            $wrap.find(".assignee-icons").html(icons);
                                    // Ensure the whole row is in sync in case other render logic overwrites the icons
                                    try { refreshTaskRowInList(taskId); } catch(e) { /* fallback already updated icons */ }
                                    $dd.hide();
                        } catch(e){ console.warn(e); }
                    },
                    error: function(){ alert("Cập nhật người phụ trách thất bại!"); }
                });
            });

            // Clear selection
            $(document).on("click", ".row-assignee-clear", function(e){
                e.stopPropagation();
                var $btn = $(this);
                var $dd = $btn.closest(".row-assignee-dropdown");
                var $wrap = $dd.closest(".row-assignee");
                var taskId = $wrap.data("taskid");

                AjaxHPAParadise({
                    data: { name: "sp_Task_UpdateSubtaskAssignees", param: ["ChildTaskID", taskId, "EmployeeIDs", "", "LoginID", LoginID] },
                    success: function(){
                        showSuccessNotification("Xóa người phụ trách thành công!", "");
                        try {
                            var t = allTasks.find(x=>String(x.TaskID) === String(taskId));
                            if (t) {
                                t.AssignedToEmployeeIDs = "";
                                t.AssignedToEmployeeNames = "";
                            }
                            $dd.find(".row-assignee-item").removeClass("selected").find(".row-assignee-checkbox").prop("checked", false);
                                    $wrap.find(".assignee-icons").html(buildAssigneeIcons(t || {}, 3));
                                    try { refreshTaskRowInList(taskId); } catch(e) {}
                                    $dd.hide();
                        } catch(e){ console.warn(e); }
                    },
                    error: function(){ alert("Xóa người phụ trách thất bại!"); }
                });
            });

            // Close assignee dropdown when clicking elsewhere. If user clicked outside
            // while having selected assignees, auto-save the selection before hiding.
            $(document).on("click", function(e){
                if(!$(e.target).closest(".row-assignee").length){
                    // For each visible dropdown, persist selection if it changed
                    $(".row-assignee-dropdown:visible").each(function(){
                        var $dd = $(this);
                        var $wrap = $dd.closest(".row-assignee");
                        var taskId = $wrap.data("taskid");
                        if(!taskId) return;

                        var selected = [];
                        $dd.find(".row-assignee-item.selected").each(function(){ selected.push($(this).data("empid")); });
                        var csv = (selected || []).map(function(x){ return String(x).trim(); }).filter(Boolean).join(",");

                        try {
                            var t = allTasks.find(x=>String(x.TaskID) === String(taskId));
                            var existingCsv = "";
                            if (t) existingCsv = ((t.AssignedToEmployeeIDs || "")+"").split(",").map(function(s){return String(s).trim();}).filter(Boolean).join(",");

                            if (csv !== existingCsv) {
                                // Save changes same as Apply button
                                AjaxHPAParadise({
                                    data: {
                                        name: "sp_Task_UpdateSubtaskAssignees",
                                        param: ["ChildTaskID", taskId, "EmployeeIDs", csv, "LoginID", LoginID]
                                    },
                                    success: function(){
                                        showSuccessNotification("Cập nhật người phụ trách thành công!", "");
                                        try {
                                            var tLocal = allTasks.find(x=>String(x.TaskID) === String(taskId));
                                            if (tLocal) {
                                                tLocal.AssignedToEmployeeIDs = csv;
                                                var names = [];
                                                $dd.find(".row-assignee-item.selected").each(function(){ names.push($(this).data("empname") || $(this).find("div").eq(1).find("div").first().text()); });
                                                tLocal.AssignedToEmployeeNames = names.join(",");
                                            }
                                            try { refreshTaskRowInList(taskId); } catch(e) { /* fallback handled below */ }
                                        } catch(e){ console.warn(e); }
                                    },
                                    error: function(){ alert("Cập nhật người phụ trách thất bại!"); }
                                });
                            }
                        } catch(err) { console.warn(err); }
                    });

                    // finally hide all dropdowns
                    $(".row-assignee-dropdown").hide();
                }
            });
            // Searchable select handlers: input -> show filtered dropdown, click item -> select
            $(document).on("input", "#selParentSearch", function() {
                var val = $(this).val() || "";
                filterOptionsForSearch("selParent", val, "#selParentDropdown");
                var selText = $("#selParent option:selected").text() || "";
                if (val.trim() === "") {
                    // user cleared input -> clear hidden select and subtask UI immediately
                    $(this).removeClass("search-valid search-invalid");
                    try { $("#selParent").val(""); } catch(e) {}
                    $("#subtask-assign-container").html(`<div class="empty-state" style="grid-column: 1 / -1;"><i class="bi bi-inbox"></i><p>Vui lòng chọn Công việc chính ở trên</p></div>`);
                    return;
                }
                if(val.trim() !== selText.trim()) {
                    // typed text doesn"t match the currently selected option -> hide subtasks and mark invalid
                    $(this).removeClass("search-valid").addClass("search-invalid");
                    $("#subtask-assign-container").html(`<div class="empty-state" style="grid-column: 1 / -1;"><i class="bi bi-inbox"></i><p>Vui lòng chọn Công việc chính ở trên</p></div>`);
                } else {
                    // exact match with selected option
                    $(this).removeClass("search-invalid").addClass("search-valid");
                }
            });
            $(document).on("input", "#selAssignedBySearch", function() {
                var val = $(this).val() || "";
                filterOptionsForSearch("selAssignedBy", val, "#selAssignedByDropdown");
                var selText = $("#selAssignedBy option:selected").text() || "";
                if(val.trim() !== selText.trim()) { $(this).removeClass("search-valid"); }
            });
            $(document).on("input", "#selMainUserSearch", function() {
                var val = $(this).val() || "";
                filterOptionsForSearch("selMainUser", val, "#selMainUserDropdown");
                var selText = $("#selMainUser option:selected").text() || "";
                if(val.trim() !== selText.trim()) { $(this).removeClass("search-valid"); }
            });
            // Show full list when input is focused or clicked. Hide other dropdowns and clear non-selected inputs.
            $(document).on("focus click", "#selParentSearch, #selAssignedBySearch, #selMainUserSearch", function(e) {
                e.stopPropagation();
                var $inp = $(this);
                var myBase = this.id.replace(/Search$/, ""); // ví dụ: selParentSearch → selParent

                // Đóng tất cả dropdown khác + xóa input nếu chưa chọn
                $(".search-select input").not($inp).each(function() {
                    var otherBase = (this.id || "").replace(/Search$/, "").trim();
                    if (!otherBase) return; // <<< BẢO VỆ: bỏ qua nếu rỗng

                    var $select = $("#" + otherBase);
                    var $dd = $("#" + otherBase + "Dropdown");

                    if ($select.length && !$select.val()) {
                        $(this).val("");
                    }
                    $dd.hide();
                });

                // Mở dropdown hiện tại
                var $dd = $("#" + myBase + "Dropdown");
                if ($dd.length) {
                    try {
                        $dd.css("width", Math.max($inp.outerWidth(), 200) + "px").show();
                    } catch(ex) {}
                    filterOptionsForSearch(myBase, "", "#" + myBase + "Dropdown");
                }
            });
            // Delegated input handlers for dynamic/temp filters (replaces inline oninput)
            $(document).on("input", ".temp-sub-filter", function() {
                try {
                    var target = $(this).data("target");
                    if(target && target !== "" && target !== "undefined") {
                        filterTempOptions(this);
                    }
                } catch(e) {
                    console.warn("temp-sub-filter error:", e);
                }
            });
            $(document).on("input", ".st-user-filter", function() {
                try {
                    var idx = $(this).data("idx");
                    if(idx !== undefined && idx !== null && idx !== "") {
                        filterMultiOptions(idx, $(this).val());
                    }
                } catch(e) {
                    console.warn("st-user-filter error:", e);
                }
            });
            // When user focuses/clicks the st-user-filter, show options and focus the select
            $(document).on("focus click", ".st-user-filter", function(e) {
                e.stopPropagation();
                var idx = $(this).data("idx");
                try { filterMultiOptions(idx, ""); } catch(e) {}
                var $sel = $(`.st-user-select[data-idx="${idx}"]`);
                if($sel.length) {
                    $sel.show();
                    try { $sel.focus(); } catch(e) {}
                }
            });
            // Checkbox to enable/disable a subtask row
            $(document).on("change", ".subtask-checkbox", function() {
                var idx = $(this).data("idx");
                var checked = $(this).is(":checked");
                var $sel = $(`.st-user-select[data-idx="${idx}"]`);
                var $from = $(`.st-from[data-idx="${idx}"]`);
                var $to = $(`.st-to[data-idx="${idx}"]`);
                var $note = $(`.st-note[data-idx="${idx}"]`);
                var $prio = $(`.st-priority[data-idx="${idx}"]`);
                var $filter = $(`.st-user-filter[data-idx="${idx}"]`);
                if(!checked) {
                    if($sel.length) { $sel.val([]); }
                    if($from.length) { $from.prop("disabled", true); }
                    if($to.length) { $to.prop("disabled", true); }
                    if($note.length) { $note.prop("disabled", true); }
                    if($prio.length) { $prio.prop("disabled", true); }
                    if($filter.length) { $filter.prop("disabled", true).val("").removeClass("search-valid search-invalid"); }
                } else {
                    if($sel.length) { /* keep selected */ }
                    if($from.length) { $from.prop("disabled", false); }
                    if($to.length) { $to.prop("disabled", false); }
                    if($note.length) { $note.prop("disabled", false); }
                    if($prio.length) { $prio.prop("disabled", false); }
                    if($filter.length) { $filter.prop("disabled", false); }
                }
            });
            // Click on dropdown items
            $(document).on("click", ".search-select-dropdown .search-item", function(e) {
                e.stopPropagation();
                var $it = $(this);
                var target = $it.data("target");  // ← có thể undefined hoặc rỗng
                var val = $it.data("value");
                var text = $it.text();

                if (!target || target.trim() === "") return;

                var $hiddenSelect = $("#" + target);
                if ($hiddenSelect.length === 0) return; // không tồn tại

                $hiddenSelect.val(val).trigger("change");

                var $inp = $("#" + target + "Search");
                if ($inp.length) {
                    $inp.val(text).addClass("search-valid").removeClass("search-invalid");
                }

                $it.closest(".search-select-dropdown").hide();

                if(target === "selParent") {
                    loadAssignTemplate();
                }
            });
            // Click on st-user-dropdown items (multi-select toggle)
            $(document).on("click", ".st-user-dropdown .st-multi-item", function(e){
                e.stopPropagation();
                var $it = $(this);
                var idx = $it.data("idx");

                var val = $it.data("value");
                var $hidden = $(`.st-user-select[data-idx="${idx}"]`);
                if(!$hidden.length) return;

                // toggle selection on hidden select
                var opt = $hidden.find(`option[value="${val}"]`);
                if(!opt.length) return;
                var currently = opt.prop("selected");
                opt.prop("selected", !currently);
                $it.toggleClass("selected", !currently);

                // Refresh visible selected names (render chips)
                try { refreshSelectedUsersDisplay(idx); } catch(err) { console.warn(err); }
            });
            $(document).on("click", function(e) {
                if(!$(e.target).closest(".search-select").length) {
                    $(".search-select input").each(function() {
                        try {
                            var id = this.id || "";
                            if (!id.endsWith("Search")) return;

                            var base = id.slice(0, -6);

                            if (!base || base.trim() === "") return;

                            var $sel = $("#" + base);
                            if ($sel.length === 0) return;

                            var $inp = $(this);

                            if ($sel.length === 0) {
                                console.warn("Select not found for base:", base);
                                return; // Skip this iteration
                            }

                            var selText = ($sel.find("option:selected").text()||"").trim();
                            var inpText = ($inp.val()||"").trim();

                            if(!$sel.val()) {
                                $inp.val("").removeClass("search-valid search-invalid");
                            } else if(inpText !== selText) {
                                // user edited after selection -> clear both
                                $sel.val("");
                                $inp.val("").removeClass("search-valid search-invalid");
                            } else {
                                // valid
                                $inp.addClass("search-valid").removeClass("search-invalid");
                            }
                        } catch(err) {
                            console.warn("Error processing search-select input:", err);
                        }
                    });

                    // Close all dropdowns
                    $(".search-select-dropdown").hide();
                }
            });
            $(document).on("hidden.bs.modal", "#mdlAssign", function() {
                try {
     $(".search-select input").val("").removeClass("search-valid search-invalid");
                    $(".search-select-dropdown").hide();
                    $("#selParent, #selAssignedBy, #selMainUser").val("");
                    $("#subtask-assign-container").html(`
                        <div class="empty-state" style="grid-column: 1 / -1;">
                            <i class="bi bi-inbox"></i>
                            <p>Vui lòng chọn Công việc chính ở trên</p>
                        </div>
                    `);
                } catch(err) {
                    console.warn("Modal cleanup error:", err);
                }
            });
            $("#btnEditDescription").on("click", function() {
                $("#descriptionDisplay").hide();
                $("#descriptionEdit").show();
                $("#txtDescription").focus();
            });
            $("#btnCancelDescription").on("click", function() {
                $("#descriptionEdit").hide();
                $("#descriptionDisplay").show();
            });
            $("#btnSaveDescription").on("click", function() {
                var desc = $("#txtDescription").val();

                AjaxHPAParadise({
                    data: {
                        name: "sp_Task_UpdateDescription",
                        param: ["TaskID", currentTaskID, "Description", desc]
                    },
                    success: function() {
                        $("#descriptionDisplay").text(desc || "Chưa có mô tả...");
                        $("#descriptionEdit").hide();
                        $("#descriptionDisplay").show();
                        showSuccessNotification("Cập nhật mô tả thành công!", "");
                    },
                    error: function() {
                        alert("Cập nhật mô tả thất bại!");
                    }
                });
            });
            $("#btnAddAttachment").on("click", function() {
                // Show menu to choose file or link
                var menu = `
                    <div class="d-flex gap-2 mt-2">
                        <button class="btn btn-sm btn-outline-primary flex-1" id="btnChooseFile">
                            <i class="bi bi-file-earmark"></i> Tải file lên
                        </button>
                        <button class="btn btn-sm btn-outline-primary flex-1" id="btnChooseLink">
                            <i class="bi bi-link-45deg"></i> Thêm link
                        </button>
                    </div>
                `;

                if ($("#attachmentMenu").length === 0) {
                    $("#attachmentsList").after(`<div id="attachmentMenu">${menu}</div>`);
                } else {
                    $("#attachmentMenu").html(menu);
                }
            });
            $(document).on("click", "#btnChooseFile", function() {
                $("#attachmentMenu").remove();
                $("#uploadArea").show();
                attachmentMode = "file";
            });
            $(document).on("click", "#btnChooseLink", function() {
                $("#attachmentMenu").remove();
                $("#linkArea").show();
                attachmentMode = "link";
            });
            // Upload Area - Click to select file
            $("#uploadArea").on("click", function() {
                $("#fileInput").click();
            });
            // Drag and drop
            $("#uploadArea").on("dragover", function(e) {
                e.preventDefault();
                $(this).addClass("dragging");
            });
            $("#uploadArea").on("dragleave", function() {
                $(this).removeClass("dragging");
            });
            $("#uploadArea").on("drop", function(e) {
                e.preventDefault();
                $(this).removeClass("dragging");
                var files = e.originalEvent.dataTransfer.files;
   handleFileUpload(files);
            });
            // File input change
            $("#fileInput").on("change", function() {
                handleFileUpload(this.files);
            });
            $("#btnSaveLink").on("click", function() {
                var name = $("#txtLinkName").val().trim();
                var url = $("#txtLinkURL").val().trim();

                if (!name || !url) {
                    alert("Vui lòng nhập đầy đủ thông tin!");
                    return;
                }

                AjaxHPAParadise({
                    data: {
                        name: "sp_Task_AddAttachment",
                        param: [
                            "TaskID", currentTaskID,
                            "FileName", name,
                            "FilePath", url,
                            "UploadedBy", LoginID,
                            "IsLink", 1
                        ]
                    },
                    success: function() {
                        $("#linkArea").hide();
                        $("#txtLinkName, #txtLinkURL").val("");
                        loadAttachments(currentTaskID);
                        showSuccessNotification("Thêm link thành công!", "");
                    },
                    error: function() {
                        alert("Thêm link thất bại!");
                    }
                });
            });
            $("#btnCancelLink").on("click", function() {
                $("#linkArea").hide();
                $("#txtLinkName, #txtLinkURL").val("");
            });
            $(document).on("click", ".subtask-priority, .st-priority", function(e) {
                e.stopPropagation();
            });
            $("#viewListT").click(function() {
                switchView("list");
            });
            $("#viewKanbanT").click(function() {
                switchView("kanban");
            });
        }
        function loadTasks() {
            AjaxHPAParadise({
                data: { name: "sp_Task_GetMyTasks", param: ["LoginID", LoginID] },
                success: function(response) {
                    try {
                        var res = JSON.parse(response);
                        var headers = res.data[0] || [];      // Headers
                        var headerTasks = res.data[1] || [];  // Tasks với HeaderID
                        var standaloneTasks = res.data[2] || []; // Tasks không có HeaderID

                        // Lưu vào biến global
                        window.taskHeaders = headers;
                        window.headerTasksMap = {};

                        // Phân loại tasks theo HeaderID
                        headerTasks.forEach(function(task) {
                            if (!window.headerTasksMap[task.HeaderID]) {
                                window.headerTasksMap[task.HeaderID] = [];
                            }
                            window.headerTasksMap[task.HeaderID].push(task);
                        });

                        // Gộp tất cả tasks để tính statistics
                        allTasks = [...headerTasks, ...standaloneTasks];

                        // Ensure employees list is loaded so buildAssigneeIcons can resolve names.
                        AjaxHPAParadise({
                            data: { name: "sp_Task_GetAssignmentSetup", param: [] },
                            success: function(setupRes) {
                                try {
                                    var setupData = JSON.parse(setupRes).data || [];
                                    employees = setupData[2] || employees || [];
                                } catch (ex) { console.warn(ex); }
                                // Now we have employees (or empty) -> proceed to render
                                updateStatistics();
                                filterTasks();
                                switchView("list");
                            },
                            error: function() {
                                // Failed to load employees - continue anyway (will fallback to IDs)
                                updateStatistics();
                                filterTasks();
                                switchView("list");
                            }
                        });
                    } catch(e) {
                        console.error(e);
                    }
                }
            });
        }
        function loadAttachments(taskId) {
            AjaxHPAParadise({
                data: { name: "sp_Task_GetDetail", param: ["TaskID", taskId, "LoginID", LoginID] },
                success: function(res) {
                    try {
                        var data = JSON.parse(res).data;
                        var attachments = data[4] || []; // data[4]: Attachments
                        renderAttachments(attachments);
                    } catch(e) {
                        console.error(e);
                        renderAttachments([]);
                    }
                }
            });
        }
        function renderAttachments(attachments) {
            if (attachments.length === 0) {
                $("#attachmentsList").html(`<p class="text-muted small">Chưa có tài liệu nào</p>`);
                return;
            }

            var html = attachments.map(function(a) {
                var icon = getFileIcon(a.FileName);
                var isLink = a.FilePath && (a.FilePath.startsWith("http://") || a.FilePath.startsWith("https://"));

                return `
                    <div class="attachment-item">
                        <div class="attachment-icon">
                            <i class="bi ${icon}"></i>
                        </div>
                        <div class="attachment-info">
                            <div class="attachment-name">${escapeHtml(a.FileName)}</div>
                            <div class="attachment-meta">
                                <i class="bi bi-person-circle"></i> ${escapeHtml(a.UploadedByName || a.UploadedBy)}
                                | <i class="bi bi-calendar"></i> ${formatSimpleDate(a.UploadedDate)}
                            </div>
                        </div>
                        <div class="attachment-actions">
                            ${isLink ?
                                `<button class="btn-attachment" onclick="window.open("${a.FilePath}", "_blank")">
                                    <i class="bi bi-box-arrow-up-right"></i> Mở
                                </button>` :
                                `<button class="btn-attachment" onclick="downloadAttachment(${a.AttachID})">
                                    <i class="bi bi-download"></i> Tải về
                                </button>`
                            }
                            <button class="btn-attachment delete" onclick="deleteAttachment(${a.AttachID})">
                                <i class="bi bi-trash"></i>
                            </button>
                        </div>
                    </div>
                `;
            }).join("");

            $("#attachmentsList").html(html);
        }
        function getFileIcon(filename) {
            var ext = filename.substring(filename.lastIndexOf(".")).toLowerCase();
            var icons = {
                ".pdf": "bi-file-pdf-fill",
                ".doc": "bi-file-word-fill",
                ".docx": "bi-file-word-fill",
                ".xls": "bi-file-excel-fill",
                ".xlsx": "bi-file-excel-fill",
                ".jpg": "bi-file-image-fill",
                ".jpeg": "bi-file-image-fill",
                ".png": "bi-file-image-fill"
            };
            return icons[ext] || "bi-file-earmark-fill";
        }
        function downloadAttachment(attachId) {
            window.location.href = `/api/task/download/${attachId}`;
        }
        function deleteAttachment(attachId) {
            if (!confirm("Bạn có chắc chắn muốn xóa tài liệu này?")) return;

            AjaxHPAParadise({
                data: {
                    name: "sp_Task_DeleteAttachment",
                    param: ["AttachID", attachId]
                },
                success: function() {
                    loadAttachments(currentTaskID);
                    showSuccessNotification("Xóa tài liệu thành công!", "");
                },
                error: function() {
                    alert("Xóa tài liệu thất bại!");
                }
            });
        }
        function handleFileUpload(files) {
            if (files.length === 0) return;

            // Validate file size and type
            var validFiles = [];
            var maxSize = 10 * 1024 * 1024; // 10MB
            var allowedTypes = [".pdf", ".doc", ".docx", ".xls", ".xlsx", ".jpg", ".jpeg", ".png"];

            for (var i = 0; i < files.length; i++) {
                var file = files[i];
                var ext = file.name.substring(file.name.lastIndexOf(".")).toLowerCase();

                if (file.size > maxSize) {
                    alert(`File ${file.name} quá lớn (> 10MB)`);
                    continue;
                }

                if (allowedTypes.indexOf(ext) === -1) {
                    alert(`File ${file.name} không được hỗ trợ`);
                    continue;
                }

                validFiles.push(file);
            }

            if (validFiles.length === 0) return;

            // Upload files (you need to implement server-side upload endpoint)
            uploadFilesToServer(validFiles);
        }
        function uploadFilesToServer(files) {
            // This is a placeholder - implement your file upload logic
            var formData = new FormData();
            formData.append("TaskID", currentTaskID);
            formData.append("UploadedBy", LoginID);

            for (var i = 0; i < files.length; i++) {
                formData.append("files[]", files[i]);
            }

            // Example using jQuery AJAX
            $.ajax({
                url: "/api/task/upload", // Your upload endpoint
                type: "POST",
                data: formData,
                processData: false,
                contentType: false,
                success: function(response) {
                    $("#uploadArea").hide();
                    $("#fileInput").val("");
                    loadAttachments(currentTaskID);
                    showSuccessNotification("Tải file thành công!", "");
                },
                error: function() {
                    alert("Tải file thất bại!");
                }
            });
        }
        function filterOptionsForSearch(selectId, text, dropdownSelector) {
            var q = normalizeForSearch(text || "");
            var $select = $("#" + selectId);
            var $dropdown = $(dropdownSelector);
            var opts = $select.find("option");
            var html = "";
            opts.each(function() {
                var v = $(this).attr("value");
                var t = $(this).text() || "";
                if(!v) return; // skip placeholder
                var norm = normalizeForSearch(t);
                if(!q || norm.indexOf(q) !== -1) {
                    html += `<div class="search-item" data-target="${selectId}" data-value="${v}" style="padding:8px 12px; cursor:pointer; border-bottom:1px solid #f1f1f1;">${escapeHtml(t)}</div>`;
                }
            });
            if(html === "") html = `<div style="padding:8px 12px;color:#777;">Không tìm thấy</div>`;
            $dropdown.html(html).show();
        }
        function switchView(view) {
            $(".view-btn").removeClass("active");
            if (view === "list") {
                $("#viewListT").addClass("active");
            } else {
                $("#viewKanbanT").addClass("active");
            }
            currentView = view;
            if(view === "list") {
                $("#kanban-view").hide();
                $("#list-view").show();
                renderListView(filteredTasks);
            } else {
                $("#list-view").hide();
                $("#kanban-view").show();
                renderKanbanView(filteredTasks);
            }
        }
        function formatSimpleDate(dateString) {
            if(!dateString) return "";
            var d = new Date(dateString);
            if (isNaN(d.getTime())) return "";
            var day = ("0" + d.getDate()).slice(-2);
            var month = ("0" + (d.getMonth() + 1)).slice(-2);
            return day + "/" + month;
        }
        function escapeHtml(str) {
            if (str === null || str === undefined) return "";
            return String(str)
                .replace(/&/g, "&amp;")
       .replace(/</g, "&lt;")
                .replace(/>/g, "&gt;")
                .replace(/""/g, "&quot;")
                .replace(/"/g, "&#39;");
        }
        function normalizeForSearch(s) {
            if (!s && s !== "") return "";
            try {
                var str = String(s || "");
                // decompose accents, remove combining marks, lower-case
               return str.normalize ? str.normalize("NFD").replace(/[\u0300-\u036f]/g, "").toLowerCase() : str.toLowerCase();
            } catch (e) {
                return String(s || "").toLowerCase();
            }
        }
        function updateStatistics() {
            var todoCount = allTasks.filter(t => t.StatusCode == 1).length;
            var doingCount = allTasks.filter(t => t.StatusCode == 2).length;
            var doneCount = allTasks.filter(t => t.StatusCode == 3).length;
            var overdueCount = allTasks.filter(t => t.IsOverdue == 1).length;
            $("#stat-todo").text(todoCount);
            $("#stat-doing").text(doingCount);
            $("#stat-done").text(doneCount);
            $("#stat-overdue").text(overdueCount);
        }
        function filterTasks() {
            var statusFilter = $("#filterStatus").val();
            var overdueFilter = $("#filterOverdue").val();
            filteredTasks = allTasks.filter(function(t) {
                var statusMatch = !statusFilter || t.StatusCode == statusFilter;
                var overdueMatch = !overdueFilter || (overdueFilter == "1" && t.IsOverdue == 1);
                return statusMatch && overdueMatch;
            });
            if(currentView === "list") {
                renderListView(filteredTasks);
            } else {
                renderKanbanView(filteredTasks);
            }
        }
        function renderKanbanView(data) {
            // Gộp tất cả tasks từ headers và standalone
            let allVisibleTasks = [];

            if (window.taskHeaders) {
                window.taskHeaders.forEach(function(header) {
                    const headerTasks = window.headerTasksMap[header.HeaderID] || [];
                    allVisibleTasks = allVisibleTasks.concat(headerTasks);
                });
            }

            // Thêm standalone tasks
            const standaloneTaskIds = new Set(allVisibleTasks.map(t => t.TaskID));
            const standaloneTasks = data.filter(t => !standaloneTaskIds.has(t.TaskID));
            allVisibleTasks = allVisibleTasks.concat(standaloneTasks);

            // Filter theo status
            var todoTasks = allVisibleTasks.filter(t => t.StatusCode == 1);
            var doingTasks = allVisibleTasks.filter(t => t.StatusCode == 2);
            var doneTasks = allVisibleTasks.filter(t => t.StatusCode == 3);

            $("#count-todo").text(todoTasks.length);
            $("#count-doing").text(doingTasks.length);
            $("#count-done").text(doneTasks.length);

            renderTaskCards("#tasks-todo", todoTasks);
            renderTaskCards("#tasks-doing", doingTasks);
            renderTaskCards("#tasks-done", doneTasks);
        }

        function buildAssigneeIcons(t, maxVisible) {
            maxVisible = Number(maxVisible) || 3;
            try {
                // 1. Lấy danh sách EmployeeID từ các trường CSV
                var ids = [];
                var names = [];
                try {
                    var idsCsv = (t && (t.AssignedToEmployeeIDs)) ? (t.AssignedToEmployeeIDs || "") + "" : "";
                    if (idsCsv) ids = String(idsCsv).split(",").map(function(s){ return s.trim(); }).filter(Boolean);
                } catch (e) { ids = []; }

                // 2. Nếu không có danh sách ID từ CSV, thử lấy từ DOM (nếu dropdown đã được render)
                if (ids.length === 0) {
                    var taskIdForDom = (t && (t.TaskID || t.ChildTaskID || t.TaskId));
                    if ((taskIdForDom || taskIdForDom === 0) && rowAssigneeMap && rowAssigneeMap[taskIdForDom]) {
                        try {
                            var mapObj = rowAssigneeMap[taskIdForDom].idToName || {};
                            var mappedKeys = Object.keys(mapObj || {});
                            if (mappedKeys && mappedKeys.length) {
                                ids = mappedKeys.slice();
                                names = ids.map(function(k){ return mapObj[k] || ""; });
                            }
                        } catch(ex) {}
                    }
                    // Nếu vẫn chưa có, thử lấy từ DOM trực tiếp
                    if ((!names || names.length === 0) && ((taskIdForDom || taskIdForDom === 0) && typeof $ !== "undefined")) {
                        var $selected = $(`.row-assignee[data-taskid="${taskIdForDom}"] .row-assignee-dropdown .row-assignee-item.selected`);
                        if ($selected && $selected.length) {
                            ids = [];
                            names = [];
                            $selected.each(function(){ ids.push(String($(this).data("empid")||"")); names.push(($(this).data("empname")||$(this).find("div").eq(1).find("div").first().text()||"").trim()); });
                        }
                    }
                }

                // 3. Quan trọng nhất: DÙNG employees ARRAY để giải mã EmployeeID thành FullName
                // Nếu chưa có names, hoặc nếu names không khớp với IDs, hãy sử dụng employees để tìm tên
                if (!names || names.length === 0 || names.length !== ids.length) {
                    names = [];
                    for (var i = 0; i < ids.length; i++) {
                        var empId = String(ids[i] || "").trim();
                        if (!empId) {
                            names.push(""); // hoặc một giá trị mặc định
                            continue;
                        }
                        // Tìm employee trong mảng employees dựa trên EmployeeID
                        var foundEmp = (employees || []).find(emp => String(emp.EmployeeID) === empId);
                        if (foundEmp) {
                            names.push(foundEmp.FullName || foundEmp.EmployeeName || empId); // Sử dụng FullName nếu có
                        } else {
                            names.push(empId); // Nếu không tìm thấy, dùng ID làm fallback
                        }
                    }
                }

                // 4. Tạo HTML cho các icon-chip
                var parts = [];
                for (var i = 0; i < ids.length; i++) {
                    var nm = names[i] || ids[i] || "";
                    var initials = escapeHtml(getInitials(nm) || (nm.charAt(0)||"?").toUpperCase());
                    parts.push(`<div class="icon-chip" title="${escapeHtml(nm)}">${initials}</div>`);
                }

                var visible = parts.slice(0, maxVisible).join("");
                var remaining = Math.max(0, parts.length - maxVisible);
                if (remaining > 0) {
                    var tooltip = escapeHtml(names.join(", "));
                    visible += `<div class="icon-more" title="${tooltip}">+${remaining}</div>`;
                }

                if (!visible || visible.trim() === "") {
                    return `<div class="icon-chip" title="Chưa có người đảm nhiệm">?</div>`;
                }

                return visible;

            } catch (e) {
                console.error("Error in buildAssigneeIcons:", e);
                return `<div class="icon-chip">?</div>`;
            }
        }

        // Call this after tasks have been loaded/rendered so buildAssigneeIcons can use these names.
        // Because the backend no longer returns name columns, ensure `employees` is loaded
        // (via `sp_Task_GetAssignmentSetup`) and use it to resolve IDs -> names.
        function setRowAssigneeMapFromAllTasks() {
            try {
                if (!allTasks || !Array.isArray(allTasks)) return;

                var ensureEmployeesThenBuild = function(cb) {
                    if (employees && Array.isArray(employees) && employees.length) {
                        return cb();
                    }
                    AjaxHPAParadise({
                        data: { name: "sp_Task_GetAssignmentSetup", param: [] },
                        success: function(res) {
                            try {
                                var data = JSON.parse(res).data || [];
                                employees = data[2] || employees || [];
                            } catch (ex) { console.warn(ex); }
                            try { cb(); } catch(e) { console.warn(e); }
                        },
                        error: function() { try { cb(); } catch(e) { console.warn(e); } }
                    });
                };

                var buildMap = function() {
                    try {
                        var empMap = {};
                        if (employees && employees.length) {
                            for (var ei = 0; ei < employees.length; ei++) {
                                var emp = employees[ei];
                                if (!emp) continue;
                                var key = String(emp.EmployeeID || emp.Id || emp.ID || "");
                                empMap[key] = emp.FullName || emp.EmployeeName || emp.Name || emp.DisplayName || "";
                            }
                        }

                        // Build mapping per task by reading any available ID fields and resolving via empMap
                        for (var i = 0; i < allTasks.length; i++) {
                            var tt = allTasks[i];
                            var tid = tt && (tt.TaskID || tt.ChildTaskID || tt.TaskId);
                            if (!tid && tid !== 0) continue;

                            // Look for possible ID-containing fields (some may be removed on backend)
                            var candidate = "";
                            var fields = ["AssignedToEmployeeIDs","AssignedToEmployeeID","AssignedTo","Assigned","EmployeeID","AssignedIDs","AssignedEmployeeIDs","Assignees"];
                            for (var fi = 0; fi < fields.length; fi++) {
                                var f = fields[fi];
                                if (tt && tt[f]) { candidate = tt[f] + ""; break; }
                            }

                            var ids = [];
                            try { if (candidate) ids = String(candidate).split(",").map(function(s){ return String(s||"").trim(); }).filter(Boolean); } catch(e) { ids = []; }

                            var mapObj = {};
                            if (ids && ids.length) {
                                for (var k = 0; k < ids.length; k++) {
                                    var idKey = String(ids[k] || "");
                                    var nm = empMap[idKey] || "";
                                    mapObj[idKey] = nm;
                                }
                            }

                            if (Object.keys(mapObj).length) {
                                rowAssigneeMap[tid] = { idToName: mapObj };
                            }
                        }
                    } catch(err) { console.warn("buildRowAssigneeMap error", err); }
                };

                ensureEmployeesThenBuild(buildMap);
            } catch (e) { console.warn("setRowAssigneeMapFromAllTasks error:", e); }
        }

        function refreshTaskRowInList(taskId) {
            try {
                var t = findTaskById(taskId);
                if (!t) return;

                var $row = $(`.task-row[data-taskid=" + taskId + "]`);
                if ($row.length) {
                    // Determine if this is rendered as a child/subtask
                    var isChild = $row.hasClass("subtask-row") || $row.closest(".subtask-container").length > 0;
                    // Generate new HTML for the row and replace the existing node
                    var newHtml = renderTaskRow(t, !!isChild);
                    $row.replaceWith(newHtml);
                } else {
                    // Check inside subtask containers (headers) as a fallback
                    $(".subtask-container").each(function() {
                        var $r = $(this).find(`.task-row[data-taskid=" + taskId + "]`);
                        if ($r.length) {
                            $r.replaceWith(renderTaskRow(t, true));
                        }
                    });
                }

                // Re-init drag & drop since rows may have been replaced
                try { initListDragDrop(); } catch (e) { /* ignore */ }
            } catch (e) { console.warn(e); }
        }

        function renderTaskCards(container, tasks) {
            if(tasks.length === 0) {
                $(container).html(`<div class="empty-state"><i class="bi bi-inbox"></i><p>Không có công việc</p></div>`);
                return;
            }
            var html = tasks.map(function(t) {
                // DÙNG AssignPriority thay vì Priority
                var prioClass = "prio-" + (t.AssignPriority || 3);
                var startStr = formatSimpleDate(t.MyStartDate);
                var dueStr = formatSimpleDate(t.DueDate);
                var dateRange = (startStr || dueStr) ? (startStr + " - " + dueStr) : "";
                var dateClass = t.IsOverdue ? "overdue" : "";
                // HIỂN THỊ TIẾN ĐỘ THEO KPI HOẶC TASK CON
                var kpiDisplayText = "";
                if (t.TargetKPI > 0) {
                    kpiDisplayText = `${t.ActualKPI} / ${t.TargetKPI} ${t.Unit || ""}`;
                } else if (t.TotalSubtasks > 0) {
                    kpiDisplayText = `${t.CompletedSubtasks || 0} / ${t.TotalSubtasks} task`;
                } else {
                    kpiDisplayText = "Chưa có tiến độ";
                }
                return `
                <div class="cu-row task-row" data-taskid="${t.TaskID}">
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
        function renderListView(data) {
            if (data.length === 0 && (!window.taskHeaders || window.taskHeaders.length === 0)) {
                $("#list-container").html(`<div class="empty-state"><i class="bi bi-inbox"></i><p>Không có công việc nào</p></div>`);
                return;
            }

            const htmlParts = [];
            const renderedTaskIds = new Set();

            // 1. Render Headers và các task thuộc header
            if (window.taskHeaders && window.taskHeaders.length > 0) {
                window.taskHeaders.forEach(function(header) {
                    const headerTasks = window.headerTasksMap[header.HeaderID] || [];
                    const visibleTasks = headerTasks.filter(t => data.some(d => d.TaskID === t.TaskID));

                    if (visibleTasks.length === 0) return; // Skip header không có task nào visible

                    // Mark tasks as rendered
                    visibleTasks.forEach(t => renderedTaskIds.add(t.TaskID));

                    // Render header row
                    htmlParts.push(renderHeaderRow(header, visibleTasks));

                    // Render subtasks container (hidden by default)
                    const subtasksHtml = visibleTasks.map(t => renderTaskRow(t, true, false)).join("");
                    htmlParts.push(`<div class="subtask-container" id="subtasks-header-${header.HeaderID}">${subtasksHtml}</div>`);
                });
            }

            // 2. Render standalone tasks (không có HeaderID)
            const standaloneTasks = data.filter(t => !renderedTaskIds.has(t.TaskID));

            if (standaloneTasks.length > 0) {
                // Group by parent-child
                const tasksById = {};
                standaloneTasks.forEach(t => tasksById[t.TaskID] = t);

                const childMap = {};
                standaloneTasks.forEach(t => {
                    if (t.ParentTaskID && tasksById[t.ParentTaskID]) {
                        childMap[t.ParentTaskID] = childMap[t.ParentTaskID] || [];
                        childMap[t.ParentTaskID].push(t);
                    }
                });

                standaloneTasks.forEach(t => {
                    if (t.ParentTaskID && tasksById[t.ParentTaskID]) return;

                    const subtasks = childMap[t.TaskID] || [];
                    const hasSubtasks = subtasks.length > 0;

                    htmlParts.push(renderTaskRow(t, false, hasSubtasks));

                    if (hasSubtasks) {
                        const subHtml = subtasks.map(st => renderTaskRow(st, true, false)).join("");
                        htmlParts.push(`<div class="subtask-container" id="subtasks-${t.TaskID}" style="display:none;">${subHtml}</div>`);
                    }

                    renderedTaskIds.add(t.TaskID);
                });
            }

            $("#list-container").html(htmlParts.join(""));
            try { setRowAssigneeMapFromAllTasks(); } catch(e) { console.warn(e); }
            setTimeout(function() {
                for (var headerId in expandedHeadersState) {
                    if (expandedHeadersState[headerId]) {
                        $(`#subtasks-header-${headerId}`).addClass("show");
                        $(`#expand-icon-${headerId}`).removeClass("bi-caret-right").addClass("bi-caret-down");
                        $(`.header-row[data-headerid="${headerId}"]`).addClass("expanded");
                    }
                }

                // INIT DRAG & DROP cho list
                initListDragDrop();
            }, 50);
        }
        function renderHeaderRow(header, tasks) {
            const completedCount = tasks.filter(t => t.StatusCode === 3).length;
            const totalCount = tasks.length;
            const progressPct = totalCount > 0 ? Math.round((completedCount / totalCount) * 100) : 0;

            const hasOverdue = tasks.some(t => t.IsOverdue === 1);
            const startDate = formatSimpleDate(header.StartDate);

            return `
            <div class="cu-row header-row" data-headerid="${header.HeaderID}" draggable="false">
                <div class="row-check" style="width:40px;">
                    <i class="bi bi-caret-right expand-icon" id="expand-icon-${header.HeaderID}"></i>
                </div>
                <div class="row-main" style="flex:1;">
                    <div class="task-title">
                        <i class="bi bi-folder-fill"></i> ${escapeHtml(header.HeaderTitle)}
                        <span class="header-badge">${totalCount} công việc</span>
                    </div>
                </div>
                <div class="row-progress" style="width:220px;">
                    <div class="kpi-text">
                        <span>${completedCount}/${totalCount} hoàn thành</span>
                        <strong style="color: white">${progressPct}%</strong>
                    </div>
                    <div class="kpi-bar-bg" style="background: rgba(255,255,255,0.3);">
                        <div class="kpi-bar-fill" style="width: ${progressPct}%; background: rgba(255,255,255,0.8);"></div>
                    </div>
                </div>
            </div>`;
        }
        function toggleHeaderExpand(headerId) {
            const $container = $(`#subtasks-header-${headerId}`);
            const $icon = $(`#expand-icon-${headerId}`);
            const $row = $(`.header-row[data-headerid="${headerId}"]`);

            const isVisible = $container.hasClass("show");

            if (isVisible) {
                $container.removeClass("show");
                $icon.removeClass("bi-caret-down").addClass("bi-caret-right");
                $row.removeClass("expanded");
            } else {
                $container.addClass("show");
                $icon.removeClass("bi-caret-right").addClass("bi-caret-down");
                $row.addClass("expanded");
            }
        }
        function renderTaskRow(t, isChild) {
            var startStr = formatSimpleDate(t.MyStartDate);
            var dueStr = formatSimpleDate(t.DueDate);
            var dateRange = (startStr || dueStr) ? (startStr + " - " + dueStr) : "";
            var dateClass = t.IsOverdue ? "overdue" : "";
            var prioClass = "prio-" + (t.AssignPriority || 3);

            var kpiDisplayText = "";
            if (t.TargetKPI > 0) {
                kpiDisplayText = `${t.ActualKPI} / ${t.TargetKPI} ${t.Unit || ""}`;
            } else if (t.TotalSubtasks > 0) {
                kpiDisplayText = `${t.CompletedSubtasks || 0} / ${t.TotalSubtasks} task`;
            } else {
                kpiDisplayText = "Chưa có tiến độ";
            }

            // Nếu là subtask (isChild=true) -> hiển thị đơn giản: Tên, độ ưu tiên (select), người nhận (icon + dropdown), trạng thái
            if (isChild) {
                var assigneeId =  t.AssignedTo || "";
                var assigneeName = t.AssignedToName || t.AssignedTo || t.EmployeeName || t.MainResponsibleName || "-";
                var prioVal = t.AssignPriority || t.Priority || 3;

                // Build priority select (1=High,2=Medium,3=Low)
                var prioSelect = `
                    <select class="form-select row-priority-select" data-taskid="${t.TaskID}" style="width:110px;">
                        <option value="1" ${prioVal==1?"selected":""}>Cao</option>
                        <option value="2" ${prioVal==2?"selected":""}>Trung bình</option>
                        <option value="3" ${prioVal==3?"selected":""}>Thấp</option>
                    </select>`;

                // Build assignee display with dropdown/search
                var assigneeHtml = `
                    <div class="row-assignee" data-taskid="${t.TaskID}" style="position:relative;">
                        <button type="button" class="btn btn-sm btn-light row-assignee-toggle" data-taskid="${t.TaskID}" style="display:flex;align-items:center;gap:8px;padding:6px 8px;">
                            <div class="assignee-icons" style="display:flex;align-items:center;gap:0;">${buildAssigneeIcons(t, 3)}</div>
                            <i class="bi bi-chevron-down" style="font-size:12px;color:var(--text-muted);"></i>
                        </button>
                        <div class="row-assignee-dropdown" style="display:none;position:absolute;right:0;top:36px;z-index:2000;width:320px;backdrop-filter:blur(50px);border:1px solid var(--border-color);border-radius:6px;box-shadow:var(--shadow-md);">
                            <div style="padding:8px;border-bottom:1px solid var(--border-color);">
                                <input type="text" class="form-control form-control-sm row-assignee-search" placeholder="Tìm nhân viên..." />
                            </div>
                            <div class="row-assignee-list" style="max-height:260px;overflow:auto;padding:4px 0;">
                            </div>
                        </div>
                    </div>`;

                // status for subtask
                var stClass = t.StatusCode == 2 ? "sts-2" : t.StatusCode == 3 ? "sts-3" : "sts-1";
                var statusLabel = t.StatusLabel || (t.StatusCode == 1 ? "Chưa làm" : (t.StatusCode == 2 ? "Đang làm" : "Hoàn thành"));
                var statusHtml = `<span class="badge-sts ${stClass} badge-toggle-status" data-taskid="${t.TaskID}" data-status="${t.StatusCode}">${statusLabel}</span>`;

                // Return simplified row HTML
                return `
                <div class="cu-row task-row draggable subtask-row" data-taskid="${t.TaskID}" draggable="true" style="padding-left:30px; display:flex;align-items:center;gap:12px;">
                    <div class="row-check" style="width:40px;">
                        <i class="bi bi-grip-vertical row-drag-handle"></i>
                        <i class="bi bi-flag-fill priority-icon ${prioClass}"></i>
                    </div>
                    <div class="row-main" style="flex:1;min-width:0;">
                        <div class="task-title" title="${escapeHtml(t.TaskName)}">${t.TaskName}</div>
                    </div>
                    <div style="width:120px;flex-shrink:0;">${prioSelect}</div>
                    <div style="width:260px;flex-shrink:0;">${assigneeHtml}</div>
                    <div style="width:140px;flex-shrink:0;text-align:right;">${statusHtml}</div>
                </div>`;
            }

            var statusHtml = "";
            if (t.HasSubtasks) {
                statusHtml = `<span class="badge-sts sts-2">Có con</span>`;
            } else {
                var stClass = t.StatusCode == 2 ? "sts-2" : t.StatusCode == 3 ? "sts-3" : "sts-1";
                var statusLabel = (t.StatusCode == 1 ? "Chưa làm" : (t.StatusCode == 2 ? "Đang làm" : "Hoàn thành"));
                statusHtml = `<span class="badge-sts ${stClass} badge-toggle-status" data-taskid="${t.TaskID}" data-status="${t.StatusCode}">${statusLabel}</span>`;
            }

            return `
            <div class="cu-row task-row draggable"
                style="${isChild ? "padding-left:30px;" : ""}"
                data-taskid="${t.TaskID}"
                draggable="true">
                <div class="row-check">
                    <i class="bi bi-grip-vertical row-drag-handle"></i>
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
                <div class="row-status">
                    ${statusHtml}
                </div>
                <div class="row-meta">
                    ${dateRange ? `<span class="date-range ${dateClass}">${dateRange}</span>` : ""}
                    ${t.IsOverdue ? `<small class="text-danger mt-1 fw-bold"><i class="bi bi-exclamation-triangle-fill"></i> Quá hạn</small>` : ""}
                </div>
            </div>`;
        }
        function openTaskDetail(taskID) {
			// Tìm task từ tất cả các nguồn
			let task = findTaskById(taskID);
			if (!task) {
				console.error("Task not found:", taskID);
				alert("Không tìm thấy thông tin công việc!");
				return;
			}
			currentTaskID = taskID;

			// Populate modal với thông tin từ local data
			$("#detailTaskName").text(task.TaskName || "");
			$("#detailCreator").text(task.RequestedByName || task.RequestedBy || "-");
			$("#detailMainResponsible").text(task.MainResponsibleName || task.MainResponsibleID || "-");
			$("#detailStartDate").text(formatSimpleDate(task.MyStartDate));
			$("#detailDueDate").text(formatSimpleDate(task.MyDueDate || task.DueDate));
			$("#detailActualKPI").text(task.ActualKPI || 0);
			$("#detailTargetKPI").text(task.KPIPerDay || task.TargetKPI || 0);
			$("#detailUnit").text(task.Unit || "");
			$("#detailProgressPct").text((task.ProgressPct || 0) + "%");
			$("#detailProgressBar").css("width", Math.min(task.ProgressPct || 0, 100) + "%");
			$("#txtUpdateKPI").val("");
			$("#txtUpdateNote").val("");

			// Render comments nếu có lưu trong task, nếu không thì để rỗng
			if (task.Comments) {
				renderComments(task.Comments);
			} else {
				renderComments([]);
			}

			// Hide/Show KPI section
			var hasKPI = (task.KPIPerDay && task.KPIPerDay > 0) || task.HasSubtasks || task.TotalSubtasks > 0;
			if (!hasKPI) {
				$(".kpi-section").hide();
			} else {
				$(".kpi-section").show();
			}

			// Load subtasks if parent (nếu có lưu local thì render, nếu không thì ẩn)
			if (task.HasSubtasks || task.TotalSubtasks > 0) {
				if (task.Subtasks) {
					renderSubtaskTable(task.Subtasks);
					$("#subtaskTableContainer").show();
				} else {
					$("#subtaskTableContainer").hide();
				}
			} else {
				$("#subtaskTableContainer").hide();
			}

            // Blur and show modal
            try {
                if (document.activeElement && typeof document.activeElement.blur === "function") {
                    document.activeElement.blur();
                }
            } catch(e) {
                console.warn(e);
            }

            var mdl = new bootstrap.Modal(document.getElementById("mdlTaskDetail"));
            mdl.show();

            setTimeout(function() {
                try {
                    document.getElementById("mdlTaskDetail").focus();
                } catch(e) {}
            }, 80);
        }
        function findTaskById(taskId) {
            // Try header tasks first
            if (window.headerTasksMap) {
                for (let headerId in window.headerTasksMap) {
                    const found = window.headerTasksMap[headerId].find(t => t.TaskID == taskId);
                    if (found) return found;
                }
            }

            // Try allTasks
            const found = allTasks.find(t => t.TaskID == taskId);
            if (found) return found;

            return null;
        }
        function loadSubtasksForDetail(parentTaskID) {
            // First fetch the template (list of child tasks), then call assign-history once for all child IDs
            AjaxHPAParadise({
                data: {
                    name: "sp_Task_GetDetailedTemplate",
                    param: ["ParentTaskID", parentTaskID]
                },
                success: function(res) {
                    try {
                        var templateData = JSON.parse(res).data[0] || [];
                        if (templateData.length === 0) {
                            $("#subtaskTableContainer").hide();
                            return;
                        }

                        // Build CSV of child IDs
                        var ids = templateData.map(function(c){ return c.ChildTaskID; }).filter(function(x){ return x !== undefined && x !== null; });
                        if(ids.length === 0) {
                            $("#subtaskTableContainer").hide();
                            return;
                        }
                        var csv = ids.join(",");

                        // Call backend once to fetch assign history for all child tasks for current user
                        AjaxHPAParadise({
                            data: {
                                name: "sp_Task_GetAssignHistoryForTaskAndEmployee",
                                param: ["TaskIDs", csv, "EmployeeID", LoginID]
                            },
                            success: function(subRes) {
                                try {
                                    var rows = JSON.parse(subRes).data[0] || [];
                                    // Normalize into a map by TaskID
                                    var map = {};
                                    rows.forEach(function(r){
                                        try { map[String(r.TaskID)] = r; } catch(e) {}
                                    });

                                    var subtasks = templateData.map(function(child){
                                        var d = map[String(child.ChildTaskID)] || {};
                                        return {
                                            ChildTaskID: child.ChildTaskID,
                                            ChildTaskName: child.ChildTaskName,
                                            EmployeeID: d.EmployeeID || "-",
                                            StartDate: d.StartDate || d.SubtaskStartDate || "",
                                            EndDate: d.EndDate || d.SubtaskEndDate || "",
                                            ActualKPI: d.ActualKPI || d.SubtaskActualKPI || 0,
                                            TargetKPI: child.DefaultKPI || 0,
                                            Progress: d.Progress || d.SubtaskProgress || 0,
                                            Status: d.Status || "Pending",
                                            AssignPriority: d.AssignPriority || child.Priority || 3
                                        };
                                    });

                                    renderSubtaskTable(subtasks);
                                } catch(e) {
                                    console.error(e);
                                    // Fallback: build from template only
                                    var subtasksFallback = templateData.map(function(child){
                                        return {
                                            ChildTaskID: child.ChildTaskID,
                                            ChildTaskName: child.ChildTaskName,
                                            EmployeeID: "-",
                                            StartDate: "",
                                            EndDate: "",
                                            ActualKPI: 0,
                                            TargetKPI: child.DefaultKPI || 0,
                                            Progress: 0,
                                            Status: "Pending",
                                            AssignPriority: child.Priority || 3
                                        };
                                    });
                                    renderSubtaskTable(subtasksFallback);
                                }
                            },
                            error: function() {
                                // fallback if assign-history endpoint fails
                                var subtasksFallback = templateData.map(function(child){
                                    return {
                                        ChildTaskID: child.ChildTaskID,
                                        ChildTaskName: child.ChildTaskName,
                                        EmployeeID: "-",
                                        StartDate: "",
                                        EndDate: "",
                                        ActualKPI: 0,
                                        TargetKPI: child.DefaultKPI || 0,
                                        Progress: 0,
                                        Status: "Pending",
                                        AssignPriority: child.Priority || 3
                                    };
                                });
                                renderSubtaskTable(subtasksFallback);
                            }
                        });
                    } catch(e) {
                        console.error(e);
                        $("#subtaskTableContainer").hide();
                    }
                }
            });
        }
        function updateTaskStatus(newStatus) {
            if (!currentTaskID) return;

            AjaxHPAParadise({
                data: {
                    name: "sp_Task_UpdateStatus",
                    param: ["TaskID", currentTaskID, "LoginID", LoginID, "NewStatus", newStatus]
                },
                success: function() {
                    // Update UI
                    $(".status-option").removeClass("active");
                    $(`.status-option[data-status="${newStatus}"]`).addClass("active");

                    // Show notification
                    showSuccessNotification("Cập nhật trạng thái thành công!",
                        newStatus === 1 ? "Đã chuyển sang Chưa làm" :
                        newStatus === 2 ? "Đã chuyển sang Đang làm" :
               "Đã chuyển sang Hoàn thành");

                    // Reload tasks
                    loadTasks();
                },
                error: function() {
                    alert("Cập nhật trạng thái thất bại!");
                }
            });
        }
        function renderSubtaskTable(subtasks) {
            if (!subtasks || subtasks.length === 0) {
                $("#subtaskTableContainer").hide();
                return;
            }

            // Build employee options for assignee select
            var empOptions = (employees || []).map(function(e) {
                return `<option value="${e.EmployeeID}">${escapeHtml(e.FullName)} (${e.EmployeeID})</option>`;
            }).join("");

            var html = subtasks.map(function(s) {
                // Normalize status
                var statusCode = 1;
                if (s.Status !== undefined && s.Status !== null) {
                    if (!isNaN(Number(s.Status))) {
                        statusCode = Number(s.Status);
                    } else {
                        var st = String(s.Status).toLowerCase();
                        if (st.indexOf("done") !== -1 || st === "completed" || st === "hoàn thành") statusCode = 3;
                        else if (st.indexOf("doing") !== -1 || st.indexOf("đang") !== -1) statusCode = 2;
                        else statusCode = 1;
                    }
                }
                var stClass = statusCode === 3 ? "sts-3" : statusCode === 2 ? "sts-2" : "sts-1";
                var statusLabel = statusCode === 3 ? "Hoàn thành" : statusCode === 2 ? "Đang làm" : "Chưa làm";

                var progressPercent = s.TargetKPI > 0 ? Math.min(Math.round((s.ActualKPI / s.TargetKPI) * 100), 100) : (s.Progress || 0);
                var prio = s.AssignPriority || 3;

                // Build assignee select with current value(s)
                var currentAssignees = [];
                try {
                    if (Array.isArray(s.EmployeeID)) currentAssignees = s.EmployeeID.slice();
                    else if (s.EmployeeID && String(s.EmployeeID).indexOf(",") !== -1) currentAssignees = String(s.EmployeeID).split(",").map(x=>x.trim());
                    else if (s.EmployeeID && String(s.EmployeeID).trim() && String(s.EmployeeID) !== "-") currentAssignees = [String(s.EmployeeID).trim()];
                    currentAssignees = currentAssignees.filter(function(id){ return id && String(id).trim() && String(id) !== "-"; });
                } catch(e) {}

                var assigneeSelectHtml = `
                    <select class="form-select subtask-assignee" data-childid="${s.ChildTaskID}" multiple style="max-height:80px;">
                        ${(employees || []).map(function(e) {
                            var selected = currentAssignees.indexOf(String(e.EmployeeID)) !== -1 ? "selected" : "";
                            return `<option value="${e.EmployeeID}" ${selected}>${escapeHtml(e.FullName)}</option>`;
                        }).join("")}
                    </select>
                `;

                return `
                <tr data-childid="${s.ChildTaskID}" class="subtask-row-draggable" draggable="true">
                    <td class="drag-handle" style="text-align:center; cursor:grab;">
                        <i class="bi bi-grip-vertical"></i>
                    </td>
                    <td style="max-width:200px; overflow:hidden; text-overflow:ellipsis; white-space:nowrap;" title="${escapeHtml(s.ChildTaskName)}">
                        ${escapeHtml(s.ChildTaskName)}
                    </td>
                    <td>${assigneeSelectHtml}</td>
                    <td style="font-size:13px;">${formatSimpleDate(s.StartDate)}</td>
                    <td style="font-size:13px;">${formatSimpleDate(s.EndDate)}</td>
                    <td class="progress-cell">
                        <div class="kpi-text">
                     <strong>${progressPercent}%</strong>
                        </div>
                        <div class="progress-bar-bg">
                            <div class="progress-bar-fill" style="width: ${progressPercent}%"></div>
                        </div>
                    </td>
                    <td class="status-cell" style="text-align:center;">
                        <span class="badge-sts subtask-toggle-status ${stClass}" data-childid="${s.ChildTaskID}" data-status="${statusCode}">${statusLabel}</span>
                    </td>
                    <td class="priority-cell">
                        <select class="form-select subtask-priority" data-childid="${s.ChildTaskID}" style="font-size:12px;">
                            <option value="1" ${prio==1?"selected":""}>Cao</option>
                            <option value="2" ${prio==2?"selected":""}>Trung bình</option>
                            <option value="3" ${prio==3?"selected":""}>Thấp</option>
                        </select>
                    </td>
                </tr>
                `;
            }).join("");

            $("#subtaskTableBody").html(html);
            $("#subtaskTableContainer").show();

            // Initialize drag and drop sau khi DOM đã render
            setTimeout(function() {
                initSubtaskDragDrop();
            }, 100);

            // Toggle KPI section
            try {
                var parentKPI = parseInt($("#detailTargetKPI").text() || "0") || 0;
                var anySubKPI = (subtasks || []).some(function(x){ return x.TargetKPI && Number(x.TargetKPI) > 0; });
                if(!parentKPI && !anySubKPI) {
                    $(".kpi-section").hide();
                } else {
                    $(".kpi-section").show();
                }
            } catch(e) {}
        }
        function renderComments(comments) {
            if(comments.length === 0) {
                $("#commentsList").html(`<p class="text-muted small">Chưa có nhận xét nào</p>`);
                return;
            }

            var html = comments.map(c => `
                <div class="comment-item">
                    <div class="comment-header">
                        <span class="comment-author">
                            <i class="bi bi-person-circle"></i>
                            ${escapeHtml(c.EmployeeName || c.EmployeeID || "Unknown")}
                        </span>
                        <span class="comment-date">${formatSimpleDate(c.CreatedDate)}</span>
                    </div>
                    <div class="comment-content">${escapeHtml(c.Content)}</div>
                </div>
            `).join("");

            $("#commentsList").html(html);
        }
        function updateKPI() {
            var val = $("#txtUpdateKPI").val();
            var note = $("#txtUpdateNote").val();

            if(!val || val == "") {
                alert("Vui lòng nhập giá trị KPI!");
                return;
            }

            AjaxHPAParadise({
                data: {
                    name: "sp_Task_UpdateKPI",
                    param: [
                        "TaskID", currentTaskID,
                        "LoginID", LoginID,
                        "ActualKPI", val,
                        "Note", note
                    ]
                },
                success: function(res) {
                    try {
                        // Close modal
                        var modalInstance = bootstrap.Modal.getInstance(document.getElementById("mdlTaskDetail"));
                        if (modalInstance) {
                            modalInstance.hide();
                        }

                        // Show success message
                        showSuccessNotification("Cập nhật KPI thành công!", `Đã cập nhật KPI: ${val}`);

                        // Reload tasks
                        loadTasks();
                    } catch(e) {
                        console.error("Error after updating KPI:", e);
                        loadTasks();
                    }
                },
                error: function(err) {
                    console.error("Error updating KPI:", err);
                    alert("Cập nhật KPI thất bại!");
                }
            });
        }
        function showSuccessNotification(title, message) {
            // Simple toast notification
            var toastHtml = `
                <div class="position-fixed top-0 end-0 p-3" style="z-index: 9999;">
                    <div class="toast show" role="alert">
                        <div class="toast-header bg-success text-white">
                            <i class="bi bi-check-circle-fill me-2"></i>
                            <strong class="me-auto">${escapeHtml(title)}</strong>
                            <button type="button" class="btn-close btn-close-white" onclick="$(this).closest(".toast").parent().remove()"></button>
                        </div>
                        <div class="toast-body">
                            ${escapeHtml(message)}
                        </div>
                    </div>
                </div>
            `;

            var $toast = $(toastHtml);
            $("body").append($toast);

            setTimeout(function() {
                $toast.fadeOut(300, function() {
                    $(this).remove();
                });
            }, 3000);
        }
        function toggleStatus(taskID, currentCode) {
            var nextCode = currentCode >= 3 ? 1 : currentCode + 1;

            AjaxHPAParadise({
                data: {
                    name: "sp_Task_UpdateStatus",
                    param: [
                        "TaskID", taskID,
                        "LoginID", LoginID,
                        "NewStatus", nextCode
                    ]
                },
                success: function() {
                    var task = findTaskById(taskID);
                    if (task) {
                        task.StatusCode = nextCode;
                    }
                    var statusLabel = nextCode === 1 ? "Chưa làm" : nextCode === 2 ? "Đang làm" : "Hoàn thành";
                    var stClass = nextCode === 1 ? "sts-1" : nextCode === 2 ? "sts-2" : "sts-3";

                    $(`.badge-toggle-status[data-taskid="${taskID}"]`)
                        .removeClass("sts-1 sts-2 sts-3")
                        .addClass(stClass)
                        .text(statusLabel)
                        .data("status", nextCode);

                    // Reload toàn bộ sau 500ms (để người dùng thấy update ngay lập tức)
                    setTimeout(function() {
                        loadTasks();
                    }, 500);
                },
                error: function(err) {
                    console.error("Error updating status:", err);
                    alert("Cập nhật trạng thái thất bại!");
                }
            });
        }
        function openAssignModal() {
            // Reset internal state and UI each time modal opens
            currentTemplate = [];
            currentChildTasks = [];
            $("#selParent").html("");
            $("#selAssignedBy").html("");
            $("#selMainUser").html("");
            $("#subtask-assign-container").html(`<div class="empty-state" style="grid-column: 1 / -1;"><i class="bi bi-inbox"></i><p>Vui lòng chọn Công việc chính ở trên</p></div>`);
            // Fetch setup
            AjaxHPAParadise({
                data: {
                    name: "sp_Task_GetAssignmentSetup",
                    param: []
                },
                success: function(res) {
                    try {
                        let data = JSON.parse(res).data;
                        headers = data[0] || [];
                        tasks = data[1] || [];
                        employees = data[2] || [];
                    } catch(e) { console.warn(e); }
                    renderAssignDropdowns();
                    try {
                        if (document.activeElement && typeof document.activeElement.blur === "function") {
                            document.activeElement.blur();
                        }
                    } catch(e) { console.warn(e); }
                    var mdl = new bootstrap.Modal(document.getElementById("mdlAssign"));
                    mdl.show();
                    setTimeout(function() {
                        try { document.getElementById("mdlAssign").focus(); } catch(e) {}
                    }, 80);
                }
            });
        }
        function renderAssignDropdowns() {
            $("#selParent").html(`<option value=""></option>` +
                tasks.map(t => `<option value="${t.TaskID}">${escapeHtml(t.TaskName)}</option>`).join(""));
            let empOpts = `<option value="">-- Chọn nhân viên --</option>` +
                employees.map(e => `<option value="${e.EmployeeID}">${escapeHtml(e.FullName)} (${e.EmployeeID})</option>`).join("");
            let empAssignedOpts = `<option value="">-- Người yêu cầu (mặc định) --</option>` +
                employees.map(e => `<option value="${e.EmployeeID}" ${e.EmployeeID == LoginID ? "selected" : ""}>${escapeHtml(e.FullName)} (${e.EmployeeID})</option>`).join("");
            $("#selMainUser").html(empOpts);
            $("#selAssignedBy").html(empAssignedOpts);
            // reflect selected options into visible search inputs (and mark valid if selected)
            try {
                var asText = $("#selAssignedBy option:selected").text() || "";
                $("#selAssignedBySearch").val(asText.trim()).toggleClass("search-valid", !!$("#selAssignedBy").val());
                var muText = $("#selMainUser option:selected").text() || "";
                $("#selMainUserSearch").val(muText.trim()).toggleClass("search-valid", !!$("#selMainUser").val());
                var pText = $("#selParent option:selected").text() || "";
                $("#selParentSearch").val(pText.trim()).toggleClass("search-valid", !!$("#selParent").val());
            } catch(e) { console.warn(e); }
            // default date -> today
            var today = new Date();
            var dd = String(today.getDate()).padStart(2, "0");
            var mm = String(today.getMonth()+1).padStart(2, "0");
            var yyyy = today.getFullYear();
            $("#dDate").val(yyyy + "-" + mm + "-" + dd);
        }
        function loadAssignTemplate() {
            let pid = $("#selParent").val();
            if(!pid) {
                $("#subtask-assign-container").html(`<div class="empty-state" style="grid-column: 1 / -1;"><i class="bi bi-inbox"></i><p>Vui lòng chọn Công việc chính ở trên</p></div>`);
                return;
            }
            AjaxHPAParadise({
                data: {
                    name: "sp_Task_GetAssignmentSetup",
                    param: ["ParentTaskID", pid]
                },
                success: function(res) {
                    try {
                        let data = JSON.parse(res).data;
                        employees = data[2] || employees || [];
                    } catch(e) { console.warn(e); }
                    fetchAssignTemplate(pid);
                },
                error: function() {
                    fetchAssignTemplate(pid);
                }
            });
        }
        function fetchAssignTemplate(pid) {
            AjaxHPAParadise({
                data: {
                    name: "sp_Task_GetDetailedTemplate",
                    param: ["ParentTaskID", pid]
                },
                success: function(res) {
                    currentTemplate = JSON.parse(res).data[0] || [];
                    fetchChildTasks(pid, function(childTasks) {
                        currentChildTasks = childTasks || [];
                        console.log(currentChildTasks);
                        if (currentTemplate.length > 0) {
                            renderAssignSubtasks();
                        } else {
                            renderTempSubtasksUI(pid);
                        }
                    });
                }
            });
        }
        function reloadChecklist() {
            var pid = $("#selParent").val();
            if(!pid) {
                $("#subtask-assign-container").html(`<div class="empty-state" style="grid-column: 1 / -1;"><i class="bi bi-inbox"></i><p>Vui lòng chọn Công việc chính ở trên</p></div>`);
                return;
            }
            fetchAssignTemplate(pid);
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
                        var ids = rows.map(function(r) { return r.ChildTaskID; });
                        var childTasks = tasks.filter(function(t) { return ids.indexOf(t.TaskID) !== -1; });
                        cb(childTasks);
                    } catch(e) { console.warn(e); cb([]); }
                },
                error: function() { cb([]); }
            });
        }
        function renderTempSubtasksUI(pid) {
            var empOpts = `<option value="">-- Chọn người làm --</option>` + employees.map(e => `<option value="${e.EmployeeID}">${e.FullName}</option>`).join("");
            fetchChildTasks(pid, function(childTasks) {
                var candidateChilds = tasks.filter(function(t){ return String(t.TaskID) !== String(pid); });
                var childOpts = `<option value="">-- Tạo mới --</option>` + candidateChilds.map(function(t){ return `<option value="${t.TaskID}">${escapeHtml(t.TaskName)}</option>`; }).join("");
                var html = `
                    <div id="temp-subtasks">
                        <div class="empty-state" style="grid-column: 1 / -1;">
                            <i class="bi bi-inbox"></i>
                            <p>Không có hàng tạm nào. Bấm "Thêm hàng" để thêm.</p>
                        </div>
                    </div>`;
                $("#subtask-assign-container").html(html);
            });
        }
        function addTempRow() {
            // require a selected parent task
            var pid = $("#selParent").val();
            if(!pid) { alert("Vui lòng chọn Công việc chính trước khi thêm hàng"); return; }

            // ensure assign container exists
            if($("#subtask-assign-container").length === 0) return;

            var count = $("#subtask-assign-container .temp-subtask").length;
            var empOpts = (employees || []).map(e => `<option value="${e.EmployeeID}">${escapeHtml(e.FullName)} (${e.EmployeeID})</option>`).join("");

            fetchChildTasks(pid, function(childTasks) {
                var candidateChilds = tasks.filter(function(t){ return String(t.TaskID) !== String(pid); });
                var childOpts = `<option value="">-- Tạo mới --</option>` + candidateChilds.map(function(t){ return `<option value="${t.TaskID}">${escapeHtml(t.TaskName)}</option>`; }).join("");
                var d = new Date();
                var yyyy = d.getFullYear();
                var mm = String(d.getMonth()+1).padStart(2,"0");
                var dd = String(d.getDate()).padStart(2,"0");
                var defStart = `${yyyy}-${mm}-${dd}T00:00`;
                var defEnd = `${yyyy}-${mm}-${dd}T23:59`;

                var idxNum = 1000 + count;
                var row = `<div class="cu-row temp-subtask" data-idx="${idxNum}">
                 <div class="row-check" style="width:40px;flex-shrink:0"></div>
                    <div class="row-main" style="min-width:0; display:flex; gap:8px; align-items:center;">
                        <select class="form-select temp-sub-exist" style="width:260px; margin-right:8px; flex:0 0 260px;" onchange="tempExistingChanged(this)">${childOpts}</select>
                        <input type="text" class="form-control temp-sub-name" value="" style="flex:1; min-width:220px;" />
                        <div style="flex: 0 0 320px; position:relative;">
                            <div class="search-select" style="position:relative;">
                               <div class="selected-icons" data-idx="${idxNum}" style="right:8px; top:50%; transform:translateY(-50%);"></div>
                               <input type="text" placeholder="Tìm..." class="form-control st-user-filter" data-idx="${idxNum}" autocomplete="off" />
                               <div class="search-select-dropdown st-user-dropdown" id="stUserDropdown-${idxNum}" style="position:absolute; z-index:1050; display:none; max-height:220px; overflow:auto; border:1px solid #ddd; box-shadow:0 6px 18px rgba(0,0,0,0.08); width:100%;"></div>
                               <select multiple class="form-select d-none st-user-select" data-idx="${idxNum}">${empOpts}</select>
                            </div>
                        </div>
                        <input type="datetime-local" class="form-control temp-sub-from" style="width:220px; flex:0 0 220px;" value="${defStart}" />
                        <input type="datetime-local" class="form-control temp-sub-to" style="width:220px; flex:0 0 220px;" value="${defEnd}" />
                        <input type="text" class="form-control temp-sub-note" placeholder="Ghi chú..." style="flex:0 0 200px;" />
                        <select class="form-select temp-sub-priority" style="width:120px; flex:0 0 120px;">
                            <option value="1">Cao</option>
                            <option value="2">Trung bình</option>
                            <option value="3" selected>Thấp</option>
                        </select>
                        <button class="btn btn-outline-danger btn-temp-remove" title="Xoá">✕</button>
                    </div>
                </div>`;

                // remove empty state placeholder inside assign container if present
                if($("#subtask-assign-container .empty-state").length) $("#subtask-assign-container .empty-state").remove();
                // append so temp rows appear inline with other subtasks
                $("#subtask-assign-container").append(row);

                // focus the name input of the newly added row for quick entry
                try {
                    var $new = $("#subtask-assign-container .temp-subtask").last();
                    $new.find(".temp-sub-name").focus();
                    $new[0].scrollIntoView({ behavior: "smooth", block: "center" });
                } catch(e) { /* ignore focus errors */ }
            });
        }
        function tempExistingChanged(sel) {
            var $row = $(sel).closest(".temp-subtask");
            var val = $(sel).val();
            if(!val) {
                $row.find(".temp-sub-name").prop("disabled", false);
                return;
            }
            var t = tasks.find(function(x){ return String(x.TaskID) === String(val); });
            if(t) {
                $row.find(".temp-sub-name").val(t.TaskName).prop("disabled", true);
                if(t.MyStartDate) $row.find(".temp-sub-from").val((t.MyStartDate.split("T")[0]||"")+"T00:00");
                if(t.DueDate) $row.find(".temp-sub-to").val((t.DueDate.split("T")[0]||"")+"T23:59");
            }
        }
        function collectTempDetails() {
            var res = [];
            // temp-subtask rows may be appended directly into the assign container
            $("#subtask-assign-container .temp-subtask").each(function() {
                var exist = $(this).find(".temp-sub-exist").val();
                var name = $(this).find(".temp-sub-name").val();
                var empList = [];
                var $hiddenSel = $(this).find(".st-user-select");
                if ($hiddenSel.length) {
                    empList = $hiddenSel.val() || [];
                } else {
                    empList = $(this).find(".temp-sub-assignee").val() || [];
                }
                var note = $(this).find(".temp-sub-note").val();
                var from = $(this).find(".temp-sub-from").val();
                var to = $(this).find(".temp-sub-to").val();
                var priority = $(this).find(".temp-sub-priority").val() || 3;
                if((exist && exist !== "") || (name && name.trim() !== "")) {
                    if(empList && empList.length>0) {
                        empList.forEach(function(eid){
                            res.push({
                                ChildTaskID: exist && exist !== "" ? parseInt(exist) : 0,
                                ChildTaskName: name,
                                EmployeeID: eid,
                                Notes: note || "",
                                StartDate: from || null,
                                EndDate: to || null,
                               Priority: parseInt(priority)
                            });
                        });
                    } else {
                        res.push({
                            ChildTaskID: exist && exist !== "" ? parseInt(exist) : 0,
                            ChildTaskName: name,
                            EmployeeID: null,
                            Notes: note || "",
                            StartDate: from || null,
                            EndDate: to || null,
                            Priority: parseInt(priority)
                        });
                    }
                }
            });
            return res;
        }
        function renderAssignSubtasks() {
            console.log(currentTemplate);
            if(currentTemplate.length === 0) {
                $("#subtask-assign-container").html(`
                    <div class="empty-state" style="grid-column: 1 / -1;">
                        <i class="bi bi-list-check"></i>
                        <p>Chưa có checklist con</p>
                    </div>
                `);
                return;
            }

            let empOpts = employees.map(e =>
                `<option value="${e.EmployeeID}">${escapeHtml(e.FullName)} (${e.EmployeeID})</option>`
            ).join("");

            function todayRange() {
                var d = new Date();
                var yyyy = d.getFullYear();
                var mm = String(d.getMonth()+1).padStart(2,"0");
                var dd = String(d.getDate()).padStart(2,"0");
                return {
                    start: `${yyyy}-${mm}-${dd}T00:00`,
                    end: `${yyyy}-${mm}-${dd}T23:59`
                };
            }

            let def = todayRange();

            let items = currentTemplate.map((item, idx) => {
                const validIdx = Number.isInteger(idx) ? idx : 0;

                return `
                <div class="cu-row" style="cursor:default; align-items: flex-start; padding: 12px; gap:8px;">
                    <div style="width:40px; display:flex; align-items:center; justify-content:center; flex-shrink:0;">
                        <input type="checkbox" class="form-check-input subtask-checkbox" data-idx="${validIdx}" checked />
                    </div>
                    <div style="flex: 2; min-width: 200px;">
                        <div class="task-title" title="${escapeHtml(item.ChildTaskName)}">${item.ChildTaskName}</div>
                        ${item.DefaultKPI > 0 ?
                            `<div class="task-sub text-muted small">KPI: ${item.DefaultKPI} ${item.Unit || ""}</div>` :
                            `<div class="task-sub text-muted small">&nbsp;</div>`
                        }
                    </div>
                    <div style="flex: 2; position:relative;">
                        <label class="form-label">Người thực hiện (chọn nhiều)</label>
                            <div class="search-select" style="position:relative;">
                               <div class="selected-icons" data-idx="${validIdx}"></div>
                               <input type="text"
                                    placeholder="Tìm..."
                                    class="form-control st-user-filter"
                                    data-idx="${validIdx}"
                                    autocomplete="off" />
                               <div class="search-select-dropdown st-user-dropdown"
                                   id="stUserDropdown-${validIdx}"
                                   style="position:absolute; z-index:1050; display:none; max-height:220px; overflow:auto; border:1px solid #ddd; box-shadow:0 6px 18px rgba(0,0,0,0.08); width:100%;"></div>
                               <select multiple
                                     class="form-select d-none st-user-select"
                                     data-idx="${validIdx}">${empOpts}</select>
                            </div>
                    </div>
                    <div style="flex: 1; min-width: 140px;">
                        <label class="form-label">Bắt đầu</label>
                        <input type="datetime-local" class="form-control st-from" data-idx="${validIdx}" value="${def.start}" />
                    </div>
                    <div style="flex: 1; min-width: 140px;">
                        <label class="form-label">Kết thúc</label>
                        <input type="datetime-local" class="form-control st-to" data-idx="${validIdx}" value="${def.end}" />
                    </div>
                    <div style="flex: 1.5; min-width: 200px;">
                        <label class="form-label">Ghi chú</label>
                        <input type="text" class="form-control st-note" data-idx="${validIdx}" placeholder="Ghi chú..." />
                    </div>
                    <div style="flex: 1; min-width: 120px;">
                        <label class="form-label">Ưu tiên</label>
                        <select class="form-select st-priority" data-idx="${validIdx}">
                            <option value="1">Cao</option>
                            <option value="2">Trung bình</option>
                            <option value="3" selected>Thấp</option>
                        </select>
                    </div>
                </div>
                `;
            }).join("");

            $("#subtask-assign-container").html(items);

            currentTemplate.forEach((_, idx) => {
                refreshSelectedUsersDisplay(idx);
            });
        }
        function submitAssignment() {
            let parent = $("#selParent").val();
            let mainUser = $("#selMainUser").val();
            let dDate = $("#dDate").val();
            if(!parent || !mainUser) {
                alert("Vui lòng chọn Công việc chính và Người chịu trách nhiệm chính");
                return;
            }
            let details = [];
            // collect from template subtasks (multiple assignees supported)
            $(".st-user-select").each(function() {
                let idx = $(this).data("idx");
                // skip if subtask checkbox exists and is unchecked
                var $chk = $(`.subtask-checkbox[data-idx="${idx}"]`);
                if($chk.length && !$chk.is(":checked")) return;
                let emps = $(this).val() || [];
                let assignPriority = $(`.st-priority[data-idx="${idx}"]`).val() || 3;
                let note = $(`.st-note[data-idx="${idx}"]`).val() || "";
                let from = $(`.st-from[data-idx="${idx}"]`).val() || null;
                let to = $(`.st-to[data-idx="${idx}"]`).val() || null;
                if(emps && emps.length>0) {
                    emps.forEach(function(emp){
                        details.push({
                            ChildTaskID: currentTemplate[idx] ? currentTemplate[idx].ChildTaskID : 0,
                            ChildTaskName: currentTemplate[idx] ? currentTemplate[idx].ChildTaskName : null,
                            EmployeeID: emp,
                            Priority: parseInt(assignPriority),
                            Notes: note,
                            StartDate: from,
                            EndDate: to
                        });
                    });
                }
            });
            // collect temp rows
            if($("#temp-subtasks").length > 0) {
                var temp = collectTempDetails();
                if(temp && temp.length > 0) {
                    details = details.concat(temp.map(t => ({
                        ...t,
                        Priority: t.Priority || 3
                    })));
                }
            }
            var assignedBy = $("#selAssignedBy").val() || LoginID;
            AjaxHPAParadise({
                data: {
                    name: "sp_Task_AssignWithDetails",
                    param: [
                        "ParentTaskID", parent,
                        "MainResponsibleID", mainUser,
                        "AssignmentDetails", JSON.stringify(details),
                        "AssignmentDate", dDate,
                        "AssignedBy", assignedBy
                    ]
                },
                success: function() {
                    alert("Giao việc thành công!");
                    bootstrap.Modal.getInstance(document.getElementById("mdlAssign")).hide();
                    loadTasks();
                }
            });
        }
        function filterSelectOptions(selectId, text) {
            var q = (text||"").toLowerCase();
            var $sel = $("#" + selectId);
            $sel.find("option").each(function(){
                var txt = ($(this).text()||"").toLowerCase();
                if(!q || txt.indexOf(q) !== -1) $(this).show(); else $(this).hide();
            });
        }
        function filterMultiOptions(idx, text) {
            try {
                // Validate idx
                if(idx === undefined || idx === null || idx === "" || !Number.isInteger(Number(idx))) {
                    console.warn("Invalid idx:", idx);
                    return;
                }

                var q = normalizeForSearch(text || "");
                var $dropdown = $(`#stUserDropdown-${idx}`);

                if($dropdown.length === 0) {
                    console.warn("Dropdown not found for idx:", idx);
                    return;
                }

                var html = "";
                (employees || []).forEach(function(e){
                        var label = (e.FullName || (e.EmployeeID||"")) + (e.EmployeeID ? ` (${e.EmployeeID})` : "");
                        var norm = normalizeForSearch(label);
                    if(!q || norm.indexOf(q) !== -1) {
                        var $hiddenSel = $(`.st-user-select[data-idx="${idx}"]`);
                        var isSel = false;

                        if($hiddenSel.length > 0) {
                            isSel = $hiddenSel.find(`option[value="${e.EmployeeID}"]`).prop("selected");
                        }

                        html += `
                            <div class="search-item st-multi-item ${isSel ? "selected" : ""}"
                                data-idx="${idx}"
                                data-value="${e.EmployeeID}"
                                style="padding:8px 12px; cursor:pointer; border-bottom:1px solid #f1f1f1;">
                                ${escapeHtml(label)}
                            </div>
                        `;
                    }
                });

                if(html === "") {
                    html = `<div style="padding:8px 12px;color:#777;">Không tìm thấy</div>`;
                }

                $dropdown.html(html).show();

            } catch(err) {
                console.error("filterMultiOptions error:", err);
            }
        }
        function filterTempOptions(inp) {
            try {
                var $input = $(inp);
                var $row = $input.closest(".temp-subtask");
                if (!$row.length) return;

                var $select = $row.find("select.temp-sub-assignee");
                if (!$select.length) return;

                var q = normalizeForSearch(($input.val() || "").trim());

                $select.find("option").each(function () {
                    var text = ($(this).text() || "");
                    var norm = normalizeForSearch(text);
                    $(this).toggle(!q || norm.indexOf(q) !== -1);
                });
            } catch (e) {
                console.error(e)
            }
        }
        function openAddParentModal() {
            // create modal if not exists
            if(!document.getElementById("mdlAddParent")) {
                var html = `
                <div class="modal fade" id="mdlAddParent" tabindex="-1">
                    <div class="modal-dialog modal-dialog-centered">
                        <div class="modal-content">
                            <div class="modal-header">
                                <h5 class="modal-title">Thêm công việc chính</h5>
                                <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                            </div>
                            <div class="modal-body">
                                <div class="form-group">
                                    <label class="form-label">Tên công việc</label>
                                    <input type="text" id="newParentName" class="form-control" />
                                </div>
                                <div class="form-group">
                                    <label class="form-label">Ghi chú</label>
                                    <input type="text" id="newParentNote" class="form-control" />
                                </div>
                            </div>
                            <div class="modal-footer">
                                <button class="btn btn-white border" data-bs-dismiss="modal">Đóng</button>
                                <button class="btn-assign" id="btnCreateParent">Tạo</button>
                            </div>
                        </div>
                    </div>
                </div>`;
                $("body").append(html);
            }
            var m = new bootstrap.Modal(document.getElementById("mdlAddParent"));
            m.show();
            setTimeout(function(){ try{ document.getElementById("newParentName").focus(); }catch(e){} },100);
        }
        function createParentFromModal() {
            var name = $("#newParentName").val();
            var note = $("#newParentNote").val();
            if(!name || name.trim()==="") { alert("Vui lòng nhập tên công việc"); return; }
            // Add locally and refresh dropdown (server call would be ideal)
            var newId = Math.max(0, ...tasks.map(t=>t.TaskID||0)) + 1;
            var nt = { TaskID: newId, TaskName: name };
            tasks.push(nt);
            // re-render dropdown and select new value
            renderAssignDropdowns();
            $("#selParent").val(newId);
            try {
                var pText = $("#selParent option:selected").text() || name;
                $("#selParentSearch").val(pText.trim()).addClass("search-valid");
            } catch(e) {}
            // close modal
            bootstrap.Modal.getInstance(document.getElementById("mdlAddParent")).hide();
            // load template for this new parent (none)
            loadAssignTemplate();
        }
        function getInitials(fullName) {
            if (!fullName) return "";
            // normalize whitespace
            var name = String(fullName).replace(/\s+/g, " ").trim();
            if (!name) return "";

            function sanitizePart(part) {
                try {
                    // keep only Unicode letters (requires modern JS engines)
                    return part.replace(/[^\p{L}]/gu, "");
                } catch (e) {
                    // fallback for engines without Unicode property escapes: keep common Latin letters
                    return part.replace(/[^A-Za-zÀ-ž]/g, "");
                }
            }

            var parts = name.split(" ").map(p => sanitizePart(p)).filter(p => p.length > 0);
            var initials = "";

            if (parts.length === 0) {
                // fallback: take first two ASCII letters/digits found
                var m = name.match(/[A-Za-z0-9]/g) || [];
                initials = (m.slice(0, 2).join(""));
            } else if (parts.length === 1) {
                // single name: take first two letters of the sanitized part
                initials = parts[0].slice(0, 2);
            } else {
                // multiple parts: take first letter of first and last parts
                var first = parts[0].charAt(0) || "";
                var last = parts[parts.length - 1].charAt(0) || "";
                initials = first + last;
            }

            return initials.toUpperCase();
        }
        function refreshSelectedUsersDisplay(idx) {
            var $hidden = $(`.st-user-select[data-idx="${idx}"]`);
            var $input = $(`.st-user-filter[data-idx="${idx}"]`);
            var $wrap = $(`.selected-icons[data-idx="${idx}"]`);
            if(!$wrap.length) return;
            $wrap.html("");
            var fullNames = [];
            $hidden.find("option:selected").each(function(){
                var text = $(this).text().trim();
                if (text) fullNames.push(text);
            });
            var MAX = 4;
            var visible = fullNames.slice(0, MAX);
            visible.forEach(function(n){
                var initials = getInitials(n) || (n.charAt(0) || "").toUpperCase();
                $wrap.append(`<div class="icon-chip" title="${escapeHtml(n)}">${escapeHtml(initials)}</div>`);
            });
            var remaining = fullNames.length - MAX;
            if(remaining > 0) {
                $wrap.append(`<div class="icon-more" title="${escapeHtml(fullNames.join(", "))}">+${remaining}</div>`);
            }
            try {
                var used = Math.min(fullNames.length, MAX);
                var base = 110;
                var dynamic = 8 + used * 20;
                $input.css("padding-right", Math.max(base, dynamic + 60) + "px");
            } catch(e) {}
            if(fullNames.length > 0) {
                $input.addClass("search-valid").removeClass("search-invalid");
                $input.attr("title", fullNames.join(", "));
            } else {
                $input.removeClass("search-valid").val("").attr("title","");
                $input.css("padding-right", "110px");
            }
        }
        function initSubtaskDragDrop() {
            var rows = document.querySelectorAll(".subtask-row-draggable");

            rows.forEach(function(row) {
                // CHỈ cho phép drag khi kéo từ handle icon
                var handle = row.querySelector(".drag-handle");

                if (!handle) return;

                // Set row draggable = false by default
                row.setAttribute("draggable", "false");

                // Khi mousedown trên handle -> enable drag
                handle.addEventListener("mousedown", function() {
                    row.setAttribute("draggable", "true");
                });

                handle.addEventListener("mouseup", function() {
                    row.setAttribute("draggable", "false");
                });

                // Bắt đầu kéo
                row.addEventListener("dragstart", function(e) {
                    if (row.getAttribute("draggable") !== "true") {
                        e.preventDefault();
                        return;
                    }
                    this.classList.add("dragging");
                    e.dataTransfer.effectAllowed = "move";
                    e.dataTransfer.setData("text/html", this.innerHTML);
                });

                // Kết thúc kéo
                row.addEventListener("dragend", function() {
                    this.classList.remove("dragging");
                    row.setAttribute("draggable", "false");
                    rows.forEach(function(r) {
                        r.classList.remove("drag-over");
                    });
                });

                // Di chuyển qua row khác
                row.addEventListener("dragover", function(e) {
                    e.preventDefault();
                    e.dataTransfer.dropEffect = "move";

                    var dragging = document.querySelector(".dragging");
                    if (dragging && dragging !== this) {
                        this.classList.add("drag-over");
                    }
                    return false;
                });

                // Rời khỏi row
                row.addEventListener("dragleave", function() {
                    this.classList.remove("drag-over");
                });

                // Thả xuống
                row.addEventListener("drop", function(e) {
                    e.stopPropagation();
                    e.preventDefault();

                    var dragging = document.querySelector(".dragging");
                    if (dragging && dragging !== this) {
                        var allRows = Array.from(rows);
                        var dragIndex = allRows.indexOf(dragging);
                        var dropIndex = allRows.indexOf(this);

                        // Chèn vào vị trí mới
                        if (dragIndex < dropIndex) {
                            this.parentNode.insertBefore(dragging, this.nextSibling);
                        } else {
                            this.parentNode.insertBefore(dragging, this);
                        }

                        // Lưu thứ tự mới vào database
                        saveSubtaskOrder();
                    }

                    this.classList.remove("drag-over");
                    return false;
                });
            });
        }
        function saveSubtaskOrder() {
            // Lấy danh sách child IDs theo thứ tự hiện tại
            var orderedIds = [];
            $("#subtaskTableBody tr.subtask-row-draggable").each(function() {
                var childId = $(this).data("childid");
                if (childId) orderedIds.push(childId);
            });

            // Kiểm tra có dữ liệu không
            if (orderedIds.length === 0) {
                console.warn("Không có subtask nào để lưu thứ tự");
                return;
            }

            // Kiểm tra currentTaskID (parent task)
            if (!currentTaskID) {
                console.error("Không xác định được task cha");
                return;
            }

            // Chuyển mảng thành chuỗi CSV
            var orderedIdsCSV = orderedIds.join(",");

            console.log("Đang lưu thứ tự mới:", orderedIds);

            // Gọi API lưu vào database
            AjaxHPAParadise({
                data: {
                    name: "sp_Task_UpdateSubtaskOrder",
                    param: [
                 "ParentTaskID", currentTaskID,
                        "OrderedChildIDs", orderedIdsCSV,
                        "LoginID", LoginID
                    ]
                },
                success: function(res) {
                    try {
                        var result = JSON.parse(res);
                        if (result.data && result.data[0] && result.data[0][0]) {
                            var data = result.data[0][0];
                            if (data.Success === 1) {
                                // Thành công - hiển thị thông báo nhẹ
                                showSuccessNotification(
                                    "Đã lưu thứ tự!",
                                    "Cập nhật " + data.UpdatedCount + " task con"
                                );
                            } else {
                                console.error("Lỗi:", data.ErrorMessage);
                                alert("Lỗi: " + data.ErrorMessage);
                            }
                        }
                    } catch(e) {
                        console.error("Parse error:", e);
                        // Vẫn coi như thành công nếu không có lỗi từ server
                        showSuccessNotification("Đã lưu thứ tự!", "");
                    }
                },
                error: function(err) {
                    console.error("Lỗi khi lưu thứ tự:", err);
                    alert("Không thể lưu thứ tự subtask!");

                    // Reload lại để khôi phục thứ tự cũ
                    loadSubtasksForDetail(currentTaskID);
                }
            });
        }
        function initSubtaskDragDrop() {
            var rows = document.querySelectorAll(".subtask-row-draggable");

            rows.forEach(function(row) {
                // Bắt đầu kéo
                row.addEventListener("dragstart", function(e) {
                    this.classList.add("dragging");
                    e.dataTransfer.effectAllowed = "move";
                    e.dataTransfer.setData("text/html", this.innerHTML);
                });

                // Kết thúc kéo
                row.addEventListener("dragend", function() {
                    this.classList.remove("dragging");
                    rows.forEach(function(r) {
                        r.classList.remove("drag-over");
                    });
                });

                // Di chuyển qua row khác
                row.addEventListener("dragover", function(e) {
                    if (e.preventDefault) {
                        e.preventDefault();
                    }
                    e.dataTransfer.dropEffect = "move";

                    var dragging = document.querySelector(".dragging");
                    if (dragging && dragging !== this) {
                        this.classList.add("drag-over");
                    }
                    return false;
                });

                // Rời khỏi row
                row.addEventListener("dragleave", function() {
                    this.classList.remove("drag-over");
                });

                // Thả xuống
                row.addEventListener("drop", function(e) {
                    if (e.stopPropagation) {
                        e.stopPropagation();
                    }

                    var dragging = document.querySelector(".dragging");
                    if (dragging && dragging !== this) {
                        var allRows = Array.from(rows);
                        var dragIndex = allRows.indexOf(dragging);
                        var dropIndex = allRows.indexOf(this);

                        // Chèn vào vị trí mới
                        if (dragIndex < dropIndex) {
                            this.parentNode.insertBefore(dragging, this.nextSibling);
                        } else {
                            this.parentNode.insertBefore(dragging, this);
                        }

                        // Lưu thứ tự mới vào database
                        saveSubtaskOrder();
                    }

                    this.classList.remove("drag-over");
                    return false;
                });
            });
        }
        function initListDragDrop() {
            var rows = document.querySelectorAll(".cu-list .cu-row.draggable:not(.header-row)");

            rows.forEach(function(row) {
                var handle = row.querySelector(".row-drag-handle");

                if (!handle) return;

                // Chỉ drag khi kéo từ handle
                row.setAttribute("draggable", "false");

                handle.addEventListener("mousedown", function(e) {
                    e.stopPropagation();
                    row.setAttribute("draggable", "true");
                });

                handle.addEventListener("mouseup", function() {
                    row.setAttribute("draggable", "false");
                });

                // Drag events
                row.addEventListener("dragstart", function(e) {
                    if (row.getAttribute("draggable") !== "true") {
                        e.preventDefault();
                        return;
                    }
                    this.classList.add("dragging");
                    e.dataTransfer.effectAllowed = "move";
                    e.dataTransfer.setData("text/plain", this.dataset.taskid);
                });

                row.addEventListener("dragend", function() {
                    this.classList.remove("dragging");
                    row.setAttribute("draggable", "false");
                    rows.forEach(function(r) {
                        r.classList.remove("drag-over");
                    });
                });

                row.addEventListener("dragover", function(e) {
                    e.preventDefault();
                    e.dataTransfer.dropEffect = "move";

                    var dragging = document.querySelector(".dragging");
                    if (dragging && dragging !== this) {
                        this.classList.add("drag-over");
                    }
                    return false;
                });

                row.addEventListener("dragleave", function() {
                    this.classList.remove("drag-over");
                });

                row.addEventListener("drop", function(e) {
                    e.stopPropagation();
                    e.preventDefault();

                    var dragging = document.querySelector(".dragging");
                    if (dragging && dragging !== this) {
                        var allRows = Array.from(rows);
                        var dragIndex = allRows.indexOf(dragging);
                        var dropIndex = allRows.indexOf(this);

                        if (dragIndex < dropIndex) {
                            this.parentNode.insertBefore(dragging, this.nextSibling);
                        } else {
                            this.parentNode.insertBefore(dragging, this);
                        }

                        // Lưu thứ tự mới
                        saveListOrder();
                    }

                    this.classList.remove("drag-over");
                    return false;
                });
            });
        }
        function saveListOrder() {
            var orderedIds = [];
            $(".cu-list .cu-row.draggable:not(.header-row)").each(function() {
                var taskId = $(this).data("taskid");
                if (taskId) orderedIds.push(taskId);
            });

            if (orderedIds.length === 0) return;

            console.log("New list order:", orderedIds);

            // Optional: Save to server
            // AjaxHPAParadise({
            //     data: {
            //         name: "sp_Task_UpdateListOrder",
            //    param: ["OrderedTaskIDs", orderedIds.join(","), "LoginID", LoginID]
            //     },
            //     success: function() {
            //         showSuccessNotification("Đã lưu thứ tự!", "");
            //     }
            // });
        }
        })();
    </script>
    ';
    SELECT @html AS html;
END
GO

EXEC sp_GenerateHTMLScript 'sp_Task_MyWork_html'
