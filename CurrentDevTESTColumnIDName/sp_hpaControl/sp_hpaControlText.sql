GO
if object_id('[dbo].[sp_hpaControlText]') is null
	EXEC ('CREATE PROCEDURE [dbo].[sp_hpaControlText] as select 1')
GO

ALTER PROCEDURE [dbo].[sp_hpaControlText]
    @TableName VARCHAR(256) = ''
AS
BEGIN
    -- =========================================================================
    -- hpaControlText - NORMAL MODE: READONLY
    -- =========================================================================
    UPDATE #temptable SET 
        loadUI = N'
            let Instance%ColumnName%%UID% = null;
            if (!$("head").find("#hpa-inherit-font-style").length) $("head").append("<style id=\"hpa-inherit-font-style\">.dx-widget{font-size:inherit!important;font-weight:inherit!important;line-height:inherit!important;border-radius:inherit!important}.dx-texteditor, .dx-texteditor-input{font-size:inherit!important;font-weight:inherit!important;line-height:inherit!important;box-sizing:border-box!important;}</style>");
            Instance%ColumnName%%UID% = $("#%UID%").dxTextBox({
                value: "",
                width: "100%",
                readOnly: true,
                elementAttr: { 
                    style: "border: none !important; box-shadow: none !important; background: transparent !important; padding: 2px 8px;" 
                },
                inputAttr: { 
                    style: "max-height: 100%; border: none !important; background: transparent; box-shadow: none; padding: inherit; font-size: inherit; font-weight: inherit;" 
                }
            }).dxTextBox("instance");
        '
    WHERE [Type] = 'hpaControlText' AND [ReadOnly] = 1;

    -- =========================================================================
    -- hpaControlText - NORMAL MODE: AUTOSAVE + Inline Edit + Popup Save/Cancel
    -- =========================================================================
    UPDATE #temptable SET 
        loadUI = N'
            let Instance%ColumnName%%UID% = null;
            if (!$("head").find("#hpa-inherit-font-style").length) $("head").append("<style id=\"hpa-inherit-font-style\">.dx-widget{font-size:inherit!important;font-weight:inherit!important;line-height:inherit!important;border-radius:inherit!important}.dx-texteditor, .dx-texteditor-input{font-size:inherit!important;font-weight:inherit!important;line-height:inherit!important;box-sizing:border-box!important;}</style>");
            let $container%ColumnName%%UID% = $("#%UID%");

            let %ColumnName%%UID%OriginalValue = "";
            let %ColumnName%%UID%IsEditing = false;
            let %ColumnName%%UID%TextDisplay = null;
            let %ColumnName%%UID%MouseDownInside = false;
            let _cancelingSave%ColumnName%%UID% = false;
            let _justSaved%ColumnName%%UID% = false;
            let _saving%ColumnName%%UID% = false;
            let %ColumnName%%UID%RealInstance = null;


            /* =============== Helper Functions =============== */
            function updateDisplayText%ColumnName%%UID%(val) {
                const displayVal = val || "";
                const $display = %ColumnName%%UID%TextDisplay;
                
                if (displayVal === "") {
                    $display.html(`<i style="color: #999;">Nhập dữ liệu</i>`);
                    $display.css("border-color", "#ddd");
                } else {
                    $display.text(displayVal);
                    $display.css("border-color", "transparent");
                }
            }

            function exitEdit%ColumnName%%UID%(cancel = false) {
                if (!%ColumnName%%UID%IsEditing) return;
                %ColumnName%%UID%IsEditing = false;
                %ColumnName%%UID%MouseDownInside = false;

                if (cancel) {
                    %ColumnName%%UID%RealInstance.option("value", %ColumnName%%UID%OriginalValue);
                } else {
                    %ColumnName%%UID%OriginalValue = %ColumnName%%UID%RealInstance.option("value");
                }

                $container%ColumnName%%UID%.find(".dx-texteditor").hide();
                
                // QUAN TRỌNG: Cập nhật lại display text và border
                const finalValue = %ColumnName%%UID%OriginalValue || "";
                updateDisplayText%ColumnName%%UID%(finalValue);
                
                %ColumnName%%UID%TextDisplay.show();
            }

            async function saveValue%ColumnName%%UID%() {
                if (_cancelingSave%ColumnName%%UID%) { 
                    _cancelingSave%ColumnName%%UID% = false; 
                    exitEdit%ColumnName%%UID%(true); 
                    return; 
                }

                if (_saving%ColumnName%%UID%) {
                    return;
                }
                
                const newVal = %ColumnName%%UID%RealInstance.option("value");
                
                if (newVal === %ColumnName%%UID%OriginalValue) {
                    exitEdit%ColumnName%%UID%();
                    _saving%ColumnName%%UID% = false;
                    _justSaved%ColumnName%%UID% = false;
                    return;
                }

                try {
                    _saving%ColumnName%%UID% = true;
                    
                    const dataJSON = JSON.stringify(["%tableId%", ["%ColumnName%"], [newVal]]);

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
                    const json = await saveFunction(dataJSON, idValsJSON);

                    const dtError = json.data[json.data.length - 1] || [];
                    if (dtError.length > 0 && dtError[0].Status === "ERROR") {
                        if ("%IsAlert%" === "1") {
                            uiManager.showAlert({ type: "error", message: dtError[0]?.Message || "Lưu thất bại" });
                        }
                        _saving%ColumnName%%UID% = false;
                        _justSaved%ColumnName%%UID% = false;
                        return;
                    }

                    %ColumnName%%UID%OriginalValue = newVal;
                    if ("%IsAlert%" === "1") {
                        uiManager.showAlert({ type: "success", message: "Lưu thành công" });
                    }
                    
                    exitEdit%ColumnName%%UID%();
                    if (typeof cellInfo !== "undefined" && cellInfo && cellInfo.component) {
                        try {
                            const grid = cellInfo.component;
                            grid.cellValue(cellInfo.rowIndex, "%ColumnName%", newVal);
                            grid.repaint();
                        } catch (syncErr) {
                            console.warn("[Grid Sync] Không thể sync grid:", syncErr);
                        }
                    }
                } catch (err) {
                    console.error(err);
                    uiManager.showAlert({ type: "error", message: "Có lỗi xảy ra khi lưu" });
                } finally {
                    setTimeout(function(){ 
                        _saving%ColumnName%%UID% = false;
                        _justSaved%ColumnName%%UID% = false;
                    }, 100);
                }
            }

            /* =============== Create UI =============== */
            %ColumnName%%UID%TextDisplay = $("<div>").css({
                "padding": "0 8px",
                "cursor": "text",
                "line-height": "2.5rem",
                "word-break": "break-word",
                "transition": "border-color 0.2s"
            }).appendTo($container%ColumnName%%UID%);

            updateDisplayText%ColumnName%%UID%("");

            // Hover effect
            %ColumnName%%UID%TextDisplay.hover(
                function() {
                    if (!%ColumnName%%UID%IsEditing) {
                        $(this).css("border-color", "#ddd");
                    }
                },
                function() {
                    if (!%ColumnName%%UID%IsEditing) {
                        const currentVal = %ColumnName%%UID%RealInstance.option("value") || "";
                        if (currentVal === "") {
                            $(this).css("border-color", "#ddd");
                        } else {
                            $(this).css("border-color", "transparent");
                        }
                    }
                }
            );

            %ColumnName%%UID%TextDisplay.on("click", function() {
                if (%ColumnName%%UID%IsEditing) return;
                %ColumnName%%UID%IsEditing = true;
                %ColumnName%%UID%MouseDownInside = false;
                %ColumnName%%UID%OriginalValue = %ColumnName%%UID%RealInstance.option("value");
                %ColumnName%%UID%TextDisplay.hide();

                $container%ColumnName%%UID%.find(".dx-texteditor").show();

                const $input = $container%ColumnName%%UID%.find("input");
                setTimeout(() => {
                    $input.focus();
                    const len = $input.val().length;
                    $input[0].setSelectionRange(len, len);
                }, 10);

                $input.css({
                    "border-color": "#1c975e",
                    "padding": "0 8px",
                    "max-height": "100%",
                    "cursor": "text",
                    "border-radius": "inherit !important",
                    "font-size": "inherit",
                    "font-weight": "inherit",
                    "box-sizing": "border-box"
                });
            });

            %ColumnName%%UID%RealInstance = $("<div>")
                .appendTo($container%ColumnName%%UID%)
                .dxTextBox({
                    value: "",
                    width: "100%",
                    inputAttr: { style: "max-height: 100%; line-height: 1.5; font-size: inherit; font-weight: inherit; padding: 1px 8px; box-sizing: border-box;" },
                    onKeyDown: function(e) {
                        if (!%ColumnName%%UID%IsEditing) return;

                        if (e.event.key === "Enter") {
                            e.event.preventDefault();
                            const $input = $container%ColumnName%%UID%.find("input");
                            const currentValue = $input.val();
                            %ColumnName%%UID%RealInstance.option("value", currentValue);
                            saveValue%ColumnName%%UID%();
                        }

                        if (e.event.key === "Tab") {
                            e.event.preventDefault();
                            const $input = $container%ColumnName%%UID%.find("input");
                            const currentValue = $input.val();
                            %ColumnName%%UID%RealInstance.option("value", currentValue);
                            saveValue%ColumnName%%UID%();
                        }

                        if (e.event.key === "Escape") {
                            e.event.preventDefault();
                            exitEdit%ColumnName%%UID%(true);
                        }
                    },
                    onFocusOut: function(e) {
                        if (_cancelingSave%ColumnName%%UID%) { 
                            _cancelingSave%ColumnName%%UID% = false; 
                            return; 
                        }
                        if (_justSaved%ColumnName%%UID%) { 
                            _justSaved%ColumnName%%UID% = false; 
                            return; 
                        }
                        if (_saving%ColumnName%%UID%) {
                            return;
                        }
                        
                        if (%ColumnName%%UID%IsEditing) {
                            const $input = $container%ColumnName%%UID%.find("input");
                            if ($input.val() !== %ColumnName%%UID%OriginalValue) {
                                const currentValue = $input.val();
                                %ColumnName%%UID%RealInstance.option("value", currentValue);
                                saveValue%ColumnName%%UID%();
                            } else {
                                exitEdit%ColumnName%%UID%(false);
                            }
                        }
                    }
                })
                .dxTextBox("instance");

            $container%ColumnName%%UID%.find(".dx-texteditor").hide();

            /* =============== Public API =============== */
            Instance%ColumnName%%UID% = {
                setValue: function(val) {
                    const displayVal = (val == null || val === "") ? "" : String(val);
                    %ColumnName%%UID%OriginalValue = displayVal;
                    %ColumnName%%UID%RealInstance.option("value", displayVal);
                    updateDisplayText%ColumnName%%UID%(displayVal);
                },
                getValue: function() {
                    return %ColumnName%%UID%RealInstance.option("value");
                },
                option: function(name, value) {
                    if (value !== undefined) {
                        %ColumnName%%UID%RealInstance.option(name, value);

                        if (name === "value") {
                            const val = value || "";
                            %ColumnName%%UID%OriginalValue = val;
                            updateDisplayText%ColumnName%%UID%(val);

                            if (
                                this.__cellInfo &&
                                typeof this.__cellInfo.setValue === "function" &&
                                this.__cellInfo.component
                            ) {
                                try {
                                    this.__cellInfo.setValue(val);
                                } catch (e) {
                                    console.warn("[hpaControlText] Grid sync skipped", e);
                                }
                            }
                        }
                    } else {
                        return %ColumnName%%UID%RealInstance.option(name);
                    }
                },
                repaint: function() {
                    %ColumnName%%UID%RealInstance.repaint();
                },
                _suppressValueChangeAction: function() {
                    if (%ColumnName%%UID%RealInstance._suppressValueChangeAction) {
                        %ColumnName%%UID%RealInstance._suppressValueChangeAction();
                    }
                },
                _resumeValueChangeAction: function() {
                    if (%ColumnName%%UID%RealInstance._resumeValueChangeAction) {
                        %ColumnName%%UID%RealInstance._resumeValueChangeAction();
                    }
                }
            };
        '
    WHERE [Type] = 'hpaControlText' AND [ReadOnly] = 0 AND [AutoSave] = 1;

    -- =========================================================================
    -- hpaControlText - NORMAL MODE: NO AUTOSAVE (ReadOnly=0, AutoSave=0)
    -- =========================================================================
    UPDATE #temptable SET 
        loadUI = N'
            let Instance%ColumnName%%UID% = null;
            if (!$("head").find("#hpa-inherit-font-style").length) $("head").append("<style id=\"hpa-inherit-font-style\">.dx-widget{font-size:inherit!important;font-weight:inherit!important;line-height:inherit!important;border-radius:inherit!important}.dx-texteditor, .dx-texteditor-input{font-size:inherit!important;font-weight:inherit!important;line-height:inherit!important;box-sizing:border-box!important;}</style>");
            let $container%ColumnName%%UID% = $("#%UID%");

            let _autoSave%ColumnName%%UID% = false;
            let _readOnly%ColumnName%%UID% = false;

            let %ColumnName%%UID%OriginalValue = "";
            let %ColumnName%%UID%IsEditing   = false;
            let %ColumnName%%UID%TextDisplay = null;
            let %ColumnName%%UID%MouseDownInside = false;
            let _cancelingSave%ColumnName%%UID% = false;
            let _justSaved%ColumnName%%UID% = false;
            let _saving%ColumnName%%UID% = false;
            let %ColumnName%%UID%RealInstance = null;


            /* =============== Helper Functions =============== */

            function updateDisplayText%ColumnName%%UID%(val) {
                const displayVal = val || "";
                const $display = %ColumnName%%UID%TextDisplay;
                
                if (displayVal === "") {
                    $display.html(`<i style="color: #999;">Nhập dữ liệu</i>`);
                } else {
                    $display.text(displayVal);
                }
            }

            function exitEdit%ColumnName%%UID%(cancel = false) {
                if (!%ColumnName%%UID%IsEditing) return;
                %ColumnName%%UID%IsEditing = false;
                %ColumnName%%UID%MouseDownInside = false;

                if (cancel) {
                    %ColumnName%%UID%RealInstance.option("value", %ColumnName%%UID%OriginalValue);
                } else {
                    %ColumnName%%UID%OriginalValue = %ColumnName%%UID%RealInstance.option("value");
                }

                $container%ColumnName%%UID%.find(".dx-texteditor").hide();
                
                // QUAN TRỌNG: Cập nhật lại display text và border
                const finalValue = %ColumnName%%UID%OriginalValue || "";
                updateDisplayText%ColumnName%%UID%(finalValue);
                
                %ColumnName%%UID%TextDisplay.show();
            }

            async function saveValue%ColumnName%%UID%() {
                if (_cancelingSave%ColumnName%%UID%) { 
                    _cancelingSave%ColumnName%%UID% = false; 
                    exitEdit%ColumnName%%UID%(true); 
                    return; 
                }
                
                if (_saving%ColumnName%%UID%) {
                    return;
                }
                
                const newVal = %ColumnName%%UID%RealInstance.option("value");
                
                if (newVal === %ColumnName%%UID%OriginalValue) {
                    exitEdit%ColumnName%%UID%();
                    _saving%ColumnName%%UID% = false;
                    _justSaved%ColumnName%%UID% = false;
                    return;
                }

                try {
                    _saving%ColumnName%%UID% = true;
                    
                    if (_autoSave%ColumnName%%UID%) {
                        const dataJSON = JSON.stringify(["%tableId%", ["%ColumnName%"], [newVal]]);

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
                        const json = await saveFunction(dataJSON, idValsJSON);

                        const dtError = json.data[json.data.length - 1] || [];
                        if (dtError.length > 0 && dtError[0].Status === "ERROR") {
                            if ("%IsAlert%" === "1") {
                                uiManager.showAlert({ type: "error", message: dtError[0]?.Message || "Lưu thất bại" });
                            }
                            _saving%ColumnName%%UID% = false;
                            _justSaved%ColumnName%%UID% = false;
                            return;
                        }

                        if ("%IsAlert%" === "1") {
                            uiManager.showAlert({ type: "success", message: "Lưu thành công" });
                        }
                    }
                    
                    %ColumnName%%UID%OriginalValue = newVal;
                    exitEdit%ColumnName%%UID%();

                    if (typeof cellInfo !== "undefined" && cellInfo && cellInfo.component) {
                        try {
                            const grid = cellInfo.component;
                            grid.cellValue(cellInfo.rowIndex, "%ColumnName%", newVal);
                            grid.repaint();
                        } catch (syncErr) {
                            console.warn("[Grid Sync] Không thể sync grid:", syncErr);
                        }
                    }

                } catch (err) {
                    console.warn("[%ColumnName%%UID%] Có lỗi:", err);
                } finally {
                    setTimeout(function(){ 
                        _saving%ColumnName%%UID% = false;
                        _justSaved%ColumnName%%UID% = false;
                    }, 100);
                }
            }

            /* =============== Create UI =============== */
            %ColumnName%%UID%TextDisplay = $("<div>").css({
                "padding": "0 8px",
                "cursor": "text",
                "line-height": "2.5rem",
                "word-break": "break-word",
                "border-radius": "inherit !important",
                "transition": "border-color 0.2s"
            }).appendTo($container%ColumnName%%UID%);

            updateDisplayText%ColumnName%%UID%("");

            %ColumnName%%UID%TextDisplay.hover(
                function() {
                    if (!%ColumnName%%UID%IsEditing) {
                        $(this).css("border-color", "#ddd");
                    }
                },
                function() {
                    if (!%ColumnName%%UID%IsEditing) {
                        const currentVal = %ColumnName%%UID%RealInstance.option("value") || "";
                        if (currentVal === "") {
                            $(this).css("border-color", "#ddd");
                        } else {
                            $(this).css("border-color", "transparent");
                        }
                    }
                }
            );

            %ColumnName%%UID%TextDisplay.on("click", function() {
                if (_readOnly%ColumnName%%UID%) return;

                if (%ColumnName%%UID%IsEditing) return;
                %ColumnName%%UID%IsEditing = true;
                %ColumnName%%UID%MouseDownInside = false;
                %ColumnName%%UID%OriginalValue = %ColumnName%%UID%RealInstance.option("value");
                %ColumnName%%UID%TextDisplay.hide();

                $container%ColumnName%%UID%.find(".dx-texteditor").show();

                const $input = $container%ColumnName%%UID%.find("input");
                setTimeout(() => {
                    $input.focus();
                    const len = $input.val().length;
                    $input[0].setSelectionRange(len, len);
                }, 10);

                $input.css({
                    "border-color": "#1c975e",
                    "padding": "0 8px",
                    "max-height": "100%",
                    "cursor": "text",
                    "border-radius": "inherit !important",
                    "font-size": "inherit",
                    "font-weight": "inherit",
                    "box-sizing": "border-box"
                });
            });

            %ColumnName%%UID%RealInstance = $("<div>")
                .appendTo($container%ColumnName%%UID%)
                .dxTextBox({
                    value: "",
                    width: "100%",
                    inputAttr: { style: "max-height: 100%; line-height: 1.5; font-size: inherit; font-weight: inherit; padding: 1px 8px; box-sizing: border-box;" },
                    onKeyDown: function(e) {
                        if (!%ColumnName%%UID%IsEditing) return;

                        if (e.event.key === "Enter") {
                            e.event.preventDefault();
                            const $input = $container%ColumnName%%UID%.find("input");
                            const currentValue = $input.val();
                            %ColumnName%%UID%RealInstance.option("value", currentValue);
                            saveValue%ColumnName%%UID%();
                        }

                        if (e.event.key === "Tab") {
                            e.event.preventDefault();
                            const $input = $container%ColumnName%%UID%.find("input");
                            const currentValue = $input.val();
                            %ColumnName%%UID%RealInstance.option("value", currentValue);
                            saveValue%ColumnName%%UID%();
                        }

                        if (e.event.key === "Escape") {
                            e.event.preventDefault();
                            exitEdit%ColumnName%%UID%(true);
                        }
                    },
                    onFocusOut: function(e) {
                        if (_cancelingSave%ColumnName%%UID%) { 
                            _cancelingSave%ColumnName%%UID% = false; 
                            return; 
                        }
                        if (_justSaved%ColumnName%%UID%) { 
                            _justSaved%ColumnName%%UID% = false; 
                            return; 
                        }
                        if (_saving%ColumnName%%UID%) {
                            return;
                        }
                        
                        if (%ColumnName%%UID%IsEditing) {
                            const $input = $container%ColumnName%%UID%.find("input");
                            if ($input.val() !== %ColumnName%%UID%OriginalValue) {
                                const currentValue = $input.val();
                                %ColumnName%%UID%RealInstance.option("value", currentValue);
                                saveValue%ColumnName%%UID%();
                            } else {
                                exitEdit%ColumnName%%UID%(false);
                            }
                        }
                    }
                })
                .dxTextBox("instance");

            $container%ColumnName%%UID%.find(".dx-texteditor").hide();

            /* =============== Public API =============== */
            Instance%ColumnName%%UID% = {
                setValue: function(val) {
                    const displayVal = (val == null || val === "") ? "" : String(val);
                    %ColumnName%%UID%OriginalValue = displayVal;
                    %ColumnName%%UID%RealInstance.option("value", displayVal);
                    updateDisplayText%ColumnName%%UID%(displayVal);
                },
                getValue: function() {
                    return %ColumnName%%UID%RealInstance.option("value");
                },
                option: function(name, value) {
                    if (value !== undefined) {
                        %ColumnName%%UID%RealInstance.option(name, value);

                        if (name === "value") {
                            const val = value || "";
                            %ColumnName%%UID%OriginalValue = val;
                            updateDisplayText%ColumnName%%UID%(val);

                            if (
                                this.__cellInfo &&
                                typeof this.__cellInfo.setValue === "function" &&
                                this.__cellInfo.component
                            ) {
                                try {
                                    this.__cellInfo.setValue(val);
                                } catch (e) {
                                    console.warn("[hpaControlText] Grid sync skipped", e);
                                }
                            }
                        }
                    } else {
                        return %ColumnName%%UID%RealInstance.option(name);
                    }
                },
                repaint: function() {
                    %ColumnName%%UID%RealInstance.repaint();
                },
                _suppressValueChangeAction: function() {
                    if (%ColumnName%%UID%RealInstance._suppressValueChangeAction) {
                        %ColumnName%%UID%RealInstance._suppressValueChangeAction();
                    }
                },
                _resumeValueChangeAction: function() {
                    if (%ColumnName%%UID%RealInstance._resumeValueChangeAction) {
                        %ColumnName%%UID%RealInstance._resumeValueChangeAction();
                    }
                }
            };
        '
    WHERE [Type] = 'hpaControlText' AND [ReadOnly] = 0 AND [AutoSave] = 0;
END
GO