USE Paradise_Dev
GO
if object_id('[dbo].[sp_hpaControlTagBox]') is null
	EXEC ('CREATE PROCEDURE [dbo].[sp_hpaControlTagBox] as select 1')
GO

ALTER PROCEDURE [dbo].[sp_hpaControlTagBox]
    @TableName VARCHAR(256) = ''
AS
BEGIN
    -- =========================================================================
    -- hpaControlTagBox - READONLY MODE
    -- =========================================================================
    UPDATE #temptable SET
        loadUI = N'
        window["DataSource_%ColumnName%"] = window["DataSource_%ColumnName%"] || [];

        let Instance%ColumnName%%UID% = $("#%UID%").dxTagBox({
            placeholder: "Tìm kiếm hoặc chọn nhiều...",
            dataSource: window["DataSource_%ColumnName%"],
            valueExpr: window["DataSourceIDField_%ColumnName%"] || "ID",
            displayExpr: window["DataSourceNameField_%ColumnName%"] || "Name",
            disabled: true,
            showSelectionControls: true,
            selectAllMode: "allPages",
            applyValueMode: "instantly",
            searchEnabled: true,
            maxDisplayedTags: 2,
            noDataText: "Không có dữ liệu",
            showMultiTagOnly: true,
            multiline: false,
            showClearButton: false,
            labelMode: "hidden",
            stylingMode: "outlined",
            onMultiTagPreparing: function(e) {
                const $element = e.component.element();
                const $input = $element.find(".dx-texteditor-input");

                if (!e.selectedItems || e.selectedItems.length === 0) {
                    e.cancel = true;
                    $input.attr("placeholder", "Tìm kiếm hoặc chọn nhiều...");
                    return;
                }

                if (e.selectedItems && e.selectedItems.length > 0) {
                    e.text = e.selectedItems.length + " đã chọn";
                    $input.attr("placeholder", "");
                }
            },
            onKeyDown: function(e) {
                // Chặn phím Delete và Backspace để không cho xóa
                if (e.event.key === "Delete" || e.event.key === "Backspace") {
                    e.event.preventDefault();
                }
            }
        }).dxTagBox("instance");

        if ("%DataSourceSP%" && "%DataSourceSP%".trim() !== "") {
            loadDataSourceCommon("%ColumnName%", "%DataSourceSP%", function(data) {
                const idField = window["DataSourceIDField_%ColumnName%"] || "ID";
                const nameField = window["DataSourceNameField_%ColumnName%"] || "Name";
                Instance%ColumnName%%UID%.option("valueExpr", idField);
                Instance%ColumnName%%UID%.option("displayExpr", nameField);
            });
        }
        '
    WHERE [Type] = 'hpaControlTagBox' AND [ReadOnly] = 1;

    -- =========================================================================
    -- hpaControlTagBox - AUTOSAVE MODE + GRID SYNC
    -- =========================================================================
    UPDATE #temptable SET
        loadUI = N'
        window["DataSource_%ColumnName%"] = window["DataSource_%ColumnName%"] || [];

        let %ColumnName%%UID%DataSourceSP = "%DataSourceSP%";
        let %ColumnName%%UID%TableAddNew = "%TableAddNew%";
        let %ColumnName%%UID%ColumnAddNew = "%ColumnNameAddNew%";
        let %ColumnName%%UID%CurrentSearch = "";
        let Instance%ColumnName%%UID% = null;
        let %ColumnName%%UID%_InitialValue = null;
        let %ColumnName%%UID%_HasChanges = false;

        // --- CORE FUNCTIONS ---
        function getDataSourceConfig%ColumnName%%UID%(data) {
            const idField = window["DataSourceIDField_%ColumnName%"] || "ID";

            return new DevExpress.data.DataSource({
                paginate: false,
                store: new DevExpress.data.CustomStore({
                    key: idField,
                    load: function(loadOptions) {
                        let searchValue = %ColumnName%%UID%CurrentSearch || "";
                        if (!searchValue && loadOptions && loadOptions.searchValue) searchValue = loadOptions.searchValue;
                        if (!searchValue && Instance%ColumnName%%UID% && Instance%ColumnName%%UID%.option) searchValue = Instance%ColumnName%%UID%.option("searchValue") || "";

                        let result = data || [];
                        if (searchValue && searchValue.trim()) {
                            const searchLower = hpaUtils.removeToneMarks(searchValue).toLowerCase();
                            const nameField = window["DataSourceNameField_%ColumnName%"] || "Name";
                            result = result.filter(item => {
                                const nameVal = item[nameField] ? hpaUtils.removeToneMarks(String(item[nameField])).toLowerCase() : "";
                                const codeVal = item["Code"] ? String(item["Code"]).toLowerCase() : "";
                                return nameVal.includes(searchLower) || codeVal.includes(searchLower);
                            });
                            if (%ColumnName%%UID%TableAddNew && %ColumnName%%UID%TableAddNew.trim() !== "") {
                                const addNewItem = { IsAddNew: true };
                                addNewItem[nameField] = searchValue.trim();
                                result.push(addNewItem);
                            }
                        }
                        return Promise.resolve({ data: result, totalCount: result.length });
                    },
                    byKey: function(key) {
                        const idField = window["DataSourceIDField_%ColumnName%"] || "ID";
                        return Promise.resolve((data || []).find(i => i[idField] === key));
                    }
                })
            });
        }

        async function processAddNew%ColumnName%(newValue) {
            if (!newValue || !newValue.trim()) return;
            Instance%ColumnName%%UID%.option("disabled", true);
            const dataJSON = JSON.stringify([%ColumnName%%UID%TableAddNew, [%ColumnName%%UID%ColumnAddNew], [newValue.trim()]]);
            try {
                const json = await saveFunction(dataJSON);
                const dtError = json.data[json.data.length - 1] || [];
                if (dtError.length > 0 && dtError[0].Status === "ERROR") {
                    uiManager.showAlert({ type: "error", message: dtError[0]?.Message || "Lỗi thêm mới" });
                } else {
                    const newItemID = dtError[0]?.IDValue || null;
                    if (newItemID) {
                        const idField = window["DataSourceIDField_%ColumnName%"] || "ID";
                        const nameField = window["DataSourceNameField_%ColumnName%"] || "Name";
                        const newItem = {};
                        newItem[idField] = newItemID;
                        newItem[nameField] = newValue.trim();
                        if (!window["DataSource_%ColumnName%"]) window["DataSource_%ColumnName%"] = [];
                        window["DataSource_%ColumnName%"].push(newItem);

                        Instance%ColumnName%%UID%.option("dataSource", getDataSourceConfig%ColumnName%%UID%(window["DataSource_%ColumnName%"]));
                        const currentVal = Instance%ColumnName%%UID%.option("value") || [];
                        const newVal = [...currentVal, newItemID];
                     Instance%ColumnName%%UID%.option("value", newVal);
                        Instance%ColumnName%%UID%.option("searchValue", "");
                        %ColumnName%%UID%CurrentSearch = "";

                        // Sau khi thêm mới thì trigger save luôn
                        await saveData%ColumnName%%UID%(newVal);
                    }
                }
            } catch (e) {
                uiManager.showAlert({ type: "error", message: "Có lỗi khi thêm mới" });
            } finally {
                Instance%ColumnName%%UID%.option("disabled", false);
                Instance%ColumnName%%UID%.close();
            }
        }

        // --- HÀM LƯU DỮ LIỆU ---
        async function saveData%ColumnName%%UID%(val) {
            var separator = window.separator%UID%;
            const valString = Array.isArray(val) ? val.join(separator) : val;

            // Sync Grid UI ngay lập tức
            if (typeof cellInfo !== "undefined" && cellInfo && cellInfo.component) {
                try {
                    const grid = cellInfo.component;
                    grid.cellValue(cellInfo.rowIndex, "%ColumnName%", valString);
                } catch (syncErr) { }
            }

            const dataJSON = JSON.stringify(["%tableId%", ["%ColumnName%"], [valString || ""]]);
            let id1 = currentRecordID_%ColumnIDName%;
            if (typeof cellInfo !== "undefined" && cellInfo && cellInfo.data) id1 = cellInfo.data["%ColumnIDName%"] || id1;
            let currentRecordIDValue = [id1];
            let currentRecordID = ["%ColumnIDName%"];
            if ("%ColumnIDName2%" && "%ColumnIDName2%".trim() !== "") {
                let id2 = currentRecordID_%ColumnIDName2%;
                if (typeof cellInfo !== "undefined" && cellInfo && cellInfo.data) id2 = cellInfo.data["%ColumnIDName2%"] || id2;
                currentRecordIDValue.push(id2);
                currentRecordID.push("%ColumnIDName2%");
            }
            const idValsJSON = JSON.stringify([currentRecordIDValue, currentRecordID]);

            try {
                const json = await saveFunction(dataJSON, idValsJSON);
                const dtError = json.data[json.data.length - 1] || [];
                if (dtError.length > 0 && dtError[0].Status === "ERROR") {
                    uiManager.showAlert({ type: "error", message: dtError[0]?.Message || "%SaveErrorMessage%" });
                    Instance%ColumnName%%UID%.option("value", %ColumnName%%UID%_InitialValue);
                } else {
                    %ColumnName%%UID%_InitialValue = val;
                    %ColumnName%%UID%_HasChanges = false;
                }
            } catch (err) {
                uiManager.showAlert({ type: "error", message: "%SaveErrorMessage%" });
                Instance%ColumnName%%UID%.option("value", %ColumnName%%UID%_InitialValue);
            }
        }

        // --- TEMPLATES ---
        const itemTemplateString%ColumnName%%UID% = function(data) {
            if (data.IsAddNew) return "";

            const idField = window["DataSourceIDField_%ColumnName%"] || "ID";
            const nameField = window["DataSourceNameField_%ColumnName%"] || "Name";
            const displayName = (data[idField] !== undefined ? data[idField] + " - " : "") + (data[nameField] || "");

            let statusBadge = "";
            if (data.Status) {
                const badgeClass = data.Status === "Active" ? "bg-success" : "bg-secondary";
                statusBadge = `<span class="badge ${badgeClass}" style="font-size: 9px; padding: 3px 6px; border-radius: 4px; opacity: 0.8;">${data.Status}</span>`;
            }

            let descHtml = "";
            if (data.Description || data.Code) {
                descHtml = `<div class="text-muted mt-1" style="font-size: 11px; overflow: hidden; text-overflow: ellipsis; white-space: nowrap;">${data.Code || data.Description}</div>`;
            }

            return `
                <div class="d-flex align-items-center gap-2 px-2 py-2 border-bottom border-light" style="position: relative;">
                    <div class="flex-fill" style="min-width: 0;">
                        <div class="fw-normal text-body" style="font-size: 13px; overflow: hidden; text-overflow: ellipsis; white-space: nowrap;">
                            ${displayName}
                        </div>
                        ${descHtml}
                    </div>
                    ${statusBadge}
                </div>
            `;
        };

        // --- INIT INSTANCE ---
        Instance%ColumnName%%UID% = $("#%UID%").dxTagBox({
            placeholder: "Tìm kiếm hoặc chọn nhiều...",
            dataSource: getDataSourceConfig%ColumnName%%UID%(window["DataSource_%ColumnName%"]),
            valueExpr: window["DataSourceIDField_%ColumnName%"] || "ID",
            displayExpr: window["DataSourceNameField_%ColumnName%"] || "Name",
            focusStateEnabled: true,
            hoverStateEnabled: true,
            activeStateEnabled: true,
            dropDownOptions: {
                showTitle: false,
                closeOnOutsideClick: true,
                maxHeight: "400px",
                minWidth: 320,
                container: undefined,
                shading: false,

                onShowing: function(e) {
                    if (Instance%ColumnName%%UID%) {
                        Instance%ColumnName%%UID%.option("searchValue", "");
                        %ColumnName%%UID%CurrentSearch = "";
                    }
                },

                onShown: function(e) {
                    setTimeout(function() {
                        // Enable keyboard navigation cho list
                        if (e.component && e.component._list) {
                            const listInstance = e.component._list;
                            listInstance.option("focusStateEnabled", true);
                            listInstance.option("hoverStateEnabled", true);
                            listInstance.option("activeStateEnabled", true);
                            listInstance.focus();
                        }

                        // Inject CSS cho focus/hover states
                        if (!$("#tagbox-focus-style-%UID%").length) {
                            const focusCSS = `
                                <style id="tagbox-focus-style-%UID%">
                                    /* Hover state */
                                    .dx-tagbox-popup-wrapper .dx-list-item:hover {
                                        background-color: #f5f5f5 !important;
                                    }

                                    /* Focus state khi dùng keyboard */
                                    .dx-tagbox-popup-wrapper .dx-list-item.dx-state-focused {
                                        background-color: #f5f5f5 !important;
                                    }

                                    /* Selected item */
                                    .dx-tagbox-popup-wrapper .dx-list-item.dx-list-item-selected {
                                        background-color: #e8f5e9 !important;
                                    }

                                    /* Focus + Selected */
                                    .dx-tagbox-popup-wrapper .dx-list-item.dx-state-focused.dx-list-item-selected {
                                        background-color: #c8e6c9 !important;
                                    }
                                </style>
                            `;
                            $("head").append(focusCSS);
                        }
                    }, 100);
                },

                onHidden: function() {
                    %ColumnName%%UID%CurrentSearch = "";
                    if (Instance%ColumnName%%UID%) Instance%ColumnName%%UID%.option("searchValue", "");
                }
            },
            tabIndex: 0,
            noDataText: "Không có dữ liệu",
            showSelectionControls: true,
            applyValueMode: "instantly",
            showMultiTagOnly: true,
            maxDisplayedTags: 2,
            searchEnabled: true,
            searchTimeout: 250,
            minSearchLength: 0,
            showDataBeforeSearch: true,
            showClearButton: false,
            multiline: false,
            labelMode: "hidden",
        stylingMode: "outlined",
            selectAllMode: "allPages",
            onFocusIn: function(e) {
                Instance%ColumnName%%UID%.option("showClearButton", true);
                // Clear search và reset data source khi tab/focus vào
                %ColumnName%%UID%CurrentSearch = "";
                Instance%ColumnName%%UID%.option("searchValue", "");

                if (Instance%ColumnName%%UID%.getDataSource()) {
                    Instance%ColumnName%%UID%.getDataSource().reload();
                }

                // Tự động mở dropdown khi tab/focus vào
                setTimeout(function() {
                    if (Instance%ColumnName%%UID% && !Instance%ColumnName%%UID%.option("opened")) {
                        Instance%ColumnName%%UID%.open();
                    }
                }, 50);
            },

            onFocusOut: function(e) {
                Instance%ColumnName%%UID%.option("showClearButton", false);

                // Đóng dropdown khi focus ra ngoài (tab sang field khác)
                if (Instance%ColumnName%%UID%.option("opened")) {
                    Instance%ColumnName%%UID%.close();
                }
            },
            onMultiTagPreparing: function(e) {
                const $element = e.component.element();
                const $input = $element.find(".dx-texteditor-input");

                if (!e.selectedItems || e.selectedItems.length === 0) {
                    e.cancel = true;
                    $input.attr("placeholder", "Tìm kiếm hoặc chọn nhiều...");
                    return;
                }

                if (e.selectedItems && e.selectedItems.length > 0) {
                    e.text = e.selectedItems.length + " đã chọn";
                    $input.attr("placeholder", "");
                }
            },
            itemTemplate: function(data, index, element) {
                if (data.IsAddNew) {
                    const nameField = window["DataSourceNameField_%ColumnName%"] || "Name";
                    const $item = $(`
                        <div class="d-flex align-items-center gap-2 px-2 py-2 text-primary" style="border-top: 1px dashed #dee2e6; font-weight: 600; cursor: pointer;">
                            <i class="bi bi-plus-circle fs-6"></i>
                            <span>Thêm mới: ${data[nameField]}</span>
                        </div>
                    `);
                    $item.on("dxclick", async function(e) {
                        e.stopPropagation();
                        if (Instance%ColumnName%%UID%) Instance%ColumnName%%UID%.blur();
                        await processAddNew%ColumnName%(data[nameField]);
                    });
                    return $item;
                }
                return itemTemplateString%ColumnName%%UID%(data);
            },
            onContentReady: function(e) {
                const $element = e.element;
                const $input = $element.find(".dx-texteditor-input");
                const $container = $element.find(".dx-texteditor-input-container");

                $input.attr("placeholder", "Tìm kiếm hoặc chọn nhiều...");

                // Căn giữa container
                $container.css({
                    "align-items": "center",
                    "display": "flex"
                });

                // Căn giữa các tag
                $element.find(".dx-tag").css({
                    "display": "flex",
                    "align-self": "center"
                });
            },
            onValueChanged: function(e) {
                const $element = e.element;
                const $input = $element.find(".dx-texteditor-input");

                // Cập nhật placeholder theo giá trị
                if (!e.value || (Array.isArray(e.value) && e.value.length === 0)) {
                    $input.attr("placeholder", "Tìm kiếm hoặc chọn nhiều...");
                } else {
                    $input.attr("placeholder", "");
                }
            },
            onKeyDown: function(e) {
                const key = e.event.key;

                // Cho phép mũi tên lên/xuống điều hướng
                if (key === "ArrowDown" || key === "ArrowUp") {
                    // Mở dropdown nếu chưa mở
                    if (!Instance%ColumnName%%UID%.option("opened")) {
                        Instance%ColumnName%%UID%.open();
                        e.event.preventDefault();
                        return;
                    }
                    // Nếu đã mở, để DevExtreme xử lý navigation mặc định
                    return;
                }

                // Enter để chọn item đang focus
                if (key === "Enter") {
                    if (!Instance%ColumnName%%UID%.option("opened")) {
                        Instance%ColumnName%%UID%.open();
                        e.event.preventDefault();
                    }
                    return;
                }

                // Escape để đóng dropdown
                if (key === "Escape") {
                    if (Instance%ColumnName%%UID%.option("opened")) {
                        Instance%ColumnName%%UID%.close();
                        e.event.preventDefault();
                    }
                    return;
                }

                // Chỉ chặn Delete/Backspace khi input trống
                if (key === "Delete" || key === "Backspace") {
                    const $input = $(e.component.element()).find(".dx-texteditor-input");
                    const inputValue = $input.val() || "";
                    if (!inputValue || inputValue.trim() === "") {
                        e.event.preventDefault();
                    }
                }
            },
            onClosed: function(e) {
                // Tự động lưu khi đóng dropdown nếu có thay đổi
                if (%ColumnName%%UID%_HasChanges) {
                    const currentVal = Instance%ColumnName%%UID%.option("value");
                    saveData%ColumnName%%UID%(currentVal);
                }
            },
            onSelectionChanged: function(e) {
                // Đánh dấu có thay đổi
                const newVal = e.component.option("value") || [];
                const oldVal = %ColumnName%%UID%_InitialValue || [];
                %ColumnName%%UID%_HasChanges = JSON.stringify(newVal.sort()) !== JSON.stringify(oldVal.sort());

                // Callback
                if (typeof window["onTagBoxChanged_%ColumnName%"] === "function") {
                    window["onTagBoxChanged_%ColumnName%"](e.value, Instance%ColumnName%%UID%, e);
                }

                // Sync grid UI ngay lập tức
                if (typeof cellInfo !== "undefined" && cellInfo && cellInfo.component) {
                    const grid = cellInfo.component;
                    const valString = Array.isArray(e.value) ? e.value.join(",") : e.value;
                    try {
                        grid.cellValue(cellInfo.rowIndex, "%ColumnName%", valString);
                    } catch (syncErr) { }
                }
            },
            onOptionChanged: function(e) {
                if (e.name === "searchValue") %ColumnName%%UID%CurrentSearch = (e.value || "").toString();
            }
        }).dxTagBox("instance");

        %ColumnName%%UID%_InitialValue = Instance%ColumnName%%UID%.option("value");

        if (%ColumnName%%UID%DataSourceSP && %ColumnName%%UID%DataSourceSP !== "") {
            loadDataSourceCommon("%ColumnName%", %ColumnName%%UID%DataSourceSP, function(data) {
                const idField = window["DataSourceIDField_%ColumnName%"] || "ID";
            const nameField = window["DataSourceNameField_%ColumnName%"] || "Name";
                Instance%ColumnName%%UID%.option("valueExpr", idField);
                Instance%ColumnName%%UID%.option("displayExpr", nameField);
                Instance%ColumnName%%UID%.option("dataSource", getDataSourceConfig%ColumnName%%UID%(data));
            });
        }
        '
    WHERE [Type] = 'hpaControlTagBox' AND [AutoSave] = 1 AND [ReadOnly] = 0;

    -- =========================================================================
    -- hpaControlTagBox - MANUAL MODE (Flexible AutoSave & ReadOnly)
    -- =========================================================================
    UPDATE #temptable SET
        loadUI = N'
        window["DataSource_%ColumnName%"] = window["DataSource_%ColumnName%"] || [];

        let %ColumnName%%UID%DataSourceSP = "%DataSourceSP%";
        let %ColumnName%%UID%TableAddNew = "%TableAddNew%";
        let %ColumnName%%UID%ColumnAddNew = "%ColumnNameAddNew%";
        let %ColumnName%%UID%CurrentSearch = "";
        let Instance%ColumnName%%UID% = null;
        let %ColumnName%%UID%_InitialValue = null;
        let %ColumnName%%UID%_HasChanges = false;
        let _autoSave%ColumnName%%UID% = false;
        let _readOnly%ColumnName%%UID% = false;

        // --- CORE FUNCTIONS ---
        function getDataSourceConfig%ColumnName%%UID%(data) {
             const idField = window["DataSourceIDField_%ColumnName%"] || "ID";
            return new DevExpress.data.DataSource({
                paginate: false,
                store: new DevExpress.data.CustomStore({
                    key: idField,
                    load: function(loadOptions) {
                        let searchValue = %ColumnName%%UID%CurrentSearch || "";
                        if (!searchValue && loadOptions && loadOptions.searchValue) searchValue = loadOptions.searchValue;
                        if (!searchValue && Instance%ColumnName%%UID% && Instance%ColumnName%%UID%.option) searchValue = Instance%ColumnName%%UID%.option("searchValue") || "";

                        let result = data || [];
                        if (searchValue && searchValue.trim()) {
                            const searchLower = hpaUtils.removeToneMarks(searchValue).toLowerCase();
                            const nameField = window["DataSourceNameField_%ColumnName%"] || "Name";
                            result = result.filter(item => {
                                const nameVal = item[nameField] ? hpaUtils.removeToneMarks(String(item[nameField])).toLowerCase() : "";
                                const codeVal = item["Code"] ? String(item["Code"]).toLowerCase() : "";
                                return nameVal.includes(searchLower) || codeVal.includes(searchLower);
                            });
                            if (%ColumnName%%UID%TableAddNew && %ColumnName%%UID%TableAddNew.trim() !== "") {
                                const addNewItem = { IsAddNew: true };
                                addNewItem[nameField] = searchValue.trim();
                                result.push(addNewItem);
                            }
                        }
                        return Promise.resolve({ data: result, totalCount: result.length });
                    },
                    byKey: function(key) {
                        const idField = window["DataSourceIDField_%ColumnName%"] || "ID";
                        return Promise.resolve((data || []).find(i => i[idField] === key));
                    }
                })
            });
        }

        async function processAddNew%ColumnName%(newValue) {
             if (!newValue || !newValue.trim()) return;
            Instance%ColumnName%%UID%.option("disabled", true);
            const dataJSON = JSON.stringify([%ColumnName%%UID%TableAddNew, [%ColumnName%%UID%ColumnAddNew], [newValue.trim()]]);
            try {
                const json = await saveFunction(dataJSON);
                const dtError = json.data[json.data.length - 1] || [];
                if (dtError.length > 0 && dtError[0].Status === "ERROR") {
                    uiManager.showAlert({ type: "error", message: dtError[0]?.Message || "Lỗi thêm mới" });
                } else {
                    const newItemID = dtError[0]?.IDValue || null;
                    if (newItemID) {
                        const idField = window["DataSourceIDField_%ColumnName%"] || "ID";
                        const nameField = window["DataSourceNameField_%ColumnName%"] || "Name";
                        const newItem = {};
                        newItem[idField] = newItemID;
                        newItem[nameField] = newValue.trim();
                        if (!window["DataSource_%ColumnName%"]) window["DataSource_%ColumnName%"] = [];
                        window["DataSource_%ColumnName%"].push(newItem);

                        Instance%ColumnName%%UID%.option("dataSource", getDataSourceConfig%ColumnName%%UID%(window["DataSource_%ColumnName%"]));
                        const currentVal = Instance%ColumnName%%UID%.option("value") || [];
                        const newVal = [...currentVal, newItemID];
                        Instance%ColumnName%%UID%.option("value", newVal);
                        Instance%ColumnName%%UID%.option("searchValue", "");
                        %ColumnName%%UID%CurrentSearch = "";

                        // Trigger save nếu _autoSave = true
                        if (_autoSave%ColumnName%%UID%) {
                            await saveData%ColumnName%%UID%(newVal);
                        }
                    }
                }
            } catch (e) {
                uiManager.showAlert({ type: "error", message: "Có lỗi khi thêm mới" });
            } finally {
                Instance%ColumnName%%UID%.option("disabled", false);
                Instance%ColumnName%%UID%.close();
            }
        }

        // --- HÀM LƯU DỮ LIỆU ---
        async function saveData%ColumnName%%UID%(val) {
            var separator = window.separator%UID%;
            const valString = Array.isArray(val) ? val.join(separator) : val;

            if (typeof cellInfo !== "undefined" && cellInfo && cellInfo.component) {
                try {
                    const grid = cellInfo.component;
                    grid.cellValue(cellInfo.rowIndex, "%ColumnName%", valString);
                } catch (syncErr) { }
            }

            const dataJSON = JSON.stringify(["%tableId%", ["%ColumnName%"], [valString || ""]]);
            let id1 = currentRecordID_%ColumnIDName%;
            if (typeof cellInfo !== "undefined" && cellInfo && cellInfo.data) id1 = cellInfo.data["%ColumnIDName%"] || id1;
            let currentRecordIDValue = [id1];
            let currentRecordID = ["%ColumnIDName%"];
            if ("%ColumnIDName2%" && "%ColumnIDName2%".trim() !== "") {
                let id2 = currentRecordID_%ColumnIDName2%;
                if (typeof cellInfo !== "undefined" && cellInfo && cellInfo.data) id2 = cellInfo.data["%ColumnIDName2%"] || id2;
                currentRecordIDValue.push(id2);
                currentRecordID.push("%ColumnIDName2%");
            }
            const idValsJSON = JSON.stringify([currentRecordIDValue, currentRecordID]);

            try {
                console.log(dataJSON, idValsJSON)
                const json = await saveFunction(dataJSON, idValsJSON);
                const dtError = json.data[json.data.length - 1] || [];
                if (dtError.length > 0 && dtError[0].Status === "ERROR") {
                    uiManager.showAlert({ type: "error", message: dtError[0]?.Message || "%SaveErrorMessage%" });
                    Instance%ColumnName%%UID%.option("value", %ColumnName%%UID%_InitialValue);
                } else {
            // Sync với Shared Grid Data Source
                    if(%GridColumnName% != 0 && %GridColumnName% != null && %GridColumnName% != "" && window.hpaSharedGridDataSources["%GridColumnName%"]) {
                        try {

                            var updateData = {};
                            updateData["%ColumnIDName%"] = currentRecordIDValue[0];
                            updateData["%ColumnName%"] = valString;

                            var id2FieldName = "%ColumnIDName2%";
                            var hasKey2 = id2FieldName && id2FieldName !== "" && id2FieldName.indexOf("%") === -1;

                            if (hasKey2) {
                                if (currentRecordIDValue.length > 1 && currentRecordIDValue[1] !== undefined) {
                                    updateData[id2FieldName] = currentRecordIDValue[1];
                                }
                            }

                            window.updateSharedGridRow("%GridColumnName%", updateData);

                            if (typeof DataSource !== "undefined" && Array.isArray(DataSource)) {
                                var ds;
                                if (!hasKey2) {
                                    ds = DataSource.filter(item => item["%ColumnIDName%"] === updateData["%ColumnIDName%"]);
                                } else {
                                    ds = DataSource.filter(item =>
                                        item["%ColumnIDName%"] === updateData["%ColumnIDName%"] &&
                                        item[id2FieldName] === updateData[id2FieldName]
                                    );
                                }

                                if (ds && ds.length > 0) {
                                    ds[0]["%ColumnName%"] = updateData["%ColumnName%"];
                                }
                            }
                        } catch (dsErr) {
                            console.warn("[Grid Sync] TagBox %ColumnName%%UID%: Không thể sync shared grid data source:", dsErr);
                        }
                    }

                    %ColumnName%%UID%_InitialValue = val;
                    %ColumnName%%UID%_HasChanges = false;
                }
            } catch (err) {
                uiManager.showAlert({ type: "error", message: "%SaveErrorMessage%" });
                Instance%ColumnName%%UID%.option("value", %ColumnName%%UID%_InitialValue);
            }
        }

        const itemTemplateString%ColumnName%%UID% = function(data) {
             if (data.IsAddNew) return "";

            const idField = window["DataSourceIDField_%ColumnName%"] || "ID";
            const nameField = window["DataSourceNameField_%ColumnName%"] || "Name";
            const displayName = (data[idField] !== undefined ? data[idField] + " - " : "") + (data[nameField] || "");

            let statusBadge = "";
            if (data.Status) {
                const badgeClass = data.Status === "Active" ? "bg-success" : "bg-secondary";
                statusBadge = `<span class="badge ${badgeClass}" style="font-size: 9px; padding: 3px 6px; border-radius: 4px; opacity: 0.8;">${data.Status}</span>`;
            }

            let descHtml = "";
            if (data.Description || data.Code) {
                descHtml = `<div class="text-muted mt-1" style="font-size: 11px; overflow: hidden; text-overflow: ellipsis; white-space: nowrap;">${data.Code || data.Description}</div>`;
            }

            return `
                <div class="d-flex align-items-center gap-2 px-2 py-2 border-bottom border-light" style="position: relative;">
                    <div class="flex-fill" style="min-width: 0;">
                        <div class="fw-normal text-body" style="font-size: 13px; overflow: hidden; text-overflow: ellipsis; white-space: nowrap;">
                            ${displayName}
                        </div>
                        ${descHtml}
                    </div>
                    ${statusBadge}
            </div>
        `;
        };

        Instance%ColumnName%%UID% = $("#%UID%").dxTagBox({
            placeholder: "Tìm kiếm hoặc chọn nhiều...",
            readOnly: _readOnly%ColumnName%%UID%,
            dataSource: getDataSourceConfig%ColumnName%%UID%(window["DataSource_%ColumnName%"]),
            valueExpr: window["DataSourceIDField_%ColumnName%"] || "ID",
            displayExpr: window["DataSourceNameField_%ColumnName%"] || "Name",
            focusStateEnabled: true,
            hoverStateEnabled: true,
            activeStateEnabled: true,
            dropDownOptions: {
                showTitle: false,
                closeOnOutsideClick: true,
                maxHeight: "400px",
                minWidth: 320,
                container: undefined,
                shading: false,

                onShowing: function(e) {
                    if (Instance%ColumnName%%UID%) {
                        Instance%ColumnName%%UID%.option("searchValue", "");
                        %ColumnName%%UID%CurrentSearch = "";
                    }
                },

                onShown: function(e) {
                    setTimeout(function() {
                        // Enable keyboard navigation cho list
                        if (e.component && e.component._list) {
                            const listInstance = e.component._list;
                            listInstance.option("focusStateEnabled", true);
                            listInstance.option("hoverStateEnabled", true);
                            listInstance.option("activeStateEnabled", true);
                            listInstance.focus();
                        }

                        // Inject CSS cho focus/hover states
                        if (!$("#tagbox-focus-style-%UID%").length) {
                            const focusCSS = `
                                <style id="tagbox-focus-style-%UID%">
                                    /* Hover state */
                                    .dx-tagbox-popup-wrapper .dx-list-item:hover {
                                        background-color: #f5f5f5 !important;
                                    }

                                    /* Focus state khi dùng keyboard */
                                    .dx-tagbox-popup-wrapper .dx-list-item.dx-state-focused {
                                        background-color: #f5f5f5 !important;
                                    }

                                    /* Selected item */
                                    .dx-tagbox-popup-wrapper .dx-list-item.dx-list-item-selected {
                                        background-color: #e8f5e9 !important;
                                    }

                                    /* Focus + Selected */
                                    .dx-tagbox-popup-wrapper .dx-list-item.dx-state-focused.dx-list-item-selected {
                                        background-color: #c8e6c9 !important;
                                    }
                                </style>
                            `;
                            $("head").append(focusCSS);
                        }
                    }, 100);
                },

                onHidden: function() {
                    %ColumnName%%UID%CurrentSearch = "";
                    if (Instance%ColumnName%%UID%) Instance%ColumnName%%UID%.option("searchValue", "");
                }
            },
            tabIndex: 0,
            noDataText: "Không có dữ liệu",
            showSelectionControls: true,
            applyValueMode: "instantly",
            showMultiTagOnly: true,
            maxDisplayedTags: 2,
            searchEnabled: true,
            searchTimeout: 250,
            minSearchLength: 0,
            showDataBeforeSearch: true,
            showClearButton: false,
            multiline: false,
            labelMode: "hidden",
            stylingMode: "outlined",
            selectAllMode: "allPages",
            onFocusIn: function(e) {
                if (!_readOnly%ColumnName%%UID%) {
                    Instance%ColumnName%%UID%.option("showClearButton", true);
                }

                // Clear search và reset data source khi tab/focus vào
                %ColumnName%%UID%CurrentSearch = "";
                Instance%ColumnName%%UID%.option("searchValue", "");

                if (Instance%ColumnName%%UID%.getDataSource()) {
                    Instance%ColumnName%%UID%.getDataSource().reload();
                }

                // Tự động mở dropdown khi tab/focus vào
                setTimeout(function() {
                    if (Instance%ColumnName%%UID% && !Instance%ColumnName%%UID%.option("opened")) {
                        Instance%ColumnName%%UID%.open();
                    }
                }, 50);
            },
            onFocusOut: function(e) {
                Instance%ColumnName%%UID%.option("showClearButton", false);

                // Đóng dropdown khi focus ra ngoài (tab sang field khác)
                if (Instance%ColumnName%%UID%.option("opened")) {
                    Instance%ColumnName%%UID%.close();
                }
            },
            onMultiTagPreparing: function(e) {
                const $element = e.component.element();
                const $input = $element.find(".dx-texteditor-input");

                if (!e.selectedItems || e.selectedItems.length === 0) {
                    e.cancel = true;
                    $input.attr("placeholder", "Tìm kiếm hoặc chọn nhiều...");
                    return;
                }

                if (e.selectedItems && e.selectedItems.length > 0) {
                    e.text = e.selectedItems.length + " đã chọn";
                    $input.attr("placeholder", "");
                }
            },
            itemTemplate: function(data, index, element) {
                if (data.IsAddNew) {
                    const nameField = window["DataSourceNameField_%ColumnName%"] || "Name";
                    const $item = $(`
                        <div class="d-flex align-items-center gap-2 px-2 py-2 text-primary" style="border-top: 1px dashed #dee2e6; font-weight: 600; cursor: pointer;">
                            <i class="bi bi-plus-circle fs-6"></i>
                            <span>Thêm mới: ${data[nameField]}</span>
                        </div>
                    `);
                    $item.on("dxclick", async function(e) {
                        e.stopPropagation();
                        if (Instance%ColumnName%%UID%) Instance%ColumnName%%UID%.blur();
                        await processAddNew%ColumnName%(data[nameField]);
                    });
                    return $item;
                }
                return itemTemplateString%ColumnName%%UID%(data);
            },
            onContentReady: function(e) {
                const $element = e.element;
                const $input = $element.find(".dx-texteditor-input");
                const $container = $element.find(".dx-texteditor-input-container");

                $input.attr("placeholder", "Tìm kiếm hoặc chọn nhiều...");

                // Căn giữa container
                $container.css({
                    "align-items": "center",
                    "display": "flex"
                });

                // Căn giữa các tag
                $element.find(".dx-tag").css({
                    "display": "flex",
                "align-self": "center"
                });
            },
            onValueChanged: function(e) {
                const $element = e.element;
        const $input = $element.find(".dx-texteditor-input");

                // Cập nhật placeholder theo giá trị
                if (!e.value || (Array.isArray(e.value) && e.value.length === 0)) {
                    $input.attr("placeholder", "Tìm kiếm hoặc chọn nhiều...");
                } else {
                    $input.attr("placeholder", "");
        }
            },
            onKeyDown: function(e) {
                const key = e.event.key;

                // Cho phép mũi tên lên/xuống điều hướng
                if (key === "ArrowDown" || key === "ArrowUp") {
                    // Mở dropdown nếu chưa mở
                    if (!Instance%ColumnName%%UID%.option("opened")) {
                        Instance%ColumnName%%UID%.open();
                        e.event.preventDefault();
                        return;
                    }
                    // Nếu đã mở, để DevExtreme xử lý navigation mặc định
                    return;
                }

                // Enter để chọn item đang focus
                if (key === "Enter") {
                    if (!Instance%ColumnName%%UID%.option("opened")) {
                        Instance%ColumnName%%UID%.open();
                        e.event.preventDefault();
                    }
                    return;
                }

                // Escape để đóng dropdown
                if (key === "Escape") {
                    if (Instance%ColumnName%%UID%.option("opened")) {
                        Instance%ColumnName%%UID%.close();
                        e.event.preventDefault();
                    }
                    return;
                }

                // Chỉ chặn Delete/Backspace khi input trống
                if (key === "Delete" || key === "Backspace") {
                    const $input = $(e.component.element()).find(".dx-texteditor-input");
                    const inputValue = $input.val() || "";
                    if (!inputValue || inputValue.trim() === "") {
                        e.event.preventDefault();
                    }
                }
            },
            onClosed: function(e) {
                // Tự động lưu khi đóng dropdown nếu _autoSave = true và có thay đổi
                if (_autoSave%ColumnName%%UID% && %ColumnName%%UID%_HasChanges) {
                    const currentVal = Instance%ColumnName%%UID%.option("value");
                    saveData%ColumnName%%UID%(currentVal);
                }
            },
            onSelectionChanged: function(e) {
                // Đánh dấu có thay đổi khi _autoSave = true
                if (_autoSave%ColumnName%%UID%) {
                    const newVal = e.component.option("value") || [];
                    const oldVal = %ColumnName%%UID%_InitialValue || [];
                    %ColumnName%%UID%_HasChanges = JSON.stringify(newVal.sort()) !== JSON.stringify(oldVal.sort());
                }

                // Callback
                if (typeof window["onTagBoxChanged_%ColumnName%"] === "function") {
                    window["onTagBoxChanged_%ColumnName%"](e.value, Instance%ColumnName%%UID%, e);
                }

                // Sync grid UI
                if (typeof cellInfo !== "undefined" && cellInfo && cellInfo.component) {
                    try {
                        const grid = cellInfo.component;
                        const valString = Array.isArray(e.value) ? e.value.join(",") : e.value;
                        grid.cellValue(cellInfo.rowIndex, "%ColumnName%", valString);
                    } catch (syncErr) {
                        console.warn("[Grid Sync] TagBox %ColumnName%%UID%: Không thể sync grid:", syncErr);
                    }
                }
            },
            onOptionChanged: function(e) {
                if (e.name === "searchValue") %ColumnName%%UID%CurrentSearch = (e.value || "").toString();
           }
        }).dxTagBox("instance");

        %ColumnName%%UID%_InitialValue = Instance%ColumnName%%UID%.option("value");

        if (%ColumnName%%UID%DataSourceSP && %ColumnName%%UID%DataSourceSP !== "") {
            loadDataSourceCommon("%ColumnName%", %ColumnName%%UID%DataSourceSP, function(data) {
                const idField = window["DataSourceIDField_%ColumnName%"] || "ID";

                const nameField = window["DataSourceNameField_%ColumnName%"] || "Name";
                Instance%ColumnName%%UID%.option("valueExpr", idField);
                Instance%ColumnName%%UID%.option("displayExpr", nameField);
                Instance%ColumnName%%UID%.option("dataSource", getDataSourceConfig%ColumnName%%UID%(data));
            });
        }
        '
    WHERE [Type] = 'hpaControlTagBox' AND [AutoSave] = 0 AND [ReadOnly] = 0;
END
GO