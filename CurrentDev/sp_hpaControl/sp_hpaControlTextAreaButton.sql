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
            let Instance%ColumnName%%UID% = null;
            Instance%ColumnName%%UID% = $("#%UID%").dxTextArea({
                value: "",
                width: "100%",
                height: 80,
                readOnly: true,
                inputAttr: { class: "form-control form-control-sm", style: "font-size: 14px; padding: 6px; height: 100%;" }
            }).dxTextArea("instance");
        '
    WHERE [Type] = 'hpaControlTextArea' AND [ReadOnly] = 1;

    -- =========================================================================
    -- EDIT MODE (INLINE + POPUP + AUTOSAVE)
    -- =========================================================================
    UPDATE #temptable SET 
        loadUI = N'
            const $container%ColumnName%%UID% = $("#%UID%");
            let Instance%ColumnName%%UID% = null;

            let %ColumnName%%UID%OriginalValue = "";
            let %ColumnName%%UID%IsEditing = false;
            let %ColumnName%%UID%TextDisplay = null;
            let %ColumnName%%UID%MouseDownInside = false;
            let _cancelingSave%ColumnName%%UID% = false;
            let _justSaved%ColumnName%%UID% = false;
            let _saving%ColumnName%%UID% = false;
            let %ColumnName%%UID%RealInstance = null;

            /* ================= POPUP ================= */
            let actionPopup%ColumnName%%UID% = null;
            let currentFieldId%ColumnName%%UID% = null;
            let saveCallback%ColumnName%%UID% = null;
            let cancelCallback%ColumnName%%UID% = null;

            function initActionPopup%ColumnName%%UID%() {
                if (actionPopup%ColumnName%%UID%) return;
                actionPopup%ColumnName%%UID% = $("<div>").appendTo("body").addClass("hpa-responsive").dxPopup({
                    width: "auto",
                    height: "auto",
                    showTitle: false,
                    visible: false,
                    shading: false,
                    dragEnabled: false,
                    hideOnOutsideClick: false,
                    animation: null,
                    showCloseButton: false,
                    position: { at: "bottom right", my: "top right", offset: "0 4" },
                    onShown: function(e) {
                        $(e.component.content()).closest(".dx-overlay-wrapper").css("z-index", "9999");
                    },
                    contentTemplate: () => {
                        return $("<div class=\"d-flex\" style=\"gap: 6px; padding: 6px;\">").append(
                            $("<div>").dxButton({
                                icon: "check",
                                type: "success",
                                stylingMode: "contained",
                                width: 32, height: 32,
                                elementAttr: { style: "border-radius: 4px !important;" },
                                onInitialized: function(e) {
                                    $(e.element).on("mousedown", function(evt) {
                                        evt.preventDefault();
                                        evt.stopPropagation();
                                        _justSaved%ColumnName%%UID% = true;
                                        _saving%ColumnName%%UID% = true;
                                    });
                                },
                                onClick: async function() {
                                    // Cập nhật value từ textarea trước khi save
                                    const $ta = $container%ColumnName%%UID%.find("textarea");
                                    const currentValue = $ta.val().trim();
                                    %ColumnName%%UID%RealInstance.option("value", currentValue);
                                    
                                    if (saveCallback%ColumnName%%UID%) {
                                        await saveCallback%ColumnName%%UID%(true);
                                    }
                                    actionPopup%ColumnName%%UID%.hide();
                                    setTimeout(function(){ 
                                        _justSaved%ColumnName%%UID% = false;
                                        _saving%ColumnName%%UID% = false;
                                    }, 300);
                                }
                            }),
                            $("<div>").dxButton({
                                icon: "close",
                                stylingMode: "outlined",
                                width: 32, height: 32,
                                elementAttr: { style: "border-radius: 4px !important;" },
                                onInitialized: function(e) {
                                    $(e.element).on("mousedown", function(evt) {
                                        evt.preventDefault();
                                        evt.stopPropagation();
                                        _cancelingSave%ColumnName%%UID% = true;
                                    });
                                },
                                onClick: function() {
                                    // Rollback ngay lập tức trước khi ẩn popup
                                    if (cancelCallback%ColumnName%%UID%) {
                                        cancelCallback%ColumnName%%UID%();
                                    }
                                    actionPopup%ColumnName%%UID%.hide();
                                    setTimeout(function(){ 
                                        _cancelingSave%ColumnName%%UID% = false; 
                                    }, 300);
                                }
                            })
                        );
                    },
                    onHiding: function() {
                        currentFieldId%ColumnName%%UID% = saveCallback%ColumnName%%UID% = cancelCallback%ColumnName%%UID% = null;
                    }
                }).dxPopup("instance");
            }

            function showActionPopup(inputElement, fieldId, onSave, onCancel) {
                if (!actionPopup%ColumnName%%UID%) initActionPopup%ColumnName%%UID%();

                // Nếu đang có field khác đang edit, cancel field đó trước
                if (currentFieldId%ColumnName%%UID% && currentFieldId%ColumnName%%UID% !== fieldId && cancelCallback%ColumnName%%UID%) {
                    cancelCallback%ColumnName%%UID%();
                }

                currentFieldId%ColumnName%%UID% = fieldId;
                saveCallback%ColumnName%%UID% = onSave;
                cancelCallback%ColumnName%%UID% = onCancel;

                const updatePos = () => {
                    if (!actionPopup%ColumnName%%UID%?.option("visible")) return;
                    const $ta = $(inputElement).find("textarea");
                    if ($ta.length === 0) return;
                    actionPopup%ColumnName%%UID%.option({
                        position: {
                            my: "top right",
                            at: "bottom right",
                            of: $ta,
                            offset: "0 4"
                        }
                    });
                    actionPopup%ColumnName%%UID%.repaint();
                };

                actionPopup%ColumnName%%UID%.show();
                setTimeout(updatePos, 10);

                $(window).off("scroll.ap" + fieldId).on("scroll.ap" + fieldId, updatePos);
                $(window).off("resize.ap" + fieldId).on("resize.ap" + fieldId, updatePos);
                $(".dx-scrollable").off("scroll.ap" + fieldId).on("scroll.ap" + fieldId, updatePos);

                const intervalId = setInterval(() => {
                    if (actionPopup%ColumnName%%UID%?.option("visible")) updatePos();
                    else clearInterval(intervalId);
                }, 100);

                actionPopup%ColumnName%%UID%.option("onHiding", function() {
                    clearInterval(intervalId);
                    $(window).off("scroll.ap" + fieldId);
                    $(window).off("resize.ap" + fieldId);
                    $(".dx-scrollable").off("scroll.ap" + fieldId);
                    currentFieldId%ColumnName%%UID% = saveCallback%ColumnName%%UID% = cancelCallback%ColumnName%%UID% = null;
                });
            }

            /* ================= EXIT EDIT ================= */
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
                $(document).off("mousedown.edit%ColumnName%%UID%");
                $(document).off("mouseup.edit%ColumnName%%UID%");

                if (actionPopup%ColumnName%%UID% && actionPopup%ColumnName%%UID%.option("visible")) {
                    actionPopup%ColumnName%%UID%.option("visible", false);
                }

                $container%ColumnName%%UID%.find(".dx-texteditor").hide();
                %ColumnName%%UID%TextDisplay.text(%ColumnName%%UID%OriginalValue || "").show();
            }

            /* ================= SAVE ================= */
            async function saveValue%ColumnName%%UID%(fromButton = false) {
                // Nếu đang cancel thì rollback và thoát
                if (_cancelingSave%ColumnName%%UID%) { 
                    _cancelingSave%ColumnName%%UID% = false; 
                    exitEdit%ColumnName%%UID%(true); 
                    return; 
                }

                // Chỉ check flag _saving khi KHÔNG phải từ button
                if (!fromButton && _saving%ColumnName%%UID%) {
                    return;
                }

                const newVal = %ColumnName%%UID%RealInstance.option("value");
                
                // Nếu không có thay đổi thì chỉ thoát edit mode
                if (newVal === %ColumnName%%UID%OriginalValue) {
                    exitEdit%ColumnName%%UID%(false);
                    _saving%ColumnName%%UID% = false;
                    _justSaved%ColumnName%%UID% = false;
                    return;
                }

                try {
                    // Chỉ set flag nếu chưa được set (từ button đã set rồi)
                    if (!fromButton) {
                        _saving%ColumnName%%UID% = true;
                    }

                    const dataJSON = JSON.stringify(["%tableId%", ["%ColumnName%%UID%"], [newVal || ""]]);
                    
                    let currentRecordIDValue = [
                        currentRecordID_%ColumnIDName%
                    ];

                    let currentRecordID = [
                        "%ColumnIDName%"
                    ];

                    if ("%ColumnIDName2%" && "%ColumnIDName2%".trim() !== "") {
                        currentRecordIDValue.push(currentRecordID_%ColumnIDName2%);
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
                            grid.cellValue(cellInfo.rowIndex, "%ColumnName%%UID%", newVal);
                            
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

            /* ================= HANDLE CLICK OUTSIDE ================= */
            function handleMouseDown%ColumnName%%UID%(e) {
                if (!%ColumnName%%UID%IsEditing) return;
                
                // Nếu đang save hoặc cancel thì không xử lý
                if (_saving%ColumnName%%UID% || _cancelingSave%ColumnName%%UID%) return;

                const $t = $(e.target);
                const isInsideControl = $t.closest($container%ColumnName%%UID%).length > 0;
                const isInsidePopup = $t.closest(".dx-popup-wrapper").length > 0;

                if (isInsideControl || isInsidePopup) {
                    %ColumnName%%UID%MouseDownInside = true;
                } else {
                    %ColumnName%%UID%MouseDownInside = false;
                }
            }

            function handleMouseUp%ColumnName%%UID%(e) {
                if (!%ColumnName%%UID%IsEditing) return;

                // Nếu đang save, cancel hoặc vừa save xong thì không xử lý
                if (_saving%ColumnName%%UID% || _cancelingSave%ColumnName%%UID% || _justSaved%ColumnName%%UID%) {
                    %ColumnName%%UID%MouseDownInside = false;
                    return;
                }

                const $t = $(e.target);
                const isInsideControl = $t.closest($container%ColumnName%%UID%).length > 0;
                const isInsidePopup = $t.closest(".dx-popup-wrapper").length > 0;

                const selection = window.getSelection();
                const hasSelection = selection && selection.toString().length > 0;

                // Chỉ save khi cả mousedown và mouseup đều ở ngoài và không có text được select
                if (!%ColumnName%%UID%MouseDownInside && !isInsideControl && !isInsidePopup && !hasSelection) {
                    // Cập nhật value từ textarea trước khi save
                    const $ta = $container%ColumnName%%UID%.find("textarea");
                    const currentValue = $ta.val().trim();
                    %ColumnName%%UID%RealInstance.option("value", currentValue);
                    saveValue%ColumnName%%UID%();
                }
                %ColumnName%%UID%MouseDownInside = false;
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
                    "height": "100%",
                    "border-radius": "4px"
                });

                showActionPopup(
                    $container%ColumnName%%UID%,
                    "%ColumnName%%UID%",
                    async (fromButton) => { await saveValue%ColumnName%%UID%(fromButton); },
                    () => exitEdit%ColumnName%%UID%(true)
                );

                setTimeout(() => {
                    $(document).on("mousedown.edit%ColumnName%%UID%", handleMouseDown%ColumnName%%UID%);
                    $(document).on("mouseup.edit%ColumnName%%UID%", handleMouseUp%ColumnName%%UID%);
                }, 100);
            });

            %ColumnName%%UID%RealInstance = $("<div>").appendTo($container%ColumnName%%UID%).dxTextArea({
                value: "",
                width: "100%",
                height: 80,
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
                    updateDisplayText%ColumnName%%UID%(displayVal); // ← CẬP NHẬT TEXT VIEW MODE
                },
                getValue: function() {
                    return %ColumnName%%UID%RealInstance.option("value");
                },
                option: function(name,value){
                    if(value !== undefined){ 
                        %ColumnName%%UID%RealInstance.option(name,value);
                        if(name==="value"){ 
                            %ColumnName%%UID%OriginalValue=value||""; 
                            %ColumnName%%UID%TextDisplay.text(value||""); 
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
            const $container%ColumnName%%UID% = $("#%UID%");
            let Instance%ColumnName%%UID% = null;

            let _autoSave%ColumnName%%UID% = false;
            let _readOnly%ColumnName%%UID% = false;

            let %ColumnName%%UID%OriginalValue = "";
            let %ColumnName%%UID%IsEditing = false;
            let %ColumnName%%UID%TextDisplay = null;
            let %ColumnName%%UID%MouseDownInside = false;
            let _cancelingSave%ColumnName%%UID% = false;
            let _justSaved%ColumnName%%UID% = false;
            let %ColumnName%%UID%RealInstance = null;

            /* ================= POPUP ================= */
            let actionPopup%ColumnName%%UID% = null;
            let currentFieldId%ColumnName%%UID% = null;
            let saveCallback%ColumnName%%UID% = null;
            let cancelCallback%ColumnName%%UID% = null;

            function initActionPopup%ColumnName%%UID%() {
                if (actionPopup%ColumnName%%UID%) return;
                actionPopup%ColumnName%%UID% = $("<div>").appendTo("body").dxPopup({
                    width: "auto",
                    height: "auto",
                    showTitle: false,
                    visible: false,
                    shading: false,
                    dragEnabled: false,
                    hideOnOutsideClick: false,
                    animation: null,
                    showCloseButton: false,
                    position: { at: "bottom right", my: "top right", offset: "0 4" },
                    onShown: function(e) {
                        $(e.component.content()).closest(".dx-overlay-wrapper").css("z-index", "9999");
                    },
                    contentTemplate: () => {
                        return $("<div class=\"d-flex\" style=\"gap: 6px; padding: 6px;\">").append(
                            $("<div>").dxButton({
                                icon: "check",
                                type: "success",
                                stylingMode: "contained",
                                width: 32, height: 32,
                                elementAttr: { style: "border-radius: 4px !important;" },
                                onInitialized: function(e) {
                                    $(e.element).on("mousedown", function(evt) {
                                        evt.preventDefault();
                                        evt.stopPropagation();
                                        _justSaved%ColumnName%%UID% = true;
                                    });
                                },
                                onClick: function() {
                                    // Cập nhật value từ textarea trước khi save
                                    const $ta = $container%ColumnName%%UID%.find("textarea");
                                    const currentValue = $ta.val().trim();
                                    %ColumnName%%UID%RealInstance.option("value", currentValue);
                                    
                                    if (saveCallback%ColumnName%%UID%) {
                                        saveCallback%ColumnName%%UID%();
                                    }
                                    actionPopup%ColumnName%%UID%.hide();
                                    setTimeout(function(){ 
                                        _justSaved%ColumnName%%UID% = false;
                                    }, 300);
                                }
                            }),
                            $("<div>").dxButton({
                                icon: "close",
                                stylingMode: "outlined",
                                width: 32, height: 32,
                                elementAttr: { style: "border-radius: 4px !important;" },
                                onInitialized: function(e) {
                                    $(e.element).on("mousedown", function(evt) {
                                        evt.preventDefault();
                                        evt.stopPropagation();
                                        _cancelingSave%ColumnName%%UID% = true;
                                    });
                                },
                                onClick: function() {
                                    // Rollback ngay lập tức trước khi ẩn popup
                                    if (cancelCallback%ColumnName%%UID%) {
                                        cancelCallback%ColumnName%%UID%();
                                    }
                                    actionPopup%ColumnName%%UID%.hide();
                                    setTimeout(function(){ 
                                        _cancelingSave%ColumnName%%UID% = false; 
                                    }, 300);
                                }
                            })
                        );
                    },
                    onHiding: function() {
                        currentFieldId%ColumnName%%UID% = saveCallback%ColumnName%%UID% = cancelCallback%ColumnName%%UID% = null;
                    }
                }).dxPopup("instance");
            }

            function showActionPopup(inputElement, fieldId, onSave, onCancel) {
                if (!actionPopup%ColumnName%%UID%) initActionPopup%ColumnName%%UID%();

                // Nếu đang có field khác đang edit, cancel field đó trước
                if (currentFieldId%ColumnName%%UID% && currentFieldId%ColumnName%%UID% !== fieldId && cancelCallback%ColumnName%%UID%) {
                    cancelCallback%ColumnName%%UID%();
                }

                currentFieldId%ColumnName%%UID% = fieldId;
                saveCallback%ColumnName%%UID% = onSave;
                cancelCallback%ColumnName%%UID% = onCancel;

                const updatePos = () => {
                    if (!actionPopup%ColumnName%%UID%?.option("visible")) return;
                    const $ta = $(inputElement).find("textarea");
                    if ($ta.length === 0) return;
                    actionPopup%ColumnName%%UID%.option({
                        position: {
                            my: "top right",
                            at: "bottom right",
                            of: $ta,
                            offset: "0 4"
                        }
                    });
                    actionPopup%ColumnName%%UID%.repaint();
                };

                actionPopup%ColumnName%%UID%.show();
                setTimeout(updatePos, 10);

                $(window).off("scroll.ap" + fieldId).on("scroll.ap" + fieldId, updatePos);
                $(window).off("resize.ap" + fieldId).on("resize.ap" + fieldId, updatePos);
                $(".dx-scrollable").off("scroll.ap" + fieldId).on("scroll.ap" + fieldId, updatePos);

                const intervalId = setInterval(() => {
                    if (actionPopup%ColumnName%%UID%?.option("visible")) updatePos();
                    else clearInterval(intervalId);
                }, 100);

                actionPopup%ColumnName%%UID%.option("onHiding", function() {
                    clearInterval(intervalId);
                    $(window).off("scroll.ap" + fieldId);
                    $(window).off("resize.ap" + fieldId);
                    $(".dx-scrollable").off("scroll.ap" + fieldId);
                    currentFieldId%ColumnName%%UID% = saveCallback%ColumnName%%UID% = cancelCallback%ColumnName%%UID% = null;
                });
            }

            /* ================= EXIT EDIT ================= */
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
                $(document).off("mousedown.edit%ColumnName%%UID%");
                $(document).off("mouseup.edit%ColumnName%%UID%");

                if (actionPopup%ColumnName%%UID% && actionPopup%ColumnName%%UID%.option("visible")) {
                    actionPopup%ColumnName%%UID%.option("visible", false);
                }

                $container%ColumnName%%UID%.find(".dx-texteditor").hide();
                %ColumnName%%UID%TextDisplay.text(%ColumnName%%UID%OriginalValue || "").show();
            }

            /* ================= SAVE LOCAL (NO API) ================= */
            function saveValueLocal%ColumnName%%UID%(fromButton = false) {
                // Nếu đang cancel thì rollback và thoát
                if (_cancelingSave%ColumnName%%UID%) { 
                    _cancelingSave%ColumnName%%UID% = false; 
                    exitEdit%ColumnName%%UID%(true); 
                    return; 
                }

                // Feature: Check Instance AutoSave Flag - Make this async and call API if needed
                if (_autoSave%ColumnName%%UID%) {
                     // Wrap async logic in IIFE
                     (async () => {
                        try {
                            if (!fromButton) {
                                _saving%ColumnName%%UID% = true;
                            }
                            const newVal = %ColumnName%%UID%RealInstance.option("value");
                            const dataJSON = JSON.stringify(["%tableId%", ["%ColumnName%%UID%"], [newVal || ""]]);
                            
                            let currentRecordIDValue = [currentRecordID_%ColumnIDName%];
                            let currentRecordID = ["%ColumnIDName%"];

                            if ("%ColumnIDName2%" && "%ColumnIDName2%".trim() !== "") {
                                currentRecordIDValue.push(currentRecordID_%ColumnIDName2%);
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
                                    grid.cellValue(cellInfo.rowIndex, "%ColumnName%%UID%", newVal);
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
                        grid.cellValue(cellInfo.rowIndex, "%ColumnName%%UID%", newVal);
                        grid.repaint();
                    } catch (syncErr) {
                        console.warn("[Grid Sync] Không thể sync grid:", syncErr);
                    }
                }
            }

            /* ================= HANDLE CLICK OUTSIDE ================= */
            function handleMouseDown%ColumnName%%UID%(e) {
                if (!%ColumnName%%UID%IsEditing) return;
                
                if (_cancelingSave%ColumnName%%UID%) return;

                const $t = $(e.target);
                const isInsideControl = $t.closest($container%ColumnName%%UID%).length > 0;
                const isInsidePopup = $t.closest(".dx-popup-wrapper").length > 0;

                if (isInsideControl || isInsidePopup) {
                    %ColumnName%%UID%MouseDownInside = true;
                } else {
                    %ColumnName%%UID%MouseDownInside = false;
                }
            }

            function handleMouseUp%ColumnName%%UID%(e) {
                if (!%ColumnName%%UID%IsEditing) return;

                // Nếu đang cancel hoặc vừa save xong thì không xử lý
                if (_cancelingSave%ColumnName%%UID% || _justSaved%ColumnName%%UID%) {
                    %ColumnName%%UID%MouseDownInside = false;
                    return;
                }

                const $t = $(e.target);
                const isInsideControl = $t.closest($container%ColumnName%%UID%).length > 0;
                const isInsidePopup = $t.closest(".dx-popup-wrapper").length > 0;

                const selection = window.getSelection();
                const hasSelection = selection && selection.toString().length > 0;

                // Chỉ save khi cả mousedown và mouseup đều ở ngoài và không có text được select
                if (!%ColumnName%%UID%MouseDownInside && !isInsideControl && !isInsidePopup && !hasSelection) {
                    // Cập nhật value từ textarea trước khi save
                    const $ta = $container%ColumnName%%UID%.find("textarea");
                    const currentValue = $ta.val().trim();
                    %ColumnName%%UID%RealInstance.option("value", currentValue);
                    saveValueLocal%ColumnName%%UID%();
                }
                %ColumnName%%UID%MouseDownInside = false;
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
                    "height": "100%",
                    "border-radius": "4px"
                });

                showActionPopup(
                    $container%ColumnName%%UID%,
                    "%ColumnName%%UID%",
                    () => saveValueLocal%ColumnName%%UID%(),
                    () => exitEdit%ColumnName%%UID%(true)
                );

                setTimeout(() => {
                    $(document).on("mousedown.edit%ColumnName%%UID%", handleMouseDown%ColumnName%%UID%);
                    $(document).on("mouseup.edit%ColumnName%%UID%", handleMouseUp%ColumnName%%UID%);
                }, 100);
            });

            %ColumnName%%UID%RealInstance = $("<div>").appendTo($container%ColumnName%%UID%).dxTextArea({
                value: "",
                width: "100%",
                height: 80,
                inputAttr: { class: "form-control form-control-sm", style: "padding: 6px;" },
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
                    updateDisplayText%ColumnName%%UID%(displayVal); // ← CẬP NHẬT TEXT VIEW MODE
                },
                getValue: function() {
                    return %ColumnName%%UID%RealInstance.option("value");
                },
                option: function(name, value) {
                    if (value !== undefined) { 
                        %ColumnName%%UID%RealInstance.option(name, value);
                        if (name === "value") { 
                            %ColumnName%%UID%OriginalValue = value || ""; 
                            %ColumnName%%UID%TextDisplay.text(value || ""); 
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
