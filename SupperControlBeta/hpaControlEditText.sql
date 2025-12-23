USE Paradise_Beta_Tai2
GO
if object_id('[dbo].[sp_Task_MyWork_html]') is null
	EXEC ('CREATE PROCEDURE [dbo].[sp_Task_MyWork_html] as select 1')
GO

ALTER PROCEDURE [dbo].[sp_Task_MyWork_html]
    @LoginID    INT = 3,
    @LanguageID VARCHAR(2) = 'VN',
    @isWeb      INT = 1
AS
BEGIN
SET NOCOUNT ON;
DECLARE @html NVARCHAR(MAX);
SET @html = N'
    <div class="container-fluid p-3">
        <div class="row mb-3">
            <div class="col-md-6" style="position: relative;">
                <label class="form-label">Mã nhân viên</label>
                <div id="EmployeeID"></div>
            </div>
            <div class="col-md-6" style="position: relative;">
                <label class="form-label">Họ và tên</label>
                <div id="FullName"></div>
            </div>
        </div>
    </div>

    <script>
        (() => {
            let EmployeeIDKey = {}
            
            let EmployeeID
            let EmployeeIDInstance
            let EmployeeIDOriginalValue
            let EmployeeIDIsEditing = false
            
            let FullName
            let FullNameInstance
            let FullNameOriginalValue
            let FullNameIsEditing = false

            async function saveFunction(dataJSON, IDValues) {
                let data = await AjaxHPAParadiseAsync({
                    data: {
                        name: "sp_Common_SaveDataTable",
                        param: [
                            "LanguageID", window.LanguageID,
                            "DataJSON", dataJSON,
                            "IDValues", IDValues
                        ],
                    },
                });
                return typeof data === "string" ? JSON.parse(data) : data;
            }

            function loadUIEmployeeID() {
                const $container = $("#EmployeeID");
                const fieldId = "EmployeeID";
                
                EmployeeIDOriginalValue = "";

                const $textDisplay = $(`<div class="editable-text" style="padding: 6px 8px; font-size: 14px; cursor: pointer; border: 1px solid transparent; border-radius: 4px; min-height: 34px;">${EmployeeIDOriginalValue}</div>`);
                $container.append($textDisplay);

                // Tạo popup ngay trong container
                const $popupContainer = $(`<div id="actionPopup_${fieldId}">`).appendTo($container);
                const actionPopup = $popupContainer.dxPopup({
                    width: "auto",
                    height: "auto",
                    showTitle: false,
                    visible: false,
                    dragEnabled: false,
                    hideOnOutsideClick: false,
                    showCloseButton: false,
                    shading: false,
                    position: {
                        at: "bottom right",
                        my: "top right",
                        collision: "fit flip",
                        offset: "0 4",
                        of: $container
                    },
                    contentTemplate: function() {
                        return $(`<div class="d-flex" style="gap: .5rem; padding: 8px 12px;">`).append(
                            $("<div>").dxButton({
                                icon: "check",
                                hint: "Lưu",
                                stylingMode: "contained",
                                type: "success",
                                width: 28,
                                height: 28,
                                elementAttr: {
                                    style: "border-radius: 6px !important;"
                                },
                                onClick: async function() {
                                    await saveEmployeeIDValue();
                                    exitEmployeeIDEditMode();
                                    actionPopup.hide();
                                }
                            }),
                            $("<div>").dxButton({
                                icon: "close",
                                hint: "Hủy",
                                stylingMode: "outlined",
                                type: "normal",
                                width: 28,
                                height: 28,
                                elementAttr: {
                                    style: "border-radius: 6px !important;"
                                },
                                onClick: function() {
                                    exitEmployeeIDEditMode(true);
                                    actionPopup.hide();
                                }
                            })
                        );
                    }
                }).dxPopup("instance");

                $textDisplay.on("click", function(e) {
                    e.stopPropagation();
                    initEmployeeIDTextBox();
                });

                function initEmployeeIDTextBox() {
                    if (EmployeeIDInstance) {
                        EmployeeIDInstance.element().show();
                        $textDisplay.hide();
                        EmployeeIDInstance.focus();
                        return;
                    }

                    $textDisplay.hide();

                    EmployeeIDInstance = $("<div>").appendTo($container).dxTextBox({
                        value: EmployeeIDOriginalValue,
                        width: "100%",
                        inputAttr: {
                            class: "form-control form-control-sm",
                            style: "border: 1px solid #1c975e !important; font-size: 14px; max-height: 100%;"
                        },
                        onInitialized: function(e) {
                            setTimeout(() => {
                                if (!EmployeeIDIsEditing) {
                                    e.component.focus();
                                }
                            }, 50);
                        },
                        onFocusIn: function(e) {
                            if (EmployeeIDIsEditing) return;
                            EmployeeIDIsEditing = true;
                            EmployeeIDOriginalValue = EmployeeIDInstance.option("value");

                            actionPopup.show();

                            setTimeout(() => {
                                $(document).on("click.editmode" + fieldId, function(e) {
                                    const $target = $(e.target);
                                    if (!$target.closest($container).length && 
                                        !$target.closest(".dx-popup-wrapper").length &&
                                        !$target.closest(".dx-texteditor").length) {
                                        exitEmployeeIDEditMode(true);
                                        actionPopup.hide();
                                    }
                                });
                            }, 100);
                        },
                        onKeyDown: function(e) {
                            if (!EmployeeIDIsEditing) return;
                            
                            if (e.event.key === "Enter") {
                                e.event.preventDefault();
                                saveEmployeeIDValue().then(() => {
                                    exitEmployeeIDEditMode();
                                    actionPopup.hide();
                                });
                            } else if (e.event.key === "Escape") {
                                e.event.preventDefault();
                                exitEmployeeIDEditMode(true);
                                actionPopup.hide();
                            }
                        }
                    }).dxTextBox("instance");

                    EmployeeIDInstance.focus();
                }

                function exitEmployeeIDEditMode(cancel = false) {
                    if (!EmployeeIDIsEditing) return;
                    EmployeeIDIsEditing = false;

                    $(document).off("click.editmode" + fieldId);

                    const displayValue = cancel ? EmployeeIDOriginalValue : EmployeeIDInstance.option("value");
                    
                    if (EmployeeIDInstance) {
                        EmployeeIDInstance.element().hide();
                    }
                    $textDisplay.text(displayValue).show();
                    
                    EmployeeIDOriginalValue = displayValue;
                }

                async function saveEmployeeIDValue() {
                    const newValue = EmployeeIDInstance.option("value");

                    if (newValue === EmployeeIDOriginalValue) {
                        return;
                    }

                    try {
                        const dataJSON = JSON.stringify([-99218308, ["EmployeeID"], [newValue]]);
                        
                        let idValues = [[EmployeeIDKey.EmployeeID || EmployeeIDOriginalValue], "EmployeeID"];
                        console.log("Saving EmployeeID with IDValues:", idValues);
                        console.log("Saving EmployeeID with dataJSON:", dataJSON);
                        
                        const json = await saveFunction(dataJSON, idValues);
                        const dtError = json.data && json.data[json.data.length - 1];

                        EmployeeIDOriginalValue = newValue;

                        uiManager.showAlert({
                            type: "success",
                            message: "Lưu thành công"
                        });

                        if (EmployeeIDKey) {
                            EmployeeIDKey.EmployeeID = newValue;
                        }
                    } catch (err) {
                        console.error("Save error:", err);
                        uiManager.showAlert({
                            type: "error",
                            message: "Có lỗi xảy ra khi lưu"
                        });
                    }
                }
                
                return {
                    setValue: function(val) {
                        EmployeeIDOriginalValue = val;
                        $textDisplay.text(val);
                        if (EmployeeIDInstance) {
                            EmployeeIDInstance.option("value", val);
                        }
                    },
                    getValue: function() {
                        return EmployeeIDInstance ? EmployeeIDInstance.option("value") : EmployeeIDOriginalValue;
                    }
                };
            }

            function loadUIFullName() {
                const $container = $("#FullName");
                const fieldId = "FullName";
                
                FullNameOriginalValue = "";

                const $textDisplay = $(`<div class="editable-text" style="padding: 6px 8px; font-size: 14px; cursor: pointer; border: 1px solid transparent; border-radius: 4px; min-height: 34px;">${FullNameOriginalValue}</div>`);
                $container.append($textDisplay);

                // Tạo popup ngay trong container
                const $popupContainer = $(`<div id="actionPopup_${fieldId}">`).appendTo($container);
                const actionPopup = $popupContainer.dxPopup({
                    width: "auto",
                    height: "auto",
                    showTitle: false,
                    visible: false,
                    dragEnabled: false,
                    hideOnOutsideClick: false,
                    showCloseButton: false,
                    shading: false,
                    position: {
                        at: "bottom right",
                        my: "top right",
                        collision: "fit flip",
                        offset: "0 4",
                        of: $container
                    },
                    contentTemplate: function() {
                        return $(`<div class="d-flex" style="gap: .5rem; padding: 8px 12px;">`).append(
                            $("<div>").dxButton({
                                icon: "check",
                                hint: "Lưu",
                                stylingMode: "contained",
                                type: "success",
                                width: 28,
                                height: 28,
                                elementAttr: {
                                    style: "border-radius: 6px !important;"
                                },
                                onClick: async function() {
                                    await saveFullNameValue();
                                    exitFullNameEditMode();
                                    actionPopup.hide();
                                }
                            }),
                            $("<div>").dxButton({
                                icon: "close",
                                hint: "Hủy",
                                stylingMode: "outlined",
                                type: "normal",
                                width: 28,
                                height: 28,
                                elementAttr: {
                                    style: "border-radius: 6px !important;"
                                },
                                onClick: function() {
                                    exitFullNameEditMode(true);
                                    actionPopup.hide();
                                }
                            })
                        );
                    }
                }).dxPopup("instance");

                $textDisplay.on("click", function(e) {
                    e.stopPropagation();
                    initFullNameTextBox();
                });

                function initFullNameTextBox() {
                    if (FullNameInstance) {
                        FullNameInstance.element().show();
                        $textDisplay.hide();
                        FullNameInstance.focus();
                        return;
                    }

                    $textDisplay.hide();

                    FullNameInstance = $("<div>").appendTo($container).dxTextBox({
                        value: FullNameOriginalValue,
                        width: "100%",
                        inputAttr: {
                            class: "form-control form-control-sm",
                            style: "border: 1px solid #1c975e !important; font-size: 14px; max-height: 100%;"
                        },
                        onInitialized: function(e) {
                            setTimeout(() => {
                                if (!FullNameIsEditing) {
                                    e.component.focus();
                                }
                            }, 50);
                        },
                        onFocusIn: function(e) {
                            if (FullNameIsEditing) return;
                            FullNameIsEditing = true;
                            FullNameOriginalValue = FullNameInstance.option("value");

                            actionPopup.show();

                            setTimeout(() => {
                                $(document).on("click.editmode" + fieldId, function(e) {
                                    const $target = $(e.target);
                                    if (!$target.closest($container).length && 
                                        !$target.closest(".dx-popup-wrapper").length &&
                                        !$target.closest(".dx-texteditor").length) {
                                        exitFullNameEditMode(true);
                                        actionPopup.hide();
                                    }
                                });
                            }, 100);
                        },
                        onKeyDown: function(e) {
                            if (!FullNameIsEditing) return;
                            
                            if (e.event.key === "Enter") {
                                e.event.preventDefault();
                                saveFullNameValue().then(() => {
                                    exitFullNameEditMode();
                                    actionPopup.hide();
                                });
                            } else if (e.event.key === "Escape") {
                                e.event.preventDefault();
                                exitFullNameEditMode(true);
                                actionPopup.hide();
                            }
                        }
                    }).dxTextBox("instance");

                    FullNameInstance.focus();
                }

                function exitFullNameEditMode(cancel = false) {
                    if (!FullNameIsEditing) return;
                    FullNameIsEditing = false;

                    $(document).off("click.editmode" + fieldId);

                    const displayValue = cancel ? FullNameOriginalValue : FullNameInstance.option("value");
                    
                    if (FullNameInstance) {
                        FullNameInstance.element().hide();
                    }
                    $textDisplay.text(displayValue).show();
                    
                    FullNameOriginalValue = displayValue;
                }

                async function saveFullNameValue() {
                    const newValue = FullNameInstance.option("value");

                    if (newValue === FullNameOriginalValue) {
                        return;
                    }

                    try {
                        const dataJSON = JSON.stringify([-99218308, ["FullName"], [newValue]]);
                        
                        let idValues = [[EmployeeIDKey.EmployeeID], "EmployeeID"];
                        
                        const json = await saveFunction(dataJSON, idValues);
                        const dtError = json.data && json.data[json.data.length - 1];

                        FullNameOriginalValue = newValue;

                        uiManager.showAlert({
                            type: "success",
                            message: "Lưu thành công"
                        });
                    } catch (err) {
                        console.error("Save error:", err);
                        uiManager.showAlert({
                            type: "error",
                            message: "Có lỗi xảy ra khi lưu"
                        });
                    }
                }
                
                return {
                    setValue: function(val) {
                        FullNameOriginalValue = val;
                        $textDisplay.text(val);
                        if (FullNameInstance) {
                            FullNameInstance.option("value", val);
                        }
                    },
                    getValue: function() {
                        return FullNameInstance ? FullNameInstance.option("value") : FullNameOriginalValue;
                    }
                };
            }

            function loadUI() {
                EmployeeID = loadUIEmployeeID()
                FullName = loadUIFullName()
            }

            function loadData() {
                AjaxHPAParadise({
                    data: {
                        name: "sp_Task_GetAllTasks",
                        param: []
                    },
                    success: function (res) {
                        const json = typeof res === "string" ? JSON.parse(res) : res;
                        const results = (json.data && json.data[0]) || [];
                        const obj = results[0];
                        EmployeeIDKey = { "EmployeeID": obj.EmployeeID };
                        loadUI();
                        
                        EmployeeID.setValue(obj.EmployeeID);
                        FullName.setValue(obj.FullName);
                    }
                });
            }

            $(document).ready(function() {
                loadData();
            });
        })();
    </script>
';
    SELECT @html AS html;
END
GO

EXEC sp_GenerateHTMLScript 'sp_Task_MyWork_html'