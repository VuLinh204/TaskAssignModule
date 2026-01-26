USE Paradise_Dev
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
            let %ColumnName%%UID%ValidationMsg = null;
            let %ColumnName%%UID%MouseDownInside = false;
            let _cancelingSave%ColumnName%%UID% = false;
            let _justSaved%ColumnName%%UID% = false;
            let _saving%ColumnName%%UID% = false;
            let %ColumnName%%UID%RealInstance = null;

            /* =============== Helper Function =============== */
            function showValidationError%ColumnName%%UID%(message) {
                %ColumnName%%UID%ValidationMsg.text(message).show();
                $container%ColumnName%%UID%.find("textarea").css({
                    "border": "1px solid #d9534f",
                    "box-shadow": "0 0 0 0.2rem rgba(217, 83, 79, 0.25)"
                });
            }

            function hideValidationError%ColumnName%%UID%() {
                %ColumnName%%UID%ValidationMsg.hide();
                $container%ColumnName%%UID%.find("textarea").css({
                    "border-color": "#1c975e",
                    "box-shadow": "none"
                });
            }

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

                hideValidationError%ColumnName%%UID%();

                if (cancel) {
                    %ColumnName%%UID%RealInstance.option("value", %ColumnName%%UID%OriginalValue);
                    const $ta = $container%ColumnName%%UID%.find("textarea");
                    $ta.val(%ColumnName%%UID%OriginalValue);
                } else {
                    %ColumnName%%UID%OriginalValue = %ColumnName%%UID%RealInstance.option("value");


                }

                %ColumnName%%UID%IsEditing = false;
                %ColumnName%%UID%MouseDownInside = false;

                $container%ColumnName%%UID%.find(".dx-texteditor").hide();

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

                const newVal = (%ColumnName%%UID%RealInstance.option("value") || "").trim();

                if (newVal === %ColumnName%%UID%OriginalValue) {
                    exitEdit%ColumnName%%UID%(false);
                    _saving%ColumnName%%UID% = false;
                    _justSaved%ColumnName%%UID% = false;
                    return;
                }

                try {
                    _saving%ColumnName%%UID% = true;

                    // Manual validation check
                    if (%IsRequired% === 1) {
                        if (!newVal || newVal.trim() === "") {
                            const errorMsg = window.ValidationEngine && window.ValidationEngine.getRequiredMessage
                                ? window.ValidationEngine.getRequiredMessage("%DisplayName%")
                                : "%DisplayName% là bắt buộc";

                            showValidationError%ColumnName%%UID%(errorMsg);
                            _saving%ColumnName%%UID% = false;
                            _justSaved%ColumnName%%UID% = false;

                            setTimeout(() => {
                                $container%ColumnName%%UID%.find("textarea").focus();
                            }, 50);
                            return;
                        }
                    }

                    hideValidationError%ColumnName%%UID%();

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
                                    console.warn("[Grid Sync] TextAreaBox %ColumnName%%UID%: Không thể sync shared grid data source:", dsErr);
                                }
                            }


                    %ColumnName%%UID%OriginalValue = newVal;
                    if ("%IsAlert%" === "1") {
                        uiManager.showAlert({ type: "success", message: "Lưu thành công" });
                    }
                    exitEdit%ColumnName%%UID%(false);

                    if (typeof cellInfo !== "undefined" && cellInfo && cellInfo.component) {
                        try {
                            const grid = cellInfo.component;
                            grid.cellValue(cellInfo.rowIndex, "%ColumnName%", newVal);
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

            %ColumnName%%UID%ValidationMsg = $("<div>").css({
                "color": "#d9534f",
                "font-size": "0.875rem",
                "padding": "4px 8px",
                "display": "none",
                "margin-top": "2px"
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
                onValueChanged: function(e) {
                    if (%ColumnName%%UID%IsEditing && e.value && e.value.trim() !== "") {
            hideValidationError%ColumnName%%UID%();
                    }
                },
                onKeyDown: function(e) {
                    if (!%ColumnName%%UID%IsEditing) return;

                    if (e.event.key === "Enter" && e.event.ctrlKey) {
                        e.event.preventDefault();
                        const $ta = $container%ColumnName%%UID%.find("textarea");
                        const currentValue = $ta.val().trim();

                        if (%IsRequired% === 1) {
                            if (!currentValue || currentValue.trim() === "") {
                                const errorMsg = window.ValidationEngine && window.ValidationEngine.getRequiredMessage
                                    ? window.ValidationEngine.getRequiredMessage("%DisplayName%")
                                    : "%DisplayName% là bắt buộc";

                                showValidationError%ColumnName%%UID%(errorMsg);
                                return;
                            }
                        }

                        hideValidationError%ColumnName%%UID%();
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

                        // Nếu giá trị không đổi, chỉ thoát edit
                        if (currentValue === %ColumnName%%UID%OriginalValue) {
                            %ColumnName%%UID%IsEditing = false;
                            hideValidationError%ColumnName%%UID%();
                            $container%ColumnName%%UID%.find(".dx-texteditor").hide();
                            updateDisplayText%ColumnName%%UID%(currentValue);
                            %ColumnName%%UID%TextDisplay.show();
                            return;
                        }

                        // Validate nếu field bắt buộc
                        if (%IsRequired% === 1) {
                            if (!currentValue || currentValue.trim() === "") {
                                const errorMsg = window.ValidationEngine && window.ValidationEngine.getRequiredMessage
                                    ? window.ValidationEngine.getRequiredMessage("%DisplayName%")
                                    : "%DisplayName% là bắt buộc";

                                showValidationError%ColumnName%%UID%(errorMsg);

                                // VẪN THOÁT EDIT MODE nhưng GIỮ LỖI HIỂN THỊ
                                %ColumnName%%UID%IsEditing = false;
                                $container%ColumnName%%UID%.find(".dx-texteditor").hide();
                                updateDisplayText%ColumnName%%UID%(currentValue);
                                %ColumnName%%UID%TextDisplay.show();
                                return;
                            }
                        }

                        // Validation pass → SAVE
                        hideValidationError%ColumnName%%UID%();
                        %ColumnName%%UID%RealInstance.option("value", currentValue);
                        saveValue%ColumnName%%UID%();
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
    -- EDIT MODE (NO AUTOSAVE)
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
            let %ColumnName%%UID%ValidationMsg = null;
            let %ColumnName%%UID%MouseDownInside = false;
            let _cancelingSave%ColumnName%%UID% = false;
            let _justSaved%ColumnName%%UID% = false;
            let _saving%ColumnName%%UID% = false;
            let %ColumnName%%UID%RealInstance = null;

            /* =============== Helper Function =============== */
            function showValidationError%ColumnName%%UID%(message) {
                %ColumnName%%UID%ValidationMsg.text(message).show();
                $container%ColumnName%%UID%.find("textarea").css({
                    "border": "1px solid #d9534f",
                    "box-shadow": "0 0 0 0.2rem rgba(217, 83, 79, 0.25)"
                });
            }

            function hideValidationError%ColumnName%%UID%() {
                %ColumnName%%UID%ValidationMsg.hide();
                $container%ColumnName%%UID%.find("textarea").css({
                    "border-color": "#1c975e",
                    "box-shadow": "none"
                });
            }

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

                hideValidationError%ColumnName%%UID%();

                if (cancel) {
                    %ColumnName%%UID%RealInstance.option("value", %ColumnName%%UID%OriginalValue);
                    const $ta = $container%ColumnName%%UID%.find("textarea");
                    $ta.val(%ColumnName%%UID%OriginalValue);
                } else {
                    %ColumnName%%UID%OriginalValue = %ColumnName%%UID%RealInstance.option("value");
                }

                %ColumnName%%UID%IsEditing = false;
                %ColumnName%%UID%MouseDownInside = false;

                $container%ColumnName%%UID%.find(".dx-texteditor").hide();

                const finalValue = %ColumnName%%UID%OriginalValue || "";
                updateDisplayText%ColumnName%%UID%(finalValue);

                %ColumnName%%UID%TextDisplay.show();
            }

            async function saveValueLocal%ColumnName%%UID%() {
                if (_cancelingSave%ColumnName%%UID%) {
                    _cancelingSave%ColumnName%%UID% = false;
                    exitEdit%ColumnName%%UID%(true);
                    return;
                }

                if (_saving%ColumnName%%UID%) return;

                const newVal = %ColumnName%%UID%RealInstance.option("value");

                // Validate nếu field bắt buộc
                if (%IsRequired% === 1) {
                    if (!newVal || newVal.trim() === "") {
                        const errorMsg = window.ValidationEngine && window.ValidationEngine.getRequiredMessage
                            ? window.ValidationEngine.getRequiredMessage("%DisplayName%")
                            : "%DisplayName% là bắt buộc";

                        showValidationError%ColumnName%%UID%(errorMsg);

                        setTimeout(() => {
                            $container%ColumnName%%UID%.find("textarea").focus();
                        }, 50);
                        return;
                    }
                }

                hideValidationError%ColumnName%%UID%();

                // Feature: Check Instance AutoSave Flag
                if (_autoSave%ColumnName%%UID%) {
                     (async () => {
                        try {
                            _saving%ColumnName%%UID% = true;
                            const dataJSON = JSON.stringify(["%tableId%", ["%ColumnName%"], [newVal || ""]]);

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
                                    console.warn("[Grid Sync] TextAreaBox %ColumnName%%UID%: Không thể sync shared grid data source:", dsErr);
                                }
                            }


                            %ColumnName%%UID%OriginalValue = newVal;
                            exitEdit%ColumnName%%UID%(false);
                            _saving%ColumnName%%UID% = false;
                            _justSaved%ColumnName%%UID% = false;

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

                if (newVal === %ColumnName%%UID%OriginalValue) {

                    exitEdit%ColumnName%%UID%(false);
                    _justSaved%ColumnName%%UID% = false;
                    return;
                }

                %ColumnName%%UID%OriginalValue = newVal;
                exitEdit%ColumnName%%UID%(false);

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

            %ColumnName%%UID%ValidationMsg = $("<div>").css({
                "color": "#d9534f",
                "font-size": "0.875rem",
                "padding": "4px 8px",
                "display": "none",
                "margin-top": "2px"
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
                        $(this).css("border-color", "transparent");
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
                onValueChanged: function(e) {
                    if (%ColumnName%%UID%IsEditing && e.value && e.value.trim() !== "") {
                        hideValidationError%ColumnName%%UID%();
                    }
                },
                onKeyDown: function(e) {
                    if (!%ColumnName%%UID%IsEditing) return;

                    if (e.event.key === "Enter" && e.event.ctrlKey) {
                        e.event.preventDefault();
                        const $ta = $container%ColumnName%%UID%.find("textarea");
         const currentValue = $ta.val().trim();

                        if (%IsRequired% === 1) {
                            if (!currentValue || currentValue.trim() === "") {
                                const errorMsg = window.ValidationEngine && window.ValidationEngine.getRequiredMessage
                                    ? window.ValidationEngine.getRequiredMessage("%DisplayName%")
                                    : "%DisplayName% là bắt buộc";

                                showValidationError%ColumnName%%UID%(errorMsg);
                                return;
                            }
                        }

                        hideValidationError%ColumnName%%UID%();
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
                    if (_cancelingSave%ColumnName%%UID%) {
                        _cancelingSave%ColumnName%%UID% = false;
                        return;
                    }
                    if (_justSaved%ColumnName%%UID%) {
                        _justSaved%ColumnName%%UID% = false;
                        return;
                    }

                    // VALIDATE NHƯNG KHÔNG AUTO SAVE (NO AUTOSAVE MODE)
                    if (%ColumnName%%UID%IsEditing) {
                        const $ta = $container%ColumnName%%UID%.find("textarea");
                        const currentValue = $ta.val().trim();

                        // Validate nếu field bắt buộc
                        if (%IsRequired% === 1) {
                            if (!currentValue || currentValue.trim() === "") {
                                const errorMsg = window.ValidationEngine && window.ValidationEngine.getRequiredMessage
                                    ? window.ValidationEngine.getRequiredMessage("%DisplayName%")
                                    : "%DisplayName% là bắt buộc";

                                showValidationError%ColumnName%%UID%(errorMsg);

                                // VẪN THOÁT EDIT MODE để user có thể click qua control khác
                                %ColumnName%%UID%IsEditing = false;
                                $container%ColumnName%%UID%.find(".dx-texteditor").hide();
                                updateDisplayText%ColumnName%%UID%(currentValue);
                                %ColumnName%%UID%TextDisplay.show();
                                return;
                            }
                        }

                        // Nếu validation pass, ẩn error và cập nhật value
                        hideValidationError%ColumnName%%UID%();
                        %ColumnName%%UID%RealInstance.option("value", currentValue);
                        %ColumnName%%UID%OriginalValue = currentValue;

                        // Thoát chế độ edit KHÔNG SAVE
                        %ColumnName%%UID%IsEditing = false;
                        $container%ColumnName%%UID%.find(".dx-texteditor").hide();
                        updateDisplayText%ColumnName%%UID%(currentValue);
                        %ColumnName%%UID%TextDisplay.show();
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