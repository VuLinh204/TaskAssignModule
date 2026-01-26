USE Paradise_Dev
GO
if object_id('[dbo].[sptblCommonControlType_Signed]') is null
	EXEC ('CREATE PROCEDURE [dbo].[sptblCommonControlType_Signed] as select 1')
GO

ALTER PROCEDURE [dbo].[sptblCommonControlType_Signed]
    @TableName VARCHAR(256) = ''
AS
BEGIN
    -- ============================================================================
    -- PROCEDURE: sptblCommonControlType_Signed
    -- MÔ TẢ: Build HTML/JavaScript cho Grid View và các control chung dựa trên cấu hình
    -- THAM SỐ:
    --   @TableName: Tên thủ tục cần build UI (VD: 'sp_Task_MyWork_html')
    -- ============================================================================

    BEGIN TRY
        -- ============================================================================
        -- VALIDATION & ERROR HANDLING
        -- ============================================================================
        IF @TableName IS NULL OR LTRIM(RTRIM(@TableName)) = ''
        BEGIN
            RAISERROR('TableName không được để trống', 16, 1);
            RETURN;
        END

        -- ============================================================================
        -- KHAI BÁO BIẾN
        -- ============================================================================
        DECLARE @UseLayout BIT = 0;  -- Flag để xác định có dùng Grid Layout hay không
        DECLARE @object_Id VARCHAR(MAX) = CAST(OBJECT_ID(@TableName) AS NVARCHAR(64)) -- Object ID của table

    -- ============================================================================
    -- KIỂM TRA XEM CÓ SỬ DỤNG LAYOUT HAY KHÔNG
    -- ============================================================================
    IF EXISTS (
        SELECT 1
        FROM dbo.tblCommonControlType_Signed
        WHERE TableName = @TableName
          AND Layout IS NOT NULL  -- Có Layout = Card_View
    )
    BEGIN
        SET @UseLayout = 1;
    END

    -- ============================================================================
    -- TẠO BẢNG TẠM VÀ RESET DỮ LIỆU
    -- ============================================================================
    IF OBJECT_ID('tempdb..#temptable') IS NOT NULL
        DROP TABLE #temptable

    -- Tạo UID mới cho các dòng chưa có UID
    UPDATE t
    SET [UID] = 'P' + REPLACE(CAST(NEWID() AS VARCHAR(36)), '-', '')
    FROM tblCommonControlType_Signed t
    WHERE TableName = @TableName
      AND ISNULL(t.[UID], '') = ''

    UPDATE t
    set html='',loadUI='',loadData=''
    from tblCommonControlType_Signed t
    WHERE TableName = @TableName

    -- ============================================================================
    -- TẠO BẢNG TẠM #temptable
    -- Chứa toàn bộ config + columnId từ sys.columns
    -- ============================================================================
    SELECT
        ROW_NUMBER() OVER (
            ORDER BY
                CASE WHEN t.GridColumnName IS NULL THEN 0 ELSE 1 END,
                CASE WHEN t.Layout = 'Grid_View' THEN 0 ELSE 1 END,
                t.ID
        ) AS RowOrder,
        t.*,
        CAST(c.column_id AS NVARCHAR(64)) AS columnId
    INTO #temptable
    FROM dbo.tblCommonControlType_Signed t
    LEFT JOIN sys.columns c
        ON c.name = t.[ColumnName]
        AND c.object_id = OBJECT_ID(t.TableEditor)
    WHERE TableName = @TableName
    -- ============================================================================
    -- BUILD CONTROL THÔNG THƯỜNG TRƯỚC (NON-LAYOUT)
    -- Các control này được dùng cho:
    -- 1. Form thông thường (không dùng Grid/Card)
    -- 2. Hoặc được Grid/Card sử dụng (sẽ bốc vào Grid)
    -- ============================================================================

    -- Gọi các SP build control theo loại
    EXEC sp_hpaControlDate @TableName = @TableName
    EXEC sp_hpaControlTime @TableName = @TableName
    EXEC sp_hpaControlDateTime @TableName = @TableName
    EXEC sp_hpaControlPhone @TableName = @TableName
    EXEC sp_hpaControlNumber @TableName = @TableName
    EXEC sp_hpaControlMoney @TableName = @TableName
    EXEC sp_hpaControlFile @TableName = @TableName
    EXEC sp_hpaControlRichTextEditor @TableName = @TableName
    EXEC sp_hpaControlText @TableName = @TableName
    EXEC sp_hpaControlTextArea @TableName = @TableName
    EXEC sp_hpaControlSelectBox @TableName = @TableName
    EXEC sp_hpaControlTagBox @TableName = @TableName
    EXEC sp_hpaControlSelectEmployee @TableName = @TableName

    -- Build HTML wrapper cho các control
    UPDATE #temptable SET
    html = N'<div id="%UID%"></div>'
    WHERE [Type] IN ('hpaControlDate', 'hpaControlTime', 'hpaControlPhone',
                     'hpaControlNumber', 'hpaControlMoney', 'hpaControlDatetime', 'hpaControlFile', 'hpaControlRichTextEditor', 'hpaControlText', 'hpaControlTextArea', 'hpaControlSelectBox', 'hpaControlTagBox', 'hpaControlSelectEmployee')

    -- Build loadData cho các control với logic check dòng dữ liệu (trừ Time)
    UPDATE #temptable SET
        loadData = N'
            // Smart Load: Check số dòng - nếu > 1000 thì dùng API, còn không thì load bình thường
            var spLoadDataGridName = "%DataSourceSP%";
            var isSmartLoadNeeded = false;

            // Kiểm tra xem có cần smart load hay không (chỉ cho các control có datasource)
            if (spLoadDataGridName && spLoadDataGridName.trim() !== "") {
                // Lấy data source từ window nếu đã load
                var dataSource = window["DataSource_%ColumnName%"];

                // Nếu chưa load hoặc dữ liệu trống, thì skip smart load cho lần này
                if (dataSource && Array.isArray(dataSource) && dataSource.length > 1000) {
                    isSmartLoadNeeded = true;
                }
            }

            // Nếu smart load, thì set flag để control sẽ tự động load qua API
            if (isSmartLoadNeeded) {
                window["UseAPILoad_%ColumnName%"] = true;
                return;
            }

            // Load bình thường (dữ liệu nhỏ <= 1000)
			 try {
				Instance%ColumnName%%UID%.option("searchValue", "");
			} catch(e) {
				// Control không hỗ trợ searchValue, bỏ qua
			}

			  Instance%ColumnName%%UID%._suppressValueChangeAction();

			try {
				Instance%ColumnName%%UID%.option("searchValue", "");
				Instance%ColumnName%%UID%.option("text", "");
				Instance%ColumnName%%UID%.reset();
			} catch(e) {}

            if(obj && obj.%ColumnName%) Instance%ColumnName%%UID%.option("value", obj.%ColumnName%);
            else Instance%ColumnName%%UID%.option("value", "");            						

			Instance%ColumnName%%UID%._resumeValueChangeAction();	

        '
    WHERE [Type] IN ('hpaControlDate', 'hpaControlPhone', 'hpaControlNumber',
                     'hpaControlMoney', 'hpaControlText', 'hpaControlTextArea',
                     'hpaControlSelectBox', 'hpaControlSelectEmployee')

    UPDATE #temptable SET
        loadData = N'
            // Smart Load: Check số dòng - nếu > 1000 thì dùng API, còn không thì load bình thường
            var spLoadDataGridName = "%DataSourceSP%";
            var isSmartLoadNeeded = false;

            if (spLoadDataGridName && spLoadDataGridName.trim() !== "") {
                var dataSource = window["DataSource_%ColumnName%"];
                if (dataSource && Array.isArray(dataSource) && dataSource.length > 1000) {
                    isSmartLoadNeeded = true;
                }
            }

            if (isSmartLoadNeeded) {
                window["UseAPILoad_%ColumnName%"] = true;
                return;
            }

            // Load bình thường cho TagBox - LUÔN CHUẨN HÓA THÀNH MẢNG
            Instance%ColumnName%%UID%._suppressValueChangeAction();

            var rawValue = obj.%ColumnName%;
            var normalizedValue;

            if (Array.isArray(rawValue)) {
                normalizedValue = rawValue.map(v => String(v).trim()).filter(v => v !== "");
            } else if (typeof rawValue === "string" && rawValue.trim() !== "") {
      normalizedValue = rawValue.split(",")
                                         .map(v => v.trim())
                                         .filter(v => v !== "");
            } else {
                normalizedValue = [];
            }

            Instance%ColumnName%%UID%.option("value", normalizedValue);
            Instance%ColumnName%%UID%._resumeValueChangeAction();
        '
    WHERE [Type] IN ('hpaControlTagBox')

    UPDATE #temptable SET
        loadData = N'
            // Smart Load logic (giữ nguyên logic check > 1000 dòng)
            var spLoadDataGridName = "%DataSourceSP%";
            var isSmartLoadNeeded = false;

            if (spLoadDataGridName && spLoadDataGridName.trim() !== "") {
                var dataSource = window["DataSource_%ColumnName%"];
                if (dataSource && Array.isArray(dataSource) && dataSource.length > 1000) {
                    isSmartLoadNeeded = true;
                }
            }

            if (isSmartLoadNeeded) {
                window["UseAPILoad_%ColumnName%"] = true;
                return;
            }

            // Load logic cho DateTime: Phải ép kiểu new Date để hiện đúng giờ
            Instance%ColumnName%%UID%._suppressValueChangeAction();
            if (obj && obj.%ColumnName%) {
                // Ép kiểu chuỗi SQL sang JS Date Object
                Instance%ColumnName%%UID%.option("value", new Date(obj.%ColumnName%));
            } else {
                Instance%ColumnName%%UID%.option("value", null);
            }
            Instance%ColumnName%%UID%._resumeValueChangeAction();
        '
    WHERE [Type] = 'hpaControlDateTime'

    UPDATE #temptable SET
        loadData = N'
        window["DataSource_%ColumnName%"] = window["DataSource_%ColumnName%"] || [];
            AjaxHPAParadise({
                data: {
                    name: "sp_GetFile",
                    param: ["LoginID", LoginID, "IdentityID", currentRecordID_%ColumnIDName%]
                },
                success: function (res) {
                    const json = typeof res === "string" ? JSON.parse(res) : res;
                    window["DataSource_%ColumnName%"] = (json.data && json.data[0]) || [];
                    Instance%ColumnName%%UID%.option("dataSource", window["DataSource_%ColumnName%"]);
                }
            });'
    WHERE [Type] = 'hpaControlFile'

    -- Build loadData đặc biệt cho Time (cần format khác) với smart load
    UPDATE #temptable SET
        loadData = N'
            // Smart Load: Check số dòng - nếu > 1000 thì dùng API, còn không thì load bình thường
            var spLoadDataGridName = "%DataSourceSP%";
            var isSmartLoadNeeded = false;

            // Kiểm tra xem có cần smart load hay không
            if (spLoadDataGridName && spLoadDataGridName.trim() !== "") {
                var dataSource = window["DataSource_%ColumnName%"];

                if (dataSource && Array.isArray(dataSource) && dataSource.length > 1000) {
                    isSmartLoadNeeded = true;
                }
            }

            // Nếu smart load, set flag và return
            if (isSmartLoadNeeded) {
                window["UseAPILoad_%ColumnName%"] = true;
                return;
            }

            // Load bình thường (dữ liệu nhỏ <= 1000)
            Instance%ColumnName%%UID%._suppressValueChangeAction();
            Instance%ColumnName%%UID%.option("value", obj.%ColumnName% ? new Date("1970/01/01 " + obj.%ColumnName%) : null);
            Instance%ColumnName%%UID%._resumeValueChangeAction();
        '
    WHERE [Type] = 'hpaControlTime'

    UPDATE #temptable SET
        loadData = N'
            // Smart Load: Check số dòng - nếu > 1000 thì dùng API, còn không thì load bình thường
            var spLoadDataGridName = "%DataSourceSP%";
            var isSmartLoadNeeded = false;

            // Kiểm tra xem có cần smart load hay không (chỉ cho các control có datasource)
            if (spLoadDataGridName && spLoadDataGridName.trim() !== "") {
                // Lấy data source từ window nếu đã load
                var dataSource = window["DataSource_%ColumnName%"];

                // Nếu chưa load hoặc dữ liệu trống, thì skip smart load cho lần này
                if (dataSource && Array.isArray(dataSource) && dataSource.length > 1000) {
                    isSmartLoadNeeded = true;
                }
            }

            // Nếu smart load, thì set flag để control sẽ tự động load qua API
            if (isSmartLoadNeeded) {
                window["UseAPILoad_%ColumnName%"] = true;
                return;
            }
            if (obj && obj.%ColumnName%) {
             var retryCount_%ColumnName%%UID% = 0;
                var fillDataInterval_%ColumnName%%UID% = setInterval(function() {
                    /* Kiểm tra xem biến rteObj đã tồn tại và chưa bị destroy chưa */
                    /* Lưu ý: ''undefined'' là do escaping trong SQL */
                    if (typeof rteObj_%ColumnName%%UID% !== ''undefined'' &&
                        rteObj_%ColumnName%%UID% &&
                        !rteObj_%ColumnName%%UID%.isDestroyed) {

                        /* --- BƯỚC 1: XỬ LÝ CHUỖI HTML TRƯỚC KHI GÁN --- */
                        var rawHtml = obj.%ColumnName%;


                        var safeHtml = rawHtml.replace(/<img([^>]*?)src=["'']([^"''+]+)["'']([^>]*?)>/gi, function(match, p1, srcVal, p2) {
                            /* Dùng nháy kép " cho chuỗi JS để không bị lỗi SQL */
                            if (srcVal.indexOf("http") === 0 || srcVal.indexOf("data:") === 0 || srcVal.indexOf("blob:") === 0) {
                                return match;
                            }
                            /* Dùng Template Literal (dấu huyền) để tạo chuỗi an toàn */
                            return `<img ${p1} src="data:image/gif;base64,R0lGODlhAQABAAD/ACwAAAAAAQABAAACADs=" data-original-url="${srcVal}" ${p2}>`;
                        });

                        /* --- BƯỚC 2: GÁN HTML SẠCH VÀO EDITOR --- */
                        rteObj_%ColumnName%%UID%.value = safeHtml;
                        rteObj_%ColumnName%%UID%.dataBind();

                        /* --- BƯỚC 3: CONVERT TỪ DATA-ORIGINAL-URL SANG BLOB --- */
                        try {
                            var rteElement = rteObj_%ColumnName%%UID%.inputElement;

                            var imgs = rteElement.querySelectorAll(''img'');

                            for (var i = 0; i < imgs.length; i++) {
                                var img = imgs[i];

                                var realPath = img.getAttribute(''data-original-url'');

                                if (realPath) {
                                    (function(targetImg, targetPath){
                                        convertPathToBlobUrl(targetPath).then(function(newBlobUrl){
                                            if (newBlobUrl) {
                                                /* ''src'' -> '''' */
                                                targetImg.setAttribute(''src'', newBlobUrl);
                                            }
                                        });
                                    })(img, realPath);
                                }
                            }
                        } catch(ex) { console.warn(ex); }

                        clearInterval(fillDataInterval_%ColumnName%%UID%);
                    } else {
                        retryCount_%ColumnName%%UID%++;
                        if (retryCount_%ColumnName%%UID% > 50) { clearInterval(fillDataInterval_%ColumnName%%UID%); }
                    }
                }, 200);
            } else {
                /* Xử lý khi dữ liệu null/rỗng */
                if (typeof rteObj_%ColumnName%%UID% !== ''undefined'' && rteObj_%ColumnName%%UID%) {
                    rteObj_%ColumnName%%UID%.value = "";
                    rteObj_%ColumnName%%UID%.dataBind();
                }
            }

            Instance%ColumnName%%UID%.innerText = obj.%ColumnName% || "";

        '
    WHERE [Type] = 'hpaControlRichTextEditor'

    -- ============================================================================
    -- GRID VIEW LAYOUT
    -- Build UI cho Grid View (dạng bảng với các cột động)
    -- ============================================================================
    IF EXISTS (SELECT 1 FROM #temptable WHERE Layout = 'Grid_View')
    BEGIN
        -- ========================================================================
        -- LẤY THÔNG TIN CƠ BẢN CỦA GRID
        -- ========================================================================
        DECLARE @PKColumnNameGrid VARCHAR(100) = 'ID'

        -- Lấy tên cột Primary Key từ config
        SELECT TOP 1 @PKColumnNameGrid = ColumnIDName
        FROM #temptable
        WHERE ColumnIDName IS NOT NULL

        SET @PKColumnNameGrid = ISNULL(@PKColumnNameGrid, 'ID')

        DECLARE @tableId NVARCHAR(64) = CAST(OBJECT_ID(@TableName) AS NVARCHAR(64))
        DECLARE @gridColumns NVARCHAR(MAX) = N''

        -- ========================================================================
        -- BUILD GRID CONTAINER CHO TẤT CẢ CÁC GRID
        -- Sử dụng CURSOR để lặp qua từng GridColumnName
        -- ========================================================================
        DECLARE @GridColumnsCursor CURSOR;
        DECLARE @GridColumnName VARCHAR(100);
        DECLARE @CurrentGridUID VARCHAR(100);

        SET @GridColumnsCursor = CURSOR FOR
        SELECT DISTINCT ColumnName
        FROM #temptable
        WHERE Layout = 'Grid_View' AND Type = 'hpaControlGrid';

        OPEN @GridColumnsCursor;
        FETCH NEXT FROM @GridColumnsCursor INTO @GridColumnName;
        WHILE @@FETCH_STATUS = 0
        BEGIN
            SELECT TOP 1 @CurrentGridUID = [UID]
            FROM #temptable
            WHERE Layout = 'Grid_View'
            AND Type = 'hpaControlGrid'
            AND ColumnName = @GridColumnName
            AND TableName = @TableName;

            SET @CurrentGridUID = ISNULL(@CurrentGridUID, '');

            -- RESET @gridColumns cho mỗi Grid
            SET @gridColumns = N'';

            -- DROP và TẠO LẠI #GridColumnsGrouped cho Grid hiện tại
            IF OBJECT_ID('tempdb..#GridColumnsGrouped') IS NOT NULL
                DROP TABLE #GridColumnsGrouped;

            -- BUILD COLUMNS CHỈ CHO GRID HIỆN TẠI (filter theo @GridColumnName)
            SELECT
                N'' + ISNULL(col.TableEditor, '') AS tableId,
                ISNULL(col.ColumnIDName, '') AS ColumnIDName,
                ISNULL(col.ColumnIDName2, '') AS ColumnIDName2,
                ISNULL(col.DataSourceSP, '') AS DataSourceSP,
                col.GridColumnName,
                col.ColumnName AS DataFieldName,
                col.[Type] AS ControlType,
                ISNULL(col.DisplayName, col.GridColumnName) AS DisplayName,
                ISNULL(col.GridWidth, 150) AS GridWidth,
                ISNULL(col.AllowSorting, 1) AS AllowSorting,
                ISNULL(col.AllowFiltering, 1) AS AllowFiltering,
                col.GroupIndex,
                MIN(col.ID) AS ColumnOrderID,
            MAX(CASE WHEN col.ReadOnly = 1 THEN col.loadUI ELSE NULL END) AS loadUI_View,
                MAX(CASE WHEN col.ReadOnly = 0 THEN col.loadUI ELSE NULL END) AS loadUI_Edit,
                MAX(CASE WHEN col.ReadOnly = 0 AND col.Type IS NOT NULL THEN 1 ELSE 0 END) AS HasEditMode
            INTO #GridColumnsGrouped
            FROM #temptable col
            WHERE col.GridColumnName = @GridColumnName AND col.TableName = @TableName
                AND col.Layout = 'Grid_View'
                AND (col.Type IS NOT NULL OR (col.Type IS NULL AND col.ColumnName IS NOT NULL))
            GROUP BY
                col.TableName,
                col.TableEditor,
                col.DataSourceSP,
                col.ColumnIDName,
                col.ColumnIDName2,
                col.GridColumnName,
                col.ColumnName,
                col.DisplayName,
                col.GridWidth,
                col.AllowSorting,
                col.AllowFiltering,
                col.[Type],
                col.GroupIndex;
				-- select * from #GridColumnsGrouped
            -- BUILD @gridColumns CHO GRID HIỆN TẠI
            SELECT @gridColumns += N'
            {
                dataField: "' + DataFieldName + N'",
                caption: "' + REPLACE(DisplayName, '"', '\"') + N'",
                width: ' + CAST(GridWidth AS VARCHAR(10)) + N',
                allowSorting: ' + CASE WHEN AllowSorting = 1 THEN 'true' ELSE 'false' END + N',
                allowFiltering: ' + CASE WHEN AllowFiltering = 1 THEN 'true' ELSE 'false' END + N',
                ' +
                CASE WHEN GroupIndex IS NOT NULL
                    THEN 'groupIndex: ' + CAST(GroupIndex AS VARCHAR(10)) + N', '
                    ELSE ''
                END
                +
                CASE
                    WHEN ControlType IS NULL THEN
                        N'cellTemplate: function(cellElement, cellInfo){
                            const val = cellInfo.value;

                            if (val === undefined || val === null || val === "") {
                                $("<div>").addClass("dx-placeholder").text("").appendTo(cellElement);
                                return;
                            }

                            $("<div>").text(val).appendTo(cellElement);
                        },'

                    WHEN ControlType NOT IN (
                        'hpaControlDateTime',
                        'hpaControlDate',
                        'hpaControlTime',
                        'hpaControlSelectEmployee'
                    ) THEN
                        N'cellTemplate: function(cellElement, cellInfo){
                            const val = cellInfo.value;

                            if (val === undefined || val === null || val === "") {
                                $("<div>").addClass("dx-placeholder").text("").appendTo(cellElement);
                                return;
                            }

                            const ds = window["DataSource_' + DataFieldName + '"];
                            if (ds && Array.isArray(ds)) {
                                const f = ds.find(x => x.id == val || x.ID == val);
                                if (f) {
                                    $("<div>").text(f.Text || f.Name || "").appendTo(cellElement);
                                    return;
                                }
                            }

                            $("<div>").text(cellInfo.displayValue ?? val).appendTo(cellElement);
                        },'
                    ELSE
                        ISNULL('cellTemplate: function(cellElement, cellInfo) {
                            ' + REPLACE(REPLACE(REPLACE(loadUI_View, '%ColumnName%', DataFieldName),'"#%UID%"','cellElement'),'%DataSourceSP%',DataSourceSP) + N'

                            const instance = Instance' + REPLACE(DataFieldName, '''', '''''') + N'%UID%;
                            if (instance && cellInfo.value !== undefined && cellInfo.value !== null) {
                                instance.option("value", cellInfo.value);
                            }
                        },'
                        ,
                        CASE
                        WHEN ControlType IN ('hpaControlDate','hpaControlTime','hpaControlDateTime') THEN
                        N'cellTemplate: function(cellElement, cellInfo){
  const val = cellInfo.value;
if (!val) {
                                $("<div>").addClass("dx-placeholder").text("").appendTo(cellElement);
                                return;
                            }

                            const d = new Date(val);
                            let text = "";

                            ' +
                            CASE
                                WHEN ControlType = 'hpaControlDate' THEN
                                    N'
                                    text = DevExpress.localization.formatDate(d, "dd/MM/yyyy");
                                    '
                                WHEN ControlType = 'hpaControlTime' THEN
                                  N'
                                    text = DevExpress.localization.formatDate(d, "HH:mm");
                                    '
                                WHEN ControlType = 'hpaControlDateTime' THEN
                                    N'
                                    text = DevExpress.localization.formatDate(d, "dd/MM/yyyy HH:mm");
                                    '
                            END
                            + N'

                            $("<div>").text(text).appendTo(cellElement);
                        },'
                        ELSE
                            N''  -- control khác xử lý chỗ khác
                        END
                        )
                END
                +
                CASE
                WHEN HasEditMode = 1

                THEN
                ISNULL(
                        N'
                        allowEditing: true,
                            editCellTemplate: function(cellElement, cellInfo) {
                            // Cập nhật record context ID cho row hiện tại
                            let rowID = null;
                            if (cellInfo.key !== undefined && cellInfo.key !== null) {
                                rowID = cellInfo.key;
                            } else if (cellInfo.data && cellInfo.data["%ColumnIDName%"] !== undefined) {
                                rowID = cellInfo.data["%ColumnIDName%"];
                            }

                            if (rowID !== null) {
                                currentRecordID_%ColumnIDName% = rowID;
                            }

                            if ("%ColumnIDName2%" && "%ColumnIDName2%".trim() !== "" && cellInfo.data && cellInfo.data["%ColumnIDName2%"] !== undefined) {
                                currentRecordID_%ColumnIDName2% = cellInfo.data["%ColumnIDName2%"];
                            }

                        ' + REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(loadUI_Edit, '%ColumnName%', DataFieldName), '"#%UID%"', 'cellElement'), '%tableId%', CHECKSUM(tableId)), '%ColumnIDName%', ColumnIDName), '%ColumnIDName2%', ColumnIDName2) + N'
                            // Set initial value
                            if (cellInfo.value !== undefined && cellInfo.value !== null && Instance' + REPLACE(DataFieldName, '''', '''''') + N'%UID%) {
                                Instance' + REPLACE(DataFieldName, '''', '''''') + N'%UID%.option("value", cellInfo.value);
                            }
                        },'
                    ,
                        N'
                            allowEditing: true,
                            editCellTemplate: function(cellElement, cellInfo) {
                                // Tạo một TextBox đơn giản để edit
                                const $input = $("<input>")
                                    .addClass("dx-texteditor-input")
                                    .val(cellInfo.value || "")
                                    .appendTo(cellElement);

                                // Khởi tạo dxTextBox
                                const textBox = cellElement.dxTextBox({
                               value: cellInfo.value,
   onValueChanged: function(e) {
                                        // Cập nhật giá trị vào grid
                                        cellInfo.setValue(e.value);
                                    }
                                }).dxTextBox("instance");

                                // Focus vào input
                                setTimeout(function() {
                                    $input.focus();
                                }, 100);
                            },
                        '
                    )
                ELSE N'
                    allowEditing: false,
                    '
                END
            +'
            },
                '
            FROM #GridColumnsGrouped
            ORDER BY ColumnOrderID;

            -- Bỏ dấu phẩy cuối cùng
            IF LEN(@gridColumns) > 0
                SET @gridColumns = LEFT(@gridColumns, LEN(@gridColumns) - 1);

            -- UPDATE GRID CONTAINER CHO GRID HIỆN TẠI
            UPDATE t1
            SET
                loadUI = REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(
                    N'
                        window.Instance%ColumnName%%UID% = null;
                        // Thêm responsive styles cho grid header
                        const style%ColumnName% = document.createElement("style");
                        style%ColumnName%.textContent = `
                            /* =============== RESPONSIVE POPUP STYLES =============== */
                            .dx-datagrid-search-panel .dx-placeholder {
                                display: none !important;
                            }

                            /* =============== FIX TEXTBOX TRONG GRID =============== */
                            .dx-datagrid .dx-texteditor {
                                width: 100% !important;
                                min-width: 0 !important;
                            }

                            .dx-datagrid .dx-texteditor-input {
                                width: 100% !important;
                                min-width: 0 !important;
                                box-sizing: border-box !important;
                            }

                            .dx-datagrid-rowsview .dx-row > td > div {
                                white-space: nowrap;
                                overflow: hidden;
                                text-overflow: ellipsis;
                                word-break: break-word !important;
                                line-height: 1.4 !important;
                            }

                            .dx-popup.hpa-responsive {
                                max-width: 95vw !important;
                                max-height: 95vh !important;
                                width: 95vw !important;
                                left: 0 !important;
                                top: 0 !important;
                            }

                            .dx-popup.hpa-responsive .dx-popup-content {
                                height: calc(95vh - 120px) !important;
                                max-height: calc(95vh - 120px) !important;
                                overflow-y: auto !important;
                                padding: 8px !important;
                                display: flex !important;
                                flex-direction: column !important;
                            }

                            .dx-popup.hpa-responsive .dx-popup-content-scrollable {
                                flex: 1 !important;
                                min-height: 0 !important;
                                overflow: auto !important;
                            }

                            .dx-popup-content.dx-popup-content-scrollable {
            height: auto !important;
                   }

                       .dx-popup.hpa-responsive .dx-toolbar-items {
                                padding: 4px 0 !important;
                                flex-wrap: wrap;
                            }

                            .dx-popup.hpa-responsive .dx-toolbar-item {
                                margin: 2px 2px !important;
                            }

                            /* =============== GRID HEADER STYLES =============== */
                            .dx-datagrid {
                                font-size: 14px;
                            }

                            .dx-datagrid-headers {
                                white-space: normal;
                                word-break: break-word;
                            }

                            .dx-datagrid-header-panel {
                                padding: 8px;
                            }

                            .dx-datagrid .dx-header-row {
                                height: auto;
                                min-height: 44px;
                            }

                            .dx-datagrid .dx-row > td {
                                padding: 8px !important;
                                vertical-align: middle !important;
                            }

                            .dx-datagrid .dx-col-fixed {
                                z-index: 800 !important;
                            }

                            /* Group row - sát mép */
                            .dx-datagrid .dx-group-row {
                                padding: 0 !important;
                            }

                            .dx-datagrid .dx-group-row > td {
                                padding: 8px !important;
                            }

                            .dx-datagrid .dx-group-row .dx-group-text {
                                padding: 0 !important;
                                margin: 0 !important;
                            }

                            /* Mobile responsive */
                            @media (max-width: 1024px) {
                                .dx-popup.hpa-responsive {
                                    max-width: 90vw !important;
                                    max-height: 90vh !important;
                                    width: 90vw !important;
                                    left: 5vw !important;
                                }
                                .dx-overlay-content.dx-popup-normal.dx-popup-draggable.dx-resizable {
                                    width: 90vw !important;
                                    max-width: 90vw !important;
                                }
                                .dx-popup.hpa-responsive .dx-popup-content {
                                    max-height: calc(95vh - 120px) !important;
                                }
                            }

                            @media (max-width: 768px) {
                                .dx-datagrid {
                                    font-size: 12px;
                                }

                                .dx-datagrid-headers {
                                    padding: 4px !important;
                                }

                                .dx-datagrid .dx-header-row {
                                    height: auto;
                                    min-height: 36px;
                                    padding: 0 !important;
                                }

                                .dx-datagrid-text-content {
                                    padding: 4px 2px !important;
                                    font-size: 11px !important;
                                    line-height: 1.3 !important;
                            overflow: visible !important;
                     white-space: nowrap;
             text-overflow: ellipsis;
                           word-break: break-word !important;
                                }

                                .dx-datagrid-text-content.dx-header-filter {
                                    padding: 2px 1px !important;
                                }

                                .dx-checkbox {
                                    width: 24px !important;
                                    height: 24px !important;
                                }

                                .dx-datagrid-rowsview {
                                    padding: 0 !important;
                                }

                                .dx-datagrid .dx-row {
                                    height: auto;
                                    min-height: 36px !important;
                                    padding: 0 !important;
                                }

                                .dx-datagrid .dx-data-row > td > div {
                                    padding: 4px 8px !important;
                                    white-space: nowrap;
                                    text-overflow: ellipsis;
                                    word-break: break-word !important;
                                    vertical-align: middle !important;
                                }

                                .dx-datagrid .dx-group-row > td {
                                    padding: 4px 2px !important;
                                }

                                .dx-pager {
                                    padding: 4px 0 !important;
                                }

                                .dx-pager-page,
                                .dx-pager-navigation {
                                    padding: 2px 4px !important;
                                    font-size: 11px !important;
                                }

                                .dx-searchbox {
                                    width: 100% !important;
                                    max-width: none !important;
                                }

                                .dx-searchbox .dx-texteditor-input {
                                    padding: 4px !important;
                                    font-size: 12px !important;
                                    height: 32px !important;
                                }

                                .dx-popup.hpa-responsive {
                                    max-width: 95vw !important;
                                    max-height: 85vh !important;
                                    width: 95vw !important;
                                    left: 2.5vw !important;
                                    top: 5vh !important;
                                }
                                .dx-overlay-content.dx-popup-normal.dx-popup-draggable.dx-resizable {
                                    width: 95vw !important;
                                    max-width: 95vw !important;
                                    height: auto !important;
                                    max-height: 85vh !important;
                                }
                                .dx-popup.hpa-responsive .dx-overlay-wrapper {
                                    position: fixed !important;
                                }
                                .dx-popup.hpa-responsive .dx-popup-content {
                                    height: calc(95vh - 120px) !important;
                                    max-height: calc(95vh - 120px) !important;
                                    font-size: 13px !important;
                                    padding: 6px !important;
            display: flex !important;
  flex-direction: column !important;
           }

 .dx-popup.hpa-responsive .dx-popup-content-scrollable {
                       flex: 1 !important;
                   min-height: 0 !important;
                                    overflow: auto !important;
                                }

                                .dx-popup-content.dx-popup-content-scrollable {
                                    height: auto !important;
                                }

                                /* Toolbar buttons */
                                .dx-popup.hpa-responsive .dx-toolbar-item .dx-button {
                                    padding: 6px 12px !important;
                                    font-size: 12px !important;
                                    min-height: 36px !important;
                                width: auto !important;
                                }
                                .dx-popup.hpa-responsive .dx-toolbar-item .dx-button .dx-button-text {
                                    font-size: 12px !important;
                                }
                                .dx-popup.hpa-responsive .dx-button {
                                    padding: 6px 12px !important;
                                    font-size: 12px !important;
                                    min-height: 36px !important;
                                    width: auto !important;
                                }
                                .dx-popup.hpa-responsive .dx-button .dx-button-text {
                                    font-size: 12px !important;
                                }
                                .dx-popup.hpa-responsive .dx-datagrid {
                                    font-size: 11px !important;
                                }
                                .dx-popup.hpa-responsive .dx-datagrid .dx-data-row td {
                                    padding: 4px 2px !important;
                                }
                            }

                            @media (max-width: 480px) {
                                .dx-datagrid {
                                    font-size: 12px;
                                }

                                .dx-datagrid-headers {
                                    padding: 2px !important;
                                }

                                .dx-datagrid .dx-header-row {
                                    min-height: 32px;
                                }

                                .dx-datagrid-text-content {
                                    padding: 2px 1px !important;
                                    font-size: 12px !important;
                                }

                                .dx-checkbox {
                                    width: 20px !important;
                                    height: 20px !important;
                                }

                                .dx-datagrid .dx-row {
                                    min-height: 32px;
                                }

                                .dx-datagrid .dx-data-row > td > div {
                                    padding: 8px !important;
                                    font-size: 12px !important;
                                }

                                .dx-pager-page,
                                .dx-pager-navigation {
                                    padding: 1px 2px !important;
                                    font-size: 12px !important;
                                }

                                .dx-popup.hpa-responsive {
                                    max-width: 98vw !important;
                                    max-height: 80vh !important;
                                    width: 98vw !important;
                                    left: 1vw !important;
                                    top: 10vh !important;
    }
                                .dx-overlay-content.dx-popup-normal.dx-popup-draggable.dx-resizable {

                              width: 98vw !important;
                                    max-width: 98vw !important;
                                    height: auto !important;
                                    max-height: 80vh !important;
                                }
                                .dx-popup.hpa-responsive .dx-overlay-wrapper {
                                    position: fixed !important;
                                }
                                .dx-popup.hpa-responsive .dx-popup-content {
                                    height: calc(95vh - 120px) !important;
                                    max-height: calc(95vh - 120px) !important;
                                    font-size: 12px !important;
                                    padding: 4px !important;
                                    display: flex !important;
                                    flex-direction: column !important;
                                }

                                .dx-popup.hpa-responsive .dx-popup-content-scrollable {
                                    flex: 1 !important;
                                    min-height: 0 !important;
                                    overflow: auto !important;
                                }

                                .dx-popup-content.dx-popup-content-scrollable {
                                    height: auto !important;
                                }
                                /* Toolbar buttons */
                                .dx-popup.hpa-responsive .dx-toolbar-item .dx-button {
                                    padding: 4px 8px !important;
                                    font-size: 11px !important;
                                    min-height: 32px !important;
                                    width: auto !important;
                                }
                                .dx-popup.hpa-responsive .dx-toolbar-item .dx-button .dx-button-text {
                                    font-size: 11px !important;
                                }
                                .dx-popup.hpa-responsive .dx-button {
                                    padding: 4px 8px !important;
                                    font-size: 11px !important;
                                    min-height: 32px !important;
                                    width: auto !important;
                                }
                                .dx-popup.hpa-responsive .dx-button .dx-button-text {
                                    font-size: 11px !important;
                                }
                                .dx-popup.hpa-responsive .dx-datagrid {
                                    font-size: 10px !important;
                                }
                                .dx-popup.hpa-responsive .dx-datagrid .dx-data-row td {
                                    padding: 2px 1px !important;
                                    font-size: 10px !important;
                                }
                                .dx-popup.hpa-responsive .dx-datagrid .dx-header-row {
                                    min-height: 28px !important;
                                }
                                .dx-popup.hpa-responsive .dx-checkbox {
                                    width: 18px !important;
                                    height: 18px !important;
                                }
                            }
                        `;
                        document.head.appendChild(style%ColumnName%);

                  // =============== GRID CONFIG DYNAMIC BASED ON DATA SIZE ===============
                        // Hàm tính remoteOperations dựa trên số lượng dòng
         window.getGridConfig_%ColumnName% = function(dataArray) {
                            const dataSize = Array.isArray(dataArray) ? dataArray.length : 0;
                const isLargeDataset = dataSize > 1000;

                            return {
                                remoteOperations: isLargeDataset,
                                pageSize: isLargeDataset ? 25 : 10,
                                allowedPageSizes: isLargeDataset ? [10, 25, 50] : [5, 10, 50, 100]
                            };
                        };

                        Instance%ColumnName%%UID% = $("#%ColumnName%").dxDataGrid({
                            dataSource: [],
                            keyExpr: "%PKColumnName%",
                            height: "100%",
                            width: "100%",
                            showBorders: true,
                            showRowLines: true,
                            rowAlternationEnabled: false,
                            hoverStateEnabled: true,
                            columnAutoWidth: true,
                            allowColumnReordering: false,
                            allowColumnResizing: false,
                            columnResizingMode: "widget",
                            wordWrapEnabled: true,
                            scrolling: {
                                mode: "standard",
                                showScrollbar: "onHover"
                            },
                            paging: {
                                enabled: true,
                                pageSize: 10
                            },
                            pager: {
                                visible: true,
                                allowedPageSizes: [5, 10, 50, 100],
                                showPageSizeSelector: true,
                                showInfo: true,
                                showNavigationButtons: true
                            },
                            selection: {
                                mode: "%SelectionMode%",
                                showCheckBoxesMode: "%ShowCheckBoxesMode%",
                                allowSelectAll: %AllowSelectAll%
                            },
                            searchPanel: {
                                visible: true,
                                width: 240,
                                placeholder: "Tìm kiếm"
                            },
                            headerFilter: { visible: true },
                            columnChooser: {
                                enabled: true,
                                mode: "select",
                                title: "Chọn cột hiển thị"
                            },
                            stateStoring: { enabled: false },
                            grouping: {
                                autoExpandAll: true,
                                contextMenuEnabled: false,
                                allowCollapsing: true
                            },
                            groupPanel: { visible: false },
                            columnFixing: { enabled: true },
                            editing: {
                                mode: "cell",
                                allowUpdating: true
                            },
                            rowDragging: {
                                allowReordering: true,
                                showDragIcons: true,
                                onReorder: function(e) {
                                    let dataSource = e.component.option("dataSource");
                                    const tableName = "%TableName%"
                            const pkColumn = "%ColumnIDName%"
            const item = dataSource[e.fromIndex];
    dataSource.splice(e.fromIndex, 1);
                                    dataSource.splice(e.toIndex, 0, item);
                e.component.option("dataSource", dataSource);
                      // LƯU thứ tự mới
  saveGridRowOrder(e.component, tableName, pkColumn);
                                }
                            },
                            noDataText: "Không có dữ liệu",
                                columns: [
                                {
                                    dataField: "rowIndex",
                                    caption: "STT",
                                    width: 60,
                                    allowSorting: false,
                                    allowFiltering: false,
                                    cellTemplate: function(container, cellInfo) {
                                        $(container).text(cellInfo.row.rowIndex + 1);
                                    },
                                    fixed: true,
                                    fixedPosition: "left"
                                },
                                %COLUMNS%
                            ],
                            onCellClick: function(e) {
                                // Nếu multiSelect k`hông bật và IsOpenDetailRowGrid không bật
                                if (%IsOpenDetailRowGrid% === 0) {
                                    return;
                                }

                                // Nếu bật IsOpenDetailRowGrid
                                if (%IsOpenDetailRowGrid% === 1) {
                                    // CHỈ CHO PHÉP click vào cột đầu tiên (index 0) - thường là cột ID/Mã
                                    if (e.columnIndex === 0) {
                                        const recordID = e.key || (e.data && e.data["%PKColumnName%"]);
                                        if (recordID !== undefined && recordID !== null && recordID !== "") {
                                            window.currentRecordID_%PKColumnName% = recordID;

                                            if (typeof openDetail%PKColumnName% === "function") {
                                                openDetail%PKColumnName%(recordID);
                                            }
                                        }
                                    }
                                }
                            },
                            onRowPrepared: function(e) {
                                if (e.rowType === "data") {
                                    // Nếu multiSelect không bật và IsOpenDetailRowGrid không bật
                                    if (%IsMultiSelectRowGrid% === 0 && %IsOpenDetailRowGrid% === 0) {
                                        return;
                                    }

                                    // Nếu bật IsOpenDetailRowGrid - CHỈ highlight cột đầu tiên
                                    if (%IsOpenDetailRowGrid% === 1 && %IsMultiSelectRowGrid% === 0) {
                                        const $firstCell = e.rowElement.find("td:first");
                                        if ($firstCell.length) {
                                            $firstCell.css({
                                                cursor: "pointer",
                                                color: "#1976d2",
                                                textDecoration: "none",
                                                fontWeight: "500"
                                            }).hover(
                                                function() {
    $(this).css({
                                                        textDecoration: "underline",
                          backgroundColor: "rgba(25, 118, 210, 0.08)"
          });
                                                },
                                                function() {
   $(this).css({
                                                        textDecoration: "none",
                             backgroundColor: ""
});
                                                }
                                            );
                                        }
                                    } else {
                                        // Trường hợp khác - cũng chỉ cột đầu là clickable
                                        const $firstCell = e.rowElement.find("td:first");
                                        if ($firstCell.length) {
                                            $firstCell.css({
                                                cursor: "pointer",
                                                color: "#1976d2",
                                                textDecoration: "none",
                                                fontWeight: "500"
                                            }).hover(
                                                function() { $(this).css({ textDecoration: "underline" }); },
                                                function() { $(this).css({ textDecoration: "none" }); }
                                            );
                                        }
                                    }
                                }
                            },
                            onContentReady: function (e) {
                                const grid = e.component;
                                const gridId = grid.element().attr("id");

                                // CHỈ LOAD CONFIG MỘT LẦN DUY NHẤT
                                if (!window._GridConfigLoaded_%ColumnName%) {
                                    window._GridConfigLoaded_%ColumnName% = true;

                                    loadGridColumnConfig(gridId, function (config) {
                                        if (!config || !config.visibleColumns || !Array.isArray(config.visibleColumns)) return;

                                        const originalColumns = window._OriginalColumnConfig_%ColumnName%;
                                        if (!originalColumns || !originalColumns.length) return;

                                        window.__isApplyingGridConfig__ = true;

                                        let hasChanges = false;
                                        let visibleIndex = 0;

                                        // Set visible + visibleIndex theo config
                                        originalColumns.forEach(col => {
                                            if (!col || !col.dataField || col.dataField === "rowIndex") return;

                                            const shouldBeVisible = config.visibleColumns.includes(col.dataField);

                                            if (col.visible !== shouldBeVisible) {
                                                col.visible = shouldBeVisible;
                                                hasChanges = true;
                                            }

                                            if (shouldBeVisible) {
                                                if (col.visibleIndex !== visibleIndex) {
                                                    col.visibleIndex = visibleIndex;
                                                    hasChanges = true;
                                                }
                                                visibleIndex++;
                                            }
                                        });

                                        // Apply vào grid
                                        if (hasChanges) {
                                            grid.beginUpdate();
                                            grid.option("columns", originalColumns);
                                            grid.endUpdate();
                                        }

                                        window.__isApplyingGridConfig__ = false;
      });
                                }

                                // XỬ LÝ SEARCH PANEL (giữ nguyên code cũ)
                                setTimeout(function() {
                                    const searchPanel = grid.getView("headerPanel");
                                    if (!searchPanel) return;
                                    const $searchBox = searchPanel._$element.find(".dx-datagrid-search-panel input");
                                    if ($searchBox.length && !$searchBox.data("vn-search-hooked")) {
                                        $searchBox.data("vn-search-hooked", true);
                                        $searchBox.off("input keyup change").on("input keyup change", function(event) {
                                            const searchValue = $(this).val();
                                            if (!searchValue || searchValue.trim() === "") {
                                                grid.clearFilter();
                                                return;
                                            }
                                            const searchNormalized = RemoveToneMarks_Js(searchValue.toLowerCase().trim());
                                            grid.filter(function(item) {
                                                for (let key in item) {
                                                    if (!item.hasOwnProperty(key)) continue;
                                                    const fieldValue = item[key];
                                                    if (fieldValue == null || fieldValue === "") continue;
                                                    const fieldStr = String(fieldValue);
                                                    const fieldNormalized = RemoveToneMarks_Js(fieldStr.toLowerCase());
                                                    if (fieldNormalized.indexOf(searchNormalized) !== -1) {
                                                        return true;
                                                    }
                                                }
                                                return false;
                                            });
                                        });
                                    }
                                }, 0);
                            },
                            onToolbarPreparing: function(e) {
                                let isReloading = false;

                                // Button Reload
                                e.toolbarOptions.items.unshift({
                                    location: "after",
                                    widget: "dxButton",
                                    options: {
                                        icon: "refresh",
                                        hint: "Tải lại",
                                        onClick: function() {
                                            if (isReloading) return;
                                            isReloading = true;
                                            this.option("disabled", true);
                                            ReloadData();
                                            setTimeout(() => {
                                                isReloading = false;
                                                this.option("disabled", false);
                                            }, 1000);
                                        }
                                    }
                                });
                            },
                            onInitialized: function(e) {
                                const grid = e.component;
                                const tableName = "%TableName%";

                                // Lưu reference GỐC (không stringify - giữ functions)
                                if (!window._OriginalColumnConfig_%ColumnName%) {
                                    window._OriginalColumnConfig_%ColumnName% = grid.option("columns");
                                }

                                // Reset flag lấy config
                                window._GridConfigLoaded_%ColumnName% = false;
                            },
                            onOptionChanged: function (e) {
                                if (e.fullName.startsWith("columns[")) {

                                    const isColumnLayoutChange =
                                        e.fullName.includes(".visible") ||
                                        e.fullName.includes(".visibleIndex");

                                    const grid = e.component;
                                    const gridId = grid.element().attr("id");

                                    if (isColumnLayoutChange) {
                                        clearTimeout(window.__saveGridColumnTimeout__%ColumnName%);
                                        window.__saveGridColumnTimeout__%ColumnName% = setTimeout(() => {
                                            const cols = e.component.getVisibleColumns();
                                            saveGridColumnConfig(gridId, cols);
                                        }, 800);
                                    }
                                }

                                // FILTER STATE
                                const isFilterChange =
                                    e.name === "filterValue" ||
                                    e.fullName === "searchPanel.text" ||
                                    (e.fullName.includes("columns[") &&
                                        (
                                            e.fullName.includes("filterValue") ||
                                            e.fullName.includes("filterValues") ||
                                            e.fullName.includes("selectedFilterOperation")
                                        ));

                                if (isFilterChange) {
                                    clearTimeout(window.__saveFilterTimeout__%ColumnName%);
                                    window.__saveFilterTimeout__%ColumnName% = setTimeout(() => {
                                        saveGridFilterState("%TableName%", e.component);
                                    }, 500);
                                }
                            }

                        }).dxDataGrid("instance");
                    ',
                    '%COLUMNS%', @gridColumns),
                    '%PKColumnName%', @PKColumnNameGrid),
                    '%Layout%', Layout),
                    '%UID%', @CurrentGridUID),
                    '%ColumnName%', ColumnName),
                    '%IsOpenDetailRowGrid%', ISNULL(IsOpenDetailRowGrid, 0)),
                    '%IsMultiSelectRowGrid%', ISNULL(IsMultiSelectRowGrid, 0)),
                    '%SelectionMode%', CASE WHEN ISNULL(IsMultiSelectRowGrid, 0) = 1 THEN 'multiple' ELSE 'single' END),
                    '%ShowCheckBoxesMode%', CASE WHEN ISNULL(IsMultiSelectRowGrid, 0) = 1 THEN 'onClick' ELSE 'none' END),
                    '%AllowSelectAll%', CASE WHEN ISNULL(IsMultiSelectRowGrid, 0) = 1 THEN 'true' ELSE 'false' END),
                html = N'<div id="%ColumnName%" style="height: 100%;"></div>'
            FROM #temptable t1
            WHERE t1.Type = 'hpaControlGrid'
                AND t1.ColumnName = @GridColumnName;
            FETCH NEXT FROM @GridColumnsCursor INTO @GridColumnName;
        END;

        CLOSE @GridColumnsCursor;
        DEALLOCATE @GridColumnsCursor;
    END

    -- ============================================================================
    -- OPTIMIZE: Collect unique DataSourceSP và gọi API 1 lần
    -- ============================================================================
    DECLARE @UniqueDataSources TABLE (
        DataSourceSP VARCHAR(256),
        ColumnNames NVARCHAR(MAX)
    );

    -- Insert các DataSourceSP unique vào temp table
    INSERT INTO @UniqueDataSources (DataSourceSP, ColumnNames)
    SELECT
        DatasourceSP,
        STRING_AGG(ColumnName, ',') WITHIN GROUP (ORDER BY ColumnName)
    FROM #temptable
    WHERE DatasourceSP IS NOT NULL
      AND LTRIM(RTRIM(DatasourceSP)) <> ''
      AND ColumnName IS NOT NULL
    GROUP BY DatasourceSP;
	
-- Xóa các dòng build control cho grid sau khi đã nối chuỗi xong
    DELETE FROM #temptable WHERE Layout = 'Grid_View' AND GridColumnName IS NOT NULL AND Type <> 'hpaControlGrid';
	
    -- ============================================================================
    -- THAY THẾ CÁC PLACEHOLDER (OPTIMIZED: Consolidated nested REPLACE + CHECKSUM Caching)
    -- ============================================================================
    -- Tạo bảng tạm để cache CHECKSUM calculation (tính 1 lần thay vì N lần)
    DECLARE @ChecksumCache TABLE (TableEditor NVARCHAR(256), ChecksumVal VARCHAR(64));

    INSERT INTO @ChecksumCache (TableEditor, ChecksumVal)
    SELECT DISTINCT t.TableEditor, CAST(CHECKSUM(o.name) AS VARCHAR(64))
    FROM #temptable t
    LEFT JOIN sys.objects o ON o.name = t.TableEditor AND o.type = 'U'
    WHERE t.TableEditor IS NOT NULL;

    UPDATE #temptable SET loadUI = REPLACE(loadUI, '%tableId%', ISNULL((SELECT TOP 1 ChecksumVal FROM @ChecksumCache WHERE TableEditor = #temptable.TableEditor), ''));
    UPDATE #temptable SET loadUI = REPLACE(loadUI, '%UID%', ISNULL([UID], ''));
    UPDATE #temptable SET loadUI = REPLACE(loadUI, '%TableName%', ISNULL(TableName, ''));
    UPDATE #temptable SET loadUI = REPLACE(loadUI, '%ColumnName%', ISNULL(ColumnName, ''));
    UPDATE #temptable SET loadUI = REPLACE(loadUI, '%DatasourceSP%', ISNULL(DatasourceSP, ''));
    UPDATE #temptable SET loadUI = REPLACE(loadUI, '%columnId%', ISNULL(columnId, ''));
    UPDATE #temptable SET loadUI = REPLACE(loadUI, '%ColumnIDName%', ISNULL(ColumnIDName, ''));
    UPDATE #temptable SET loadUI = REPLACE(loadUI, '%ColumnIDName2%', ISNULL(ColumnIDName2, ''));
    UPDATE #temptable SET loadUI = REPLACE(loadUI, '%Layout%', ISNULL(Layout, ''));
    UPDATE #temptable SET loadUI = REPLACE(loadUI, '%IsAlert%', ISNULL(CAST(IsAlert AS VARCHAR(10)), '0'));
    UPDATE #temptable SET loadUI = REPLACE(loadUI, '%IsRequired%', ISNULL(CAST(IsRequired AS VARCHAR(10)), '0'));
    UPDATE #temptable SET loadUI = REPLACE(loadUI, '%TableAddNew%', ISNULL(TableAddNew, ''));
    UPDATE #temptable SET loadUI = REPLACE(loadUI, '%ColumnNameAddNew%', ISNULL(ColumnNameAddNew, ''));
    UPDATE #temptable SET loadUI = REPLACE(loadUI, '%ActionRichTextEditor%', ISNULL(ActionRichTextEditor, ''));
    UPDATE #temptable SET loadUI = REPLACE(loadUI, '%DisplayName%', ISNULL(DisplayName, ''));
    UPDATE #temptable SET loadUI = REPLACE(loadUI, '%GridColumnName%', ISNULL(GridColumnName, 0));

    UPDATE #temptable
    SET loadData = REPLACE(
            REPLACE(
                REPLACE(
                    REPLACE(
                        REPLACE(
                            REPLACE(
                                REPLACE(loadData, '%UID%', ISNULL([UID], '')),
                            '%ColumnName%', ISNULL(ColumnName, '')),
                        '%DatasourceSP%', ISNULL(DatasourceSP, '')),
                    '%columnId%', ISNULL(columnId, '')),
                '%ColumnIDName%', ISNULL(ColumnIDName, '')),
            '%ColumnIDName2%', ISNULL(ColumnIDName2, '')),
        '%Layout%', ISNULL(Layout, ''));

    UPDATE #temptable
    SET html = REPLACE(
       REPLACE(
                REPLACE(html, '%UID%', ISNULL([UID], '')),
            '%Layout%', ISNULL(Layout, '')),
        '%ColumnName%', ISNULL(ColumnName, ''));

    -- ============================================================================
    -- XUẤT KẾT QUẢ CUỐI CÙNG (OPTIMIZED: Gộp 4 SELECT thành 1)
    -- ============================================================================
    DECLARE @SPLoadData VARCHAR(100), @ColumnIDName VARCHAR(100), @UID VARCHAR(100), @ColumnName VARCHAR(100);
    DECLARE @ColumnIDNames TABLE (ColumnIDName VARCHAR(200));
    DECLARE @ColumnIDNames2 TABLE (ColumnIDName2 VARCHAR(200));

    -- Lấy thông tin cơ bản 1 lần duy nhất
    SELECT TOP 1
        @SPLoadData = SPLoadData,
        @UID = [UID],
        @ColumnName = [ColumnName],
        @GridColumnName = ISNULL((SELECT TOP 1 [ColumnName] FROM #temptable WHERE TableName = @TableName AND Layout = 'Grid_View'), '')
    FROM #temptable
    WHERE TableName = @TableName

    -- Lấy danh sách ColumnIDName
    INSERT INTO @ColumnIDNames(ColumnIDName)
    SELECT DISTINCT ColumnIDName
    FROM #temptable
    WHERE TableName = @TableName
      AND ColumnIDName IS NOT NULL;

    INSERT INTO @ColumnIDNames2(ColumnIDName2)
    SELECT DISTINCT ColumnIDName2
    FROM #temptable
    WHERE TableName = @TableName
      AND ColumnIDName2 IS NOT NULL;

    -- Build JavaScript variables cho currentRecordID
    DECLARE @jsCurrentRecordID NVARCHAR(MAX) = N'';
    DECLARE @jsCurrentRecordID2 NVARCHAR(MAX) = N'';

    -- Thay đổi cách build @jsCurrentRecordID
    SELECT @jsCurrentRecordID += ' window.currentRecordID_' + ColumnIDName + ' = null;'
    FROM @ColumnIDNames
    WHERE ColumnIDName IS NOT NULL;

    SELECT @jsCurrentRecordID2 += ' window.currentRecordID_' + ColumnIDName2 + ' = null;'
    FROM @ColumnIDNames2
    WHERE ColumnIDName2 IS NOT NULL;

    DECLARE @jsHandleRecord NVARCHAR(MAX) = N'';
    DECLARE @jsHandleRecord2 NVARCHAR(MAX) = N'';

    SELECT @jsHandleRecord += ' if (obj) { window.currentRecordID_' + ColumnIDName + ' = (obj.' + ColumnIDName + ' !== undefined && obj.' + ColumnIDName + ' !== null) ? obj.' + ColumnIDName + ' : window.currentRecordID_' + ColumnIDName + '; }'
    FROM @ColumnIDNames;

    SELECT @jsHandleRecord2 += ' if (obj) { window.currentRecordID_' + ColumnIDName2 + ' = (obj.' + ColumnIDName2 + ' !== undefined && obj.' + ColumnIDName2 + ' !== null) ? obj.' + ColumnIDName2 + ' : window.currentRecordID_' + ColumnIDName2 + '; }'
    FROM @ColumnIDNames2;

    -- Build JavaScript code để load tất cả unique DataSourceSP
    DECLARE @jsLoadAllDataSources NVARCHAR(MAX) = N'';

    SELECT @jsLoadAllDataSources += N'
            // Load DataSource: ' + DataSourceSP + N'
            if ("' + DataSourceSP + N'" && "' + DataSourceSP + N'".trim() !== "") {
                loadDataSourceCommon("' + LEFT(ColumnNames, CHARINDEX(',', ColumnNames + ',') - 1) + N'", "' + DataSourceSP + N'", function(data) {
                    // Data được shared qua callback
                });
            }
        '
    FROM @UniqueDataSources
    WHERE DataSourceSP IS NOT NULL;

    IF ISNULL(LTRIM(RTRIM(@jsLoadAllDataSources)), '') <> ''
    BEGIN
    SET  @jsLoadAllDataSources += N'
        function loadDataSourceCommon(columnName, dataSourceSP, onSuccessCallback) {
            if (!columnName || !dataSourceSP || dataSourceSP.trim() === "") {
                console.warn("[loadDataSourceCommon] Missing columnName or dataSourceSP");
                return;
            }

            const dataSourceKey = "DataSource_" + columnName;
            // Sử dụng format: columnNameDataSourceLoaded để tương thích với code hiện tại
            const loadedKey = columnName + "DataSourceLoaded";

            // Kiểm tra nếu đã load rồi thì không load lại
            if (window[loadedKey] === true) {
                if (typeof onSuccessCallback === "function") {
                    onSuccessCallback(window[dataSourceKey] || []);
                }
                return;
            }

            // Kiểm tra nếu đang load thì đợi
            if (window[loadedKey] === "loading") {
                // Đợi một chút rồi thử lại
                setTimeout(function() {
                    loadDataSourceCommon(columnName, dataSourceSP, onSuccessCallback);
                }, 100);
                return;
            }

            // Đánh dấu đang load để tránh load trùng lặp
            window[loadedKey] = "loading";

            return new Promise((resolve, reject) => {
                AjaxHPAParadise({
                    data: {
                        name: dataSourceSP,
                        param: ["LoginID", LoginID, "LanguageID", LanguageID]
                    },
                    success: function (res) {
                        const json = typeof res === "string" ? JSON.parse(res) : res;

                        window[dataSourceKey] = (json.data && json.data[0]) || [];
                        window[loadedKey] = true;

                        // Ưu tiên lấy từ json response (nếu API trả về explicit)
                        // Sau đó mới fallback query dataSchema
                        let idField = json.valueExpr;
                        let nameField = json.displayExpr;

                        if (!idField || !nameField) {
                            if (json.dataSchema && json.dataSchema[0]) {
                                const schema = json.dataSchema[0];
                                if (!idField) idField = schema[0]?.name;
                                if (!nameField) nameField = schema[1]?.name;
                            }
                        }

                        window["DataSourceIDField_" + columnName]   = idField || "ID";
                        window["DataSourceNameField_" + columnName] = nameField || "Name";

                        const data = window[dataSourceKey];

                        // callback trước
                        if (typeof onSuccessCallback === "function") {
                            onSuccessCallback(data, json);
                        }

                        // resolve sau
                        resolve(data);
                    },
                    error: function (err) {
                        console.error("[loadDataSourceCommon] Failed to load datasource for", columnName, ":", err);
                        window[loadedKey] = false;

                        if (typeof onSuccessCallback === "function") {
                            onSuccessCallback([]);
                        }

                        reject(err);
                    }
                });
            });
        }
    ';
    END

    DECLARE @jsLayoutHandling NVARCHAR(MAX) = N'';
    IF @UseLayout = 1
    BEGIN
        DECLARE @GridHandlingCursor CURSOR;
        DECLARE @CurrentGridName VARCHAR(100);
        DECLARE @CurrentGridUID_JS VARCHAR(100);
        DECLARE @CurrentGridPKColumnName VARCHAR(100);

        SET @GridHandlingCursor = CURSOR FOR
        SELECT DISTINCT ColumnName, [UID], ColumnIDName
        FROM #temptable
        WHERE Layout = 'Grid_View' AND Type = 'hpaControlGrid';

        OPEN @GridHandlingCursor;
        FETCH NEXT FROM @GridHandlingCursor INTO @CurrentGridName, @CurrentGridUID_JS, @CurrentGridPKColumnName;

        WHILE @@FETCH_STATUS = 0
        BEGIN
            SET @jsLayoutHandling += N'
                const gridInstance' + @CurrentGridName + ' = Instance' + @CurrentGridName + @CurrentGridUID_JS + N';
                const gridConfig' + @CurrentGridName + ' = window.getGridConfig_' + @CurrentGridName + N'(results);

                loadGridRowOrder(
                    "' + @TableName + '",
                    results,
                    "' + @CurrentGridPKColumnName + '",
                    function(sortedData) {
                        // Clear search panel khi reload
                        gridInstance' + @CurrentGridName + '.option("searchPanel.text", "");

                        gridInstance' + @CurrentGridName + '.beginUpdate();
                        gridInstance' + @CurrentGridName + '.option("scrolling", {
                            mode: "standard",
                            showScrollbar: "onHover"
                        });
                        gridInstance' + @CurrentGridName + '.option("remoteOperations", false);
                        gridInstance' + @CurrentGridName + '.option("paging.enabled", true);
                        gridInstance' + @CurrentGridName + '.option("paging.pageSize", gridConfig' + @CurrentGridName + '.pageSize);
                        gridInstance' + @CurrentGridName + '.option("pager.allowedPageSizes", gridConfig' + @CurrentGridName + '.allowedPageSizes);
                        gridInstance' + @CurrentGridName + '.pageIndex(0);
                        gridInstance' + @CurrentGridName + '.option("dataSource", sortedData);

                        gridInstance' + @CurrentGridName + '.endUpdate();

                        // RESTORE FILTER STATE TỪ LOCALSTORAGE (nếu không skip)
                        setTimeout(function() {
                            if (window._SkipRestoreFilter) {
                                window._SkipRestoreFilter = false;
                                return;
                            }
                            const savedFilter = loadGridFilterState("' + @TableName + '", gridInstance' + @CurrentGridName + ');
                            if (savedFilter) {
                                applyGridFilterState(gridInstance' + @CurrentGridName + ', savedFilter);
                            }
                        }, 100);
                    }
                );
            ';

            FETCH NEXT FROM @GridHandlingCursor INTO @CurrentGridName, @CurrentGridUID_JS, @CurrentGridPKColumnName;
        END;

        CLOSE @GridHandlingCursor;
        DEALLOCATE @GridHandlingCursor;
  END

    DECLARE @jsFunctionGridConfig NVARCHAR(MAX) = N'';
    IF @UseLayout = 1 AND @CurrentGridName IS NOT NULL
    BEGIN
        SET @jsFunctionGridConfig = N'
        // =============== GRID COLUMN CONFIG PERSISTENCE ===============
        function saveGridColumnConfig(gridId, columns) {
            const menuId = getActiveMenuId();
            if (!menuId) {
                console.warn("Không lấy được menuId");
                return;
            }

            if (!gridId) {
                console.warn("gridId không hợp lệ");
                return;
            }

            const visibleColumns = columns
                .filter(col =>
                    col.visible !== false &&
                    col.dataField &&
                    col.dataField !== "rowIndex" &&
                    typeof col.dataField === "string"
                )
                .map(col => col.dataField);

            const columnOrder = columns
                .filter(col =>
                    col.dataField &&
                    col.dataField !== "rowIndex" &&
                    typeof col.dataField === "string"
                )
                .map(col => col.dataField);

            const config = { visibleColumns, columnOrder };

            console.log("[SaveConfig]", {
                menuId,
                gridId,
                config
            });

            AjaxHPAParadise({
                data: {
                    name: "sp_SaveGridColumnConfig",
                    param: [
                        "LoginID", LoginID,
                        "MenuID", menuId,
                        "GridID", gridId,
                        "ColumnConfigJson", JSON.stringify(config)
                    ]
                }
            });
        }

        function getActiveMenuId() {
            const activeTab = $(".nav-link.active");
            const tabId = activeTab.filter("button").attr("id");
            return tabId ? tabId.split("-").pop() : null;
        }

        function loadGridColumnConfig(gridId, callback) {
            const menuId = getActiveMenuId();
            if (!menuId) {
                console.warn("Không lấy được menuId");
                if (typeof callback === "function") callback({});
                return;
            }

            AjaxHPAParadise({
                data: {
                    name: "sp_GetGridColumnConfig",
                    param: [
                        "LoginID", LoginID,
                        "MenuID", menuId,
                        "GridID", gridId
                    ]
                },
                async: false,
                success: function (res) {
                    let config = {};

                    const json = typeof res === "string" ? JSON.parse(res) : res;

                    if (
                        json &&
                        json.data &&
                        json.data[0] &&
                        json.data[0][0] &&
                        json.data[0][0].ColumnConfigJson
                    ) {
                        const raw = json.data[0][0].ColumnConfigJson;
                        config = typeof raw === "string" ? JSON.parse(raw) : raw;
                    }

                    if (typeof callback === "function") {
                        callback(config);
                    }
                }
            });
        }

        // =============== FILTER STATE - LOCALSTORAGE ONLY ===============
        function saveGridFilterState(tableName, gridInstance) {
            try {
                const filterValue = gridInstance.getCombinedFilter();
                const searchValue = gridInstance.option("searchPanel.text") || "";

                // Lấy filter của từng cột
                const columnFilters = {};
                const columns = gridInstance.option("columns");

                columns.forEach(col => {
                    if (col.dataField && col.filterValue !== undefined) {
                        columnFilters[col.dataField] = {
                            filterValue: col.filterValue,
                            filterType: col.filterType || "include",
                            selectedFilterOperation: col.selectedFilterOperation
                        };
                    }
                });

                const filterState = {
                    combinedFilter: filterValue,
                    searchText: searchValue,
                    columnFilters: columnFilters,
                    timestamp: new Date().getTime()
                };

                // CHỈ LƯU VÀO LOCALSTORAGE
                localStorage.setItem("GridFilter_" + tableName + "_" + LoginID, JSON.stringify(filterState));
            } catch(e) {
                console.error("[SaveFilterState] Error:", e);
            }
        }

        function loadGridFilterState(tableName, gridInstance) {
            try {
                const storageKey = "GridFilter_" + tableName + "_" + LoginID;
                const savedState = localStorage.getItem(storageKey);

                if (!savedState) {
                    return null;
                }

                const filterState = JSON.parse(savedState);

                return filterState;
            } catch(e) {
                console.error("[LoadFilterState] Error:", e);
                return null;
            }
        }

        function applyGridFilterState(gridInstance, filterState) {

            if (!filterState) return;

            try {
                gridInstance.beginUpdate();

                // 1. Apply search text
                if (filterState.searchText) {
                    gridInstance.option("searchPanel.text", filterState.searchText);
                }

                // 2. Apply column filters
                if (filterState.columnFilters) {
                    Object.keys(filterState.columnFilters).forEach(dataField => {
                        const colFilter = filterState.columnFilters[dataField];
                        const colIndex = gridInstance.columnOption(dataField, "index");

                        if (colIndex !== undefined) {
                            gridInstance.columnOption(dataField, "filterValue", colFilter.filterValue);
                            if (colFilter.filterType) {
                                gridInstance.columnOption(dataField, "filterType", colFilter.filterType);
                            }
                            if (colFilter.selectedFilterOperation) {
                                gridInstance.columnOption(dataField, "selectedFilterOperation", colFilter.selectedFilterOperation);
                            }
                        }
                    });
                }

                // 3. Apply combined filter (fallback)
                if (filterState.combinedFilter && !filterState.columnFilters) {
                    gridInstance.option("filterValue", filterState.combinedFilter);
                }

                gridInstance.endUpdate();

            } catch(e) {
                console.error("[ApplyFilterState] Error:", e);
            }
        }

        function clearGridFilterState(tableName) {
            try {
                const storageKey = "GridFilter_" + tableName + "_" + LoginID;
                localStorage.removeItem(storageKey);
            } catch(e) {
                console.error("[ClearFilterState] Error:", e);
            }
        }

        // =============== ROW ORDER PERSISTENCE ===============
        function saveGridRowOrder(gridInstance, tableName, pkColumn) {
            const dataSource = gridInstance.option("dataSource");
            const rowOrderArray = dataSource.map(item => item[pkColumn]);

            AjaxHPAParadise({
                data: {
                    name: "sp_SaveGridRowOrder",
                    param: [
                        "LoginID", LoginID,
                        "TableName", tableName,
                        "RowOrderJson", JSON.stringify(rowOrderArray)
                    ]
                },
                success: function(res) {},
                error: function(err) {
                    console.error("[SaveRowOrder] Error:", err);
                }
            });
        }

        function loadGridRowOrder(tableName, dataSource, pkColumn, callback) {
            AjaxHPAParadise({
                data: {
                    name: "sp_GetGridRowOrder",
                    param: ["LoginID", LoginID, "TableName", tableName]
                },
                async: false,
                success: function(res) {
                    try {
                        const json = typeof res === "string" ? JSON.parse(res) : res;
                        const rowOrderJson = json.data[0][0].RowOrderJson;

                        if (rowOrderJson && rowOrderJson !== "[]") {
                            const savedOrder = JSON.parse(rowOrderJson);

                            const dataMap = {};
                            dataSource.forEach(item => {
                                dataMap[item[pkColumn]] = item;
                            });

                            const sortedData = [];
                            savedOrder.forEach(id => {
                                if (dataMap[id]) {
                                    sortedData.push(dataMap[id]);
                          delete dataMap[id];
                                }
                            });

              Object.values(dataMap).forEach(item => {
                                sortedData.push(item);
                            });

                            if (typeof callback === "function") {
                                callback(sortedData);
                            }
                        } else {
                            if (typeof callback === "function") {
   callback(dataSource);
                            }
                        }
                    } catch (e) {
                        if (typeof callback === "function") {
                            callback(dataSource);
                        }
                    }
                },
                error: function(err) {
                    console.error("[LoadRowOrder] Error:", err);
                    if (typeof callback === "function") {
                        callback(dataSource);
                    }
                }
            });
        }

        // =============== MYWORK FILTER STATE PERSISTENCE ===============
        function saveFilterState(filterType) {
            try {
                localStorage.setItem("MyWork_Filter_" + LoginID, filterType);
            } catch (e) {
                console.error("[SaveFilterState] Error:", e);
            }
        }

        function loadFilterState() {
            try {
                const saved = localStorage.getItem("MyWork_Filter_" + LoginID);
                if (saved) {
                    return saved;
                }
            } catch (e) {
                console.error("[LoadFilterState] Error:", e);
            }
            return "all";
        }

        function applyFilter(filterType) {
            currentFilter = filterType;
            const gridInstance = InstancegridMyWorkPDB2DB35885F14803A9A52961A7871972;

            if (!gridInstance) return;

            let filteredData = allTasks;

            if (filterType === "todo") {
                filteredData = allTasks.filter(task => task.Status === 1);
            } else if (filterType === "doing") {
                filteredData = allTasks.filter(task => task.Status === 2);
            } else if (filterType === "overdue") {
                // Filter tasks that are overdue (có deadline < hôm nay và status !== 3 (Done))
                const today = new Date();
                today.setHours(0, 0, 0, 0);
                filteredData = allTasks.filter(task => {
                    if (task.Status === 3) return false; // Exclude done tasks
                    const deadlineDate = new Date(task.DeadlineDate);
                    return deadlineDate < today;
                });
            }
            // else filterType === "all" -> show all tasks

            gridInstance.option("dataSource", filteredData);

            // Lưu filter vào localStorage
            saveFilterState(filterType);
        }

        function restoreFilterState() {
            const savedFilter = loadFilterState();
            currentFilter = savedFilter;

            // Cập nhật UI button
            $(".filter-btn").removeClass("active");
            $(`.filter-btn[data-filter="${savedFilter}"]`).addClass("active");

            // Áp dụng filter
            applyFilter(savedFilter);
        }
    ';
    END

    -- ============================================================================
    -- VALIDATION ENGINE SETUP
    -- ============================================================================
    DECLARE @jsValidationEngine NVARCHAR(MAX) = N'
        // ValidationEngine utility for validation messages
        window.ValidationEngine = window.ValidationEngine || {};
        window.ValidationEngine.getRequiredMessage = function(displayName) {
            return "không được để trống " + (displayName || "trường này");
        };
    ';

    -- ============================================================================
    -- BUILD HTML OUTPUT
    -- ============================================================================
    DECLARE @nsqlHtml NVARCHAR(MAX) = N'
    <div id="%TableName%">
        %paradisehtml%
    </div>
    <script>
        (() => {
            let DataSource = []
            %JS_LOAD_ALL_DATA_SOURCES%
            %JS_VALIDATION_ENGINE%
            %paradiseloadUI%
    %JS_CURRENT_ID%
            %jsFunctionGridConfig%

            function ReloadData() {
                AjaxHPAParadise({
                    data: {
                        name: "%SPLoadData%",
                        param: []
                    },
                    success: function (res) {
                        const json = typeof res === "string" ? JSON.parse(res) : res;
                        const results = Array.isArray(json?.data?.[0])
                            ? json.data[0]
                            : (json?.data?.[0] ? [json.data[0]] : []);

                        const obj = results.length === 1 ? results[0] : (results[0] || null);

                        %jsLayoutHandling%
                        %JS_HANDLE_RECORD%
                        DataSource = results;
                        %paradiseloadData%
                    }
                })
            }
            ReloadData()
        })();
    </script>'
	
    -- Thay thế placeholders
    SET @nsqlHtml = REPLACE(@nsqlHtml, '%TableName%', ISNULL(@TableName, ''))
    SET @nsqlHtml = REPLACE(@nsqlHtml, '%ColumnName%', ISNULL(@ColumnName, ''))
    SET @nsqlHtml = REPLACE(@nsqlHtml, '%SPLoadData%', ISNULL(@SPLoadData, ''))
    SET @nsqlHtml = REPLACE(@nsqlHtml, '%UseLayout%', CAST(@UseLayout AS VARCHAR(1)))
    SET @nsqlHtml = REPLACE(@nsqlHtml, '%jsLayoutHandling%', @jsLayoutHandling)
    SET @nsqlHtml = REPLACE(@nsqlHtml, '%jsFunctionGridConfig%', @jsFunctionGridConfig)
    SET @nsqlHtml = REPLACE(@nsqlHtml, '%JS_CURRENT_ID%', @jsCurrentRecordID);
    SET @nsqlHtml = REPLACE(@nsqlHtml, '%JS_HANDLE_RECORD%', @jsHandleRecord);
    SET @nsqlHtml = REPLACE(@nsqlHtml, '%JS_LOAD_ALL_DATA_SOURCES%', @jsLoadAllDataSources);
    SET @nsqlHtml = REPLACE(@nsqlHtml, '%JS_VALIDATION_ENGINE%', @jsValidationEngine);
    SET @nsqlHtml = REPLACE(@nsqlHtml, '%UID%', ISNULL(@UID, ''))

    -- ============================================================================
    -- BUILD HTML PROCEDURE VERSION (với dynamic SQL)
    -- ============================================================================
    DECLARE @html NVARCHAR(MAX) = N''
    DECLARE @loadUI NVARCHAR(MAX) = N''
    DECLARE @loadData NVARCHAR(MAX) = N''

    -- Build dynamic SQL để lấy từ database
    SELECT
        @html += ISNULL(html, ''),

        @loadUI += ISNULL('
        +(select loadUI from tblCommonControlType_Signed where UID = '''+UID+''')', ''),
        @loadData += ISNULL('
        +(select loadData from tblCommonControlType_Signed where UID = '''+UID+''')', '')
    FROM #temptable

    SET @nsqlHtml = REPLACE(@nsqlHtml, '%paradisehtml%', ISNULL(@html, ''))
    SET @nsqlHtml = REPLACE(@nsqlHtml, '%paradiseloadUI%', ''''+ISNULL(@loadUI, '') + ' +N''')
    SET @nsqlHtml = REPLACE(@nsqlHtml, '%paradiseloadData%', ''''+ISNULL(@loadData, '') + ' +N''')

    -- ============================================================================
    -- CẬP NHẬT LẠI VÀO DATABASE
    -- ============================================================================

    UPDATE t
    SET
        html = tt.html,
        loadUI = tt.loadUI,
        loadData = tt.loadData
    FROM tblCommonControlType_Signed t
    INNER JOIN #temptable tt ON tt.ID = t.ID
    WHERE t.TableName = @TableName;

    -- ============================================================================
    -- RETURN KẾT QUẢ
    -- @nsqlHtml: HTML với dynamic SQL (dùng cho sp_GenerateHTMLScript)
    -- ============================================================================
    SELECT @nsqlHtml AS htmlProc

    -- ============================================================================
    -- CLEANUP: Giải phóng tài nguyên tường minh
    -- ============================================================================
    IF OBJECT_ID('tempdb..#temptable') IS NOT NULL
        DROP TABLE #temptable;

    IF OBJECT_ID('tempdb..#GridColumnsGrouped') IS NOT NULL
        DROP TABLE #GridColumnsGrouped;

    END TRY
    BEGIN CATCH
        -- Log error message
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        DECLARE @ErrorSeverity INT = ERROR_SEVERITY();
        DECLARE @ErrorState INT = ERROR_STATE();

        -- Cleanup resources
        IF OBJECT_ID('tempdb..#temptable') IS NOT NULL
            DROP TABLE #temptable;
        IF OBJECT_ID('tempdb..#GridColumnsGrouped') IS NOT NULL
            DROP TABLE #GridColumnsGrouped;

        -- Re-throw error
        RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState);
    END CATCH
END
GO

EXEC sptblCommonControlType_Signed 'sp_Task_MyWork_html'
EXEC sp_GenerateHTMLScript_new 'sp_Task_MyWork_html'
