GO
if object_id('[dbo].[sp_hpaControlTextArea]') is null
	EXEC ('CREATE PROCEDURE [dbo].[sp_hpaControlTextArea] as select 1')
GO

ALTER PROCEDURE [dbo].[sp_hpaControlTextArea]
    @TableName VARCHAR(256) = ''
AS
BEGIN
    -- =========================================================================
    -- READONLY MODE
    -- =========================================================================
    UPDATE #temptable SET 
        loadUI = N'
            /* Thêm CSS cho textarea height 100% */
            if (!$("head").find("#hpa-textarea-height-style").length) {
                $("head").append("<style id=\"hpa-textarea-height-style\">textarea.dx-texteditor-input { height: 100% !important; }</style>");
            }
            
            let Instance%ColumnName%%UID% = null;
            Instance%ColumnName%%UID% = $("#%UID%").dxTextArea({
                value: "",
                width: "100%",
                height: 80,
                readOnly: true,
                inputAttr: { class: "form-control form-control-sm dx-texteditor-input", style: "font-size: 14px; padding: 6px;" }
            }).dxTextArea("instance");
        '
    WHERE [Type] = 'hpaControlTextArea' AND [ReadOnly] = 1;

    -- =========================================================================
    -- EDIT MODE (INLINE + POPUP + AUTOSAVE)
    -- =========================================================================
    UPDATE #temptable SET 
        loadUI = N'
            /* Thêm CSS cho textarea height 100% */
            if (!$("head").find("#hpa-textarea-height-style").length) {
                $("head").append("<style id=\"hpa-textarea-height-style\">textarea.dx-texteditor-input { height: 100% !important; }</style>");
            }
            
            let $container%ColumnName%%UID% = $("#%UID%");
            let Instance%ColumnName%%UID% = null;

            let %ColumnName%%UID%OriginalValue = "";
            let %ColumnName%%UID%IsEditing = false;
            let %ColumnName%%UID%TextDisplay = null;
            let %ColumnName%%UID%MouseDownInside = false;
            let _cancelingSave%ColumnName%%UID% = false;
            let _justSaved%ColumnName%%UID% = false;
            let _saving%ColumnName%%UID% = false;
            let %ColumnName%%UID%RealInstance = null;

            /* =============== Helper Function =============== */
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
                
                if (cancel) {
                    // Rollback về giá trị gốc TRƯỚC KHI tắt editing mode
                    %ColumnName%%UID%RealInstance.option("value", %ColumnName%%UID%OriginalValue);
                    // Cập nhật textarea DOM ngay lập tức
                    const $ta = $container%ColumnName%%UID%.find("textarea");
                    $ta.val(%ColumnName%%UID%OriginalValue);
                } else {
                    // Lưu giá trị hiện tại làm giá trị gốc mới
                    %ColumnName%%UID%OriginalValue = %ColumnName%%UID%RealInstance.option("value");
                }
                
                %ColumnName%%UID%IsEditing = false;
                %ColumnName%%UID%MouseDownInside = false;

                $container%ColumnName%%UID%.find(".dx-texteditor").hide();
                
                // Cập nhật display text với placeholder
                const finalValue = %ColumnName%%UID%OriginalValue || "";
                updateDisplayText%ColumnName%%UID%(finalValue);
                
                %ColumnName%%UID%TextDisplay.show();
            }

            async function saveValue%ColumnName%%UID%() {
                // Nếu đang cancel thì rollback và thoát
                if (_cancelingSave%ColumnName%%UID%) { 
                    _cancelingSave%ColumnName%%UID% = false; 
                    exitEdit%ColumnName%%UID%(true); 
                    return; 
                }

                if (_saving%ColumnName%%UID%) {
                    return;
                }

                const newVal = (%ColumnName%%UID%RealInstance.option("value") || "").trim();
                
                // Nếu không có thay đổi thì chỉ thoát edit mode
                if (newVal === %ColumnName%%UID%OriginalValue) {
                    exitEdit%ColumnName%%UID%(false);
                    _saving%ColumnName%%UID% = false;
                    _justSaved%ColumnName%%UID% = false;
                    return;
                }

                try {
                    _saving%ColumnName%%UID% = true;

                    const dataJSON = JSON.stringify(["%tableId%", ["%ColumnName%"], [newVal || ""]]);
                    
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

                    const json = await saveFunction(dataJSON, idValsJSON);

                    const dtError = json.data[json.data.length-1] ?? [];
                    if (dtError.length && dtError[0].Status === "ERROR") {
                        if ("%IsAlert%" === "1") {
                            uiManager.showAlert({ type: "error", message: dtError[0].Message || "Lưu thất bại" });
                        }
                        _saving%ColumnName%%UID% = false;
                        _justSaved%ColumnName%%UID% = false;
                        return;
                    }

                    %ColumnName%%UID%OriginalValue = newVal;
                    if ("%IsAlert%" === "1") {
                        uiManager.showAlert({ type: "success", message: "Lưu thành công" });
                    }
                    exitEdit%ColumnName%%UID%(false);

                    if (typeof cellInfo !== "undefined" && cellInfo && cellInfo.component) {
                        try {
                            const grid = cellInfo.component;
                            const rowKey = cellInfo.key || cellInfo.data["%ColumnIDName%"];
                            
                            // Cập nhật cell value trong grid
                            grid.cellValue(cellInfo.rowIndex, "%ColumnName%", newVal);
                            
                            // Refresh cell để hiển thị giá trị mới
                            grid.repaint();
                            
                        } catch (syncErr) {
                            console.warn("[Grid Sync] Không thể sync grid:", syncErr);
                        }
                    }

                } catch (e) {
                    if ("%IsAlert%" === "1") {
                        uiManager.showAlert({ type: "error", message: "Lỗi khi lưu" });
                    }
                } finally {
                    setTimeout(function(){ 
                        _saving%ColumnName%%UID% = false;
                        _justSaved%ColumnName%%UID% = false;
                    }, 100);
                }
            }

            /* ================= CREATE UI ================= */
            %ColumnName%%UID%TextDisplay = $("<div>").css({
                "padding":"6px 8px",
                "cursor":"text",
                "min-height":"80px",
                "font-size":"14px",
                "height": "100%",
                "line-height":"1.5",
                "white-space":"pre-wrap",
                "border":"1px solid transparent",
                "border-radius":"4px",
                "transition":"border-color 0.2s"
            }).appendTo($container%ColumnName%%UID%);

            // Khởi tạo với placeholder
            updateDisplayText%ColumnName%%UID%("");

            %ColumnName%%UID%TextDisplay.hover(
                function() {
                    if (!%ColumnName%%UID%IsEditing) {
                        $(this).css("border-color", "#ddd");
                    }
                },
                function() {
                    if (!%ColumnName%%UID%IsEditing) {
                        $(this).css("border-color", "transparent");
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

                const $ta = $container%ColumnName%%UID%.find("textarea");
                setTimeout(() => {
                    $ta.focus();
                    const len = $ta.val().length;
                    $ta[0].setSelectionRange(len,len);
                }, 10);

                $ta.css({
                    "border-color": "#1c975e",
                    "padding": "6px",
                    "border-radius": "4px"
                });
            });

            %ColumnName%%UID%RealInstance = $("<div>").appendTo($container%ColumnName%%UID%).dxTextArea({
                value: "",
                width: "100%",
                height: 80,
                inputAttr: { class: "dx-texteditor-input" },
                onKeyDown: function(e) {
                    if (!%ColumnName%%UID%IsEditing) return;
                    
                    if (e.event.key === "Enter" && e.event.ctrlKey) { 
                        e.event.preventDefault();
                        const $ta = $container%ColumnName%%UID%.find("textarea");
                        const currentValue = $ta.val().trim();
                        %ColumnName%%UID%RealInstance.option("value", currentValue);
                        saveValue%ColumnName%%UID%();
                    }
                    
                    if (e.event.key === "Tab") {
                        e.event.preventDefault();
                        const $ta = $container%ColumnName%%UID%.find("textarea");
                        const currentValue = $ta.val().trim();
                        %ColumnName%%UID%RealInstance.option("value", currentValue);
                        saveValue%ColumnName%%UID%();
                    }
                    
                    if (e.event.key === "Escape") { 
                        e.event.preventDefault(); 
                        exitEdit%ColumnName%%UID%(true); 
                    }
                },
                onFocusOut: function(e) {
                    // QUAN TRỌNG: Kiểm tra flag cancel TRƯỚC
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
                        const $ta = $container%ColumnName%%UID%.find("textarea");
                        const currentValue = $ta.val().trim();
                        
                        if (currentValue !== %ColumnName%%UID%OriginalValue) {
                            %ColumnName%%UID%RealInstance.option("value", currentValue);
                            saveValue%ColumnName%%UID%();
                        } else {
                            exitEdit%ColumnName%%UID%(false);
                        }
                    }
                }
            }).dxTextArea("instance");

            $container%ColumnName%%UID%.find(".dx-texteditor").hide();

            /* ================= PUBLIC API ================= */
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
                option: function(name,value){
                    if(value !== undefined){ 
                        %ColumnName%%UID%RealInstance.option(name,value);
                        if(name==="value"){ 
                            %ColumnName%%UID%OriginalValue=value||""; 
                            updateDisplayText%ColumnName%%UID%(value||"");
                        }
                    }else{
                        return %ColumnName%%UID%RealInstance.option(name);
                    }
                },
                repaint: function() {
                    %ColumnName%%UID%RealInstance.repaint();
                },
                _suppressValueChangeAction: function(){
                    if (%ColumnName%%UID%RealInstance._suppressValueChangeAction) {
                        %ColumnName%%UID%RealInstance._suppressValueChangeAction();
                    }
                },
                _resumeValueChangeAction: function(){
                    if (%ColumnName%%UID%RealInstance._resumeValueChangeAction) {
                        %ColumnName%%UID%RealInstance._resumeValueChangeAction();
                    }
                }
            };
        '
    WHERE [Type] = 'hpaControlTextArea' AND [ReadOnly] = 0 AND [AutoSave] = 1;

    -- =========================================================================
    -- EDIT MODE (NO AUTOSAVE) - Có popup Save/Cancel nhưng không gọi API
    -- =========================================================================
    UPDATE #temptable SET 
        loadUI = N'
            /* Thêm CSS cho textarea height 100% */
            if (!$("head").find("#hpa-textarea-height-style").length) {
                $("head").append("<style id=\"hpa-textarea-height-style\">textarea.dx-texteditor-input { height: 100% !important; }</style>");
            }
            
            let $container%ColumnName%%UID% = $("#%UID%");
            let Instance%ColumnName%%UID% = null;

            let _autoSave%ColumnName%%UID% = false;
            let _readOnly%ColumnName%%UID% = false;

            let %ColumnName%%UID%OriginalValue = "";
            let %ColumnName%%UID%IsEditing = false;
            let %ColumnName%%UID%TextDisplay = null;
            let %ColumnName%%UID%MouseDownInside = false;
            let _cancelingSave%ColumnName%%UID% = false;
            let _justSaved%ColumnName%%UID% = false;
            let _saving%ColumnName%%UID% = false;
            let %ColumnName%%UID%RealInstance = null;

            /* =============== Helper Function =============== */
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
                
                if (cancel) {
                    // Rollback về giá trị gốc TRƯỚC KHI tắt editing mode
                    %ColumnName%%UID%RealInstance.option("value", %ColumnName%%UID%OriginalValue);
                    // Cập nhật textarea DOM ngay lập tức
                    const $ta = $container%ColumnName%%UID%.find("textarea");
                    $ta.val(%ColumnName%%UID%OriginalValue);
                } else {
                    // Lưu giá trị hiện tại làm giá trị gốc mới
                    %ColumnName%%UID%OriginalValue = %ColumnName%%UID%RealInstance.option("value");
                }
                
                %ColumnName%%UID%IsEditing = false;
                %ColumnName%%UID%MouseDownInside = false;

                $container%ColumnName%%UID%.find(".dx-texteditor").hide();
                
                // Cập nhật display text với placeholder
                const finalValue = %ColumnName%%UID%OriginalValue || "";
                updateDisplayText%ColumnName%%UID%(finalValue);
                
                %ColumnName%%UID%TextDisplay.show();
            }

            function saveValueLocal%ColumnName%%UID%() {
                // Nếu đang cancel thì rollback và thoát
                if (_cancelingSave%ColumnName%%UID%) { 
                    _cancelingSave%ColumnName%%UID% = false; 
                    exitEdit%ColumnName%%UID%(true); 
                    return; 
                }

                if (_saving%ColumnName%%UID%) return;

                // Feature: Check Instance AutoSave Flag - Make this async and call API if needed
                if (_autoSave%ColumnName%%UID%) {
                     // Wrap async logic in IIFE
                     (async () => {
                        try {
                            _saving%ColumnName%%UID% = true;
                            const newVal = %ColumnName%%UID%RealInstance.option("value");
                            const dataJSON = JSON.stringify(["%tableId%", ["%ColumnName%"], [newVal || ""]]);
                            
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
                            const json = await saveFunction(dataJSON, idValsJSON);
                            
                            const dtError = json.data[json.data.length-1] ?? [];
                            if (dtError.length && dtError[0].Status === "ERROR") {
                                if ("%IsAlert%" === "1") {
                                    uiManager.showAlert({ type: "error", message: dtError[0].Message || "Lưu thất bại" });
                                }
                                _saving%ColumnName%%UID% = false;
                                _justSaved%ColumnName%%UID% = false;
                                return;
                            }

                            if ("%IsAlert%" === "1") {
                                uiManager.showAlert({ type: "success", message: "Lưu thành công" });
                            }
                            
                            %ColumnName%%UID%OriginalValue = newVal;
                            exitEdit%ColumnName%%UID%(false);
                            _saving%ColumnName%%UID% = false;
                            _justSaved%ColumnName%%UID% = false;

                            // Sync grid
                            if (typeof cellInfo !== "undefined" && cellInfo && cellInfo.component) {
                                try {
                                    const grid = cellInfo.component;
                                    grid.cellValue(cellInfo.rowIndex, "%ColumnName%", newVal);
                                    grid.repaint();
                                } catch (syncErr) { console.warn(syncErr); }
                            }

                        } catch (e) {
                             if ("%IsAlert%" === "1") uiManager.showAlert({ type: "error", message: "Lỗi khi lưu" });
                             _saving%ColumnName%%UID% = false;
                        }
                     })();
                     
                     return;
                }

                const newVal = %ColumnName%%UID%RealInstance.option("value");
                
                // Nếu không có thay đổi thì chỉ thoát edit mode
                if (newVal === %ColumnName%%UID%OriginalValue) {
                    exitEdit%ColumnName%%UID%(false);
                    _justSaved%ColumnName%%UID% = false;
                    return;
                }
                
                // Lưu giá trị mới
                %ColumnName%%UID%OriginalValue = newVal;
                exitEdit%ColumnName%%UID%(false);

                // Sync grid cell nếu được gọi từ grid
                if (typeof cellInfo !== "undefined" && cellInfo && cellInfo.component) {
                    try {
                        const grid = cellInfo.component;
                        grid.cellValue(cellInfo.rowIndex, "%ColumnName%", newVal);
                        grid.repaint();
                    } catch (syncErr) {
                        console.warn("[Grid Sync] Không thể sync grid:", syncErr);
                    }
                }
            }

            /* ================= CREATE UI ================= */
            %ColumnName%%UID%TextDisplay = $("<div>").css({
                "padding":"6px 8px",
                "cursor":"text",
                "min-height":"80px",
                "font-size":"14px",
                "height": "100%",
                "line-height":"1.5",
                "white-space":"pre-wrap",
                "border":"1px solid transparent",
                "border-radius":"4px",
                "transition":"border-color 0.2s"
            }).appendTo($container%ColumnName%%UID%);

            // Khởi tạo với placeholder
            updateDisplayText%ColumnName%%UID%("");

            %ColumnName%%UID%TextDisplay.hover(
                function() {
                    if (!%ColumnName%%UID%IsEditing) {
                        $(this).css("border-color", "#ddd");
                    }
                },
                function() {
                    if (!%ColumnName%%UID%IsEditing) {
                        $(this).css("border-color", "transparent");
                    }
                }
            );

            %ColumnName%%UID%TextDisplay.on("click", function() {
                // Feature: Check Instance ReadOnly Flag
                if (_readOnly%ColumnName%%UID%) return;
                
                if (%ColumnName%%UID%IsEditing) return;
                %ColumnName%%UID%IsEditing = true;
                %ColumnName%%UID%MouseDownInside = false;
                %ColumnName%%UID%OriginalValue = %ColumnName%%UID%RealInstance.option("value");
                %ColumnName%%UID%TextDisplay.hide();
                $container%ColumnName%%UID%.find(".dx-texteditor").show();

                const $ta = $container%ColumnName%%UID%.find("textarea");
                setTimeout(() => {
                    $ta.focus();
                    const len = $ta.val().length;
                    $ta[0].setSelectionRange(len, len);
                }, 10);

                $ta.css({
                    "border-color": "#1c975e",
                    "padding": "6px",
                    "border-radius": "4px"
                });
            });

            %ColumnName%%UID%RealInstance = $("<div>").appendTo($container%ColumnName%%UID%).dxTextArea({
                value: "",
                width: "100%",
                height: 80,
                inputAttr: { class: "dx-texteditor-input" },
                onKeyDown: function(e) {
                    if (!%ColumnName%%UID%IsEditing) return;
                    
                    if (e.event.key === "Enter" && e.event.ctrlKey) { 
                        e.event.preventDefault();
                        const $ta = $container%ColumnName%%UID%.find("textarea");
                        const currentValue = $ta.val().trim();
                        %ColumnName%%UID%RealInstance.option("value", currentValue);
                        saveValueLocal%ColumnName%%UID%(); 
                    }
                    
                    if (e.event.key === "Tab") {
                        e.event.preventDefault();
                        const $ta = $container%ColumnName%%UID%.find("textarea");
                        const currentValue = $ta.val().trim();
                        %ColumnName%%UID%RealInstance.option("value", currentValue);
                        saveValueLocal%ColumnName%%UID%();
                    }
                    
                    if (e.event.key === "Escape") { 
                        e.event.preventDefault(); 
                        exitEdit%ColumnName%%UID%(true); 
                    }
                },
                onFocusOut: function(e) {
                    // QUAN TRỌNG: Kiểm tra flag cancel TRƯỚC
                    if (_cancelingSave%ColumnName%%UID%) { 
                        _cancelingSave%ColumnName%%UID% = false; 
                        return; 
                    }
                    if (_justSaved%ColumnName%%UID%) { 
                        _justSaved%ColumnName%%UID% = false; 
                        return; 
                    }

                    // Auto-save local khi mất focus
                    if (%ColumnName%%UID%IsEditing) {
                        const $ta = $container%ColumnName%%UID%.find("textarea");
                        const currentValue = $ta.val().trim();
                        
                        if (currentValue !== %ColumnName%%UID%OriginalValue) {
                            %ColumnName%%UID%RealInstance.option("value", currentValue);
                            saveValueLocal%ColumnName%%UID%();
                        } else {
                            exitEdit%ColumnName%%UID%(false);
                        }
                    }
                }
            }).dxTextArea("instance");

            $container%ColumnName%%UID%.find(".dx-texteditor").hide();

            /* ================= PUBLIC API ================= */
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
                            %ColumnName%%UID%OriginalValue = value || ""; 
                            updateDisplayText%ColumnName%%UID%(value||"");
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
    WHERE [Type] = 'hpaControlTextArea' AND [ReadOnly] = 0 AND [AutoSave] = 0;
END
GO