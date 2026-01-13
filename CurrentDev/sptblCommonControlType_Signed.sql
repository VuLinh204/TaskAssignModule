USE Paradise_Beta_Tai2
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
    EXEC sp_hpaControlText @TableName = @TableName
    EXEC sp_hpaControlTextArea @TableName = @TableName
    EXEC sp_hpaControlSelectBox @TableName = @TableName
    EXEC sp_hpaControlTagBox @TableName = @TableName
    EXEC sp_hpaControlSelectEmployee @TableName = @TableName

    UPDATE #temptable SET
        loadUI = REPLACE(loadUI, '$("#%UID%")', '$("#%UID%" + currentRecordID_%ColumnIDName2%)')
WHERE ColumnIDName2 IS NOT NULL
      AND LTRIM(RTRIM(ColumnIDName2)) <> ''
      AND loadUI LIKE '%$("#%UID%")%';

    -- Build HTML wrapper cho các control
    UPDATE #temptable SET
    html = N'<div id="%UID%"></div>'
    WHERE [Type] IN ('hpaControlDate', 'hpaControlTime', 'hpaControlPhone',
                     'hpaControlNumber', 'hpaControlMoney', 'hpaControlDatetime', 'hpaControlFile', 'hpaControlText', 'hpaControlTextArea', 'hpaControlSelectBox', 'hpaControlSelectEmployee')

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
                    console.log("[SmartLoad] %ColumnName%: Dữ liệu > 1000 dòng, sẽ load theo API pagination");
                }
            }

            // Nếu smart load, thì set flag để control sẽ tự động load qua API
            if (isSmartLoadNeeded) {
                window["UseAPILoad_%ColumnName%"] = true;
                console.log("[SmartLoad] %ColumnName%: Kích hoạt load API, tránh load toàn bộ dữ liệu lớn");
                return;
            }

            // Load bình thường (dữ liệu nhỏ <= 1000)
            Instance%ColumnName%._suppressValueChangeAction();
            Instance%ColumnName%.option("value", obj.%columnName%);
            Instance%ColumnName%._resumeValueChangeAction();
        '
    WHERE [Type] IN ('hpaControlDate', 'hpaControlPhone', 'hpaControlNumber',
                     'hpaControlMoney', 'hpaControlText', 'hpaControlTextArea',
                     'hpaControlSelectBox', 'hpaControlTagBox', 'hpaControlSelectEmployee')

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
            Instance%ColumnName%._suppressValueChangeAction();
            if (obj.%columnName%) {
                // Ép kiểu chuỗi SQL sang JS Date Object
                Instance%ColumnName%.option("value", new Date(obj.%columnName%));
            } else {
                Instance%ColumnName%.option("value", null);
            }
            Instance%ColumnName%._resumeValueChangeAction();
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
                    Instance%ColumnName%.option("dataSource", window["DataSource_%ColumnName%"]);
                    console.log(currentRecordID_%ColumnIDName%)
                    console.log(json)
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
                    console.log("[SmartLoad] %ColumnName%: Dữ liệu > 1000 dòng, sẽ load theo API pagination");
                }
            }

            // Nếu smart load, set flag và return
            if (isSmartLoadNeeded) {
                window["UseAPILoad_%ColumnName%"] = true;
                console.log("[SmartLoad] %ColumnName%: Kích hoạt load API, tránh load toàn bộ dữ liệu lớn");
                return;
            }

            // Load bình thường (dữ liệu nhỏ <= 1000)
            Instance%ColumnName%._suppressValueChangeAction();
            Instance%ColumnName%.option("value", obj.%columnName% ? new Date("1970/01/01 " + obj.%columnName%) : null);
            Instance%ColumnName%._resumeValueChangeAction();
        '
    WHERE [Type] = 'hpaControlTime'

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

    SET @GridColumnsCursor = CURSOR FOR
    SELECT DISTINCT GridColumnName
    FROM #temptable
    WHERE Layout = 'Grid_View' AND GridColumnName IS NOT NULL;

    OPEN @GridColumnsCursor;
    FETCH NEXT FROM @GridColumnsCursor INTO @GridColumnName;

    WHILE @@FETCH_STATUS = 0
    BEGIN
        PRINT '========== Building Grid: ' + @GridColumnName + ' =========='

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
            ISNULL(MAX(CASE WHEN col.ReadOnly = 0 THEN col.loadUI ELSE NULL END), '') AS loadUI_Edit,
            MAX(CASE WHEN col.ReadOnly = 0 THEN 1 ELSE 0 END) AS HasEditMode
        INTO #GridColumnsGrouped
        FROM #temptable col
        WHERE col.GridColumnName = @GridColumnName  -- FILTER theo Grid hiện tại
            AND col.Layout = 'Grid_View'
            AND col.Type IS NOT NULL
            AND col.loadUI IS NOT NULL
            AND LTRIM(RTRIM(col.loadUI)) <> ''
        GROUP BY
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
            ISNULL(
                N'cellTemplate: function(container, cellInfo) {
                    ' + REPLACE(REPLACE(REPLACE(loadUI_View, '%ColumnName%', DataFieldName), '"#%UID%"', 'container'), '%DataSourceSP%', DataSourceSP) + N'
                    if (cellInfo.value !== undefined && cellInfo.value !== null && Instance' + REPLACE(DataFieldName, '''', '''''') + N') {
                        Instance' + REPLACE(DataFieldName, '''', '''''') + N'.option("value", cellInfo.value);
                    }
                },'
            ,
                CASE
                WHEN ControlType = 'hpaControlDateTime'
                THEN N'cellTemplate: function(container, cellInfo){
                    const val = cellInfo.value;

                    if (val === undefined || val === null || val === "") {
                        $("<div>").addClass("dx-placeholder").text("--").appendTo(container);
                        return;
                    }

                    const d = new Date(val);
                    const txt = DevExpress.localization.formatDate(d, "dd/MM/yyyy HH:mm");
                    $("<div>").text(txt).appendTo(container);
                },'
                ELSE N'cellTemplate: function(container, cellInfo){
                    const val = cellInfo.value;

                    if (val === undefined || val === null || val === "") {
                        $("<div>").addClass("dx-placeholder").text("--").appendTo(container);
                        return;
                    }

                    const ds = window["DataSource_' + DataFieldName + '"];
                    if (ds && Array.isArray(ds)) {
                        const f = ds.find(x => x.id == val || x.ID == val);
                        if (f) {
              $("<div>").text(f.Text || f.Name || "").appendTo(container);
                            return;
                        }
                    }

                    $("<div>").text(cellInfo.displayValue ?? val).appendTo(container);
                },'
                END
            )
            +
            ISNULL(
                N'allowEditing: true,
                editCellTemplate: function(cellElement, cellInfo) {
                    if (cellInfo.key !== undefined && cellInfo.key !== null) {
                        currentRecordID_%ColumnIDName% = cellInfo.key;
                        console.log(currentRecordID_%ColumnIDName%)
                    } else if (cellInfo.data && cellInfo.data["%ColumnIDName%"] !== undefined) {
                        currentRecordID_%ColumnIDName% = cellInfo.data["%ColumnIDName%"];
                        console.log(currentRecordID_%ColumnIDName%)
                    }

                ' + REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(loadUI_Edit, '%ColumnName%', DataFieldName), '"#%UID%"', 'cellElement'), '%tableId%', CHECKSUM(tableId)), '%ColumnIDName%', ColumnIDName), '%ColumnIDName2%', ColumnIDName2) + N'
                    // Set initial value
                    if (cellInfo.value !== undefined && cellInfo.value !== null && Instance' + REPLACE(DataFieldName, '''', '''''') + N') {
                        Instance' + REPLACE(DataFieldName, '''', '''''') + N'.option("value", cellInfo.value);
                    }

                    // TRUYỀN cellInfo vào control để sync Grid sau khi save
                    if (Instance' + REPLACE(DataFieldName, '''', '''''') + N' && Instance' + REPLACE(DataFieldName, '''', '''''') + N'.setCellInfo) {
                        Instance' + REPLACE(DataFieldName, '''', '''''') + N'.setCellInfo(cellInfo);
                        console.log("[Grid Edit] Passed cellInfo to Instance' + REPLACE(DataFieldName, '''', '''''') + N'");
                    }
                },'
            ,
                N'allowEditing: false,'
            )
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
            loadUI = REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(
                N'
                    // Thêm responsive styles cho grid header
                    const style%ColumnName% = document.createElement("style");
                    style%ColumnName%.textContent = `
                        /* =============== RESPONSIVE POPUP STYLES =============== */
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

                        .dx-datagrid .dx-col-fixed {
                            z-index: 800 !important;
                        }

                        /* Group row - sát mép */
                        .dx-datagrid .dx-group-row {
                            padding: 0 !important;
                        }

                        .dx-datagrid .dx-group-row > td {
                            padding: 4px 6px !important;
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
                                white-space: normal !important;
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
                                min-height: 36px;
                                padding: 0 !important;
                            }

                            .dx-datagrid .dx-data-row > td {
                                padding: 4px 2px !important;
                                white-space: normal !important;
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

                            .dx-datagrid .dx-data-row > td {
                                padding: 2px 1px !important;
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

                    window.Instance%ColumnName% = $("#%ColumnName%").dxDataGrid({
                        dataSource: [],
                        keyExpr: "%PKColumnName%",
                        height: "100%",
                        remoteOperations: false,
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
                            mode: "virtual",
                            rowRenderingMode: "virtual",
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
                            mode: "multiple",
                            showCheckBoxesMode: "onClick",
                allowSelectAll: true
                        },

                        searchPanel: {
                            visible: true,
                            width: 240,
                            placeholder: "Tìm kiếm..."
                        },

                        headerFilter: { visible: true },

                        columnChooser: {
                            enabled: true,
                            mode: "select",
                            title: "Chọn cột hiển thị"
                        },

                        stateStoring: {
                            enabled: false,
                            type: "localStorage",
                            storageKey: "gridState_%Layout%"
                        },

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
                                const item = dataSource[e.fromIndex];
                                dataSource.splice(e.fromIndex, 1);
                                dataSource.splice(e.toIndex, 0, item);
                                e.component.option("dataSource", dataSource);
                            }
                        },

                        noDataText: "Không có dữ liệu",

                        columns: [' + @gridColumns + N'],

                        onCellClick: function(e) {
                            if (e.columnIndex === 0) {
                                const recordID = e.key || (e.data && e.data["%PKColumnName%"]);
                                console.log("[Grid Detail] Click mã - recordID:", recordID);
                                console.log("[Grid Detail] Mở detail bằng hàm openDetail%PKColumnName%");
                                if (recordID !== undefined && recordID !== null && recordID !== "") {
                                    if (typeof openDetail%PKColumnName% === "function") {
                                        console.log("[Grid Detail] Mở detail bằng hàm openDetail%PKColumnName%");
                                        openDetail%PKColumnName%(recordID);
                                    } else {
                                        uiManager.showAlert({ type: "info", message: "Chi tiết bản ghi ID: " + recordID });
                                    }
                                }
                            }
                        },

                        onRowPrepared: function(e) {
                            if (e.rowType === "data") {
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
                        },

                        onToolbarPreparing: function(e) {
                            let isReloading = false;
                            
                            e.toolbarOptions.items.unshift({
                                location: "after",
                                widget: "dxButton",
                                options: {
                                    icon: "refresh",
                                    hint: "Tải lại",
                                    onClick: function() {
                                        if (isReloading) {
                                            console.log("[Grid] Đang reload, vui lòng đợi...");
                                            return;
                                        }
                                        
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
                        }
                    }).dxDataGrid("instance");
                ',
                '%COLUMNS%', @gridColumns),
                '%PKColumnName%', @PKColumnNameGrid),
                '%Layout%', Layout),
                '%UID%', [UID]),
                '%ColumnName%', ColumnName),
            html = N'<div id="%ColumnName%" style="height: 100%;"></div>'
        FROM #temptable t1
        WHERE t1.Layout = 'Grid_View'
            AND t1.ColumnName = @GridColumnName
            AND t1.Type IS NULL;

        FETCH NEXT FROM @GridColumnsCursor INTO @GridColumnName;
    END;

    CLOSE @GridColumnsCursor;
    DEALLOCATE @GridColumnsCursor;
END
-- Xóa các dòng build control cho grid sau khi đã nối chuỗi xong
DELETE FROM #temptable WHERE Layout = 'Grid_View' AND GridColumnName IS NOT NULL AND Type IS NOT NULL;

    -- ============================================================================
    -- THAY THẾ CÁC PLACEHOLDER
    -- ============================================================================
    UPDATE t
        SET loadUI = REPLACE(loadUI, '%tableId%', CAST(CHECKSUM(o.name) AS VARCHAR(64)))
        FROM #temptable t
        INNER JOIN sys.objects o ON o.name = t.TableEditor AND o.type = 'U'
    UPDATE #temptable SET loadUI = REPLACE(loadUI, '%tableId%', ISNULL(@object_Id, ''))
    UPDATE #temptable SET loadUI = REPLACE(loadUI, '%UID%', ISNULL([UID], ''))
    UPDATE #temptable SET loadUI = REPLACE(loadUI, '%columnName%', ISNULL(ColumnName, ''))
    UPDATE #temptable SET loadUI = REPLACE(loadUI, '%DatasourceSP%', ISNULL(DatasourceSP, ''))
    UPDATE #temptable SET loadUI = REPLACE(loadUI, '%columnId%', ISNULL(columnId, ''))
    UPDATE #temptable SET loadUI = REPLACE(loadUI, '%ColumnIDName%', ISNULL(ColumnIDName, ''))
    UPDATE #temptable SET loadUI = REPLACE(loadUI, '%ColumnIDName2%', ISNULL(ColumnIDName2, ''))
    UPDATE #temptable SET loadUI = REPLACE(loadUI, '%Layout%', ISNULL(Layout, ''))
    UPDATE #temptable SET loadUI = REPLACE(loadUI, '%IsAlert%', ISNULL(IsAlert, 0))

    UPDATE #temptable SET loadData = REPLACE(loadData, '%UID%', ISNULL([UID], ''))
    UPDATE #temptable SET loadData = REPLACE(loadData, '%columnName%', ISNULL(ColumnName, ''))
    UPDATE #temptable SET loadData = REPLACE(loadData, '%DatasourceSP%', ISNULL(DatasourceSP, ''))
    UPDATE #temptable SET loadData = REPLACE(loadData, '%columnId%', ISNULL(columnId, ''))
    UPDATE #temptable SET loadData = REPLACE(loadData, '%ColumnIDName%', ISNULL(ColumnIDName, ''))
    UPDATE #temptable SET loadData = REPLACE(loadData, '%ColumnIDName2%', ISNULL(ColumnIDName2, ''))
    UPDATE #temptable SET loadData = REPLACE(loadData, '%Layout%', ISNULL(Layout, ''))

    UPDATE #temptable SET html = REPLACE(html, '%UID%', ISNULL([UID], ''))
    UPDATE #temptable SET html = REPLACE(html, '%Layout%', ISNULL(Layout, ''))
    UPDATE #temptable SET html = REPLACE(html, '%ColumnName%', ISNULL(ColumnName, ''))

    -- ============================================================================
    -- XUẤT KẾT QUẢ CUỐI CÙNG
    -- ============================================================================
    DECLARE @SPLoadData VARCHAR(100), @ColumnIDName VARCHAR(100), @UID VARCHAR(100), @ColumnName VARCHAR(100);
    DECLARE @ColumnIDNames TABLE (ColumnIDName VARCHAR(200));
    DECLARE @ColumnIDNames2 TABLE (ColumnIDName2 VARCHAR(200));

    -- Lấy thông tin cơ bản
    SELECT TOP 1 @SPLoadData = SPLoadData FROM #temptable WHERE TableName = @TableName
    SELECT TOP 1 @UID = [UID] FROM #temptable WHERE TableName = @TableName
    SELECT TOP 1 @ColumnName = [ColumnName] FROM #temptable WHERE TableName = @TableName

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

    SELECT @jsCurrentRecordID += ' let currentRecordID_' + ColumnIDName + ';'
    FROM @ColumnIDNames
    WHERE ColumnIDName IS NOT NULL;

    SELECT @jsCurrentRecordID2 += ' let currentRecordID_' + ColumnIDName2 + ';'
    FROM @ColumnIDNames2
    WHERE ColumnIDName2 IS NOT NULL;

    -- Build JavaScript code để handle record
    DECLARE @jsHandleRecord NVARCHAR(MAX) = N'';
    DECLARE @jsHandleRecord2 NVARCHAR(MAX) = N'';

    SELECT @jsHandleRecord += ' currentRecordID_' + ColumnIDName + ' = obj.' + ColumnIDName + ' || currentRecordID_' + ColumnIDName + ';'
    FROM @ColumnIDNames;

    SELECT @jsHandleRecord2 += ' currentRecordID_' + ColumnIDName2 + ' = obj.' + ColumnIDName2 + ' || currentRecordID_' + ColumnIDName2 + ';'
    FROM @ColumnIDNames2;

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
            %paradiseloadUI%

            %JS_CURRENT_ID%

            function ReloadData() {
                AjaxHPAParadise({
                    data: {
                        name: "%SPLoadData%",
                        param: []
                    },
                    success: function (res) {
                        const json = typeof res === "string" ? JSON.parse(res) : res;

                        // Chuẩn hóa: results LUÔN là array
                        const results = Array.isArray(json?.data?.[0])
                            ? json.data[0]
                            : (json?.data?.[0] ? [json.data[0]] : []);

                        const obj = results[0] || null;

                        %JS_HANDLE_RECORD%

                        DataSource = results;

                        if (%UseLayout% === 1) {
                            Instance%ColumnName%.option("dataSource", results);
                        } else {
                            %paradiseloadData%
                        }
                    }
                })
            }
            %TableName%.ReloadData = ReloadData
            ReloadData()
        })();
    </script>'

    -- Thay thế placeholders
    SET @nsqlHtml = REPLACE(@nsqlHtml, '%TableName%', ISNULL(@TableName, ''))
    SET @nsqlHtml = REPLACE(@nsqlHtml, '%ColumnName%', ISNULL(@ColumnName, ''))
    SET @nsqlHtml = REPLACE(@nsqlHtml, '%SPLoadData%', ISNULL(@SPLoadData, ''))
    SET @nsqlHtml = REPLACE(@nsqlHtml, '%UseLayout%', CAST(@UseLayout AS VARCHAR(1)))
    SET @nsqlHtml = REPLACE(@nsqlHtml, '%JS_CURRENT_ID%', @jsCurrentRecordID);
    SET @nsqlHtml = REPLACE(@nsqlHtml, '%JS_HANDLE_RECORD%', @jsHandleRecord);
    SET @nsqlHtml = REPLACE(@nsqlHtml, '%UID%', ISNULL(@UID, ''))

    DECLARE @nsql NVARCHAR(MAX) = @nsqlHtml

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

    SET @nsql = REPLACE(@nsql, '%paradisehtml%', ISNULL(@html, ''))
    SET @nsql = REPLACE(@nsql, '%paradiseloadUI%', ISNULL(@loadUI, ''))
    SET @nsql = REPLACE(@nsql, '%paradiseloadData%', ISNULL(@loadData, ''))

    -- ============================================================================
    -- CẬP NHẬT LẠI VÀO DATABASE
    -- ============================================================================

    UPDATE t
    SET html = tt.html,
        loadUI = tt.loadUI,
        loadData = tt.loadData
    FROM tblCommonControlType_Signed t
    INNER JOIN #temptable tt ON tt.ID = t.ID
    WHERE tt.TableName = @TableName

    -- ============================================================================
    -- RETURN KẾT QUẢ
    -- @nsql: HTML trực tiếp (dùng cho render)
    -- @nsqlHtml: HTML với dynamic SQL (dùng cho sp_GenerateHTMLScript)
    -- ============================================================================
    SELECT @nsql AS htmlProc, @nsqlHtml AS Html
END
GO

EXEC sptblCommonControlType_Signed 'sp_Task_MyWork_html'
EXEC sp_GenerateHTMLScript 'sp_Task_MyWork_html'
