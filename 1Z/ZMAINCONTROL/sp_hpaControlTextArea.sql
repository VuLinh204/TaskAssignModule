USE Paradise_Beta_Tai2
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
            window.Instance%columnName% = $("#%UID%").dxTextArea({
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
            const $container%columnName% = $("#%UID%");

            let %columnName%OriginalValue = "";
            let %columnName%IsEditing = false;
            let %columnName%TextDisplay = null;
            let %columnName%MouseDownInside = false;
            let _cancelingSave%columnName% = false;
            let _justSaved%columnName% = false;
            let _saving%columnName% = false;
            window.%columnName%RealInstance = null;

            /* ================= POPUP ================= */
            let actionPopup%columnName% = null;
            let currentFieldId%columnName% = null;
            let saveCallback%columnName% = null;
            let cancelCallback%columnName% = null;

            function initActionPopup%columnName%() {
                if (actionPopup%columnName%) return;
                actionPopup%columnName% = $("<div>").appendTo("body").addClass("hpa-responsive").dxPopup({
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
                                        _justSaved%columnName% = true;
                                        _saving%columnName% = true;
                                    });
                                },
                                onClick: async function() {
                                    // Cập nhật value từ textarea trước khi save
                                    const $ta = $container%columnName%.find("textarea");
                                    const currentValue = $ta.val().trim();
                                    %columnName%RealInstance.option("value", currentValue);
                                    
                                    if (saveCallback%columnName%) {
                                        await saveCallback%columnName%(true);
                                    }
                                    actionPopup%columnName%.hide();
                                    setTimeout(function(){ 
                                        _justSaved%columnName% = false;
                                        _saving%columnName% = false;
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
                                        _cancelingSave%columnName% = true;
                                    });
                                },
                                onClick: function() {
                                    // Rollback ngay lập tức trước khi ẩn popup
                                    if (cancelCallback%columnName%) {
                                        cancelCallback%columnName%();
                                    }
                                    actionPopup%columnName%.hide();
                                    setTimeout(function(){ 
                                        _cancelingSave%columnName% = false; 
                                    }, 300);
                                }
                            })
                        );
                    },
                    onHiding: function() {
                        currentFieldId%columnName% = saveCallback%columnName% = cancelCallback%columnName% = null;
                    }
                }).dxPopup("instance");
            }

            function showActionPopup(inputElement, fieldId, onSave, onCancel) {
                if (!actionPopup%columnName%) initActionPopup%columnName%();

                // Nếu đang có field khác đang edit, cancel field đó trước
                if (currentFieldId%columnName% && currentFieldId%columnName% !== fieldId && cancelCallback%columnName%) {
                    cancelCallback%columnName%();
                }

                currentFieldId%columnName% = fieldId;
                saveCallback%columnName% = onSave;
                cancelCallback%columnName% = onCancel;

                const updatePos = () => {
                    if (!actionPopup%columnName%?.option("visible")) return;
                    const $ta = $(inputElement).find("textarea");
                    if ($ta.length === 0) return;
                    actionPopup%columnName%.option({
                        position: {
                            my: "top right",
                            at: "bottom right",
                            of: $ta,
                            offset: "0 4"
                        }
                    });
                    actionPopup%columnName%.repaint();
                };

                actionPopup%columnName%.show();
                setTimeout(updatePos, 10);

                $(window).off("scroll.ap" + fieldId).on("scroll.ap" + fieldId, updatePos);
                $(window).off("resize.ap" + fieldId).on("resize.ap" + fieldId, updatePos);
                $(".dx-scrollable").off("scroll.ap" + fieldId).on("scroll.ap" + fieldId, updatePos);

                const intervalId = setInterval(() => {
                    if (actionPopup%columnName%?.option("visible")) updatePos();
                    else clearInterval(intervalId);
                }, 100);

                actionPopup%columnName%.option("onHiding", function() {
                    clearInterval(intervalId);
                    $(window).off("scroll.ap" + fieldId);
                    $(window).off("resize.ap" + fieldId);
                    $(".dx-scrollable").off("scroll.ap" + fieldId);
                    currentFieldId%columnName% = saveCallback%columnName% = cancelCallback%columnName% = null;
                });
            }

            /* ================= EXIT EDIT ================= */
            function exitEdit%columnName%(cancel = false) {
                if (!%columnName%IsEditing) return;
                
                if (cancel) {
                    // Rollback về giá trị gốc TRƯỚC KHI tắt editing mode
                    %columnName%RealInstance.option("value", %columnName%OriginalValue);
                    // Cập nhật textarea DOM ngay lập tức
                    const $ta = $container%columnName%.find("textarea");
                    $ta.val(%columnName%OriginalValue);
                } else {
                    // Lưu giá trị hiện tại làm giá trị gốc mới
                    %columnName%OriginalValue = %columnName%RealInstance.option("value");
                }
                
                %columnName%IsEditing = false;
                %columnName%MouseDownInside = false;
                $(document).off("mousedown.edit%columnName%");
                $(document).off("mouseup.edit%columnName%");

                if (actionPopup%columnName% && actionPopup%columnName%.option("visible")) {
                    actionPopup%columnName%.option("visible", false);
                }

                $container%columnName%.find(".dx-texteditor").hide();
                %columnName%TextDisplay.text(%columnName%OriginalValue || "").show();
            }

            /* ================= SAVE ================= */
            async function saveValue%columnName%(fromButton = false) {
                // Nếu đang cancel thì rollback và thoát
                if (_cancelingSave%columnName%) { 
                    _cancelingSave%columnName% = false; 
                    exitEdit%columnName%(true); 
                    return; 
                }

                // Chỉ check flag _saving khi KHÔNG phải từ button
                if (!fromButton && _saving%columnName%) {
                    return;
                }

                const newVal = %columnName%RealInstance.option("value");
                
                // Nếu không có thay đổi thì chỉ thoát edit mode
                if (newVal === %columnName%OriginalValue) {
                    exitEdit%columnName%(false);
                    _saving%columnName% = false;
                    _justSaved%columnName% = false;
                    return;
                }

                try {
                    // Chỉ set flag nếu chưa được set (từ button đã set rồi)
                    if (!fromButton) {
                        _saving%columnName% = true;
                    }

                    const dataJSON = JSON.stringify(["%tableId%", ["%columnName%"], [newVal || ""]]);
                    
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
                        _saving%columnName% = false;
                        _justSaved%columnName% = false;
                        return;
                    }

                    %columnName%OriginalValue = newVal;
                    if ("%IsAlert%" === "1") {
                        uiManager.showAlert({ type: "success", message: "Lưu thành công" });
                    }
                    exitEdit%columnName%(false);

                    if (cellInfo && cellInfo.component) {
                        try {
                            const grid = cellInfo.component;
                            const rowKey = cellInfo.key || cellInfo.data["%ColumnIDName%"];
                            
                            // Cập nhật cell value trong grid
                            grid.cellValue(cellInfo.rowIndex, "%columnName%", newVal);
                            
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
                        _saving%columnName% = false;
                        _justSaved%columnName% = false;
                    }, 100);
                }
            }

            /* ================= HANDLE CLICK OUTSIDE ================= */
            function handleMouseDown%columnName%(e) {
                if (!%columnName%IsEditing) return;
                
                // Nếu đang save hoặc cancel thì không xử lý
                if (_saving%columnName% || _cancelingSave%columnName%) return;

                const $t = $(e.target);
                const isInsideControl = $t.closest($container%columnName%).length > 0;
                const isInsidePopup = $t.closest(".dx-popup-wrapper").length > 0;

                if (isInsideControl || isInsidePopup) {
                    %columnName%MouseDownInside = true;
                } else {
                    %columnName%MouseDownInside = false;
                }
            }

            function handleMouseUp%columnName%(e) {
                if (!%columnName%IsEditing) return;

                // Nếu đang save, cancel hoặc vừa save xong thì không xử lý
                if (_saving%columnName% || _cancelingSave%columnName% || _justSaved%columnName%) {
                    %columnName%MouseDownInside = false;
                    return;
                }

                const $t = $(e.target);
                const isInsideControl = $t.closest($container%columnName%).length > 0;
                const isInsidePopup = $t.closest(".dx-popup-wrapper").length > 0;

                const selection = window.getSelection();
                const hasSelection = selection && selection.toString().length > 0;

                // Chỉ save khi cả mousedown và mouseup đều ở ngoài và không có text được select
                if (!%columnName%MouseDownInside && !isInsideControl && !isInsidePopup && !hasSelection) {
                    // Cập nhật value từ textarea trước khi save
                    const $ta = $container%columnName%.find("textarea");
                    const currentValue = $ta.val().trim();
                    %columnName%RealInstance.option("value", currentValue);
                    saveValue%columnName%();
                }
                %columnName%MouseDownInside = false;
            }

            /* ================= CREATE UI ================= */
            %columnName%TextDisplay = $("<div>").css({
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
            }).appendTo($container%columnName%);

            %columnName%TextDisplay.hover(
                function() {
                    if (!%columnName%IsEditing) {
                        $(this).css("border-color", "#ddd");
                    }
                },
                function() {
                    if (!%columnName%IsEditing) {
                        $(this).css("border-color", "transparent");
                    }
                }
            );

            %columnName%TextDisplay.on("click", function() {
                if (%columnName%IsEditing) return;
                %columnName%IsEditing = true;
                %columnName%MouseDownInside = false;
                %columnName%OriginalValue = %columnName%RealInstance.option("value");
                %columnName%TextDisplay.hide();
                $container%columnName%.find(".dx-texteditor").show();

                const $ta = $container%columnName%.find("textarea");
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
                    $container%columnName%,
                    "%columnName%",
                    async (fromButton) => { await saveValue%columnName%(fromButton); },
                    () => exitEdit%columnName%(true)
                );

                setTimeout(() => {
                    $(document).on("mousedown.edit%columnName%", handleMouseDown%columnName%);
                    $(document).on("mouseup.edit%columnName%", handleMouseUp%columnName%);
                }, 100);
            });

            window.%columnName%RealInstance = $("<div>").appendTo($container%columnName%).dxTextArea({
                value: "",
                width: "100%",
                height: 80,
                onKeyDown: function(e) {
                    if (!%columnName%IsEditing) return;
                    
                    if (e.event.key === "Enter" && e.event.ctrlKey) { 
                        e.event.preventDefault();
                        const $ta = $container%columnName%.find("textarea");
                        const currentValue = $ta.val().trim();
                        %columnName%RealInstance.option("value", currentValue);
                        saveValue%columnName%();
                    }
                    
                    if (e.event.key === "Tab") {
                        e.event.preventDefault();
                        const $ta = $container%columnName%.find("textarea");
                        const currentValue = $ta.val().trim();
                        %columnName%RealInstance.option("value", currentValue);
                        saveValue%columnName%();
                    }
                    
                    if (e.event.key === "Escape") { 
                        e.event.preventDefault(); 
                        exitEdit%columnName%(true); 
                    }
                },
                onFocusOut: function(e) {
                    // QUAN TRỌNG: Kiểm tra flag cancel TRƯỚC
                    if (_cancelingSave%columnName%) { 
                        _cancelingSave%columnName% = false; 
                        return; 
                    }
                    if (_justSaved%columnName%) { 
                        _justSaved%columnName% = false; 
                        return; 
                    }
                    if (_saving%columnName%) {
                        return;
                    }

                    if (%columnName%IsEditing) {
                        const $ta = $container%columnName%.find("textarea");
                        const currentValue = $ta.val().trim();
                        
                        if (currentValue !== %columnName%OriginalValue) {
                            %columnName%RealInstance.option("value", currentValue);
                            saveValue%columnName%();
                        } else {
                            exitEdit%columnName%(false);
                        }
                    }
                }
            }).dxTextArea("instance");

            $container%columnName%.find(".dx-texteditor").hide();

            /* ================= PUBLIC API ================= */
            let Instance%columnName% = {
                setValue: function(val) {
                    %columnName%OriginalValue = val || "";
                    %columnName%RealInstance.option("value", val || "");
                    %columnName%TextDisplay.text(val || "");
                },
                getValue: function() {
                    return %columnName%RealInstance.option("value");
                },
                option: function(name,value){
                    if(value!==undefined){ 
                        %columnName%RealInstance.option(name,value);
                        if(name==="value"){ 
                            %columnName%OriginalValue=value||""; 
                            %columnName%TextDisplay.text(value||""); 
                        }
                    }else{
                        return %columnName%RealInstance.option(name);
                    }
                },
                repaint: function() {
                    %columnName%RealInstance.repaint();
                },
                _suppressValueChangeAction: function(){
                    if (%columnName%RealInstance._suppressValueChangeAction) {
                        %columnName%RealInstance._suppressValueChangeAction();
                    }
                },
                _resumeValueChangeAction: function(){
                    if (%columnName%RealInstance._resumeValueChangeAction) {
                        %columnName%RealInstance._resumeValueChangeAction();
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
            const $container%columnName% = $("#%UID%");

            let %columnName%OriginalValue = "";
            let %columnName%IsEditing = false;
            let %columnName%TextDisplay = null;
            let %columnName%MouseDownInside = false;
            let _cancelingSave%columnName% = false;
            let _justSaved%columnName% = false;
            window.%columnName%RealInstance = null;

            /* ================= POPUP ================= */
            let actionPopup%columnName% = null;
            let currentFieldId%columnName% = null;
            let saveCallback%columnName% = null;
            let cancelCallback%columnName% = null;

            function initActionPopup%columnName%() {
                if (actionPopup%columnName%) return;
                actionPopup%columnName% = $("<div>").appendTo("body").dxPopup({
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
                                        _justSaved%columnName% = true;
                                    });
                                },
                                onClick: function() {
                                    // Cập nhật value từ textarea trước khi save
                                    const $ta = $container%columnName%.find("textarea");
                                    const currentValue = $ta.val().trim();
                                    %columnName%RealInstance.option("value", currentValue);
                                    
                                    if (saveCallback%columnName%) {
                                        saveCallback%columnName%();
                                    }
                                    actionPopup%columnName%.hide();
                                    setTimeout(function(){ 
                                        _justSaved%columnName% = false;
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
                                        _cancelingSave%columnName% = true;
                                    });
                                },
                                onClick: function() {
                                    // Rollback ngay lập tức trước khi ẩn popup
                                    if (cancelCallback%columnName%) {
                                        cancelCallback%columnName%();
                                    }
                                    actionPopup%columnName%.hide();
                                    setTimeout(function(){ 
                                        _cancelingSave%columnName% = false; 
                                    }, 300);
                                }
                            })
                        );
                    },
                    onHiding: function() {
                        currentFieldId%columnName% = saveCallback%columnName% = cancelCallback%columnName% = null;
                    }
                }).dxPopup("instance");
            }

            function showActionPopup(inputElement, fieldId, onSave, onCancel) {
                if (!actionPopup%columnName%) initActionPopup%columnName%();

                // Nếu đang có field khác đang edit, cancel field đó trước
                if (currentFieldId%columnName% && currentFieldId%columnName% !== fieldId && cancelCallback%columnName%) {
                    cancelCallback%columnName%();
                }

                currentFieldId%columnName% = fieldId;
                saveCallback%columnName% = onSave;
                cancelCallback%columnName% = onCancel;

                const updatePos = () => {
                    if (!actionPopup%columnName%?.option("visible")) return;
                    const $ta = $(inputElement).find("textarea");
                    if ($ta.length === 0) return;
                    actionPopup%columnName%.option({
                        position: {
                            my: "top right",
                            at: "bottom right",
                            of: $ta,
                            offset: "0 4"
                        }
                    });
                    actionPopup%columnName%.repaint();
                };

                actionPopup%columnName%.show();
                setTimeout(updatePos, 10);

                $(window).off("scroll.ap" + fieldId).on("scroll.ap" + fieldId, updatePos);
                $(window).off("resize.ap" + fieldId).on("resize.ap" + fieldId, updatePos);
                $(".dx-scrollable").off("scroll.ap" + fieldId).on("scroll.ap" + fieldId, updatePos);

                const intervalId = setInterval(() => {
                    if (actionPopup%columnName%?.option("visible")) updatePos();
                    else clearInterval(intervalId);
                }, 100);

                actionPopup%columnName%.option("onHiding", function() {
                    clearInterval(intervalId);
                    $(window).off("scroll.ap" + fieldId);
                    $(window).off("resize.ap" + fieldId);
                    $(".dx-scrollable").off("scroll.ap" + fieldId);
                    currentFieldId%columnName% = saveCallback%columnName% = cancelCallback%columnName% = null;
                });
            }

            /* ================= EXIT EDIT ================= */
            function exitEdit%columnName%(cancel = false) {
                if (!%columnName%IsEditing) return;
                
                if (cancel) {
                    // Rollback về giá trị gốc TRƯỚC KHI tắt editing mode
                    %columnName%RealInstance.option("value", %columnName%OriginalValue);
                    // Cập nhật textarea DOM ngay lập tức
                    const $ta = $container%columnName%.find("textarea");
                    $ta.val(%columnName%OriginalValue);
                } else {
                    // Lưu giá trị hiện tại làm giá trị gốc mới
                    %columnName%OriginalValue = %columnName%RealInstance.option("value");
                }
                
                %columnName%IsEditing = false;
                %columnName%MouseDownInside = false;
                $(document).off("mousedown.edit%columnName%");
                $(document).off("mouseup.edit%columnName%");

                if (actionPopup%columnName% && actionPopup%columnName%.option("visible")) {
                    actionPopup%columnName%.option("visible", false);
                }

                $container%columnName%.find(".dx-texteditor").hide();
                %columnName%TextDisplay.text(%columnName%OriginalValue || "").show();
            }

            /* ================= SAVE LOCAL (NO API) ================= */
            function saveValueLocal%columnName%() {
                // Nếu đang cancel thì rollback và thoát
                if (_cancelingSave%columnName%) { 
                    _cancelingSave%columnName% = false; 
                    exitEdit%columnName%(true); 
                    return; 
                }

                const newVal = %columnName%RealInstance.option("value");
                
                // Nếu không có thay đổi thì chỉ thoát edit mode
                if (newVal === %columnName%OriginalValue) {
                    exitEdit%columnName%(false);
                    _justSaved%columnName% = false;
                    return;
                }
                
                // Lưu giá trị mới
                %columnName%OriginalValue = newVal;
                exitEdit%columnName%(false);

                // Sync grid cell nếu được gọi từ grid
                if (cellInfo && cellInfo.component) {
                    try {
                        const grid = cellInfo.component;
                        grid.cellValue(cellInfo.rowIndex, "%columnName%", newVal);
                        grid.repaint();
                    } catch (syncErr) {
                        console.warn("[Grid Sync] Không thể sync grid:", syncErr);
                    }
                }
            }

            /* ================= HANDLE CLICK OUTSIDE ================= */
            function handleMouseDown%columnName%(e) {
                if (!%columnName%IsEditing) return;
                
                if (_cancelingSave%columnName%) return;

                const $t = $(e.target);
                const isInsideControl = $t.closest($container%columnName%).length > 0;
                const isInsidePopup = $t.closest(".dx-popup-wrapper").length > 0;

                if (isInsideControl || isInsidePopup) {
                    %columnName%MouseDownInside = true;
                } else {
                    %columnName%MouseDownInside = false;
                }
            }

            function handleMouseUp%columnName%(e) {
                if (!%columnName%IsEditing) return;

                // Nếu đang cancel hoặc vừa save xong thì không xử lý
                if (_cancelingSave%columnName% || _justSaved%columnName%) {
                    %columnName%MouseDownInside = false;
                    return;
                }

                const $t = $(e.target);
                const isInsideControl = $t.closest($container%columnName%).length > 0;
                const isInsidePopup = $t.closest(".dx-popup-wrapper").length > 0;

                const selection = window.getSelection();
                const hasSelection = selection && selection.toString().length > 0;

                // Chỉ save khi cả mousedown và mouseup đều ở ngoài và không có text được select
                if (!%columnName%MouseDownInside && !isInsideControl && !isInsidePopup && !hasSelection) {
                    // Cập nhật value từ textarea trước khi save
                    const $ta = $container%columnName%.find("textarea");
                    const currentValue = $ta.val().trim();
                    %columnName%RealInstance.option("value", currentValue);
                    saveValueLocal%columnName%();
                }
                %columnName%MouseDownInside = false;
            }

            /* ================= CREATE UI ================= */
            %columnName%TextDisplay = $("<div>").css({
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
            }).appendTo($container%columnName%);

            %columnName%TextDisplay.hover(
                function() {
                    if (!%columnName%IsEditing) {
                        $(this).css("border-color", "#ddd");
                    }
                },
                function() {
                    if (!%columnName%IsEditing) {
                        $(this).css("border-color", "transparent");
                    }
                }
            );

            %columnName%TextDisplay.on("click", function() {
                if (%columnName%IsEditing) return;
                %columnName%IsEditing = true;
                %columnName%MouseDownInside = false;
                %columnName%OriginalValue = %columnName%RealInstance.option("value");
                %columnName%TextDisplay.hide();
                $container%columnName%.find(".dx-texteditor").show();

                const $ta = $container%columnName%.find("textarea");
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
                    $container%columnName%,
                    "%columnName%",
                    () => saveValueLocal%columnName%(),
                    () => exitEdit%columnName%(true)
                );

                setTimeout(() => {
                    $(document).on("mousedown.edit%columnName%", handleMouseDown%columnName%);
                    $(document).on("mouseup.edit%columnName%", handleMouseUp%columnName%);
                }, 100);
            });

            window.%columnName%RealInstance = $("<div>").appendTo($container%columnName%).dxTextArea({
                value: "",
                width: "100%",
                height: 80,
                inputAttr: { class: "form-control form-control-sm", style: "padding: 6px;" },
                onKeyDown: function(e) {
                    if (!%columnName%IsEditing) return;
                    
                    if (e.event.key === "Enter" && e.event.ctrlKey) { 
                        e.event.preventDefault();
                        const $ta = $container%columnName%.find("textarea");
                        const currentValue = $ta.val().trim();
                        %columnName%RealInstance.option("value", currentValue);
                        saveValueLocal%columnName%(); 
                    }
                    
                    if (e.event.key === "Tab") {
                        e.event.preventDefault();
                        const $ta = $container%columnName%.find("textarea");
                        const currentValue = $ta.val().trim();
                        %columnName%RealInstance.option("value", currentValue);
                        saveValueLocal%columnName%();
                    }
                    
                    if (e.event.key === "Escape") { 
                        e.event.preventDefault(); 
                        exitEdit%columnName%(true); 
                    }
                },
                onFocusOut: function(e) {
                    // QUAN TRỌNG: Kiểm tra flag cancel TRƯỚC
                    if (_cancelingSave%columnName%) { 
                        _cancelingSave%columnName% = false; 
                        return; 
                    }
                    if (_justSaved%columnName%) { 
                        _justSaved%columnName% = false; 
                        return; 
                    }

                    // Auto-save local khi mất focus
                    if (%columnName%IsEditing) {
                        const $ta = $container%columnName%.find("textarea");
                        const currentValue = $ta.val().trim();
                        
                        if (currentValue !== %columnName%OriginalValue) {
                            %columnName%RealInstance.option("value", currentValue);
                            saveValueLocal%columnName%();
                        } else {
                            exitEdit%columnName%(false);
                        }
                    }
                }
            }).dxTextArea("instance");

            $container%columnName%.find(".dx-texteditor").hide();

            /* ================= PUBLIC API ================= */
            let Instance%columnName% = {
                setValue: function(val) {
                    %columnName%OriginalValue = val || "";
                    %columnName%RealInstance.option("value", val || "");
                    %columnName%TextDisplay.text(val || "");
                },
                getValue: function() {
                    return %columnName%RealInstance.option("value");
                },
                option: function(name, value) {
                    if (value !== undefined) { 
                        %columnName%RealInstance.option(name, value);
                        if (name === "value") { 
                            %columnName%OriginalValue = value || ""; 
                            %columnName%TextDisplay.text(value || ""); 
                        }
                    } else {
                        return %columnName%RealInstance.option(name);
                    }
                },
                repaint: function() {
                    %columnName%RealInstance.repaint();
                },
                _suppressValueChangeAction: function() {
                    if (%columnName%RealInstance._suppressValueChangeAction) {
                        %columnName%RealInstance._suppressValueChangeAction();
                    }
                },
                _resumeValueChangeAction: function() {
                    if (%columnName%RealInstance._resumeValueChangeAction) {
                        %columnName%RealInstance._resumeValueChangeAction();
                    }
                }
            };
        '
    WHERE [Type] = 'hpaControlTextArea' AND [ReadOnly] = 0 AND [AutoSave] = 0;
END
GO
