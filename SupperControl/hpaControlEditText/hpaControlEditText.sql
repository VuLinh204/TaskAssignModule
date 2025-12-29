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
    </script>

    <script>
        (() => {
            let actionPopup = null;
            let currentField = null;
            let currentFieldId = null;
            let saveCallback = null;
            let cancelCallback = null;
            
            function initActionPopup() {
                actionPopup = $(`<div id="actionPopup">`).appendTo("body").dxPopup({
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
                        offset: "0 4"
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
                                    if (saveCallback) {
                                        await saveCallback();
                                    }
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
                                    if (cancelCallback) {
                                        cancelCallback();
                                    }
                                    actionPopup.hide();
                                }
                            })
                        );
                    },
                    onHiding: function() {
                        currentField = null;
                        currentFieldId = null;
                        saveCallback = null;
                        cancelCallback = null;
                    }
                }).dxPopup("instance");
            }

            function showActionPopup(targetElement, fieldId, onSave, onCancel) {
                if (!actionPopup) {
                    initActionPopup();
                }
                
                if (currentFieldId && currentFieldId !== fieldId) {
                    if (cancelCallback) {
                        cancelCallback();
                    }
                }
                
                saveCallback = onSave;
                cancelCallback = onCancel;
                currentField = targetElement;
                currentFieldId = fieldId;
                
                actionPopup.option("position.of", targetElement);
                actionPopup.show();
            }

            function hideActionPopup() {
                if (actionPopup && actionPopup.option("visible")) {
                    actionPopup.hide();
                }
            }

            let EmployeeID
            let EmployeeIDInstance
            let EmployeeIDOriginalValue
            let EmployeeIDIsEditing = false
            function loadUIEmployeeID() {
                const $container = $("#EmployeeID");
                const fieldId = "EmployeeID";
                
                EmployeeIDOriginalValue = "";

                // Khởi tạo dxTextBox trực tiếp với readOnly
                EmployeeIDInstance = $("<div>").appendTo($container).dxTextBox({
                    value: EmployeeIDOriginalValue,
                    width: "100%",
                    readOnly: true,
                    inputAttr: {
                        class: "form-control form-control-sm",
                        style: "font-size: 14px; max-height: 100%;"
                    }
                }).dxTextBox("instance");
            }

            let FullName
            let FullNameInstance
            let FullNameOriginalValue
            let FullNameIsEditing = false
            function loadUIFullName() {
                const $container = $("#FullName");
                const fieldId = "FullName";
                
                FullNameOriginalValue = "";

                // Khởi tạo dxTextBox trực tiếp
                FullNameInstance = $("<div>").appendTo($container).dxTextBox({
                    value: FullNameOriginalValue,
                    width: "100%",
                    inputAttr: {
                        class: "form-control form-control-sm",
                        style: "font-size: 14px; max-height: 100%;"
                    },
                    onFocusIn: function(e) {
                        if (FullNameIsEditing) return;
                        FullNameIsEditing = true;
                        FullNameOriginalValue = FullNameInstance.option("value");

                        // Thay đổi border khi focus
                        $(e.element).find("input").css("border", "1px solid #1c975e");

                        showActionPopup(
                            $container,
                            fieldId,
                            async () => {
                                await saveFullNameValue();
                                exitFullNameEditMode();
                            },
                            () => {
                                exitFullNameEditMode(true);
                            }
                        );

                        setTimeout(() => {
                            $(document).on("click.editmode" + fieldId, function(e) {
                                const $target = $(e.target);
                                if (!$target.closest($container).length && 
                                    !$target.closest(".dx-popup-wrapper").length &&
                                    !$target.closest(".dx-texteditor").length) {
                                    exitFullNameEditMode(true);
                                    hideActionPopup();
                                }
                            });
                        }, 100);
                    },
                    onFocusOut: function(e) {
                        // Reset border khi blur
                        $(e.element).find("input").css("border", "");
                    },
                    onKeyDown: function(e) {
                        if (!FullNameIsEditing) return;
                        
                        if (e.event.key === "Enter") {
                            e.event.preventDefault();
                            saveFullNameValue().then(() => {
                                exitFullNameEditMode();
                                hideActionPopup();
                            });
                        } else if (e.event.key === "Escape") {
                            e.event.preventDefault();
                            exitFullNameEditMode(true);
                            hideActionPopup();
                        }
                    }
                }).dxTextBox("instance");

                function exitFullNameEditMode(cancel = false) {
                    if (!FullNameIsEditing) return;
                    FullNameIsEditing = false;

                    $(document).off("click.editmode" + fieldId);

                    if (cancel) {
                        FullNameInstance.option("value", FullNameOriginalValue);
                    } else {
                        FullNameOriginalValue = FullNameInstance.option("value");
                    }
                }

                async function saveFullNameValue() {
                    const newValue = FullNameInstance.option("value");

                    if (newValue === FullNameOriginalValue) {
                        return;
                    }

                    try {
                        const dataJSON = JSON.stringify([-99218308, ["FullName"], [newValue]]);
                        
                        let idValues = [[EmployeeIDKey.EmployeeID], "EmployeeID"];
                        console.log("Saving FullName with IDValues:", idValues);
                        console.log("Saving FullName with dataJSON:", dataJSON);
                        
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
                loadUIEmployeeID()
                loadUIFullName()
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
                        let EmployeeIDKey = { "EmployeeID": obj.EmployeeID };
                        
                        // Set giá trị trực tiếp vào instance
                        EmployeeIDOriginalValue = obj.EmployeeID;
                        EmployeeIDInstance.option("value", obj.EmployeeID);
                        
                        FullNameOriginalValue = obj.FullName;
                        FullNameInstance.option("value", obj.FullName);
                    }
                });
            }

            loadUI();
            loadData();
        })();
    </script>
';
    SELECT @html AS html;
END
GO

EXEC sp_GenerateHTMLScript 'sp_Task_MyWork_html'