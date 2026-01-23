USE Paradise_Dev
GO

IF OBJECT_ID('[dbo].[sp_hpaControlSelectBox]') IS NULL
    EXEC ('CREATE PROCEDURE [dbo].[sp_hpaControlSelectBox] AS SELECT 1')
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
            valueExpr: "ID",
            displayExpr: "Name",
            placeholder: "Chọn...",
            disabled: true,
            stylingMode: "outlined",
            searchEnabled: true
        }).dxSelectBox("instance");

        let _initial%ColumnName%%UID% = Instance%ColumnName%%UID%.option("value");
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
        let Instance%ColumnName%%UID% = null;

        function getDataSourceConfig%ColumnName%%UID%(data) {
            return new DevExpress.data.DataSource({
                store: new DevExpress.data.CustomStore({
                    key: "ID",
                    load: function(loadOptions) {
                        // LẤY searchValue từ INSTANCE (option "text" hoặc "searchValue")
                        const searchValue = (Instance%ColumnName%%UID% && Instance%ColumnName%%UID%.option) 
                            ? (Instance%ColumnName%%UID%.option("text") || Instance%ColumnName%%UID%.option("searchValue") || "")
                            : (loadOptions.searchValue || "");
                                                
                        let result = data || [];
                        
                        if (searchValue && searchValue.trim()) {
                            result = result.filter(item => customSearch%ColumnName%(item, searchValue));
                        }
                        
                        return Promise.resolve(result);
                    },
                    byKey: function(key) {
                        return Promise.resolve((data || []).find(i => i.ID === key));
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
                            Instance%ColumnName%%UID%.option("dataSource", getDataSourceConfig%ColumnName%%UID%(data));
                            const newItem = data.find(x => x.Name === newValue.trim());
                            if (newItem) {
                                Instance%ColumnName%%UID%.option("value", newItem.ID);
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
            
            const fields = ["ID", "Name", "Code", "Description"];
            
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

        Instance%ColumnName%%UID% = $("#%UID%").dxSelectBox({
            dataSource: getDataSourceConfig%ColumnName%%UID%(window["DataSource_%ColumnName%"]),
            valueExpr: "ID",
            displayExpr: "Name",
            onOptionChanged: function(e) {},
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
                    if (!%ColumnName%%UID%IsDataLoaded && %ColumnName%%UID%DataSourceSP && %ColumnName%%UID%DataSourceSP !== "") {
                        loadDataSourceCommon("%ColumnName%", %ColumnName%%UID%DataSourceSP, function(data) {
                            %ColumnName%%UID%IsDataLoaded = true;
                            Instance%ColumnName%%UID%.option("dataSource", getDataSourceConfig%ColumnName%%UID%(data));
                        });
                    }
                }
            },
            itemTemplate: function(data, index) {
                if (data.IsAddNew) {
                    const $item = $("<div>")
                        .addClass("d-flex align-items-center gap-2 px-3 py-2 text-primary fw-bold")
                        .css({ cursor: "pointer", borderTop: "1px dashed #dee2e6" });

                    $("<i>").addClass("bi bi-plus-circle-fill fs-5").appendTo($item);
                    $("<span>").text("Thêm mới: \"" + data.Name + "\"").appendTo($item);

                    $item.on("dxclick", async function(e) {
                        e.stopPropagation();
                        if (Instance%ColumnName%%UID% && Instance%ColumnName%%UID%.blur) Instance%ColumnName%%UID%.blur();
                        await processAddNew%ColumnName%(data.Name);
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

                const displayName = (data.ID !== undefined ? data.ID + " - " : "") + (data.Name || "");
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
                $(e.component._popup.content()).parent()
                    .addClass("shadow-lg border rounded hpa-responsive")
                    .css({
                        borderRadius: "12px",
                        padding: "8px 0",
                        borderColor: "#dee2e6"
                    });
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

                // Xử lý multiple IDs nếu ColumnIDName chứa dấu phẩy
                if ("%ColumnIDName%".includes(",")) {
                    const ids = "%ColumnIDName%".split(",").map(id => id.trim());
                    ids.forEach(id => {
                        let idVal = window["currentRecordID_" + id];
                        if (typeof cellInfo !== "undefined" && cellInfo && cellInfo.data && cellInfo.data[id] !== undefined) {
                            idVal = cellInfo.data[id] || idVal;
                        }
                        currentRecordIDValue.push(idVal);
                    });
                    currentRecordID = "%ColumnIDName%".split(",").map(id => id.trim());
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
        let Instance%ColumnName%%UID% = null;

        function getDataSourceConfig%ColumnName%%UID%(data) {
            return new DevExpress.data.DataSource({
                store: new DevExpress.data.CustomStore({
                    key: "ID",
                    load: function(loadOptions) {
                        // LẤY searchValue từ INSTANCE (option "text" hoặc "searchValue")
                        const searchValue = (Instance%ColumnName%%UID% && Instance%ColumnName%%UID%.option) 
                            ? (Instance%ColumnName%%UID%.option("text") || Instance%ColumnName%%UID%.option("searchValue") || "")
                            : (loadOptions.searchValue || "");
                                                
                        let result = data || [];
                        
                        if (searchValue && searchValue.trim()) {
                            result = result.filter(item => customSearch%ColumnName%(item, searchValue));
                        }
                        
                        return Promise.resolve(result);
                    },
                    byKey: function(key) {
                        return Promise.resolve((data || []).find(i => i.ID === key));
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
                            Instance%ColumnName%%UID%.option("dataSource", getDataSourceConfig%ColumnName%%UID%(data));
                            const newItem = data.find(x => x.Name === newValue.trim());
                            if (newItem) {
                                Instance%ColumnName%%UID%.option("value", newItem.ID);
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
            
            const fields = ["ID", "Name", "Code", "Description"];
            
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

        Instance%ColumnName%%UID% = $("#%UID%").dxSelectBox({
            readOnly: _readOnly%ColumnName%%UID%,
            dataSource: getDataSourceConfig%ColumnName%%UID%(window["DataSource_%ColumnName%"]),
            valueExpr: "ID",
            displayExpr: "Name",
            onOptionChanged: function(e) {},
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
                    if (!%ColumnName%%UID%IsDataLoaded && %ColumnName%%UID%DataSourceSP && %ColumnName%%UID%DataSourceSP !== "") {
                        loadDataSourceCommon("%ColumnName%", %ColumnName%%UID%DataSourceSP, function(data) {
                            %ColumnName%%UID%IsDataLoaded = true;
                            Instance%ColumnName%%UID%.option("dataSource", getDataSourceConfig%ColumnName%%UID%(data));
                        });
                    }
                }
            },
            itemTemplate: function(data, index) {
                if (data.IsAddNew) {
                    const $item = $("<div>")
                        .addClass("d-flex align-items-center gap-2 px-3 py-2 text-primary fw-bold")
                        .css({ cursor: "pointer", borderTop: "1px dashed #dee2e6" });

                    $("<i>").addClass("bi bi-plus-circle-fill fs-5").appendTo($item);
                    $("<span>").text("Thêm mới: \"" + data.Name + "\"").appendTo($item);

                    $item.on("dxclick", async function(e) {
                        e.stopPropagation();
                        if (Instance%ColumnName%%UID% && Instance%ColumnName%%UID%.blur) Instance%ColumnName%%UID%.blur();
                        await processAddNew%ColumnName%(data.Name);
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

                const displayName = (data.ID !== undefined ? data.ID + " - " : "") + (data.Name || "");
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
                $(e.component._popup.content()).parent()
                    .addClass("shadow-lg border rounded hpa-responsive")
                    .css({
                        borderRadius: "12px",
                        padding: "8px 0",
                        borderColor: "#dee2e6"
                    });
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

                    // Xử lý multiple IDs nếu ColumnIDName chứa dấu phẩy
                    if ("%ColumnIDName%".includes(",")) {
                        const ids = "%ColumnIDName%".split(",").map(id => id.trim());
                        ids.forEach(id => {
                            let idVal = window["currentRecordID_" + id];
                            if (typeof cellInfo !== "undefined" && cellInfo && cellInfo.data && cellInfo.data[id] !== undefined) {
                                idVal = cellInfo.data[id] || idVal;
                            }
                            currentRecordIDValue.push(idVal);
                        });
                        currentRecordID = "%ColumnIDName%".split(",").map(id => id.trim());
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
        '
    WHERE [Type] = 'hpaControlSelectBox' AND [AutoSave] = 0 AND [ReadOnly] = 0;
END
GO