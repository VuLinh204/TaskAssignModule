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
    <div id="TaskGrid"></div>
    <script>
        let TaskGrid;
        let TaskGridInstance;
        let TaskGridDataSource = [];
        let TaskGridKey;

        function loadUI_TaskGrid() {
            const $container = $("#TaskGrid");
            const fieldId = "TaskGrid";
            
            // Khởi tạo DataSource rỗng
            TaskGridDataSource = [];
            
            // Khởi tạo DevExtreme DataGrid
            TaskGridInstance = $("<div>").appendTo($container).dxDataGrid({
                dataSource: TaskGridDataSource,
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
                        const visibleRows = e.component.getVisibleRows();
                        const toIndex = e.toIndex;
                        const fromIndex = visibleRows.findIndex(row => row.data.TaskID === e.itemData.TaskID);
                        
                        const tasksCopy = TaskGridDataSource.slice();
                        const movedTask = tasksCopy.splice(fromIndex, 1)[0];
                        tasksCopy.splice(toIndex, 0, movedTask);
                        
                        TaskGridDataSource = tasksCopy;
                        e.component.option("dataSource", TaskGridDataSource);
                        
                        // Save order to server
                        saveTaskOrder(e.itemData, toIndex);
                    }
                },
                
                // ===== TOOLBAR =====
                toolbar: {
                    items: [
                        { 
                            location: "before", 
                            template: () => $("<div>").css({ 
                                fontWeight: "600", 
                                fontSize: "14px", 
                                color: "var(--text-secondary)" 
                            }).text("Danh sách công việc")
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
                paging: { enabled: true, pageSize: 50 },
                pager: { 
                    visible: true, 
                    allowedPageSizes: [10, 20, 50, 100], 
                    showPageSizeSelector: true, 
                    showInfo: true, 
                    showNavigationButtons: true 
                },
                
                // ===== GROUPING =====
                grouping: { autoExpandAll: true, contextMenuEnabled: true },
                groupPanel: { visible: true, emptyPanelText: "Kéo cột vào đây để nhóm theo tiêu chí" },
                
                // ===== FILTERING =====
                filterRow: { visible: false, applyFilter: "auto" },
                searchPanel: { visible: true, width: 240, placeholder: "Tìm kiếm công việc..." },
                headerFilter: { visible: true },
                
                // ===== COLUMN CHOOSER =====
                columnChooser: { enabled: true, mode: "select", title: "Chọn cột hiển thị" },
                
                // ===== EXPORT =====
                export: { enabled: true, fileName: "CongViecCuaToi", allowExportSelectedData: true },
                
                // ===== STATE STORING =====
                stateStoring: { enabled: true, type: "localStorage", storageKey: "taskGridState" },
                
                // ===== SORTING & SCROLLING =====
                sorting: { mode: "multiple" },
                scrolling: { mode: "virtual", rowRenderingMode: "virtual", showScrollbar: "onHover" },
                columnFixing: { enabled: true },
                
                // ===== COLUMNS =====
                columns: [
                    // Drag Handle
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
                        cellTemplate: (container) => {
                            $("<i>").addClass("bi bi-grip-vertical drag-handle")
                                .attr("title", "Kéo để sắp xếp")
                                .appendTo(container);
                        }
                    },
                    
                    // Task ID
                    {
                        dataField: "TaskID",
                        caption: "ID",
                        width: 80,
                        alignment: "center",
                        allowEditing: false,
                        sortOrder: "desc"
                    },
                    
                    // Group ID
                    {
                        dataField: "GroupID",
                        caption: "Nhóm",
                        width: 120,
                        alignment: "center",
                        allowGrouping: true,
                        cellTemplate: (container, options) => {
                            const groupId = options.value;
                            if (groupId === null || groupId === undefined) {
                                $("<span>").css("color", "var(--text-muted)").text("-").appendTo(container);
                            } else {
                                $("<span>").text("#" + groupId).appendTo(container);
                            }
                        }
                    },
                    
                    // Parent Task ID
                    {
                        dataField: "ParentTaskID",
                        caption: "Task cha",
                        width: 100,
                        alignment: "center",
                        cellTemplate: (container, options) => {
                            const parentId = options.value;
                            if (parentId === null || parentId === undefined) {
                                $("<span>").css({ color: "var(--success-color)", fontWeight: "600" })
                                    .text("Parent").appendTo(container);
                            } else {
                                $("<span>").css({ color: "var(--text-secondary)" })
                                    .text("Child").appendTo(container);
                            }
                        }
                    },
                    
                    // Task Name - INLINE EDIT
                    {
                        dataField: "TaskName",
                        caption: "Tên công việc",
                        minWidth: 250,
                        cellTemplate: (container, options) => {
                            const task = options.data;
                            const taskID = task.TaskID;
                            const containerId = "TaskNameDiv_" + taskID;
                            
                            const $wrapper = $("<div>")
                                .attr("id", containerId)
                                .data("record", task)
                                .css({ width: "100%", minHeight: "40px", cursor: "pointer" });
                            
                            // Display div
                            const $displayDiv = $("<div>").addClass("task-name-cell");
                            $("<div>").addClass("task-name-title").text(task.TaskName).appendTo($displayDiv);
                            const $meta = $("<div>").addClass("task-name-meta");
                            
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
                            
                            // Click handler
                            $wrapper.on("click", function(e) {
                                e.stopPropagation();
                                $displayDiv.hide();
                                
                                if (!$wrapper.find(".dx-textbox").length) {
                                    const $controlContainer = $("<div>").css({ width: "100%" });
                                    $wrapper.append($controlContainer);
                                    
                                    const textBoxInstance = $controlContainer.dxTextBox({
                                        value: task.TaskName,
                                        width: "100%",
                                        inputAttr: { 
                                            class: "form-control form-control-sm", 
                                            style: "font-size: 14px;" 
                                        },
                                        onFocusIn: (e) => {
                                            const originalValue = textBoxInstance.option("value");
                                            $(e.element).find("input").css("border", "1px solid #1c975e");
                                            
                                            showActionPopup($wrapper, "TaskName_" + taskID,
                                                async () => {
                                                    const newVal = textBoxInstance.option("value");
                                                    if (newVal !== originalValue) {
                                                        try {
                                                            await saveFunction(
                                                                JSON.stringify([-99218308, ["TaskName"], [newVal]]), 
                                                                [[taskID], "TaskID"]
                                                            );
                                                            task.TaskName = newVal;
                                                            $displayDiv.find(".task-name-title").text(newVal);
                                                            uiManager.showAlert({ type: "success", message: "Lưu thành công" });
                                                        } catch (err) {
                                                            uiManager.showAlert({ type: "error", message: "Có lỗi xảy ra khi lưu" });
                                                        }
                                                    }
                                                    $controlContainer.hide();
                                                    $displayDiv.show();
                                                },
                                                () => {
                                                    textBoxInstance.option("value", originalValue);
                                                    $controlContainer.hide();
                                                    $displayDiv.show();
                                                }
                                            );
                                        },
                                        onFocusOut: (e) => { 
                                            $(e.element).find("input").css("border", ""); 
                                        },
                                        onKeyDown: (e) => {
                                            if (e.event.key === "Enter") { 
                                                e.event.preventDefault();
                                                $(e.element).find("input").blur();
                                            }
                                            if (e.event.key === "Escape") { 
                                                e.event.preventDefault();
                                                if (actionPopupInstance) actionPopupInstance.hide();
                                                $controlContainer.hide();
                                                $displayDiv.show();
                                            }
                                        }
                                    }).dxTextBox("instance");
                                    
                                    setTimeout(() => textBoxInstance.focus(), 100);
                                } else {
                                    $wrapper.find(".dx-textbox").parent().show();
                                    const instance = $wrapper.find(".dx-textbox").dxTextBox("instance");
                                    if (instance) instance.focus();
                                }
                            });
                            
                            container.append($wrapper);
                        }
                    },
                    
                    // Assign Priority - INLINE EDIT
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
                        cellTemplate: (container, options) => {
                            const task = options.data;
                            const taskID = task.TaskID;
                            const containerId = "AssignPriorityDiv_" + taskID;
                            
                            const $wrapper = $("<div>")
                                .attr("id", containerId)
                                .data("record", task)
                                .css({ width: "100%", cursor: "pointer" });
                            
                            let priority = options.value || 3;
                            const prioClass = "prio-" + priority;
                            const $icon = $("<i>")
                                .addClass("bi bi-flag-fill priority-icon " + prioClass)
                                .attr("title", priority === 1 ? "Cao" : priority === 2 ? "Trung bình" : "Thấp");
                            
                            $wrapper.append($icon);
                            
                            $wrapper.on("click", function(e) {
                                e.stopPropagation();
                                
                                if ($wrapper.find(".dx-selectbox").length) return;
                                
                                $icon.hide();
                                const $controlContainer = $("<div>").css({ width: "100%" });
                                $wrapper.append($controlContainer);
                                
                                const priorityDataSource = [
                                    { ID: 1, Name: "Cao", Text: "Cao" },
                                    { ID: 2, Name: "Trung bình", Text: "Trung bình" },
                                    { ID: 3, Name: "Thấp", Text: "Thấp" }
                                ];
                                
                                $controlContainer.dxSelectBox({
                                    dataSource: priorityDataSource,
                                    valueExpr: "ID",
                                    displayExpr: "Name",
                                    value: priority,
                                    searchEnabled: false,
                                    showClearButton: false,
                                    stylingMode: "outlined",
                                    width: "100%",
                                    onValueChanged: async (e) => {
                                        if (e.value !== priority) {
                                            try {
                                                await saveFunction(
                                                    JSON.stringify([-99218308, ["AssignPriority"], [e.value]]), 
                                                    [[taskID], "TaskID"]
                                                );
                                                task.AssignPriority = e.value;
                                                priority = e.value;
                                                const newClass = "prio-" + e.value;
                                                $icon.removeClass("prio-1 prio-2 prio-3").addClass(newClass);
                                                $icon.attr("title", e.value === 1 ? "Cao" : e.value === 2 ? "Trung bình" : "Thấp");
                                                uiManager.showAlert({ type: "success", message: "Lưu thành công" });
                                            } catch (err) {
                                                uiManager.showAlert({ type: "error", message: "Có lỗi xảy ra khi lưu" });
                                            }
                                        }
                                        $controlContainer.remove();
                                        $icon.show();
                                    },
                                    onInitialized: (e) => {
                                        setTimeout(() => e.component.open(), 100);
                                    }
                                });
                            });
                            
                            container.append($wrapper);
                        }
                    },
                    
                    // Progress
                    {
                        dataField: "ProgressPct",
                        caption: "Tiến độ",
                        width: 200,
                        alignment: "left",
                        sortOrder: "desc",
                        cellTemplate: (container, options) => {
                            const task = options.data;
                            const progress = options.value || 0;
                            let displayText = "";
                            
                            if (task.TargetKPI > 0) {
                                displayText = (task.ActualKPI || 0) + "/" + task.TargetKPI;
                            } else if (task.TotalSubtasks > 0) {
                                displayText = (task.CompletedSubtasks || 0) + "/" + task.TotalSubtasks;
                            }
                            
                            const div = $("<div>").addClass("progress-cell");
                            if (displayText) {
                                $("<div>").addClass("progress-info").text(displayText).appendTo(div);
                            }
                            const barContainer = $("<div>").addClass("progress-bar-container");
                            $("<div>").addClass("progress-bar-fill")
                                .css("width", Math.min(progress, 100) + "%")
                                .appendTo(barContainer);
                            barContainer.appendTo(div);
                            $("<div>").addClass("progress-text").text(progress + "%").appendTo(div);
                            
                            container.append(div);
                        }
                    },
                    
                    // Status Code - INLINE EDIT
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
                        cellTemplate: (container, options) => {
                            const task = options.data;
                            const taskID = task.TaskID;
                            const containerId = "StatusDiv_" + taskID;
                            
                            const $wrapper = $("<div>")
                                .attr("id", containerId)
                                .data("record", task)
                                .css({ width: "100%", cursor: "pointer" });
                            
                            let status = options.value || 1;
                            const statusClass = "sts-" + status;
                            const statusText = status === 1 ? "Chưa làm" : status === 2 ? "Đang làm" : "Hoàn thành";
                            
                            const $badge = $("<span>")
                                .addClass("badge-sts " + statusClass)
                                .text(statusText);
                            
                            $wrapper.append($badge);
                            
                            $wrapper.on("click", function(e) {
                                e.stopPropagation();
                                
                                if ($wrapper.find(".dx-selectbox").length) return;
                                
                                $badge.hide();
                                const $controlContainer = $("<div>").css({ width: "100%" });
                                $wrapper.append($controlContainer);
                                
                                const statusDataSource = [
                                    { ID: 1, Name: "Chưa làm", Text: "Chưa làm" },
                                    { ID: 2, Name: "Đang làm", Text: "Đang làm" },
                                    { ID: 3, Name: "Hoàn thành", Text: "Hoàn thành" }
                                ];
                                
                                $controlContainer.dxSelectBox({
                                    dataSource: statusDataSource,
                                    valueExpr: "ID",
                                    displayExpr: "Name",
                                    value: status,
                                    searchEnabled: false,
                                    showClearButton: false,
                                    stylingMode: "outlined",
                                    width: "100%",
                                    onValueChanged: async (e) => {
                                        if (e.value !== status) {
                                            try {
                                                await saveFunction(
                                                    JSON.stringify([-99218308, ["StatusCode"], [e.value]]), 
                                                    [[taskID], "TaskID"]
                                                );
                                                task.StatusCode = e.value;
                                                status = e.value;
                                                const newClass = "sts-" + e.value;
                                                const newText = e.value === 1 ? "Chưa làm" : e.value === 2 ? "Đang làm" : "Hoàn thành";
                                                $badge.removeClass("sts-1 sts-2 sts-3").addClass(newClass).text(newText);
                                                uiManager.showAlert({ type: "success", message: "Lưu thành công" });
                                                
                                                // Reload data if needed
                                                if (typeof loadTasks === "function") loadTasks();
                                            } catch (err) {
                                                uiManager.showAlert({ type: "error", message: "Có lỗi xảy ra khi lưu" });
                                            }
                                        }
                                        $controlContainer.remove();
                                        $badge.show();
                                    },
                                    onInitialized: (e) => {
                                        setTimeout(() => e.component.open(), 100);
                                    }
                                });
                            });
                            
                            container.append($wrapper);
                        }
                    },
                    
                    // Due Date
                    {
                        dataField: "DueDate",
                        caption: "Hạn hoàn thành",
                        width: 140,
                        dataType: "date",
                        format: "dd/MM/yyyy",
                        alignment: "center",
                        cellTemplate: (container, options) => {
                            const task = options.data;
                            const dateStr = formatSimpleDate(options.value);
                            const dateDiv = $("<div>").addClass("date-cell");
                            if (task.IsOverdue === 1) {
                                dateDiv.addClass("overdue");
                                $("<i>").addClass("bi bi-exclamation-triangle-fill").appendTo(dateDiv);
                            }
                            $("<span>").text(dateStr || "-").appendTo(dateDiv);
                            container.append(dateDiv);
                        }
                    },
                    
                    // Actions
                    {
                        caption: "Thao tác",
                        width: 120,
                        alignment: "center",
                        allowExporting: false,
                        allowSorting: false,
                        allowFiltering: false,
                        allowGrouping: false,
                        cellTemplate: (container, options) => {
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
                    totalItems: [
                        { column: "TaskID", summaryType: "count", displayFormat: "Tổng: {0} công việc" },
                        { column: "ProgressPct", summaryType: "avg", valueFormat: "fixedPoint", precision: 1, displayFormat: "TB: {0}%" }
                    ],
                    groupItems: [
                        { column: "TaskID", summaryType: "count", displayFormat: "{0} việc" },
                        { column: "ProgressPct", summaryType: "avg", valueFormat: "fixedPoint", precision: 1, displayFormat: "TB: {0}%" }
                    ]
                },
                
                // ===== MASTER DETAIL =====
                masterDetail: { enabled: false },
                
                // ===== EVENT HANDLERS =====
                onRowPrepared: (e) => {
                    if (e.rowType === "data") {
                        if (e.data.IsOverdue === 1) {
                            e.rowElement.css("background-color", "rgba(229, 57, 53, 0.03)");
                        }
                        if (e.data.StatusCode === 3) {
                            e.rowElement.css("opacity", "0.7");
                        }
                    }
                },
                
                onContextMenuPreparing: (e) => {
                    if (e.row && e.row.rowType === "data") {
                        e.items = [
                            { text: "Xem chi tiết", icon: "info", onItemClick: () => openTaskDetail(e.row.data.TaskID) },
                            { text: "Chỉnh sửa", icon: "edit", onItemClick: () => console.log("Edit task:", e.row.data.TaskID) },
                            { beginGroup: true },
                            { text: "Đánh dấu hoàn thành", icon: "check", disabled: e.row.data.StatusCode === 3, onItemClick: () => updateTaskStatus(e.row.data.TaskID, 3) },
                            { text: "Đánh dấu đang làm", icon: "runner", disabled: e.row.data.StatusCode === 2, onItemClick: () => updateTaskStatus(e.row.data.TaskID, 2) },
                            { beginGroup: true },
                            { text: "Xóa", icon: "trash", onItemClick: () => { if (confirm("Bạn có chắc chắn muốn xóa công việc này?")) deleteTask(e.row.data.TaskID); } }
                        ];
                    }
                },
                
                onRowClick: (e) => {
                    if (e.rowType === "data" && e.column && e.column.type !== "drag" && e.column.caption !== "Thao tác") {
                        const hasSubtasks = e.data.HasSubtasks || (e.data.TotalSubtasks && e.data.TotalSubtasks > 0);
                        if (hasSubtasks) {
                            e.component.isRowExpanded(e.key) ? e.component.collapseRow(e.key) : e.component.expandRow(e.key);
                        }
                    }
                },
                
                onRowDblClick: (e) => {
                    if (e.rowType === "data") openTaskDetail(e.data.TaskID);
                },
                
                onToolbarPreparing: (e) => {
                    e.toolbarOptions.items.unshift({
                        location: "after",
                        widget: "dxButton",
                        options: {
                            icon: "refresh",
                            hint: "Tải lại dữ liệu",
                            onClick: () => { if (typeof loadTasks === "function") loadTasks(); }
                        }
                    });
                }
            }).dxDataGrid("instance");// ===== HELPER FUNCTIONS (cần có trong scope) =====
            
            // Return control interface
            return {
                setValue: (val) => {
                    TaskGridDataSource = val || [];
                    if (TaskGridInstance) {
                        TaskGridInstance.option("dataSource", TaskGridDataSource);
                        TaskGridInstance.refresh();
                    }
                },
                getValue: () => TaskGridDataSource,
                getInstance: () => TaskGridInstance
            };
        }

        function formatSimpleDate(dateString) {
            if(!dateString) return "";
            const d = new Date(dateString);
            if (isNaN(d.getTime())) return "";
            const day = ("0" + d.getDate()).slice(-2);
            const month = ("0" + (d.getMonth() + 1)).slice(-2);
            const year = d.getFullYear();
            return day + "/" + month + "/" + year;
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
                success: (res) => {
                    console.log("Task order saved successfully");
                    uiManager.showAlert({ type: "success", message: "Đã lưu thứ tự mới" });
                },
                error: (error) => {
                    console.error("Error saving task order:", error);
                    uiManager.showAlert({ type: "error", message: "Không thể lưu thứ tự" });
                }
            });
        }

        // 1. Khởi tạo Grid Control
        function loadUI() {
            TaskGrid = loadUI_TaskGrid();
        }

        // 2. Load data và gán vào Grid
        function loadData() {
            AjaxHPAParadise({
                data: { 
                    name: "sp_Task_GetMyTasks", 
                    param: ["LoginID", LoginID] 
                },
                success: (response) => {
                    try {
                        const res = JSON.parse(response);
                        const results = res.data[0] || [];
                        
                        // Set data vào Grid
                        TaskGrid.setValue(results);
                        
                        // Lấy TaskID đầu tiên làm key
                        if (results.length > 0) {
                            TaskGridKey = { TaskID: results[0].TaskID };
                        }
                        
                        console.log("Loaded", results.length, "tasks");
                    } catch(e) {
                        console.error("Error loading tasks:", e);
                        uiManager.showAlert({ 
                            type: "error", 
                            message: "Lỗi khi tải dữ liệu công việc" 
                        });
                    }
                },
                error: (error) => {
                    console.error("Ajax error:", error);
                    uiManager.showAlert({ 
                        type: "error", 
                        message: "Không thể kết nối đến server" 
                    });
                }
            });
        }

        // 3. Khởi động
        loadUI();
        loadData();
    </script>
';
    SELECT @html AS html;
END
GO

EXEC sp_GenerateHTMLScript 'sp_Task_MyWork_html'