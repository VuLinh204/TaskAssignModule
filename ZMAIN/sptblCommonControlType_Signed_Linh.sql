USE Paradise_Beta_Tai2
GO
IF OBJECT_ID('[dbo].[sptblCommonControlType_Signed_Linh]') IS NULL
	EXEC ('CREATE PROCEDURE [dbo].[sptblCommonControlType_Signed_Linh] AS SELECT 1')
GO

ALTER PROCEDURE [dbo].[sptblCommonControlType_Signed_Linh]
    @TableName VARCHAR(256) = ''
AS
BEGIN
    -- Thắng: Kiểm tra có sử dụng layout hay không
    DECLARE @UseLayout BIT = 0;
    IF EXISTS (
        SELECT 1
        FROM dbo.tblCommonControlType_Signed
        WHERE TableName = @TableName
          AND Layout IS NOT NULL
    )
    BEGIN
        SET @UseLayout = 1;
    END
    DECLARE @object_Id VARCHAR(MAX) = CAST(OBJECT_ID(@TableName) AS NVARCHAR(64))
    -- Tạo bảng tạm
    IF OBJECT_ID('tempdb..#temptable') IS NOT NULL DROP TABLE #temptable

    SELECT
        t.*,
        CAST('' AS NVARCHAR(MAX)) AS html,
        CAST('' AS NVARCHAR(MAX)) AS loadUI,
        CAST('' AS NVARCHAR(MAX)) AS loadData,
        CAST('' AS NVARCHAR(MAX)) AS loadUILayout,
        CAST(c.column_id AS NVARCHAR(64)) AS columnId
    INTO #temptable
    FROM dbo.tblCommonControlType_Signed t
    LEFT JOIN sys.columns c ON c.name = t.[ColumnName] AND c.object_id = OBJECT_ID(t.TableEditor)
    WHERE TableName = @TableName

	-- select * from #temptable return

    -- CardView Container
    UPDATE t1 SET loadUI = N'
        let%Layout%Instance = $("#%Layout%").dxList({
            dataSource: [],
            height: "100%",
            scrolling: { mode: "virtual" },
            noDataText: "Không có dữ liệu",
            itemTemplate: function(data, index, element) {
                const $card = $("<div>").addClass("hpa-card-item").css({
                    "padding": "10px",
                    "margin-bottom": "10px",
                    "border": "1px solid #ddd",
                    "border-radius": "8px",
                    "box-shadow": "0 2px 4px rgba(0,0,0,0.05)"
                });

                $("<div>").dxForm({
                    formData: data,
                    readOnly: false,
                    labelLocation: "top",
                    colCount: 1,
                    items: [],
                    onFieldDataChanged: async function(e) {
                        const colName = e.dataField;
                        let val = e.value;
                        const recordID = e.component.option("formData").%PKColumnName%;
                        const itemOption = e.component.itemOption(colName);
                        if (itemOption.editorType === "dxDateBox") {
                            if (itemOption.editorOptions.type === "date" && val) {
                                val = DevExpress.localization.formatDate(new Date(val), "yyyy/MM/dd");
                            } else if (itemOption.editorOptions.type === "time" && val) {
                                val = DevExpress.localization.formatDate(new Date(val), "HH:mm");
                            }
                        } else if (itemOption.editorType === "dxTextBox" && itemOption.editorOptions.mode === "tel") {
                             val = val ? val.replace(/[^0-9+]/g, "") : "";
                        }

                        const dataJSON = JSON.stringify(["%tableId%", [colName], [val]]);
                        const idValuesJSON = JSON.stringify([[recordID], "%columnIDName%"]);

                        try {
                           const json = await saveFunction(dataJSON, idValuesJSON);
                           const dtError = json.data[json.data.length - 1] || [];
                           if (dtError.length > 0 && dtError[0].Status === "ERROR") {
                               uiManager.showAlert({ type: "error", message: dtError[0]?.Message || "Lưu thất bại" });
                           }
                        } catch (err) {
                           console.error("AutoSave Error:", err);
                        }
                    }
                }).appendTo($card);

                return $card;
            }
        }).dxList("instance");
    '
    FROM #temptable t1
    WHERE t1.ID = (
        SELECT TOP 1 ID
        FROM #temptable
        WHERE CardView = 1 AND Layout = 'Card_View'
        ORDER BY ID
    )

    UPDATE t1 SET html = N'
        <div id="%Layout%" style="height: 100%;"></div>
        '
    FROM #temptable t1
    WHERE t1.ID = (
        SELECT TOP 1 ID
        FROM #temptable
        WHERE CardView = 1 AND Layout = 'Card_View'
        ORDER BY ID
    )

    -- LoadUILayout cho CardView - DateBox
    UPDATE #temptable SET loadUILayout = N'
        {
            dataField: "%columnName%",
            label: { text: "%DisplayName%" },
            editorType: "dxDateBox",
            editorOptions: {
                type: "date",
                displayFormat: "dd/MM/yyyy",
                useMaskBehavior: true,
                dateSerializationFormat: "yyyy-MM-dd",
                readOnly:%ReadOnly%
            }
        },'
    WHERE [Type] = 'hpaControlDate' AND CardView = 1

    -- LoadUILayout cho CardView - TimeBox
    UPDATE #temptable SET loadUILayout = N'
        {
            dataField: "%columnName%",
            label: { text: "%DisplayName%" },
            editorType: "dxDateBox",
            editorOptions: {
                type: "time",
                displayFormat: "HH:mm",
                pickerType: "rollers",
                useMaskBehavior: true,
                readOnly:%ReadOnly%
            }
        },'
    WHERE [Type] = 'hpaControlTime' AND CardView = 1

    -- LoadUILayout cho CardView - PhoneBox
    UPDATE #temptable SET loadUILayout = N'
        {
            dataField: "%columnName%",
            label: { text: "%DisplayName%" },
            editorType: "dxTextBox",
            editorOptions: {
                mode: "tel",
                readOnly:%ReadOnly%
            }
        },'
    WHERE [Type] = 'hpaControlPhone' AND CardView = 1

    -- LoadUILayout cho CardView - NumberBox
    UPDATE #temptable SET loadUILayout = N'
        {
            dataField: "%columnName%",
            label: { text: "%DisplayName%" },
            editorType: "dxNumberBox",
            editorOptions: {
                format: "#,##0",
                showSpinButtons: false,
                readOnly:%ReadOnly%
            }
        },'
    WHERE [Type] = 'hpaControlNumber' AND CardView = 1

    -- LoadUILayout cho CardView - MoneyBox
    UPDATE #temptable SET loadUILayout = N'
        {
            dataField: "%columnName%",
            label: { text: "%DisplayName%" },
            editorType: "dxNumberBox",
            editorOptions: {
                format: "#,##0 ₫",
                showSpinButtons: false,
                readOnly:%ReadOnly%
            }
        },'
    WHERE [Type] = 'hpaControlMoney' AND CardView = 1

    --CONTROL THÔNG THƯỜNG (NON-LAYOUT)
    -- ControlDateBox AutoSave
    UPDATE #temptable SET loadUI = N'
        //ControlDateBox AutoSave
        let%IDDiv%Instance
        let%IDDiv%TimeOut

        async function%IDDiv%SaveLogic() {
            let val =%IDDiv%Instance.option("value");
            let valToSave = val ? DevExpress.localization.formatDate(new Date(val), "yyyy/MM/dd") : null;
            const dataJSON = JSON.stringify(["%tableId%", ["%columnName%"], [valToSave]]);
            const idValuesJSON = JSON.stringify([[currentRecordID], "%columnIDName%"]);
            const json = await saveFunction(dataJSON, idValuesJSON);
            const dtError = json.data[json.data.length - 1] || [];
            if (dtError.length > 0 && dtError[0].Status === "ERROR") {
                uiManager.showAlert({ type: "error", message: dtError[0]?.Message || "Lưu thất bại" });
                return;
            }
        }

        %IDDiv%Instance = $("#%IDDiv%").dxDateBox({
            type: "date",
            displayFormat: "dd/MM/yyyy",
            useMaskBehavior: true,
            openOnFieldClick: true,
            showClearButton: false,
            dateSerializationFormat: "yyyy-MM-dd",
            width: "100%",
            elementAttr: { class: "hpa-dx-datebox-inline" },
            onValueChanged: async (e) => {
                clearTimeout(%IDDiv%TimeOut);
                e.event && await%IDDiv%SaveLogic();
            },
           onKeyUp: (e) => {
                clearTimeout(%IDDiv%TimeOut);
          %IDDiv%TimeOut = setTimeout(async () =>%IDDiv%SaveLogic(), 1000);
            }
        }).dxDateBox("instance")
        '
    WHERE [Type] = 'hpaControlDate' AND AutoSave = 1 AND Layout IS NULL

    -- ControlDateBox ReadOnly
    UPDATE #temptable SET loadUI = N'
        //ControlDateBox ReadOnly
        let%IDDiv%Instance = $("#%IDDiv%").dxDateBox({
            type: "date",
            displayFormat: "dd/MM/yyyy",
            useMaskBehavior: true,
            openOnFieldClick: true,
            showClearButton: false,
            dateSerializationFormat: "yyyy-MM-dd",
            width: "100%",
            elementAttr: { class: "hpa-dx-datebox-inline" },
            readOnly: true,
        }).dxDateBox("instance")
        '
    WHERE [Type] = 'hpaControlDate' AND ReadOnly = 1 AND Layout IS NULL

    -- ControlDateBox Non-AutoSave
    UPDATE #temptable SET loadUI = N'
        //ControlDateBox Non-AutoSave
        let%IDDiv%Instance = $("#%IDDiv%").dxDateBox({
            type: "date",
            displayFormat: "dd/MM/yyyy",
            useMaskBehavior: true,
            openOnFieldClick: true,
            showClearButton: false,
            dateSerializationFormat: "yyyy-MM-dd",
            width: "100%",
            elementAttr: { class: "hpa-dx-datebox-inline" },
        }).dxDateBox("instance")
        '
    WHERE [Type] = 'hpaControlDate' AND (AutoSave = 0 OR AutoSave IS NULL) AND (ReadOnly = 0 OR ReadOnly IS NULL) AND Layout IS NULL

    -- ControlTimeBox AutoSave
    UPDATE #temptable SET loadUI = N'
        //ControlTimeBox AutoSave
        let%IDDiv%Instance
        let%IDDiv%TimeOut
        async function%IDDiv%SaveLogic() {
            let val =%IDDiv%Instance.option("value");
            const timeString = val ? DevExpress.localization.formatDate(val, "HH:mm") : "";
            const dataJSON = JSON.stringify(["%tableId%", ["%columnName%"], [timeString]]);
            const idValuesJSON = JSON.stringify([[currentRecordID], "%columnIDName%"]);
            const json = await saveFunction(dataJSON, idValuesJSON);
            const dtError = json.data[json.data.length - 1] || [];
            if (dtError.length > 0 && dtError[0].Status === "ERROR") {
                uiManager.showAlert({ type: "error", message: dtError[0]?.Message || "Lưu thất bại" });
                return;
            }
        }

        %IDDiv%Instance = $("#%IDDiv%").dxDateBox({
            type: "time",
            displayFormat: "HH:mm",
            pickerType: "rollers",
            useMaskBehavior: true,
            showClearButton: false,
            width: "100%",
            elementAttr: { class: "hpa-dx-timebox-inline" },
            onValueChanged: async (e) => {
                clearTimeout(%IDDiv%TimeOut);
                e.event && await%IDDiv%SaveLogic();
            },
            onKeyUp: (e) => {
                clearTimeout(%IDDiv%TimeOut);
          %IDDiv%TimeOut = setTimeout(async () =>%IDDiv%SaveLogic(), 1000);
            }
        }).dxDateBox("instance")
        '
    WHERE [Type] = 'hpaControlTime' AND AutoSave = 1 AND Layout IS NULL

    -- ControlTimeBox ReadOnly
    UPDATE #temptable SET loadUI = N'
        //ControlTimeBox ReadOnly
        let%IDDiv%Instance = $("#%IDDiv%").dxDateBox({
            type: "time",
            displayFormat: "HH:mm",
            pickerType: "rollers",
            useMaskBehavior: true,
            showClearButton: true,
            width: "100%",
            elementAttr: { class: "hpa-dx-timebox-inline" },
            readOnly: true,
        }).dxDateBox("instance")
        '
    WHERE [Type] = 'hpaControlTime' AND ReadOnly = 1 AND Layout IS NULL

    -- ControlTimeBox Non-AutoSave
    UPDATE #temptable SET loadUI = N'
        //ControlTimeBox Non-AutoSave
        let%IDDiv%Instance = $("#%IDDiv%").dxDateBox({
            type: "time",
            displayFormat: "HH:mm",
            pickerType: "rollers",
            useMaskBehavior: true,
            showClearButton: true,
            width: "100%",
            elementAttr: { class: "hpa-dx-timebox-inline" },
        }).dxDateBox("instance")
        '
    WHERE [Type] = 'hpaControlTime' AND (AutoSave = 0 OR AutoSave IS NULL) AND (ReadOnly = 0 OR ReadOnly IS NULL) AND Layout IS NULL

    -- ControlPhoneBox AutoSave
    UPDATE #temptable SET loadUI = N'
        //ControlPhoneBox AutoSave
        let%IDDiv%Instance
        let%IDDiv%TimeOut
        async function%IDDiv%SaveLogic() {
            let currentVal =%IDDiv%Instance.option("value") || "";
            let cleanVal = currentVal.replace(/[^0-9+]/g, "");
            const dataJSON = JSON.stringify(["%tableId%", ["%columnName%"], [cleanVal]]);
            const idValuesJSON = JSON.stringify([[currentRecordID], "%columnIDName%"]);
            const json = await saveFunction(dataJSON, idValuesJSON);
            const dtError = json.data[json.data.length - 1] || [];
            if (dtError.length > 0 && dtError[0].Status === "ERROR") {
                uiManager.showAlert({ type: "error", message: dtError[0]?.Message || "Lưu thất bại" });
                return;
            }
        }

        %IDDiv%Instance = $("#%IDDiv%").dxTextBox({
            mode: "tel",
            showClearButton: false,
            width: "100%",
            elementAttr: { class: "hpa-dx-textbox-inline" },
            onKeyDown: function(e) {
                const regex = /^[0-9+]$|^Backspace$|^Delete$|^Tab$|^Enter$|^Arrow|^Home$|^End$/;
                regex.test(e.event.key) ? null : e.event.preventDefault();
            },
            onValueChanged: async (e) => {
                clearTimeout(%IDDiv%TimeOut);
                e.event && await%IDDiv%SaveLogic();
            },
            onKeyUp: (e) => {
                clearTimeout(%IDDiv%TimeOut);
          %IDDiv%TimeOut = setTimeout(async () =>%IDDiv%SaveLogic(), 1000);
            }
        }).dxTextBox("instance")
        '
    WHERE [Type] = 'hpaControlPhone' AND AutoSave = 1 AND Layout IS NULL

    -- ControlPhoneBox ReadOnly
    UPDATE #temptable SET loadUI = N'
        //ControlPhoneBox ReadOnly
        let%IDDiv%Instance = $("#%IDDiv%").dxTextBox({
            mode: "tel",
            showClearButton: false,
            width: "100%",
            elementAttr: { class: "hpa-dx-textbox-inline" },
            readOnly: true,
        }).dxTextBox("instance")
        '
    WHERE [Type] = 'hpaControlPhone' AND ReadOnly = 1 AND Layout IS NULL

    -- ControlPhoneBox Non-AutoSave
    UPDATE #temptable SET loadUI = N'
        //ControlPhoneBox Non-AutoSave
        let%IDDiv%Instance = $("#%IDDiv%").dxTextBox({
            mode: "tel",
            showClearButton: false,
            width: "100%",
            elementAttr: { class: "hpa-dx-textbox-inline" },
            onKeyDown: function(e) {
                const regex = /^[0-9+]$|^Backspace$|^Delete$|^Tab$|^Enter$|^Arrow|^Home$|^End$/;
                regex.test(e.event.key) ? null : e.event.preventDefault();
            }
        }).dxTextBox("instance")
        '
    WHERE [Type] = 'hpaControlPhone' AND (AutoSave = 0 OR AutoSave IS NULL) AND (ReadOnly = 0 OR ReadOnly IS NULL) AND Layout IS NULL

    -- ControlNumberBox AutoSave
    UPDATE #temptable SET loadUI = N'
        //ControlNumberBox AutoSave
        let%IDDiv%Instance
        let%IDDiv%TimeOut
        async function%IDDiv%SaveLogic() {
            let val =%IDDiv%Instance.option("value");
            const dataJSON = JSON.stringify(["%tableId%", ["%columnName%"], [val]]);
            const idValuesJSON = JSON.stringify([[currentRecordID], "%columnIDName%"]);
            const json = await saveFunction(dataJSON, idValuesJSON);
            const dtError = json.data[json.data.length - 1] || [];
            if (dtError.length > 0 && dtError[0].Status === "ERROR") {
                uiManager.showAlert({ type: "error", message: dtError[0]?.Message || "Lưu thất bại" });
                return;
            }
        }

        %IDDiv%Instance = $("#%IDDiv%").dxNumberBox({
            format: "#,##0",
            showSpinButtons: false,
            showClearButton: false,
            width: "100%",
            elementAttr: { class: "hpa-dx-numberbox-inline" },
            onValueChanged: async (e) => {
                clearTimeout(%IDDiv%TimeOut);
                e.event && await%IDDiv%SaveLogic();
            },
            onKeyUp: (e) => {
                clearTimeout(%IDDiv%TimeOut);
          %IDDiv%TimeOut = setTimeout(async () =>%IDDiv%SaveLogic(), 1000);
            }
        }).dxNumberBox("instance")
        '
    WHERE [Type] = 'hpaControlNumber' AND AutoSave = 1 AND Layout IS NULL

    -- ControlNumberBox ReadOnly
    UPDATE #temptable SET loadUI = N'
        //ControlNumberBox ReadOnly
        let%IDDiv%Instance = $("#%IDDiv%").dxNumberBox({
            format: "#,##0",
            showSpinButtons: false,
            showClearButton: false,
            width: "100%",
            elementAttr: { class: "hpa-dx-numberbox-inline" },
            readOnly: true,
        }).dxNumberBox("instance")
        '
    WHERE [Type] = 'hpaControlNumber' AND ReadOnly = 1 AND Layout IS NULL

    -- ControlNumberBox Non-AutoSave
    UPDATE #temptable SET loadUI = N'
        //ControlNumberBox Non-AutoSave
        let%IDDiv%Instance = $("#%IDDiv%").dxNumberBox({
            format: "#,##0",
            showSpinButtons: false,
            showClearButton: false,
            width: "100%",
            elementAttr: { class: "hpa-dx-numberbox-inline" },
        }).dxNumberBox("instance")
        '
    WHERE [Type] = 'hpaControlNumber' AND (AutoSave = 0 OR AutoSave IS NULL) AND (ReadOnly = 0 OR ReadOnly IS NULL) AND Layout IS NULL

    -- ControlMoneyBox AutoSave
    UPDATE #temptable SET loadUI = N'
        //ControlMoneyBox AutoSave
        let%IDDiv%Instance
        let%IDDiv%TimeOut
        async function%IDDiv%SaveLogic() {
            let val =%IDDiv%Instance.option("value");
            const dataJSON = JSON.stringify(["%tableId%", ["%columnName%"], [val]]);
            const idValuesJSON = JSON.stringify([[currentRecordID], "%columnIDName%"]);
            const json = await saveFunction(dataJSON, idValuesJSON);
            const dtError = json.data[json.data.length - 1] || [];
            if (dtError.length > 0 && dtError[0].Status === "ERROR") {
                uiManager.showAlert({ type: "error", message: dtError[0]?.Message || "Lưu thất bại" });
                return;
            }
        }

        %IDDiv%Instance = $("#%IDDiv%").dxNumberBox({
            format: "#,##0 ₫",
            showSpinButtons: false,
            showClearButton: false,
            width: "100%",
            elementAttr: { class: "hpa-dx-numberbox-inline" },
            onValueChanged: async (e) => {
                clearTimeout(%IDDiv%TimeOut);
                e.event && await%IDDiv%SaveLogic();
            },
            onKeyUp: (e) => {
                clearTimeout(%IDDiv%TimeOut);
          %IDDiv%TimeOut = setTimeout(async () =>%IDDiv%SaveLogic(), 1000);
            }
        }).dxNumberBox("instance")
        '
    WHERE [Type] = 'hpaControlMoney' AND AutoSave = 1 AND Layout IS NULL

    -- ControlMoneyBox ReadOnly
    UPDATE #temptable SET loadUI = N'
        //ControlMoneyBox ReadOnly
        let%IDDiv%Instance = $("#%IDDiv%").dxNumberBox({
            format: "#,##0 ₫",
            showSpinButtons: false,
            showClearButton: false,
            width: "100%",
            elementAttr: { class: "hpa-dx-numberbox-inline" },
            readOnly: true,
        }).dxNumberBox("instance")
  '
    WHERE [Type] = 'hpaControlMoney' AND ReadOnly = 1 AND Layout IS NULL

    -- ControlMoneyBox Non-AutoSave
    UPDATE #temptable SET loadUI = N'
        //ControlMoneyBox Non-AutoSave
        let%IDDiv%Instance = $("#%IDDiv%").dxNumberBox({
            format: "#,##0 ₫",
            showSpinButtons: false,
            showClearButton: false,
            width: "100%",
            elementAttr: { class: "hpa-dx-numberbox-inline" },
        }).dxNumberBox("instance")
        '
    WHERE [Type] = 'hpaControlMoney' AND (AutoSave = 0 OR AutoSave IS NULL) AND (ReadOnly = 0 OR ReadOnly IS NULL) AND Layout IS NULL

    UPDATE #temptable SET html = N'
        <div id="%IDDiv%"></div>
        '
    WHERE [Type] IN ('hpaControlDate', 'hpaControlTime', 'hpaControlPhone', 'hpaControlNumber', 'hpaControlMoney') AND Layout IS NULL

    UPDATE #temptable SET loadData = N'
        %IDDiv%Instance._suppressValueChangeAction()
        %IDDiv%Instance.option("value", obj.%columnName%)
        %IDDiv%Instance._resumeValueChangeAction()'
    WHERE [Type] IN ('hpaControlDate', 'hpaControlPhone', 'hpaControlNumber', 'hpaControlMoney') AND Layout IS NULL

    UPDATE #temptable SET loadData = N'
        %IDDiv%Instance._suppressValueChangeAction()
        %IDDiv%Instance.option("value", obj.%columnName%? new Date("1970/01/01 " + obj.%columnName%) : null)
        %IDDiv%Instance._resumeValueChangeAction()'
    WHERE [Type] = 'hpaControlTime' AND Layout IS NULL


    -- =====================================================================

    -- Linh: hpaControlText Manual
    UPDATE #temptable SET loadUI = N'
        if ($("#%IDDiv%").length === 0) {
            $("<div>", {
                id: "%IDDiv%"
            }).appendTo("body");
        }
        let actionPopup%columnName%= null;
        let currentField%columnName%= null;
        let currentFieldId%columnName%= null;
        let saveCallback%columnName%= null;
        let cancelCallback%columnName%= null;

        function initActionPopup() {
            actionPopup%columnName%= $(`<div id="actionPopup%columnName%">`).appendTo("body").dxPopup({
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
                                if (saveCallback%columnName%) await saveCallback%columnName%();
                                actionPopup%columnName%.hide();
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
                                if (cancelCallback%columnName%) cancelCallback%columnName%();
                                actionPopup%columnName%.hide();
                            }
                        })
                    );
                },
                onHiding: function() {
                    currentField%columnName%= currentFieldId%columnName%= saveCallback%columnName%= cancelCallback%columnName%= null;
                }
            }).dxPopup("instance");
        }

        function showActionPopup(target, fieldId, onSave, onCancel) {
            if (!actionPopup%columnName%) initActionPopup();
            if (currentFieldId%columnName%&& currentFieldId%columnName%!== fieldId && cancelCallback%columnName%) cancelCallback%columnName%();
            saveCallback%columnName%= onSave;
            cancelCallback%columnName%= onCancel;
            currentField%columnName%= target;
            currentFieldId%columnName%= fieldId;
            actionPopup%columnName%.option("position.of", target);
            actionPopup%columnName%.show();
        }
        let%columnName%Instance,%columnName%OriginalValue,%columnName%IsEditing = false;

        function loadUI%columnName%() {
            const $container = $("#%IDDiv%");
            const fieldId = "%columnName%";
            /*BEGIN_DX*/
            %columnName%Instance = $("<div>").appendTo($container).dxTextBox({
                value:%columnName%OriginalValue || "",
                width: "100%",
                inputAttr: {
                    class: "form-control form-control-sm",
                    style: "font-size: 14px; max-height: 100%;"
                },
                onFocusIn: function(e) {
                    if (%columnName%IsEditing) return;%
                    columnName%IsEditing = true;%
                    columnName%OriginalValue =%columnName%Instance.option("value");
                    $(e.element).find("input").css("border", "1px solid #1c975e");
                    showActionPopup($container, fieldId,
                        async () => {
                                await saveValue%columnName%();
                                exitEdit%columnName%();
                            },
                            () => exitEdit%columnName%(true)
                    );
                    setTimeout(() => {
                        $(document).on("click.editmode" + fieldId, function(ev) {
                            const $t = $(ev.target);
                            if (!$t.closest($container).length && !$t.closest(".dx-popup-wrapper").length && !$t.closest(".dx-texteditor").length) {
                                exitEdit%columnName%(true);
                            }
                        });
                    }, 100);
                },
                onFocusOut: function(e) {
                    $(e.element).find("input").css("border", "");
                },
                onKeyDown: function(e) {
                    if (!%columnName%IsEditing) return;
                    if (e.event.key === "Enter") {
                        e.event.preventDefault();
                        saveValue%columnName%().then(() => exitEdit%columnName%());
                    }
                    if (e.event.key === "Escape") {
                        e.event.preventDefault();
                        exitEdit%columnName%(true);
                    }
                }
            }).dxTextBox("instance");
            /*END_DX*/
            function exitEdit%columnName%(cancel = false) {
                if (!%columnName%IsEditing) return;%
                columnName%IsEditing = false;
                $(document).off("click.editmode" + fieldId);
                if (cancel)%columnName%Instance.option("value",%columnName%OriginalValue);
                else%columnName%OriginalValue =%columnName%Instance.option("value");
            }
            async function saveValue%columnName%() {
                const newVal =%columnName%Instance.option("value");
                if (newVal ===%columnName%OriginalValue) return;
                try {
                    const dataJSON = JSON.stringify(["%tableId%", ["%columnName%"],
                        [newVal]
                    ]);
                    const idValuesJSON = JSON.stringify([
                        [%columnName%Key.%columnId%], "%columnIDName%"]);  
                    ]);
                    const json = await saveFunction(dataJSON, idValuesJSON);
                    const dtError = json.data[json.data.length - 1] || [];
                    if (dtError.length > 0 && dtError[0].Status === "ERROR") {
                        uiManager.showAlert({
                            type: "error",
                            message: dtError[0]?.Message || "Lưu thất bại"
                        });
                        return;
                    }%
                    columnName%OriginalValue = newVal;
                    uiManager.showAlert({
                        type: "success",
                        message: "Lưu thành công"
                    });
                } catch (err) {
                    uiManager.showAlert({
                        type: "error",
                        message: "Có lỗi xảy ra khi lưu"
                    });
                }
            }
            return {
                setValue: val => {
              %columnName%OriginalValue = val;
                    if (%columnName%Instance)%columnName%Instance.option("value", val);
                },
                getValue: () =>%columnName%Instance ?%columnName%Instance.option("value") :%columnName%OriginalValue
            };
        }
    ' WHERE [Type] = 'hpaControlText' AND [AutoSave] = 0 AND [ReadOnly] = 0 AND Layout IS NULL

    -- Linh: hpaControlText ReadOnly
    UPDATE #temptable SET loadUI = N'
        if ($("#%IDDiv%").length === 0) {
            $("<div>", {
                id: "%IDDiv%"
            }).appendTo("body");
        }
        let%columnName%Instance;
        let%columnName%OriginalValue = "";

        function loadUI%columnName%() {
            const $container = $("#%IDDiv%");
            /*BEGIN_DX*/
          %columnName%Instance = $("<div>").appendTo($container).dxTextBox({
                value:%columnName%OriginalValue,
                width: "100%",
                readOnly: true,
                inputAttr: {
                    class: "form-control form-control-sm",
                    style: "font-size: 14px; max-height: 100%;"
                }
            }).dxTextBox("instance");
            /*END_DX*/
            return {
                setValue: val => {
              %columnName%OriginalValue = val;
                    if (%columnName%Instance)%columnName%Instance.option("value", val);
                },
                getValue: () =>%columnName%Instance ?%columnName%Instance.option("value") :%columnName%OriginalValue
            };
        }
    ' WHERE [Type] = 'hpaControlText' AND [ReadOnly] = 1 AND Layout IS NULL

    -- Linh: hpaControlText AutoSave
    UPDATE #temptable SET loadUI = N'
        if ($("#%IDDiv%").length === 0) {
            $("<div>", {
                id: "%IDDiv%"
            }).appendTo("body");
        }
        let%columnName%Instance;
        let%columnName%OriginalValue = "";
        let%columnName%TimeOut;

        function loadUI%columnName%() {
            const $container = $("#%IDDiv%");
            async function saveValue%columnName%() {
                    const newVal =%columnName%Instance.option("value");
                    if (newVal ===%columnName%OriginalValue) return;
                    try {
                        const dataJSON = JSON.stringify(["%tableId%", ["%columnName%"],
                            [newVal]
                        ]);
                        const idValuesJSON = JSON.stringify([
                            [%columnName%Key.%columnId%], "%columnIDName%"]);
                        ]);
                        const json = await saveFunction(dataJSON, idValuesJSON);
                        const dtError = json.data[json.data.length - 1] || [];
                        if (dtError.length > 0 && dtError[0].Status === "ERROR") {
                            uiManager.showAlert({
                                type: "error",
                                message: dtError[0]?.Message || "Lưu thất bại"
                            });
                            return;
                        }%
                        columnName%OriginalValue = newVal;
                        uiManager.showAlert({
                            type: "success",
                            message: "Lưu thành công"
                        });
                    } catch (err) {
                  %columnName%Instance.option("value",%columnName%OriginalValue);
                        uiManager.showAlert({
                            type: "error",
                            message: "Có lỗi xảy ra khi lưu"
                        });
                    }
                }
                /*BEGIN_DX*/
              %columnName%Instance = $("<div>").appendTo($container).dxTextBox({
                    value:%columnName%OriginalValue,
                    width: "100%",
                    inputAttr: {
                        class: "form-control form-control-sm",
                        style: "font-size: 14px; max-height: 100%;"
                    },
                    onValueChanged: e => {
                        clearTimeout(%columnName%TimeOut);
                        saveValue%columnName%();
                    },
                    onKeyUp: e => {
                        clearTimeout(%columnName%TimeOut);%columnName%TimeOut = setTimeout(saveValue%columnName%, 100);
                    }
                }).dxTextBox("instance");
            /*END_DX*/
            return {
                setValue: val => {
              %columnName%OriginalValue = val;
                    if (%columnName%Instance)%columnName%Instance.option("value", val);
                },
                getValue: () =>%columnName%Instance ?%columnName%Instance.option("value") :%columnName%OriginalValue
            };
        }
    ' WHERE [Type] = 'hpaControlText' AND [AutoSave] = 1 AND [ReadOnly] = 0 AND Layout IS NULL

    UPDATE #temptable SET loadData = N'
        %columnName%Control = loadUI%columnName%();
        %columnName%Control.setValue(obj.%columnName%);
        %columnName%Key = {%columnId%: obj.%columnId%}'
    WHERE [Type] = 'hpaControlText' AND Layout IS NULL

    -- Linh: hpaControlSelectBox AutoSave
    UPDATE #temptable SET loadUI = N'
        if ($("#%IDDiv%").length === 0) {
            $("<div>", {
                id: "%IDDiv%"
            }).appendTo("body");
        }
        let%columnName%Instance
        let%columnName%OriginalValue = null

        function loadUI%columnName%() {
            const $container = $("#%IDDiv%");
            const customStore = new DevExpress.data.CustomStore({
                key: "%columnName%",
                byKey: function(key) {
                    const item = DataSource.find(i => i.ID === key);
                    return $.Deferred().resolve(item || null).promise();
                },
                load: function(loadOptions) {
                    const searchValue = loadOptions.searchValue || "";
                    let filteredData = DataSource;
                    if (searchValue) {
                        const searchLower = searchValue.toLowerCase();
                        filteredData = DataSource.filter(item =>
                            (item.Name && item.Name.toLowerCase().includes(searchLower)) ||
                            (item.Text && item.Text.toLowerCase().includes(searchLower))
                        );
                        const exactMatch = filteredData.some(item =>
                            (item.Name && item.Name.toLowerCase() === searchLower) ||
                            (item.Text && item.Text.toLowerCase() === searchLower)
                        );
                        if (!exactMatch && searchValue.trim()) {
                            filteredData = [{
                                ID: "add_new_%columnName%",
                                Name: "Thêm mới: \"" + searchValue + "\"",
                                Text: "Thêm mới: \"" + searchValue + "\"",
                                _isAddNew: true,
                                _newValue: searchValue
                            }].concat(filteredData);
                        }
                    }
                    return filteredData;
                }
            });
            /*BEGIN_DX*/
            %columnName%Instance = $("<div>").appendTo($container).dxSelectBox({
                dataSource: customStore,
                valueExpr: "ID",
                displayExpr: "Name",
                placeholder: "Chọn...",
                searchEnabled: true,
                searchMode: "contains",
                searchTimeout: 300,
                minSearchLength: 0,
                showClearButton: true,
                showDataBeforeSearch: true,
                stylingMode: "outlined",
                itemTemplate: function(data) {
                    if (data._isAddNew) {
                        return $("<div>").addClass("d-flex align-items-center text-success fw-semibold").append(
                            $("<i>").addClass("bi bi-plus-circle me-2"),
                            $("<span>").text(data.Name)
                        );
                    }
                    return $("<div>").addClass("d-flex align-items-center").text(data.Name || data.Text || "");
                },
                onValueChanged: async function(e) {
                    if (e.value === "add_new_%columnName%") {
                        const selectedItem = e.component.option("selectedItem");
                        if (selectedItem && selectedItem._isAddNew) {
                            const newItem = {
                                ID: Date.now(),
                                Name: selectedItem._newValue,
                                Text: selectedItem._newValue
                            };
                            DataSource.push(newItem);
                            e.component.option("value", newItem.ID);
                            e.component.getDataSource().reload();
                            console.log("Created new item%columnName%:", newItem);
                            return;
                        }
                    }
                    if (e.value !==%columnName%OriginalValue) {
                        await save%columnName%Value(e.value);
                    }
                }
            }).dxSelectBox("instance");
            /*END_DX*/
            async function save%columnName%Value(newValue) {
                if (newValue ===%columnName%OriginalValue) return;
                try {
                    const dataJSON = JSON.stringify(["%tableId%", ["%columnName%"],
                        [newValue || ""]
                    ]);
                    const idValuesJSON = JSON.stringify([
                        [%columnName%Key.%columnId%], "%columnIDName%"]);
                    ]);
                    const json = await saveFunction(dataJSON, idValuesJSON);
                    const dtError = json.data[json.data.length - 1] || [];
                    if (dtError.length > 0 && dtError[0].Status === "ERROR") {
                        uiManager.showAlert({
                            type: "error",
                            message: dtError[0]?.Message || "Lưu thất bại"
                        });%
                        columnName%Instance.option("value",%columnName%OriginalValue);
                        return;
                    }%
                    columnName%OriginalValue = newValue;
                    uiManager.showAlert({
                        type: "success",
                        message: "Lưu thành công"
                    });
                } catch (err) {
                    console.error("Save error:", err);%
                    columnName%Instance.option("value",%columnName%OriginalValue);
                    uiManager.showAlert({
                        type: "error",
                        message: "Có lỗi xảy ra khi lưu: " + (err.message || "Vui lòng thử lại")
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
                    return%columnName%Instance ?%columnName%Instance.option("value") :%columnName%OriginalValue;
                }
            };
        }
    ' WHERE [Type] = 'hpaControlSelectBox' AND [AutoSave] = 1 AND [ReadOnly] = 0 AND Layout IS NULL

    -- Linh: hpaControlSelectBox ReadOnly
    UPDATE #temptable SET loadUI = N'
        if ($("#%IDDiv%").length === 0) {
            $("<div>", {
                id: "%IDDiv%"
            }).appendTo("body");
        }
        let%columnName%Instance
        let%columnName%OriginalValue = null

        function loadUI%columnName%() {
            const $container = $("#%IDDiv%";
			const customStore = new DevExpress.data.CustomStore({
				key: "%columnName%",
				byKey: function(key) {
					const item = DataSource.find(i => i.ID === key);
					return $.Deferred().resolve(item || null).promise();
				},
				load: function(loadOptions) {
					const searchValue = loadOptions.searchValue || "";
					let filteredData = DataSource;
					if (searchValue) {
						const searchLower = searchValue.toLowerCase();
						filteredData = DataSource.filter(item =>
							(item.Name && item.Name.toLowerCase().includes(searchLower)) ||
							(item.Text && item.Text.toLowerCase().includes(searchLower))
						);
					}
					return filteredData;
				}
			});
			/*BEGIN_DX*/
			%
			columnName%Instance = $("<div>").appendTo($container).dxSelectBox({
				dataSource: customStore,
				valueExpr: "ID",
				displayExpr: "Name",
				placeholder: "Chọn...",
				searchEnabled: true,
				searchMode: "contains",
				searchTimeout: 300,
				minSearchLength: 0,
				showClearButton: true,
				showDataBeforeSearch: true,
				stylingMode: "outlined",
				disabled: true,
				itemTemplate: function(data) {
					return $("<div>").addClass("d-flex align-items-center").text(data.Name || data.Text || "");
				}
			}).dxSelectBox("instance");
			/*END_DX*/
			return {
				setValue: function(val) {
					%
					columnName%OriginalValue = val;
					if (%columnName%Instance) {
						%
						columnName%Instance.option("value", val);
					}
				},
				getValue: function() {
					return%columnName%Instance ?%columnName%Instance.option("value") :%columnName%OriginalValue;
				}
			};
		}
    ' WHERE [Type] = 'hpaControlSelectBox' AND [ReadOnly] = 1 AND Layout IS NULL

    -- Linh: hpaControlSelectBox Manual
    UPDATE #temptable SET loadUI = N'
        if ($("#%IDDiv%").length === 0) {
            $("<div>", {
                id: "%IDDiv%"
            }).appendTo("body");
        }
        let%columnName%Instance
        let%columnName%OriginalValue = null

        function loadUI%columnName%() {
		    const $container = $("#%IDDiv%");
			const customStore = new DevExpress.data.CustomStore({
				key: "%columnName%",
				byKey: function(key) {
					const item = DataSource.find(i => i.ID === key);
					return $.Deferred().resolve(item || null).promise();
				},
				load: function(loadOptions) {
					const searchValue = loadOptions.searchValue || "";
					let filteredData = DataSource;
					if (searchValue) {
						const searchLower = searchValue.toLowerCase();
						filteredData = DataSource.filter(item =>
							(item.Name && item.Name.toLowerCase().includes(searchLower)) ||
							(item.Text && item.Text.toLowerCase().includes(searchLower))
						);
					}
					return filteredData;
				}
			});
			/*BEGIN_DX*/
			%
			columnName%Instance = $("<div>").appendTo($container).dxSelectBox({
				dataSource: customStore,
				valueExpr: "ID",
				displayExpr: "Name",
				placeholder: "Chọn...",
				searchEnabled: true,
				searchMode: "contains",
				searchTimeout: 300,
				minSearchLength: 0,
				showClearButton: true,
				showDataBeforeSearch: true,
				stylingMode: "outlined",
				itemTemplate: function(data) {
					return $("<div>").addClass("d-flex align-items-center").text(data.Name || data.Text || "");
				}
			}).dxSelectBox("instance");
			/*END_DX*/
			return {
				setValue: function(val) {
					%
					columnName%OriginalValue = val;
					if (%columnName%Instance) {
						%
						columnName%Instance.option("value", val);
					}
				},
				getValue: function() {
					return%columnName%Instance ?%columnName%Instance.option("value") :%columnName%OriginalValue;
				}
			};
		}
    ' WHERE [Type] = 'hpaControlSelectBox' AND [AutoSave] = 0 AND [ReadOnly] = 0 AND Layout IS NULL

    UPDATE #temptable SET loadData = N'
        %columnName%Control = loadUI%columnName%();
        %columnName%Control.setValue(obj.%columnName%);
        %columnName%Key = {%columnId%: obj.%columnId%}'
    WHERE [Type] = 'hpaControlSelectBox' AND Layout IS NULL

    -- Linh: hpaControlSelectEmployee(Normal)
    UPDATE #temptable SET loadUI = N'
        if ($("#%IDDiv%").length === 0) {
            $("<div>", {
                id: "%IDDiv%"
            }).appendTo("body");
        }
        let%columnName%Instance
        let%columnName%SelectedIds = []
        let%columnName%SelectedIdsOriginal = []
        const%columnName%MAX_VISIBLE = 3
        let%columnName%AvatarCache = {}

        function getInitials(name) {
            const words = name.trim().split(/\s+/);
            if (words.length >= 2) {
                return (words[0][0] + words[words.length - 1][0]).toUpperCase();
            }
            return name.substring(0, 2).toUpperCase();
        }

        function getColorForId(id) {
            const colors = [{
                    bg: "#e3f2fd",
                    text: "#1976d2"
                },
                {
                    bg: "#f3e5f5",
                    text: "#7b1fa2"
                },
                {
                    bg: "#e8f5e9",
                    text: "#388e3c"
                },
                {
                    bg: "#fff3e0",
                    text: "#f57c00"
                },
                {
                    bg: "#fce4ec",
                    text: "#c2185b"
                }
            ];
            return colors[id%colors.length];
        }

        function loadAvatarImage(employee) {
            if (!employee || !employee.storeImgName || !employee.paramImg) {
                return null;
            }
            const cacheKey = employee.storeImgName + "|" + employee.paramImg;
            if (%columnName%AvatarCache[cacheKey]) {
                return%columnName%AvatarCache[cacheKey];
            }
            return new Promise((resolve) => {
                try {
                    AjaxHPAParadise({
                        data: {
                            name: "sp_GetParadiseFile",
                            param: [employee.storeImgName, employee.paramImg]
                        },
                        success: function(res) {
                            const json = typeof res === "string" ? JSON.parse(res) : res;
                            const fileUrl = (json.data && json.data[0] && json.data[0][0]) || null;
                            if (fileUrl) {
                              %
                                columnName%AvatarCache[cacheKey] = fileUrl;
                            }
                            resolve(fileUrl);
                        },
                        error: function() {
                            resolve(null);
                        }
                    });
                } catch (err) {
                    console.error("Avatar loading error:", err);
                    resolve(null);
                }
            });
        }

        function loadUI%columnName%() {
            const $container = $("#%IDDiv%");
            const uniqueId = "%columnName%_" + Date.now();
            const $displayBox = $("<div>").attr("id", uniqueId + "_display");
            $container.append($displayBox);

            function renderDisplayBox() {
                $displayBox.empty();
                const $wrapper = $("<div>").css({
                    border: "1px solid #dee2e6",
                    borderRadius: "4px",
                    padding: "8px 12px",
                    backgroundColor: "#fff",
                    cursor: "pointer",
                    minHeight: "42px",
                    display: "flex",
                    alignItems: "center"
                });
                if (%columnName%SelectedIds.length === 0) {
                    $wrapper.append(
                        $("<span>").addClass("text-muted").html(
                            "<i class=\"bi bi-person-plus me-1\"></i>Chọn nhân viên..."
                        )
                    );
                } else {
                    const $avatarGroup = $("<div>").css({
                        display: "flex",
                        alignItems: "center"
                    });
                    const displayIds =%columnName%SelectedIds.slice(0,%columnName%MAX_VISIBLE);
                    displayIds.forEach((id, index) => {
                        const item = DataSource.find(e => e.ID === id);
                        if (!item) return;
                        const $chip = $("<div>").css({
                            display: "inline-flex",
                            alignItems: "center",
                            justifyContent: "center",
                            width: "32px",
                            height: "32px",
                            borderRadius: "50%",
                            border: "2px solid #fff",
                            boxShadow: "0 2px 4px rgba(0,0,0,0.1)",
                            marginLeft: index === 0 ? "0" : "-8px",
                            zIndex:%columnName%MAX_VISIBLE - index,
                            transition: "transform 0.2s ease",
                            background: "#f8f9fa",
                            overflow: "hidden"
                        }).attr("title", item.Name || item.FullName || "");
                        $chip.hover(
                            function() {
                                $(this).css("transform", "translateY(-2px) scale(1.05)");
                            },
                            function() {
                                $(this).css("transform", "translateY(0) scale(1)");
                            }
                        );
                        const cacheKey = (item.storeImgName || "") + "|" + (item.paramImg || "");
                        const cachedUrl =%columnName%AvatarCache[cacheKey];
                        if (cachedUrl) {
                            $chip.append(
                                $("<img>").attr({
                                    src: cachedUrl,
                                    alt: item.Name || item.FullName || ""
                                }).css({
                                    width: "100%",
                                    height: "100%",
                                    objectFit: "cover"
                                })
                            );
                        } else {
                            const initials = getInitials(item.Name || item.FullName || "");
                            const color = getColorForId(item.ID);
                            $chip.css({
                                background: color.bg,
                                color: color.text,
                                fontWeight: "600",
                                fontSize: "12px"
                            }).text(initials);
                        }
                        $avatarGroup.append($chip);
                    });
                    if (%columnName%SelectedIds.length >%columnName%MAX_VISIBLE) {
                        const remaining =%columnName%SelectedIds.length -%columnName%MAX_VISIBLE;
                        const $badge = $("<div>").css({
                            display: "inline-flex",
                            alignItems: "center",
                            justifyContent: "center",
                            width: "32px",
                            height: "32px",
                            borderRadius: "50%",
                            border: "2px solid #fff",
                            background: "#6c757d",
                            color: "#fff",
                            fontWeight: "600",
                            fontSize: "12px",
                            boxShadow: "0 2px 4px rgba(0,0,0,0.1)",
                            marginLeft: "-8px",
                            zIndex: "0",
                            transition: "transform 0.2s ease"
                        }).text(`+${remaining}`).attr("title", `Còn ${remaining} người nữa`);
                        $badge.hover(
                            function() {
                                $(this).css("transform", "translateY(-2px) scale(1.05)");
                            },
                            function() {
                                $(this).css("transform", "translateY(0) scale(1)");
                            }
                        );
                        $avatarGroup.append($badge);
                    }
                    $wrapper.append($avatarGroup);
                }
                $displayBox.append($wrapper);
                $wrapper.off("click").on("click", function() {
                    popup.show();
                });
            }
            const popup = $("<div>").attr("id", uniqueId + "_popup").appendTo($container).dxPopup({
                width: 750,
                height: 600,
                showTitle: true,
                title: "Chọn nhân viên",
                dragEnabled: true,
                closeOnOutsideClick: true,
                showCloseButton: true,
                toolbarItems: [{
                    widget: "dxButton",
                    location: "after",
                    toolbar: "bottom",
                    options: {
                        text: "Xác nhận",
                        type: "success",
                        onClick: async function() {
                            try {
                                await save%columnName%Value();
                                popup.hide();
                            } catch (err) {
                                console.error("Save error:", err);
                            }
                        }
                    }
                }],
                contentTemplate: function() {
                    return $("<div>").attr("id", uniqueId + "_grid");
                },
                onShown: function() {
                    const gridContainer = $(`#${uniqueId}_grid`);
                    gridContainer.dxDataGrid({
                        dataSource: DataSource,
                        keyExpr: "ID",
                        selection: {
                            mode: "multiple",
                            showCheckBoxesMode: "always"
                        },
                        selectedRowKeys:%columnName%SelectedIds,
                        columns: [{
                                caption: "Ảnh",
                                width: 70,
                                alignment: "center",
                                cellTemplate: function(container, options) {
                                    const item = options.data;
                                    const $cell = $("<div>").addClass("d-flex justify-content-center align-items-center");
                                    const cacheKey = (item.storeImgName || "") + "|" + (item.paramImg || "");
                                    const cachedUrl =%columnName%AvatarCache[cacheKey];
                                    if (cachedUrl) {
                                        $cell.append(
                                            $("<div>").addClass("d-flex align-items-center justify-content-center bg-light border").css({
                                                width: "40px",
                                                height: "40px",
                                                borderRadius: "50%",
                                                overflow: "hidden",
                                                boxShadow: "0 2px 4px rgba(0,0,0,0.1)"
                                            }).append(
                                                $("<img>").attr({
                                                    src: cachedUrl,
                                                    alt: item.Name || item.FullName || ""
                                                }).css({
                                                    width: "100%",
                                                    height: "100%",
                                                    objectFit: "cover"
                                                })
                                            )
                                        );
                                    } else {
                                        const initials = getInitials(item.Name || item.FullName || "");
                                        const color = getColorForId(item.ID);
                                        $cell.append(
                                            $("<div>").addClass("d-flex align-items-center justify-content-center border").css({
                                                width: "40px",
                                                height: "40px",
                                                borderRadius: "50%",
                                                background: color.bg,
                                                color: color.text,
                                                fontWeight: 600,
                                                fontSize: "14px",
                                                boxShadow: "0 2px 4px rgba(0,0,0,0.1)"
                                            }).text(initials)
                                        );
                                    }
                                    container.append($cell);
                                }
                            },
                            {
                                dataField: "Name",
                                caption: "Họ tên",
                                width: 200,
                                cellTemplate: function(container, options) {
                                    const item = options.data;
                                    container.append(
                                        $("<div>").append(
                                            $("<div>").addClass("fw-semibold").text(item.Name || item.FullName || ""),
                                            $("<div>").addClass("small text-muted").text(item.Position || "")
                                        )
                                    );
                                }
                            },
                            {
                                dataField: "Email",
                                caption: "Email",
                                width: 200,
                                cellTemplate: function(container, options) {
                                    const email = options.data.Email || "";
                                    container.append(
                                        $("<div>").addClass("small").css("word-break", "break-word").text(email)
                                    );
                                }
                            }
                        ],
                        showBorders: true,
                        showRowLines: true,
                        rowAlternationEnabled: true,
                        hoverStateEnabled: true,
                        searchPanel: {
                            visible: true,
                            placeholder: "Tìm kiếm..."
                        },
                        paging: {
                            pageSize: 10
                        },
                        onSelectionChanged: function(e) {
                            %columnName%SelectedIds = e.selectedRowKeys || [];
                        }
                    });
                },
                onHidden: function() {
                    renderDisplayBox();
                }
            }).dxPopup("instance");
            /*BEGIN_DX*/
            %columnName%Instance = {
                renderDisplay: renderDisplayBox,
                popup: popup
            };
            /*END_DX*/
            renderDisplayBox();
            async function save%columnName%Value() {
                const originalStr =%columnName%SelectedIdsOriginal.slice().sort().join(",");
                const currentStr =%columnName%SelectedIds.slice().sort().join(",");
                if (originalStr === currentStr) return;
                try {
                    const dataJSON = JSON.stringify(["%tableId%", ["%columnName%"],
                        [%columnName%SelectedIds.join(",")]
                    ]);
                    const idValuesJSON = JSON.stringify([
                        [%columnName%Key.%columnId%], "%columnIDName%"]);
                    ]);
                    const json = await saveFunction(dataJSON, idValuesJSON);
                    const dtError = json.data[json.data.length - 1] || [];
                    if (dtError.length > 0 && dtError[0].Status === "ERROR") {
                        uiManager.showAlert({
                            type: "error",
                            message: dtError[0]?.Message || "Lưu thất bại"
                        });
                        return;
                    }%
                    columnName%SelectedIdsOriginal = [...%columnName%SelectedIds];
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
                    if (typeof val === "string" && val.trim() !== "") {
                      %columnName%SelectedIds = val.split(",").map(v => {
                            const num = parseInt(v);
                            return isNaN(num) ? v : num;
                        });
                    } else if (Array.isArray(val)) {
                      %columnName%SelectedIds = val;
                    } else {
                      %columnName%SelectedIds = [];
                    }%
                    columnName%SelectedIdsOriginal = [...%columnName%SelectedIds];
                    if (%columnName%Instance) {
                      %columnName%Instance.renderDisplay();
                    }
                },
                getValue: function() {
                    return%columnName%SelectedIds;
                }
            };
        }
    ' WHERE [Type] = 'hpaControlSelectEmployee' AND Layout IS NULL

    UPDATE #temptable SET loadData = N'
        %columnName%Control = loadUI%columnName%();
        %columnName%Control.setValue(obj.%columnName%);
        %columnName%Key = {%columnId%: obj.%columnId%}'
    WHERE [Type] = 'hpaControlSelectEmployee' AND Layout IS NULL

    -- Linh: hpaControlSelectEmployeeNoAvatar
    UPDATE #temptable SET loadUI = N'
        if ($("#%IDDiv%").length === 0) {
            $("<div>", {
                id: "%IDDiv%"
            }).appendTo("body");
        }
        let%columnName%Instance
        let%columnName%SelectedIds = []
        let%columnName%SelectedIdsOriginal = []

        function loadUI%columnName%() {
            const $container = $("#%IDDiv%");

            function renderDisplayBox() {
                $container.empty();
                const $wrapper = $("<div>").css({
                    border: "1px solid #dee2e6",
                    borderRadius: "4px",
                    padding: "8px 12px",
                    backgroundColor: "#fff",
                    minHeight: "42px",
                    display: "flex",
                    alignItems: "center",
                    flexWrap: "wrap",
                    gap: "4px"
                });
                if (%columnName%SelectedIds.length === 0) {
                    $wrapper.append(
                        $("<span>").addClass("text-muted").html(
                            "<i class=\"bi bi-person-fill-add me-1\"></i>Chọn nhân viên..."
                        )
                    );
                } else {
                  %columnName%SelectedIds.forEach((id) => {
                        const item = DataSource.find(e => e.ID === id);
                        if (!item) return;
                        const $tag = $("<span>").addClass("badge bg-light text-dark border").css({
                            padding: "6px 10px",
                            borderRadius: "20px",
                            fontSize: "13px",
                            fontWeight: "500",
                            whiteSpace: "nowrap",
                            cursor: "default"
                        }).text(item.Name || item.FullName || "");
                        $wrapper.append($tag);
                    });
                }
                $container.append($wrapper);
            }
            renderDisplayBox();
            return {
                setValue: function(val) {
                    if (typeof val === "string" && val.trim() !== "") {
                      %columnName%SelectedIds = val.split(",").map(v => {
                            const num = parseInt(v);
                            return isNaN(num) ? v : num;
                        });
                    } else if (Array.isArray(val)) {
                      %columnName%SelectedIds = val;
                    } else {
                      %columnName%SelectedIds = [];
                    }%
                    columnName%SelectedIdsOriginal = [...%columnName%SelectedIds];
                    renderDisplayBox();
                },
                getValue: function() {
                    return%columnName%SelectedIds;
                }
            };
        }
    ' WHERE [Type] = 'hpaControlSelectEmployeeNoAvatar' AND Layout IS NULL

    UPDATE #temptable SET loadData = N'
        %columnName%Control = loadUI%columnName%();
        %columnName%Control.setValue(obj.%columnName%);
        %columnName%Key = {%columnId%: obj.%columnId%}'
    WHERE [Type] = 'hpaControlSelectEmployeeNoAvatar' AND Layout IS NULL

    -- Linh: hpaControlTagBox AutoSave
    UPDATE #temptable SET loadUI = N'
        if ($("#%IDDiv%").length === 0) {
            $("<div>", {
                id: "%IDDiv%"
            }).appendTo("body");
        }
        let%columnName%Instance
        let%columnName%OriginalValue = []

        function loadUI%columnName%() {
            const $container = $("#%IDDiv%");
            const customStore = new DevExpress.data.CustomStore({
                key: "%columnName%",
                byKey: function(key) {
                    const item = DataSource.find(i => i.ID === key);
                    return $.Deferred().resolve(item || null).promise();
                },
                load: function(loadOptions) {
                    const searchValue = loadOptions.searchValue || "";
                    let filteredData = DataSource;
                    if (searchValue) {
                        const searchLower = searchValue.toLowerCase();
                        filteredData = DataSource.filter(item =>
                            (item.Name && item.Name.toLowerCase().includes(searchLower)) ||
                            (item.Text && item.Text.toLowerCase().includes(searchLower))
                        );
                        const exactMatch = filteredData.some(item =>
                            (item.Name && item.Name.toLowerCase() === searchLower) ||
                            (item.Text && item.Text.toLowerCase() === searchLower)
                        );
                        if (!exactMatch && searchValue.trim()) {
                            filteredData = [{
                                ID: "add_new_%columnName%",
                                Name: "Thêm mới: \"" + searchValue + "\"",
                                Text: "Thêm mới: \"" + searchValue + "\"",
                                Icon: "plus-circle",
                                _isAddNew: true,
                                _newValue: searchValue
                            }].concat(filteredData);
                        }
                    }
                    return filteredData;
                }
            });
            /*BEGIN_DX*/
            %
            columnName%Instance = $("<div>").appendTo($container).dxTagBox({
                dataSource: customStore,
                valueExpr: "ID",
                displayExpr: "Name",
                placeholder: "Chọn hoặc thêm...",
                searchEnabled: true,
                showClearButton: true,
                showSelectionControls: true,
                applyValueMode: "useButtons",
                stylingMode: "outlined",
                multiline: false,
                searchMode: "contains",
                searchTimeout: 300,
                minSearchLength: 0,
                itemTemplate: function(data) {
                    if (data._isAddNew) {
                        return $("<div>").addClass("d-flex align-items-center text-success fw-semibold").append(
                            $("<i>").addClass("bi bi-" + (data.Icon || "plus-circle") + " me-2"),
                            $("<span>").text(data.Name)
                        );
                    }
                    return $("<div>").addClass("d-flex align-items-center").append(
                        $("<i>").addClass("bi bi-" + (data.Icon || "tag") + " me-2 text-primary"),
                        $("<span>").text(data.Name || data.Text || "")
                    );
                },
                tagTemplate: function(data) {
                    return $("<div>").addClass("d-flex align-items-center").append(
                        $("<i>").addClass("bi bi-" + (data.Icon || "tag") + " me-1").css("font-size", "11px"),
                        $("<span>").text(data.Name || data.Text || "")
                    );
                },
                onSelectionChanged: function(e) {
                    const addedItems = e.addedItems || [];
                    addedItems.forEach(item => {
                        if (item._isAddNew) {
                            const newTag = {
                                ID: Date.now(),
                                Name: item._newValue,
                                Text: item._newValue,
                                Icon: "tag"
                            };
                            DataSource.push(newTag);
                            const currentValues = e.component.option("value") || [];
                            const filteredValues = currentValues.filter(v => v !== "add_new_%columnName%");
                            filteredValues.push(newTag.ID);
                            e.component.option("value", filteredValues);
                            e.component.getDataSource().reload();
                            console.log("Created new tag %columnName%:", newTag);
                        }
                    });
                },
                onInitialized: function(e) {
                    const $element = $(e.element);
                    $element.find(".dx-placeholder").css({
                        "top": "0",
                        "transform": "none",
                        "padding-top": "8px",
                        "transition": "none"
                    });
                    $element.find(".dx-texteditor-input").css({
                        "padding-top": "8px",
                        "padding-bottom": "8px"
                    });
                    $element.find(".dx-tag-container").css({
                        "padding-top": "4px",
                        "padding-bottom": "4px"
                    });
                },
                onFocusIn: function(e) {
                    setTimeout(() => {
                        const $element = $(e.element);
                        $element.find(".dx-placeholder").css({
                            "top": "0",
                            "transform": "none",
                            "padding-top": "8px",
                            "transition": "none"
                        });
                        $element.find(".dx-texteditor-input").css({
                            "padding-top": "8px",
                            "padding-bottom": "8px"
                        });
                        $element.find(".dx-tag-container").css({
                            "padding-top": "4px",
                            "padding-bottom": "4px"
                        });
                    }, 0);
                },
                onValueChanged: async function(e) {
                    const values = (e.value || []).filter(v => v !== "add_new_%columnName%");
                    if (JSON.stringify(values.slice().sort()) !== JSON.stringify(%columnName%OriginalValue.slice().sort())) {
                        await save%columnName%Value(values);
                    }
                    setTimeout(() => {
                        const $element = $(e.element);
                        $element.find(".dx-placeholder").css({
                            "top": "0",
                            "transform": "none",
                            "padding-top": "8px",
                            "transition": "none"
                        });
                        $element.find(".dx-texteditor-input").css({
                            "padding-top": "8px",
                            "padding-bottom": "8px"
                        });
                        $element.find(".dx-tag-container").css({
                            "padding-top": "4px",
                            "padding-bottom": "4px"
                        });
                    }, 0);
                }
            }).dxTagBox("instance");
            /*END_DX*/
            async function save%columnName%Value(newValue) {
                try {
                    const dataJSON = JSON.stringify(["%tableId%", ["%columnName%"],
                        [newValue.join(",")]
                    ]);
                    const idValuesJSON = JSON.stringify([
                        [%columnName%Key.%columnId%], "%columnIDName%"]);
                    ]);
                    const json = await saveFunction(dataJSON, idValuesJSON);
                    const dtError = json.data[json.data.length - 1] || [];
                    if (dtError.length > 0 && dtError[0].Status === "ERROR") {
                        uiManager.showAlert({
                            type: "error",
                            message: dtError[0]?.Message || "Lưu thất bại"
                        }); %
                        columnName%Instance.option("value",%columnName%OriginalValue);
                        return;
                    } %
                    columnName%OriginalValue = newValue;
                    uiManager.showAlert({
                        type: "success",
                        message: "Lưu thành công"
                    });
                } catch (err) {
                    console.error("Save error:", err); %
                    columnName%Instance.option("value",%columnName%OriginalValue);
                    uiManager.showAlert({
                        type: "error",
                        message: "Có lỗi xảy ra khi lưu: " + (err.message || "Vui lòng thử lại")
                    });
                }
            }
            return {
                setValue: function(val) {
                    if (typeof val === "string") {
                        %
                        columnName%OriginalValue = val.split(",").map(v => {
                            const num = parseInt(v);
                            return isNaN(num) ? v : num;
                        });
                    } else if (Array.isArray(val)) {
                        %
                        columnName%OriginalValue = val;
                    } else {
                        %
                        columnName%OriginalValue = [];
                    }
                    if (%columnName%Instance) {
                        %
                        columnName%Instance.option("value",%columnName%OriginalValue);
                    }
                },
                getValue: function() {
                    return%columnName%Instance ?%columnName%Instance.option("value") :%columnName%OriginalValue;
                }
            };
        }
    ' WHERE [Type] = 'hpaControlTagBox' AND [AutoSave] = 1 AND [ReadOnly] = 0 AND Layout IS NULL

    -- Linh: hpaControlTagBox ReadOnly
    UPDATE #temptable SET loadUI = N'
        if ($("#%IDDiv%").length === 0) {
            $("<div>", {
                id: "%IDDiv%"
            }).appendTo("body");
        }
        let % columnName % Instance
        let % columnName % OriginalValue = []

        function loadUI % columnName % () {
		    const $container = $("#%IDDiv%";
			const customStore = new DevExpress.data.CustomStore({
				key: "%columnName%",
				byKey: function(key) {
					const item = DataSource.find(i => i.ID === key);
					return $.Deferred().resolve(item || null).promise();
				},
				load: function(loadOptions) {
					const searchValue = loadOptions.searchValue || "";
					let filteredData = DataSource;
					if (searchValue) {
						const searchLower = searchValue.toLowerCase();
						filteredData = DataSource.filter(item =>
							(item.Name && item.Name.toLowerCase().includes(searchLower)) ||
							(item.Text && item.Text.toLowerCase().includes(searchLower))
						);
					}
					return filteredData;
				}
			});
			/*BEGIN_DX*/
			%
			columnName % Instance = $("<div>").appendTo($container).dxTagBox({
				dataSource: customStore,
				valueExpr: "ID",
				displayExpr: "Name",
				placeholder: "Chọn hoặc thêm...",
				searchEnabled: true,
				showClearButton: true,
				showSelectionControls: true,
				applyValueMode: "useButtons",
				stylingMode: "outlined",
				multiline: false,
				searchMode: "contains",
				searchTimeout: 300,
				minSearchLength: 0,
				disabled: true,
				itemTemplate: function(data) {
					return $("<div>").addClass("d-flex align-items-center").append(
						$("<i>").addClass("bi bi-" + (data.Icon || "tag") + " me-2 text-primary"),
						$("<span>").text(data.Name || data.Text || "")
					);
				},
				tagTemplate: function(data) {
					return $("<div>").addClass("d-flex align-items-center").append(
						$("<i>").addClass("bi bi-" + (data.Icon || "tag") + " me-1").css("font-size", "11px"),
						$("<span>").text(data.Name || data.Text || "")
					);
				}
			}).dxTagBox("instance");
			/*END_DX*/
			return {
				setValue: function(val) {
					%
					columnName % OriginalValue = val;
					if ( % columnName % Instance) {
						%
						columnName % Instance.option("value", val);
					}
				},
				getValue: function() {
					return % columnName % Instance ? % columnName % Instance.option("value") : % columnName % OriginalValue;
				}
			};
		}
	' WHERE [Type] = 'hpaControlTagBox' AND [ReadOnly] = 1 AND Layout IS NULL

    -- Linh: hpaControlTagBox Manual
    UPDATE #temptable SET loadUI = N'
        if ($("#%IDDiv%").length === 0) {
            $("<div>", {
                id: "%IDDiv%"
            }).appendTo("body");
        }
        let % columnName % Instance
        let % columnName % OriginalValue = []

        function loadUI % columnName % () {
            const $container = $("#%IDDiv%";
			const customStore = new DevExpress.data.CustomStore({
				key: "%columnName%",
				byKey: function(key) {
					const item = DataSource.find(i => i.ID === key);
					return $.Deferred().resolve(item || null).promise();
				},
				load: function(loadOptions) {
					const searchValue = loadOptions.searchValue || "";
					let filteredData = DataSource;
					if (searchValue) {
						const searchLower = searchValue.toLowerCase();
						filteredData = DataSource.filter(item =>
							(item.Name && item.Name.toLowerCase().includes(searchLower)) ||
							(item.Text && item.Text.toLowerCase().includes(searchLower))
						);
					}
					return filteredData;
				}
			});
			/*BEGIN_DX*/
			%
			columnName % Instance = $("<div>").appendTo($container).dxTagBox({
				dataSource: customStore,
				valueExpr: "ID",
				displayExpr: "Name",
				placeholder: "Chọn hoặc thêm...",
				searchEnabled: true,
				showClearButton: true,
				showSelectionControls: true,
				applyValueMode: "useButtons",
				stylingMode: "outlined",
				multiline: false,
				searchMode: "contains",
				searchTimeout: 300,
				minSearchLength: 0,
				itemTemplate: function(data) {
					return $("<div>").addClass("d-flex align-items-center").append(
						$("<i>").addClass("bi bi-" + (data.Icon || "tag") + " me-2 text-primary"),
						$("<span>").text(data.Name || data.Text || "")
					);
				},
				tagTemplate: function(data) {
					return $("<div>").addClass("d-flex align-items-center").append(
						$("<i>").addClass("bi bi-" + (data.Icon || "tag") + " me-1").css("font-size", "11px"),
						$("<span>").text(data.Name || data.Text || "")
					);
				},
				onInitialized: function(e) {
					const $element = $(e.element);
					$element.find(".dx-placeholder").css({
						"top": "0",
						"transform": "none",
						"padding-top": "8px",
						"transition": "none"
					});
					$element.find(".dx-texteditor-input").css({
						"padding-top": "8px",
						"padding-bottom": "8px"
					});
					$element.find(".dx-tag-container").css({
						"padding-top": "4px",
						"padding-bottom": "4px"
					});
				}
			}).dxTagBox("instance");
			/*END_DX*/
			return {
				setValue: function(val) {
					%
					columnName % OriginalValue = val;
					if ( % columnName % Instance) {
						%
						columnName % Instance.option("value", val);
					}
				},
				getValue: function() {
					return % columnName % Instance ? % columnName % Instance.option("value") : % columnName % OriginalValue;
				}
			};
		}
	' WHERE [Type] = 'hpaControlTagBox' AND [AutoSave] = 0 AND [ReadOnly] = 0 AND Layout IS NULL

    UPDATE #temptable SET loadData = N'
        %columnName%Control = loadUI%columnName%();
        %columnName%Control.setValue(obj.%columnName%);
        %columnName%Key = {%columnId%: obj.%columnId%}'
    WHERE [Type] = 'hpaControlTagBox' AND Layout IS NULL

    -- Thắng: Xử lý tableId cho control thông thường
    UPDATE t
        SET loadUI = REPLACE(loadUI, '%tableId%', CAST(CHECKSUM(o.name) AS VARCHAR(64)))
        FROM #temptable t
        INNER JOIN sys.objects o ON o.name = t.TableEditor AND o.type = 'U'
        WHERE t.Layout IS NULL

    -- Thắng: Xử lý tableId cho CardView
    UPDATE t
        SET
            loadUI = REPLACE(loadUI, '%tableId%', CAST(CHECKSUM(o.name) AS VARCHAR(64))),
            loadUILayout = REPLACE(loadUILayout, '%tableId%', CAST(CHECKSUM(o.name) AS VARCHAR(64)))
        FROM #temptable t
        INNER JOIN sys.objects o ON o.name = t.TableEditor AND o.type = 'U'
        WHERE t.CardView = 1

    -- Phần thay thế biến chung
    UPDATE #temptable SET loadUI = REPLACE(loadUI, '%tableId%', @object_Id)
    UPDATE #temptable SET loadUI = REPLACE(loadUI, '%IDDiv%', IDDiv)
    UPDATE #temptable SET loadUI = REPLACE(loadUI, '%columnName%', ColumnName)
    UPDATE #temptable SET loadUI = REPLACE(loadUI, '%columnId%', columnId)
    UPDATE #temptable SET loadUI = REPLACE(loadUI, '%ColumnIDName%', ColumnIDName)
    UPDATE #temptable SET loadData = REPLACE(loadData, '%IDDiv%', IDDiv)
    UPDATE #temptable SET loadData = REPLACE(loadData, '%columnName%', ColumnName)
    UPDATE #temptable SET loadData = REPLACE(loadData, '%columnId%', columnId)
    UPDATE #temptable SET loadData = REPLACE(loadData, '%ColumnIDName%', ColumnIDName)
    UPDATE #temptable SET html = REPLACE(html, '%IDDiv%', IDDiv)
    -- Thắng: Replace cho loadUILayout (CardView)
    UPDATE #temptable SET loadUILayout = REPLACE(loadUILayout, '%columnName%', ColumnName)
    UPDATE #temptable SET loadUILayout = REPLACE(loadUILayout, '%DisplayName%', ISNULL(DisplayName, ColumnName))
    UPDATE #temptable SET loadUILayout = REPLACE(loadUILayout, '%ReadOnly%', CAST(ISNULL(ReadOnly, 0) AS VARCHAR(1)))
    UPDATE #temptable SET loadUILayout = REPLACE(loadUILayout, '%columnId%', columnId)

    -- =====================================================================
    -- XỬ LÝ GRID (hpaControlGrid) - ĐÃ SỬA ĐẦY ĐỦ
    -- =====================================================================
    -- Extract DXBoxUI từ các control con
    IF OBJECT_ID('tempdb..#DXBoxUI') IS NOT NULL DROP TABLE #DXBoxUI;
    SELECT
        t.ID,
        t.ColumnName,
        t.Type,
        t.DisplayName,
        t.GridColumnName,
        t.AutoSave,
        t.ReadOnly,
        t.SPLoadData,
        t.TableEditor,
        t.columnId,
        DXBoxUI = SUBSTRING(
            t.loadUI,
            CHARINDEX('/*BEGIN_DX*/', t.loadUI) + LEN('/*BEGIN_DX*/'),
            CHARINDEX('/*END_DX*/', t.loadUI) - (CHARINDEX('/*BEGIN_DX*/', t.loadUI) + LEN('/*BEGIN_DX*/'))
        )
    INTO #DXBoxUI
    FROM #temptable t
    WHERE t.loadUI LIKE '%/*BEGIN_DX*/%'
    AND CHARINDEX('/*BEGIN_DX*/', t.loadUI) > 0
    AND CHARINDEX('/*END_DX*/', t.loadUI) > CHARINDEX('/*BEGIN_DX*/', t.loadUI);

    -- Build bảng con để tạo columns
    IF OBJECT_ID('tempdb..#GridChildControls') IS NOT NULL DROP TABLE #GridChildControls;
    SELECT
        g.ColumnName AS GridColumnName,
        c.ColumnName AS ChildColumnName,
        c.Type AS ChildControlType,
        c.ReadOnly,
        c.AutoSave,
        ISNULL(dx.DXBoxUI, '') AS ChildDXBoxUI,
        ISNULL(c.DisplayName, c.ColumnName) AS Caption,
        c.columnId AS ChildColumnId,
        ROW_NUMBER() OVER (PARTITION BY g.ColumnName ORDER BY c.ID) AS ColOrder
    INTO #GridChildControls
    FROM #temptable g
    INNER JOIN #temptable c ON c.GridColumnName = g.ColumnName AND c.GridColumnName IS NOT NULL
    LEFT JOIN #DXBoxUI dx ON dx.ColumnName = c.ColumnName AND dx.TableEditor = c.TableName
    WHERE g.Type = 'hpaControlGrid';

    -- Xử lý từng grid
    DECLARE @currentGrid NVARCHAR(256), @columnsConfig NVARCHAR(MAX), @gridColumnId NVARCHAR(64), @gridPrimaryKey NVARCHAR(256);
    DECLARE grid_cursor CURSOR LOCAL FAST_FORWARD FOR
        SELECT DISTINCT GridColumnName FROM #GridChildControls;
    OPEN grid_cursor;
    FETCH NEXT FROM grid_cursor INTO @currentGrid;
    WHILE @@FETCH_STATUS = 0
    BEGIN
        -- Lấy thông tin grid
        SELECT @gridColumnId = ColumnName FROM #temptable WHERE ColumnName = @currentGrid AND Type = 'hpaControlGrid';
        SELECT @gridPrimaryKey = ISNULL(GridPrimaryKeyField, @gridColumnId)
        FROM dbo.tblCommonControlType_Signed
        WHERE ColumnName = @currentGrid AND Type = 'hpaControlGrid';
        IF @gridPrimaryKey IS NULL SET @gridPrimaryKey = @gridColumnId;

        -- Tạo cấu hình columns
        SET @columnsConfig = N'';
        SELECT @columnsConfig +=
            CASE WHEN @columnsConfig <> N'' THEN N',' + CHAR(13) + CHAR(10) ELSE N'' END +
            N'    { dataField: "' + ChildColumnName + N'", caption: "' + Caption + N'", width: 150, allowEditing: ' +
            CASE WHEN ReadOnly = 1 THEN 'false' ELSE 'true' END + N' }'
        FROM #GridChildControls
        WHERE GridColumnName = @currentGrid
        ORDER BY ColOrder;

        -- Xử lý cột ParentTaskID đặc biệt
        IF EXISTS (SELECT 1 FROM #GridChildControls WHERE GridColumnName = @currentGrid AND ChildColumnName = 'ParentTaskID')
        BEGIN
            SET @columnsConfig =
            N'    { dataField: "ParentTaskID", caption: "Task cha", width: 100, alignment: "center", allowGrouping: false, allowFiltering: true, visible: true },' + CHAR(13) + CHAR(10) + @columnsConfig;
        END

        -- Trường hợp không có cột nào
        IF @columnsConfig = N''
            SET @columnsConfig = N'    { dataField: "ID", caption: "ID", width: 80 },' + CHAR(13) + CHAR(10) +
                                N'    { dataField: "Name", caption: "Tên", minWidth: 200 }';
        SET @columnsConfig = N'[' + CHAR(13) + CHAR(10) + @columnsConfig + CHAR(13) + CHAR(10) + N']';

        -- CẬP NHẬT DÒNG GRID CHA: html, loadUI, loadData
        UPDATE #temptable
        SET
            html = N'<div id="' + @currentGrid + N'" style="height: 100%;"></div>',
            loadUI = N'
                if ($("#' + @currentGrid + N'").length === 0) {
                    $("<div>", { id: "' + @currentGrid + N'" }).appendTo("body");
                }
                let ' + @currentGrid + N'Instance;
                let ' + @currentGrid + N'DataSource = [];
                function loadUI' + @currentGrid + N'() {
                    const $container = $("#' + @currentGrid + N'");
                    const store = new DevExpress.data.ArrayStore({ data: ' + @currentGrid + N'DataSource, key: "' + @gridPrimaryKey + N'" });
                    /*BEGIN_DX*/
                    ' + @currentGrid + N'Instance = $("<div>").appendTo($container).dxDataGrid({
                        dataSource: store,
                        keyExpr: "' + @gridPrimaryKey + N'",
                        height: "100%",
                        showBorders: true,
                        showRowLines: true,
                        rowAlternationEnabled: true,
                        hoverStateEnabled: true,
                        columnAutoWidth: true,
                        allowColumnReordering: true,
                        allowColumnResizing: true,
                        wordWrapEnabled: true,
                        paging: { enabled: true, pageSize: 20 },
                        pager: { visible: true, allowedPageSizes: [10, 20, 50], showPageSizeSelector: true, showInfo: true },
                        filterRow: { visible: true, applyFilter: "auto" },
                        searchPanel: { visible: true, width: 200, placeholder: "Tìm kiếm..." },
                        headerFilter: { visible: true },
                        columnChooser: { enabled: true, mode: "select" },
                        columns: ' + @columnsConfig + N',
                        summary: {
                            totalItems: [{
                                column: "' + @currentGrid + N'",
                                summaryType: "count",
                                displayFormat: "Tổng: {0} bản ghi"
                            }],
                            groupItems: [{
                                column: "' + @currentGrid + N'",
                                summaryType: "count",
                                displayFormat: "{0}"
                            }]
                        },
                        onRowUpdating: async function(e) {
                            const col = Object.keys(e.newData)[0];
                            let newVal = e.newData[col];
                            try {
                                const dataJSON = JSON.stringify(["%tableId%", [col], [newVal]]);
                                const idValuesJSON = JSON.stringify([[e.key], "' + @gridColumnId + N'"]);
                                const json = await saveFunction(dataJSON, idValuesJSON);
                                const dtError = json.data[json.data.length - 1] || [];
                                if (dtError.length > 0 && dtError[0].Status === "ERROR") {
                                    uiManager.showAlert({ type: "error", message: dtError[0]?.Message || "Lưu thất bại" });
                                    e.cancel = true;
                                    return;
                                }
                                const rowIdx = ' + @currentGrid + N'Instance.getRowIndexByKey(e.key);
                                ' + @currentGrid + N'Instance.cellValue(rowIdx, col, newVal);
                                uiManager.showAlert({ type: "success", message: "Lưu thành công" });
                            } catch (err) {
                                e.cancel = true;
                                console.error("Grid save error:", err);
                                uiManager.showAlert({ type: "error", message: "Lỗi lưu dữ liệu" });
                            }
                        }
                    }).dxDataGrid("instance");
                    /*END_DX*/
                    return {
                        setValue: val => {
                            ' + @currentGrid + N'DataSource = val || [];
                            if (' + @currentGrid + N'Instance) {
                                ' + @currentGrid + N'Instance.option("dataSource", ' + @currentGrid + N'DataSource);
                                ' + @currentGrid + N'Instance.refresh();
                            }
                        },
                        getValue: () => ' + @currentGrid + N'DataSource,
                        getInstance: () => ' + @currentGrid + N'Instance
                    };
                }',
            loadData = N'
                let ' + @currentGrid + N'Control = null;
                ' + @currentGrid + N'Control = loadUI' + @currentGrid + N'();
                ' + @currentGrid + N'Control.setValue(obj.' + @currentGrid + N');
                currentRecordID = obj.' + @gridColumnId +
                N' console.log("Loaded grid ' + @currentGrid + N' data:", obj.' + @currentGrid + N');'
        WHERE ColumnName = @currentGrid AND Type = 'hpaControlGrid';

        FETCH NEXT FROM grid_cursor INTO @currentGrid;
    END
    CLOSE grid_cursor;
    DEALLOCATE grid_cursor;

    -- XÓA DÒNG CON SAU KHI XỬ LÝ XONG
    DELETE FROM #temptable WHERE GridColumnName IS NOT NULL;
    -- Thắng: CARD VIEW AGGREGATION (nếu dùng layout)
        IF @UseLayout = 1
        BEGIN
            -- Tổng hợp items cho CardView
            DECLARE @cardViewItems NVARCHAR(MAX) = N''
            SELECT @cardViewItems += loadUILayout
            FROM #temptable
            WHERE CardView = 1
            ORDER BY ID

            -- Xóa dấu phẩy cuối
            IF LEN(@cardViewItems) > 0
                SET @cardViewItems = LEFT(@cardViewItems, LEN(@cardViewItems) - 1)

            -- Lấy PKColumnName và columnId từ CardView items
            DECLARE @PKColumnName VARCHAR(100)
            DECLARE @PKColumnId VARCHAR(64)

            SELECT TOP 1
                @PKColumnName = ColumnIDName,
                @PKColumnId = columnId
            FROM #temptable
            WHERE CardView = 1

            -- Replace vào loadUI của CardView
            UPDATE #temptable
            SET loadUI = REPLACE(
                REPLACE(
                    REPLACE(loadUI, '%PKColumnName%', ISNULL(@PKColumnName, 'ID')),
                    '%columnId%', ISNULL(@PKColumnId, '1')
                ),
                'items: []', 'items: [' + @cardViewItems + ']'
            )
            WHERE Layout = 'Card_View'
        END

    -- ====== XUẤT KẾT QUẢ =======
    DECLARE @html NVARCHAR(MAX) = N''
    DECLARE @loadUI NVARCHAR(MAX) = N'let DataSource = [];'
    DECLARE @loadData NVARCHAR(MAX) = N''

    SELECT
        @html += html,
        @loadUI += loadUI,
        @loadData += loadData
    FROM #temptable

    DECLARE @nsql NVARCHAR(MAX) = N'
    ' + @html + '
    <script>
        (() => {
            var currentRecordID;
            ' + @loadUI + N'

            //Hàm tải dữ liệu
            function loadData() {
                AjaxHPAParadise({
                    data: {
                        name: "%SPLoadData%",
                        param: []
                    },
                    success: function (res) {
                        const json = typeof res === "string" ? JSON.parse(res) : res
                        const results = (json.data && json.data[0]) || []

                        if (%UseLayout%=== 1) {
                          %Layout%Instance.option("dataSource", results);
                        } else {
                            const obj = results[0]
                            currentRecordID = obj.%ColumnIDName% || currentRecordID;
                            DataSource = results;
                            ' + @loadData + N'
                        }
                    }
                });
            }
            loadData()
        })();
    </script>'

    DECLARE @SPLoadData VARCHAR(100)
    DECLARE @LayoutName VARCHAR(100)
    DECLARE @ColumnIDName VARCHAR(100)

    SELECT TOP 1 @SPLoadData = SPLoadData FROM #temptable WHERE TableName = @TableName
    SELECT TOP 1 @LayoutName = Layout FROM #temptable WHERE CardView = 1 AND TableName = @TableName
    SELECT TOP 1 @PKColumnName = ColumnIDName FROM #temptable WHERE CardView = 1
    SELECT TOP 1 @ColumnIDName = ColumnIDName FROM #temptable WHERE TableName = @TableName

    SET @nsql = REPLACE(@nsql, '%SPLoadData%', ISNULL(@SPLoadData, ''))
    SET @nsql = REPLACE(@nsql, '%UseLayout%', CAST(@UseLayout AS VARCHAR(1)))
    SET @nsql = REPLACE(@nsql, '%Layout%',ISNULL(@LayoutName, ''))
    SET @nsql = REPLACE(@nsql, '%ColumnIDName%', ISNULL(@ColumnIDName, ''))
    SELECT @nsql AS htmlProc
END
GO

exec sptblCommonControlType_Signed_Linh 'sp_Task_Mywork_html' 