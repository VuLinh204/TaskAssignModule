USE Paradise_Beta_Tai2
GO
if object_id('[dbo].[sptblCommonControlType_Signed]') is null
	EXEC ('CREATE PROCEDURE [dbo].[sptblCommonControlType_Signed] as select 1')
GO

ALTER PROCEDURE [dbo].[sptblCommonControlType_Signed]
    @TableName VARCHAR(256) = ''
AS
BEGIN
    DECLARE @UseLayout BIT = 0;
    DECLARE @PKColumnName VARCHAR(100);
    DECLARE @PKColumnId VARCHAR(64);
    DECLARE @object_Id VARCHAR(MAX) = CAST(OBJECT_ID(@TableName) AS NVARCHAR(64))
    IF EXISTS (
        SELECT 1
        FROM dbo.tblCommonControlType_Signed
        WHERE TableName = @TableName
          AND Layout IS NOT NULL
    )
    BEGIN
        SET @UseLayout = 1;
    END
    -- Tạo bảng tạm
    IF OBJECT_ID('tempdb..#temptable') IS NOT NULL DROP TABLE #temptable

    update t
    set html='',loadUI='',loadData='',loadUILayout=''
    from tblCommonControlType_Signed t
    WHERE TableName = @TableName

    UPDATE t SET [UID] = 'P' + Replace(CAST(NEWID() as varchar(36)), '-', '' )
	from tblCommonControlType_Signed t
    WHERE TableName = @TableName and ISNULL(t.[UID],'') = ''

    SELECT
        t.*,
        CAST(c.column_id AS NVARCHAR(64)) AS columnId
    INTO #temptable
    FROM dbo.tblCommonControlType_Signed t
    LEFT JOIN sys.columns c ON c.name = t.[ColumnName] AND c.object_id = OBJECT_ID(t.TableEditor)
    WHERE TableName = @TableName

    -- ============================ CARD VIEW LAYOUT =====================================
    -- CardView Container
    UPDATE t1 SET loadUI = N'
        let Instance%UID% = $("#%Layout%").dxList({
            dataSource: [],
            height: "100%",
            scrolling: { mode: "virtual" },
            noDataText: "Không có dữ liệu",
            itemTemplate: (data, index, element) => {
                const $card = $("<div>").addClass("hpa-card-item").css({
                    "padding": "10px",
                    "margin-bottom": "10px",
                    "border": "1px solid #ddd",
                    "border-radius": "8px",
                    "box-shadow": "0 2px 4px rgba(0,0,0,0.05)"
                });

                $("<div>").dxForm({
                    formData: data,
                    readOnly: false,
                    labelLocation: "top",
                    colCount: 1,
                    items: [],
                    onFieldDataChanged: async function(e) {
                        const colName = e.dataField;
                        let val = e.value;
                        const recordID = e.component.option("formData").%PKColumnName%;
                        const itemOption = e.component.itemOption(colName);

                        if (itemOption.editorType === "dxDateBox") {
                            if (itemOption.editorOptions.type === "date" && val) {
                                val = DevExpress.localization.formatDate(new Date(val), "yyyy/MM/dd");
                            } else if (itemOption.editorOptions.type === "time" && val) {
                                val = DevExpress.localization.formatDate(new Date(val), "HH:mm");
                            }
                        } else if (itemOption.editorType === "dxTextBox" && itemOption.editorOptions.mode === "tel") {
                            val = val ? val.replace(/[^0-9+]/g, "") : "";
                        }

                        const dataJSON = JSON.stringify(["%tableId%", [colName], [val]]);
                        const idValuesJSON = JSON.stringify([[recordID], "%ColumnIDName%"]);

                        try {
                            const json = await saveFunction(dataJSON, idValuesJSON);
                            const dtError = json.data[json.data.length - 1] || [];
                            if (dtError.length > 0 && dtError[0].Status === "ERROR") {
                                uiManager.showAlert({ type: "error", message: dtError[0]?.Message || "Lưu thất bại" });
                            }
                        } catch (err) {
                            console.error("AutoSave Error:", err);
                        }
                    }
}).appendTo($card);

              return $card;
            }
        }).dxList("instance");
    '
    FROM #temptable t1
    WHERE t1.ID = (
        SELECT TOP 1 ID
        FROM #temptable
        WHERE CardView = 1 AND Layout = 'Card_View'
        ORDER BY ID
    )

    UPDATE t1 SET html = N'<div id="%Layout%" style="height: 100%;"></div>'
    FROM #temptable t1
    WHERE t1.ID = (
        SELECT TOP 1 ID
        FROM #temptable
        WHERE CardView = 1 AND Layout = 'Card_View'
        ORDER BY ID
    )

    -- ============================ GRID VIEW LAYOUT =====================================
    -- GridView Container (hỗ trợ grouping + drag & drop + hover action button ở đầu row)
    UPDATE t1 SET
        loadUI = N'
            let Instance%UID% = $("#%Layout%").dxDataGrid({
                dataSource: [],
                keyExpr: "%PKColumnName%",
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
                    storageKey: "gridState_%Layout%"
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
                    group: "%columnName%",
                    cursor: "grabbing",

                    onReorder: async function(e) {
                        if (e.itemData.key !== undefined || e.itemData.items) {
                            e.component.refresh();
                            return;
                        }

                        const movedItem = e.itemData;
                        if (!movedItem || movedItem.%PKColumnName% === undefined) {
                            console.warn("movedItem invalid:", movedItem);
                            return;
                        }

                        const grid = e.component;
                        const visibleRows = grid.getVisibleRows();
                        const pkField = "%PKColumnName%";

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
                                "%tableId%",
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
                columns: [],

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
                                const recordID = e.data.%PKColumnName%;
                                if (typeof openDetail%PKColumnName% === "function") {
                                    openDetail%PKColumnName%(recordID);
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
        ',
        html = N'<div id="%Layout%" style="height: 100%;"></div>'
    FROM #temptable t1
    WHERE t1.ID = (
        SELECT TOP 1 ID
        FROM #temptable
        WHERE GridView = 1 AND Layout = 'Grid_View'
        ORDER BY ID
    )

    -- ========================================================================================
    -- START BUILD CONTROL

   -- ========================================================================================
    UPDATE #temptable SET loadUILayout = N'{
        dataField: "%columnName%",
        label: { text: "%DisplayName%" },
        editorType: "dxDateBox",
        editorOptions: {
            type: "date",
            displayFormat: "dd/MM/yyyy",
            useMaskBehavior: true,
            dateSerializationFormat: "yyyy-MM-dd",
            readOnly: %ReadOnly%
        }
    },'
    WHERE [Type] = 'hpaControlDate' AND (CardView = 1 OR GridView = 1)

    UPDATE #temptable SET loadUILayout = N'{
        dataField: "%columnName%",
        label: { text: "%DisplayName%" },
        editorType: "dxDateBox",
        editorOptions: {
            type: "time",
            displayFormat: "HH:mm",
            pickerType: "rollers",
            useMaskBehavior: true,
            readOnly: %ReadOnly%
        }
    },'
    WHERE [Type] = 'hpaControlTime' AND (CardView = 1 OR GridView = 1)

    UPDATE #temptable SET loadUILayout = N'{
        dataField: "%columnName%",
        label: { text: "%DisplayName%" },
        editorType: "dxTextBox",
        editorOptions: {
            mode: "tel",
            readOnly: %ReadOnly%
        }
    },'
    WHERE [Type] = 'hpaControlPhone' AND (CardView = 1 OR GridView = 1)

    UPDATE #temptable SET loadUILayout = N'{
        dataField: "%columnName%",
        label: { text: "%DisplayName%" },
        editorType: "dxNumberBox",
        editorOptions: {
            format: "#,##0",
            showSpinButtons: false,
            readOnly: %ReadOnly%
        }
    },'
    WHERE [Type] = 'hpaControlNumber' AND (CardView = 1 OR GridView = 1)

    UPDATE #temptable SET loadUILayout = N'{
        dataField: "%columnName%",
        label: { text: "%DisplayName%" },
        editorType: "dxNumberBox",
        editorOptions: {
            format: "#,##0 ₫",
            showSpinButtons: false,
            readOnly: %ReadOnly%
        }
    },'
    WHERE [Type] = 'hpaControlMoney' AND (CardView = 1 OR GridView = 1)

    UPDATE #temptable SET loadUILayout = N'{
        dataField: "%columnName%",
        caption: "%DisplayName%",
        minWidth: 150,
        allowEditing: true,
        cellTemplate: function(cellElement, cellInfo) {
            const task = cellInfo.data;
            const taskID = task.%ColumnIDName%;
            const containerId = "txt_%columnName%_" + taskID;

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
            let actionPopup_%columnName% = null;
            let currentFieldId_%columnName% = null;
            let saveCallback_%columnName% = null;
            let cancelCallback_%columnName% = null;

            function initActionPopup_%columnName%() {
                if (actionPopup_%columnName%) return;

                actionPopup_%columnName% = $("<div>").appendTo("body").dxPopup({
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

                actionPopup_%columnName%.option("contentTemplate", () => {
                    return $("<div class=\"d-flex\" style=\"gap: 6px; padding: 6px;\">").append(
                        $("<div>").dxButton({
                            icon: "check",
                            type: "success",
                            stylingMode: "contained",
                            width: 32, height: 32,
                            onClick: async () => {
                                if (saveCallback_%columnName%) await saveCallback_%columnName%();
                                actionPopup_%columnName%.hide();
                            }
                        }),
                        $("<div>").dxButton({
                            icon: "close",
                            stylingMode: "outlined",
                            width: 32, height: 32,
                            onClick: () => {
                                if (cancelCallback_%columnName%) cancelCallback_%columnName%();
                                actionPopup_%columnName%.hide();
                            }
                        })
                    );
                });
            }

            function showActionPopup_%columnName%(inputElement, fieldId, onSave, onCancel) {
                initActionPopup_%columnName%();

                if (currentFieldId_%columnName% && currentFieldId_%columnName% !== fieldId) {
                    if (cancelCallback_%columnName%) cancelCallback_%columnName%();
                }

                currentFieldId_%columnName% = fieldId;
                saveCallback_%columnName% = onSave;
                cancelCallback_%columnName% = onCancel;

                const updatePosition = () => {
                    if (!actionPopup_%columnName%?.option("visible")) return;
                    const $input = $(inputElement).find("input");
                    if ($input.length === 0) return;

                    actionPopup_%columnName%.option({
                        position: {
                            my: "top right",
                            at: "bottom right",
                            of: $input,
                            offset: "0 4"
                        }
                    });
                };

                actionPopup_%columnName%.show();
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
                    cellInfo.data["%columnName%"] = originalValue;
                    $displayDiv.text(originalValue);
                }

                if ($controlContainer) $controlContainer.hide();
                $displayDiv.show();

                if (actionPopup_%columnName%) {
                    actionPopup_%columnName%.hide();
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


                        JSON.stringify(["%tableId%", ["%columnName%"], [newVal]]),
                        [[taskID], "%ColumnIDName%"]
                    );

                    originalValue = newVal;
                    cellInfo.data["%columnName%"] = newVal;
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
                    showActionPopup_%columnName%($input, containerId,
                        async () => { await saveValue(); },
                        () => { exitEditMode(true); }
                    );
                    textBoxInstance.focus();
                }, 80);
            });
        }
    },'
    WHERE [Type] = 'hpaControlText' AND (CardView = 1 OR GridView = 1) AND [ReadOnly] = 0

    UPDATE #temptable SET loadUILayout = N'{
        dataField: "%columnName%",
        label: { text: "%DisplayName%" },
        editorType: "dxTextBox",
        editorOptions: {
            readOnly: true
        }
    },'
    WHERE [Type] = 'hpaControlText' AND (CardView = 1 OR GridView = 1) AND [ReadOnly] = 1

    UPDATE #temptable SET loadUILayout = N'{
        dataField: "%columnName%",
        caption: "%DisplayName%",
        width: 180,
        alignment: "left",
        allowEditing: true,

        cellTemplate: function(cellElement, cellInfo) {
            const task = cellInfo.data;
            const taskID = task.%ColumnIDName%;
            const containerId = "sel_%columnName%_" + taskID;

            const $wrapper = $("<div>")
                .attr("id", containerId)
                .css({ width: "100%", cursor: "pointer" });

            // =============== LOAD DATA SOURCE ONCE =====================
            if (!window["load%columnName%DataSource"]) {

                if (!window["DataSource_%columnName%"]) {
                    window["DataSource_%columnName%"] = [];
                }

                window["load%columnName%DataSource"] = function(callback) {

                    if (Array.isArray(window["DataSource_%columnName%"]) &&
                        window["DataSource_%columnName%"].length > 0) {
                        if (callback) callback();
                        return;
                    }

                    AjaxHPAParadise({
                        data: {
                            name: "%DataSourceSP%",
                            param: ["LoginID", LoginID, "LanguageID", LanguageID]
                        },
                        success: function(res) {
                            let json = typeof res === "string" ? JSON.parse(res) : res;
                            window["DataSource_%columnName%"] = (json.data && json.data[0]) || [];

                            if (callback) callback();
                        },
                        error: function() {
                            uiManager.showAlert({ type: "error", message: "Lỗi tải dữ liệu %columnName%" });
                        }
                    });
                };
            }

            // Hiển thị name ban đầu
            const item = (window["DataSource_%columnName%"] || []).find(x => x.ID === cellInfo.value);
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

                const rollbackItem = window["DataSource_%columnName%"].find(x => x.ID === (cancel ? originalValue : cellInfo.value));
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
                window["load%columnName%DataSource"](function() {
                    selectBoxInstance = $controlContainer.dxSelectBox({
                        dataSource: window["DataSource_%columnName%"],
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
                                        JSON.stringify(["%tableId%", ["%columnName%"], [e.value || ""]]),
                                        [[taskID], "%ColumnIDName%"]
                                    );

                                    cellInfo.setValue(e.value);
                                    originalValue = e.value;

                                    const newItem = window["DataSource_%columnName%"].find(x => x.ID === e.value);
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
    },'
    WHERE [Type] = 'hpaControlSelectBox' AND (CardView = 1 OR GridView = 1) AND [ReadOnly] = 0;

    UPDATE #temptable SET loadUILayout = N'{
     dataField: "%columnName%",
        label: { text: "%DisplayName%" },
        editorType: "dxSelectBox",
        editorOptions: {
            dataSource: DataSource_%columnName%,
       valueExpr: "ID",
            displayExpr: "Name",
            readOnly: true
        }
    },'
    WHERE [Type] = 'hpaControlSelectBox' AND (CardView = 1 OR GridView = 1) AND [ReadOnly] = 1

    UPDATE #temptable SET loadUILayout = N'{
        dataField: "%columnName%",
        caption: "%DisplayName%",
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
            const taskID = task.%ColumnIDName%;
            const containerId = "emp_%columnName%_" + taskID;
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
                                            const dataJSON = JSON.stringify(["%tableId%", ["%columnName%"], [newValue]]);
                                            const idValsJSON = JSON.stringify([[taskID], "%ColumnIDName%"]);
                                            const json = await saveFunction(dataJSON, idValsJSON);
                                            const dtError = json.data?.[json.data.length - 1] || [];
                                            if (dtError.length > 0 && dtError[0].Status === "ERROR") {
                                                uiManager.showAlert({ type: "error", message: dtError[0]?.Message || "Lưu thất bại" });
                                                return;
                                            }
                                            cellInfo.setValue(newValue);
                                            cellInfo.data["%columnName%"] = newValue;
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
    },'
    WHERE [Type] = 'hpaControlSelectEmployee' AND (CardView = 1 OR GridView = 1)

    -- ============================ CONTROL THÔNG THƯỜNG (NON-LAYOUT) ===================================

    EXEC sp_hpaControlDate @TableName = @TableName

    EXEC sp_hpaControlTime @TableName = @TableName

    EXEC sp_hpaControlPhone @TableName = @TableName

    EXEC sp_hpaControlNumber @TableName = @TableName

    EXEC sp_hpaControlMoney @TableName = @TableName

    EXEC sp_hpaControlText @TableName = @TableName

    EXEC sp_hpaControlTextArea @TableName = @TableName

    EXEC sp_hpaControlSelectBox @TableName = @TableName

    EXEC sp_hpaControlSelectEmployee @TableName = @TableName

    -- HTML và LoadData cho các control cơ bản
    UPDATE #temptable SET html = N'<div id="%UID%"></div>'
    WHERE [Type] IN ('hpaControlDate', 'hpaControlTime', 'hpaControlPhone', 'hpaControlNumber', 'hpaControlMoney', 'hpaControlText', 'hpaControlTextArea', 'hpaControlSelectBox', 'hpaControlSelectEmployee') AND Layout IS NULL

    UPDATE #temptable SET loadData = N'
       Instance%ColumnName%._suppressValueChangeAction();
       Instance%ColumnName%.option("value", obj.%columnName%);
       Instance%ColumnName%._resumeValueChangeAction();
    '
    WHERE [Type] IN ('hpaControlDate', 'hpaControlPhone', 'hpaControlNumber', 'hpaControlMoney', 'hpaControlText', 'hpaControlTextArea', 'hpaControlSelectBox', 'hpaControlSelectEmployee') AND Layout IS NULL

    UPDATE #temptable SET loadData = N'
       Instance%ColumnName%._suppressValueChangeAction();
       Instance%ColumnName%.option("value", obj.%columnName% ? new Date("1970/01/01 " + obj.%columnName%) : null);
       Instance%ColumnName%._resumeValueChangeAction();
    '
    WHERE [Type] = 'hpaControlTime' AND Layout IS NULL

    -- ========================================================================================
    -- END BUILD CONTROL
    -- ========================================================================================

    -- Thêm groupIndex nếu có giá trị trong cột GroupIndex (cho Grid View)
    UPDATE #temptable
    SET loadUILayout =
        CASE
            WHEN GroupIndex IS NOT NULL
            THEN REPLACE(loadUILayout,
                        'caption: "%DisplayName%",',
                        'caption: "%DisplayName%", groupIndex: ' + CAST(GroupIndex AS VARCHAR(10)) + ',')
            ELSE loadUILayout
        END
    WHERE GridView = 1
    AND loadUILayout IS NOT NULL
    AND loadUILayout LIKE '%caption: "%DisplayName%",%';

    -- Xử lý tableId cho control thông thường
    UPDATE t
        SET loadUI = REPLACE(loadUI, '%tableId%', CAST(CHECKSUM(o.name) AS VARCHAR(64)))
        FROM #temptable t
        INNER JOIN sys.objects o ON o.name = t.TableEditor AND o.type = 'U'
        WHERE t.Layout IS NULL
    -- Xử lý tableId cho control cardview gridview
    UPDATE t
        SET
            loadUI = REPLACE(loadUI, '%tableId%', CAST(CHECKSUM(o.name) AS VARCHAR(64))),
            loadUILayout = REPLACE(loadUILayout, '%tableId%', CAST(CHECKSUM(o.name) AS VARCHAR(64)))
        FROM #temptable t
        INNER JOIN sys.objects o ON o.name = t.TableEditor AND o.type = 'U'
        WHERE t.CardView = 1 OR t.GridView = 1

    -- Phần thay thế biến chung
    UPDATE #temptable SET loadUI = REPLACE(loadUI, '%tableId%', ISNULL(@object_Id, ''))
    UPDATE #temptable SET loadUI = REPLACE(loadUI, '%UID%', ISNULL([UID], ''))
    UPDATE #temptable SET loadUI = REPLACE(loadUI, '%columnName%', ISNULL(ColumnName, ''))
    UPDATE #temptable SET loadUI = REPLACE(loadUI, '%DatasourceSP%', ISNULL(DatasourceSP, ''))
    UPDATE #temptable SET loadUI = REPLACE(loadUI, '%columnId%', ISNULL(columnId, ''))
    UPDATE #temptable SET loadUI = REPLACE(loadUI, '%ColumnIDName%', ISNULL(ColumnIDName, ''))
    UPDATE #temptable SET loadUI = REPLACE(loadUI, '%ColumnIDName2%', ISNULL(ColumnIDName2, ''))
    UPDATE #temptable SET loadUI = REPLACE(loadUI, '%Layout%', ISNULL(Layout, ''))

    UPDATE #temptable SET loadData = REPLACE(loadData, '%UID%', ISNULL([UID], ''))
    UPDATE #temptable SET loadData = REPLACE(loadData, '%columnName%', ISNULL(ColumnName, ''))
    UPDATE #temptable SET loadData = REPLACE(loadData, '%DatasourceSP%', ISNULL(DatasourceSP, ''))
    UPDATE #temptable SET loadData = REPLACE(loadData, '%columnId%', ISNULL(columnId, ''))
    UPDATE #temptable SET loadData = REPLACE(loadData, '%ColumnIDName%', ISNULL(ColumnIDName, ''))
    UPDATE #temptable SET loadData = REPLACE(loadData, '%ColumnIDName2%', ISNULL(ColumnIDName2, ''))
    UPDATE #temptable SET loadData = REPLACE(loadData, '%Layout%', ISNULL(Layout, ''))

    UPDATE #temptable SET html = REPLACE(html, '%UID%', ISNULL([UID], ''))
    UPDATE #temptable SET html = REPLACE(html, '%Layout%', ISNULL(Layout, ''))

    -- Xử lý loadUILayout replacements cho tất cả cases
    UPDATE #temptable SET loadUILayout = REPLACE(loadUILayout, '%columnName%', ISNULL(ColumnName, ''))
    UPDATE #temptable SET loadUILayout = REPLACE(loadUILayout, '%DatasourceSP%', ISNULL(DatasourceSP, ''))
    UPDATE #temptable SET loadUILayout = REPLACE(loadUILayout, '%DisplayName%', ISNULL(DisplayName, ISNULL(ColumnName, '')))
    UPDATE #temptable SET loadUILayout = REPLACE(loadUILayout, '%ReadOnly%', CAST(ISNULL(ReadOnly, 0) AS VARCHAR(1)))
    UPDATE #temptable SET loadUILayout = REPLACE(loadUILayout, '%columnId%', ISNULL(columnId, ''))
    UPDATE #temptable SET loadUILayout = REPLACE(loadUILayout, '%UID%', ISNULL([UID], ''))
    UPDATE #temptable SET loadUILayout = REPLACE(loadUILayout, '%ColumnIDName%', ISNULL(ColumnIDName, ''))
    UPDATE #temptable SET loadUILayout = REPLACE(loadUILayout, '%ColumnIDName2%', ISNULL(ColumnIDName2, ''))
    UPDATE #temptable SET loadUILayout = REPLACE(loadUILayout, '%tableId%', ISNULL(@object_Id, ''))
    UPDATE #temptable SET loadUILayout = REPLACE(loadUILayout, '%Layout%', ISNULL(Layout, ''))

    IF @UseLayout = 1
    BEGIN
        DECLARE @LayoutType VARCHAR(20) = (SELECT TOP 1 Layout FROM #temptable WHERE TableName = @TableName AND Layout IS NOT NULL)
        IF @LayoutType = 'Card_View'
        BEGIN
            -- CARD VIEW: tổng hợp items cho dxForm
            DECLARE @cardViewItems NVARCHAR(MAX) = N''
            SELECT @cardViewItems += loadUILayout
            FROM #temptable
            WHERE CardView = 1
            ORDER BY ID

            IF LEN(@cardViewItems) > 0
                SET @cardViewItems = LEFT(@cardViewItems, LEN(@cardViewItems) - 1)

            SELECT TOP 1
                @PKColumnName = ColumnIDName,
                @PKColumnId = columnId
            FROM #temptable
            WHERE CardView = 1

            UPDATE #temptable
            SET loadUI = REPLACE(
                    REPLACE(
                        REPLACE(loadUI, '%PKColumnName%', ISNULL(@PKColumnName, 'ID')),
                        '%columnId%', ISNULL(@PKColumnId, '1')
                    ),
                    'items: []', 'items: [' + @cardViewItems + ']'
                )
            WHERE Layout = 'Card_View'
        END
        ELSE IF @LayoutType = 'Grid_View'
        BEGIN
            -- GRID VIEW: tổng hợp columns cho dxDataGrid
            DECLARE @gridViewColumns NVARCHAR(MAX) = N''
            SELECT @gridViewColumns += loadUILayout
            FROM #temptable
            WHERE GridView = 1
            ORDER BY ID

            -- Xóa dấu phẩy cuối nếu có
            IF LEN(@gridViewColumns) > 0 AND RIGHT(@gridViewColumns, 1) = ','
                SET @gridViewColumns = LEFT(@gridViewColumns, LEN(@gridViewColumns) - 1)

            -- Lấy PKColumnName (dùng để reference record, nếu cần)
            SELECT TOP 1 @PKColumnName = ColumnIDName
            FROM #temptable
            WHERE GridView = 1

            SET @PKColumnName = ISNULL(@PKColumnName, 'ID')

            -- Cập nhật columns + PK vào loadUI của Grid_View container
            UPDATE #temptable
            SET loadUI = REPLACE(
                    REPLACE(loadUI, 'columns: []', 'columns: [' + @gridViewColumns + ']'),
                    '%PKColumnName%', @PKColumnName
                )
            WHERE Layout = 'Grid_View'
        END
    END

    -- ====== XUẤT KẾT QUẢ =======
    DECLARE @SPLoadData VARCHAR(100), @LayoutName VARCHAR(100), @ColumnIDName VARCHAR(100), @UID VARCHAR(100);
	DECLARE @ColumnIDNames TABLE (ColumnIDName VARCHAR(200));
	DECLARE @ColumnIDNames2 TABLE (ColumnIDName2 VARCHAR(200));

    SELECT TOP 1 @SPLoadData = SPLoadData FROM #temptable WHERE TableName = @TableName
    SELECT TOP 1 @UID = [UID] FROM #temptable WHERE TableName = @TableName
    SELECT TOP 1 @LayoutName = Layout FROM #temptable WHERE (CardView = 1 OR GridView = 1) AND TableName = @TableName
    SELECT TOP 1 @PKColumnName = ColumnIDName FROM #temptable WHERE (CardView = 1 OR GridView = 1)

    INSERT INTO @ColumnIDNames(ColumnIDName) SELECT DISTINCT ColumnIDName FROM #temptable WHERE TableName = @TableName AND ColumnIDName IS NOT NULL;
    INSERT INTO @ColumnIDNames2(ColumnIDName2) SELECT DISTINCT ColumnIDName2 FROM #temptable WHERE TableName = @TableName AND ColumnIDName2 IS NOT NULL;

    DECLARE @jsCurrentRecordID NVARCHAR(MAX) = N'';
	DECLARE @jsCurrentRecordID2 NVARCHAR(MAX) = N'';
    SELECT @jsCurrentRecordID += ' let currentRecordID_' + ColumnIDName + ';' FROM @ColumnIDNames WHERE ColumnIDName IS NOT NULL;
    SELECT @jsCurrentRecordID2 += ' let currentRecordID_' + ColumnIDName2 + ';' FROM @ColumnIDNames2 WHERE ColumnIDName2 IS NOT NULL;

    DECLARE @jsHandleRecord NVARCHAR(MAX) = N'';
    DECLARE @jsHandleRecord2 NVARCHAR(MAX) = N'';
    SELECT @jsHandleRecord += ' currentRecordID_' + ColumnIDName + ' = obj.' + ColumnIDName + ' || currentRecordID_' + ColumnIDName + ';' FROM @ColumnIDNames;
    SELECT @jsHandleRecord2 += ' currentRecordID_' + ColumnIDName2 + ' = obj.' + ColumnIDName2 + ' || currentRecordID_' + ColumnIDName2 + ';' FROM @ColumnIDNames2;

    DECLARE @nsqlHtml NVARCHAR(MAX) = N'
    <div id="%TableName%">
        %paradisehtml%
    </div>
    <script>
        (() => {
            let DataSource = []
            %paradiseloadUI%

            %JS_CURRENT_ID%

            function ReloadData() {
                AjaxHPAParadise({
                    data: {
                        name: "%SPLoadData%",
                        param: []
                    },
                    success: function (res) {
                        const json = typeof res === "string" ? JSON.parse(res) : res
                        const results = (json.data && json.data[0]) || []

                    if (%UseLayout%=== 1) {
                     Instance%UID%.option("dataSource", results)
                        } else {
                            const obj = results[0]
                            %JS_HANDLE_RECORD%
                            DataSource = results
                            %paradiseloadData%
                        }
                    }
                })
            }
            %TableName%.ReloadData = ReloadData
            ReloadData()
        })();
    </script>'
    SET @nsqlHtml = REPLACE(@nsqlHtml, '%TableName%', ISNULL(@TableName, ''))
    SET @nsqlHtml = REPLACE(@nsqlHtml, '%SPLoadData%', ISNULL(@SPLoadData, ''))
    SET @nsqlHtml = REPLACE(@nsqlHtml, '%UseLayout%', CAST(@UseLayout AS VARCHAR(1)))
    SET @nsqlHtml = REPLACE(@nsqlHtml, '%JS_CURRENT_ID%', @jsCurrentRecordID);
    SET @nsqlHtml = REPLACE(@nsqlHtml, '%JS_HANDLE_RECORD%', @jsHandleRecord);
    SET @nsqlHtml = REPLACE(@nsqlHtml, '%UID%', ISNULL(@UID, ''))
    DECLARE @nsql NVARCHAR(MAX) = @nsqlHtml

    DECLARE @html NVARCHAR(MAX) = N''
    DECLARE @loadUI NVARCHAR(MAX) = N''
    DECLARE @loadData NVARCHAR(MAX) = N''

    SELECT
        @html += html,
        @loadUI += '
        +(select loadUI from tblCommonControlType_Signed where UID = '''+UID+''')',
                @loadData += '
        +(select loadData from tblCommonControlType_Signed where UID = '''+UID+''')'
    FROM #temptable

    SET @nsqlHtml = REPLACE(@nsqlHtml, '%paradisehtml%', ISNULL(@html, ''))
    SET @nsqlHtml = REPLACE(@nsqlHtml, '%paradiseloadUI%', ''''+isNull(@loadUI, '') + ' +N''')
    SET @nsqlHtml = REPLACE(@nsqlHtml, '%paradiseloadData%', ''''+isNull(@loadData, '') + ' +N''')

    set @html = ''
    set @loadUI = ''
    set @loadData = ''
    SELECT
        @html += html,
        @loadUI += loadUI,
        @loadData += loadData
  FROM #temptable
    SET @nsql = REPLACE(@nsql, '%paradisehtml%', ISNULL(@html, ''))
    SET @nsql = REPLACE(@nsql, '%paradiseloadUI%', ISNULL(@loadUI, ''))
    SET @nsql = REPLACE(@nsql, '%paradiseloadData%', ISNULL(@loadData, ''))

    update t
    set html=tt.html,loadUI=tt.loadUI,loadData=tt.loadData,loadUILayout=tt.loadUILayout
    from tblCommonControlType_Signed t
    inner join #temptable tt on tt.ID = t.ID
    WHERE tt.TableName = @TableName

    SELECT @nsql AS htmlProc,@nsqlHtml Html
END
GO

Exec sptblCommonControlType_Signed 'sp_Task_TaskDetail_html'
EXEC sp_GenerateHTMLScript 'sp_Task_TaskDetail_html'