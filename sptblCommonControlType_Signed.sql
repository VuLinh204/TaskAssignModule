USE Paradise_Beta_Tai2
GO
if object_id('[dbo].[sptblCommonControlType_SignedTest]') is null
	EXEC ('CREATE PROCEDURE [dbo].[sptblCommonControlType_SignedTest] as select 1')
GO

ALTER PROCEDURE [dbo].[sptblCommonControlType_SignedTest]
    @TableName VARCHAR(256) = ''
AS
BEGIN
    --Tạo bảng tạm
    IF OBJECT_ID('tempdb..#temptable') IS NOT NULL DROP TABLE #temptable

    SELECT
        t.*,
        CAST('' AS NVARCHAR(MAX)) AS html,
        CAST('' AS NVARCHAR(MAX)) AS loadUI,
        CAST('' AS NVARCHAR(MAX)) AS loadData,
        CAST(c.column_id AS NVARCHAR(64)) AS columnId
    INTO #temptable
    FROM dbo.tblCommonControlType_Signed t
    LEFT JOIN sys.columns c ON c.name = t.[ColumnName] AND c.object_id = OBJECT_ID(t.TableEditor)
    WHERE TableName = @TableName


    --ControlDateBox AutoSave
    UPDATE #temptable SET loadUI = N'
        //ControlDateBox AutoSave
        let %IDDiv%Instance
        let %IDDiv%TimeOut

        async function %IDDiv%SaveLogic() {
            let val = %IDDiv%Instance.option("value");
            let valToSave = val ? DevExpress.localization.formatDate(new Date(val), "yyyy/MM/dd") : null;
            const dataJSON = JSON.stringify(["%tableId%", ["%columnName%"], [valToSave]]);
            const idValuesJSON = JSON.stringify([[currentRecordID], "%columnId%"]);
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
                e.event && await %IDDiv%SaveLogic();
            },
            onKeyUp: (e) => {
                clearTimeout(%IDDiv%TimeOut);
                %IDDiv%TimeOut = setTimeout(async () => %IDDiv%SaveLogic(), 1000);
            }
        }).dxDateBox("instance")
        '
    WHERE [Type] = 'hpaControlDate' AND AutoSave = 1

    --ControlDateBox ReadOnly
    UPDATE #temptable SET loadUI = N'

        //ControlDateBox ReadOnly
        let %IDDiv%Instance = $("#%IDDiv%").dxDateBox({
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
    WHERE [Type] = 'hpaControlDate' AND ReadOnly = 1

    --ControlDateBox Non-AutoSave
    UPDATE #temptable SET loadUI = N'

        //ControlDateBox Non-AutoSave
        let %IDDiv%Instance = $("#%IDDiv%").dxDateBox({
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
    WHERE [Type] = 'hpaControlDate' AND (AutoSave = 0 OR AutoSave IS NULL) AND (ReadOnly = 0 OR ReadOnly IS NULL)



    --ControlTimeBox AutoSave
    UPDATE #temptable SET loadUI = N'

        //ControlTimeBox AutoSave
        let %IDDiv%Instance
        let %IDDiv%TimeOut
        async function %IDDiv%SaveLogic() {
            let val = %IDDiv%Instance.option("value");
            const timeString = val ? DevExpress.localization.formatDate(val, "HH:mm") : "";
            const dataJSON = JSON.stringify(["%tableId%", ["%columnName%"], [timeString]]);
            const idValuesJSON = JSON.stringify([[currentRecordID], "%columnId%"]);
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
            showClearButton: true,
            width: "100%",
            elementAttr: { class: "hpa-dx-timebox-inline" },
            onValueChanged: async (e) => {
                clearTimeout(%IDDiv%TimeOut);
                e.event && await %IDDiv%SaveLogic();
            },
            onKeyUp: (e) => {
                clearTimeout(%IDDiv%TimeOut);
                %IDDiv%TimeOut = setTimeout(async () => %IDDiv%SaveLogic(), 1000);
            }
        }).dxDateBox("instance")
        '
    WHERE [Type] = 'hpaControlTime' AND AutoSave = 1

    --ControlTimeBox ReadOnly
    UPDATE #temptable SET loadUI = N'

        //ControlTimeBox ReadOnly
        let %IDDiv%Instance = $("#%IDDiv%").dxDateBox({
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
    WHERE [Type] = 'hpaControlTime' AND ReadOnly = 1

    --ControlTimeBox Non-AutoSave
    UPDATE #temptable SET loadUI = N'

        //ControlTimeBox Non-AutoSave
        let %IDDiv%Instance = $("#%IDDiv%").dxDateBox({
            type: "time",
            displayFormat: "HH:mm",
            pickerType: "rollers",
            useMaskBehavior: true,
            showClearButton: true,
            width: "100%",
            elementAttr: { class: "hpa-dx-timebox-inline" },
        }).dxDateBox("instance")
        '
    WHERE [Type] = 'hpaControlTime' AND (AutoSave = 0 OR AutoSave IS NULL) AND (ReadOnly = 0 OR ReadOnly IS NULL)


    --ControlPhoneBox AutoSave
    UPDATE #temptable SET loadUI = N'

        //ControlPhoneBox AutoSave
        let %IDDiv%Instance
        let %IDDiv%TimeOut
        async function %IDDiv%SaveLogic() {
            let currentVal = %IDDiv%Instance.option("value") || "";
            let cleanVal = currentVal.replace(/[^0-9+]/g, "");
            const dataJSON = JSON.stringify(["%tableId%", ["%columnName%"], [cleanVal]]);
            const idValuesJSON = JSON.stringify([[currentRecordID], "%columnId%"]);
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
                e.event && await %IDDiv%SaveLogic();
            },
            onKeyUp: (e) => {
                clearTimeout(%IDDiv%TimeOut);
                %IDDiv%TimeOut = setTimeout(async () => %IDDiv%SaveLogic(), 1000);
            }
        }).dxTextBox("instance")
        '
    WHERE [Type] = 'hpaControlPhone' AND AutoSave = 1

    --ControlPhoneBox ReadOnly
    UPDATE #temptable SET loadUI = N'

        //ControlPhoneBox ReadOnly
        let %IDDiv%Instance = $("#%IDDiv%").dxTextBox({
            mode: "tel",
            showClearButton: false,
            width: "100%",
            elementAttr: { class: "hpa-dx-textbox-inline" },
            readOnly: true,
        }).dxTextBox("instance")
        '
    WHERE [Type] = 'hpaControlPhone' AND ReadOnly = 1

    --ControlPhoneBox Non-AutoSave
    UPDATE #temptable SET loadUI = N'

        //ControlPhoneBox Non-AutoSave
        let %IDDiv%Instance = $("#%IDDiv%").dxTextBox({
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
    WHERE [Type] = 'hpaControlPhone' AND (AutoSave = 0 OR AutoSave IS NULL) AND (ReadOnly = 0 OR ReadOnly IS NULL)


    --ControlNumberBox AutoSave
    UPDATE #temptable SET loadUI = N'

        //ControlNumberBox AutoSave
        let %IDDiv%Instance
        let %IDDiv%TimeOut
        async function %IDDiv%SaveLogic() {
            let val = %IDDiv%Instance.option("value");
            const dataJSON = JSON.stringify(["%tableId%", ["%columnName%"], [val]]);
            const idValuesJSON = JSON.stringify([[currentRecordID], "%columnId%"]);
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
                e.event && await %IDDiv%SaveLogic();
            },
            onKeyUp: (e) => {
                clearTimeout(%IDDiv%TimeOut);
                %IDDiv%TimeOut = setTimeout(async () => %IDDiv%SaveLogic(), 1000);
            }
        }).dxNumberBox("instance")
        '
    WHERE [Type] = 'hpaControlNumber' AND AutoSave = 1

    --ControlNumberBox ReadOnly
    UPDATE #temptable SET loadUI = N'

        //ControlNumberBox ReadOnly
        let %IDDiv%Instance = $("#%IDDiv%").dxNumberBox({
            format: "#,##0",
            showSpinButtons: false,
            showClearButton: false,
            width: "100%",
            elementAttr: { class: "hpa-dx-numberbox-inline" },
            readOnly: true,
        }).dxNumberBox("instance")
        '
    WHERE [Type] = 'hpaControlNumber' AND ReadOnly = 1

    --ControlNumberBox Non-AutoSave
    UPDATE #temptable SET loadUI = N'

        //ControlNumberBox Non-AutoSave
        let %IDDiv%Instance = $("#%IDDiv%").dxNumberBox({
            format: "#,##0",
            showSpinButtons: false,
            showClearButton: false,
            width: "100%",
            elementAttr: { class: "hpa-dx-numberbox-inline" },
        }).dxNumberBox("instance")
        '
    WHERE [Type] = 'hpaControlNumber' AND (AutoSave = 0 OR AutoSave IS NULL) AND (ReadOnly = 0 OR ReadOnly IS NULL)



    --ControlMoneyBox AutoSave
    UPDATE #temptable SET loadUI = N'

      //ControlMoneyBox AutoSave
        let %IDDiv%Instance
        let %IDDiv%TimeOut
        async function %IDDiv%SaveLogic() {
            let val = %IDDiv%Instance.option("value");
            const dataJSON = JSON.stringify(["%tableId%", ["%columnName%"], [val]]);
            const idValuesJSON = JSON.stringify([[currentRecordID], "%columnId%"]);
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
                %IDDiv%SaveLogic();
            },
            onKeyUp: (e) => {
                clearTimeout(%IDDiv%TimeOut);
                %IDDiv%TimeOut = setTimeout(async () => %IDDiv%SaveLogic(), 1000);
            }
        }).dxNumberBox("instance")
        '
    WHERE [Type] = 'hpaControlMoney' AND AutoSave = 1

    --ControlMoneyBox ReadOnly
    UPDATE #temptable SET loadUI = N'

        //ControlMoneyBox ReadOnly
        let %IDDiv%Instance = $("#%IDDiv%").dxNumberBox({
            format: "#,##0 ₫",
            showSpinButtons: false,
            showClearButton: false,
            width: "100%",
            elementAttr: { class: "hpa-dx-numberbox-inline" },
            readOnly: true,
        }).dxNumberBox("instance")
        '
    WHERE [Type] = 'hpaControlMoney' AND ReadOnly = 1

    --ControlMoneyBox Non-AutoSave
    UPDATE #temptable SET loadUI = N'

        //ControlMoneyBox Non-AutoSave
        let %IDDiv%Instance = $("#%IDDiv%").dxNumberBox({
            format: "#,##0 ₫",
            showSpinButtons: false,
            showClearButton: false,
            width: "100%",
            elementAttr: { class: "hpa-dx-numberbox-inline" },
        }).dxNumberBox("instance")
        '
    WHERE [Type] = 'hpaControlMoney' AND (AutoSave = 0 OR AutoSave IS NULL) AND (ReadOnly = 0 OR ReadOnly IS NULL)



    -- HTML
    UPDATE #temptable SET html = N'
        <div id="%IDDiv%"></div>
        '
    WHERE [Type] IN ('hpaControlDate', 'hpaControlTime', 'hpaControlPhone', 'hpaControlNumber', 'hpaControlMoney')

    -- LoadData
    UPDATE #temptable SET loadData = N'
        %IDDiv%Instance._suppressValueChangeAction()
        %IDDiv%Instance.option("value", obj.%columnName%)
        %IDDiv%Instance._resumeValueChangeAction()'
    WHERE [Type] IN ('hpaControlDate', 'hpaControlPhone', 'hpaControlNumber', 'hpaControlMoney')

    UPDATE #temptable SET loadData =N'
        %IDDiv%Instance._suppressValueChangeAction()
        %IDDiv%Instance.option("value", obj.%columnName% ? new Date("1970/01/01 " + obj.%columnName%) : null)
        %IDDiv%Instance._resumeValueChangeAction()'
    WHERE [Type] = 'hpaControlTime'


    -- Xứ lý id bảng
    UPDATE t
    SET loadUI = REPLACE(loadUI, '%tableId%', CAST(CHECKSUM(o.name) AS VARCHAR(64)))
    FROM #temptable t
    INNER JOIN sys.objects o ON o.name = t.TableEditor AND o.type = 'U'

    -- Thực hiện Replace hàng loạt cho tất cả các control
    UPDATE #temptable SET loadUI   = REPLACE(loadUI,   '%columnName%', ColumnName)
    UPDATE #temptable SET loadUI   = REPLACE(loadUI,   '%columnId%',   ColumnIDName)
    UPDATE #temptable SET loadUI   = REPLACE(loadUI,   '%IDDiv%',      IDDiv)
    UPDATE #temptable SET loadData = REPLACE(loadData, '%columnName%', ColumnName)
    UPDATE #temptable SET loadData = REPLACE(loadData, '%columnId%',   ColumnId)
    UPDATE #temptable SET loadData = REPLACE(loadData, '%IDDiv%',      IDDiv)
    UPDATE #temptable SET html     = REPLACE(html,     '%IDDiv%',      IDDiv)

    -- Tổng hợp kết quả
    DECLARE @html     NVARCHAR(MAX) = N''
    DECLARE @loadUI   NVARCHAR(MAX) = N''
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
                    const obj = results[0]
                    currentRecordID = obj.CRM_ID || currentRecordID;
                    ' + @loadData + N'
                }
            });
        }
        loadData()
    })();
</script>'

    DECLARE @SPLoadData VARCHAR(100)
    SELECT @SPLoadData = SPLoadData FROM #temptable WHERE TableName = @TableName

    SET @nsql = REPLACE(@nsql, '%SPLoadData%', @SPLoadData)

    SELECT @nsql AS htmlProc
END
GO