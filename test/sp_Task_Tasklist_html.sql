USE Paradise_Beta_Tai2
GO

-- ========================================================================
-- CONTROL 1: SELECTBOX (Single Select with Add New)
-- ========================================================================

if object_id('[dbo].[sp_Task_Tasklist_html]') is null
	EXEC ('CREATE PROCEDURE [dbo].[sp_Task_Tasklist_html] as select 1')
GO

ALTER PROCEDURE [dbo].[sp_Task_Tasklist_html]
    @LoginID    INT = 3,
    @LanguageID VARCHAR(2) = 'VN',
    @isWeb      INT = 1
AS
BEGIN
SET NOCOUNT ON;
DECLARE @html NVARCHAR(MAX);
SET @html = N'
    
  
   
            let Instance46B6CAFE927642E1895AD4AC3AB63B26 = $("#Grid_View").dxDataGrid({
                dataSource: [],
                keyExpr: "TaskID",
                height: "100%",
                showBorders: true,
                showRowLines: true,
                rowAlternationEnabled: false,
                hoverStateEnabled: true,
                columnAutoWidth: true,
                allowColumnReordering: true,
                allowColumnResizing: true,
                columnResizingMode: "widget",
                wordWrapEnabled: false,

                scrolling: {
                    mode: "virtual",
                    rowRenderingMode: "virtual",
                    showScrollbar: "onHover"
                },

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

                selection: {
                    mode: "multiple",
                    showCheckBoxesMode: "onClick",
                    allowSelectAll: true
                },

                filterRow: {
                    visible: false
                },

                searchPanel: {
                    visible: true,
                    width: 240,
                    placeholder: "Tìm kiếm..."
                },

                headerFilter: {
                    visible: true
                },

                columnChooser: {
                    enabled: true,
                    mode: "select",
                    title: "Chọn cột hiển thị"
                },

                export: {
                    enabled: true,
                    allowExportSelectedData: true
                },

                stateStoring: {
                    enabled: true,
                    type: "localStorage",
                    storageKey: "gridState_Grid_View"
                },

                sorting: {
                    mode: "none"
                },

                grouping: {
                    autoExpandAll: false,
                    contextMenuEnabled: true
                },

                groupPanel: {
                    visible: true
                },

                columnFixing: {
                    enabled: true
                },

                rowDragging: {
                    allowReordering: true,
                    showDragIcons: true,
                    group: "TaskName",
                    cursor: "grabbing",

                    onReorder: async function(e) {
                        if (e.itemData.key !== undefined || e.itemData.items) {
                            e.component.refresh();
                            return;
                        }

                        const movedItem = e.itemData;
                        if (!movedItem || movedItem.TaskID === undefined) {
                            console.warn("movedItem invalid:", movedItem);
                            return;
                        }

                        const grid = e.component;
                        const visibleRows = grid.getVisibleRows();
                        const pkField = "TaskID";

                        const dataRowsAfterReorder = visibleRows
                            .filter(row => row.rowType === "data")
                            .map(row => row.data);

                        const updates = [];
                        let orderInGroup = 1;

                        for (const row of dataRowsAfterReorder) {
                            const newSortOrder = orderInGroup++;

                            if (row.SortOrder !== newSortOrder) {
                                updates.push({
                                    id: row[pkField],
                                    sortOrder: newSortOrder
                                });
                                row.SortOrder = newSortOrder;
                            }
                        }

                        if (updates.length === 0) {
                            grid.refresh();
                            return;
                        }

                        try {
                            const dataJSON = JSON.stringify([
                                "-1233093056",
                                ["SortOrder"],
                                updates.map(u => u.sortOrder)
                            ]);

                            const idValuesJSON = JSON.stringify([
                                updates.map(u => u.id),
                                pkField
                            ]);

                            const json = await saveFunction(dataJSON, idValuesJSON);

                            const dtError = json.data?.[json.data.length - 1] || [];
                            if (dtError.length > 0 && dtError[0].Status === "ERROR") {
                                uiManager.showAlert({ type: "error", message: dtError[0]?.Message || "Lưu thất bại" });
                                ReloadData();
                            } else {
                                uiManager.showAlert({ type: "success", message: `Đã cập nhật thứ tự (${updates.length} mục)` });
                                grid.refresh();
                            }
                        } catch (err) {
                            console.error("Save error:", err);
                            uiManager.showAlert({ type: "error", message: "Lỗi lưu thứ tự" });
                            ReloadData();
                        }
                    }
                },

                noDataText: "Không có dữ liệu",
                columns: [{
        dataField: "TaskName",
        caption: "Tên công việc",
        minWidth: 150,
        allowEditing: true,
        cellTemplate: function(cellElement, cellInfo) {
            const task = cellInfo.data;
            const taskID = task.TaskID;
            const containerId = "txt_TaskName_" + taskID;

            /* =============== Inline DOM =============== */
            const $wrapper = $("<div>")
                .attr("id", containerId)
                .css({ width: "100%", minHeight: "40px", cursor: "pointer" });

            const $displayDiv = $("<div>")
                .text(cellInfo.value || "")
                .css({ padding: "8px" });

            $wrapper.append($displayDiv);
            cellElement.append($wrapper);

            let textBoxInstance = null;
            let $controlContainer = null;
            let isEditing = false;
            let originalValue = cellInfo.value || "";

            /* =============== Popup SAVE/CANCEL =============== */
            let actionPopup_TaskName = null;
            let currentFieldId_TaskName = null;
            let saveCallback_TaskName = null;
            let cancelCallback_TaskName = null;

            function initActionPopup_TaskName() {
                if (actionPopup_TaskName) return;

                actionPopup_TaskName = $("<div>").appendTo("body").dxPopup({
                    width: "auto",
                    height: "auto",
                    showTitle: false,
                    visible: false,
                    shading: false,
                    animation: null,
                    showCloseButton: false,
                    dragEnabled: false,
                    position: { at: "bottom right", my: "top right", offset: "0 4" },

         }).dxPopup("instance");

                actionPopup_TaskName.option("contentTemplate", () => {
                    return $("<div class=\"d-flex\" style=\"gap: 6px; padding: 6px;\">").append(
                        $("<div>").dxButton({
                            icon: "check",
                            type: "success",
                            stylingMode: "contained",
                            width: 32, height: 32,
                            onClick: async () => {
                                if (saveCallback_TaskName) await saveCallback_TaskName();
                                actionPopup_TaskName.hide();
                            }
                        }),
                        $("<div>").dxButton({
                            icon: "close",
                            stylingMode: "outlined",
                            width: 32, height: 32,
                            onClick: () => {
                                if (cancelCallback_TaskName) cancelCallback_TaskName();
                                actionPopup_TaskName.hide();
                            }
                        })
                    );
                });
            }

            function showActionPopup_TaskName(inputElement, fieldId, onSave, onCancel) {
                initActionPopup_TaskName();

                if (currentFieldId_TaskName && currentFieldId_TaskName !== fieldId) {
                    if (cancelCallback_TaskName) cancelCallback_TaskName();
                }

                currentFieldId_TaskName = fieldId;
                saveCallback_TaskName = onSave;
                cancelCallback_TaskName = onCancel;

                const updatePosition = () => {
                    if (!actionPopup_TaskName?.option("visible")) return;
                    const $input = $(inputElement).find("input");
                    if ($input.length === 0) return;

                    actionPopup_TaskName.option({
                        position: {
                            my: "top right",
                            at: "bottom right",
                            of: $input,
                            offset: "0 4"
                        }
                    });
                };

                actionPopup_TaskName.show();
                setTimeout(updatePosition, 10);

                $(window).off("scroll.ap" + fieldId).on("scroll.ap" + fieldId, updatePosition);
                $(window).off("resize.ap" + fieldId).on("resize.ap" + fieldId, updatePosition);
            }

            /* =============== Exit Edit Mode =============== */
            function exitEditMode(cancel) {
                if (!isEditing) return;
                isEditing = false;

                if (cancel && textBoxInstance) {
                    textBoxInstance.option("value", originalValue);
                } else if (textBoxInstance) {
                    originalValue = textBoxInstance.option("value");
                    cellInfo.data["TaskName"] = originalValue;
                    $displayDiv.text(originalValue);
                }

                if ($controlContainer) $controlContainer.hide();
                $displayDiv.show();

                if (actionPopup_TaskName) {
                    actionPopup_TaskName.hide();
                }
            }

            /* =============== SAVE VALUE =============== */
            async function saveValue() {
                if (!textBoxInstance) {
                    exitEditMode(false);
                    return;
                }

                const newVal = textBoxInstance.option("value");
                if (newVal === originalValue) {
                    exitEditMode(false);
                    return;
                }

                try {
                    await saveFunction(


                        JSON.stringify(["-1233093056", ["TaskName"], [newVal]]),
                        [[taskID], "TaskID"]
                    );

                    originalValue = newVal;
                    cellInfo.data["TaskName"] = newVal;
                    $displayDiv.text(newVal);
                    uiManager.showAlert({ type: "success", message: "Lưu thành công" });

                    exitEditMode(false);
                } catch (err) {
                    uiManager.showAlert({ type: "error", message: "Có lỗi xảy ra khi lưu" });
                }
            }

            /* =============== CLICK TO EDIT =============== */
            $wrapper.on("click", function(e) {
                e.stopPropagation();
                if (isEditing) return;
                isEditing = true;

                $displayDiv.hide();

                if (!$controlContainer) {
                    $controlContainer = $("<div>").css({ width: "100%" }).appendTo($wrapper);

                    textBoxInstance = $controlContainer.dxTextBox({
                        value: originalValue,
                        width: "100%",
                        inputAttr: { class: "form-control form-control-sm" },
                        onKeyDown: function(e) {
                            if (e.event.key === "Enter") { e.event.preventDefault(); saveValue(); }
                            if (e.event.key === "Escape") { e.event.preventDefault(); exitEditMode(true); }
                        }
                    }).dxTextBox("instance");
                } else {
                    $controlContainer.show();
                    textBoxInstance.option("value", originalValue);
                }

                setTimeout(() => {
                    const $input = $(textBoxInstance.element());
                    showActionPopup_TaskName($input, containerId,
                        async () => { await saveValue(); },
                        () => { exitEditMode(true); }
                    );
                    textBoxInstance.focus();
                }, 80);
            });
        }
    },{
        dataField: "Status",
        caption: "Trạng thái",
        width: 180,
        alignment: "left",
        allowEditing: true,

        cellTemplate: function(cellElement, cellInfo) {
            const task = cellInfo.data;
            const taskID = task.TaskID;
            const containerId = "sel_Status_" + taskID;

            const $wrapper = $("<div>")
                .attr("id", containerId)
                .css({ width: "100%", cursor: "pointer" });

            // =============== LOAD DATA SOURCE ONCE =====================
            if (!window["loadStatusDataSource"]) {

                if (!window["DataSource_Status"]) {
                    window["DataSource_Status"] = [];
                }

                window["loadStatusDataSource"] = function(callback) {

                    if (Array.isArray(window["DataSource_Status"]) &&
                        window["DataSource_Status"].length > 0) {
                        if (callback) callback();
                        return;
                    }

                    AjaxHPAParadise({
    data: {
         name: "",
                            param: ["LoginID", LoginID, "LanguageID", LanguageID]
                        },
                        success: function(res) {
                            let json = typeof res === "string" ? JSON.parse(res) : res;
                            window["DataSource_Status"] = (json.data && json.data[0]) || [];

                            if (callback) callback();
                        },
                        error: function() {
                            uiManager.showAlert({ type: "error", message: "Lỗi tải dữ liệu Status" });
                        }
                    });
                };
            }

            // Hiển thị name ban đầu
            const item = (window["DataSource_Status"] || []).find(x => x.ID === cellInfo.value);
            const displayText = item ? item.Name : "Chọn...";

            const $badge = $("<span>")
                .addClass("badge bg-light text-dark px-2 py-1")
                .css({ fontSize: "13px" })
                .text(displayText);
            $wrapper.append($badge);

            let isEditing = false;
            let originalValue = cellInfo.value;
            let selectBoxInstance = null;
            let $controlContainer = null;

            function exitEditMode(cancel) {
                if (!isEditing) return;
                isEditing = false;

                $(document).off("click.outside" + taskID);
                $(document).off("keydown.selectbox" + taskID);

                if ($controlContainer) {
                    $controlContainer.remove();
                    $controlContainer = null;
                }

                if (cancel && selectBoxInstance) {
                    cellInfo.setValue(originalValue);
                }

                const rollbackItem = window["DataSource_Status"].find(x => x.ID === (cancel ? originalValue : cellInfo.value));
                $badge.text(rollbackItem ? rollbackItem.Name : "Chọn...");
                $badge.show();

                selectBoxInstance = null;
            }

            $wrapper.on("click", function(e) {
                e.stopPropagation();
                if (isEditing) return;

                isEditing = true;
                $badge.hide();

                $controlContainer = $("<div>").css({ width: "100%" });
                $wrapper.append($controlContainer);

                // đảm bảo DS đã load xong trước khi mở selectbox
                window["loadStatusDataSource"](function() {
                    selectBoxInstance = $controlContainer.dxSelectBox({
                        dataSource: window["DataSource_Status"],
                        valueExpr: "ID",
                        displayExpr: "Name",
                        value: cellInfo.value,
                        searchEnabled: true,
                        searchMode: "contains",
                        searchExpr: ["Name", "Code", "Description"],
                        searchTimeout: 300,
                        showClearButton: true,
                        width: "100%",

                        dropDownOptions: {
                            width: 280,
                            maxHeight: 400,
                            container: $wrapper.closest(".dx-datagrid"),
                            position: { my: "top left", at: "bottom left", of: $wrapper, offset: "0 4" }
                        },

                        itemTemplate: function(data) {
                            const $item = $(`<div class="d-flex align-items-center gap-2 px-2 py-1">`);

                            const initials = (data.Name || "?").charAt(0).toUpperCase();
                            $(`<div class="rounded-circle bg-primary text-white d-flex align-items-center justify-content-center">`)
                .css({ width: "28px", height: "28px", fontSize: "13px", flexShrink: 0 })
                                .text(initials)
                                .appendTo($item);

                            const $textContainer = $(`<div class="flex-grow-1" style="min-width: 0;">`);
                            $(`<div class="text-truncate" style="font-weight: 500;">`)
                                .text(data.Name)
                                .appendTo($textContainer);

                            if (data.Code || data.Description) {
                                $(`<div class="text-muted text-truncate" style="font-size: 11px;">`)
                                    .text(data.Code || data.Description)
                                    .appendTo($textContainer);
                            }

                            $textContainer.appendTo($item);
                            return $item;
                        },

                        onValueChanged: async function(e) {
                            if (e.value !== originalValue) {
                                try {
                                    await saveFunction(
                                        JSON.stringify(["-1518142557", ["Status"], [e.value || ""]]),
                                        [[taskID], "TaskID"]
                                    );

                                    cellInfo.setValue(e.value);
                                    originalValue = e.value;

                                    const newItem = window["DataSource_Status"].find(x => x.ID === e.value);
                                    $badge.text(newItem ? newItem.Name : "Chọn...");

                                    uiManager.showAlert({ type: "success", message: "Lưu thành công" });
                                } catch (err) {
                                    uiManager.showAlert({ type: "error", message: "Lỗi lưu dữ liệu" });
                                }
                            }
                            exitEditMode(false);
                        },

                        onInitialized: function(e) {
                            setTimeout(() => {
                                e.component.open();
                                e.component.focus();
                            }, 100);
                        }
                    }).dxSelectBox("instance");

                    // Handle Enter key - close dropdown
                    setTimeout(() => {
                        $(document).on("keydown.selectbox" + taskID, function(ev) {
                            if (ev.key === "Enter") {
                                ev.preventDefault();
                                if (selectBoxInstance) {
                                    selectBoxInstance.close();
                                }
                                exitEditMode(false);
                            } else if (ev.key === "Escape") {
                                ev.preventDefault();
                                exitEditMode(true);
                            }
                        });
                    }, 150);

                    // Auto cancel khi click ra ngoài
                    setTimeout(() => {
                        $(document).on("click.outside" + taskID, function(ev) {
                            if (!$(ev.target).closest($wrapper).length &&
                                !$(ev.target).closest(".dx-overlay-content").length) {
                                exitEditMode(false);
                            }
                        });
                    }, 200);
                });
            });

            cellElement.append($wrapper);
        }
    },{
        dataField: "AssignPriority",
        caption: "Ưu tiên",
        width: 180,
        alignment: "left",
        allowEditing: true,

        cellTemplate: function(cellElement, cellInfo) {
            const task = cellInfo.data;
            const taskID = task.TaskID;
            const containerId = "sel_AssignPriority_" + taskID;

            const $wrapper = $("<div>")
                .attr("id", containerId)
                .css({ width: "100%", cursor: "pointer" });

            // =============== LOAD DATA SOURCE ONCE =====================
            if (!window["loadAssignPriorityDataSource"]) {

                if (!window["DataSource_AssignPriority"]) {
                    window["DataSource_AssignPriority"] = [];
                }

                window["loadAssignPriorityDataSource"] = function(callback) {

                    if (Array.isArray(window["DataSource_AssignPriority"]) &&
                        window["DataSource_AssignPriority"].length > 0) {
                        if (callback) callback();
                        return;
                    }

                    AjaxHPAParadise({
    data: {
         name: "",
                            param: ["LoginID", LoginID, "LanguageID", LanguageID]
                        },
                        success: function(res) {
                            let json = typeof res === "string" ? JSON.parse(res) : res;
                            window["DataSource_AssignPriority"] = (json.data && json.data[0]) || [];

                            if (callback) callback();
                        },
                        error: function() {
                            uiManager.showAlert({ type: "error", message: "Lỗi tải dữ liệu AssignPriority" });
                        }
                    });
                };
            }

            // Hiển thị name ban đầu
            const item = (window["DataSource_AssignPriority"] || []).find(x => x.ID === cellInfo.value);
            const displayText = item ? item.Name : "Chọn...";

            const $badge = $("<span>")
                .addClass("badge bg-light text-dark px-2 py-1")
                .css({ fontSize: "13px" })
                .text(displayText);
            $wrapper.append($badge);

            let isEditing = false;
            let originalValue = cellInfo.value;
            let selectBoxInstance = null;
            let $controlContainer = null;

            function exitEditMode(cancel) {
                if (!isEditing) return;
                isEditing = false;

                $(document).off("click.outside" + taskID);
                $(document).off("keydown.selectbox" + taskID);

                if ($controlContainer) {
                    $controlContainer.remove();
                    $controlContainer = null;
                }

                if (cancel && selectBoxInstance) {
                    cellInfo.setValue(originalValue);
                }

                const rollbackItem = window["DataSource_AssignPriority"].find(x => x.ID === (cancel ? originalValue : cellInfo.value));
                $badge.text(rollbackItem ? rollbackItem.Name : "Chọn...");
                $badge.show();

                selectBoxInstance = null;
            }

            $wrapper.on("click", function(e) {
                e.stopPropagation();
                if (isEditing) return;

                isEditing = true;
                $badge.hide();

                $controlContainer = $("<div>").css({ width: "100%" });
                $wrapper.append($controlContainer);

                // đảm bảo DS đã load xong trước khi mở selectbox
                window["loadAssignPriorityDataSource"](function() {
                    selectBoxInstance = $controlContainer.dxSelectBox({
                        dataSource: window["DataSource_AssignPriority"],
                        valueExpr: "ID",
                        displayExpr: "Name",
                        value: cellInfo.value,
                        searchEnabled: true,
                        searchMode: "contains",
                        searchExpr: ["Name", "Code", "Description"],
                        searchTimeout: 300,
                        showClearButton: true,
                        width: "100%",

                        dropDownOptions: {
                            width: 280,
                            maxHeight: 400,
                            container: $wrapper.closest(".dx-datagrid"),
                            position: { my: "top left", at: "bottom left", of: $wrapper, offset: "0 4" }
                        },

                        itemTemplate: function(data) {
                            const $item = $(`<div class="d-flex align-items-center gap-2 px-2 py-1">`);

                            const initials = (data.Name || "?").charAt(0).toUpperCase();
                            $(`<div class="rounded-circle bg-primary text-white d-flex align-items-center justify-content-center">`)
                .css({ width: "28px", height: "28px", fontSize: "13px", flexShrink: 0 })
                                .text(initials)
                                .appendTo($item);

                            const $textContainer = $(`<div class="flex-grow-1" style="min-width: 0;">`);
                            $(`<div class="text-truncate" style="font-weight: 500;">`)
                                .text(data.Name)
                                .appendTo($textContainer);

                            if (data.Code || data.Description) {
                                $(`<div class="text-muted text-truncate" style="font-size: 11px;">`)
                                    .text(data.Code || data.Description)
                                    .appendTo($textContainer);
                            }

                            $textContainer.appendTo($item);
                            return $item;
                        },

                        onValueChanged: async function(e) {
                            if (e.value !== originalValue) {
                                try {
                                    await saveFunction(
                                        JSON.stringify(["-1518142557", ["AssignPriority"], [e.value || ""]]),
                                        [[taskID], "TaskID"]
                                    );

                                    cellInfo.setValue(e.value);
                                    originalValue = e.value;

                                    const newItem = window["DataSource_AssignPriority"].find(x => x.ID === e.value);
                                    $badge.text(newItem ? newItem.Name : "Chọn...");

                                    uiManager.showAlert({ type: "success", message: "Lưu thành công" });
                                } catch (err) {
                                    uiManager.showAlert({ type: "error", message: "Lỗi lưu dữ liệu" });
                                }
                            }
                            exitEditMode(false);
                        },

                        onInitialized: function(e) {
                            setTimeout(() => {
                                e.component.open();
                                e.component.focus();
                            }, 100);
                        }
                    }).dxSelectBox("instance");

                    // Handle Enter key - close dropdown
                    setTimeout(() => {
                        $(document).on("keydown.selectbox" + taskID, function(ev) {
                            if (ev.key === "Enter") {
                                ev.preventDefault();
                                if (selectBoxInstance) {
                                    selectBoxInstance.close();
                                }
                                exitEditMode(false);
                            } else if (ev.key === "Escape") {
                                ev.preventDefault();
                                exitEditMode(true);
                            }
                        });
                    }, 150);

                    // Auto cancel khi click ra ngoài
                    setTimeout(() => {
                        $(document).on("click.outside" + taskID, function(ev) {
                            if (!$(ev.target).closest($wrapper).length &&
                                !$(ev.target).closest(".dx-overlay-content").length) {
                                exitEditMode(false);
                            }
                        });
                    }, 200);
                });
            });

            cellElement.append($wrapper);
        }
    },{
        dataField: "StartDate",
        label: { text: "Ngày giao" },
        editorType: "dxDateBox",
        editorOptions: {
            type: "date",
            displayFormat: "dd/MM/yyyy",
            useMaskBehavior: true,
            dateSerializationFormat: "yyyy-MM-dd",
            readOnly: 1
        }
    },{
        dataField: "EndDate",
        label: { text: "Hạn hoàn thành" },
        editorType: "dxDateBox",
        editorOptions: {
            type: "date",
            displayFormat: "dd/MM/yyyy",
            useMaskBehavior: true,
            dateSerializationFormat: "yyyy-MM-dd",
            readOnly: 1
        }
    },{
        dataField: "Progress",
        label: { text: "Tiến độ (%)" },
        editorType: "dxNumberBox",
        editorOptions: {
            format: "#,##0",
            showSpinButtons: false,
            readOnly: 1
        }
    },{
        dataField: "TaskID",
        caption: "Mã CV",
        minWidth: 150,
        allowEditing: true,
        cellTemplate: function(cellElement, cellInfo) {
            const task = cellInfo.data;
            const taskID = task.TaskID;
            const containerId = "txt_TaskID_" + taskID;

            /* =============== Inline DOM =============== */
            const $wrapper = $("<div>")
                .attr("id", containerId)
                .css({ width: "100%", minHeight: "40px", cursor: "pointer" });

            const $displayDiv = $("<div>")
                .text(cellInfo.value || "")
                .css({ padding: "8px" });

            $wrapper.append($displayDiv);
            cellElement.append($wrapper);

            let textBoxInstance = null;
            let $controlContainer = null;
            let isEditing = false;
            let originalValue = cellInfo.value || "";

            /* =============== Popup SAVE/CANCEL =============== */
            let actionPopup_TaskID = null;
            let currentFieldId_TaskID = null;
            let saveCallback_TaskID = null;
            let cancelCallback_TaskID = null;

            function initActionPopup_TaskID() {
                if (actionPopup_TaskID) return;

                actionPopup_TaskID = $("<div>").appendTo("body").dxPopup({
                    width: "auto",
                    height: "auto",
                    showTitle: false,
                    visible: false,
                    shading: false,
                    animation: null,
                    showCloseButton: false,
                    dragEnabled: false,
                    position: { at: "bottom right", my: "top right", offset: "0 4" },

         }).dxPopup("instance");

                actionPopup_TaskID.option("contentTemplate", () => {
                    return $("<div class=\"d-flex\" style=\"gap: 6px; padding: 6px;\">").append(
                        $("<div>").dxButton({
                            icon: "check",
                            type: "success",
                            stylingMode: "contained",
                            width: 32, height: 32,
                            onClick: async () => {
                                if (saveCallback_TaskID) await saveCallback_TaskID();
                                actionPopup_TaskID.hide();
                            }
                        }),
                        $("<div>").dxButton({
                            icon: "close",
                            stylingMode: "outlined",
                            width: 32, height: 32,
                            onClick: () => {
                                if (cancelCallback_TaskID) cancelCallback_TaskID();
                                actionPopup_TaskID.hide();
                            }
                        })
                    );
                });
            }

            function showActionPopup_TaskID(inputElement, fieldId, onSave, onCancel) {
                initActionPopup_TaskID();

                if (currentFieldId_TaskID && currentFieldId_TaskID !== fieldId) {
                    if (cancelCallback_TaskID) cancelCallback_TaskID();
                }

                currentFieldId_TaskID = fieldId;
                saveCallback_TaskID = onSave;
                cancelCallback_TaskID = onCancel;

                const updatePosition = () => {
                    if (!actionPopup_TaskID?.option("visible")) return;
                    const $input = $(inputElement).find("input");
                    if ($input.length === 0) return;

                    actionPopup_TaskID.option({
                        position: {
                            my: "top right",
                            at: "bottom right",
                            of: $input,
                            offset: "0 4"
                        }
                    });
                };

                actionPopup_TaskID.show();
                setTimeout(updatePosition, 10);

                $(window).off("scroll.ap" + fieldId).on("scroll.ap" + fieldId, updatePosition);
                $(window).off("resize.ap" + fieldId).on("resize.ap" + fieldId, updatePosition);
            }

            /* =============== Exit Edit Mode =============== */
            function exitEditMode(cancel) {
                if (!isEditing) return;
                isEditing = false;

                if (cancel && textBoxInstance) {
                    textBoxInstance.option("value", originalValue);
                } else if (textBoxInstance) {
                    originalValue = textBoxInstance.option("value");
                    cellInfo.data["TaskID"] = originalValue;
                    $displayDiv.text(originalValue);
                }

                if ($controlContainer) $controlContainer.hide();
                $displayDiv.show();

                if (actionPopup_TaskID) {
                    actionPopup_TaskID.hide();
                }
            }

            /* =============== SAVE VALUE =============== */
            async function saveValue() {
                if (!textBoxInstance) {
                    exitEditMode(false);
                    return;
                }

                const newVal = textBoxInstance.option("value");
                if (newVal === originalValue) {
                    exitEditMode(false);
                    return;
                }

                try {
                    await saveFunction(


                        JSON.stringify(["-1518142557", ["TaskID"], [newVal]]),
                        [[taskID], "TaskID"]
                    );

                    originalValue = newVal;
                    cellInfo.data["TaskID"] = newVal;
                    $displayDiv.text(newVal);
                    uiManager.showAlert({ type: "success", message: "Lưu thành công" });

                    exitEditMode(false);
                } catch (err) {
                    uiManager.showAlert({ type: "error", message: "Có lỗi xảy ra khi lưu" });
                }
            }

            /* =============== CLICK TO EDIT =============== */
            $wrapper.on("click", function(e) {
                e.stopPropagation();
                if (isEditing) return;
                isEditing = true;

                $displayDiv.hide();

                if (!$controlContainer) {
                    $controlContainer = $("<div>").css({ width: "100%" }).appendTo($wrapper);

                    textBoxInstance = $controlContainer.dxTextBox({
                        value: originalValue,
                        width: "100%",
                        inputAttr: { class: "form-control form-control-sm" },
                        onKeyDown: function(e) {
                            if (e.event.key === "Enter") { e.event.preventDefault(); saveValue(); }
                            if (e.event.key === "Escape") { e.event.preventDefault(); exitEditMode(true); }
                        }
                    }).dxTextBox("instance");
                } else {
                    $controlContainer.show();
                    textBoxInstance.option("value", originalValue);
                }

                setTimeout(() => {
                    const $input = $(textBoxInstance.element());
                    showActionPopup_TaskID($input, containerId,
                        async () => { await saveValue(); },
                        () => { exitEditMode(true); }
                    );
                    textBoxInstance.focus();
                }, 80);
            });
        }
    },{
        dataField: "IsOverdue",
        caption: "Trạng thái hạn",
        minWidth: 150,
        allowEditing: true,
        cellTemplate: function(cellElement, cellInfo) {
            const task = cellInfo.data;
            const taskID = task.TaskID;
            const containerId = "txt_IsOverdue_" + taskID;

            /* =============== Inline DOM =============== */
            const $wrapper = $("<div>")
                .attr("id", containerId)
                .css({ width: "100%", minHeight: "40px", cursor: "pointer" });

            const $displayDiv = $("<div>")
                .text(cellInfo.value || "")
                .css({ padding: "8px" });

            $wrapper.append($displayDiv);
            cellElement.append($wrapper);

            let textBoxInstance = null;
            let $controlContainer = null;
            let isEditing = false;
            let originalValue = cellInfo.value || "";

            /* =============== Popup SAVE/CANCEL =============== */
            let actionPopup_IsOverdue = null;
            let currentFieldId_IsOverdue = null;
            let saveCallback_IsOverdue = null;
            let cancelCallback_IsOverdue = null;

            function initActionPopup_IsOverdue() {
                if (actionPopup_IsOverdue) return;

                actionPopup_IsOverdue = $("<div>").appendTo("body").dxPopup({
                    width: "auto",
                    height: "auto",
                    showTitle: false,
                    visible: false,
                    shading: false,
                    animation: null,
                    showCloseButton: false,
                    dragEnabled: false,
                    position: { at: "bottom right", my: "top right", offset: "0 4" },

         }).dxPopup("instance");

                actionPopup_IsOverdue.option("contentTemplate", () => {
                    return $("<div class=\"d-flex\" style=\"gap: 6px; padding: 6px;\">").append(
                        $("<div>").dxButton({
                            icon: "check",
                            type: "success",
                            stylingMode: "contained",
                            width: 32, height: 32,
                            onClick: async () => {
                                if (saveCallback_IsOverdue) await saveCallback_IsOverdue();
                                actionPopup_IsOverdue.hide();
                            }
                        }),
                        $("<div>").dxButton({
                            icon: "close",
                            stylingMode: "outlined",
                            width: 32, height: 32,
                            onClick: () => {
                                if (cancelCallback_IsOverdue) cancelCallback_IsOverdue();
                                actionPopup_IsOverdue.hide();
                            }
                        })
                    );
                });
            }

            function showActionPopup_IsOverdue(inputElement, fieldId, onSave, onCancel) {
                initActionPopup_IsOverdue();

                if (currentFieldId_IsOverdue && currentFieldId_IsOverdue !== fieldId) {
                    if (cancelCallback_IsOverdue) cancelCallback_IsOverdue();
                }

                currentFieldId_IsOverdue = fieldId;
                saveCallback_IsOverdue = onSave;
                cancelCallback_IsOverdue = onCancel;

                const updatePosition = () => {
                    if (!actionPopup_IsOverdue?.option("visible")) return;
                    const $input = $(inputElement).find("input");
                    if ($input.length === 0) return;

                    actionPopup_IsOverdue.option({
                        position: {
                            my: "top right",
                            at: "bottom right",
                            of: $input,
                            offset: "0 4"
                        }
                    });
                };

                actionPopup_IsOverdue.show();
                setTimeout(updatePosition, 10);

                $(window).off("scroll.ap" + fieldId).on("scroll.ap" + fieldId, updatePosition);
                $(window).off("resize.ap" + fieldId).on("resize.ap" + fieldId, updatePosition);
            }

            /* =============== Exit Edit Mode =============== */
            function exitEditMode(cancel) {
                if (!isEditing) return;
                isEditing = false;

                if (cancel && textBoxInstance) {
                    textBoxInstance.option("value", originalValue);
                } else if (textBoxInstance) {
                    originalValue = textBoxInstance.option("value");
                    cellInfo.data["IsOverdue"] = originalValue;
                    $displayDiv.text(originalValue);
                }

                if ($controlContainer) $controlContainer.hide();
                $displayDiv.show();

                if (actionPopup_IsOverdue) {
                    actionPopup_IsOverdue.hide();
                }
            }

            /* =============== SAVE VALUE =============== */
            async function saveValue() {
                if (!textBoxInstance) {
                    exitEditMode(false);
                    return;
                }

                const newVal = textBoxInstance.option("value");
                if (newVal === originalValue) {
                    exitEditMode(false);
                    return;
                }

                try {
                    await saveFunction(


                        JSON.stringify(["1832609208", ["IsOverdue"], [newVal]]),
                        [[taskID], "TaskID"]
                    );

                    originalValue = newVal;
                    cellInfo.data["IsOverdue"] = newVal;
                    $displayDiv.text(newVal);
                    uiManager.showAlert({ type: "success", message: "Lưu thành công" });

                    exitEditMode(false);
                } catch (err) {
                    uiManager.showAlert({ type: "error", message: "Có lỗi xảy ra khi lưu" });
                }
            }

            /* =============== CLICK TO EDIT =============== */
            $wrapper.on("click", function(e) {
                e.stopPropagation();
                if (isEditing) return;
                isEditing = true;

                $displayDiv.hide();

                if (!$controlContainer) {
                    $controlContainer = $("<div>").css({ width: "100%" }).appendTo($wrapper);

                    textBoxInstance = $controlContainer.dxTextBox({
                        value: originalValue,
                        width: "100%",
                        inputAttr: { class: "form-control form-control-sm" },
                        onKeyDown: function(e) {
                            if (e.event.key === "Enter") { e.event.preventDefault(); saveValue(); }
                            if (e.event.key === "Escape") { e.event.preventDefault(); exitEditMode(true); }
                        }
                    }).dxTextBox("instance");
                } else {
                    $controlContainer.show();
                    textBoxInstance.option("value", originalValue);
                }

                setTimeout(() => {
                    const $input = $(textBoxInstance.element());
                    showActionPopup_IsOverdue($input, containerId,
                        async () => { await saveValue(); },
                        () => { exitEditMode(true); }
                    );
                    textBoxInstance.focus();
                }, 80);
            });
        }
    },{
        dataField: "EmployeeID",
        caption: "Người thực hiện",
        width: 220,
        allowSorting: false,
        allowEditing: false,
        cellTemplate: function(cellElement, cellInfo) {
            // === Đảm bảo các hàm dùng chung toàn cục tồn tại ===
            if (typeof window.getInitials !== "function") {
                window.getInitials = function(name) {
                    if (!name) return "?";
                    const words = name.trim().split(/\s+/);
                    if (words.length >= 2) {
                        return (words[0][0] + words[words.length - 1][0]).toUpperCase();
                    }
                    return name.substring(0, 2).toUpperCase();
                };
            }
            if (typeof window.loadEmployeeImage !== "function") {
                window.__paradisefile_cache = window.__paradisefile_cache || {};
                window.__paradisefile_promises = window.__paradisefile_promises || {};
                window.loadEmployeeImage = function(emp) {
                    if (!emp || !emp.storeImgName || !emp.paramImg) return Promise.resolve(null);
                    const cacheKey = emp.storeImgName + "|" + emp.paramImg;
                    if (window.__paradisefile_cache[cacheKey]) {
                        return Promise.resolve(window.__paradisefile_cache[cacheKey]);
                    }
                    if (window.__paradisefile_promises[cacheKey]) {
                        return window.__paradisefile_promises[cacheKey];
                    }
                    const promise = new Promise((resolve) => {
                        try {
                            const decoded = decodeURIComponent(emp.paramImg);
                            const paramArray = JSON.parse(decoded);
                            if (Array.isArray(paramArray) && paramArray.length > 1) {
                                AjaxHPAParadise({
                                    data: { name: emp.storeImgName, param: paramArray },
                                    xhrFields: { responseType: "blob" },
                                    cache: true,
                                    success: function(blob) {
                                        if (blob && blob.size > 0) {
                                            const url = URL.createObjectURL(blob);
                                            window.__paradisefile_cache[cacheKey] = url;
                                            resolve(url);
                                        } else {
                                            console.warn(`[EMPTY BLOB] Ảnh rỗng hoặc không hợp lệ cho ${emp.Name} (${emp.ID})`);
                                            resolve(null);
                                        }
                                    },
                                    error: function(xhr, status, error) {
                                        console.error(`[ERROR] Lỗi khi tải ảnh cho ${emp.Name} (${emp.ID}):`, error);
                                        resolve(null);
                                    }
                                });
                            } else resolve(null);
                        } catch (e) {
                            console.error(`[PARSE ERROR] Lỗi khi parse paramImg cho ${emp.Name} (${emp.ID}):`, e);
                            resolve(null);
                      }
                    }).finally(() => {
              delete window.__paradisefile_promises[cacheKey];
                    });
                    window.__paradisefile_promises[cacheKey] = promise;
                    return promise;
                };
            }

            const task = cellInfo.data;
            const taskID = task.TaskID;
            const containerId = "emp_EmployeeID_" + taskID;
            const $container = $("<div>")
                .attr("id", containerId)
                .css({ cursor: "pointer", padding: "4px" });

            const empIdsStr = cellInfo.value || "";
            const empIds = empIdsStr ? empIdsStr.split(",").map(id => id.trim()) : [];

            // === Render avatars ===
            const renderAvatars = () => {
                $container.empty();
                const $avatarList = $("<div>").addClass("d-flex align-items-center flex-wrap gap-1");
                let empList = [];

                if (window.DataSource_Employee && window.DataSource_Employee_Loaded) {
                    empList = empIds.map(id => {
                        return window.DataSource_Employee.find(e => String(e.ID) === String(id)) || { ID: id, Name: "?" };
                    });
                } else {
                    empList = empIds.map(id => ({ ID: id, Name: "..." }));
                }

                const MAX_VISIBLE = 4;
                const visibleEmps = empList.slice(0, MAX_VISIBLE);

                visibleEmps.forEach((emp, idx) => {
                    const $avatar = $("<div>")
                        .css({
                            width: "28px",
                            height: "28px",
                            borderRadius: "50%",
                            display: "flex",
                            alignItems: "center",
                            justifyContent: "center",
                            border: "2px solid white",
                            marginLeft: idx > 0 ? "-10px" : "0",
                            boxShadow: "0 1px 3px rgba(0,0,0,0.15)",
                            background: "#e9ecef",
                            overflow: "hidden"
                        })
                        .attr("title", emp.Name || "?");

                    const cacheKey = emp.storeImgName && emp.paramImg ? (emp.storeImgName + "|" + emp.paramImg) : null;
                    const cachedUrl = cacheKey ? window.__paradisefile_cache[cacheKey] : null;

                    if (cachedUrl) {
                        $("<img>")
                            .attr("src", cachedUrl)
                            .css({ width: "100%", height: "100%", objectFit: "cover" })
                            .appendTo($avatar);
                    } else {
                        const initials = window.getInitials(emp.Name);
                        $avatar
                            .css({ background: "#e9ecef", color: "#495057", fontWeight: "600", fontSize: "11px" })
                            .text(initials);

                        if (emp.storeImgName && emp.paramImg) {
                            window.loadEmployeeImage(emp).then(url => {
                                if (url) {
                                    $avatar.empty().append($("<img>").attr("src", url).css({
                                        width: "100%",
                                        height: "100%",
                                        objectFit: "cover"
                                    }));
                                }
                            });
                        }
                    }
                    $avatar.appendTo($avatarList);
                });

                if (empList.length > MAX_VISIBLE) {
                    $("<div>")
                        .css({
                            width: "28px",
                            height: "28px",
                            borderRadius: "50%",
                            background: "#6c757d",
                            color: "white",
                            fontSize: "11px",
                            fontWeight: "700",
                            display: "flex",
                            alignItems: "center",
                            justifyContent: "center",
                            border: "2px solid white",
                            marginLeft: "-10px",
                            boxShadow: "0 1px 3px rgba(0,0,0,0.15)"
                        })
                        .text("+" + (empList.length - MAX_VISIBLE))
                        .appendTo($avatarList);
                }

                if (empList.length === 0) {
                    $("<span class=\"text-muted fst-italic fs-13\">Chưa gán</span>")
                        .appendTo($avatarList);
                }

                $container.append($avatarList);
            };

            // === Load employee data if not loaded ===
            if (!window.loadEmployeeDataSource) {
                window.DataSource_Employee = [];
                window.DataSource_Employee_Loaded = false;
                window.DataSource_Employee_Callbacks = [];
                window.loadEmployeeDataSource = function(callback) {
                    if (window.DataSource_Employee_Loaded) {
                        if (callback) callback();
                        return;
                    }
                    if (callback) window.DataSource_Employee_Callbacks.push(callback);
                    if (window.DataSource_Employee_Loading) return;
                    window.DataSource_Employee_Loading = true;
                    AjaxHPAParadise({
                        data: {
                            name: "EmployeeListAll_DataSetting_Custom",
                            param: ["LoginID", LoginID, "LanguageID", LanguageID]
                        },
                        success: function(res) {
                            const json = typeof res === "string" ? JSON.parse(res) : res;
                            window.DataSource_Employee = (json.data?.[0]) || [];
                            window.DataSource_Employee_Loaded = true;
                            window.DataSource_Employee_Loading = false;
                            while (window.DataSource_Employee_Callbacks.length > 0) {
                                const cb = window.DataSource_Employee_Callbacks.shift();
                                if (cb) cb();
                            }
                        },
                        error: function() {
                            console.error("Không thể tải danh sách nhân viên");
                            window.DataSource_Employee_Loading = false;
                            window.DataSource_Employee_Callbacks = [];
                        }
                    });
                };
            }

            renderAvatars();
            if (!window.DataSource_Employee_Loaded) {
                window.loadEmployeeDataSource(() => renderAvatars());
            }

            // === Popup chọn nhân viên ===
            $container.on("click", function(e) {
                e.stopPropagation();

                const $popupEl = $("<div>").appendTo("body");
          const popupInstance = $popupEl.dxPopup({
                    width: 720,
    height: 560,
 showTitle: true,
                    title: "Chọn nhân viên",
             visible: true,
                    shading: true,
                    closeOnOutsideClick: true,
                    dragEnabled: true,
                    resizeEnabled: true,
                    toolbarItems: [
                        {
                            widget: "dxButton",
                            location: "after",
                            toolbar: "bottom",
                            options: {
                                text: "Xác nhận",
                                type: "success",
                                stylingMode: "contained",
                                onClick: async function() {
                                    const selectedIds = tagBox.option("value") || [];
                                    const newValue = selectedIds.join(",");
                                    if (newValue !== empIdsStr) {
                                        try {
                                            const dataJSON = JSON.stringify(["-1518142557", ["EmployeeID"], [newValue]]);
                                            const idValsJSON = JSON.stringify([[taskID], "TaskID"]);
                                            const json = await saveFunction(dataJSON, idValsJSON);
                                            const dtError = json.data?.[json.data.length - 1] || [];
                                            if (dtError.length > 0 && dtError[0].Status === "ERROR") {
                                                uiManager.showAlert({ type: "error", message: dtError[0]?.Message || "Lưu thất bại" });
                                                return;
                                            }
                                            cellInfo.setValue(newValue);
                                            cellInfo.data["EmployeeID"] = newValue;
                                            uiManager.showAlert({ type: "success", message: "Đã cập nhật" });
                                        } catch (err) {
                                            uiManager.showAlert({ type: "error", message: "Có lỗi xảy ra khi lưu" });
                                        }
                                    }
                                    popupInstance.hide();
                                }
                            }
                        },
                        {
                            widget: "dxButton",
                            location: "after",
                            toolbar: "bottom",
                            options: {
                                text: "Hủy",
                                onClick: function() { popupInstance.hide(); }
                            }
                        }
                    ],
                    contentTemplate: function() {
                        const $content = $("<div>").css({ padding: "12px" });

                        const tagBox = $("<div>").dxTagBox({
                            dataSource: window.DataSource_Employee,
                            valueExpr: "ID",
                            displayExpr: "Name",
                            value: empIds,
                            showSelectionControls: true,
                            applyValueMode: "useButtons",
                            searchEnabled: true,
                            searchExpr: ["Name", "Email", "Code"],
                            placeholder: "Tìm kiếm nhân viên...",
                            showClearButton: true,
                            maxDisplayedTags: 6,
                            itemTemplate: function(data) {
                                const $item = $("<div>").addClass("d-flex align-items-center gap-2");
                                const hasImg = data.storeImgName && data.paramImg;
     if (hasImg) {
       const cacheKey = data.storeImgName + "|" + data.paramImg;
     const imgUrl = window.__paradisefile_cache?.[cacheKey] || null;
                                    if (imgUrl) {
                                        $("<img>").attr("src", imgUrl).css({
                                            width: "24px", height: "24px", borderRadius: "50%", objectFit: "cover"
                                        }).appendTo($item);
                                    } else {
                                        window.loadEmployeeImage(data).then(url => {
                                            if (url) {
                                                $item.find("img").attr("src", url);
                                            }
                                        });
                                        const initials = window.getInitials(data.Name);
                                        $("<div>").text(initials).css({
                                            width: "24px", height: "24px", borderRadius: "50%",
                                            background: "#e9ecef", color: "#495057", fontSize: "11px",
                                            display: "flex", alignItems: "center", justifyContent: "center"
                                        }).appendTo($item);
                                    }
                                } else {
                                    const initials = window.getInitials(data.Name);
                                    $("<div>").text(initials).css({
                                        width: "24px", height: "24px", borderRadius: "50%",
                                        background: "#e9ecef", color: "#495057", fontSize: "11px",
                                        display: "flex", alignItems: "center", justifyContent: "center"
                                    }).appendTo($item);
                                }
                                $("<span>").text(data.Name).appendTo($item);
                                return $item;
                            }
                        }).appendTo($content);

                        $("<div>").dxDataGrid({
                            dataSource: window.DataSource_Employee,
                            keyExpr: "ID",
                            height: 380,
                            selection: { mode: "multiple", showCheckBoxesMode: "always" },
                            selectedRowKeys: empIds,
                            columns: [
                                {
                                    dataField: "ID",
                                    caption: "Avatar",
                                    width: 40,
                                    cellTemplate: function(container, cellInfo) {
                                        const emp = cellInfo.data;
                                        const $cell = $(container);
                                        const hasImg = emp.storeImgName && emp.paramImg;
                                        if (hasImg) {
                                            const cacheKey = emp.storeImgName + "|" + emp.paramImg;
                                            const imgUrl = window.__paradisefile_cache?.[cacheKey] || null;
                                            if (imgUrl) {
                                                $("<img>").attr("src", imgUrl).css({
                                                    width: "28px", height: "28px", borderRadius: "50%", objectFit: "cover"
                                                }).appendTo($cell);
                                            } else {
                                                const initials = window.getInitials(emp.Name);
                                                $("<div>").text(initials).css({
                              width: "28px", height: "28px", borderRadius: "50%",
                                                    background: "#e9ecef", color: "#495057", fontSize: "11px",
                                            display: "flex", alignItems: "center", justifyContent: "center"
                                                }).appendTo($cell);
                                                window.loadEmployeeImage(emp).then(url => {
                                                    if (url) {
                                                        $cell.empty().append($("<img>").attr("src", url).css({
                                                            width: "28px", height: "28px", borderRadius: "50%", objectFit: "cover"
                                                        }));
                                                    }
                                                });
                                            }
                                        } else {
                                            const initials = window.getInitials(emp.Name);
                                            $("<div>").text(initials).css({
                                                width: "28px", height: "28px", borderRadius: "50%",
                                                background: "#e9ecef", color: "#495057", fontSize: "11px",
                                                display: "flex", alignItems: "center", justifyContent: "center"
                                            }).appendTo($cell);
                                        }
                                    }
                                },
                                { dataField: "Name", caption: "Họ tên", width: 180 },
                                { dataField: "Email", caption: "Email", width: 200 },
                                { dataField: "Department", caption: "Phòng ban", width: 120 },
                                { dataField: "Position", caption: "Chức vụ", width: 120 }
                            ],
                            showBorders: true,
                            searchPanel: { visible: true, placeholder: "Tìm nhanh..." },
                            onSelectionChanged: function(e) {
                                tagBox.dxTagBox("instance").option("value", e.selectedRowKeys);
                            },
                            onContentReady: function(e) {
                                const sortColumns = e.component.getVisibleColumns().filter(c => c.sortIndex >= 0);
                                sortColumns.forEach(col => {
                                    e.component.columnOption(col.dataField, "sortIndex", undefined);
                                });
                            }
                        }).appendTo($content);

                        return $content;
                    },
                    onShowing: function(e) {
                        const popupInst = e.component;
                        if (!window.DataSource_Employee_Loaded) {
                            popupInst.showLoadingOverlay("Đang tải danh sách nhân viên...");
                            window.loadEmployeeDataSource(() => {
                                popupInst.hideLoadingOverlay();
                                const $content = $(popupInst.content());
                                const tagBoxInst = $content.find(".dx-tagbox").dxTagBox("instance");
                                const gridInst = $content.find(".dx-datagrid").dxDataGrid("instance");
                                if (tagBoxInst) tagBoxInst.option("dataSource", window.DataSource_Employee);
                                if (gridInst) gridInst.option("dataSource", window.DataSource_Employee);
    });
                        }
                    },
                    onHiding: function(e) {
                        setTimeout(() => {
   $popupEl.remove();
                        }, 300);
               }
                }).dxPopup("instance");
            });

         cellElement.append($container);
        }
    },{
        dataField: "ParentTaskID",
        caption: "ID Task cha", groupIndex: 0,
        minWidth: 150,
        allowEditing: true,
        cellTemplate: function(cellElement, cellInfo) {
            const task = cellInfo.data;
            const taskID = task.TaskID;
            const containerId = "txt_ParentTaskID_" + taskID;

            /* =============== Inline DOM =============== */
            const $wrapper = $("<div>")
                .attr("id", containerId)
                .css({ width: "100%", minHeight: "40px", cursor: "pointer" });

            const $displayDiv = $("<div>")
                .text(cellInfo.value || "")
                .css({ padding: "8px" });

            $wrapper.append($displayDiv);
            cellElement.append($wrapper);

            let textBoxInstance = null;
            let $controlContainer = null;
            let isEditing = false;
            let originalValue = cellInfo.value || "";

            /* =============== Popup SAVE/CANCEL =============== */
            let actionPopup_ParentTaskID = null;
            let currentFieldId_ParentTaskID = null;
            let saveCallback_ParentTaskID = null;
            let cancelCallback_ParentTaskID = null;

            function initActionPopup_ParentTaskID() {
                if (actionPopup_ParentTaskID) return;

                actionPopup_ParentTaskID = $("<div>").appendTo("body").dxPopup({
                    width: "auto",
                    height: "auto",
                    showTitle: false,
                    visible: false,
                    shading: false,
                    animation: null,
                    showCloseButton: false,
                    dragEnabled: false,
                    position: { at: "bottom right", my: "top right", offset: "0 4" },

         }).dxPopup("instance");

                actionPopup_ParentTaskID.option("contentTemplate", () => {
                    return $("<div class=\"d-flex\" style=\"gap: 6px; padding: 6px;\">").append(
                        $("<div>").dxButton({
                            icon: "check",
                            type: "success",
                            stylingMode: "contained",
                            width: 32, height: 32,
                            onClick: async () => {
                                if (saveCallback_ParentTaskID) await saveCallback_ParentTaskID();
                                actionPopup_ParentTaskID.hide();
                            }
                        }),
                        $("<div>").dxButton({
                            icon: "close",
                            stylingMode: "outlined",
                            width: 32, height: 32,
                            onClick: () => {
                                if (cancelCallback_ParentTaskID) cancelCallback_ParentTaskID();
                                actionPopup_ParentTaskID.hide();
                            }
                        })
                    );
                });
            }

            function showActionPopup_ParentTaskID(inputElement, fieldId, onSave, onCancel) {
                initActionPopup_ParentTaskID();

                if (currentFieldId_ParentTaskID && currentFieldId_ParentTaskID !== fieldId) {
                    if (cancelCallback_ParentTaskID) cancelCallback_ParentTaskID();
                }

                currentFieldId_ParentTaskID = fieldId;
                saveCallback_ParentTaskID = onSave;
                cancelCallback_ParentTaskID = onCancel;

                const updatePosition = () => {
                    if (!actionPopup_ParentTaskID?.option("visible")) return;
                    const $input = $(inputElement).find("input");
                    if ($input.length === 0) return;

                    actionPopup_ParentTaskID.option({
                        position: {
                            my: "top right",
                            at: "bottom right",
                            of: $input,
                            offset: "0 4"
                        }
                    });
                };

                actionPopup_ParentTaskID.show();
                setTimeout(updatePosition, 10);

                $(window).off("scroll.ap" + fieldId).on("scroll.ap" + fieldId, updatePosition);
                $(window).off("resize.ap" + fieldId).on("resize.ap" + fieldId, updatePosition);
            }

            /* =============== Exit Edit Mode =============== */
            function exitEditMode(cancel) {
                if (!isEditing) return;
                isEditing = false;

                if (cancel && textBoxInstance) {
                    textBoxInstance.option("value", originalValue);
                } else if (textBoxInstance) {
                    originalValue = textBoxInstance.option("value");
                    cellInfo.data["ParentTaskID"] = originalValue;
                    $displayDiv.text(originalValue);
                }

                if ($controlContainer) $controlContainer.hide();
                $displayDiv.show();

                if (actionPopup_ParentTaskID) {
                    actionPopup_ParentTaskID.hide();
                }
            }

            /* =============== SAVE VALUE =============== */
            async function saveValue() {
                if (!textBoxInstance) {
                    exitEditMode(false);
                    return;
                }

                const newVal = textBoxInstance.option("value");
                if (newVal === originalValue) {
                    exitEditMode(false);
                    return;
                }

                try {
                    await saveFunction(


                        JSON.stringify(["1832609208", ["ParentTaskID"], [newVal]]),
                        [[taskID], "TaskID"]
                    );

                    originalValue = newVal;
                    cellInfo.data["ParentTaskID"] = newVal;
                    $displayDiv.text(newVal);
                    uiManager.showAlert({ type: "success", message: "Lưu thành công" });

                    exitEditMode(false);
                } catch (err) {
                    uiManager.showAlert({ type: "error", message: "Có lỗi xảy ra khi lưu" });
                }
            }

            /* =============== CLICK TO EDIT =============== */
            $wrapper.on("click", function(e) {
                e.stopPropagation();
                if (isEditing) return;
                isEditing = true;

                $displayDiv.hide();

                if (!$controlContainer) {
                    $controlContainer = $("<div>").css({ width: "100%" }).appendTo($wrapper);

                    textBoxInstance = $controlContainer.dxTextBox({
                        value: originalValue,
                        width: "100%",
                        inputAttr: { class: "form-control form-control-sm" },
                        onKeyDown: function(e) {
                            if (e.event.key === "Enter") { e.event.preventDefault(); saveValue(); }
                            if (e.event.key === "Escape") { e.event.preventDefault(); exitEditMode(true); }
                        }
                    }).dxTextBox("instance");
                } else {
                    $controlContainer.show();
                    textBoxInstance.option("value", originalValue);
                }

                setTimeout(() => {
                    const $input = $(textBoxInstance.element());
                    showActionPopup_ParentTaskID($input, containerId,
                        async () => { await saveValue(); },
                        () => { exitEditMode(true); }
                    );
                    textBoxInstance.focus();
                }, 80);
            });
        }
    }],

                onCellPrepared: function(e) {
                    if (e.rowType === "data") {
                        // Drag icon
                        if ($(e.cellElement).hasClass("dx-command-drag")) {
                            $(e.cellElement).css({
                                padding: "0 0 0 10px",
                                cursor: "pointer"
                            });
                        }

                        // Checkbox select
                        if ($(e.cellElement).hasClass("dx-command-select")) {
                            $(e.cellElement).css({
                                padding: "0 5px 0 0"
                            });
                        }
                    }
                },

                onRowPrepared: function(e) {
                    if (e.rowType === "data") {
                        // Tạo wrapper cho action buttons - CHỈ GIỮ PHẦN NÀY
                        const $actionWrapper = $("<div>")
                            .addClass("hpa-row-actions-start")
                            .css({
                                position: "absolute",
                                left: "100px",  // Vị trí sau checkbox (~40px)
                                top: "50%",
                                transform: "translateY(-50%)",
                                display: "none",
                                zIndex: 10,
                                background: "white",
                                borderRadius: "6px",
                                boxShadow: "0 2px 8px rgba(0,0,0,0.15)",
                                padding: "6px 8px"
                            });

                        const $detailBtn = $("<i>")
                            .addClass("bi bi-eye")
                            .css({
                                fontSize: "18px",
                                color: "#495057",
                                cursor: "pointer",
                                padding: "6px",
                                borderRadius: "4px",
                                transition: "all 0.2s"
                            })
                            .attr("title", "Xem chi tiết")
                            .hover(
                                function() { $(this).css({ backgroundColor: "#e3f2fd", color: "#1976d2" }); },
                                function() { $(this).css({ backgroundColor: "transparent", color: "#495057" }); }
                            )
                            .on("click", function(ev) {
                                ev.stopPropagation();
                                const recordID = e.data.TaskID;
                                if (typeof openDetailTaskID === "function") {
                                    openDetailTaskID(recordID);
                                } else {
                                    uiManager.showAlert({
                                        type: "info",
                                        message: "Chi tiết bản ghi ID: " + recordID
                                    });
                                }
                            });

                        $actionWrapper.append($detailBtn);

                        e.rowElement
                            .addClass("hpa-grid-item")
                            .css({ position: "relative" })
                            .append($actionWrapper)
                            .hover(
                                function() {
                                    $(this).find(".hpa-row-actions-start").stop().fadeIn(150);
                                },
                                function() {
                                    $(this).find(".hpa-row-actions-start").stop().fadeOut(100);
                                }
                            );
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
                                if (typeof ReloadData === "function") {
                                    ReloadData();
                                }
                            }
                        }
                    });
                },
            }).dxDataGrid("instance");
        
    
    
';
    SELECT @html AS html;
END
GO

EXEC sp_GenerateHTMLScript 'sp_Task_Tasklist_html'