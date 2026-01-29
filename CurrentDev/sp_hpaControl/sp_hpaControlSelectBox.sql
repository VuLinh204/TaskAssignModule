USE Paradise_Dev
GO
if object_id('[dbo].[sp_hpaControlSelectBox]') is null
	EXEC ('CREATE PROCEDURE [dbo].[sp_hpaControlSelectBox] as select 1')
GO

ALTER PROCEDURE [dbo].[sp_hpaControlSelectBox]
    @TableName VARCHAR(256) = ''
AS
BEGIN
    -- =========================================================================
    -- hpaControlSelectBox - READONLY MODE
    -- =========================================================================
    UPDATE #temptable SET
        loadUI = N'
        window["DataSource_%ColumnName%"] = window["DataSource_%ColumnName%"] || [];

        let Instance%ColumnName%%UID% = $("#%UID%").dxSelectBox({
            dataSource: window["DataSource_%ColumnName%"],
            valueExpr: window["DataSourceIDField_%ColumnName%"] || "ID",
            displayExpr: window["DataSourceNameField_%ColumnName%"] || "Name",
            placeholder: "Chọn...",
            disabled: true,
            stylingMode: "outlined",
            searchEnabled: true
        }).dxSelectBox("instance");

        let _initial%ColumnName%%UID% = Instance%ColumnName%%UID%.option("value");

        // Load data source to update field names
        if ("%DataSourceSP%" && "%DataSourceSP%".trim() !== "") {
            loadDataSourceCommon("%ColumnName%", "%DataSourceSP%", function(data) {
                const idField = window["DataSourceIDField_%ColumnName%"] || "ID";
                const nameField = window["DataSourceNameField_%ColumnName%"] || "Name";
                Instance%ColumnName%%UID%.option("valueExpr", idField);
                Instance%ColumnName%%UID%.option("displayExpr", nameField);
            });
        }
        '
    WHERE [Type] = 'hpaControlSelectBox' AND [ReadOnly] = 1;

    -- =========================================================================
    -- hpaControlSelectBox - AUTOSAVE MODE + GRID SYNC
    -- =========================================================================
    UPDATE #temptable SET
        loadUI = N'
        window["DataSource_%ColumnName%"] = window["DataSource_%ColumnName%"] || [];

        let %ColumnName%%UID%DataSourceSP = "%DataSourceSP%";
        let %ColumnName%%UID%IsLoading = false;
        let %ColumnName%%UID%IsDataLoaded = false;
        let %ColumnName%%UID%TableAddNew = "%TableAddNew%";
        let %ColumnName%%UID%ColumnAddNew = "%ColumnNameAddNew%";
        let %ColumnName%%UID%CurrentSearch = "";
        let %ColumnName%%UID%LastSearchValue = "";
        let Instance%ColumnName%%UID% = null;
        const %ColumnName%%UID%LastSearchClass = "hpa-last-search-%UID%";

        function getDataSourceConfig%ColumnName%%UID%(data) {
            const idField = window["DataSourceIDField_%ColumnName%"] || "ID";
            return new DevExpress.data.DataSource({
                paginate: false,
                store: new DevExpress.data.CustomStore({
                    key: idField,
                    load: function(loadOptions) {
                        let searchValue = %ColumnName%%UID%CurrentSearch || "";

                        if (!searchValue && loadOptions && loadOptions.searchValue) {
                            searchValue = loadOptions.searchValue;
                        }

                        if (!searchValue && Instance%ColumnName%%UID% && Instance%ColumnName%%UID%.option) {
                            searchValue = Instance%ColumnName%%UID%.option("searchValue") || "";
                        }

                        let result = data || [];

                        if (searchValue && searchValue.trim()) {
                            result = result.filter(item => customSearch%ColumnName%(item, searchValue));

                            if (%ColumnName%%UID%TableAddNew && %ColumnName%%UID%TableAddNew.trim() !== "") {
                                const nameField = window["DataSourceNameField_%ColumnName%"] || "Name";
                                const addNewItem = { IsAddNew: true };
                                addNewItem[nameField] = searchValue.trim();
                                result.push(addNewItem);
                            }
                        }

                        return Promise.resolve(result);
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

                        if (!window["DataSource_%ColumnName%"]) {
                            window["DataSource_%ColumnName%"] = [];
                        }
                        window["DataSource_%ColumnName%"].push(newItem);

                        Instance%ColumnName%%UID%.option("dataSource", getDataSourceConfig%ColumnName%%UID%(window["DataSource_%ColumnName%"]));

                        Instance%ColumnName%%UID%.option("value", newItemID);
                        Instance%ColumnName%%UID%.option("searchValue", "");
                        %ColumnName%%UID%CurrentSearch = "";
                    }
                }
            } catch (e) {
                console.error(e);
                uiManager.showAlert({ type: "error", message: "Có lỗi khi thêm mới" });
            } finally {
                Instance%ColumnName%%UID%.option("disabled", false);
                Instance%ColumnName%%UID%.close();
            }
        }

        function customSearch%ColumnName%(item, searchValue) {
            if (!searchValue) return true;
            const searchNormalized = hpaUtils.removeToneMarks(searchValue).toLowerCase();
            const idField = window["DataSourceIDField_%ColumnName%"] || "ID";
            const nameField = window["DataSourceNameField_%ColumnName%"] || "Name";
            const fields = [idField, nameField, "Code", "Description"];

            for (let i = 0; i < fields.length; i++) {
                const fieldValue = item[fields[i]];
                if (fieldValue) {
                    const fieldNormalized = hpaUtils.removeToneMarks(String(fieldValue)).toLowerCase();
                    if (fieldNormalized.indexOf(searchNormalized) !== -1) return true;
                }
            }
            return false;
        }

        function renderLastSearchHint%ColumnName%%UID%($popupContent) {
            if (!$popupContent || !$popupContent.length) return;

            const lastSearch = (%ColumnName%%UID%LastSearchValue || "").trim();
            let $hint = $popupContent.find("." + %ColumnName%%UID%LastSearchClass);

            if (!lastSearch) {
                if ($hint.length) {
                    $hint.remove();
                }
                return;
            }

            if (!$hint.length) {
                $hint = $("<div>")
                    .addClass(%ColumnName%%UID%LastSearchClass + " d-flex align-items-center justify-content-between gap-2 px-3 py-2 border-bottom")
                    .css({
                        fontSize: "12px",
                        background: "#f8f9fa"
                    })
                    .prependTo($popupContent);

                $("<span>")
                    .addClass("flex-fill text-muted text-truncate")
                    .appendTo($hint);

                $("<button>")
                    .attr("type", "button")
                    .addClass("btn btn-link p-0 text-decoration-none fw-semibold")
                    .text("Áp dụng lại")
                    .on("dxclick", function(ev) {
                        ev.preventDefault();
                        ev.stopPropagation();
                        if (!%ColumnName%%UID%LastSearchValue) return;
                        %ColumnName%%UID%CurrentSearch = %ColumnName%%UID%LastSearchValue;
                        Instance%ColumnName%%UID%.option("searchValue", %ColumnName%%UID%LastSearchValue);
                        const $input = $("#%UID%").find(".dx-texteditor-input");
                        if ($input && $input.length) {
                            setTimeout(function() { $input.focus(); }, 0);
                        }
                    })
                    .appendTo($hint);
            }

            $hint.find("span").text("Lần tìm trước: \"" + lastSearch + "\"");
        }

        Instance%ColumnName%%UID% = $("#%UID%").dxSelectBox({
            dataSource: getDataSourceConfig%ColumnName%%UID%(window["DataSource_%ColumnName%"]),
            valueExpr: window["DataSourceIDField_%ColumnName%"] || "ID",
            displayExpr: window["DataSourceNameField_%ColumnName%"] || "Name",
            onOptionChanged: function(e) {
                if (!e || !e.component) return;
                if (e.name === "searchValue") {
                    const newVal = (e.value || "").toString();
                    %ColumnName%%UID%CurrentSearch = newVal;
                    if (newVal && newVal.trim()) {
                        %ColumnName%%UID%LastSearchValue = newVal;
                    }

                    if (e.component.option("opened") && e.component._popup) {
                        renderLastSearchHint%ColumnName%%UID%($(e.component._popup.content()));
                    }
                }
            },
            onContentReady: function(e) {},
            placeholder: "Tìm kiếm hoặc chọn...",
            searchEnabled: true,
            searchTimeout: 300,
            minSearchLength: 0,
            showDataBeforeSearch: true,
            showClearButton: false,
            stylingMode: "outlined",
            itemTemplate: function(data, index) {
                if (data.IsAddNew) {
                    const nameField = window["DataSourceNameField_%ColumnName%"] || "Name";
                    const $item = $("<div>")
                        .addClass("d-flex align-items-center gap-2 px-3 py-2 text-primary")
                        .css({ cursor: "pointer", borderTop: "1px dashed #dee2e6", fontWeight: "600" });

                    $("<i>").addClass("bi bi-plus-circle fs-6").appendTo($item);
                    $("<span>").text("Thêm mới: \"" + data[nameField] + "\"").appendTo($item);

                    $item.on("dxclick", async function(e) {
                        e.stopPropagation();
                        if (Instance%ColumnName%%UID% && Instance%ColumnName%%UID%.blur) Instance%ColumnName%%UID%.blur();
                        await processAddNew%ColumnName%(data[nameField]);
                    });

                    return $item;
                }

                const idField = window["DataSourceIDField_%ColumnName%"] || "ID";
                const nameField = window["DataSourceNameField_%ColumnName%"] || "Name";
                const searchValue = Instance%ColumnName%%UID%.option("searchValue") || "";

                const $item = $("<div>")
                    .addClass("d-flex align-items-center gap-2 px-3 py-2 border-bottom border-light")
                    .css({ cursor: "pointer" });

                const $content = $("<div>").addClass("flex-fill").css("minWidth", "0");

                const displayName = (data[idField] !== undefined ? data[idField] + " - " : "") + (data[nameField] || "");
                $("<div>")
                    .addClass("fw-normal text-body")
                    .css({
                        fontSize: "13px",
                        overflow: "hidden",
                        textOverflow: "ellipsis",
                        whiteSpace: "nowrap"
                    })
                    .html(hpaUtils.highlightText(displayName, searchValue))
                    .appendTo($content);

                if (data.Description || data.Code) {
                    $("<div>")
                        .addClass("text-muted")
                        .css({
                            fontSize: "11px",
                            overflow: "hidden",
                            textOverflow: "ellipsis",
                            whiteSpace: "nowrap"
                        })
                        .text(data.Code || data.Description)
                        .appendTo($content);
                }

                $content.appendTo($item);

                if (data.Status) {
                    const badgeClass = data.Status === "Active" ? "bg-success" : "bg-secondary";
                    $("<span>")
                        .addClass("badge " + badgeClass)
                        .css({
                            fontSize: "9px",
                            padding: "3px 6px",
                            borderRadius: "4px",
                            opacity: "0.8"
                        })
                        .text(data.Status)
                        .appendTo($item);
                }

                return $item;
            },
            onOpened: function(e) {
                const $popupContent = $(e.component._popup.content());
                $popupContent.parent()
                    .addClass("shadow-lg border rounded")
                    .css({
                        borderRadius: "8px",
                        padding: "4px 0",
                        borderColor: "#dee2e6"
                    });

                renderLastSearchHint%ColumnName%%UID%($popupContent);

                // Enable keyboard navigation
                setTimeout(function() {
                    if (e.component && e.component._list) {
                        const listInstance = e.component._list;
                        listInstance.option("focusStateEnabled", true);
                        listInstance.option("hoverStateEnabled", true);
                        listInstance.option("activeStateEnabled", true);
                        listInstance.focus();
                    }

                    // Inject CSS cho focus/hover states
                    if (!$("#selectbox-focus-style-%UID%").length) {
                        const focusCSS = `
                            <style id="selectbox-focus-style-%UID%">
                                /* Hover state */
                                .dx-selectbox-popup-wrapper .dx-list-item:hover {
                                    background-color: #f5f5f5 !important;
                                }

                                /* Focus state khi dùng keyboard */
                                .dx-selectbox-popup-wrapper .dx-list-item.dx-state-focused {
                                    background-color: #f5f5f5 !important;
                                }

                                /* Selected item */
                                .dx-selectbox-popup-wrapper .dx-list-item.dx-list-item-selected {
                                    background-color: #e8f5e9 !important;
                                }

                                /* Focus + Selected */
                                .dx-selectbox-popup-wrapper .dx-list-item.dx-state-focused.dx-list-item-selected {
                                    background-color: #c8e6c9 !important;
                                }
                            </style>
                        `;
                        $("head").append(focusCSS);
                    }
                }, 100);
            },
            onFocusIn: function(e) {
                Instance%ColumnName%%UID%.option("showClearButton", true);

                // Clear search và reset data source
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
                }, 100);
            },
            dropDownOptions: {
                showTitle: false,
                closeOnOutsideClick: true,
                height: "auto",
                maxHeight: 400,
                minWidth: 320,
                onShowing: function(e) {
                    // Clear search trước khi mở dropdown
                    %ColumnName%%UID%CurrentSearch = "";
                    if (Instance%ColumnName%%UID% && Instance%ColumnName%%UID%.option) {
                        Instance%ColumnName%%UID%.option("searchValue", "");
                    }

                    // Reload để hiển thị full list
                    if (Instance%ColumnName%%UID%.getDataSource()) {
                        Instance%ColumnName%%UID%.getDataSource().reload();
                    }
                },
                onHidden: function() {
                    %ColumnName%%UID%CurrentSearch = "";
                    if (Instance%ColumnName%%UID% && Instance%ColumnName%%UID%.option) {
                        Instance%ColumnName%%UID%.option("searchValue", "");
                    }
                }
            },
            onFocusOut: function(e) {
                Instance%ColumnName%%UID%.option("showClearButton", false);
            },
            onKeyDown: function(e) {
                if (e.key === "Enter" || e.key === "Tab") {
                    Instance%ColumnName%%UID%.option("showClearButton", false);
                }
            },
            onValueChanged: async function(e) {
                if (!e.event) return;
                if (e.value === "" || e.value == null || e.value === 0 || e.value === "0") {
                    Instance%ColumnName%%UID%.option("value", _initial%ColumnName%%UID%);
                    return;
                }

                $("#%UID%").find(".dx-texteditor-input").blur();
                if (Instance%ColumnName%%UID% && Instance%ColumnName%%UID%.blur) Instance%ColumnName%%UID%.blur();

                if (typeof window["onSelectBoxChanged_%ColumnName%"] === "function") {
                    window["onSelectBoxChanged_%ColumnName%"](e.value, Instance%ColumnName%%UID%, e);
                }

                const val = e.value;
                const dataJSON = JSON.stringify(["%tableId%", ["%ColumnName%"], [val || ""]]);
				
                let id1 = currentRecordID_%ColumnIDName%;
                if (typeof cellInfo !== "undefined" && cellInfo && cellInfo.data) {
					id1 = cellInfo.data["%ColumnIDName%"] || id1;
                }
                let currentRecordIDValue = [id1];
                let currentRecordID = ["%ColumnIDName%"];

                if ("%ColumnIDName2%" && "%ColumnIDName2%".trim() !== "") {
                    let id2 = currentRecordID_%ColumnIDName2%;
                    if (typeof cellInfo !== "undefined" && cellInfo && cellInfo.data) {
                        id2 = cellInfo.data["%ColumnIDName2%"] || id2;
                    }
                    currentRecordIDValue.push(id2);
                    currentRecordID.push("%ColumnIDName2%");
                }
				console.log(currentRecordIDValue)
				console.log(currentRecordID)
                const idValsJSON = JSON.stringify([currentRecordIDValue, currentRecordID]);

                try {
					console.log(idValsJSON)
					console.log(dataJSON)
                    const json = await saveFunction(dataJSON, idValsJSON);
                    const dtError = json.data[json.data.length - 1] || [];
                    if (dtError.length > 0 && dtError[0].Status === "ERROR") {
                        uiManager.showAlert({ type: "error", message: dtError[0]?.Message || "%SaveErrorMessage%" });
                        Instance%ColumnName%%UID%.option("value", _initial%ColumnName%%UID%);
                    } else {
                        if (typeof cellInfo !== "undefined" && cellInfo && cellInfo.component) {
                            try {
                                const grid = cellInfo.component;
                                grid.cellValue(cellInfo.rowIndex, "%ColumnName%", val);
                                grid.repaint();
                            } catch (syncErr) {
                                console.warn("[Grid Sync] SelectBox %ColumnName%%UID%: Không thể sync grid:", syncErr);
                            }
                        }
                        _initial%ColumnName%%UID% = val;
                    }
                } catch (err) {
                    uiManager.showAlert({ type: "error", message: "Có lỗi xảy ra khi lưu" });
                    Instance%ColumnName%%UID%.option("value", _initial%ColumnName%%UID%);
                    console.error("SelectBox Save Error:", err);
                }
            }
        }).dxSelectBox("instance");

        let _initial%ColumnName%%UID% = Instance%ColumnName%%UID%.option("value");

        if (%ColumnName%%UID%DataSourceSP && %ColumnName%%UID%DataSourceSP !== "") {
            loadDataSourceCommon("%ColumnName%", %ColumnName%%UID%DataSourceSP, function(data) {
                %ColumnName%%UID%IsDataLoaded = true;

                const idField = window["DataSourceIDField_%ColumnName%"] || "ID";
                const nameField = window["DataSourceNameField_%ColumnName%"] || "Name";

                Instance%ColumnName%%UID%.option("valueExpr", idField);
                Instance%ColumnName%%UID%.option("displayExpr", nameField);

                Instance%ColumnName%%UID%.option("dataSource", getDataSourceConfig%ColumnName%%UID%(data));
                Instance%ColumnName%%UID%.repaint();
            });
        }
        '
    WHERE [Type] = 'hpaControlSelectBox' AND [AutoSave] = 1 AND [ReadOnly] = 0;

    -- =========================================================================
    -- hpaControlSelectBox - MANUAL MODE (No AutoSave)
    -- =========================================================================
    UPDATE #temptable SET
        loadUI = N'
        window["DataSource_%ColumnName%"] = window["DataSource_%ColumnName%"] || [];

        let %ColumnName%%UID%DataSourceSP = "%DataSourceSP%";
        let %ColumnName%%UID%IsLoading = false;
        let %ColumnName%%UID%IsDataLoaded = false;
        let _autoSave%ColumnName%%UID% = false;
        let _readOnly%ColumnName%%UID% = false;
        let %ColumnName%%UID%TableAddNew = "%TableAddNew%";
        let %ColumnName%%UID%ColumnAddNew = "%ColumnNameAddNew%";
        let %ColumnName%%UID%CurrentSearch = "";
        let %ColumnName%%UID%LastSearchValue = "";
        let Instance%ColumnName%%UID% = null;

        const %ColumnName%%UID%LastSearchClass = "hpa-last-search-%UID%";

        function getDataSourceConfig%ColumnName%%UID%(data) {
            const idField = window["DataSourceIDField_%ColumnName%"] || "ID";
            return new DevExpress.data.DataSource({
                paginate: false,
                store: new DevExpress.data.CustomStore({
                    key: idField,
                    load: function(loadOptions) {
                        let searchValue = %ColumnName%%UID%CurrentSearch || "";

                        if (!searchValue && loadOptions && loadOptions.searchValue) {
                            searchValue = loadOptions.searchValue;
                        }

                        if (!searchValue && Instance%ColumnName%%UID% && Instance%ColumnName%%UID%.option) {
                            searchValue = Instance%ColumnName%%UID%.option("searchValue") || "";
                        }

                        let result = data || [];

                        if (searchValue && searchValue.trim()) {
                            result = result.filter(item => customSearch%ColumnName%(item, searchValue));

                            if (%ColumnName%%UID%TableAddNew && %ColumnName%%UID%TableAddNew.trim() !== "") {
                                const nameField = window["DataSourceNameField_%ColumnName%"] || "Name";
                                const addNewItem = { IsAddNew: true };
                                addNewItem[nameField] = searchValue.trim();
                                result.push(addNewItem);
                            }
                        }

                        return Promise.resolve(result);
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

                        if (!window["DataSource_%ColumnName%"]) {
                            window["DataSource_%ColumnName%"] = [];
                        }
                        window["DataSource_%ColumnName%"].push(newItem);

                        Instance%ColumnName%%UID%.option("dataSource", getDataSourceConfig%ColumnName%%UID%(window["DataSource_%ColumnName%"]));

                        Instance%ColumnName%%UID%.option("value", newItemID);
                        Instance%ColumnName%%UID%.option("searchValue", "");
                        %ColumnName%%UID%CurrentSearch = "";
                    }
                }
            } catch (e) {
                console.error(e);
                uiManager.showAlert({ type: "error", message: "Có lỗi khi thêm mới" });
   } finally {
                Instance%ColumnName%%UID%.option("disabled", false);
                Instance%ColumnName%%UID%.close();
            }
        }

        function customSearch%ColumnName%(item, searchValue) {
            if (!searchValue) return true;
            const searchNormalized = hpaUtils.removeToneMarks(searchValue).toLowerCase();
            const idField = window["DataSourceIDField_%ColumnName%"] || "ID";
            const nameField = window["DataSourceNameField_%ColumnName%"] || "Name";
            const fields = [idField, nameField, "Code", "Description"];

            for (let i = 0; i < fields.length; i++) {
                const fieldValue = item[fields[i]];
                if (fieldValue) {
                    const fieldNormalized = hpaUtils.removeToneMarks(String(fieldValue)).toLowerCase();
                    if (fieldNormalized.indexOf(searchNormalized) !== -1) return true;
                }
            }
            return false;
        }

        function renderLastSearchHint%ColumnName%%UID%($popupContent) {
            if (!$popupContent || !$popupContent.length) return;

            const lastSearch = (%ColumnName%%UID%LastSearchValue || "").trim();
            let $hint = $popupContent.find("." + %ColumnName%%UID%LastSearchClass);

            if (!lastSearch) {
                if ($hint.length) {
                    $hint.remove();
                }
                return;
            }

            if (!$hint.length) {
                $hint = $("<div>")
                    .addClass(%ColumnName%%UID%LastSearchClass + " d-flex align-items-center justify-content-between gap-2 px-3 py-2 border-bottom")
                    .css({
                        fontSize: "12px",
                        background: "#f8f9fa"
                    })
                    .prependTo($popupContent);

                $("<span>")
                    .addClass("flex-fill text-muted text-truncate")
                    .appendTo($hint);

                $("<button>")
                    .attr("type", "button")
                    .addClass("btn btn-link p-0 text-decoration-none fw-semibold")
                    .text("Áp dụng lại")
                    .on("dxclick", function(ev) {
                        ev.preventDefault();
                        ev.stopPropagation();
                        if (!%ColumnName%%UID%LastSearchValue) return;
                        %ColumnName%%UID%CurrentSearch = %ColumnName%%UID%LastSearchValue;
                        Instance%ColumnName%%UID%.option("searchValue", %ColumnName%%UID%LastSearchValue);
                        const $input = $("#%UID%").find(".dx-texteditor-input");
                        if ($input && $input.length) {
                            setTimeout(function() { $input.focus(); }, 0);
                        }
                    })
                    .appendTo($hint);
            }

            $hint.find("span").text("Lần tìm trước: \"" + lastSearch + "\"");
        }

        Instance%ColumnName%%UID% = $("#%UID%").dxSelectBox({
            readOnly: _readOnly%ColumnName%%UID%,
            dataSource: getDataSourceConfig%ColumnName%%UID%(window["DataSource_%ColumnName%"]),
            valueExpr: window["DataSourceIDField_%ColumnName%"] || "ID",
            displayExpr: window["DataSourceNameField_%ColumnName%"] || "Name",
            onOptionChanged: function(e) {
                if (!e || !e.component) return;
                if (e.name === "searchValue") {
                    const newVal = (e.value || "").toString();
                    %ColumnName%%UID%CurrentSearch = newVal;
                    if (newVal && newVal.trim()) {
                        %ColumnName%%UID%LastSearchValue = newVal;
                    }

                    if (e.component.option("opened") && e.component._popup) {
                        renderLastSearchHint%ColumnName%%UID%($(e.component._popup.content()));
                    }
                }
            },
            onContentReady: function(e) {},
            placeholder: "Tìm kiếm hoặc chọn...",
            searchEnabled: true,
            searchTimeout: 300,
            minSearchLength: 0,
            showDataBeforeSearch: true,
            showClearButton: false,
            stylingMode: "outlined",
            itemTemplate: function(data, index) {
                if (data.IsAddNew) {
                    const nameField = window["DataSourceNameField_%ColumnName%"] || "Name";
                    const $item = $("<div>")
                        .addClass("d-flex align-items-center gap-2 px-3 py-2 text-primary")
                        .css({ cursor: "pointer", borderTop: "1px dashed #dee2e6", fontWeight: "600" });

                    $("<i>").addClass("bi bi-plus-circle fs-6").appendTo($item);
                    $("<span>").text("Thêm mới: \"" + data[nameField] + "\"").appendTo($item);

                    $item.on("dxclick", async function(e) {
                        e.stopPropagation();
                        if (Instance%ColumnName%%UID% && Instance%ColumnName%%UID%.blur) Instance%ColumnName%%UID%.blur();
                        await processAddNew%ColumnName%(data[nameField]);
                    });

                    return $item;
                }

                const idField = window["DataSourceIDField_%ColumnName%"] || "ID";
                const nameField = window["DataSourceNameField_%ColumnName%"] || "Name";
                const searchValue = Instance%ColumnName%%UID%.option("searchValue") || "";

                const $item = $("<div>")
                    .addClass("d-flex align-items-center gap-2 px-3 py-2 border-bottom border-light")
                    .css({ cursor: "pointer" });

                const $content = $("<div>").addClass("flex-fill").css("minWidth", "0");

                const displayName = (data[idField] !== undefined ? data[idField] + " - " : "") + (data[nameField] || "");
                $("<div>")
                    .addClass("fw-normal text-body")
                    .css({
                        fontSize: "13px",
                        overflow: "hidden",
                        textOverflow: "ellipsis",
                        whiteSpace: "nowrap"
                    })
                    .html(hpaUtils.highlightText(displayName, searchValue))
                    .appendTo($content);

                if (data.Description || data.Code) {
                    $("<div>")
                        .addClass("text-muted")
                        .css({
                            fontSize: "11px",
                            overflow: "hidden",
                            textOverflow: "ellipsis",
                            whiteSpace: "nowrap"
                        })
                        .text(data.Code || data.Description)
                        .appendTo($content);
                }

                $content.appendTo($item);

                if (data.Status) {
                    const badgeClass = data.Status === "Active" ? "bg-success" : "bg-secondary";
                    $("<span>")
                        .addClass("badge " + badgeClass)
                        .css({
                            fontSize: "9px",
                            padding: "3px 6px",
                            borderRadius: "4px",
                            opacity: "0.8"
                        })
                        .text(data.Status)
                        .appendTo($item);
                }

                return $item;
            },
            onOpened: function(e) {
                const $popupContent = $(e.component._popup.content());
                $popupContent.parent()
                    .addClass("shadow-lg border rounded")
                   .css({
                        borderRadius: "8px",
                padding: "4px 0",
                        borderColor: "#dee2e6"
                    });

                renderLastSearchHint%ColumnName%%UID%($popupContent);

                // Enable keyboard navigation
                setTimeout(function() {
                    if (e.component && e.component._list) {
                        const listInstance = e.component._list;
                        listInstance.option("focusStateEnabled", true);
                        listInstance.option("hoverStateEnabled", true);
                        listInstance.option("activeStateEnabled", true);
                        listInstance.focus();
                    }

                    // Inject CSS cho focus/hover states
                    if (!$("#selectbox-focus-style-%UID%").length) {
                        const focusCSS = `
                            <style id="selectbox-focus-style-%UID%">
                                /* Hover state */
                                .dx-selectbox-popup-wrapper .dx-list-item:hover {
                                    background-color: #f5f5f5 !important;
                                }

                                /* Focus state khi dùng keyboard */
                                .dx-selectbox-popup-wrapper .dx-list-item.dx-state-focused {
                                    background-color: #f5f5f5 !important;
                                }

                                /* Selected item */
                                .dx-selectbox-popup-wrapper .dx-list-item.dx-list-item-selected {
                                    background-color: #e8f5e9 !important;
                                }

                                /* Focus + Selected */
                                .dx-selectbox-popup-wrapper .dx-list-item.dx-state-focused.dx-list-item-selected {
                                    background-color: #c8e6c9 !important;
                                }
                            </style>
                        `;
                        $("head").append(focusCSS);
                    }
                }, 100);
            },
            onFocusIn: function(e) {
                Instance%ColumnName%%UID%.option("showClearButton", true);

                // Clear search và reset data source
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
                }, 100);
            },
            dropDownOptions: {
                showTitle: false,
                closeOnOutsideClick: true,
                height: "auto",
                maxHeight: 400,
                minWidth: 320,
                onShowing: function(e) {
                    // Clear search trước khi mở dropdown
                    %ColumnName%%UID%CurrentSearch = "";
                    if (Instance%ColumnName%%UID% && Instance%ColumnName%%UID%.option) {
                        Instance%ColumnName%%UID%.option("searchValue", "");
                    }

                    // Reload để hiển thị full list
                    if (Instance%ColumnName%%UID%.getDataSource()) {
                        Instance%ColumnName%%UID%.getDataSource().reload();
                    }
                },
                onHidden: function() {
                    %ColumnName%%UID%CurrentSearch = "";
                    if (Instance%ColumnName%%UID% && Instance%ColumnName%%UID%.option) {
                        Instance%ColumnName%%UID%.option("searchValue", "");
                    }
                }
            },
            onFocusOut: function(e) {
                Instance%ColumnName%%UID%.option("showClearButton", false);
            },
            onKeyDown: function(e) {
                if (e.key === "Enter" || e.key === "Tab") {
                    Instance%ColumnName%%UID%.option("showClearButton", false);
                }
            },
            onValueChanged: async function(e) {
                if (!e.event) return;

                if (_autoSave%ColumnName%%UID%) {
                    if (e.value === "" || e.value == null || e.value === 0 || e.value === "0") {
                        Instance%ColumnName%%UID%.option("value", _initial%ColumnName%%UID%);
                        return;
                    }

                    $("#%UID%").find(".dx-texteditor-input").blur();
                    if (Instance%ColumnName%%UID% && Instance%ColumnName%%UID%.blur) Instance%ColumnName%%UID%.blur();

                    if (typeof window["onSelectBoxChanged_%ColumnName%"] === "function") {
                        window["onSelectBoxChanged_%ColumnName%"](e.value, Instance%ColumnName%%UID%, e);
                    }

                    const val = e.value;
                    const dataJSON = JSON.stringify(["%tableId%", ["%ColumnName%"], [val || ""]]);

                    let id1 = currentRecordID_%ColumnIDName%;
                    if (typeof cellInfo !== "undefined" && cellInfo && cellInfo.data) {
                        id1 = cellInfo.data["%ColumnIDName%"] || id1;
                    }
                    let currentRecordIDValue = [id1];
                    let currentRecordID = ["%ColumnIDName%"];

                    if ("%ColumnIDName2%" && "%ColumnIDName2%".trim() !== "") {
                        let id2 = currentRecordID_%ColumnIDName2%;
                        if (typeof cellInfo !== "undefined" && cellInfo && cellInfo.data) {
                            id2 = cellInfo.data["%ColumnIDName2%"] || id2;
                        }
                        currentRecordIDValue.push(id2);
                        currentRecordID.push("%ColumnIDName2%");
                    }
                    const idValsJSON = JSON.stringify([currentRecordIDValue, currentRecordID]);

                    try {
                        const json = await saveFunction(dataJSON, idValsJSON);
                        const dtError = json.data[json.data.length - 1] || [];
                        if (dtError.length > 0 && dtError[0].Status === "ERROR") {
                            uiManager.showAlert({ type: "error", message: dtError[0]?.Message || "%SaveErrorMessage%" });
                            Instance%ColumnName%%UID%.option("value", _initial%ColumnName%%UID%);
                        } else {
                            if (typeof cellInfo !== "undefined" && cellInfo && cellInfo.component) {
                                try {
                                    const grid = cellInfo.component;
                                    grid.cellValue(cellInfo.rowIndex, "%ColumnName%", val);
                                    grid.repaint();
                                } catch (syncErr) {
                                    console.warn("[Grid Sync] SelectBox %ColumnName%%UID%: Không thể sync grid:", syncErr);
                                }
                            }
                            _initial%ColumnName%%UID% = val;
                        }
                    } catch (err) {
                        uiManager.showAlert({ type: "error", message: "Có lỗi xảy ra khi lưu" });
                        Instance%ColumnName%%UID%.option("value", _initial%ColumnName%%UID%);
                        console.error("SelectBox Save Error:", err);
                    }
                }
            }
        }).dxSelectBox("instance");

        if (%ColumnName%%UID%DataSourceSP && %ColumnName%%UID%DataSourceSP !== "") {
            loadDataSourceCommon("%ColumnName%", %ColumnName%%UID%DataSourceSP, function(data) {
                %ColumnName%%UID%IsDataLoaded = true;

                const idField = window["DataSourceIDField_%ColumnName%"] || "ID";
                const nameField = window["DataSourceNameField_%ColumnName%"] || "Name";

                Instance%ColumnName%%UID%.option("valueExpr", idField);
                Instance%ColumnName%%UID%.option("displayExpr", nameField);

                Instance%ColumnName%%UID%.option("dataSource", getDataSourceConfig%ColumnName%%UID%(data));
                Instance%ColumnName%%UID%.repaint();
            });
        }
        '
    WHERE [Type] = 'hpaControlSelectBox' AND [AutoSave] = 0 AND [ReadOnly] = 0;
END
GO