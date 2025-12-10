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
            white-space: nowrap;
        }

        #sp_Task_MyWork_html .status-select {
            min-width: 200px;
            border-radius: var(--radius-md);
            font-weight: 600;
            font-size: 14px;
   cursor: pointer;
            transition: all var(--transition-base);
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

        /* Priority Field Wrapper */
        #sp_Task_MyWork_html .priority-field-wrapper {
            min-width: 200px;
        }

        #sp_Task_MyWork_html .priority-field-wrapper .hpa-field-display {
            border-radius: var(--radius-md);
            font-weight: 600;
            font-size: 14px;
            cursor: pointer;
            transition: all var(--transition-base);
            min-height: 38px;
            position: relative;
        }

        #sp_Task_MyWork_html .priority-field-wrapper .hpa-field-display:hover {
            border-color: var(--task-primary);
        }

        #sp_Task_MyWork_html .priority-field-wrapper .hpa-field-display.focused {
            border-color: var(--task-primary);
            box-shadow: 0 0 0 3px rgba(46, 125, 50, 0.1);
        }

        /* Icon styling for priority field */
        #sp_Task_MyWork_html .priority-field-wrapper .hpa-field-icon {
            right: 12px !important;
            top: 50% !important;
            transform: translateY(-50%) !important;
        }

        /* Hide duplicate icons in priority field */
        #sp_Task_MyWork_html .priority-field-wrapper .hpa-field-clear {
            display: none !important;
        }

        /* Assign Modal */
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
            padding-bottom: 24px;
            border-bottom: 1px solid var(--border-color);
        }
        #sp_Task_MyWork_html .assign-step:last-child {
            border-bottom: none;
            margin-bottom: 0;
        }
        #sp_Task_MyWork_html .step-header {
            display: flex;
            align-items: center;
            gap: 12px;
            margin-bottom: 18px;
        }
        #sp_Task_MyWork_html .step-number {
            width: 40px;
            height: 40px;
            background: linear-gradient(135deg, var(--task-primary), #1c975e);
            color: white;
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            font-weight: 800;
            font-size: 18px;
            flex-shrink: 0;
            box-shadow: 0 2px 8px rgba(46, 125, 50, 0.2);
        }
        #sp_Task_MyWork_html .step-title {
            font-size: 16px;
            font-weight: 700;
            color: var(--text-primary);
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
            margin-bottom: 16px;
            flex: 1;
            min-width: 220px;
        }
        #sp_Task_MyWork_html .form-label {
            font-size: 12px;
            font-weight: 700;
            margin-bottom: 6px;
            display: block;
            color: var(--text-primary);
            text-transform: uppercase;
            letter-spacing: 0.3px;
        }
        #sp_Task_MyWork_html .form-select {
            font-size: 14px;
        }
        #sp_Task_MyWork_html .form-control,
        #sp_Task_MyWork_html .form-select,
        #sp_Task_MyWork_html .hpa-combobox,
        #sp_Task_MyWork_html [role="combobox"] {
            width: 100%;
            padding: 10px 12px;
            border: none;
            border-radius: var(--radius-md);
            transition: all var(--transition-base);
            font-size: 14px;
        }
        #sp_Task_MyWork_html .form-control::placeholder,
        #sp_Task_MyWork_html .form-select::placeholder {
            color: var(--text-muted);
        }
        #sp_Task_MyWork_html .form-control:hover,
        #sp_Task_MyWork_html .form-select:hover,
        #sp_Task_MyWork_html .hpa-combobox:hover,
        #sp_Task_MyWork_html [role="combobox"]:hover {
            border-color: var(--task-primary);
            box-shadow: 0 2px 6px rgba(46, 125, 50, 0.04);
        }
        #sp_Task_MyWork_html .form-control:focus,
        #sp_Task_MyWork_html .form-select:focus,
        #sp_Task_MyWork_html .hpa-combobox:focus,
        #sp_Task_MyWork_html [role="combobox"]:focus {
            border-color: var(--task-primary);
            outline: none;
            box-shadow: 0 0 0 3px rgba(46, 125, 50, 0.15);
            background: rgba(46, 125, 50, 0.02);
        }
        /* Searchable select: consistent sizing and responsive dropdown */
        #sp_Task_MyWork_html .search-select { display: inline-block; vertical-align: middle; }
        #sp_Task_MyWork_html .search-select input.form-control {  width: 320px; min-width:180px; max-width: 100%; height: 40px; padding-right: 12px; }
        #sp_Task_MyWork_html .search-select .search-select-dropdown {  box-sizing: border-box; height:200px; width: 320px; min-width: 180px; max-width: 100%; border-radius:6px; overflow:auto; backdrop-filter: blur(50px); -webkit-backdrop-filter: blur(50px); }
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
                            <div id="detailStatusSelect" class="status-select">
                            </div>
                        </div>
                        <div class="status-select-wrapper">
                            <label for="detailPriority">
                                Ưu tiên:
                            </label>
                            <div id="detailPriority" class="priority-field-wrapper"></div>
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
                                    <label class="form-label">Công việc chính (Task cha)</label>
                                    <div id="parentTaskCombobox"></div>
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
            var avatarLoadStatus = {}; // employeeId → "loading" | "loaded" | "failed"
            var currentTaskID = null;
            var currentTaskPriority = 3; // Default priority

            // ============================================
            // CACHE GLOBALS - Tối ưu API calls
            // ============================================
            var globalCacheStorage = {
                allTasksLoaded: false,
                selectBoxState: {}, // {elementId: {value, text, dirty}}
                selectBoxOptions: {} // {optionKey: [...options]} - cache options từ config
            };

            // Helper: Normalize string cho search (remove diacritics, lowercase)
            function normalizeForSearch(str) {
                if (!str) return "";
                return String(str)
                    .toLowerCase()
                    .normalize("NFD")
                    .replace(/[\u0300-\u036f]/g, "")
                    .trim();
            }

            // Expose only specific APIs intentionally
            window.toggleHeaderExpand = toggleHeaderExpand;
            window.updateTaskStatus = updateTaskStatus;
            $(document).ready(function() {
                attachUIHandlers();
                loadTasks();
            });

            function attachUIHandlers() {
                // Cache jQuery selectors
                const $btnAssign = $("#btnAssign");
                const $btnRefresh = $("#btnRefresh");
                const $btnUpdateKPI = $("#btnUpdateKPI");
                const $btnAddParentOpen = $("#btnAddParentOpen");
                const $btnQuickAddSubtask = $("#btnQuickAddSubtask");
                const $btnReloadChecklist = $("#btnReloadChecklist");
                const $btnSubmitAssignment = $("#btnSubmitAssignment");
                const $doc = $(document);

                // Static buttons
                $btnAssign.on("click", openAssignModal);
                $btnRefresh.on("click", loadTasks);
                $btnUpdateKPI.on("click", updateKPI);
                $btnAddParentOpen.on("click", openAddParentModal);
                $btnQuickAddSubtask.on("click", showQuickSubtaskInput);
                $btnReloadChecklist.on("click", reloadChecklist);
                $btnSubmitAssignment.on("click", submitAssignment);

                // Delegated handlers for dynamic elements
                $doc.off("click", ".task-row:not(.header-row)");
                $doc.on("click", ".task-row .detail-icon", function(e) {
                    e.stopPropagation();
                    e.preventDefault();
                    var id = $(this).data("recordid") || $(this).closest(".task-row").data("recordid");
                    if (id) openTaskDetail(id);
                });

                // Riêng cho header row - không mở detail
                $doc.on("click", ".header-row", function(e) {
                    e.stopPropagation();
                    var headerId = $(this).data("headerid");
                    if(headerId) toggleHeaderExpand(headerId);
                });

                $doc.on("click", ".badge-toggle-status", function(e) {
                    e.stopPropagation();
                    e.preventDefault();
                    var id = $(this).data("recordid");
                    var code = parseInt($(this).data("status")) || 1;
                    if(id) toggleStatus(id, code);
                });

                $doc.on("click", ".btn-temp-remove", function() {
                    $(this).closest(".temp-subtask").remove();
                });

                // Toggle subtask status (in detail table)
                $doc.on("click", ".subtask-toggle-status", function(e) {
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

                // Create parent modal button may be appended dynamically
                $doc.on("click", "#btnCreateParent", function() {
                    createParentFromModal();
                });

                // When hidden parent select changes, hide subtasks if cleared
                $doc.on("change", "#selParent", function() {
                    if(!$(this).val()) {
                       $("#subtask-assign-container").html(`<div class="empty-state" style="grid-column: 1 / -1;"><i class="bi bi-inbox"></i><p>Vui lòng chọn Công việc chính ở trên</p></div>`);
                    }
              });

                $(document).on("click", ".row-assignee-toggle", function(e) {
                    e.stopPropagation();
                    var $btn = $(this);
                    var $wrap = $btn.closest(".row-assignee");

                    // Đóng tất cả dropdown khác TRƯỚC (bất kể dropdown này có tồn tại hay chưa)
                    $(".row-assignee-dropdown:visible").not($wrap.find(".row-assignee-dropdown")).hide();

                    var $dd = $wrap.find(".row-assignee-dropdown");

                    // Nếu dropdown này đã mở thì chỉ đóng nó
                    if($dd.is(":visible")) {
                        $dd.hide();
                        return;
                    }

                    // Mở dropdown hiện tại
                    $dd = $wrap.find(".row-assignee-dropdown");
                    if($dd.length) {
                        $dd.show();
                        $dd.find(".row-assignee-search").val("").focus();

                    }
                });


                // Filter assignee list
                $(document).on("input", ".row-assignee-search", function(e){
                    e.stopPropagation();
                    var q = normalizeForSearch($(this).val() || "");
                    var $list = $(this).closest(".row-assignee-dropdown").find(".row-assignee-list");
                    $list.children().each(function(){
                        var $it = $(this);
                        var name = ($it.find("div").first().text() || "") + " " + ($it.find("div").last().text() || "");
                        if(!q || normalizeForSearch(name).indexOf(q) !== -1) $it.show(); else $it.hide();
                    });
                });

                // Checkbox click: prevent bubbling to parent and reflect visual state
                $(document).on("click", ".row-assignee-checkbox", function(e){
                    e.stopPropagation();
                    var $chk = $(this);
                    var $it = $chk.closest(".control-row-assignee-item");
                    $it.toggleClass("selected", $chk.prop("checked"));
                });

                // Click on row item toggles selection (when clicking outside the checkbox)
                $(document).on("click", ".control-row-assignee-item", function(e){
                    e.stopPropagation();
                    if ($(e.target).is(".row-assignee-checkbox")) return; // already handled
                    var $it = $(this);
                    var $chk = $it.find(".row-assignee-checkbox");
                    var now = !$chk.prop("checked");
                    $chk.prop("checked", now);
                    $it.toggleClass("selected", now);
                });

                // Delegated input handlers for dynamic/temp filters (replaces inline oninput)
                $(document).on("input", ".temp-sub-filter", function() {
                    try {
                        var target = $(this).data("target");
                        if(target && target !== "" && target !== "undefined") {
                            filterTempOptions(this);
                        }
                    } catch(e) {
                    }
                });
                $(document).on("input", ".st-user-filter", function() {
                    try {
                        var idx = $(this).data("idx");
                        if(idx !== undefined && idx !== null && idx !== "") {
                            filterMultiOptions(idx, $(this).val());
                        }
                    } catch(e) {
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
                    try { refreshSelectedUsersDisplay(idx); } catch(err) {
                    }
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
                $(document).on("click", ".st-priority", function(e) {
                    e.stopPropagation();
                });
                $("#viewListT, #viewKanbanT").on("click", function() {
                    updateView($(this).attr("id") === "viewListT" ? "list" : "kanban");
                });
                $("#detailStatusSelect").change(function() {
                    updateTaskStatusFromSelect();
                })
                // Khi thay đổi bộ lọc trạng thái
                $("#filterStatus, #filterOverdue").on("change", updateView);
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
                // Nếu đã tải → dùng cache, không gọi lại
                if (globalCacheStorage.allTasksLoaded && allTasks.length > 0) {
                    updateStatistics();
                    updateView("list");
                    return;
                }

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

                            // ✅ Mark cache as loaded
                            globalCacheStorage.allTasksLoaded = true;

                            AjaxHPAParadise({
                                data: { name: "EmployeeListAll_DataSetting_Custom", param: [] },
                                success: function(setupRes) {
                                    try {
                                        var setupData = JSON.parse(setupRes).data || [];
                             employees = setupData[0] || employees || [];
                                    } catch (ex) {
                                    }
                                    // Now we have employees (or empty) -> proceed to render
                                    updateStatistics();
                                    updateView("list");
                                },
                                error: function() {
                                    // Failed to load employees - continue anyway (will fallback to IDs)
                                    updateStatistics();
                                    updateView("list");
                                }
                            });
                        } catch(e) {
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
                try { $("#parentTaskCombobox").val(newId); } catch(e) {}
                // load template (likely empty)
                loadAssignTemplate();
            }
            function updateView(view) {
                // 1. Cập nhật view nếu có truyền tham số view
                if (view) {
                    $(".view-btn").removeClass("active");
                    if (view === "list") {
                        $("#viewListT").addClass("active");
                    } else {
                        $("#viewKanbanT").addClass("active");
                    }
                    currentView = view;
                }

                // 2. Lọc task
                var statusFilter = $("#filterStatus").val();
                var overdueFilter = $("#filterOverdue").val();

                filteredTasks = allTasks.filter(function (t) {
                    var statusMatch = !statusFilter || t.StatusCode == statusFilter;
                    var overdueMatch = !overdueFilter || (overdueFilter == "1" && t.IsOverdue == 1);
                    return statusMatch && overdueMatch;
                });

                // 3. Hiển thị view phù hợp
                if (currentView === "list") {
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

                    // Fallback: return empty string
                    return "";
                } catch (e) {
                    return "";
                }
            }
            function normalizeForSearch(s) {
                if (!s && s !== "") return "";
                try {
                    var str = String(s || "").toLowerCase();

                    // Bản đồ ký tự tiếng Việt đầy đủ (bao gồm tất cả dấu và biến thể)
                    var vietnameseMap = {
                        "à": "a", "á": "a", "ả": "a", "ã": "a", "ạ": "a",
                        "ă": "a", "ằ": "a", "ắ": "a", "ẳ": "a", "ẵ": "a", "ặ": "a",
                        "â": "a", "ầ": "a", "ấ": "a", "ẩ": "a", "ẫ": "a", "ậ": "a",
                        "è": "e", "é": "e", "ẻ": "e", "ẽ": "e", "ẹ": "e",
                        "ê": "e", "ề": "e", "ế": "e", "ễ": "e", "ệ": "e",
                        "ì": "i", "í": "i", "ỉ": "i", "ĩ": "i", "ị": "i",
                        "ò": "o", "ó": "o", "ỏ": "o", "õ": "o", "ọ": "o",
                        "ô": "o", "ồ": "o", "ố": "o", "ổ": "o", "ỗ": "o", "ộ": "o",
                        "ơ": "o", "ờ": "o", "ớ": "o", "ở": "o", "ỡ": "o", "ợ": "o",
                        "ù": "u", "ú": "u", "ủ": "u", "ũ": "u", "ụ": "u",
                        "ư": "u", "ừ": "u", "ứ": "u", "ử": "u", "ữ": "u", "ự": "u",
                        "ỳ": "y", "ý": "y", "ỷ": "y", "ỹ": "y", "ỵ": "y",
                        "đ": "d"
                    };

                    // Áp dụng bản đồ ký tự
                    var result = "";
                    for (var i = 0; i < str.length; i++) {
                        var char = str[i];
                        result += vietnameseMap[char] || char;
                    }

                    // Fallback: NFD normalization cho các ký tự khác
                    return result.normalize ? result.normalize("NFD").replace(/[\u0300-\u036f]/g, "") : result;
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
                                <div id="listCreateParentSearch" class="w-100"></div>
                                <select id="listCreateParentSelect" class="form-select d-none"></select>
                            </div>
                        </div>
          <div class="d-flex flex-column align-items-end" style="gap:6px;">
                            <small class="text-muted">Nhập xong nhấn Enter hoặc chọn để lưu</small>
                        </div>
                    </div>
                `;

                // When user clicks the "+" toggle, replace the minimal footer with the expanded create HTML
                $(document).on("click", "#btnListCreateToggle", function(e) {
                    e.stopPropagation();
                    // Thay thế toàn bộ dòng footer bằng form mở rộng
                    $(this).closest(".temp-subtask").replaceWith(expandedCreateHtml);

                    // Populate select
                    try {
                        var opts = `<option value=""></option>` + (tasks || []).map(t =>
                            `<option value="${t.TaskID}">${escapeHtml(t.TaskName)}</option>`
                        ).join("");
                        $("#listCreateParentSelect").html(opts);

                        try {
                            var listCreateHpa = hpaControlField("#listCreateParentSearch", {
                                searchable: true,
                                placeholder: "Nhập tên công việc hoặc chọn...",
                                useApi: true,
                                take: 20,
                                ajaxListName: "sp_Task_GetListChildCandidate",
                                tableName: "tblTask",
                                columnName: "TaskID",
                                idColumnName: "TaskID",
                                idValue: currentTaskID,
                                onChange: function(value, text) {
                                    try {
                                        $("#listCreateParentSelect").val(value);
                                        try { $("#listCreateParentSearch").find(".hpa-field-text").addClass("search-valid"); } catch(e) {}
                                    } catch(e) {}
                                }
                            });
                            // open dropdown to allow immediate typing/search
                            try { $("#listCreateParentSearch .hpa-field-display").first().trigger("click"); } catch(e) {}
                        } catch(initErr) {}
                    } catch(e) {}
                });

                // Auto-save when user presses Enter in the internal hpa-field search input
                $(document).on("keyup", "#listCreateParentSearch .hpa-field-search-input", function(e) {
                    try {
                        if (e.key === "Enter" || e.keyCode === 13) {
                            var sel = $("#listCreateParentSelect").val();
                            var txt = $(this).val().trim();
                            if (sel) {
                                uiManager.showAlert({ type: "success", message: "Đã chọn công việc." });
                            } else if (txt) {
                                createParentInline(txt);
                                loadTasks();
                            }
                            // restore minimal footer
                            try {
                                var $block = $(this).closest(".temp-subtask");
                                if ($block.length && typeof footerHtml !== "undefined") {
                                    $block.replaceWith(footerHtml);
                                }
                            } catch(e) {}
                        }
                    } catch(e) {}
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
                    // Initialize priority controls after list render
                    try { initRowPriorityControls(); } catch(e) {}
                }, 50);
            }

            // Initialize priority controls in a deterministic way.
            // Call this after the list HTML is rendered so elements exist in the DOM.
            function initRowPriorityControls(context) {
                var $root = context ? $(context) : $(document);
                $root.find(".row-priority-select, .row-priority-field").each(function () {
                    const $el = $(this);
                    const historyId = $el.data("recordid") || $el.closest(".cu-row").data("historyid") || $el.closest(".cu-row").data("taskid");
                    const currentPriority = parseInt($el.data("priority") || $el.data("current-priority") || $el.val() || 3);

                    // Avoid double-init: if already initialized (wrapper present), skip
                    if ($el.hasClass("hpa-field-wrapper") || $el.closest(".hpa-field-wrapper").length) return;

                    try {
                        hpaControlField(this, {
                            options: [
                                { value: 1, text: "Cao" },
                                { value: 2, text: "Trung bình" },
                                { value: 3, text: "Thấp" }
                            ],
                            selected: currentPriority,
                            tableName: "tblAssignHistory",
                            columnName: "AssignPriority",
                            idColumnName: "HistoryID",
                            idValue: historyId,
                            silent: false,
                            onChange: function(newValue) {
                                try {
                                    $el.closest(".cu-row").find(".priority-icon")
                                        .removeClass("prio-1 prio-2 prio-3")
                                        .addClass("prio-" + newValue);
                                } catch (e) {}
                                try { updateStatistics(); } catch(e) {}
                            }
                        });
                    } catch (e) {}
                });
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
                        <div class="row-priority-select" data-recordid="${t.TaskID}" style="width:110px;">
                        </div>`;

                    // Build assignee display using shared component
                    var assigneeContainerId = `assignee-container-${t.TaskID}`;
                    var assigneeHtml = `<div id="${assigneeContainerId}" style="width:260px;flex-shrink:0;"></div>`;

                    // Initialize dropdown after render
                    setTimeout(async function() {
                        if ($(`#${assigneeContainerId}`).length === 0) {
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

                                            // Lấy danh sách EmployeeID từ csv
                                            var empIds = csv.split(",").map(id => id.trim()).filter(Boolean);

                                            // Tìm object employee tương ứng từ global `employees`
                                            var selectedEmployees = empIds.map(id => {
                                                var emp = (employees || []).find(e => String(e.EmployeeID) === String(id));
                                                return emp || { EmployeeID: id, FullName: id }; // fallback nếu không tìm thấy
                                            });

                                            // Render từng avatar với quyền & lazy-load (giới hạn theo maxVisible)
                                            const maxVisibleChips = Math.max(1, parseInt(3) || 3); // maxVisible = 3
                                            const visibleEmps = selectedEmployees.slice(0, maxVisibleChips);
                                            const remainingCount = selectedEmployees.length - maxVisibleChips;

                                            var avatarHtml = visibleEmps.map(emp =>
                                                renderEmployeeAvatarOrChip(emp, {
                                                    showAvatar: true,  // ← quan trọng: bật avatar
                                                    size: "small",
                                                    className: "emp-selected-chip"
                                                })
                                            ).join("");

                                            // Thêm badge +N nếu có còn lại
                                            if (remainingCount > 0) {
                                                const allNames = selectedEmployees.map(e => e.FullName + (e.EmployeeID ? ` (${e.EmployeeID})` : "")).join(", ");
                                                avatarHtml += `<div class="icon-more" title="${escapeHtml(allNames)}" style="display:inline-flex; align-items:center; justify-content:center; min-width:32px; height:32px; padding:0 8px; border-radius:50%; background:var(--task-primary); color:white; font-weight:700; font-size:12px;">+${remainingCount}</div>`;
                                            }

                                            // Cập nhật vào DOM
                                            $(`#${assigneeContainerId} .assignee-icons`).html(avatarHtml);

                                            // Kích hoạt lazy-load cho các avatar mới (nếu có)
                                            setTimeout(() => {
                                                const newAvatars = document.querySelectorAll(`#${assigneeContainerId} .customer-avatar-employee`);
                                                if (typeof callImg_EmployeeSelector === "function") {
                                                    callImg_EmployeeSelector(newAvatars);
                                                }
                                            }, 0);
                                        },
                                        error: function() {
                                            uiManager.showAlert({ type: "error", message: "Cập nhật người phụ trách thất bại!" });
                                        }
                                    });
                                }
                            });
                        } catch(e) {
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
                // Tìm task từ tất cả các nguồn
                let task = findTaskById(taskID);
                if (!task) {
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

                // Set priority value for later initialization
                currentTaskPriority = task.Priority || task.AssignPriority || 3;

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
                }

                var mdl = new bootstrap.Modal(document.getElementById("mdlTaskDetail"));
                mdl.show();

                // Hiện vùng upload file trong modal chi tiết
                try { $("#uploadArea").show(); } catch(e) {}

                setTimeout(function() {
                    try {
                        document.getElementById("mdlTaskDetail").focus();
                    } catch(e) {
                    }

                    // USE hpaControlDatebox
                    if ($("#detailStartDate").length > 0) {
                    }
                    if ($("#detailDueDate").length > 0) {
                    }

                    if ($("#detailPriority").length > 0) {
                        hpaControlField("#detailPriority", {
                            options: [
                                {value: 3, text: "Thấp"},
                                {value: 2, text: "Trung bình"},
                                {value: 1, text: "Cao"}
                            ],
                            selected: currentTaskPriority,
                            tableName: "tblAssignHistory",
                            columnName: "AssignPriority",
                            idColumnName: "HistoryID",
                            idValue: taskID,
                            onChange: function(value, text) {
                            }
                        });
                    }

                    if ($("#detailStatusSelect").length > 0) {
                        hpaControlField("#detailStatusSelect", {
                            options: [
                                {value: 3, text: "Hoàn thành"},
                                {value: 2, text: "Đang làm"},
                                {value: 1, text: "Chưa làm"}
                            ],
                            selected: currentStatus,
                            searchable: false,
                            silent: true,
                            onChange: function(value, text) {
                                try {
                                    var newStatus = parseInt(value, 10);
                                    if (!isNaN(newStatus)) updateTaskStatus(newStatus);
                                } catch (e) { console.warn("updateTaskStatus failed", e); }
                            }
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
                            loadTasks();
                        }
                    },
                    error: function(err) {
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
                        uiManager.showAlert({ type: "error",  message: "Cập nhật trạng thái thất bại!", });
                    }
                });
            }
            function openAssignModal() {
                if (tasks && tasks.length > 0) {
                    // Đã có → render luôn
                    initAssignModal();
                } else {
                    // Chưa có → gọi API nạp tasks
                    AjaxHPAParadise({
                        data: { name: "sp_Task_GetAssignmentSetup", param: ["ParentTaskID", 0] },
                        success: function(res) {
                            try {
                                var data = JSON.parse(res).data;
                                tasks = data[0] || []; // <-- Table 0 vì SP chỉ trả 1 bảng
                            } catch (e) {
                                tasks = [];
                            }
                            initAssignModal();
                        },
                        error: function() {
                            tasks = [];
                            initAssignModal();
                        }
                    });
                }
            }
            function initAssignModal() {
                currentTemplate = [];
                currentChildTasks = [];
                $("#subtask-assign-container").html(`<div class="empty-state" style="grid-column: 1 / -1;"><i class="bi bi-inbox"></i><p>Vui lòng chọn Công việc chính ở trên</p></div>`);

                renderAssignDropdowns();

                // Khởi tạo employee selectors
                var defaultEmp = (window.EmployeeID_Login || LoginID);
                hpaControlEmployeeSelector("#assignedBySelector", {
                    type: "employee",
                    selectedIds: [defaultEmp],
                    ajaxListName: "EmployeeListAll_DataSetting_Custom",
                    showAvatar: true,
                    multi: false,
                    onChange: (ids) => { $("#selAssignedBy").val(ids[0]); }
                });
                hpaControlEmployeeSelector("#mainUserSelector", {
                    type: "employee",
                    selectedIds: [defaultEmp],
                    ajaxListName: "EmployeeListAll_DataSetting_Custom",
                    showAvatar: true,
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
                var defaultEmp = (window.EmployeeID_Login || LoginID);
                const taskOptions = (tasks || []).map(t => ({ value: t.TaskID, text: t.TaskName }));
                const empOptions = (employees || []).map(e => ({ value: e.EmployeeID, text: e.FullName }));

                try {
                    hpaControlField("#parentTaskCombobox", {
                        searchable: true,
                        placeholder: "Chọn Công việc chính...",
                        useApi: true,
                        take: 20,
                        searchMode: "local",
                        ajaxListName: "sp_Task_GetListForParent",
                        
                        tableName: "tblTask",
                        columnName: "TaskName",
                        idColumnName: "TaskID",
                        idValue: currentTaskID,
                        
                        onChange: function(value, text) {
                            loadAssignTemplate();
                        }
                    });
                } catch(e) {
                    console.warn("[renderAssignDropdowns] Error initializing parent task combobox", e);
                }

                // Người yêu cầu - already initialized in initAssignModal
                // just ensure selector is ready
                setTimeout(() => {
                    if (!$("#assignedBySelector").find(".hpa-selector").length) {
                        hpaControlEmployeeSelector("#assignedBySelector", {
                            type: "employee",
                            selectedIds: [defaultEmp],
                            ajaxListName: "EmployeeListAll_DataSetting_Custom",
                            showAvatar: true,
                            multi: false,
                            onChange: () => {}
                        });
                    }
                }, 50);

                // Người chịu trách nhiệm - already initialized in initAssignModal
                setTimeout(() => {
                    if (!$("#mainUserSelector").find(".hpa-selector").length) {
                        hpaControlEmployeeSelector("#mainUserSelector", {
                            type: "employee",
                            selectedIds: [defaultEmp],
                            ajaxListName: "EmployeeListAll_DataSetting_Custom",
                            showAvatar: true,
                            multi: false,
                            onChange: () => {}
                        });
                    }
                }, 50);

                // 5. Đặt ngày mặc định là hôm nay
                const today = new Date().toISOString().split("T")[0];
                $("#dDate").val(today);

                console.log("[renderAssignDropdowns] Dropdowns initialized");
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
                        } catch(e) {
                        }
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
                        } catch(e) {
                            cb([]);
                        }
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
                q = normalizeForSearch(q || "");
                var pid = $("#selParent").val();
                var candidates = (allTasks || []).filter(function(t){
                    if(!t || !t.TaskName) return false;
                    if(String(t.TaskID) === String(pid)) return false; // skip self
                    if(t.ParentTaskID && Number(t.ParentTaskID) !== 0) return false; // skip those already children
                    if(t.Status === 5) return false; // skip disabled
                    if(t.PositionID && String(t.PositionID).trim() !== "") return false; // skip fixed tasks

                    return !q || normalizeForSearch(t.TaskName).indexOf(q) !== -1;
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
                        showAvatar: true,
                        ajaxListName: "EmployeeListAll_DataSetting_Custom",
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
                    uiManager.showAlert({ type: "danger", message: "Lỗi khi chuẩn bị dữ liệu giao việc" });
                }
            }
            function filterSelectOptions(selectId, text) {
                var q = normalizeForSearch(text || "");
                var $sel = $("#" + selectId);
                $sel.find("option").each(function(){
                    var txt = normalizeForSearch($(this).text() || "");
                    if(!q || txt.indexOf(q) !== -1) $(this).show(); else $(this).hide();
                });
            }
            function filterMultiOptions(idx, text) {
                try {
                    // Validate idx
                    if(idx === undefined || idx === null || idx === "" || !Number.isInteger(Number(idx))) {
                        return;
                    }

                    var q = normalizeForSearch(text || "");
                    var $dropdown = $(`#stUserDropdown-${idx}`);

                    if($dropdown.length === 0) {
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
                if (!$wrap.length || !$hidden.length) return;

                $wrap.html("");
                var selectedEmpIds = $hidden.val() || [];
          var empObjects = selectedEmpIds.map(empId => {
                    var emp = (employees || []).find(e => String(e.EmployeeID) === String(empId));
                    if (emp) {
                      return emp;
                    } else {
                        // fallback: tạo object tối thiểu để render icon-chip
                        return { EmployeeID: empId, FullName: empId };
                    }
                });

                // DÙNG HÀM CHUNG → ĐẢM BẢO NHẤT QUÁN
                var chips = empObjects.map(emp => {
                    return renderEmployeeAvatarOrChip(emp, {
                        showAvatar: true, // vì đây là khu vực chọn nhân viên → thường muốn thấy avatar
                        size: "small",
                        className: ""
                    });
                });

                $wrap.html(chips.join(""));

                try {
                    var used = Math.min(empObjects.length, 4);
                    var base = 110;
                    var dynamic = 8 + used * 20;
                    $input.css("padding-right", Math.max(base, dynamic + 60) + "px");
                } catch(e) {}

                if (empObjects.length > 0) {
                    var fullNames = empObjects.map(e => e.FullName || e.EmployeeID).join(", ");
                    $input.addClass("search-valid").removeClass("search-invalid").attr("title", fullNames);
                } else {
                    $input.removeClass("search-valid").val("").attr("title", "").css("padding-right", "110px");
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
                    return;
                }

                // Kiểm tra currentTaskID (parent task)
                if (!currentTaskID) {
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
                                        uiManager.showAlert({
                                        type: "error",
                                        message: "Không thể lưu thứ tự subtask: " + data.ErrorMessage
                                    });
                                }
                            }
                        } catch(e) {
                        }
                    },
                    error: function(err) {
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

            // Linh xử lý các control
            var DEFAULT_AVATAR_SVG_Employee = `
                <svg class="avatar" viewBox="0 0 200 200" xmlns="http://www.w3.org/2000/svg" role="img" aria-label="Default user avatar">
                    <rect width="200" height="200" fill="#ebf6ff"/>
                    <circle cx="100" cy="235" r="100" fill="#a4c3f5" stroke="#7192c7" stroke-width="6"/>
                    <circle cx="100" cy="76" r="43" fill="#fde69a" stroke="#e0b958" stroke-width="6"/>
                </svg>
            `;
            function renderEmployeeAvatarOrChip(employee, options = {}) {
                if (!employee) return `<div class="icon-chip">?</div>`;

                const empId = String(employee.EmployeeID || "");
                const fullName = employee.FullName || empId;
                const showAvatar = options.showAvatar !== false; // mặc định true
                const isChipOnly = options.isChipOnly === true;
                const className = options.className || "";
                const size = options.size || "medium"; // "small" | "medium"

                // CSS tùy theo kích thước
                const styleMap = {
                    small: "width:28px;height:28px;margin-left:-8px;border:2px solid white;box-shadow:0 1px 0 rgba(0,0,0,0.04);",
                    medium: "width:32px;height:32px;"
                };
                const baseStyle = "border-radius:50%; object-fit:cover; flex-shrink:0;";
                const finalStyle = (styleMap[size] || styleMap.medium) + baseStyle;

                if (!showAvatar || isChipOnly) {
                    const initials = getInitials(fullName) || (empId.charAt(0) || "?").toUpperCase();
                    return `<div class="icon-chip ${className}" title="${escapeHtml(fullName)}">${escapeHtml(initials)}</div>`;
                }

                // Nếu có đủ dữ liệu avatar → render <img>
                if (employee.storeImgName && employee.paramImg) {
                    return `
                        <img alt="${escapeHtml(fullName)}"
                            class="profile-img customer-avatar-employee ${className}"
                            _name="${employee.storeImgName}"
                            _param="${employee.paramImg}"
                            data-employee-id="${empId}"
                            loading="lazy"
                            style="${finalStyle}"
                        />
                    `;
                }

                // Thiếu dữ liệu → render avatar default (không lazy-load)
                return `
                    <img alt="${escapeHtml(fullName)}"
                        class="profile-img customer-avatar-employee ${className}"
                        src="data:image/svg+xml;base64,${btoa(DEFAULT_AVATAR_SVG_Employee)}"
                        data-employee-id="${empId}"
                        style="${finalStyle}"
                    />
                `;
            }
            function callImg_EmployeeSelector(a) {
                if (window.pendingImageRequests) {
                    window.pendingImageRequests.forEach(xhr => {
                        if (xhr && xhr.abort) xhr.abort();
                    });
                }
                window.pendingImageRequests = [];
                let observer = new IntersectionObserver((entries) => {
                    entries.forEach(entry => {
                        if (entry.isIntersecting) {
               let img = entry.target;
                            observer.unobserve(img);
                            loadSingleImage_Employee(img);
                        }
                    });
                }, {
                    rootMargin: "200px"
                });
                for (let i = 0; i < a.length; i++) {
                    let img = a[i];
                    if (!img.hasAttribute("data-loaded")) {
                        img.src = "data:image/svg+xml;base64," + btoa(DEFAULT_AVATAR_SVG_Employee);
                    }
                    observer.observe(img);
                }
            }

            // Thêm biến toàn cục để cache URL đã tạo
            window.employeeAvatarCache = window.employeeAvatarCache || {};
            function loadSingleImage_Employee(imgElement) {
                let self = $(imgElement);
                let employeeId = self.attr("data-employee-id");
                if (!employeeId) return;

                // ƯU TIÊN 1: Nếu đã có trong cache → dùng luôn
                if (window.employeeAvatarCache[employeeId]) {
                    if (self.attr("src") !== window.employeeAvatarCache[employeeId]) {
                        self.attr("src", window.employeeAvatarCache[employeeId]);
                    }
                    avatarLoadStatus[employeeId] = "loaded";
                    return;
                }

                // ƯU TIÊN 2: Nếu đã loaded hoặc đang loading → bỏ qua
                if (avatarLoadStatus[employeeId] === "loading" || avatarLoadStatus[employeeId] === "loaded") {
                    return;
                }

                let name = self.attr("_name");
                if (!name || name.length === 0 || name === "null" || name === "undefined") {
                    avatarLoadStatus[employeeId] = "failed";
                    return;
                }

                avatarLoadStatus[employeeId] = "loading";

                let paramStr = self.attr("_param") || "{}";
                let param;
                try {
                    param = JSON.parse(decodeURIComponent(paramStr));
                } catch(e) {
                    try { param = JSON.parse(paramStr); } catch(e2) {
                        avatarLoadStatus[employeeId] = "failed";
                        return;
                    }
                }

                let success = function (blob, status, xhr) {
                    avatarLoadStatus[employeeId] = "loaded";

                    if (blob && blob.size > 0) {
                        try {
                            var url = URL.createObjectURL(blob);
                            // LƯU VÀO CACHE TOÀN CỤC
                            window.employeeAvatarCache[employeeId] = url;

                            // Gán cho ảnh hiện tại
                            self.attr("src", url);

                            // QUAN TRỌNG: Gán luôn cho tất cả các img khác của cùng employeeId đang chờ
                            $(`.customer-avatar-employee[data-employee-id="${employeeId}"]`).each(function() {
                                if (this !== imgElement && !this.src.includes("blob:")) {
                                    this.src = url;
                                }
                            });

                            // Optional: dọn dẹp sau 5 phút để tránh memory leak (tùy chọn)
                            setTimeout(() => {
                                if (window.employeeAvatarCache[employeeId] === url) {
                                    URL.revokeObjectURL(url);
                                    delete window.employeeAvatarCache[employeeId];
                                }
                            }, 5 * 60 * 1000);

                        } catch(e) {
                            avatarLoadStatus[employeeId] = "failed";
                        }
                    } else {
                        avatarLoadStatus[employeeId] = "failed";
                    }
                };

                let error = function(xhr, status, error) {
                    avatarLoadStatus[employeeId] = "failed";
                };

                AjaxHPAParadise({
                    data: { name: name, param: param },
                    xhrFields: { responseType: "blob" },
                    cache: true,
                    success: success,
                    error: error
               });
            }

            // Linh: Hàm control chọn nhân viên (đơn hoặc đa chọn)
            function hpaControlEmployeeSelector(el, config) {
                setTimeout(() => {
                    const imgs = document.querySelectorAll(".customer-avatar-employee");
                    if (typeof callImg_EmployeeSelector === "function") {
                      callImg_EmployeeSelector(imgs);
                    }
                }, 100);
                const $el = $(el);
                const defaults = {
                    type: "employeesMulti",  // employeeMulti | employee
                    displayId: null,         //
                    selectedIds: [],
                    multi: true,
                    ajaxListName: null,      // sp load dữ liệu
                    silent: true,            // thông báo
                    placeholder: "Tìm...",
                    position: "right",
                    maxVisible: 3,
                    onChange: null,
                    showAvatar: false,
                    showId: true,
                    showName: true,
                    autoSave: false,
                    ajaxSaveName: null
                };
                const cfg = { ...defaults, ...config };
                // normalize selectedIds to strings for consistent comparisons
                cfg.selectedIds = (cfg.selectedIds || []).map(x => String(x));
                // MẢNG TẠM để lưu selectedIds khi load và xử lý trong mảng tạm
                let tempSelectedIds = [...cfg.selectedIds];
                const displayId = cfg.displayId || cfg.recordId || null;

                function selIdsToCsv(arr) {
                    return (arr || []).map(x => String(x)).filter(Boolean).join(",");
                }

                if ((!employees || employees.length === 0) && cfg.ajaxListName) {
                    AjaxHPAParadise({
                        data: { name: cfg.ajaxListName, param: ["LanguageID", cfg.language || "VN"] },
                        success: function(res) {
                            try {
                                const data = JSON.parse(res).data || [];
                                employees = data[0] || [];
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

                    // GỌI HÀM CHUNG ĐỂ ĐẢM BẢO NHẤT QUÁN
                    let avatarHtml = renderEmployeeAvatarOrChip(e, {
                        showAvatar: cfg.showAvatar,
                        size: "medium",
                        className: ""
                    });

                    // BG highlight khi selected
                    const bgStyle = isSelected ? "background-color: #e3f2fd; border-left: 3px solid var(--task-primary);" : "";

                    return `
                        <div class="control-row-assignee-item ${isSelected ? "selected" : ""}"
                            data-empid="${empId}"
                       data-empname="${escapeHtml(fullName)}"
                            style="padding:8px 10px; cursor:pointer; display:flex; align-items:center; gap:8px; border-bottom:1px solid #f0f2f5; ${bgStyle}">
                            ${cfg.multi ? `<div style="width:28px; flex-shrink:0;"><input type="checkbox" class="row-assignee-checkbox" ${isSelected ? "checked" : ""} style="cursor:pointer;" /></div>` : `<div style="width:28px; flex-shrink:0;"></div>`}
                            ${avatarHtml}
                            ${labelHtml ? `<div style="flex:1; min-width:0; font-weight:600; font-size:14px;">${labelHtml}</div>` : ""}
                        </div>
                    `;
                }

                function renderSelectedChips(selectedIds) {
                    if (!selectedIds || selectedIds.length === 0) {
                        return `<div class="icon-chip" title="Chưa chọn" style="display:inline-flex; align-items:center; justify-content:center; width:32px; height:32px; border-radius:50%; background:#f0f2f5; color:#676879; font-weight:700; font-size:14px;">?</div>`;
                    }

                    // Đảm bảo maxVisible là số dương
                    const maxVisible = Math.max(1, parseInt(cfg.maxVisible) || 3);

                    const empMap = {};
                    (employees || []).forEach(e => { empMap[String(e.EmployeeID)] = e; });

                    // Lấy chỉ maxVisible items đầu tiên để render chip
                    const visibleIds = selectedIds.slice(0, maxVisible);
                    const remaining = selectedIds.length - maxVisible;

                    const chips = visibleIds.map(empId => {
                        const e = empMap[empId];
                        return renderEmployeeAvatarOrChip(e, {
                            showAvatar: cfg.showAvatar,
                            size: "small",
                            className: "emp-selected-chip"
                        });
                    });

                    let visible = chips.join("");

                    // Nếu có còn lại, thêm badge +N
                    if (remaining > 0) {
                        const allNames = selectedIds.map(id => {
                            const e = empMap[id];
                            return (cfg.showName && e?.FullName ? e.FullName : "") +
                                (cfg.showId && e?.EmployeeID ? ` (${e.EmployeeID})` : "") ||
                                id;
                        }).join(", ");
                        // Chip hiển thị +N với style badge
                        visible += `<div class="icon-more" title="${escapeHtml(allNames)}" style="display:inline-flex; align-items:center; justify-content:center; min-width:32px; height:32px; padding:0 8px; border-radius:50%; background:var(--task-primary); color:white; font-weight:700; font-size:12px;">+${remaining}</div>`;
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
                        const selectedItems = [];
                        const unselectedItems = [];

                        (employees || []).forEach(e => {
                            const label = `${e.FullName || ""} (${e.EmployeeID || ""})`;
                            if (!q || normalizeForSearch(label).indexOf(q) !== -1) {
                                const empIdStr = String(e.EmployeeID);
                                // SỬ DỤNG mảng tạm tempSelectedIds để kiểm tra trạng thái
                                const isSelected = (tempSelectedIds || []).includes(empIdStr);
                                const itemHtml = renderEmployeeItem(e, isSelected);
                                if (isSelected) {
                                    selectedItems.push(itemHtml);
                                } else {
                                    unselectedItems.push(itemHtml);
                                }
                            }
                        });

                        // Sắp xếp: selected lên đầu, unselected phía sau
                        const items = [...selectedItems, ...unselectedItems];
                        $el.find(".row-assignee-list").html(items.length ? items.join("") : `<div style="padding:8px 12px;color:#777;">Không tìm thấy</div>`);

                        // Trigger lazy-load cho avatars trong dropdown
                        setTimeout(() => {
                            const imgs = $el.find(".row-assignee-list .customer-avatar-employee");
                            if (imgs.length && typeof callImg_EmployeeSelector === "function") {
                                callImg_EmployeeSelector(imgs);
                            }
                        }, 0);
                    };

                    // Gọi renderList lần đầu để populate danh sách khi khởi tạo
                    renderList("");

                    // Xử lý click nút toggle để mở/đóng dropdown và render list
                    $el.find(".row-assignee-toggle").on("click", function(e) {
                        e.preventDefault();
                        e.stopPropagation();
                        const $dropdown = $el.find(".row-assignee-dropdown");
                        const isVisible = $dropdown.is(":visible");

                        if (!isVisible) {
                            // Mở dropdown: render list lại để đảm bảo checkbox đúng trạng thái
                            renderList($el.find(".row-assignee-search").val() || "");
                            $dropdown.show();
                            $el.find(".row-assignee-search").focus();
                        } else {
                            // Đóng dropdown
                            $dropdown.hide();
                        }
                    });

                    $el.find(".row-assignee-search").on("input", (e) => renderList($(e.target).val()));

                    $el.on("click", ".control-row-assignee-item", (e) => {
                        e.stopPropagation();
                        const $it = $(e.currentTarget);
                        const empId = String($it.data("empid"));
                        const isCheckboxClick = $(e.target).hasClass("row-assignee-checkbox") || $(e.target).closest(".row-assignee-checkbox").length > 0;

                        // Lưu trạng thái cũ để rollback nếu cần
                        const prevSelected = [...tempSelectedIds];
                        let newSelected = [...tempSelectedIds];

                        if (cfg.multi) {
                            const idx = newSelected.indexOf(empId);
                            if (idx === -1) {
                                // Thêm mới: đưa lên đầu để ảnh hiển thị đầu tiên
                                newSelected = [empId, ...newSelected];
                            } else {
                                // Bỏ chọn: xóa khỏi mảng
                                newSelected.splice(idx, 1);
                            }
                        } else {
                            newSelected = newSelected.includes(empId) ? [] : [empId];
                            $el.find(".row-assignee-dropdown").hide();
                        }

                        // CẬP NHẬT mảy tạm tempSelectedIds
                        tempSelectedIds = newSelected.map(x => String(x));
                        cfg.selectedIds = [...tempSelectedIds];

                        // Render lại danh sách: selected lên đầu, checkbox đánh dấu đúng
                        const currentFilter = $el.find(".row-assignee-search").val() || "";
                        renderList(currentFilter);

                        // Cập nhật chip hiển thị với số lượng tăng dần
                        $el.find(".assignee-icons").html(renderSelectedChips(tempSelectedIds));

                        // Lazy load ảnh trong chips
                        try {
                            const imgs = $el.find(".assignee-icons .customer-avatar-employee");
                            if (imgs.length && typeof callImg_EmployeeSelector === "function") callImg_EmployeeSelector(imgs);
                        } catch (err) {
                        }

                        // Gọi onChange callback
                        if (typeof cfg.onChange === "function") cfg.onChange(tempSelectedIds, displayId);

                        // Optional auto-save
                        if (cfg.autoSave && cfg.ajaxSaveName) {
                            const csv = selIdsToCsv(tempSelectedIds);
                            AjaxHPAParadise({
                                data: { name: cfg.ajaxSaveName, param: [displayId, csv] },
                                success: function(res) {
                                    // Success - mảy tạm đã được lưu
                                },
                                error: function() {
                                    // Rollback: khôi phục mảy tạm về trạng thái cũ
                                    tempSelectedIds = prevSelected;
                                    cfg.selectedIds = [...tempSelectedIds];
                                    renderList(currentFilter);
                                    $el.find(".assignee-icons").html(renderSelectedChips(tempSelectedIds));
                                    if (!cfg.silent) alert("Lưu người được giao thất bại.");
                                }
                            });
                        }
                    });

                    // Xử lý click ra ngoài control để tắt dropdown
                    $(document).on("click.assignee-dropdown-" + displayId, (e) => {
                        const $target = $(e.target);
                        // Nếu click không phải trên control này → đóng dropdown
                        if (!$el.find(".row-assignee").is(e.target) &&
                            !$el.find(".row-assignee").has(e.target).length &&
                            !$target.closest($el.find(".row-assignee")).length) {
                            $el.find(".row-assignee-dropdown").hide();
                        }
                    });

                    // Cleanup event khi destroy
                    $el.data("destroy", () => {
                        $(document).off("click.assignee-dropdown-" + displayId);
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
                                    <div class="emp-sel-icons">
                                        ${renderSelectedChips(cfg.selectedIds)}
                                    </div>
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

                        // Thêm dòng này: Kích hoạt lazy load cho các avatar mới trong dropdown
                        setTimeout(() => {
                            const newImgs = $type.find(".emp-sel-list .customer-avatar-employee");
                            if (newImgs.length && typeof callImg_EmployeeSelector === "function") {
                                callImg_EmployeeSelector(newImgs);
                            }
                        }, 0);
                    };

                    $type.find(".emp-sel-trigger").on("click", (e) => {
                        e.stopPropagation();
                        $(".emp-sel-dropdown").not($type.find(".emp-sel-dropdown")).hide();
                        $type.find(".emp-sel-dropdown").toggle();
                        renderList("");
                        $type.find(".emp-sel-search").focus();
                    });

                    $type.find(".emp-sel-search").on("input", (e) => renderList($(e.target).val()));

                    $type.on("click", ".control-row-assignee-item, .row-assignee-checkbox", function(e) {
                        e.stopPropagation();

                        const $item = $(this).closest(".control-row-assignee-item");
                        const empId = String($item.data("empid"));
                        const isCheckboxClick = e.target.type === "checkbox";

                        // Nếu là single select và click vào item đã chọn → không làm gì cả (tránh gọi onChange vô ích)
                        if (!cfg.multi && $item.hasClass("selected") && !isCheckboxClick) {
                            $type.find(".emp-sel-dropdown").hide();
                            return;
                        }

                        let newSelected = [...cfg.selectedIds];
                        const currentlySelected = newSelected.includes(empId);

                        if (cfg.multi) {
                            if (currentlySelected) {
                                newSelected = newSelected.filter(id => id !== empId);
                            } else {
                                newSelected.push(empId);
                            }
                        } else {
                            newSelected = currentlySelected ? [] : [empId]; // toggle hoặc chọn mới
                        }

                        // Cập nhật UI
                        $type.find(".control-row-assignee-item").removeClass("selected").find(".row-assignee-checkbox").prop("checked", false);
                        // ensure order: put newly selected at front
                        if (cfg.multi) {
                            // keep newSelected order as-is (already managed above)
                        } else {
                            // single: newSelected contains only the chosen id
                        }
                        newSelected.forEach(id => {
                            $type.find(`.control-row-assignee-item[data-empid="${id}"]`)
                                .addClass("selected")
                                .find(".row-assignee-checkbox").prop("checked", true);
                        });

                        // Cập nhật chip hiển thị
                        $type.find(".emp-sel-icons").html(renderSelectedChips(newSelected));
                        // lazy-load avatars inside the display
                        try {
                            const newImgs = $type.find(".emp-sel-icons .customer-avatar-employee");
                            if (newImgs.length && typeof callImg_EmployeeSelector === "function") callImg_EmployeeSelector(newImgs);
                        } catch (err) {
                        }

                        // GỌI onChange DUY NHẤT 1 LẦN
                        if (typeof cfg.onChange === "function") {
                            cfg.onChange(newSelected, displayId);
                        }

                        // Đóng dropdown nếu là single select
                        if (!cfg.multi) {
                            $type.find(".emp-sel-dropdown").hide();
                        }
                    });

                    $(document).on("click.emp-sel-" + uniqueId, (e) => {
                        if (!$(e.target).closest($type).length) {
                            const $dropdown = $type.find(".emp-sel-dropdown");
                            if ($dropdown.is(":visible")) {
                                $dropdown.hide();
                            }
                       }
                    });

                    $type.data("destroy", () => {
                        $(document).off("click.emp-sel-" + uniqueId);
                    });

                    return $type;
                }
            }
            
        })();
    </script>
    ';
    SELECT @html AS html;
    --EXEC sp_GenerateHTMLScript 'sp_Task_MyWork_html'
END
GO

EXEC sp_GenerateHTMLScript 'sp_Task_MyWork_html'
