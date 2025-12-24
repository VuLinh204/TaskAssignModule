USE Paradise_Beta_Tai2
GO
if object_id('[dbo].[sptblCommonControlType_Signed_Linh]') is null
	EXEC ('CREATE PROCEDURE [dbo].[sptblCommonControlType_Signed_Linh] as select 1')
GO
ALTER PROCEDURE [dbo].[sptblCommonControlType_Signed_Linh]@TableName varchar(256) = ''
as
if object_Id('tempdb..#temptable') is not null drop table #temptable
select 
    t.*,
    cast('' as nvarchar(max)) html,
    cast('' as nvarchar(max)) loadUI,
    cast('' as nvarchar(max)) loadData,
    cast(pk.PKColumn as nvarchar(64)) columnId
	into #temptable
	from dbo.tblCommonControlType_Signed t
	left join (
		SELECT  
			so.name AS TableName,
			sc.name AS PKColumn
		FROM sys.objects so
		INNER JOIN sys.key_constraints kc 
			ON kc.parent_object_id = so.object_id AND kc.type = 'PK'
		INNER JOIN sys.index_columns ic
			ON ic.object_id = so.object_id AND ic.index_id = kc.unique_index_id
		INNER JOIN sys.columns sc
			ON sc.object_id = so.object_id AND sc.column_id = ic.column_id
	) pk ON pk.TableName = t.TableEditor
	where t.TableName = @TableName

-- hpaControlText
update #temptable set loadUI = N'
    if ($("#%columnName%").length === 0) {
        $("<div>", { id: "%columnName%" }).appendTo("body");
    }

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
    let %columnName%
    let %columnName%Instance
    let %columnName%OriginalValue
    let %columnName%IsEditing = false
    function loadUI%columnName%() {
        const $container = $("#%columnName%");
        const fieldId = "%columnName%";

        %columnName%OriginalValue = "";

        // Khởi tạo dxTextBox trực tiếp
        %columnName%Instance = $("<div>").appendTo($container).dxTextBox({
            value: %columnName%OriginalValue,
            width: "100%",
            inputAttr: {
                class: "form-control form-control-sm",
                style: "font-size: 14px; max-height: 100%;"
            },
            onFocusIn: function(e) {
                if (%columnName%IsEditing) return;
                %columnName%IsEditing = true;
                %columnName%OriginalValue = %columnName%Instance.option("value");

                // Thay đổi border khi focus
                $(e.element).find("input").css("border", "1px solid #1c975e");

                showActionPopup(
                    $container,
                    fieldId,
                    async () => {
                        await save%columnName%Value();
                        exit%columnName%EditMode();
                    },
                    () => {
                        exit%columnName%EditMode(true);
                    }
                );

                setTimeout(() => {
                    $(document).on("click.editmode" + fieldId, function(e) {
                        const $target = $(e.target);
                        if (!$target.closest($container).length && 
                            !$target.closest(".dx-popup-wrapper").length &&
                            !$target.closest(".dx-texteditor").length) {
                            exit%columnName%EditMode(true);
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
                if (!%columnName%IsEditing) return;
                
                if (e.event.key === "Enter") {
                    e.event.preventDefault();
                    save%columnName%Value().then(() => {
                        exit%columnName%EditMode();
                        hideActionPopup();
                    });
                } else if (e.event.key === "Escape") {
                    e.event.preventDefault();
                    exit%columnName%EditMode(true);
                    hideActionPopup();
                }
            }
        }).dxTextBox("instance");

        function exit%columnName%EditMode(cancel = false) {
            if (!%columnName%IsEditing) return;
            %columnName%IsEditing = false;

            $(document).off("click.editmode" + fieldId);

            if (cancel) {
                %columnName%Instance.option("value", %columnName%OriginalValue);
            } else {
                %columnName%OriginalValue = %columnName%Instance.option("value");
            }
        }

        async function save%columnName%Value() {
            const newValue = %columnName%Instance.option("value");

            if (newValue === %columnName%OriginalValue) {
                return;
            }

            try {
                const dataJSON = JSON.stringify([-99218308, ["%columnName%"], [newValue]]);
                
                let idValues = [[%columnId%Key.%columnId%], "%columnId%"];
                console.log("Saving %columnName% with IDValues:", idValues);
                console.log("Saving %columnName% with dataJSON:", dataJSON);
                
                const json = await saveFunction(dataJSON, idValues);
                const dtError = json.data && json.data[json.data.length - 1];

                %columnName%OriginalValue = newValue;

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
                %columnName%OriginalValue = val;
                if (%columnName%Instance) {
                    %columnName%Instance.option("value", val);
                }
            },
            getValue: function() {
                return %columnName%Instance ? %columnName%Instance.option("value") : %columnName%OriginalValue;
            }
        };
    }
    ' where [Type] = 'hpaControlText'
update #temptable set loadData =N'
    %columnName%Control = loadUI%columnName%();
    %columnName%Control.setValue(obj.%columnName%);
    %columnName%Key = { %columnId%: obj.%columnId% }' where [Type] = 'hpaControlText'

declare @object_Id varchar(max) = cast(object_Id(@TableName) as nVarchar(64))
update #temptable set loadUI =replace(loadUI,'%columnName%',[ColumnName]) where [Type] = 'hpaControlText'
update #temptable set loadUI =replace(loadUI,'%tableId%',@object_Id) where [Type] = 'hpaControlText'
update #temptable set loadUI =replace(loadUI,'%columnId%',columnId) where [Type] = 'hpaControlText'
update #temptable set loadData =replace(loadData,'%columnName%',[ColumnName]) where [Type] = 'hpaControlText'
update #temptable set loadData =replace(loadData,'%columnId%',columnId) where [Type] = 'hpaControlText'


declare @loadUI nVarchar(max) = N''
declare @loadData nVarchar(max) = N''
select @loadUI+=loadUI,@loadData+=loadData from #temptable
declare @nsql nVarchar(max) = N'
<script>
    (() => {
        '+@loadUI+N'
        
        function loadData() {
            AjaxHPAParadise({
                data: {
                    name: "%SPLoadData%",
                    param: []
                },
                success: function (res) {
                    const json = typeof res === "string" ? JSON.parse(res) : res
                    const results = (json.data && json.data[0]) || []
                    const obj = results[0]
                    '+@loadData+N'
                }
            });
        }
		loadData()
    })();
</script>'
set @nsql = replace(@nsql, '%SPLoadData%', (select top 1 SPLoadData from #temptable))
select @nsql htmlProc
GO

Exec sptblCommonControlType_Signed_Linh 'sp_Task_MyWork_html'