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
            border-radius: 12px;
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
            border-radius: 12px;
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
            border-radius: 8px;
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
        /* Kanban Board */
        #sp_Task_MyWork_html .kanban-board {
            display: grid;
            grid-template-columns: repeat(3, 1fr);
            gap: 20px;
        }
        #sp_Task_MyWork_html .kanban-column {
            border-radius: 12px;
            padding: 16px;
            min-height: 500px;
            border: 1px solid var(--border-color);
            box-shadow: var(--shadow-sm);
        }
        #sp_Task_MyWork_html .kanban-board .cu-row {
            margin-bottom: 12px;
            border-radius: 8px;
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
            border-radius: 12px;
            font-size: 12px;
            font-weight: 700;
            color: var(--text-secondary);
            min-width: 28px;
            text-align: center;
        }
        /* Task Row (List + Card) */
        #sp_Task_MyWork_html .cu-list {
            border: 1px solid var(--border-color);
            border-radius: 12px;
            box-shadow: var(--shadow-sm);
        }
        #sp_Task_MyWork_html .cu-row {
            display: flex;
            align-items: center;
            justify-content: space-between;
            padding: 8px 20px;
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

        /* Drag handle position adjustment */
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
            font-weight: 600;
            width: 100%;
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
            border-radius: 8px;
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
            border-radius: 6px;
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
        
        

        /* Priority Field Wrapper */
        #sp_Task_MyWork_html .priority-field-wrapper {
            min-width: 200px;
        }

        #sp_Task_MyWork_html .priority-field-wrapper .hpa-field-display {
            border-radius: 8px;
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
            border-radius: 12px;
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
            border-radius: 8px;
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

        /* Priority Select - Không bị block */
        #sp_Task_MyWork_html .st-priority {
            position: relative;
            z-index: 10;
            pointer-events: auto;
        }

        /* Subtask Table in Detail Modal */
        #sp_Task_MyWork_html .subtask-table {
            width: 100%;
            border-collapse: collapse;
            margin-top: 16px;
            background: var(--bg-white);
            border: 1px solid var(--border-color);
            border-radius: 8px;
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
            border-radius: 6px;
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
            box-shadow: 0 10px 40px rgb(151 151 151 / 15%)
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
            overflow-x: auto;
            -webkit-overflow-scrolling: touch;
            padding: 8px 0;
        }

        #sp_Task_MyWork_html .subtask-container.show {
            display: block;
            animation: slideDown 0.3s ease;
        }

        /* Subtask container as table-like rows */
        #sp_Task_MyWork_html .subtask-container .subtask-row {
            display: grid;
            grid-template-columns: 40px 1fr 260px 110px 160px minmax(220px, 520px);
            gap: 12px;
            align-items: center;
            padding: 8px 12px;
            border-bottom: 1px solid var(--bg-lighter);
            background: var(--bg-white);
        }

        @media (max-width: 768px) {
            #sp_Task_MyWork_html .subtask-container .subtask-row {
                grid-template-columns: 40px 1fr 120px;
                grid-auto-rows: auto;
            }
        }

        /* Timeline strip */
        .timeline-strip { position: relative; height: 56px; display: flex; align-items: center; }
        .timeline-bar { position: absolute; left: 6px; right: 6px; height: 8px; background: var(--bg-lighter); border-radius: 6px; }
        .timeline-marker { position: absolute; transform: translateX(-50%); display: flex; flex-direction: column; align-items: center; font-size: 11px; }
        .timeline-marker .dot { width: 12px; height: 12px; border-radius: 50%; background: var(--task-primary); border: 2px solid #fff; box-shadow: 0 1px 3px rgba(0,0,0,0.08); }
        .timeline-marker .label { margin-top: 6px; white-space: nowrap; max-width: 120px; overflow: hidden; text-overflow: ellipsis; color: var(--text-secondary); }

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

        /* Detail icon shown on row hover */
        #sp_Task_MyWork_html .cu-row { position: relative; }
        #sp_Task_MyWork_html .cu-row .detail-icon {
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
        #sp_Task_MyWork_html .cu-row:hover .detail-icon { display: block; opacity: 1; transform: translateY(-2px); }
        #sp_Task_MyWork_html .cu-row .detail-icon i { font-size: 14px; }
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
        <!-- Task detail moved to separate form `sp_Task_TaskDetail_html` -->
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
            var currentChildTasks = []; // cached child tasks for selected ParentTaskID
            var expandedHeadersState = {};
            var attachmentMode = ""; // "file"
            var currentTaskID = null;
            var globalCacheStorage = {
                allTasksLoaded: false,
                selectBoxState: {}, // {elementId: {value, text, dirty}}
                selectBoxOptions: {} // {optionKey: [...options]} - cache options từ config
            };

            window.toggleHeaderExpand = toggleHeaderExpand;

            $(document).ready(function() {
                attachUIHandlers();
                loadTasks();
            });

            function attachUIHandlers() {
                // Cache jQuery selectors
                const $btnAssign = $("#btnAssign");
                const $btnRefresh = $("#btnRefresh");
                const $btnAddParentOpen = $("#btnAddParentOpen");
                const $btnQuickAddSubtask = $("#btnQuickAddSubtask");
                const $btnReloadChecklist = $("#btnReloadChecklist");
                const $btnSubmitAssignment = $("#btnSubmitAssignment");
                const $doc = $(document);

                // Static buttons
                $btnAssign.on("click", openAssignModal);
                $btnRefresh.on("click", loadTasks);
                // detail KPI update handled in sp_Task_TaskDetail_html
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

                $doc.on("click", ".btn-temp-remove", function() {
                    $(this).closest(".temp-subtask").remove();
                });

                // Create parent modal button may be appended dynamically
                $doc.on("click", "#btnCreateParent", function() {
                    createParentFromModal();
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
                $(document).on("click", ".st-priority", function(e) {
                    e.stopPropagation();
                });
                $("#viewListT, #viewKanbanT").on("click", function() {
                    updateView($(this).attr("id") === "viewListT" ? "list" : "kanban");
                });

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

            function normalizeForSearch(str) {
                if (!str) return "";
                return String(str)
                    .toLowerCase()
                    .normalize("NFD")
                    .replace(/[\u0300-\u036f]/g, "")
                    .trim();
            }
            function loadTasks() {
                // Nếu đã tải → dùng cache, không gọi lại
                if (globalCacheStorage.allTasksLoaded && allTasks.length > 0) {
                    updateStatistics();
                    updateView("list");
                    return;
                }

                function getImageCacheKey(employee) {
                    try {
                        var store = employee.storeImgName || "";
                        var param = employee.paramImg || "";
                        return store + "|" + param;
                    } catch (e) { return (employee.storeImgName || "") + "|" + (employee.paramImg || ""); }
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

                            // Mark cache as loaded
                            globalCacheStorage.allTasksLoaded = true;

                            updateStatistics();
                            updateView("list");
                        } catch(e) {
                        }
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

            // Build timeline HTML from normalized entries (each {dt: Date, label: string})
            function buildTimelineHtml(entries) {
                if (!entries || entries.length === 0) return `<div class="text-muted">Không có lịch</div>`;
                // normalize to { start: Date, end: Date, label }
                var norm = (entries||[]).map(function(e){
                    if (!e) return null;
                    if (e.start && e.end) return { start: new Date(e.start), end: new Date(e.end), label: e.label||e.EmployeeName||e.label||"" };
                    if (e.dt) return { start: new Date(e.dt), end: new Date(e.dt), label: e.label||"" };
                    if (typeof e === "string" || typeof e === "number") { var d=new Date(e); return { start:d, end:d, label: "" }; }
                    return null;
                }).filter(Boolean);

                if (norm.length === 0) return `<div class="text-muted">Không có lịch</div>`;

                // compute global range
                var minStart = norm.reduce((min,e)=> e.start < min ? e.start : min, norm[0].start);
                var maxEnd = norm.reduce((max,e)=> e.end > max ? e.end : max, norm[0].end);
                var rangeMs = Math.max(1, maxEnd - minStart);

                // Build a simple table: Assignee | Start | End | Duration | Visual
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

                    // visual bar: compute left and width percent relative to global range
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

            // Populate timeline DOM for a single task (called after list HTML is rendered)
            function populateTimelineForTask(t) {
                try {
                    console.log("[populateTimelineForTask] start", t && t.TaskID, t);
                    var timelineContainerId = `timeline-container-${t.TaskID}`;
                    var $el = $(`#${timelineContainerId}`);
                    if (!$el.length) return;

                    // Build entries from possible shapes
                    var raw = t.Schedule || t.AssignHistory || t.ScheduleEntries || t.Timeline || [];
                    try {
                        if (typeof raw === "string" && raw.trim() !== "") {
                            try { raw = JSON.parse(raw); } catch(e) {
                                raw = raw.split(/[,;|]/).map(s=>({ Date: s.trim(), Label: "" }));
                            }
                        }
                    } catch(e) { raw = []; }
                    if (!Array.isArray(raw)) raw = [raw];
                    console.log("[populateTimelineForTask] raw after-parse", raw);

                    var entries = [];
                    raw.forEach(function(e){
                        if (!e) return;
                        if (typeof e === "string" || typeof e === "number") { entries.push({ dt: new Date(e), label: ""}); return; }
                        var d = e.ScheduleDate || e.AssignDate || e.Date || e.StartDate || e.DateTime || e.ActionDate || e.MyStartDate || e.DueDate || e.DateString || e.DateTimeString || e.Date || null;
                        if (!d && e.date) d = e.date;
                        var label = e.EmployeeName || e.FullName || e.UserName || e.Label || e.Description || e.Action || e.Note || e.Title || "";
                        if (d) entries.push({ dt: new Date(d), label: label });
                    });

                    if (entries.length === 0) {
                        if (t.MyStartDate) entries.push({ dt: new Date(t.MyStartDate), label: "Start" });
                        if (t.DueDate) entries.push({ dt: new Date(t.DueDate), label: "Due" });
                    }

                    console.log("[populateTimelineForTask] normalized entries", entries);
                    $el.html(buildTimelineHtml(entries));
                } catch(e) {}
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

                // Populate timelines for rendered tasks after DOM insertion
                try {
                    (data || []).forEach(function(t){
                        try { populateTimelineForTask(t); } catch(e) {}
                    });
                } catch(e) {}

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
            function initRowPriorityControls(context) {
                var $root = context ? $(context) : $(document);
                $root.find(".row-priority-select, .row-priority-field").each(function () {
                    const $el = $(this);
                    const historyId = $el.attr("data-historyid");
                    console.log("[initRowPriorityControls] init for historyId=", historyId);
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
                            searchable: false,
                            tableName: "tblTask_AssignHistory",
                            columnName: "AssignPriority",
                            idColumnName: "HistoryID",
                            idValue: historyId,
                            silent: true,
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
                            <strong>${progressPct}%</strong>
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
                        <div class="row-priority-select" data-recordid="${t.TaskID}" data-historyid="${t.HistoryID}" style="width:110px;">
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
                                selectedIds: currentIds,
                                ajaxListName: "EmployeeListAll_DataSetting_Custom",
                                showAvatar: true,
                                multi: true,
                                tableName: "tblTask_AssignHistory",
                                columnName: "EmployeeID",
                                idColumnName: "HistoryID",
                                idValue: t.HistoryID,
                                onChange: function(selectedIds) {
                                    // Handle change
                                }
                            });
                        } catch(e) {
                        }
                    }, 100);

                    // status for subtask
                    var stClass = t.StatusCode == 2 ? "sts-2" : t.StatusCode == 3 ? "sts-3" : "sts-1";
                    var statusLabel = t.StatusLabel || (t.StatusCode == 1 ? "Chưa làm" : (t.StatusCode == 2 ? "Đang làm" : "Hoàn thành"));
                    var statusHtml = `<div id="status-control-${t.TaskID}" class="task-status-control" data-taskid="${t.TaskID}"></div>`;

                    // initialize status control after render
                    setTimeout(function() {
                        try {
                            if ($(`#status-control-${t.TaskID}`).length === 0) return;
                            hpaControlField(`#status-control-${t.TaskID}`, {
                                type: "select",
                                options: [
                                    { value: 1, text: "Chưa làm" },
                                    { value: 2, text: "Đang làm" },
                                    { value: 3, text: "Hoàn thành" }
                                ],
                                selected: Number(t.StatusCode) || 1,
                                width: 140,
                                silent: true,
                                onChange: function(newVal) {
                                    var newStatus = Number(newVal);
                                    if (newStatus === Number(t.StatusCode)) return;
                                    // optimistic UI update
                                    $(`#status-control-${t.TaskID} .hpa-control-display`).text(newStatus===1?"Chưa làm":newStatus===2?"Đang làm":"Hoàn thành");
                                    AjaxHPAParadise({
                                        data: {
                                            name: "sp_Task_UpdateStatus",
                                            param: [
                                                "TaskID", t.TaskID,
                                                "LoginID", LoginID,
                                                "NewStatus", newStatus
                                            ]
                                        },
                                        success: function() { setTimeout(loadTasks, 300); },
                                        error: function() { uiManager.showAlert({ type: "error", message: "Cập nhật trạng thái thất bại!" }); }
                                    });
                                }
                            });
                        } catch (e) {}
                    }, 120);

                    // Timeline container for subtask
                    var timelineContainerId = `timeline-container-${t.TaskID}`;

                    // Initialize timeline for subtask after render (simple fallback)
                    setTimeout(function(){
                        try {
                            var entries = [];
                            if (t.MyStartDate) entries.push({ date: t.MyStartDate, label: "Start" });
                            if (t.DueDate) entries.push({ date: t.DueDate, label: "Due" });
                            var html = "";
                            if (entries.length === 0) {
                                html = `<div class="text-muted">Không có lịch</div>`;
                            } else {
                                // compute visual range
                                var firstDt = entries[0].dt;
                                var lastDt = entries[entries.length-1].dt;
                                var rangeMs = Math.max(1, lastDt - firstDt);
                                var days = Math.max(1, Math.ceil(rangeMs / (24*3600*1000)));
                                var widthPx = Math.min(900, Math.max(260, days * 28));

                                html = `<div style="overflow:auto;">`;
                                html += `<div class="timeline-strip" style="width:${widthPx}px;margin:6px 8px;">`;
                                html += `<div class="timeline-bar"></div>`;

                                entries.forEach(function(en){
                                    var leftPercent = ((en.dt - firstDt) / rangeMs) * 100;
                                    var dd = ("0"+en.dt.getDate()).slice(-2) + "/" + ("0"+(en.dt.getMonth()+1)).slice(-2);
                                    var tt = ("0"+en.dt.getHours()).slice(-2) + ":" + ("0"+en.dt.getMinutes()).slice(-2);
                                    var safeLabel = escapeHtml(en.label || "");
                                    html += `<div class="timeline-marker" title="${safeLabel}" style="left:${leftPercent}%;">
                                                <div class="dot"></div>
                                                <div class="label">${dd} ${tt}</div>
                                             </div>`;
                                });

                                html += `</div></div>`;
                            }
                            $(`#${timelineContainerId}`).html(html);
                        } catch(e) {}
                    }, 120);

                    // Return simplified row HTML (with timeline)
                    return `
                    <div class="cu-row task-row draggable subtask-row" data-recordid="${t.TaskID}" data-historyid="${t.HistoryID}" draggable="true" style="padding-left:30px; display:flex;align-items:center;gap:12px;">
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
                        <div style="min-width:220px;max-width:520px;flex-shrink:0;">
                            <div id="${timelineContainerId}"></div>
                        </div>
                    </div>`;
                }

                var statusHtml = "";
                if (t.HasSubtasks) {
                    statusHtml = `<span class="badge-sts sts-2">Có con</span>`;
                } else {
                    var stClass = t.StatusCode == 2 ? "sts-2" : t.StatusCode == 3 ? "sts-3" : "sts-1";
                    var statusLabel = (t.StatusCode == 1 ? "Chưa làm" : (t.StatusCode == 2 ? "Đang làm" : "Hoàn thành"));
                    statusHtml = `<div id="status-control-${t.TaskID}" class="task-status-control" data-taskid="${t.TaskID}"></div>`;

                    // init status control for main task after render
                    setTimeout(function() {
                        try {
                            if ($(`#status-control-${t.TaskID}`).length === 0) return;
                            hpaControlField(`#status-control-${t.TaskID}`, {
                                type: "select",
                                options: [
                                    { value: 1, text: "Chưa làm" },
                                    { value: 2, text: "Đang làm" },
                                    { value: 3, text: "Hoàn thành" }
                                ],
                                selected: Number(t.StatusCode) || 1,
                                width: 140,
                                silent: true,
                                onChange: function(newVal) {
                                    var newStatus = Number(newVal);
                                    if (newStatus === Number(t.StatusCode)) return;
                                    $(`#status-control-${t.TaskID} .hpa-control-display`).text(newStatus===1?"Chưa làm":newStatus===2?"Đang làm":"Hoàn thành");
                                    AjaxHPAParadise({
                                        data: {
                                            name: "sp_Task_UpdateStatus",
                                            param: [
                                                "TaskID", t.TaskID,
                                                "LoginID", LoginID,
                                                "NewStatus", newStatus
                                            ]
                                        },
                                        success: function() { setTimeout(loadTasks, 300); },
                                        error: function() { uiManager.showAlert({ type: "error", message: "Cập nhật trạng thái thất bại!" }); }
                                    });
                                }
                            });
                        } catch(e) {}
                    }, 120);
                }

                // Build assignee container for main task
                var assigneeContainerId = `assignee-container-${t.TaskID}`;
                var prioSelect = `
                    <div class="row-priority-select" data-recordid="${t.TaskID}" style="width:110px;">
                    </div>`;

                // Timeline container id
                var timelineContainerId = `timeline-container-${t.TaskID}`;
                console.log("timelineContainerId", timelineContainerId);

                // Initialize assignee selector, priority and timeline after render
                setTimeout(function() {
                    try {
                        // Assignees
                        if ($(`#${assigneeContainerId}`).length) {
                            var currentIds = [];
                            if (t.AssignedToEmployeeIDs) {
                                currentIds = String(t.AssignedToEmployeeIDs).split(",").map(s=>s.trim()).filter(Boolean);
                            }
                            // fallback to single AssignedTo
                            if ((!currentIds || currentIds.length===0) && t.AssignedTo) {
                                currentIds = [String(t.AssignedTo)];
                            }
                            try{
                                hpaControlEmployeeSelector(`#${assigneeContainerId}`, {
                                    selectedIds: currentIds,
                                    ajaxListName: "EmployeeListAll_DataSetting_Custom",
                                    showAvatar: true,
                                    multi: true,
                                    silent: true,
                                    readOnly: true
                                });
                            }catch(e){}
                        }

                        // Priority init (if any control expects it)
                        if ($(`.row-priority-select[data-recordid="${t.TaskID}"]`).length) {
                            try { initRowPriorityControls($(`.row-priority-select[data-recordid="${t.TaskID}"]`)); } catch(e){}
                        }

                        // Timeline render
                        if ($(`#${timelineContainerId}`).length) {
                            try {
                                var rawEntries = t.Schedule || t.AssignHistory || t.ScheduleEntries || t.Timeline || [];
                                // Accept array, JSON string, or comma-separated dates
                                try {
                                    if (typeof rawEntries === "string" && rawEntries.trim() !== "") {
                                        try { rawEntries = JSON.parse(rawEntries); } catch (e) {
                                            var parts = rawEntries.split(/[,;|]/).map(s => s.trim()).filter(Boolean);
                                            rawEntries = parts.map(function(p){ return { Date: p, Label: "" }; });
                                        }
                                    }
                                } catch(e) { rawEntries = []; }

                                if (!Array.isArray(rawEntries)) rawEntries = [rawEntries];

                                var entries = [];
                                rawEntries.forEach(function(e){
                                    if (!e) return;
                                    // handle raw primitives
                                    if (typeof e === "string" || typeof e === "number") {
                                        entries.push({ date: e, label: "" });
                                        return;
                                    }
                                    var d = e.ScheduleDate || e.AssignDate || e.Date || e.StartDate || e.DateTime || e.ActionDate || e.MyStartDate || e.DueDate || e.DateString || e.DateTimeString || null;
                                    var label = e.EmployeeName || e.FullName || e.UserName || e.Label || e.Description || e.Action || e.Note || e.Title || "";
                                    if (d) entries.push({ date: d, label: label });
                                });

                                if (entries.length === 0) {
                                    if (t.MyStartDate) entries.push({ date: t.MyStartDate, label: "Start" });
                                    if (t.DueDate) entries.push({ date: t.DueDate, label: "Due" });
                                }
                                // normalize and sort
                                entries = entries.map(function(en){ var dt = new Date(en.date); return { dt: dt, label: en.label }; }).filter(en=>en.dt && !isNaN(en.dt.getTime()));
                                entries.sort(function(a,b){ return a.dt - b.dt; });

                                var html = "";
                                if (entries.length === 0) {
                                    html = `<div class="text-muted">Không có lịch</div>`;
                                } else {
                                    var firstDt = entries[0].dt;
                                    var lastDt = entries[entries.length-1].dt;
                                    var rangeMs = Math.max(1, lastDt - firstDt);
                                    var days = Math.max(1, Math.ceil(rangeMs / (24*3600*1000)));
                                    var widthPx = Math.min(900, Math.max(260, days * 28));

                                    html = `<div style="overflow:auto;">`;
                                    html += `<div class="timeline-strip" style="width:${widthPx}px;margin:6px 8px;">`;
                                    html += `<div class="timeline-bar"></div>`;

                                    entries.forEach(function(en){
                                        var leftPercent = ((en.dt - firstDt) / rangeMs) * 100;
                                        var dd = ("0"+en.dt.getDate()).slice(-2) + "/" + ("0"+(en.dt.getMonth()+1)).slice(-2);
                                        var tt = ("0"+en.dt.getHours()).slice(-2) + ":" + ("0"+en.dt.getMinutes()).slice(-2);
                                        var safeLabel = escapeHtml(en.label || "");
                                        html += `<div class="timeline-marker" title="${safeLabel}" style="left:${leftPercent}%;">
                                                    <div class="dot"></div>
                                                    <div class="label">${dd} ${tt}</div>
                                                 </div>`;
                                    });

                                    html += `</div></div>`;
                                }
                                $(`#${timelineContainerId}`).html(html);
                            } catch(e) {}
                        }
                    } catch(e) {}
                }, 140);

                return `
                <div class="cu-row task-row draggable"
                    style="${isChild ? "padding-left:30px;" : ""}"
                    data-recordid="${t.TaskID}"
                    draggable="true">
                    <div class="row-check" style="width:40px;flex-shrink:0;display:flex;align-items:center;gap:8px;">
                        <i class="bi bi-grip-vertical row-drag-handle"></i>
                    </div>

                    <!-- Name -->
                    <div class="col-name" style="flex:1;min-width:220px;display:flex;align-items:center;gap:12px;">
                        <div class="task-main" style="width:100%;">
                            <div class="task-title" title="${escapeHtml(t.TaskName)}">${t.TaskName}</div>
                            <div class="task-sub">
                                ${t.CommentCount > 0 ? `<span><i class="bi bi-chat-dots"></i> ${t.CommentCount}</span>` : ""}
                                <span class="text-muted">#${t.TaskID}</span>
                            </div>
                        </div>
                        <div class="detail-icon" data-recordid="${t.TaskID}" title="Xem chi tiết"><i class="bi bi-box-arrow-up-right"></i></div>
                    </div>

                    <!-- Assignees -->
                    <div class="col-assignees" style="width:260px;flex-shrink:0;">
                        <div id="${assigneeContainerId}" style="width:100%;"></div>
                    </div>

                    <!-- Priority -->
                    <div class="col-priority" style="width:110px;flex-shrink:0;display:flex;align-items:center;justify-content:center;">
                        <i class="bi bi-flag-fill priority-icon ${prioClass}"></i>
                        ${prioSelect}
                    </div>

                    <!-- Status -->
                    <div class="col-status" style="width:160px;flex-shrink:0;display:flex;align-items:center;justify-content:center;">
                        ${statusHtml}
                    </div>

                    <!-- Timeline -->
                    <div class="col-timeline" style="min-width:220px;max-width:520px;flex-shrink:0;">
                        <div id="${timelineContainerId}"></div>
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
                // Provide full task payload to the detail form before opening
                try {
                    window.sp_Task_TaskDetail_html = window.sp_Task_TaskDetail_html || {};
                    window.sp_Task_TaskDetail_html.TaskID = taskID;
                    window.sp_Task_TaskDetail_html.TaskData = task;
                    console.log("[openTaskDetail] passing TaskData to detail", task && task.TaskID, task);
                } catch (e) { /* ignore */ }

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
                            // When hidden parent select changes, hide subtasks if cleared
                            if($("#parentTaskCombobox .hpa-field-item.selected").val()) {
                                $("#subtask-assign-container").html(`<div class="empty-state" style="grid-column: 1 / -1;"><i class="bi bi-inbox"></i><p>Vui lòng chọn Công việc chính ở trên</p></div>`);
                            } else {
                                console.log("parentTaskCombobox cleared");
                            }
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

                // 5. Đặt ngày mặc định là hôm nay (use hpaControl datebox when available)
                const today = new Date().toISOString().split("T")[0];
                if (window.hpaControlDateBox && typeof window.hpaControlDateBox === "function") {
                    try { hpaControlDateBox("#dDate", { value: today }); } catch(e) { $("#dDate").val(today); }
                    try { hpaControlDateBox("#dDue", { value: "" }); } catch(e) { $("#dDue").val(""); }
                } else {
                    $("#dDate").val(today);
                }

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
            function removeQuickAdd() { 
                $("#quickAddWrapper").remove(); $("#quickSubtaskDropdown").remove(); 
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
                            <div id="assignee-${validIdx}" data-child-id="${item.ChildTaskID || 0}"></div>
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

                // ✅ Đợi DOM render xong (100-200ms)
                setTimeout(() => {
                    currentTemplate.forEach((item, idx) => {
                        // ✅ Parse selectedIds từ dữ liệu có sẵn
                        let preSelectedIds = [];
                        
                        // Kiểm tra nhiều trường có thể chứa EmployeeIDs
                        const idsSource = item.AssignedToEmployeeIDs || 
                                        item.EmployeeIDs || 
                                        item.AssignedTo || 
                                        "";
                        
                        if (idsSource) {
                            preSelectedIds = String(idsSource)
                                .split(",")
                                .map(s => s.trim())
                                .filter(Boolean);
                        }

                        // ✅ Log để debug
                        console.log(`[Subtask ${idx}] Pre-selected IDs:`, preSelectedIds);

                        hpaControlEmployeeSelector(`#assignee-${idx}`, {
                            selectedIds: preSelectedIds,  // ← Truyền đúng IDs
                            ajaxListName: "EmployeeListAll_DataSetting_Custom",
                            showAvatar: true,
                            multi: true,
                            onChange: function(selectedIds) {
                                // Lưu vào data attribute để lấy khi submit
                                $(`#assignee-${idx}`).data("selected", selectedIds);
                                console.log(`[Subtask ${idx}] Changed to:`, selectedIds);
                            }
                        });
                    });
                }, 200);  // ← Tăng timeout nếu cần
            }
            function submitAssignment() {
                let parent = $("#selParent").val();
                let mainUser = $("#selMainUser").val();
                let dDate = $("#dDate").val();
                let dDue = $("#dDue").val();
                console.log("[submitAssignment] parent:", parent, "mainUser:", mainUser, "dDate:", dDate, "dDue:", dDue);
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
                // Support both legacy .subtask-row-draggable and current .subtask-row
                var rows = document.querySelectorAll(".subtask-row-draggable, .subtask-row");

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

                            // Lưu thứ tự mới vào database (pass context for parent detection)
                            try { saveSubtaskOrder(this); } catch(ex) { console.warn("saveSubtaskOrder failed", ex); }
                        }

                        this.classList.remove("drag-over");
                        return false;
                    });
              });
            }
            function saveSubtaskOrder(context) {
                try {
                    console.log("[saveSubtaskOrder] start", context);

                    var $container = null;
                    try {
                        if (context && context.closest) {
                            $container = $(context).closest(".subtask-container");
                        }
                    } catch(e) {}

                    if ((!$container || $container.length === 0) ) {
                        $container = $(".subtask-container:visible").first();
                    }

                    if ((!$container || $container.length === 0) && currentTaskID) {
                        $container = $(`#subtasks-${currentTaskID}`);
                    }

                    if (!$container || $container.length === 0) {
                        console.warn("[saveSubtaskOrder] no subtask container found");
                        return;
                    }

                    // Derive parent id from container id (format: subtasks-<parentId> or subtasks-header-<id>)
                    var parentId = null;
                    try {
                        var idAttr = $container.attr("id") || "";
                        var m = idAttr.match(/subtasks-(\d+)$/);
                        if (m && m[1]) parentId = m[1];
                        // fallback: try numeric at end
                        if (!parentId) {
                            var mm = idAttr.match(/subtasks-.*?(\d+)/);
                            if (mm && mm[1]) parentId = mm[1];
                        }
                    } catch(e) {}

                    if (!parentId && currentTaskID) parentId = currentTaskID;
                    if (!parentId) {
                        console.warn("[saveSubtaskOrder] cannot determine parentId");
                        return;
                    }

                    // Collect ordered child IDs from rendered rows (support multiple possible classes/attrs)
                    var orderedIds = [];
                    $container.find(".subtask-row, .subtask-row-draggable, .cu-row.task-row").each(function() {
                        var childId = $(this).data("recordid") || $(this).data("childid") || $(this).data("taskid");
                        if (childId) orderedIds.push(childId);
                    });

                    if (orderedIds.length === 0) {
                        console.warn("[saveSubtaskOrder] no child rows found under container", $container.attr("id"));
                        return;
                    }

                    var orderedIdsCSV = orderedIds.join(",");
                    console.log("[saveSubtaskOrder] parentId", parentId, "ordered", orderedIdsCSV);

                    // Call API to save ordering
                    AjaxHPAParadise({
                        data: {
                            name: "sp_Common_SaveDataTable",
                            param: [
                                "LoginID", window.LoginID || 0,
                                "LanguageID", typeof LanguageID !== "undefined" ? LanguageID : "VN",
                                "TableName", "tblTask_AssignHistory",
                                "ColumnName", "SortOrder",
                                "IDColumnName", "HistoryID",
                                "ColumnValue", orderedIdsCSV,
                                "ID_Value", ""
                            ]
                        },
                        success: function(res) {
                            try {
                                var result = JSON.parse(res);
                                if (result.data && result.data[0] && result.data[0][0]) {
                                    var data = result.data[0][0];
                                    if (data.Success === 1) {
                                        uiManager.showAlert({ type: "success", message: "Đã lưu thứ tự subtask thành công!" });
                                    } else {
                                        uiManager.showAlert({ type: "error", message: "Không thể lưu thứ tự subtask: " + (data.ErrorMessage || "Unknown") });
                                    }
                                }
                            } catch(e) { console.warn("saveSubtaskOrder parse result error", e); }
                        },
                        error: function(err) {
                            uiManager.showAlert({ type: "error", message: "Không thể lưu thứ tự subtask do lỗi hệ thống." });
                        }
                    });
                } catch(e) { console.error("saveSubtaskOrder unexpected error", e); }
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

                            // Lưu thứ tự mới (only update the moved row)
                            try { saveListOrder(dragging); } catch(e) { console.warn("saveListOrder error", e); }
                        }

                        this.classList.remove("drag-over");
                        return false;
                    });
                });
            }
            function saveListOrder(movedRow) {
                var orderedIds = [];
                var orderedPairs = []; // HistoryID:position
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

                $(".cu-list .cu-row.draggable:not(.header-row)").each(function(index) {
                    var $row = $(this);
                    var taskId = $row.data("recordid") || $row.data("taskid") || $row.data("recordid");
                    var historyId = $row.attr("data-historyid");
                    // fallback: try to find any element inside with history id
                    if (!historyId) {
                        var $inner = $row.find("[data-historyid]");
                        if ($inner.length) historyId = $inner.first().data("historyid");
                    }
                    if (taskId) orderedIds.push(taskId);
                    if (historyId) orderedPairs.push(historyId + ":" + (index + 1));
                });
                if (orderedIds.length === 0) return;

                if (movedRow) {
                    var $m = $(movedRow);
                    var movedHistoryId = $m.attr("data-historyid");
                    if (!movedHistoryId) {
                        var $inner = $m.find("[data-historyid]");
                        if ($inner.length) movedHistoryId = $inner.first().data("historyid");
                    }
                    if (movedHistoryId) {
                        // determine new position index
                        var newIndex = $(".cu-list .cu-row.draggable:not(.header-row)").index(movedRow);
                        var newPos = (newIndex >= 0) ? (newIndex + 1) : 1;
                        console.log("[saveListOrder] updating single HistoryID", movedHistoryId, "->", newPos);
                        AjaxHPAParadise({
                            data: {
                                name: "sp_Common_SaveDataTable",
                                param: [
                                    "LoginID", LoginID,
                                    "LanguageID", typeof LanguageID !== "undefined" ? LanguageID : "VN",
                                    "TableName", "tblTask_AssignHistory",
                                    "ColumnName", "SortOrder",
                                    "IDColumnName", "HistoryID",
                                    "ColumnValue", newPos,
                                    "ID_Value", movedHistoryId
                                ]
                            },
                            success: function(res) {},
                            error: function() {}
                        });
                        return;
                    }
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
