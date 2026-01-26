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
                store: new DevExpress.data.CustomStore({
                    key: idField,
                    load: function(loadOptions) {
                        // Ưu tiên searchValue đã được chúng ta lưu lại để tránh dính với text hiển thị
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
            const idValsJSON = JSON.stringify([[], []]);

            try {
                const json = await saveFunction(dataJSON, idValsJSON);
                const dtError = json.data[json.data.length - 1] || [];
                if (dtError.length > 0 && dtError[0].Status === "ERROR") {
                    if ("%IsAlert%" === "1") {
                        uiManager.showAlert({ type: "error", message: dtError[0]?.Message || "Lỗi thêm mới" });
                    }
                } else {
                    if ("%IsAlert%" === "1") {
                        uiManager.showAlert({ type: "success", message: "Đã thêm mới: " + newValue });
                    }

                    if (%ColumnName%%UID%DataSourceSP && %ColumnName%%UID%DataSourceSP !== "") {
                        loadDataSourceCommon("%ColumnName%", %ColumnName%%UID%DataSourceSP, function(data) {
                            const idField = window["DataSourceIDField_%ColumnName%"] || "ID";
                            const nameField = window["DataSourceNameField_%ColumnName%"] || "Name";
                            Instance%ColumnName%%UID%.option("dataSource", getDataSourceConfig%ColumnName%%UID%(data));
                            const newItem = data.find(x => x[nameField] === newValue.trim());
                            if (newItem) {
                                Instance%ColumnName%%UID%.option("value", newItem[idField]);
                                Instance%ColumnName%%UID%.option("searchValue", "");
                                %ColumnName%%UID%CurrentSearch = "";
                            }
                        });
                    }
                }
            } catch (e) {
                console.error(e);
                if ("%IsAlert%" === "1") uiManager.showAlert({ type: "error", message: "Có lỗi khi thêm mới" });
            } finally {
                Instance%ColumnName%%UID%.option("disabled", false);
                Instance%ColumnName%%UID%.close();
            }
        }

        function highlightText%ColumnName%(text, search) {
            if (!search || !text) return text;
            const regex = new RegExp("(" + search.replace(/[.*+?^${}()|[\]\\]/g, "\\$&") + ")", "gi");
            return text.replace(regex, "<mark class=\"bg-warning fw-bold px-1 rounded\">$1</mark>");
        }

        function customSearch%ColumnName%(item, searchValue) {
            if (!searchValue) return true;

            // Chuẩn hóa searchValue - loại bỏ dấu và chuyển thành lowercase
            let searchNormalized = searchValue.toLowerCase();

            if (typeof RemoveToneMarks_Js === "function") {
                searchNormalized = RemoveToneMarks_Js(searchValue).toLowerCase();
            } else {
                console.warn("[SelectBox Search Debug] RemoveToneMarks_Js is NOT defined!");
            }

            const idField = window["DataSourceIDField_%ColumnName%"] || "ID";
            const nameField = window["DataSourceNameField_%ColumnName%"] || "Name";
            const fields = [idField, nameField, "Code", "Description"];

            for (let i = 0; i < fields.length; i++) {
                const fieldValue = item[fields[i]];

                if (fieldValue) {
                    // Chuẩn hóa fieldValue - loại bỏ dấu và chuyển thành lowercase
                    let fieldNormalized = String(fieldValue).toLowerCase();

                    if (typeof RemoveToneMarks_Js === "function") {
                        fieldNormalized = RemoveToneMarks_Js(String(fieldValue)).toLowerCase();
                    }

                    const matchIndex = fieldNormalized.indexOf(searchNormalized);

                    // So sánh sau khi đã chuẩn hóa
                    if (matchIndex !== -1) {
                        return true;
                    }
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
            dropDownOptions: {
                showTitle: false,
                closeOnOutsideClick: true,
                height: "auto",
                maxHeight: 400,
                minWidth: 320,
                onShowing: function(e) {
                    if (Instance%ColumnName%%UID% && Instance%ColumnName%%UID%.option) {
                        const pendingSearch = Instance%ColumnName%%UID%.option("searchValue") || "";
                        if (pendingSearch && pendingSearch.trim()) {
                            %ColumnName%%UID%LastSearchValue = pendingSearch;
                        }
                        %ColumnName%%UID%CurrentSearch = "";
                        Instance%ColumnName%%UID%.option("searchValue", "");
                    }
                },
                onHidden: function() {
                    %ColumnName%%UID%CurrentSearch = "";
                    if (Instance%ColumnName%%UID% && Instance%ColumnName%%UID%.option) {
                        Instance%ColumnName%%UID%.option("searchValue", "");
                    }
                }
            },
            itemTemplate: function(data, index) {
                if (data.IsAddNew) {
                    const $item = $("<div>")
                        .addClass("d-flex align-items-center gap-2 px-3 py-2 text-primary fw-bold")
                        .css({ cursor: "pointer", borderTop: "1px dashed #dee2e6" });

                    const nameField = window["DataSourceNameField_%ColumnName%"] || "Name";
                    $("<i>").addClass("bi bi-plus-circle-fill fs-5").appendTo($item);
                    $("<span>").text("Thêm mới: \"" + data[nameField] + "\"").appendTo($item);

                    $item.on("dxclick", async function(e) {
                        e.stopPropagation();
                        if (Instance%ColumnName%%UID% && Instance%ColumnName%%UID%.blur) Instance%ColumnName%%UID%.blur();
                        await processAddNew%ColumnName%(data[nameField]);
                    });

                    return $item;
                }

                const $item = $("<div>")
                    .addClass("d-flex align-items-center gap-3 px-3 py-2 my-1 mx-2 rounded")
                    .css({
                        cursor: "pointer",
                        transition: "all 0.2s ease",
                        border: "1px solid transparent"
                    });

                $item.on("mouseenter", function() {
                    $(this).css({
                        transform: "translateX(4px)",
                        borderColor: "#90caf9",
                        boxShadow: "0 2px 8px rgba(0,0,0,0.08)"
                    });
                }).on("mouseleave", function() {
                    $(this).css({
                        background: "",
                        transform: "",
                        borderColor: "transparent",
                        boxShadow: ""
                    });
                });

                const $content = $("<div>").addClass("flex-fill").css("minWidth", "0");
                const searchValue = Instance%ColumnName%%UID%.option("searchValue") || "";

                const idField = window["DataSourceIDField_%ColumnName%"] || "ID";
                const nameField = window["DataSourceNameField_%ColumnName%"] || "Name";
                const displayName = (data[idField] !== undefined ? data[idField] + " - " : "") + (data[nameField] || "");
                $("<div>")
                    .addClass("fw-semibold")
                    .css({
                        fontSize: "14px",
                        lineHeight: "1.4",
                        overflow: "hidden",
                        textOverflow: "ellipsis",
                        whiteSpace: "nowrap"
                    })
                    .html(highlightText%ColumnName%(displayName, searchValue))
                    .appendTo($content);

                if (data.Description || data.Code) {
                    $("<div>")
                        .addClass("small text-muted")
                        .css({
                            fontSize: "12px",
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
                        .addClass("badge " + badgeClass + " text-uppercase")
                        .css({
                            fontSize: "9px",
                            padding: "4px 8px",
    letterSpacing: "0.5px",
                            flexShrink: "0"
                        })
                        .text(data.Status)
                        .appendTo($item);
                }

                setTimeout(() => {
                    $item.css({
  opacity: "0",
                        transform: "translateX(-10px)"
                    }).animate({
                        opacity: 1
                    }, {
           duration: 300,
                        step: function(now) {
                            $(this).css("transform", "translateX(" + (-10 + (now * 10)) + "px)");
                        },
                        delay: index * 30
                    });
                }, 10);

                return $item;
            },
            onOpened: function(e) {
                // Style dropdown
                const $popupContent = $(e.component._popup.content());
                $popupContent.parent()
                    .addClass("shadow-lg border rounded hpa-responsive")
                    .css({
                        borderRadius: "12px",
                        padding: "8px 0",
                        borderColor: "#dee2e6"
                    });

                renderLastSearchHint%ColumnName%%UID%($popupContent);
            },
            onFocusIn: function(e) {
                Instance%ColumnName%%UID%.option("showClearButton", true);
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

                const $el = $(e.element);
                $el.css({
                    transform: "scale(1.02)",
                    boxShadow: "0 0 0 3px rgba(28, 151, 94, 0.2)",
                    transition: "all 0.2s ease"
                });
                setTimeout(() => {
                    $el.css({ transform: "", boxShadow: "" });
                }, 300);

                if (typeof window["onSelectBoxChanged_%ColumnName%"] === "function") {
                    window["onSelectBoxChanged_%ColumnName%"](e.value, Instance%ColumnName%%UID%, e);
                }

                const val = e.value;
                const dataJSON = JSON.stringify(["%tableId%", ["%ColumnName%"], [val || ""]]);

                // Context-aware record IDs
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
                    console.log(dataJSON, idValsJSON)
                    const json = await saveFunction(dataJSON, idValsJSON);
                    const dtError = json.data[json.data.length - 1] || [];
                    if (dtError.length > 0 && dtError[0].Status === "ERROR") {
                        if ("%IsAlert%" === "1") {
                            uiManager.showAlert({ type: "error", message: dtError[0]?.Message || "Lưu thất bại" });
                        }
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
                        if ("%IsAlert%" === "1") {
                            uiManager.showAlert({ type: "success", message: "Lưu thành công" });
                        }
                        _initial%ColumnName%%UID% = val;
                    }
                } catch (err) {
                    if ("%IsAlert%" === "1") {
                        uiManager.showAlert({ type: "error", message: "Có lỗi xảy ra khi lưu" });
                    }
                    Instance%ColumnName%%UID%.option("value", _initial%ColumnName%%UID%);
                    console.error("SelectBox Save Error:", err);
                }
            }
        }).dxSelectBox("instance");

        let _initial%ColumnName%%UID% = Instance%ColumnName%%UID%.option("value");

        // Load data source immediately to get field names
        if (%ColumnName%%UID%DataSourceSP && %ColumnName%%UID%DataSourceSP !== "") {
            loadDataSourceCommon("%ColumnName%", %ColumnName%%UID%DataSourceSP, function(data) {
                %ColumnName%%UID%IsDataLoaded = true;

                // Get field names from API response
                const idField = window["DataSourceIDField_%ColumnName%"] || "ID";
                const nameField = window["DataSourceNameField_%ColumnName%"] || "Name";

                // Update control options with actual field names
                Instance%ColumnName%%UID%.option("valueExpr", idField);
                Instance%ColumnName%%UID%.option("displayExpr", nameField);

                // Update data source
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
          const idValsJSON = JSON.stringify([[], []]);

            try {
                const json = await saveFunction(dataJSON, idValsJSON);
                const dtError = json.data[json.data.length - 1] || [];
                if (dtError.length > 0 && dtError[0].Status === "ERROR") {
                    if ("%IsAlert%" === "1") {
                        uiManager.showAlert({ type: "error", message: dtError[0]?.Message || "Lỗi thêm mới" });
                    }
                } else {
                    if ("%IsAlert%" === "1") {
                        uiManager.showAlert({ type: "success", message: "Đã thêm mới: " + newValue });
                    }

                    if (%ColumnName%%UID%DataSourceSP && %ColumnName%%UID%DataSourceSP !== "") {
                        loadDataSourceCommon("%ColumnName%", %ColumnName%%UID%DataSourceSP, function(data) {
                            const idField = window["DataSourceIDField_%ColumnName%"] || "ID";
                            const nameField = window["DataSourceNameField_%ColumnName%"] || "Name";
                            Instance%ColumnName%%UID%.option("dataSource", getDataSourceConfig%ColumnName%%UID%(data));
                            const newItem = data.find(x => x[nameField] === newValue.trim());
                            if (newItem) {
                                Instance%ColumnName%%UID%.option("value", newItem[idField]);
                                Instance%ColumnName%%UID%.option("searchValue", "");
                                %ColumnName%%UID%CurrentSearch = "";
                            }
                        });
                    }
                }
            } catch (e) {
          console.error(e);
                if ("%IsAlert%" === "1") uiManager.showAlert({ type: "error", message: "Có lỗi khi thêm mới" });
            } finally {
                Instance%ColumnName%%UID%.option("disabled", false);
                Instance%ColumnName%%UID%.close();
            }
        }

        function highlightText%ColumnName%(text, search) {
            if (!search || !text) return text;
            const regex = new RegExp("(" + search.replace(/[.*+?^${}()|[\]\\]/g, "\\$&") + ")", "gi");
            return text.replace(regex, "<mark class=\"bg-warning fw-bold px-1 rounded\">$1</mark>");
        }

        function customSearch%ColumnName%(item, searchValue) {
            if (!searchValue) return true;

            // Chuẩn hóa searchValue - loại bỏ dấu và chuyển thành lowercase
            let searchNormalized = searchValue.toLowerCase();

            if (typeof RemoveToneMarks_Js === "function") {
                searchNormalized = RemoveToneMarks_Js(searchValue).toLowerCase();
            }

            const idField = window["DataSourceIDField_%ColumnName%"] || "ID";
            const nameField = window["DataSourceNameField_%ColumnName%"] || "Name";
            const fields = [idField, nameField, "Code", "Description"];

            for (let i = 0; i < fields.length; i++) {
                const fieldValue = item[fields[i]];

                if (fieldValue) {
                    // Chuẩn hóa fieldValue - loại bỏ dấu và chuyển thành lowercase
                    let fieldNormalized = String(fieldValue).toLowerCase();

                    if (typeof RemoveToneMarks_Js === "function") {
                        fieldNormalized = RemoveToneMarks_Js(String(fieldValue)).toLowerCase();
                    }

                    const matchIndex = fieldNormalized.indexOf(searchNormalized);

                    // So sánh sau khi đã chuẩn hóa
                    if (matchIndex !== -1) {
                        return true;
                    }
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
            dropDownOptions: {
                showTitle: false,
                closeOnOutsideClick: true,
                height: "auto",
                maxHeight: 400,
                minWidth: 320,
                onShowing: function(e) {
                    if (Instance%ColumnName%%UID% && Instance%ColumnName%%UID%.option) {
                        const pendingSearch = Instance%ColumnName%%UID%.option("searchValue") || "";
                        if (pendingSearch && pendingSearch.trim()) {
                            %ColumnName%%UID%LastSearchValue = pendingSearch;
                        }
                        %ColumnName%%UID%CurrentSearch = "";
                        Instance%ColumnName%%UID%.option("searchValue", "");
                    }
                },
                onHidden: function() {
                    %ColumnName%%UID%CurrentSearch = "";
                    if (Instance%ColumnName%%UID% && Instance%ColumnName%%UID%.option) {
                        Instance%ColumnName%%UID%.option("searchValue", "");
                    }
                }
            },
            itemTemplate: function(data, index) {
                if (data.IsAddNew) {
                    const $item = $("<div>")
                        .addClass("d-flex align-items-center gap-2 px-3 py-2 text-primary fw-bold")
                        .css({ cursor: "pointer", borderTop: "1px dashed #dee2e6" });

                    const nameField = window["DataSourceNameField_%ColumnName%"] || "Name";
                    $("<i>").addClass("bi bi-plus-circle-fill fs-5").appendTo($item);
                    $("<span>").text("Thêm mới: \"" + data[nameField] + "\"").appendTo($item);

                    $item.on("dxclick", async function(e) {
                        e.stopPropagation();
                        if (Instance%ColumnName%%UID% && Instance%ColumnName%%UID%.blur) Instance%ColumnName%%UID%.blur();
                        await processAddNew%ColumnName%(data[nameField]);
                    });

                    return $item;
                }

                const $item = $("<div>")
                    .addClass("d-flex align-items-center gap-3 px-3 py-2 my-1 mx-2 rounded")
                    .css({
                        cursor: "pointer",
                        transition: "all 0.2s ease",
                        border: "1px solid transparent"
                    });

                $item.on("mouseenter", function() {
                    $(this).css({
                        transform: "translateX(4px)",
                      borderColor: "#90caf9",
                        boxShadow: "0 2px 8px rgba(0,0,0,0.08)"
                    });
                }).on("mouseleave", function() {
             $(this).css({
                        background: "",
                        transform: "",
                        borderColor: "transparent",
                        boxShadow: ""
                    });
                });

                const $content = $("<div>").addClass("flex-fill").css("minWidth", "0");
                const searchValue = Instance%ColumnName%%UID%.option("searchValue") || "";

                const idField = window["DataSourceIDField_%ColumnName%"] || "ID";
                const nameField = window["DataSourceNameField_%ColumnName%"] || "Name";
                const displayName = (data[idField] !== undefined ? data[idField] + " - " : "") + (data[nameField] || "");
                $("<div>")
                    .addClass("fw-semibold")
                    .css({
                        fontSize: "14px",
                        lineHeight: "1.4",
                        overflow: "hidden",
                        textOverflow: "ellipsis",
                        whiteSpace: "nowrap"
                    })
                    .html(highlightText%ColumnName%(displayName, searchValue))
                    .appendTo($content);

                if (data.Description || data.Code) {
                    $("<div>")
                        .addClass("small text-muted")
                        .css({
                            fontSize: "12px",
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
                        .addClass("badge " + badgeClass + " text-uppercase")
                        .css({
          fontSize: "9px",
                            padding: "4px 8px",
                            letterSpacing: "0.5px",
                            flexShrink: "0"
                        })
                        .text(data.Status)
                        .appendTo($item);
                }

                setTimeout(() => {
                    $item.css({
                        opacity: "0",
                        transform: "translateX(-10px)"
                    }).animate({
                        opacity: 1
                    }, {
                        duration: 300,
                        step: function(now) {
                            $(this).css("transform", "translateX(" + (-10 + (now * 10)) + "px)");
                        },
                        delay: index * 30
                    });
                }, 10);

                return $item;
            },
            onOpened: function(e) {
                // Style dropdown
                const $popupContent = $(e.component._popup.content());
                $popupContent.parent()
                    .addClass("shadow-lg border rounded hpa-responsive")
                    .css({
                        borderRadius: "12px",
                        padding: "8px 0",
                        borderColor: "#dee2e6"
                    });

                renderLastSearchHint%ColumnName%%UID%($popupContent);
            },
            onFocusIn: function(e) {
                Instance%ColumnName%%UID%.option("showClearButton", true);
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

                // Feature: Check Instance AutoSave Flag
                if (_autoSave%ColumnName%%UID%) {
                     // Nếu người dùng tìm kiếm rỗng và kết quả trả về là 0/empty/null (Copy from AutoSave mode)
                    if (e.value === "" || e.value == null || e.value === 0 || e.value === "0") {
                        Instance%ColumnName%%UID%.option("value", _initial%ColumnName%%UID%);
                        return;
                    }

                    $("#%UID%").find(".dx-texteditor-input").blur();
                    if (Instance%ColumnName%%UID% && Instance%ColumnName%%UID%.blur) Instance%ColumnName%%UID%.blur();

                    const $el = $(e.element);
                    $el.css({
                        transform: "scale(1.02)",
                        boxShadow: "0 0 0 3px rgba(28, 151, 94, 0.2)",
                        transition: "all 0.2s ease"
                    });
                    setTimeout(() => {
                        $el.css({ transform: "", boxShadow: "" });
                    }, 300);

                    if (typeof window["onSelectBoxChanged_%ColumnName%"] === "function") {
                        window["onSelectBoxChanged_%ColumnName%"](e.value, Instance%ColumnName%%UID%, e);
                    }

                    const val = e.value;
                    const dataJSON = JSON.stringify(["%tableId%", ["%ColumnName%"], [val || ""]]);

                    // Context-aware record IDs
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
                            if ("%IsAlert%" === "1") {
                                uiManager.showAlert({ type: "error", message: dtError[0]?.Message || "Lưu thất bại" });
                            }
                            Instance%ColumnName%%UID%.option("value", _initial%ColumnName%%UID%);
                        } else {

                            if(%GridColumnName% != 0 && %GridColumnName% != null && %GridColumnName% != "" && window.hpaSharedGridDataSources["%GridColumnName%"])
                            {
                               try {
                                    var updateData = {};
                                    updateData["%ColumnIDName%"] = currentRecordIDValue[0];
                                    updateData["%ColumnName%"] = Instance%ColumnName%%UID%.option("value");

                                    var id2FieldName = "%ColumnIDName2%";
                                    var hasKey2 = id2FieldName && id2FieldName !== "" && id2FieldName.indexOf("%") === -1;

                                    if (hasKey2) {
                                        if (currentRecordIDValue.length > 1 && currentRecordIDValue[1] !== undefined) {
                                            updateData[id2FieldName] = currentRecordIDValue[1];
                                        }
 }

                                    // Thực hiện update shared grid
                                    window.updateSharedGridRow("%GridColumnName%", updateData);

                                    // Kiểm tra và cập nhật biến DataSource cục bộ
                                    if (typeof DataSource !== "undefined" && Array.isArray(DataSource)) {
                                        var ds;
                                        if (!hasKey2) {
                                            // Trường hợp 1 khóa
                                            ds = DataSource.filter(item => item["%ColumnIDName%"] === updateData["%ColumnIDName%"]);
                                        } else {
                                            // Trường hợp 2 khóa
                                            ds = DataSource.filter(item =>
                                                item["%ColumnIDName%"] === updateData["%ColumnIDName%"] &&
                                                item[id2FieldName] === updateData[id2FieldName]
                                            );
                                        }

                                        if (ds && ds.length > 0) {
                                            ds[0]["%ColumnName%"] = updateData["%ColumnName%"];
                                        }
                                    } // <-- Bạn thiếu dấu này
                                } catch (dsErr) {
                                    console.warn("[Grid Sync] SelectBox %ColumnName%%UID%: Không thể sync shared grid data source:", dsErr);
                                }
                            }

                            if (typeof cellInfo !== "undefined" && cellInfo && cellInfo.component) {
                                try {
         const grid = cellInfo.component;
                                    grid.cellValue(cellInfo.rowIndex, "%ColumnName%", val);
                                    grid.repaint();
                                } catch (syncErr) {
                                    console.warn("[Grid Sync] SelectBox %ColumnName%%UID%: Không thể sync grid:", syncErr);
                                }
                            }
                            if ("%IsAlert%" === "1") {
                                uiManager.showAlert({ type: "success", message: "Lưu thành công" });
                            }
                            _initial%ColumnName%%UID% = val;
                        }
                    } catch (err) {
                        if ("%IsAlert%" === "1") {
                            uiManager.showAlert({ type: "error", message: "Có lỗi xảy ra khi lưu" });
                        }
                        Instance%ColumnName%%UID%.option("value", _initial%ColumnName%%UID%);
                        console.error("SelectBox Save Error:", err);
                    }
                    return;
                }

                // Normal Manual Mode Logic (No API)
                const $el = $(e.element);
                $el.css({
                    transform: "scale(1.02)",
                    boxShadow: "0 0 0 3px rgba(28, 151, 94, 0.2)",
                    transition: "all 0.2s ease"
                });
                setTimeout(() => {
                    $el.css({ transform: "", boxShadow: "" });
                }, 300);

                if (typeof window["onSelectBoxChanged_%ColumnName%"] === "function") {
                    window["onSelectBoxChanged_%ColumnName%"](e.value, Instance%ColumnName%%UID%, e);
                }

          if (typeof cellInfo !== "undefined" && cellInfo && cellInfo.component) {
                    try {
                        const grid = cellInfo.component;
                        grid.cellValue(cellInfo.rowIndex, "%ColumnName%", e.value);
                        grid.repaint();
                    } catch (syncErr) {
                  console.warn("[Grid Sync] Không thể sync grid:", syncErr);
                    }
                }
            }
        }).dxSelectBox("instance");

        let _initial%ColumnName%%UID% = Instance%ColumnName%%UID%.option("value");

        // Load data source immediately to get field names
        if (%ColumnName%%UID%DataSourceSP && %ColumnName%%UID%DataSourceSP !== "") {
            loadDataSourceCommon("%ColumnName%", %ColumnName%%UID%DataSourceSP, function(data) {
                %ColumnName%%UID%IsDataLoaded = true;

                // Get field names from API response
                const idField = window["DataSourceIDField_%ColumnName%"] || "ID";
                const nameField = window["DataSourceNameField_%ColumnName%"] || "Name";

                // Update control options with actual field names
                Instance%ColumnName%%UID%.option("valueExpr", idField);
                Instance%ColumnName%%UID%.option("displayExpr", nameField);

                // Update data source
                Instance%ColumnName%%UID%.option("dataSource", getDataSourceConfig%ColumnName%%UID%(data));
                Instance%ColumnName%%UID%.repaint();
            });
        }
        '
    WHERE [Type] = 'hpaControlSelectBox' AND [AutoSave] = 0 AND [ReadOnly] = 0;
END
GO