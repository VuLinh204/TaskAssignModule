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
        #sp_Task_MyWork_html .h-title {
            font-weight: 700;
            font-size: clamp(20px, 5vw, 28px);
        }
        #sp_Task_MyWork_html .h-title i {
            color: var(--task-primary);
            font-size: 1.2em;
        }
        /* Compact Stats Row: small, tidy cards with icons and reduced padding */
        #sp_Task_MyWork_html .stats-row {
            gap: 10px;
            margin-bottom: 12px;
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
        #sp_Task_MyWork_html .stats-row .stat-card .stat-label-task {
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
            content: "";
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
        #sp_Task_MyWork_html .stat-label-task {
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
            box-shadow: var(--shadow-sm);
        }
        #sp_Task_MyWork_html .cu-row {
            display: flex;
            align-items: center;
            justify-content: space-between;
            padding: 16px 20px;
            border-bottom: 1px solid var(--bg-lighter);
            transition: all var(--transition-base);
            cursor: pointer;
            gap: 2px;
            max-height: 110px;
        }
        /* Make temp-subtask rows visually consistent with other cu-rows */
        #sp_Task_MyWork_html .temp-subtask {
            cursor: pointer;
            display: flex;
            align-items: center;
            padding: 16px 20px;
            border-bottom: 1px solid var(--bg-lighter);
            transition: all var(--transition-base);
            cursor: default;
            gap: 12px;
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
            max-width: 1000px;
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
            gap: 8px;
            padding: 8px 0;
        }

        #sp_Task_MyWork_html .meta-row i {
            color: var(--task-primary);
            font-size: 16px;
            width: 20px;
            flex-shrink: 0;
        }

        #sp_Task_MyWork_html .meta-label {
            font-weight: 600;
            color: var(--text-secondary);
            min-width: 100px;
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
            background: white;
            border: 1px solid var(--border-color);
        border-radius: var(--radius-lg);
            padding: 20px;
            margin-bottom: 20px;
        }
        #sp_Task_MyWork_html .kpi-display {
            display: flex;
           justify-content: space-between;
            align-items: center;
            margin-bottom: 16px;
            gap: 24px;
        }
        #sp_Task_MyWork_html .kpi-current {
            font-size: 32px;
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
        #sp_Task_MyWork_html .status-select-wrapper {
            display: flex;
            align-items: center;
            margin-top: 24px;
            margin-left: 20px;
            gap: 12px;
        }

        #sp_Task_MyWork_html .status-select-wrapper label {
            font-weight: 600;
            font-size: 14px;
            color: var(--text-secondary);
            white-space: nowrap;
        }

        #sp_Task_MyWork_html .status-select {
            min-width: 200px;
  padding: 10px 16px;
            border: 2px solid var(--border-color);
            border-radius: var(--radius-md);
            font-weight: 600;
            font-size: 14px;
            cursor: pointer;
            transition: all var(--transition-base);
            background: white;
        }

        #sp_Task_MyWork_html .status-select:hover {
            border-color: var(--task-primary);
        }

        #sp_Task_MyWork_html .status-select:focus {
            border-color: var(--task-primary);
            outline: none;
            box-shadow: 0 0 0 3px rgba(46, 125, 50, 0.1);
        }

        #sp_Task_MyWork_html .status-select option[value="1"] {
            background: var(--sts-todo);
            color: var(--sts-todo-text);
        }

        #sp_Task_MyWork_html .status-select option[value="2"] {
            background: var(--sts-doing);
            color: var(--sts-doing-text);
        }

        #sp_Task_MyWork_html .status-select option[value="3"] {
            background: var(--sts-done);
            color: var(--sts-done-text);
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
            gap: 0 10px;
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
        #sp_Task_MyWork_html .form-select {
            font-size: 14px;
        }
        #sp_Task_MyWork_html .form-control,
        #sp_Task_MyWork_html .form-select {
            width: 100%;
            padding: 8px 12px;
            border: 1.5px solid var(--border-color);
            border-radius: var(--radius-sm);
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
            border: 1px solid var(--border-color);
        }

        #sp_Task_MyWork_html .description-content {
            width: 100%;
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
            font-weight: 700;
            cursor: pointer;
            position: relative;
            border-radius: 10px 10px 0 0;
            transition: all 0.3s ease;
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

       .control-row-assignee-item.selected {
            background: rgba(46,125,94,0.06);
        }

       .control-row-assignee-item .row-assignee-checkbox {
            width:16px; height:16px;
        }

       .control-employee-selector .emp-sel-item:hover {
            opacity: 0.8;
        }

       .control-employee-selector .emp-sel-item.selected {
            background: rgba(46, 125, 50, 0.08);
        }

       .control-employee-selector .icon-chip {
            width: 28px;
            height: 28px;
            border-radius: 50%;
            background: #f1f5f9;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 12px;
            font-weight: 600;
            border: 2px solid white;
        }
          /* Detail icon shown on row hover */
          .cu-row { position: relative; }
          .cu-row .detail-icon {
              display: none;
              cursor: pointer;
              color: var(--text-secondary);
              background: rgba(255,255,255,0.9);
              border-radius: 6px;
              padding: 6px;
              box-shadow: 0 2px 6px rgba(0,0,0,0.06);
              transition: transform 0.12s ease, opacity 0.12s ease;
              z-index: 20;
          }
          .cu-row:hover .detail-icon { display: block; opacity: 1; transform: translateY(-2px); }
          .cu-row .detail-icon i { font-size: 14px; }
    </style>
    <div id="sp_Task_MyWork_html">
        <div class="cu-header d-flex justify-content-between align-items-center mb-4 gap-2 flex-wrap">
            <div class="h-title m-0 gap-3 d-flex align-items-center"><i class="bi bi-check-circle-fill"></i>Công việc của tôi</div>
            <div class="header-actions d-flex align-items-center gap-2 flex-wrap">
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
        <!-- Filters -->
        <div class="filter-section">
            <label style="font-weight: 600; font-size: 13px;">Lọc:</label>
            <select id="filterStatus">
                <option value="">Tất cả trạng thái</option>
                <option value="1">Chưa làm</option>
                <option value="2">Đang làm</option>
                <option value="3">Hoàn thành</option>
            </select>
            <select id="filterOverdue">
                <option value="">Tất cả</option>
                <option value="1">Chỉ quá hạn</option>
            </select>
        </div>
        <!-- List View -->
        <div id="list-view">
            <div class="cu-list" id="list-container"></div>
        </div>
        <!-- Kanban View -->
        <div id="kanban-view" style="display:none;">
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
        <!-- Task Detail Modal -->
        <div class="modal fade task-detail-modal" id="mdlTaskDetail" tabindex="-1" data-bs-backdrop="static">
            <div class="modal-dialog modal-dialog-centered modal-dialog-scrollable">
                <div class="modal-content">
                    <div class="task-detail-header">
                        <button type="button" class="btn-close float-end" data-bs-dismiss="modal"></button>
                        <div class="task-detail-title" id="detailTaskName">...</div>
                        <div class="task-detail-meta">
                            <div class="meta-row">
                                <i class="bi bi-person-badge"></i>
                                <span class="meta-label">Người yêu cầu:</span>
                                <span class="meta-value" id="detailCreator">-</span>
                            </div>
                            <div class="meta-row">
                                <i class="bi bi-person-check"></i>
                                <span class="meta-label">Trách nhiệm chính:</span>
                                <span class="meta-value" id="detailMainResponsible">-</span>
                            </div>
                            <div class="meta-row">
                                <i class="bi bi-calendar-event"></i>
                                <span class="meta-label">Ngày bắt đầu:</span>
                                <span class="meta-value" id="detailStartDate">-</span>
                            </div>
                            <div class="meta-row">
                                <i class="bi bi-calendar-x"></i>
                                <span class="meta-label">Hạn chót:</span>
                                <span class="meta-value" id="detailDueDate">-</span>
                            </div>
                        </div>
                    </div>

                    <!-- Quick Actions Bar -->
                    <div class="quick-actions-bar">
                        <div class="status-select-wrapper">
                            <label for="detailStatusSelect">
                                Trạng thái:
                            </label>

                            <select id="detailStatusSelect" class="status-select">
                                <option value="1">
                                    <i class="bi bi-circle"></i> Chưa làm
                                </option>
                                <option value="2">
                                    <i class="bi bi-arrow-repeat"></i> Đang làm
                                </option>
                                <option value="3">
                                    <i class="bi bi-check2-circle"></i> Hoàn thành
                                </option>
                            </select>
                        </div>
                        <div class="status-select-wrapper">
                            <label for="detailPriority">
                                Ưu tiên:
                            </label>
                            <span class="meta-value" id="detailPriority" style="cursor:pointer;padding:6px 12px;border-radius:4px;border:1px solid var(--border-color);display:inline-block;background:white;min-width:120px;text-align:center;">Thường</span>
                        </div>
                    </div>

                    <div class="task-detail-body">
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
                        <div class="attachments-section" id="attachmentsSection">
                            <div class="section-title"><i class="bi bi-file-earmark-arrow-up"></i> Tài liệu đính kèm</div>
                            <div id="attachmentsList"></div>
                            <div id="attachFileControl"></div>
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
                                    <div class="search-select" style="position:relative;">
                                        <input type="text" id="selParentSearch" class="form-control" autocomplete="off" placeholder="Tìm công việc..." />
                                        <div class="search-select-dropdown" id="selParentDropdown"></div>
                                        <select class="form-control d-none" id="selParent"></select>
                                    </div>
                                </div>
                                <div class="form-group">
                                    <label class="form-label">Người yêu cầu</label>
                                    <div id="assignedBySelector"></div>
                                </div>
                                <div class="form-group">
                                    <label class="form-label">Người chịu trách nhiệm chính</label>
                                    <div id="mainUserSelector"></div>
                                </div>
                                <div class="form-group">
                                    <label class="form-label">Ngày yêu cầu</label>
                                    <input type="date" class="form-control" id="dDate" />
                                </div>
                                <div class="form-group">
                                    <label class="form-label">Hạn hoàn thành</label>
                                    <input type="date" class="form-control" id="dDue" />
                                </div>
                            </div>
                        </div>
                        <!-- Step 2: Phân bổ chi tiết -->
                        <div class="assign-step">
                            <div class="step-header">
                                <div class="step-number">2</div>
                                <div class="step-title">Phân bổ chi tiết (Subtasks)</div>
                                <div style="margin-left:auto; display:flex; gap:8px; align-items:center;">
                                    <button class="text-success" id="btnQuickAddSubtask" title="Thêm task con"><i class="bi bi-plus-lg fs-4"></i></button>
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
        (function(){ "use strict";
            var allTasks = [], filteredTasks = [], currentTaskID = 0, currentView = "list";
            var employees = [], tasks = [], headers = [], currentTemplate = [];
            var rowAssigneeMap = {};
            var currentChildTasks = []; // cached child tasks for selected ParentTaskID
            var expandedHeadersState = {};
            var attachmentMode = ""; // "file"

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
                $("#btnQuickAddSubtask").on("click", showQuickSubtaskInput);
                $("#btnReloadChecklist").on("click", reloadChecklist);
                $("#btnSubmitAssignment").on("click", submitAssignment);
                // Delegated handlers for dynamic elements
                // Open detail only when clicking the detail icon — row clicks no longer open modal
                $(document).off("click", ".task-row:not(.header-row)");
                $(document).on("click", ".task-row .detail-icon", function(e) {
                    console.log("detail-icon click");
                    e.stopPropagation();
                    e.preventDefault();
                    var id = $(this).data("recordid") || $(this).closest(".task-row").data("recordid");
                    if (id) openTaskDetail(id);
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

                    var id = $(this).data("recordid");
                    var code = parseInt($(this).data("status")) || 1;

                    if(id) {
                        toggleStatus(id, code);
                    }
                });
                $(document).on("click", ".btn-temp-remove", function() {
                    $(this).closest(".temp-subtask").remove();
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
                            uiManager.showAlert({
                                type: "success",
                                message: "Cập nhật độ ưu tiên thành công!",
                            });
                        },
                        error: function() {
                            uiManager.showAlert({ type: "error",  message: "Cập nhật độ ưu tiên thất bại!",});
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
                    var taskId = $sel.data("recordid");
                    var val = $sel.val();

                    AjaxHPAParadise({
                        data: {
                            name: "sp_Task_UpdateField",
                            param: ["TaskID", taskId, "Priority", val]
                        },
                        success: function() {
                            uiManager.showAlert({
                                type: "success",
                                message: "Cập nhật độ ưu tiên thành công!",
                            });
                            // Không reload toàn bộ, chỉ update icon
                            var prioClass = "prio-" + val;
                            $sel.closest(".task-row").find(".priority-icon")
                                .removeClass("prio-1 prio-2 prio-3")
                                .addClass(prioClass);
                        },
                        error: function() {
                            uiManager.showAlert({
                                type: "error",
                                message: "Cập nhật độ ưu tiên thất bại!",
                            });
                        }
                    });
                });
                // Change priority directly on subtask row
                $(document).on("change", ".row-priority-select", function(e) {
                    e.stopPropagation();
                    var $sel = $(this);
                    var taskId = $sel.data("recordid");
                    var val = $sel.val();

                    AjaxHPAParadise({
                        data: {
                            name: "sp_Task_UpdateField",
                            param: ["TaskID", taskId, "Priority", val]
                        },
                        success: function() {
                            uiManager.showAlert({
                                type: "success",
                                message: "Cập nhật độ ưu tiên thành công!",
                            });
                            var prioClass = "prio-" + val;
                            $sel.closest(".task-row").find(".priority-icon")
                                .removeClass("prio-1 prio-2 prio-3")
                                .addClass(prioClass);
                            try {
                                var t = allTasks.find(x => x.TaskID == taskId);
                                if (t) { t.AssignPriority = Number(val); t.Priority = Number(val); }
                            } catch(e) { console.warn(e); }
                        },
                        error: function() { uiManager.showAlert({
                                type: "error",
                                message: "Cập nhật độ ưu tiên thất bại!",
                            });
                        }
                    });
                });

                // Row assignee: toggle dropdown, search and select
                $(document).on("click", ".row-assignee-toggle", function(e) {
                    hpaControlCombobox("#listCreateParentSearch", {
                        field: "ParentTaskID",
                        tableName: "tblTask",
                        idColumnName: "TaskID",
                        idValue: currentTaskID,
                        displayId: currentTaskID,
                        options: (tasks || []).map(t => ({ value: t.TaskID, text: t.TaskName })),
                        ajaxListName: "EmployeeListAll_DataSetting_Custom",
                        placeholder: "Nhập tên công việc hoặc chọn...",
                        silent: true,
                        onSave: function(value, text) {
                            try { $("#listCreateParentSelect").val(value); $("#listCreateParentSearch").val(text).addClass("search-valid"); } catch(e){}
                        }
                    });

                    e.stopPropagation();

                    var $btn = $(this);

                    var $wrap = $btn.closest(".row-assignee");

                    // close other dropdowns
                    $(".row-assignee-dropdown").not($wrap.find(".row-assignee-dropdown")).hide();

                    var $dd = $wrap.find(".row-assignee-dropdown");
                    var $list = $dd.find(".row-assignee-list");

                    // populate list if empty
                    var populateList = function() {
                        if ($list.children().length === 0) {
                            // Determine already-assigned employee IDs
                            var assignedIds = [];
                            try {
                                var tid = $wrap.data("recordid");

                                var t = allTasks?.find(function(x){
                                    return String(x.TaskID) === String(tid);
                                });

                                console.log("task object found =", t);

                                var idsCsv = t?.AssignedToEmployeeIDs || "";

                                if (idsCsv) {
                                    assignedIds = String(idsCsv)
                                        .split(",")
                                        .map(s => s.trim())
                                        .filter(Boolean);
                                }
                            } catch (err) {
                                console.error("ERROR when parsing assigned IDs:", err);
                                assignedIds = [];
                            }

                            var items = (employees || []).map(function(e){
                                var isSel = assignedIds.indexOf(String(e.EmployeeID)) !== -1;
                                return `
                                    <div class="control-row-assignee-item ${isSel? "selected":""}"
                                        data-empid="${e.EmployeeID}"
                                        data-empname="${escapeHtml(e.FullName)}"
                                        style="padding:8px 10px;cursor:pointer;display:flex;align-items:center;gap:8px;border-bottom:1px solid #f0f2f5;">

                                        <div style="width:28px;flex-shrink:0;">
                                            <input type="checkbox" class="row-assignee-checkbox" ${isSel? "checked":""} />
                                        </div>

                                        <div class="icon-chip"
                                            style="width:32px;height:32px;border-radius:50%;background:#f1f5f9;display:flex;align-items:center;justify-content:center;font-size:12px;">
                                            ${escapeHtml(getInitials(e.FullName))}
                                        </div>

                                        <div style="flex:1;min-width:0;">
                                            <div style="font-weight:600">${escapeHtml(e.FullName)}</div>
                                            <div style="font-size:12px;color:var(--text-muted)">${escapeHtml(e.EmployeeID)}</div>
                                        </div>
                                    </div>`;
                            }).join("");

                            $list.html(items);
                            console.log("List populated, items count =", employees.length);
                        } else {
                            console.log("List already populated, skip");
                        }
                    };

                    if (employees && employees.length !== 0) {
                        populateList();
                        $dd.toggle();

                        $dd.find(".row-assignee-search").val("").focus();
                    } else {
                        console.warn("⚠ employees is empty → cannot load list");
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
                $(document).on("click", ".control-row-assignee-item", function(e){
                    e.stopPropagation();
                    var $it = $(this);
                    var $chk = $it.find(".row-assignee-checkbox");
                    // toggle
                    var now = !$chk.prop("checked");
                    $chk.prop("checked", now);
                    $it.toggleClass("selected", now);
                });


                // Close assignee dropdown when clicking elsewhere. If user clicked outside
                // while having selected assignees, auto-save the selection before hiding.
                $(document).on("click", function(e){
                    if(!$(e.target).closest(".row-assignee").length){
                        // For each visible dropdown, persist selection if it changed
                        $(".row-assignee-dropdown:visible").each(function(){
                            var $dd = $(this);
                            var $wrap = $dd.closest(".row-assignee");
                            var taskId = $wrap.data("recordid");
                            if(!taskId) return;

                            var selected = [];
                            $dd.find(".control-row-assignee-item.selected").each(function(){ selected.push($(this).data("empid")); });
                            var csv = (selected || []).map(function(x){ return String(x).trim(); }).filter(Boolean).join(",");

                            try {
                                var t = allTasks.find(x=>String(x.TaskID) === String(taskId));
                                var existingCsv = "";
                                if (t) existingCsv = ((t.AssignedToEmployeeIDs || "")+"").split(",").map(function(s){return String(s).trim();}).filter(Boolean).join(",");

                                if (csv !== existingCsv) {
                                    // Save changes same as Apply button via common SP
                                    var _params2 = [
                                        "LoginID", LoginID,
                                        "LanguageID", "VN",
                                        "TableName", "tblTask",
                                        "ColumnName", "AssignedToEmployeeIDs",
                                        "IDColumnName", "ChildTaskID",
                                        "ColumnValue", csv,
                                        "ID_Value", taskId
                                    ];
                                    AjaxHPAParadise({
                                        data: {
                                            name: "sp_Common_SaveDataTable",
                                            param: _params2
                                        },
                                        success: function(){
                                            uiManager.showAlert({
                                                type: "success",
                                                message: "Cập nhật người phụ trách thành công!",
                                            });
                                            try {
                                                var tLocal = allTasks.find(x=>String(x.TaskID) === String(taskId));
                                                if (tLocal) {
                                                    tLocal.AssignedToEmployeeIDs = csv;
                                                    var names = [];
                                                    $dd.find(".control-row-assignee-item.selected").each(function(){ names.push($(this).data("empname") || $(this).find("div").eq(1).find("div").first().text()); });
                                                    tLocal.AssignedToEmployeeNames = names.join(",");
                                                }
                                                try { refreshTaskRowInList(taskId); } catch(e) { /* fallback handled below */ }
                                            } catch(e){ console.warn(e); }
                                        },
                                        error: function(){
                                            uiManager.showAlert({
                                                type: "error",
                                                message: "Cập nhật người phụ trách thất bại!",
                                            });
                                        }
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
                            uiManager.showAlert({
                                type: "success",
                                message: "Cập nhật mô tả thành công!",
                            });
                        },
                        error: function() {
                            uiManager.showAlert({
                                type: "error",
                                message: "Cập nhật mô tả thất bại!",
                            });
                        }
                    });
                });
                $("#btnAddAttachment").on("click", () => {
                    new bootstrap.Modal(document.getElementById("mdlAttachType")).show();
                });

                $(document).on("click", "#btnAttachFile", () => {
                    $("#mdlAttachType").modal("hide");
                    $("#uploadArea").show();
                    $("#fileInput").click();
                });

                $(document).on("click", "#btnAttachLink", () => {
                    $("#mdlAttachType").modal("hide");
                    $("#linkArea").show();
                    $("#txtLinkName").focus();
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
                        uiManager.showAlert({
                            type: "warning",
                            message: "Vui lòng nhập đầy đủ thông tin!",
                        });

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
                            uiManager.showAlert({
                                type: "success",
                                message: "Thêm link thành công!",
                            });
                        },
                        error: function() {
                            uiManager.showAlert({
                                type: "error",
                                message: "Thêm link thất bại!",
                            });
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
                $("#viewListT, #viewKanbanT").on("click", function() {
                    switchView($(this).attr("id") === "viewListT" ? "list" : "kanban");
                });
                $("#detailStatusSelect").change(function() {
                    updateTaskStatusFromSelect();
                })
                // Khi thay đổi bộ lọc trạng thái
                $("#filterStatus, #filterOverdue").on("change", filterTasks);
                // Xử lý click để chỉnh sửa trực tiếp
                $(document).on("click", ".cu-row .task-title", function() {
                    const $title = $(this);
                    const taskId = $title.closest(".cu-row").data("recordid") || currentTaskID;
                    hpaControlEditableRow($title[0], {
                        type: "input",
                        tableName: "tblTask",
                        columnName: "TaskName",
                        idColumnName: "TaskID",
                        idValue: taskId
                    });
                    $title.trigger("click"); // tự động mở form sửa luôn
                });
                $(document).on("renderTaskDetail", function() {
                    hpaControlEditableRow("#detailTaskName", {
                        type: "input",
                        tableName: "tblTask",
                        columnName: "TaskName",
                        idColumnName: "TaskID",
                        idValue: currentTaskID
                    });
                });
                $(document).on("renderTaskDetail", function() {
                    hpaControlEditableRow("#detailDescription", {
                        type: "textarea",
                        tableName: "tblTask",
                        columnName: "Description",
                        idColumnName: "TaskID",
                        idValue: currentTaskID
                    });
                });
                $(document).on("renderSubtasks", function() {
                    $("#subtaskTableBody .subtask-name").each(function() {
                        const childId = $(this).closest("tr").data("childid");
                        hpaControlEditableRow(this, {
                            type: "input",
                            tableName: "tblTask",
                            columnName: "ChildTaskName",
                            idColumnName: "ChildTaskID",
                            idValue: childId
                        });
                    });
                });
                const originalOpenTaskDetail = openTaskDetail;
                openTaskDetail = function(taskId) {
                    currentTaskID = taskId;
                    originalOpenTaskDetail(taskId);
                    setTimeout(() => {
                        $(document).trigger("renderTaskDetail");
                        $(document).trigger("renderSubtasks");
                    }, 200);
                };
                $(document).on("click", ".task-title", function(e) {
                    var taskId = $(this).closest(".cu-row").data("recordid");
                    if (!taskId) return;

                    e.stopPropagation(); // Chặn sự kiện click row để không mở modal ngay lập tức nếu đang sửa

                    hpaControlEditableRow(this, {
                        type: "text",
                        tableName: "tblTask",
                        columnName: "TaskName",
                        idColumnName: "TaskID",
                        idValue: taskId,
                        onSave: function(val) {
                            console.log("Đã lưu tên mới:", val);
                            loadTasks(); // Reload lại list sau khi sửa
                        }
                    });
                });

                $(document).on("click", "#descriptionDisplay", function(e) {
                    hpaControlEditableRow(this, {
                        type: "textarea",
                        tableName: "tblTask",
                        columnName: "Description",
                        idColumnName: "TaskID",
                        idValue: currentTaskID
                    });
                });

                $(document).on("click", ".search-select-dropdown .create-parent", function(e) {
                    e.stopPropagation();
                    var name = $(this).data("name") || $(this).text().trim();
                    createParentInline(name);
                    $(this).closest(".search-select-dropdown").hide();
                });

                $(document).on("click", ".search-item-quick", function(e){
                    e.stopPropagation();
                    var tid = $(this).data("recordid");
                    var pid = $("#selParent").val();
                    if(!pid) { uiManager.showAlert({ type: "warning", message: "Vui lòng chọn Công việc chính trước khi thực hiện" }); return; }
                    AjaxHPAParadise({
                        data: { name: "sp_Task_SaveTaskRelations", param: ["ParentTaskID", pid, "ChildTaskIDs", String(tid)] },
                        success: function() { removeQuickAdd(); fetchAssignTemplate(pid); uiManager.showAlert({ type: "success", message: "Đã thêm task con." }); },
                        error: function(){ uiManager.showAlert({ type: "error", message: "Thêm task con thất bại." }); }
                    });
                });
                $(document).on("input", "#quickSubtaskInput", function(e){
                    var q = ($(this).val()||"").trim();
                    if(!q) { $("#quickSubtaskDropdown").hide(); return; }
                    renderQuickSubtaskDropdown(q);
                });

                // Save on outside click: if quick input exists and click outside, create or link
                $(document).on("click", function(e){
                    if($(e.target).closest("#quickAddWrapper, #btnQuickAddSubtask, .search-item-quick").length) return;
                    if($("#quickAddWrapper").length) {
                        var val = $("#quickSubtaskInput").val() || "";
                        if(val.trim()) { createSubtaskFromQuick(val.trim()); }
                        else { removeQuickAdd(); }
                    }
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
                                data: { name: "EmployeeListAll_DataSetting_Custom", param: [] },
                                success: function(setupRes) {
                                    try {
                                        var setupData = JSON.parse(setupRes).data || [];
                                        employees = setupData[0] || employees || [];
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

                var html = (attachments || []).map(function(a){ return renderComponent("attachmentItem", { attachment: a }); }).join("");

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
                        uiManager.showAlert({
                            type: "success",
                            message: "Xóa tài liệu thành công!",
                        });
                    },
                    error: function() {
                        uiManager.showAlert({
                            type: "error",
                            message: "Xóa tài liệu thất bại!",
                        });
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
                        uiManager.showAlert({
                            type: "warning",
                            message: `File ${file.name} quá lớn (> 10MB)`,
                        });
                        continue;
                    }

                    if (allowedTypes.indexOf(ext) === -1) {
                        uiManager.showAlert({
                            type: "warning",
                            message: `File ${file.name} không được hỗ trợ`,
                        });
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
                        uiManager.showAlert({
                            type: "success",
                            message: "Tải file thành công!",
                        });
                    },
                error: function() {
                        uiManager.showAlert({
                            type: "error",
                            message: "Tải file thất bại!",
                     });
                    }
                });
            }
            function filterOptionsForSearch(selectId, text, dropdownSelector) {
                console.log("filterOptionsForSearch", selectId);
                var rawText = (text || "").trim();
                var q = normalizeForSearch(rawText || "");
                var $select = $("#" + selectId);
                var $dropdown = $(dropdownSelector);
                var opts = $select.find("option");
                var html = "";
                var matchedExact = false;
                opts.each(function() {
                    var v = $(this).attr("value");
                    var t = $(this).text() || "";
                    if(!v) return; // skip placeholder
                    var norm = normalizeForSearch(t);
                    if(!q || norm.indexOf(q) !== -1) {
                        html += `<div class="search-item" data-target="${selectId}" data-value="${v}" style="padding:8px 12px; cursor:pointer; border-bottom:1px solid #f1f1f1;">${escapeHtml(t)}</div>`;
                    }
                    if (q && norm === q) matchedExact = true;
                });
                if(html === "") html = `<div style="padding:8px 12px;color:#777;">Không tìm thấy</div>`;

                // Nếu đang search cho selParent và không có exact match, cho phép tạo mới ngay từ dropdown
                if (selectId === "selParent" && rawText && !matchedExact) {
                    html += `<div class="search-item create-parent" data-name="${escapeHtml(rawText)}" style="padding:8px 12px; cursor:pointer; border-top:1px solid #f1f1f1; background:#f8f9fb; font-weight:600;">Tạo công việc "${escapeHtml(rawText)}"</div>`;
                }

                $dropdown.html(html).show();
            }
            function createParentInline(name) {
                if (!name || String(name).trim() === "") return;
                var n = String(name).trim();
                // tạo id tạm (client-side)
                var newId = 1;
                try { newId = Math.max(0, ...((tasks||[]).map(t=>t.TaskID||0))) + 1; } catch(e) { newId = Date.now(); }
                var nt = { TaskID: newId, TaskName: n };
                tasks = tasks || [];
                tasks.push(nt);
                // re-render dropdown và chọn
                renderAssignDropdowns();
                try { $("#selParent").val(newId); } catch(e) {}
                try { $("#selParentSearch").val(n).addClass("search-valid"); } catch(e) {}
                // load template (likely empty)
                loadAssignTemplate();
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
            // Unified small component renderer
            function renderComponent(type, props) {
                props = props || {};
                try {
                    if (type === "attachmentItem") {
                        var a = props.attachment || {};
                        var icon = getFileIcon(a.FileName || "");
                        var isLink = a.FilePath && (String(a.FilePath).startsWith("http://") || String(a.FilePath).startsWith("https://"));
                        var uploadedBy = a.UploadedByName || a.UploadedBy || "";
                        var uploadedDate = a.UploadedDate ? formatSimpleDate(a.UploadedDate) : "";
                        return `
                            <div class="attachment-item">
                                <div class="attachment-icon"><i class="bi ${icon}"></i></div>
                                <div class="attachment-info">
                                    <div class="attachment-name">${escapeHtml(a.FileName || "")}</div>
                                    <div class="attachment-meta text-muted small">${escapeHtml(uploadedBy)} ${uploadedDate ? "• " + escapeHtml(uploadedDate) : ""}</div>
                                </div>
                                <div class="attachment-actions">
                                    ${isLink ? `<a href="${escapeHtml(a.FilePath)}" target="_blank" class="btn btn-sm btn-light">Mở</a>` : `<button class="btn btn-sm btn-light" data-attachid="${a.AttachID || ""}" onclick="downloadAttachment(${a.AttachID || ""})">Tải</button>`}
                                    <button class="btn btn-sm btn-danger ms-2" onclick="deleteAttachment(${a.AttachID || ""})">Xóa</button>
                                </div>
                            </div>
                        `;
                    }

                    if (type === "commentItem") {
                        var c = props.comment || {};
                        var author = c.FullName || c.Author || c.CreatedBy || "";
                        var date = c.CreatedDate ? formatSimpleDate(c.CreatedDate) : "";
                        return `
                            <div class="comment-item">
                                <div class="comment-header">
                                    <span class="comment-author">${escapeHtml(author)}</span>
                                    <span class="comment-date text-muted small">${escapeHtml(date)}</span>
                                </div>
                                <div class="comment-content">${escapeHtml(c.Content || "")}</div>
                            </div>
                        `;
                    }

                    if (type === "assigneeIcons") {
                        // props.ids: csv or array, props.maxVisible
                        var ids = props.ids || "";
                        if (Array.isArray(ids)) ids = ids.join(",");
                        return buildAssigneeIcons({ AssignedToEmployeeIDs: ids }, props.maxVisible || 3);
                    }

                    if (type === "prioritySelect") {
                        var val = props.value || 3;
                        var idAttr = props.dataTaskId ? ` data-recordid="${props.dataTaskId}"` : "";
                        return `
                            <select class="form-select row-priority-select"${idAttr} style="width:110px;">
                                <option value="1" ${val==1?"selected":""}>Cao</option>
                                <option value="2" ${val==2?"selected":""}>Trung bình</option>
                                <option value="3" ${val==3?"selected":""}>Thấp</option>
                            </select>
                        `;
                    }

                    // Fallback: return empty string
                    return "";
                } catch (e) {
                    console.error("renderComponent error", e);
                    return "";
                }
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
                            var $selected = $(`.row-assignee[data-displayid="${taskIdForDom}"] .row-assignee-dropdown .control-row-assignee-item.selected`);
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
            function refreshTaskRowInList(taskId) {
                try {
                    var t = findTaskById(taskId);
                    if (!t) return;

                    var $row = $(`.task-row[data-recordid="${taskId}"]`);
                    if ($row.length) {
                        // Determine if this is rendered as a child/subtask
                        var isChild = $row.hasClass("subtask-row") || $row.closest(".subtask-container").length > 0;
                        // Generate new HTML for the row and replace the existing node
                        var newHtml = renderTaskRow(t, !!isChild);
                        $row.replaceWith(newHtml);
                    } else {
                        // Check inside subtask containers (headers) as a fallback
                        $(".subtask-container").each(function() {
                            var $r = $(this).find(`.task-row[data-recordid="${taskId}"]`);
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
                    <div class="cu-row task-row" data-recordid="${t.TaskID}">
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

                // Thêm dòng ở cuối: hiển thị nút "+" gọn — click sẽ mở vùng tạo/chọn công việc
                var footerHtml = `
                    <div class="cu-row temp-subtask d-flex align-items-center mt-3">
                        <div class="flex-grow-1">
                            <small class="text-muted">Tạo công việc mới</small>
                        </div>
                        <div>
                            <button id="btnListCreateToggle" class="text-success border-0" style="background:transparent;" title="Tạo công việc"><i class="bi bi-plus-lg fs-4"></i></button>
                        </div>
                    </div>`;

                $("#list-container").append(footerHtml);

                // Expanded HTML (inserted when user clicks "+") — reuse bootstrap classes and minimal inline styles
                var expandedCreateHtml = `
                    <div class="cu-row temp-subtask mt-3 d-flex align-items-start gap-3">
                        <div class="flex-grow-1">
                            <div class="fw-bold mb-1">Tạo công việc mới / Chọn có sẵn</div>
                            <div class="search-select position-relative">
                                <input type="text" id="listCreateParentSearch" class="form-control" autocomplete="off" placeholder="Nhập tên công việc hoặc chọn..." />
                            </div>
                        </div>
                        <div class="d-flex flex-column align-items-end" style="gap:6px;">
                            <button class="btn btn-sm btn-outline-secondary" id="btnListCreateCancel">Hủy</button>
                            <button class="btn btn-sm btn-primary" id="btnListCreateSave">Lưu</button>
                        </div>
                    </div>`;

                // When user clicks the "+" toggle, replace the minimal footer with the expanded create HTML
                $(document).on("click", ".temp-subtask:not(.expanded)", function(e) {
                    // Chỉ xử lý nếu chưa ở trạng thái expanded
                    e.stopPropagation();
                    // Thay thế toàn bộ dòng footer bằng form mở rộng
                    $(this).replaceWith(expandedCreateHtml);

                    // Populate select
                    try {
                        var opts = `<option value=""></option>` + (tasks || []).map(t =>
                            `<option value="${t.TaskID}">${escapeHtml(t.TaskName)}</option>`
                        ).join("");
                        $("#listCreateParentSelect").html(opts);
                        $("#listCreateParentSearch").focus();

                        try {
                            hpaControlCombobox("#listCreateParentSearch", {
                                field: "ParentTaskID",
                                tableName: "tblTask",
                                idColumnName: "TaskID",
                                idValue: currentTaskID,
                                displayId: currentTaskID,
                                options: (tasks || []).map(t => ({ value: t.TaskID, text: t.TaskName })),
                                ajaxListName: "EmployeeListAll_DataSetting_Custom",
                                placeholder: "Nhập tên công việc hoặc chọn...",
                                silent: true,
                                onSave: function(value, text) {
                                    try { $("#listCreateParentSelect").val(value); $("#listCreateParentSearch").val(text).addClass("search-valid"); } catch(e){}
                                }
                            });
                        } catch(initErr) { console.warn("init listCreateParent combobox error", initErr); }

                    } catch(e) { console.warn(e); }
                });

                // populate hidden select with tasks
                try {
                    var opts = `<option value=""></option>` + (tasks || []).map(t => `<option value="${t.TaskID}">${escapeHtml(t.TaskName)}</option>`).join("");
                    $("#listCreateParentSelect").html(opts);
                } catch(e) { console.warn(e); }

                $(document).on("click", "#btnListCreateSave", function() {
                    var sel = $("#listCreateParentSelect").val();
                    var txt = $("#listCreateParentSearch").val().trim();
                    if (sel) {
                        // selected existing
                        uiManager.showAlert({ type: "success", message: "Đã chọn công việc." });
                    } else if (txt) {
                        createParentInline(txt);
                        loadTasks();
                    }
                });
                $(document).on("click", "#btnListCreateCancel", function() {
                    try {
                        $("#listCreateParentSearch").val("");
                        $("#listCreateParentSelect").val("");
                        $("#listCreateParentDropdown").hide();
                        // restore minimal footer by replacing expanded block with footerHtml
                        try {
                            var $block = $(this).closest(".temp-subtask");
                            if ($block.length && typeof footerHtml !== "undefined") {
                                $block.replaceWith(footerHtml);
                            }
                        } catch(e) { console.warn(e); }
                    } catch(e) { console.warn(e); }
                });
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
                    <div class="row-main" style="width: fit-content; display: flex; align-items: center; gap: 12px; cursor: pointer;">
                        <div class="row-check" style="width:40px;">
                            <i class="bi bi-caret-right expand-icon" id="expand-icon-${header.HeaderID}"></i>
                        </div>
                        <div class="task-title">
                            ${escapeHtml(header.HeaderTitle)}
                        </div>
                    </div>
                    <div class="row-progress" style="width:220px;">
                        <div class="kpi-text">
                            <span>${completedCount}/${totalCount} hoàn thành</span>
                            <strong style="color: white">${progressPct}%</strong>
                        </div>
                        <div class="kpi-bar-bg">
                            <div class="kpi-bar-fill" style="width: ${progressPct}%;"></div>
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
                        <select class="form-select row-priority-select" data-recordid="${t.TaskID}" style="width:110px;">
                            <option value="1" ${prioVal==1?"selected":""}>Cao</option>
                            <option value="2" ${prioVal==2?"selected":""}>Trung bình</option>
                            <option value="3" ${prioVal==3?"selected":""}>Thấp</option>
                        </select>`;

                    // Build assignee display using shared component
                    var assigneeContainerId = `assignee-container-${t.TaskID}`;
                    var assigneeHtml = `<div id="${assigneeContainerId}" style="width:260px;flex-shrink:0;"></div>`;

                    // Initialize dropdown after render
                    setTimeout(async function() {
                        if ($(`#${assigneeContainerId}`).length === 0) {
                            console.warn("DOM chưa sẵn sàng:", assigneeContainerId);
                            return;
                        }
                        try {
                            var currentIds = [];
                            if (t.AssignedToEmployeeIDs) {
                                currentIds = String(t.AssignedToEmployeeIDs).split(",").map(s => s.trim()).filter(Boolean);
                            }
                            if ((!currentIds || currentIds.length === 0) && (window.EmployeeID_Login || LoginID)) {
                                currentIds = [String(window.EmployeeID_Login || LoginID)];
                            }

                            hpaControlEmployeeSelector(`#${assigneeContainerId}`, {
                                type: "employeesMulti",
                                displayId: t.TaskID,
                                showAvatar: true,
                                selectedIds: currentIds,
                                position: "right",
                                ajaxListName: "EmployeeListAll_DataSetting_Custom",
                                onChange: function(selectedIds, taskId) {
                                    var csv = selectedIds.join(",");
                                    var _p = [
                                        "LoginID", LoginID,
                                        "LanguageID", "VN",
                                        "TableName", "tblTask",
                                        "ColumnName", "AssignedToEmployeeIDs",
                                        "IDColumnName", "ChildTaskID",
                                        "ColumnValue", csv,
                                        "ID_Value", taskId
                                    ];
                                    AjaxHPAParadise({
                                        data: { name: "sp_Common_SaveDataTable", param: _p },
                                        success: function() {
                                            uiManager.showAlert({ type: "success", message: "Cập nhật người phụ trách thành công!" });

                                            // Update local data
                                            var task = allTasks.find(x => String(x.TaskID) === String(taskId));
                                            if (task) {
                                                task.AssignedToEmployeeIDs = csv;
                                            }

                                            // Refresh icons
                                            var icons = buildAssigneeIcons({ AssignedToEmployeeIDs: csv }, 3);
                                            $(`#${assigneeContainerId} .assignee-icons`).html(icons);
                                        },
                                        error: function() {
                                            uiManager.showAlert({ type: "error", message: "Cập nhật người phụ trách thất bại!" });
                                        }
                                    });
                                }
                            });
                        } catch(e) {
                            console.warn("Error initializing assignee dropdown:", e);
                        }
                    }, 100);

                    // status for subtask
                    var stClass = t.StatusCode == 2 ? "sts-2" : t.StatusCode == 3 ? "sts-3" : "sts-1";
                    var statusLabel = t.StatusLabel || (t.StatusCode == 1 ? "Chưa làm" : (t.StatusCode == 2 ? "Đang làm" : "Hoàn thành"));
                    var statusHtml = `<span class="badge-sts ${stClass} badge-toggle-status" data-recordid="${t.TaskID}" data-status="${t.StatusCode}">${statusLabel}</span>`;

                    // Return simplified row HTML
                    return `
                    <div class="cu-row task-row draggable subtask-row" data-recordid="${t.TaskID}" draggable="true" style="padding-left:30px; display:flex;align-items:center;gap:12px;">
                        <div class="row-check" style="width:40px;">
                            <i class="bi bi-grip-vertical row-drag-handle"></i>
                            <i class="bi bi-flag-fill priority-icon ${prioClass}"></i>
                        </div>
                        <div class="row-main" style="width:100%; display:flex;align-items:center; justify-content:space-between;">
                            <div class="task-title" title="${escapeHtml(t.TaskName)}">${t.TaskName}</div>
                            <div class="detail-icon" data-recordid="${t.TaskID}" title="Xem chi tiết"><i class="bi bi-box-arrow-up-right"></i></div>
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
                    statusHtml = `<span class="badge-sts ${stClass} badge-toggle-status" data-recordid="${t.TaskID}" data-status="${t.StatusCode}">${statusLabel}</span>`;
                }

                return `
                <div class="cu-row task-row draggable"
                    style="${isChild ? "padding-left:30px;" : ""}"
                    data-recordid="${t.TaskID}"
                    draggable="true">
                    <div class="row-check">
                        <i class="bi bi-grip-vertical row-drag-handle"></i>
                        <i class="bi bi-flag-fill priority-icon ${prioClass}"></i>
                    </div>
                    <div class="row-main" style="position: relative;">
                        <div class="task-title" title="${escapeHtml(t.TaskName)}">${t.TaskName}</div>
                        <div class="task-sub">
                            ${t.CommentCount > 0 ? `<span><i class="bi bi-chat-dots"></i> ${t.CommentCount}</span>` : ""}
                            <span class="text-muted">#${t.TaskID}</span>
                        </div>
                        <div class="detail-icon" data-recordid="${t.TaskID}" title="Xem chi tiết"><i class="bi bi-box-arrow-up-right"></i></div>
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
                console.log(taskID);
                // Tìm task từ tất cả các nguồn
                let task = findTaskById(taskID);
                if (!task) {
                    console.error("Task not found:", taskID);
                    uiManager.showAlert({ type: "error",  message: "Không tìm thấy thông tin công việc!",});
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
                var currentStatus = task.StatusCode || 1;
                $("#detailStatusSelect").val(currentStatus);

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

                // Hiện vùng upload file trong modal chi tiết
                try { $("#uploadArea").show(); } catch(e) {}

                setTimeout(function() {
                    try {
                        document.getElementById("mdlTaskDetail").focus();
                    } catch(e) {}

                    // 📅 Initialize Date Box cho ngày bắt đầu
                    if ($("#detailStartDate").length > 0) {
                        hpaControlDateBox("#detailStartDate", {
                            field: "MyStartDate",
                            tableName: "tblTask",
                            idColumnName: "TaskID",
                            idValue: taskID,
                            displayId: taskID,
                            onSave: (val) => {
                                task.MyStartDate = val;
                                $("#detailStartDate").text(formatSimpleDate(val));
                            }
                        });
                    }

                    // 📅 Initialize Date Box cho ngày kết thúc
                    if ($("#detailDueDate").length > 0) {
                        hpaControlDateBox("#detailDueDate", {
                            field: "MyDueDate",
                            tableName: "tblTask",
                            idColumnName: "TaskID",
                            idValue: taskID,
                            displayId: taskID,
                            onSave: (val) => {
                                task.MyDueDate = val;
                                $("#detailDueDate").text(formatSimpleDate(val));
                            }
                        });
                    }

                    // 📋 Initialize Select Box cho Priority
                    if ($("#detailPriority").length > 0) {
                        hpaControlSelectBox("#detailPriority", {
                            field: "Priority",
                            tableName: "tblTask",
                            idColumnName: "TaskID",
                            idValue: taskID,
                            displayId: taskID,
                            options: [
                                {value: 1, text: "Cao"},
                                {value: 2, text: "Trung bình"},
                                {value: 3, text: "Thấp"}
                            ]
                        });
                    }

                    // 📎 Initialize File Upload control
                    if ($("#attachmentsSection").length > 0) {
                        hpaControlAttachFile("#attachmentsSection", {
                            taskId: taskID,
                            field: "Attachments",
                            tableName: "tblTask",
                            maxSize: 10485760,
                            allowedTypes: ["pdf", "doc", "docx", "xls", "xlsx", "jpg", "png", "gif", "txt"]
                        });
                    }
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
            function updateTaskStatus(newStatus) {
                if (!currentTaskID) return;

                AjaxHPAParadise({
                    data: {
                        name: "sp_Task_UpdateStatus",
                        param: ["TaskID", currentTaskID, "LoginID", LoginID, "NewStatus", newStatus]
                    },
                    success: function() {
                        // Update UI
                        $(".status-quick-btn").removeClass("active");
                        $(`.status-quick-btn[data-status="${newStatus}"]`).addClass("active");

                        uiManager.showAlert({ type: "success",  message: "Cập nhật trạng thái thành công!",});

                        // Reload tasks
                        loadTasks();
                    },
                    error: function() {
                        uiManager.showAlert({ type: "error",  message: "Cập nhật trạng thái thất bại!",});
                    }
                });
            }
            function updateTaskStatusFromSelect() {
                var newStatus = parseInt($("#detailStatusSelect").val());
                if (!newStatus || !currentTaskID) return;

                AjaxHPAParadise({
                    data: {
                        name: "sp_Task_UpdateStatus",
                        param: ["TaskID", currentTaskID, "LoginID", LoginID, "NewStatus", newStatus]
                    },
                    success: function() {
                        // Show notification
                        var statusText = newStatus === 1 ? "Chưa làm" : newStatus === 2 ? "Đang làm" : "Hoàn thành";
                        uiManager.showAlert({ type: "success",  message: "Cập nhật trạng thái thành công!",});

                        // Reload tasks
                        loadTasks();
                    },
                    error: function() {
                        uiManager.showAlert({ type: "error",  message: "Cập nhật trạng thái thất bại!",});
                    }
                });
            }
            function renderComments(comments) {
                if(comments.length === 0) {
                    $("#commentsList").html(`<p class="text-muted small">Chưa có nhận xét nào</p>`);
                    return;
                }

                var html = (comments || []).map(function(c){ return renderComponent("commentItem", { comment: c }); }).join("");
                $("#commentsList").html(html);
            }
            function updateKPI() {
                var val = $("#txtUpdateKPI").val();
                var note = $("#txtUpdateNote").val();

                if(!val || val == "") {
                    uiManager.showAlert({ type: "error",  message: "Vui lòng nhập giá trị KPI!",});
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
                            uiManager.showAlert({ type: "success",  message: "Cập nhật KPI thành công!",});

                            // Reload tasks
                            loadTasks();
                        } catch(e) {
                            console.error("Error after updating KPI:", e);
                            loadTasks();
                        }
                    },
                    error: function(err) {
                        console.error("Error updating KPI:", err);
                        uiManager.showAlert({ type: "error",  message: "Cập nhật KPI thất bại!", });
                    }
                });
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

                        $(`.badge-toggle-status[data-recordid="${taskID}"]`)
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
                        uiManager.showAlert({ type: "error",  message: "Cập nhật trạng thái thất bại!", });
                    }
                });
            }
            function openAssignModal() {
                // Reset trạng thái và UI mỗi lần mở modal
                currentTemplate = [];
                currentChildTasks = [];
                $("#selParent").html("");
                $("#selAssignedBy").html("");
                $("#selMainUser").html("");
                $("#subtask-assign-container").html(`
                    <div class="empty-state" style="grid-column: 1 / -1;">
                        <i class="bi bi-inbox"></i>
                        <p>Vui lòng chọn Công việc chính ở trên</p>
                    </div>
                `);

                // Nếu chưa có `tasks` (danh sách công việc chính), luôn gọi API để lấy dữ liệu
                if (tasks && tasks.length !== 0) {
                    // tasks đã có → dùng luôn
                    renderAssignDropdowns();
                    showAssignModal();
                }

                // Khởi tạo employee selectors
                // Mặc định người yêu cầu và người chịu trách nhiệm chính lấy từ `window.EmployeeID_Login` nếu có, fallback `LoginID`
                var defaultEmp = (window.EmployeeID_Login || LoginID);
                hpaControlEmployeeSelector("#assignedBySelector", {
                    type: "employee",
                    selectedIds: [defaultEmp],
                    multi: false,
                    onChange: (ids) => { $("#selAssignedBy").val(ids[0]); }
                });

                hpaControlEmployeeSelector("#mainUserSelector", {
                    type: "employee",
                    selectedIds: [defaultEmp],
                    multi: false,
                    onChange: (ids) => { $("#selMainUser").val(ids[0]); }
                });

                showAssignModal();
            }
            function showAssignModal() {
                try {
                    if (document.activeElement && typeof document.activeElement.blur === "function") {
                        document.activeElement.blur();
                    }
                } catch(e) { /* ignore */ }

                var mdl = new bootstrap.Modal(document.getElementById("mdlAssign"));
                mdl.show();

                setTimeout(function() {
                    try {
                        document.getElementById("mdlAssign").focus();
                    } catch(e) { /* ignore */ }
                }, 80);
            }
            function renderAssignDropdowns() {
                console.log("renderAssignDropdowns");
                // 1. Render danh sách công việc chính
                $("#selParent").html(`<option value=""></option>` +
                    (tasks || []).map(t =>
                        `<option value="${t.TaskID}">${escapeHtml(t.TaskName)}</option>`
                    ).join("")
                );

                // 2. Render danh sách nhân viên (dùng `employees` toàn cục)
                const empOpts = `<option value="">-- Chọn nhân viên --</option>` +
                    (employees || []).map(e =>
                        `<option value="${e.EmployeeID}">${escapeHtml(e.FullName)} (${e.EmployeeID})</option>`
                    ).join("");

                // 3. Render người yêu cầu (mặc định chọn người đang đăng nhập)
                var defaultEmp = (window.EmployeeID_Login || LoginID);
                const empAssignedOpts = `<option value="">-- Người yêu cầu (mặc định) --</option>` +
                    (employees || []).map(e =>
                        `<option value="${e.EmployeeID}" ${e.EmployeeID == defaultEmp ? "selected" : ""}>
                            ${escapeHtml(e.FullName)} (${e.EmployeeID})
                        </option>`
                    ).join("");

                $("#selMainUser").html(empOpts);
                $("#selAssignedBy").html(empAssignedOpts);

                // 4. Đồng bộ input tìm kiếm (searchable select)
                syncSearchInputs();

                // 4.5 Initialize combobox for Parent selector — searchable + optional server search
                try {
                    hpaControlCombobox("#selParentSearch", {
                        field: "ParentTaskID",
                        tableName: "TaskName",
                        idColumnName: "TaskID",
                        idValue: currentTaskID,
                        displayId: currentTaskID,
                        options: (tasks || []).map(t => ({ value: t.TaskID, text: t.TaskName })),
                        ajaxListName: "EmployeeListAll_DataSetting_Custom",
                        placeholder: "Tìm hoặc chọn Công việc chính...",
                        onSave: function(value, text) {
                            try { $("#selParent").val(value); $("#selParentSearch").val(text).addClass("search-valid"); } catch(e){}
                        }
                    });
                } catch(e) { console.warn("init error", e); }

                // 5. Đặt ngày mặc định là hôm nay
                const today = new Date().toISOString().split("T")[0];
                $("#dDate").val(today);

                // 5.5 Initialize attachment control for assign modal (kept in main script)
                try {
                    if ($("#attachFileControl").length) {
                    hpaControlAttachFile("#attachFileControl", {
                            taskId: currentTaskID || 0,
                            field: "Attachments",
                            tableName: "tblTask"
                        });
                    }
                } catch (e) {
                    console.warn("init attachFileControl error", e);
                }
            }
            function syncSearchInputs() {
                try {
                    const asText = $("#selAssignedBy option:selected").text().trim() || "";
                    $("#selAssignedBySearch").val(asText).toggleClass("search-valid", !!$("#selAssignedBy").val());

                    const muText = $("#selMainUser option:selected").text().trim() || "";
                    $("#selMainUserSearch").val(muText).toggleClass("search-valid", !!$("#selMainUser").val());

                    const pText = $("#selParent option:selected").text().trim() || "";
                    $("#selParentSearch").val(pText).toggleClass("search-valid", !!$("#selParent").val());
                } catch(e) {
                    console.warn("syncSearchInputs error:", e);
                }
            }
            function loadAssignTemplate() {
                console.log("loadAssignTemplate");
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
                if(!pid) { uiManager.showAlert({ type: "warning",  message: "Vui lòng chọn Công việc chính trước khi thêm hàng",}); return; }

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
                    </div>
                    `;

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
            function showQuickSubtaskInput() {
                var pid = $("#selParent").val();
                if(!pid) { uiManager.showAlert({ type: "warning", message: "Vui lòng chọn Công việc chính trước khi thêm task con" }); return; }

                // If already visible, just focus
                if($("#quickAddWrapper").length) { $("#quickSubtaskInput").focus(); return; }

                var wrapper = `<div id="quickAddWrapper" style="grid-column:1 / -1; padding:8px 0;">
                    <div style="display:flex; gap:8px; align-items:center; position:relative;">
                        <input id="quickSubtaskInput" class="form-control" placeholder="Nhập tên task con hoặc chọn từ gợi ý..." autocomplete="off" style="min-width:260px;" />
                        <div class="search-select-dropdown" id="quickSubtaskDropdown" style="position:absolute; z-index:1060; display:none; max-height:220px; overflow:auto; border:1px solid #ddd; box-shadow:0 6px 18px rgba(0,0,0,0.08); background:#fff; top:40px; left:0; right:0;"></div>
                    </div>
                </div>`;

                // prepend so input appears on top
                $("#subtask-assign-container").prepend(wrapper);
                $("#quickSubtaskInput").focus();
            }
            function renderQuickSubtaskDropdown(q) {
                q = (q||"").toLowerCase();
                var pid = $("#selParent").val();
                var candidates = (allTasks || []).filter(function(t){
                    if(!t || !t.TaskName) return false;
                    if(String(t.TaskID) === String(pid)) return false; // skip self
                    if(t.ParentTaskID && Number(t.ParentTaskID) !== 0) return false; // skip those already children
                    if(t.Status === 5) return false; // skip disabled
                    if(t.PositionID && String(t.PositionID).trim() !== "") return false; // skip fixed tasks

                    return t.TaskName.toLowerCase().indexOf(q) !== -1;
                }).slice(0,50);

                var $dd = $("#quickSubtaskDropdown");
                if(!candidates || candidates.length === 0) {
                    $dd.html(`<div style="padding:10px;color:var(--text-muted);">Không có gợi ý</div>`).show();
                    return;
                }

                var html = candidates.map(function(t){
                    return `<div class="search-item-quick p-2" data-recordid="${t.TaskID}" style="cursor:pointer;border-bottom:1px solid #f1f3f5;">${escapeHtml(t.TaskName)}</div>`;
                }).join("");

                $dd.html(html).show();
            }
            function createSubtaskFromQuick(name) {
                var pid = $("#selParent").val();
                if(!pid) { uiManager.showAlert({ type: "warning", message: "Vui lòng chọn Công việc chính trước khi thêm task con" }); removeQuickAdd(); return; }
                name = (name||"").trim();
                if(!name) { removeQuickAdd(); return; }

                // First create the task
                AjaxHPAParadise({
                    data: {
                        name: "sp_Task_SaveTask",
                        param: [
                            "TaskID", 0,
                            "TaskName", name,
                            "PositionID", "",
                            "DefaultKPI", 0,
                            "Unit", "",
                            "Status", 1
                        ]
                    },
                    success: function(res) {
                        try {
                            var parsed = JSON.parse(res);
                            var newId = parsed.data && parsed.data[0] && parsed.data[0][0] && parsed.data[0][0].TaskID;
                            if(!newId) { throw new Error("No TaskID returned"); }

                            // then link it as child
                            AjaxHPAParadise({
                                data: {
                                    name: "sp_Task_SaveTaskRelations",
                                    param: ["ParentTaskID", pid, "ChildTaskIDs", String(newId)]
                                },
                                success: function() {
                                    removeQuickAdd();
                                    fetchAssignTemplate(pid);
                                    uiManager.showAlert({ type: "success", message: "Tạo task con thành công." });
                                },
                                error: function() {
                                    uiManager.showAlert({ type: "error", message: "Tạo quan hệ task con thất bại." });
                                }
                            });
                        } catch(e) {
                            console.warn(e);
                            uiManager.showAlert({ type: "error", message: "Tạo task thất bại." });
                        }
                    },
                    error: function() { uiManager.showAlert({ type: "error", message: "Tạo task thất bại." }); }
                });
            }
            function removeQuickAdd() { $("#quickAddWrapper").remove(); $("#quickSubtaskDropdown").remove(); }
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
                        <div style="flex: 2; min-width: 200px;">
                            <label class="form-label">Người thực hiện</label>
                            <div id="assignee-${validIdx}"></div>
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

                // Khởi tạo employee selectors cho mỗi subtask
                currentTemplate.forEach((item, idx) => {
                    hpaControlEmployeeSelector(`#assignee-${idx}`, {
                        type: "employee",
                        selectedIds: [],
                        multi: true,
                        onChange: function(selectedIds) {
                            // Lưu vào data attribute hoặc biến global
                            $(`#assignee-${idx}`).data("selected", selectedIds);
                        }
                    });
                });
            }
            function submitAssignment() {
                let parent = $("#selParent").val();
                let mainUser = $("#selMainUser").val();
                let dDate = $("#dDate").val();
                let dDue = $("#dDue").val();
                if(!parent || !mainUser) {
                    uiManager.showAlert({ type: "warning",  message: "Vui lòng chọn Công việc chính và Người chịu trách nhiệm chính",});
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
                // Group details by ChildTaskID so the stored-proc receives
                // objects with an "EmployeeIDs" array (or just ChildTaskID when empty)
                try {
                    var grouped = {};
                    details.forEach(function(d){
                        var cid = (d.ChildTaskID || 0).toString();
                        if(!grouped[cid]) grouped[cid] = {
                            ChildTaskID: d.ChildTaskID || 0,
                            ChildTaskName: d.ChildTaskName || null,
                            EmployeeIDs: [],
                            Notes: d.Notes || "",
                            Priority: d.Priority || 3,
                            StartDate: d.StartDate || null,
                            EndDate: d.EndDate || null
                        };
                        if(d.EmployeeID !== undefined && d.EmployeeID !== null) {
                            var v = String(d.EmployeeID);
                            if(grouped[cid].EmployeeIDs.indexOf(v) === -1) grouped[cid].EmployeeIDs.push(v);
                        }
                    });

                    var finalDetails = Object.keys(grouped).map(function(k){
                        var it = grouped[k];
                        var obj = { ChildTaskID: it.ChildTaskID };
                        if(it.EmployeeIDs && it.EmployeeIDs.length>0) obj.EmployeeIDs = it.EmployeeIDs;
                        if(it.Notes) obj.Notes = it.Notes;
                        if(it.Priority) obj.Priority = it.Priority;
                        if(it.StartDate) obj.StartDate = it.StartDate;
                        if(it.EndDate) obj.EndDate = it.EndDate;
                        return obj;
                    });

                    var assignedBy = $("#selAssignedBy").val() || LoginID;
                    // CommittedHours: no per-header input currently, send null by default
                    var committedHours = null;

                    AjaxHPAParadise({
                        data: {
                            name: "sp_Task_AssignWithDetails",
                            param: [
                                "ParentTaskID", parent,
                                "MainResponsibleID", mainUser,
                                "AssignmentDetails", JSON.stringify(finalDetails),
                                "AssignmentDate", dDate,
                                "AssignmentDueDate", dDue,
                                "CommittedHours", committedHours,
                                "AssignedBy", assignedBy
                            ]
                        },
                        success: function() {
                            uiManager.showAlert({
                                type: "success",
                                message: "Giao việc thành công!"
                            });
                            bootstrap.Modal.getInstance(document.getElementById("mdlAssign")).hide();
                            loadTasks();
                        }
                    });
                } catch(err) {
                    console.error("submitAssignment grouping error:", err);
                    uiManager.showAlert({ type: "danger", message: "Lỗi khi chuẩn bị dữ liệu giao việc" });
                }
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
                if(!name || name.trim()==="") { uiManager.showAlert({ type: "warning",  message: "Vui lòng nhập tên công việc",}); return; }
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
                                    uiManager.showAlert({
                                      type: "success",
                                        message: "Đã lưu thứ tự subtask thành công!"
                                    });
                                } else {
                                    console.error("Lỗi:", data.ErrorMessage);
                                    uiManager.showAlert({
                                        type: "error",
                                        message: "Không thể lưu thứ tự subtask: " + data.ErrorMessage
                                    });
                                }
                            }
                        } catch(e) {
                            console.error("Parse error:", e);
                        }
                    },
                    error: function(err) {
                        console.error("Lỗi khi lưu thứ tự:", err);
                        uiManager.showAlert({
                            type: "error",
                            message: "Không thể lưu thứ tự subtask do lỗi hệ thống."
                        });
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
                var headerId = null;

                // Lấy headerId từ row đầu tiên trong danh sách (hoặc từ dragging row)
                var firstRow = document.querySelector(".cu-list .cu-row.header-row");
                if (firstRow && firstRow.dataset && firstRow.dataset.headerid !== undefined) {
                    headerId = firstRow.dataset.headerid;
                }

                // Nếu vẫn không có thì thử lấy từ row đang dragging
                if (!headerId) {
                    var dragging = document.querySelector(".cu-list .cu-row.dragging");
                    if (dragging) {
                        var parentHeader = dragging.closest(".cu-list")?.querySelector(".header-row");
                        if (parentHeader) headerId = parentHeader.dataset.headerid;
                    }
                }

                $(".cu-list .cu-row.draggable:not(.header-row)").each(function() {
                    var taskId = $(this).data("recordid");
                    if (taskId) orderedIds.push(taskId);
                });

                if (orderedIds.length === 0) return;

                AjaxHPAParadise({
                    data: {
                        name: "sp_Task_UpdateMainTaskOrder",
                        param: [
                            "LoginID", LoginID,
                            "HeaderID", headerId,           // BÂY GIỜ ĐÃ CÓ GIÁ TRỊ
                            "OrderedTaskIDs", orderedIds.join(",")
                        ]
                    },
                    success: function(res) {
                        uiManager.showAlert({ type: "success", message: "Đã lưu thứ tự công việc!" });
                    },
                    error: function() {
                        uiManager.showAlert({ type: "error", message: "Lưu thứ tự thất bại!" });
                        loadTasks(); // rollback UI
                    }
                });
            }
            
            // Linh: Hàm control chọn nhân viên (đơn hoặc đa chọn)
            function hpaControlEmployeeSelector(el, config) {
                const $el = $(el);
                const defaults = {
                    type: "employeesMulti",
                    displayId: null,
                    selectedIds: [],
                    multi: true,
                    ajaxListName: null,
                    placeholder: "Tìm...",
                    position: "right",
                    maxVisible: 3,
                    onChange: null,
                    showAvatar: false,
                    showId: true,
                    showName: true
                };
                const cfg = { ...defaults, ...config };
                const displayId = cfg.displayId || cfg.recordId || null;

                function selIdsToCsv(arr) {
                    return (arr || []).map(x => String(x)).filter(Boolean).join(",");
                }
                console.log("run employees",employees);

                if ((!employees || employees.length === 0) && cfg.ajaxListName) {
                    AjaxHPAParadise({
                        data: { name: cfg.ajaxListName, param: ["LanguageID", cfg.language || "VN"] },
                        success: function(res) {
                            try {
                                const data = JSON.parse(res).data || [];
                                employees = data[0] || [];
                                console.log("run2 employees",employees);
                            } catch (e) {
                                employees = [];
                            }
                        }
                    });
                }

                function renderEmployeeItem(e, isSelected) {
                    const empId = String(e.EmployeeID);
                    const fullName = e.FullName || empId;
                    let labelHtml = "";

                    if (cfg.showName || cfg.showId) {
                        const namePart = cfg.showName ? escapeHtml(fullName) : "";
                        const idPart = cfg.showId ? escapeHtml(empId) : "";
                        if (namePart && idPart) {
                            labelHtml = `${namePart} (${idPart})`;
                        } else {
                            labelHtml = namePart || idPart;
                        }
                    }

                    // === FIXED AVATAR ===
                    let avatarHtml = "";
                    if (cfg.showAvatar && e.storeImgName && e.paramImg) {
                        avatarHtml = `
                            <img alt="${escapeHtml(e.FullName)}"
                                class="profile-img customer-avatar-birthday"
                                _name="${e.storeImgName}"
                                _param="${e.paramImg}"
                                data-employee-id="${e.EmployeeID}"
                                loading="lazy"
                                style="width:32px; height:32px; border-radius:50%; object-fit:cover; flex-shrink:0;"
                            />
                        `;
                    } else {
                        const initials = getInitials(fullName) || (empId.charAt(0) || "?").toUpperCase();
                        avatarHtml = `<div class="icon-chip">${escapeHtml(initials)}</div>`;
                    }

                    return `
                        <div class="control-row-assignee-item ${isSelected ? "selected" : ""}"
                            data-empid="${empId}"
                            data-empname="${escapeHtml(fullName)}"
                            style="padding:8px 10px; cursor:pointer; display:flex; align-items:center; gap:8px; border-bottom:1px solid #f0f2f5;">
                            ${cfg.multi ? `<div style="width:28px; flex-shrink:0;"><input type="checkbox" class="row-assignee-checkbox" ${isSelected ? "checked" : ""} /></div>` : `<div style="width:28px; flex-shrink:0;"></div>`}
                            ${avatarHtml}
                            ${labelHtml ? `<div style="flex:1; min-width:0; font-weight:600; font-size:14px;">${labelHtml}</div>` : ""}
                        </div>
                    `;
                }

                function renderSelectedChips(selectedIds) {
                    console.log("renderSelectedChips",selectedIds);
                    if (!selectedIds || selectedIds.length === 0) {
                        return `<div class="icon-chip" title="Chưa chọn">?</div>`;
                    }

                    const empMap = {};
                    (employees || []).forEach(e => { empMap[String(e.EmployeeID)] = e; });

                    const chips = selectedIds.map(empId => {

                        const e = empMap[empId];
                        const fullName = e ? e.FullName : empId;

                        const displayName = (cfg.showName && e?.FullName ? e.FullName : "") +
                                            (cfg.showId && e?.EmployeeID ? ` (${e.EmployeeID})` : "") ||
                                            empId;
                        console.log("run chips", cfg.showAvatar, e?.storeImgName, e?.paramImg);

                        // === FIXED AVATAR HERE ===
                        if (cfg.showAvatar && e?.storeImgName && e?.paramImg) {
                            console.log("render avatar",e);
                            return `
                                <img alt="Profile Picture" class="profile-img customer-avatar-birthday"
                                    _name="${e.storeImgName}"
                                    _param="${e.paramImg}"
                                    data-employee-id="${empId}"
                                    loading="lazy"
                                    title="${escapeHtml(displayName)}"
                                    style="width:28px; height:28px; border-radius:50%; object-fit:cover; margin-left:-8px; border:2px solid white; box-shadow:0 1px 0 rgba(0,0,0,0.04);"
                                />
                            `;
                        } else {
                            const initials = getInitials(fullName) || (empId.charAt(0) || "?").toUpperCase();
                            return `<div class="icon-chip" title="${escapeHtml(displayName)}">${escapeHtml(initials)}</div>`;
                        }
                    });

                    let visible = chips.slice(0, cfg.maxVisible).join("");
                    const remaining = chips.length - cfg.maxVisible;
                    if (remaining > 0) {
                        const allNames = selectedIds.map(id => {
                            const e = empMap[id];
                            return (cfg.showName && e?.FullName ? e.FullName : "") +
                                (cfg.showId && e?.EmployeeID ? ` (${e.EmployeeID})` : "") ||
                                id;
                        }).join(", ");
                        visible += `<div class="icon-more" title="${escapeHtml(allNames)}">+${remaining}</div>`;
                    }
                    return visible;
                }

                // == MULTI SELECT ==
                if (cfg.type === "employeesMulti") {
                    const containerId = `assignee-${displayId || Date.now()}`;
                    const html = `
                        <div class="row-assignee" data-displayid="${displayId || ""}" style="position:relative;">
                            <button type="button" class="btn btn-sm btn-light row-assignee-toggle" data-displayid="${displayId}"
                                style="display:flex;align-items:center;gap:8px;padding:6px 8px;width:100%;">
                                <div class="assignee-icons" style="display:flex;align-items:center;gap:0;" id="${containerId}-icons">
                                    ${renderSelectedChips(cfg.selectedIds)}
                                </div>
                                <i class="bi bi-chevron-down" style="font-size:12px;color:var(--text-muted);margin-left:auto;"></i>
                            </button>
                            <div class="row-assignee-dropdown" style="display:none;position:absolute;${cfg.position}:0;top:36px;z-index:2000;width:320px;backdrop-filter:blur(50px);border:1px solid var(--border-color);border-radius:6px;box-shadow:var(--shadow-md);">
                                <div style="padding:8px;border-bottom:1px solid var(--border-color);">
                                    <input id="selMultiEmployee" type="text" class="form-control form-control-sm row-assignee-search" placeholder="${escapeHtml(cfg.placeholder)}" />
                                </div>
                                <div class="row-assignee-list" style="max-height:260px;overflow:auto;padding:4px 0;"></div>
                            </div>
                        </div>
                    `;
                    $el.html(html);

                    const renderList = (filter) => {
                        const q = normalizeForSearch(filter || "");
                        let items = [];
                        (employees || []).forEach(e => {
                            const label = `${e.FullName || ""} (${e.EmployeeID || ""})`;
                            if (!q || normalizeForSearch(label).indexOf(q) !== -1) {
                                const isSelected = (cfg.selectedIds || []).indexOf(String(e.EmployeeID)) !== -1;
                                items.push(renderEmployeeItem(e, isSelected));
                            }
                        });
                        $el.find(".row-assignee-list").html(items.length ? items.join("") : `<div style="padding:8px 12px;color:#777;">Không tìm thấy</div>`);
                    };

                    renderList("");
                    $el.find(".row-assignee-search").on("input", (e) => renderList($(e.target).val()));

                    $el.on("click", ".control-row-assignee-item", (e) => {
                        e.stopPropagation();
                        const $it = $(e.currentTarget);
                        const empId = String($it.data("empid"));
                        let newSelected = [...cfg.selectedIds];

                        if (cfg.multi) {
                            const idx = newSelected.indexOf(empId);
                            if (idx === -1) newSelected.push(empId);
                            else newSelected.splice(idx, 1);
                            $it.toggleClass("selected", idx === -1);
                            $it.find(".row-assignee-checkbox").prop("checked", idx === -1);
                        } else {
                            newSelected = [empId];
                            $el.find(".row-assignee-dropdown").hide();
                        }

                        $el.find(".assignee-icons").html(renderSelectedChips(newSelected));
                        if (typeof cfg.onChange === "function") cfg.onChange(newSelected, displayId);
                    });

                    return $el.find(".row-assignee");
                }

                // == SINGLE SELECT ==
                if (cfg.type === "employee") {
                    const uniqueId = `emp-sel-${Date.now()}-${Math.random().toString(36).substr(2, 9)}`;
                    const html = `
                        <div class="control-employee-selector" data-id="${uniqueId}">
                            <div class="emp-sel-display" style="position:relative;">
                                <button type="button" class="btn btn-light emp-sel-trigger" style="width:100%;display:flex;align-items:center;gap:8px;padding:8px 12px;">
                                    <div class="emp-sel-icons">${renderSelectedChips(cfg.selectedIds)}</div>
                                    <i class="bi bi-chevron-down ms-auto"></i>
                                </button>
                            </div>
                            <div class="emp-sel-dropdown" style="display:none;position:absolute;z-index:2000;width:320px;background:white;border:1px solid #ddd;border-radius:8px;box-shadow:0 4px 12px rgba(0,0,0,0.15);margin-top:4px;">
                                <div style="padding:8px;border-bottom:1px solid #eee;">
                                    <input type="text" class="form-control form-control-sm emp-sel-search" placeholder="${escapeHtml(cfg.placeholder)}" />
                                </div>
                                <div class="emp-sel-list" style="max-height:260px;overflow:auto;padding:4px 0;"></div>
                            </div>
                        </div>
                    `;
                    $el.html(html);
                    const $type = $el.find(".control-employee-selector");

                    const renderList = (searchText) => {
                        const q = normalizeForSearch(searchText || "");
                        let html = "";
                        (employees || []).forEach(e => {
                            const label = `${e.FullName || ""} (${e.EmployeeID || ""})`;
                            if (!q || normalizeForSearch(label).indexOf(q) !== -1) {
                                const isSelected = (cfg.selectedIds || []).indexOf(String(e.EmployeeID)) !== -1;
                                html += renderEmployeeItem(e, isSelected);
                            }
                        });
                        $type.find(".emp-sel-list").html(html || `<div style="padding:20px;text-align:center;color:#999;">Không tìm thấy</div>`);
                    };

                    $type.find(".emp-sel-trigger").on("click", (e) => {
                        e.stopPropagation();
                        $(".emp-sel-dropdown").not($type.find(".emp-sel-dropdown")).hide();
                        $type.find(".emp-sel-dropdown").toggle();
                        renderList("");
                        $type.find(".emp-sel-search").focus();
                    });

                    $type.find(".emp-sel-search").on("input", (e) => renderList($(e.target).val()));

                    $type.on("click", ".control-row-assignee-item", (e) => {
                        e.stopPropagation();
                        const empId = String($(e.currentTarget).data("empid"));
                        cfg.selectedIds = [empId];
                        $type.find(".emp-sel-dropdown").hide();
                        $type.find(".emp-sel-icons").html(renderSelectedChips(cfg.selectedIds));
                        if (typeof cfg.onChange === "function") cfg.onChange(cfg.selectedIds, displayId);
                    });

                    $type.on("click", ".row-assignee-checkbox", (e) => {
                        e.stopPropagation();
                        $(e.currentTarget).closest(".control-row-assignee-item").trigger("click");
                    });

                    $(document).on("click.emp-sel-" + uniqueId, (e) => {
                        if (!$(e.target).closest($type).length) {
                            const $dropdown = $type.find(".emp-sel-dropdown");
                            if ($dropdown.is(":visible")) {
                                $dropdown.hide();
                                if (typeof cfg.onChange === "function") cfg.onChange(cfg.selectedIds, displayId);
                            }
                        }
                    });

                    $type.data("destroy", () => {
                        $(document).off("click.emp-sel-" + uniqueId);
                    });

                    return $type;
                }
            }
            
            function hpaControlDateBox(el, config) {
                const $el = $(el);
                const defaults = {
                    type: "date",
                    field: null,
                    tableName: null,
                    idColumnName: null,
                    taskId: currentTaskID,
                    getValue: () => $el.text().trim(),
                    setValue: (val) => $el.text(val),
                    silent: false,
                    onSave: null,
                    language: "VN"
                };
                const cfg = { ...defaults, ...config };
                if (!cfg.field || !cfg.tableName || !cfg.idColumnName) return console.error("thiếu field, tableName hoặc idColumnName");

                // Resolve ID used for persistence/display: prefer explicit displayId or recordId, fallback to global currentTaskID
                const resolvedId = cfg.displayId || cfg.recordId || currentTaskID;

                // Remove all old click handlers first
                $el.off("click.editable click.datebox click.selectbox").removeClass("editable editing");

                $el.on("click.datebox", function(e) {
                    e.stopPropagation();
                    if ($el.hasClass("editing")) return false;

                    const curVal = typeof cfg.getValue === "function" ? cfg.getValue() : cfg.getValue;
                    const $input = $("<input type=\"date\" class=\"form-control form-control-sm\">");
                    if (curVal) $input.val(curVal);

                    const $save = $("<button class=\"btn-edit btn-save\" title=\"Lưu\"><i class=\"bi bi-check-lg\"></i></button>");
                    const $cancel = $("<button class=\"btn-edit btn-cancel\" title=\"Hủy\"><i class=\"bi bi-x-lg\"></i></button>");
                    const $actions = $("<div class=\"edit-actions\"></div>").append($save).append($cancel);
                    const $wrap = $("<div class=\"hpa-form-controls d-flex align-items-end gap-1 w-100\"></div>").append($input).append($actions);

                    $el.addClass("editing").html("").append($wrap);
                    $input.focus();

                    let currentIdValue = resolvedId;
                    let isAddMode = false;

                    $input.on("input", function() {
                        const isEmpty = !$(this).val() || $(this).val().length === 0;
                        if (isEmpty && !isAddMode) {
                            isAddMode = true;
                            currentIdValue = null;
                            $save.html(`<i class="bi bi-plus-lg"></i>`).attr("title", "Thêm mới");
                        } else if (!isEmpty && isAddMode) {
                            isAddMode = false;
                            currentIdValue = resolvedId;
                            $save.html(`<i class="bi bi-check-lg"></i>`).attr("title", "Lưu");
                        }
                    });

                    const finish = (saveIt) => {
                        const newVal = $input.val();
                        $save.off("click");
                        $cancel.off("click");
                        $input.off("input");
                        $(document).off("click.datebox-doc");

                        $el.removeClass("editing");
                        if (!saveIt || newVal === curVal) {
                            typeof cfg.setValue === "function" ? cfg.setValue(curVal) : $el.text(curVal);
                            return;
                        }

                        const idVal = currentIdValue;
                        const params = [
                            "LoginID", LoginID,
                            "LanguageID", cfg.language || "VN",
                            "TableName", cfg.tableName,
                            "ColumnName", cfg.field,
                            "IDColumnName", cfg.idColumnName,
                            "ColumnValue", newVal,
                            "ID_Value", idVal
                        ];

                        AjaxHPAParadise({
                            data: { name: "sp_Common_SaveDataTable", param: params },
                            success: () => {
                                typeof cfg.setValue === "function" ? cfg.setValue(newVal) : $el.text(newVal);
                                const msgType = isAddMode ? "Đã thêm mới!" : "Đã cập nhật!";
                                if (!cfg.silent) uiManager.showAlert({ type: "success", message: msgType });
                                if (cfg.onSave) cfg.onSave(newVal, isAddMode);
                            },
                            error: () => {
                            uiManager.showAlert({ type: "error", message: "Cập nhật thất bại!" });
                                typeof cfg.setValue === "function" ? cfg.setValue(curVal) : $el.text(curVal);
                            }
                        });
                    };

                    $save.on("click", () => finish(true));
                    $cancel.on("click", (e) => {
                        e.stopPropagation();
                        e.preventDefault();
                        finish(false);
                        return false;
                    });

                    $(document).one("click.datebox-doc", (e) => {
                        if (!$(e.target).closest($el).length) finish(true);
                    });
                });
            }
            function hpaControlSelectBox(el, config) {
                const $el = $(el);
                const defaults = {
                    field: null,
                    tableName: null,
                    idColumnName: null,
                    taskId: currentTaskID,
                    options: [],
                    ajaxOptionsName: null, // stored-proc name to fetch options if options not provided
                    getValue: () => $el.data("value") || $el.text().trim(),
                    setValue: (val) => $el.text(val),
                    silent: false,
                    onSave: null,
                    language: "VN"
                };
                const cfg = { ...defaults, ...config };
                if (!cfg.field || !cfg.tableName || !cfg.idColumnName) return console.error("thiếu field, tableName hoặc idColumnName");

                // Resolve ID used for persistence/display: prefer explicit displayId or recordId, fallback to global currentTaskID
                const resolvedId = cfg.displayId || cfg.recordId || currentTaskID;

                function continueInit() {
                    if (!cfg.options || cfg.options.length === 0) return console.error("thiếu options để hiển thị");

                    // Remove all old click handlers first
                    $el.off("click.editable click.datebox click.selectbox").removeClass("editable editing");

                    $el.on("click.selectbox", function(e) {
                        e.stopPropagation();
                        if ($el.hasClass("editing")) return false;

                        const curVal = typeof cfg.getValue === "function" ? cfg.getValue() : cfg.getValue;
                        const $select = $("<select class=\"form-control form-control-sm\">");
                        cfg.options.forEach(o => {
                            $select.append(`<option value="${o.value}" ${String(o.value) === String(curVal) ? "selected" : ""}>${o.text}</option>`);
                        });

                        const $save = $("<button class=\"btn-edit btn-save\" title=\"Lưu\"><i class=\"bi bi-check-lg\"></i></button>");
                        const $cancel = $("<button class=\"btn-edit btn-cancel\" title=\"Hủy\"><i class=\"bi bi-x-lg\"></i></button>");
                        const $actions = $("<div class=\"edit-actions\"></div>").append($save).append($cancel);
                        const $wrap = $("<div class=\"hpa-form-controls d-flex align-items-end gap-1 w-100\"></div>").append($select).append($actions);

                        $el.addClass("editing").html("").append($wrap);
                        $select.focus();

                        let currentIdValue = resolvedId;
                        let isAddMode = false;

                        const finish = (saveIt) => {
                            const newVal = $select.val();
                            const newText = $select.find("option:selected").text();

                            $save.off("click");
                            $cancel.off("click");
                            $(document).off("click.selectbox-doc");

                            $el.removeClass("editing");
                            if (!saveIt || newVal === curVal) {
                                typeof cfg.setValue === "function" ? cfg.setValue(curVal) : $el.text(curVal);
                                return;
                            }

                            const idVal = currentIdValue;
                            const params = [
                                "LoginID", LoginID,
                                "LanguageID", cfg.language || "VN",
                                "TableName", cfg.tableName,
                                "ColumnName", cfg.field,
                                "IDColumnName", cfg.idColumnName,
                                "ColumnValue", newVal,
                                "ID_Value", idVal
                            ];

                            AjaxHPAParadise({
                                data: { name: "sp_Common_SaveDataTable", param: params },
                                success: () => {
                                    typeof cfg.setValue === "function" ? cfg.setValue(newText) : $el.text(newText);
                                    $el.data("value", newVal);
                                    if (!cfg.silent) uiManager.showAlert({ type: "success", message: "Đã cập nhật!" });
                                    if (cfg.onSave) cfg.onSave(newVal, newText);
                                },
                                error: () => {
                                    uiManager.showAlert({ type: "error", message: "Cập nhật thất bại!" });
                                    typeof cfg.setValue === "function" ? cfg.setValue(curVal) : $el.text(curVal);
                                }
                            });
                        };

                        $save.on("click", () => finish(true));
                        $cancel.on("click", (e) => {
                            e.stopPropagation();
                            finish(false);
                        });

                        $(document).one("click.selectbox-doc", (e) => {
                            if (!$(e.target).closest($el).length) finish(true);
                        });
                    });
                }

                // If options not provided but ajaxOptionsName is given, fetch them, else init immediately
                if ((!cfg.options || cfg.options.length === 0) && cfg.ajaxOptionsName) {
                    AjaxHPAParadise({
                        data: { name: cfg.ajaxOptionsName, param: ["LoginID", LoginID, "LanguageID", cfg.language || "VN"] },
                        success: function(res) {
                            cfg.options = Array.isArray(res) ? res : (res && res.data) || [];
                            continueInit();
                        },
                        error: function() { continueInit(); }
                    });
                } else {
                    continueInit();
                }
            }
            function hpaControlCombobox(el, config) {
                console.log("run combobox", el, config)
                const $el = $(el);
                const defaults = {
                    field: null,
                    tableName: null,
                    idColumnName: null,
                    options: [], // [{ value, text }]
                    ajaxListName: null,   // stored proc name to fetch list when user clicks
                    placeholder: "Chọn...",
                 minChars: 1,
                    silent: false,
                    onSave: null,
                    language: "VN"
                };
                const cfg = { ...defaults, ...config };
                if (!cfg.field || !cfg.tableName || !cfg.idColumnName) return console.error("thiếu field, tableName hoặc idColumnName");

                const isInput = $el.is("input") || $el.find("input").length > 0 && $el.find("input").is("input");
                let $input, $dropdown, baseName;

                if (isInput && $el.is("input")) {
                    $input = $el;
                    baseName = ($input.attr("id") || "").replace(/Search$/, "");
                    $dropdown = $input.closest(".search-select").find(".search-select-dropdown");
                } else if (isInput && !$el.is("input")) {
                    $input = $el.find("input").first();
                    baseName = ($input.attr("id") || "").replace(/Search$/, "");
                    $dropdown = $el.find(".search-select-dropdown").first();
                } else {
                    $el.off("click.combobox").removeClass("editable editing");
                    $input = $(`<input type="text" class="form-control form-control-sm" placeholder="${escapeHtml(cfg.placeholder)}" />`);
                    $dropdown = $(`<div class="combobox-dropdown" style="position:absolute;z-index:2000;max-height:240px;overflow:auto;border:1px solid var(--border-color);background:white;border-radius:6px;margin-top:6px;min-width:220px;"></div>`);
                    const $wrap = $(`<div style="position:relative;display:flex;gap:8px;align-items:flex-start;width:100%"></div>`).append($input).append($dropdown);
                    $el.addClass("editing").html("").append($wrap);
                    baseName = ($el.attr("id") || "").replace(/Search$/, "");
                }

                if (!$dropdown || $dropdown.length === 0) {
                    $dropdown = $(`<div class="combobox-dropdown" style="position:absolute;z-index:2000;max-height:240px;overflow:auto;border:1px solid var(--border-color);background:white;border-radius:6px;margin-top:6px;min-width:220px;"></div>`);
                    $input.after($dropdown);
                }

                $input.off(".combobox");
                const resolvedId = cfg.displayId || cfg.recordId || cfg.idValue || currentTaskID;

                const renderOptions = (items) => {
                    let html = "";
                    if (!items || items.length === 0) {
                        html = `<div class="search-empty" style="padding:12px;color:var(--text-muted);text-align:center;">Không có dữ liệu</div>`;
                    } else {
                        items.forEach(it => {
                            html += `<div class="combobox-item" data-value="${escapeHtml(it.value)}" style="padding:10px;cursor:pointer;border-bottom:1px solid #f0f0f0;hover:background:#f5f5f5;">${escapeHtml(it.text)}</div>`;
                        });
                    }
                    $dropdown.html(html).show();
                };

                let isLoading = false;
                let dataLoaded = false;

                const loadDataOnce = () => {
                    if (dataLoaded || isLoading) return;
                    if (!cfg.ajaxListName) return;

                    isLoading = true;
                    $dropdown.html(`<div style="padding:12px;color:var(--text-muted);text-align:center;">Đang tải...</div>`).show();

                    AjaxHPAParadise({
                        data: { name: cfg.ajaxListName, param: ["LoginID", LoginID, "LanguageID", cfg.language || "VN"] },
                        success: function(res) {
                            console.log("Load data cho hpaCombobox", res);
                            const items = Array.isArray(res) ? res : (res && res.data) || [];
                            cfg.options = items;
                            dataLoaded = true;
                            isLoading = false;
                            renderOptions(items);
                        },
                        error: function() {
                            isLoading = false;
                            $dropdown.html(`<div style="padding:12px;color:#d32f2f;text-align:center;">Lỗi tải dữ liệu</div>`).show();
                        }
                    });
                };

                const doLocalFilter = (q) => {
                    const normalized = (q || "").toString().toLowerCase();
                    const items = (cfg.options || []).filter(o => (o.text || "").toString().toLowerCase().indexOf(normalized) !== -1);
                    renderOptions(items);
                };

                // Load data on first focus/click
                $input.on("focus.combobox click.combobox", function() {
                    loadDataOnce();
                    if (dataLoaded) doLocalFilter($input.val());
                });

                let typingTimer = null;
                $input.on("input.combobox keyup.combobox", function(ev) {
                    const q = $(this).val();
                    clearTimeout(typingTimer);
                    typingTimer = setTimeout(() => {
                        if (dataLoaded) doLocalFilter(q);
                    }, 100);
                });

                $dropdown.off("click.combobox").on("click.combobox", ".combobox-item", function() {
                    const newVal = $(this).data("value");
                    const newText = $(this).text().trim();
                    saveSelection(newVal, newText);
                });

                function saveSelection(valueToSave, displayText) {
                    try {
                        if (baseName) {
                            const $hidden = $("#" + baseName);
                            if ($hidden.length) {
                                try { $hidden.val(valueToSave); $hidden.trigger("change"); } catch(e) {}
                            }
                        }
                    } catch(e) { console.warn(e); }

                    $input.val(displayText).removeClass("search-invalid").addClass("search-valid");
                    $dropdown.hide();

                    const params = [
                        "LoginID", LoginID,
                        "LanguageID", cfg.language || "VN",
                        "TableName", cfg.tableName,
                        "ColumnName", cfg.field,
                        "IDColumnName", cfg.idColumnName,
                        "ColumnValue", valueToSave,
                        "ID_Value", resolvedId
                    ];
                    AjaxHPAParadise({
                        data: { name: "sp_Common_SaveDataTable", param: params },
                        success: function() {
                            if (!cfg.silent) uiManager.showAlert({ type: "success", message: "Đã cập nhật!" });
                            if (cfg.onSave) cfg.onSave(valueToSave, displayText);
                        },
                        error: function() {
                            uiManager.showAlert({ type: "error", message: "Cập nhật thất bại!" });
                        }
                    });
                }

                $(document).one("click.combobox-doc", (e) => {
                    if (!$(e.target).closest($input).length && !$(e.target).closest($dropdown).length) {
                        $dropdown.hide();
                    }
                });
            }
            function hpaControlAttachFile(el, config) {
                const $el = $(el);
                const defaults = {
                    taskId: currentTaskID,
                    field: "Attachments",
                    tableName: "tblTask",
                    maxSize: 10485760, // 10MB
                    allowedTypes: ["pdf", "doc", "docx", "xls", "xlsx", "jpg", "png", "gif"],
                    onChange: null,
                    silent: false
                };
                const cfg = { ...defaults, ...config };

                // Resolve ID used for uploads/display: prefer explicit displayId or recordId, fallback to global currentTaskID
                const resolvedId = cfg.displayId || cfg.recordId || currentTaskID;

                // Create upload UI
                const uploadId = `upload-${resolvedId}-${Date.now()}`;
                const html = `
                    <div class="hpa-form-controls upload-container" style="border:2px dashed var(--border-color);border-radius:8px;padding:20px;text-align:center;cursor:pointer;transition:all 0.3s;">
                        <div style="font-size:32px;margin-bottom:10px;"><i class="bi bi-cloud-upload"></i></div>
                        <div style="font-weight:600;margin-bottom:4px;">Kéo file vào hoặc bấm để chọn</div>
                        <div style="font-size:12px;color:var(--text-muted);">Tối đa ${(cfg.maxSize / 1024 / 1024).toFixed(0)}MB</div>
                        <input type="file" id="${uploadId}" class="file-input" style="display:none;" multiple />
                    </div>
                    <div class="file-list" style="margin-top:16px;"></div>
                `;
                $el.html(html);

                const $upload = $el.find(".upload-container");
                const $fileInput = $el.find(".file-input");
                const $fileList = $el.find(".file-list");

                // Drag & drop
                $upload.on("dragover", (e) => {
                    e.preventDefault();
                    $upload.css("background", "rgba(46,125,50,0.05)").css("border-color", "var(--task-primary)");
                });

                $upload.on("dragleave", () => {
                    $upload.css("background", "").css("border-color", "var(--border-color)");
                });

                $upload.on("drop", (e) => {
                    e.preventDefault();
                    $upload.css("background", "").css("border-color", "var(--border-color)");
                    handleFiles(e.originalEvent.dataTransfer.files);
                });

                $upload.on("click", () => $fileInput.click());
                $fileInput.on("change", function() { handleFiles(this.files); });

                function handleFiles(files) {
                    const fileArray = Array.from(files);
                    let validFiles = [];

                    fileArray.forEach(file => {
                        const ext = file.name.split(".").pop().toLowerCase();
                        if (!cfg.allowedTypes.includes(ext)) {
                            if (!cfg.silent) uiManager.showAlert({ type: "error", message: `File ${file.name}: loại không được phép` });
                            return;
                        }
                        if (file.size > cfg.maxSize) {
                            if (!cfg.silent) uiManager.showAlert({ type: "error", message: `File ${file.name}: vượt quá dung lượng tối đa` });
                            return;
                        }
                        validFiles.push(file);
                    });

                    if (validFiles.length === 0) return;

                    // Show uploading status
                    let html = "";
                    validFiles.forEach((file, idx) => {
                        const fileId = `file-${Date.now()}-${idx}`;
                        html += `
                            <div class="file-item" data-fileid="${fileId}" style="display:flex;align-items:center;gap:10px;padding:10px;background:#f9f9f9;border-radius:6px;margin-bottom:8px;border:1px solid var(--border-color);">
                                <i class="bi bi-file-earmark" style="font-size:20px;color:var(--task-primary);"></i>
                                <div style="flex:1;min-width:0;">
                                    <div style="font-weight:600;font-size:13px;white-space:nowrap;overflow:hidden;text-overflow:ellipsis;">${escapeHtml(file.name)}</div>
                                    <div style="font-size:12px;color:var(--text-muted);">${(file.size / 1024).toFixed(1)}KB</div>
                                </div>
                                <div style="display:flex;gap:6px;">
                                    <button class="btn-file-download" style="padding:4px 8px;border:1px solid var(--border-color);border-radius:4px;background:white;cursor:pointer;font-size:12px;display:none;">Tải</button>
                                    <button class="btn-file-delete" style="padding:4px 8px;border:1px solid var(--border-color);border-radius:4px;background:#fee;color:var(--danger-color);cursor:pointer;font-size:12px;"><i class="bi bi-trash"></i></button>
                                </div>
                            </div>
                        `;
                    });
                    $fileList.html(html);

                    // Handle delete button
                    $el.on("click", ".btn-file-delete", function() {
                        $(this).closest(".file-item").remove();
                    });

                    // Auto upload via API
                    const formData = new FormData();
                    formData.append("LoginID", LoginID);
                    formData.append("TaskID", resolvedId);
                    formData.append("TableName", cfg.tableName);

                    validFiles.forEach(file => {
                        formData.append("files", file);
                    });

                    // Call upload API
                    fetch("/api/upload", {
                        method: "POST",
                        body: formData
                    }).then(res => res.json()).then(data => {
                        if (data.success) {
                            if (!cfg.silent) uiManager.showAlert({ type: "success", message: "Đã upload file!" });
                            if (cfg.onChange) cfg.onChange(data.files);
                        } else {
                            uiManager.showAlert({ type: "error", message: "Upload thất bại!" });
                        }
                    }).catch(err => {
                        uiManager.showAlert({ type: "error", message: "Lỗi upload!" });
                        console.error(err);
                    });
                }
            }
        })();
    </script>
    ';
    SELECT @html AS html;
END
GO

EXEC sp_GenerateHTMLScript 'sp_Task_MyWork_html'
