USE Paradise_Dev
GO
if object_id('[dbo].[sp_CRM_ContractHistory_html]') is null
	EXEC ('CREATE PROCEDURE [dbo].[sp_CRM_ContractHistory_html] as select 1')
GO
ALTER PROCEDURE [dbo].[sp_CRM_ContractHistory_html]
as
	DECLARE @html nvarchar(max) = '', @Empty nvarchar(max) =''

	select @html = N'



    <div id="sp_CRM_ContractHistory_html">
        <div id="gridContractHistory" style="height: 100%;"></div><div id="P53E5F56DC72B4F08904E976C0EACEF0B"></div><div id="PBE8BE54C38914BAEA0646C9B6A1DD6A2"></div><div id="P6F1F5081B8A146988DA1C280BACFF0FA"></div><div id="P6A9B5A5B2C704EF5A0C9CE949993E245"></div>
    </div>
    <script>
        (() => {
            let currentRecordID_Company_ID
            let DataSource = []

            // Load DataSource: sp_CRM_getContractType
            if ("sp_CRM_getContractType" && "sp_CRM_getContractType".trim() !== "") {
                loadDataSourceCommon("ContractID", "sp_CRM_getContractType", function(data) {
                    // Data được shared qua callback
                });
            }

            // Load DataSource: sp_getCompanyInfo
            if ("sp_getCompanyInfo" && "sp_getCompanyInfo".trim() !== "") {
                loadDataSourceCommon("Company_ID", "sp_getCompanyInfo", function(data) {
                    // Data được shared qua callback
                });
            }

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

            AjaxHPAParadise({
                data: {
                    name: dataSourceSP,
                    param: ["LoginID", LoginID, "LanguageID", LanguageID]
                },
                success: function(res) {
                    const json = typeof res === "string" ? JSON.parse(res) : res;
                    window[dataSourceKey] = (json.data && json.data[0]) || [];
                    window[loadedKey] = true;

                    // Gọi callback nếu có
                    if (typeof onSuccessCallback === "function") {
                        onSuccessCallback(window[dataSourceKey]);
                    }

                    // Tự động cập nhật control nếu có method setDataSource hoặc option
                    // Thử nhiều format tên instance để tương thích
                    const instanceVariants = [
                        "Instance" + columnName.charAt(0).toUpperCase() + columnName.slice(1) + "P1D531D804E6F493BAF505C302A7A5760",
                        "Instance" + columnName + "P1D531D804E6F493BAF505C302A7A5760",
                        "instance" + columnName.charAt(0).toUpperCase() + columnName.slice(1) + "P1D531D804E6F493BAF505C302A7A5760"
                    ];

                    for (let i = 0; i < instanceVariants.length; i++) {
                        const instanceKey = instanceVariants[i];
                        if (window[instanceKey]) {
                            const instanceObj = window[instanceKey];

                            // Kiểm tra nếu đây là dxDataGrid
                            if (typeof instanceObj.dxDataGrid === "function" || instanceObj.option && instanceObj.option("dataSource") !== undefined) {
                                try {
                                    // Nếu là Grid, apply dynamic config
                                    const gridConfigFn = window["getGridConfig_" + columnName.charAt(0).toUpperCase() + columnName.slice(1)];
                                    if (typeof gridConfigFn === "function") {
                                        const gridConfig = gridConfigFn(window[dataSourceKey]);
                                        instanceObj.option("remoteOperations", gridConfig.remoteOperations);
                                        instanceObj.option("paging.pageSize", gridConfig.pageSize);
                                        instanceObj.option("pager.allowedPageSizes", gridConfig.allowedPageSizes);
                                    }

                                    instanceObj.option("dataSource", window[dataSourceKey]);
                                    break;
                                } catch(e) {
                                    console.warn("[LoadDataSourceCommon] Grid config error:", e);
                                    // Fallback: just set data source
                                    instanceObj.option("dataSource", window[dataSourceKey]);
                                    break;
                                }
                            } else if (typeof instanceObj.setDataSource === "function") {
                                instanceObj.setDataSource(window[dataSourceKey]);
                                break;
                            } else if (typeof instanceObj.option === "function") {
                                try {
                                    instanceObj.option("dataSource", window[dataSourceKey]);
                                    break;
                                } catch(e) {
                                    // Continue to next variant
                                }
                            }
                        }
                    }
                },
                error: function(err) {
                    console.error("[loadDataSourceCommon] Failed to load datasource for", columnName, ":", err);
                    window[loadedKey] = false;
                    if (typeof onSuccessCallback === "function") {
                        onSuccessCallback([]);
                    }
                }
            });
        }


                        window.InstancegridContractHistoryP1D531D804E6F493BAF505C302A7A5760 = null;
                        // Thêm responsive styles cho grid header
                        const stylegridContractHistory = document.createElement("style");
                        stylegridContractHistory.textContent = `
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
                        document.head.appendChild(stylegridContractHistory);

                        // =============== GRID CONFIG DYNAMIC BASED ON DATA SIZE ===============
                        // Hàm tính remoteOperations dựa trên số lượng dòng
                        window.getGridConfig_gridContractHistory = function(dataArray) {
                            const dataSize = Array.isArray(dataArray) ? dataArray.length : 0;
                            const isLargeDataset = dataSize > 1000;

                            return {
                                remoteOperations: isLargeDataset,
                                pageSize: isLargeDataset ? 25 : 10,
                                allowedPageSizes: isLargeDataset ? [10, 25, 50] : [5, 10, 50, 100]
                            };
                        };

                        InstancegridContractHistoryP1D531D804E6F493BAF505C302A7A5760 = $("#gridContractHistory").dxDataGrid({
                            dataSource: [],
                            keyExpr: "ContracID",
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
                                mode: "single",
                                showCheckBoxesMode: "none",
                                allowSelectAll: false
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
                                    const item = dataSource[e.fromIndex];
                                    dataSource.splice(e.fromIndex, 1);
                                    dataSource.splice(e.toIndex, 0, item);
                                    e.component.option("dataSource", dataSource);
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

            {
                dataField: "Company_ID",
                caption: "Khách hàng",
                width: 200,
                allowSorting: true,
                allowFiltering: true,
                cellTemplate: function(cellElement, cellInfo){
                            const val = cellInfo.value;

                            if (val === undefined || val === null || val === "") {
                                $("<div>").addClass("dx-placeholder").text("--").appendTo(cellElement);
                                return;
                            }

                            const ds = window["DataSource_Company_ID"];
                            if (ds && Array.isArray(ds)) {
                                const f = ds.find(x => x.id == val || x.ID == val);
                                if (f) {
                                    $("<div>").text(f.Text || f.Name || "").appendTo(cellElement);
                                    return;
                                }
                            }

                            $("<div>").text(cellInfo.displayValue ?? val).appendTo(cellElement);
                        },
                        allowEditing: true,
                        editCellTemplate: function(cellElement, cellInfo) {
                            // Cập nhật record context ID cho row hiện tại
                            let rowID = null;
                            if (cellInfo.key !== undefined && cellInfo.key !== null) {
                                rowID = cellInfo.key;
                            } else if (cellInfo.data && cellInfo.data["ContracID"] !== undefined) {
                                rowID = cellInfo.data["ContracID"];
                            }

                            if (rowID !== null) {
                                currentRecordID_ContracID = rowID;
                            }

                            if ("Company_ID" && "Company_ID".trim() !== "" && cellInfo.data && cellInfo.data["Company_ID"] !== undefined) {
                                currentRecordID_Company_ID = cellInfo.data["Company_ID"];
                            }


        window["DataSource_Company_ID"] = window["DataSource_Company_ID"] || [];

        let Company_IDP1D531D804E6F493BAF505C302A7A5760DataSourceSP = "";
        let Company_IDP1D531D804E6F493BAF505C302A7A5760IsLoading = false;
        let Company_IDP1D531D804E6F493BAF505C302A7A5760IsDataLoaded = false;
        let _autoSaveCompany_IDP1D531D804E6F493BAF505C302A7A5760 = false;
        let _readOnlyCompany_IDP1D531D804E6F493BAF505C302A7A5760 = false;
        let Company_IDP1D531D804E6F493BAF505C302A7A5760TableAddNew = "";
        let Company_IDP1D531D804E6F493BAF505C302A7A5760ColumnAddNew = "";
        let Company_IDP1D531D804E6F493BAF505C302A7A5760CurrentSearch = "";
        let InstanceCompany_IDP1D531D804E6F493BAF505C302A7A5760 = null;

        function getDataSourceConfigCompany_IDP1D531D804E6F493BAF505C302A7A5760(data) {
            return new DevExpress.data.DataSource({
                store: new DevExpress.data.CustomStore({
                    key: "ID",
                    load: function(loadOptions) {
                        // LẤY searchValue từ INSTANCE (option "text" hoặc "searchValue")
                        const searchValue = (InstanceCompany_IDP1D531D804E6F493BAF505C302A7A5760 && InstanceCompany_IDP1D531D804E6F493BAF505C302A7A5760.option)
                            ? (InstanceCompany_IDP1D531D804E6F493BAF505C302A7A5760.option("text") || InstanceCompany_IDP1D531D804E6F493BAF505C302A7A5760.option("searchValue") || "")
                            : (loadOptions.searchValue || "");

                        let result = data || [];

                        if (searchValue && searchValue.trim()) {
                            result = result.filter(item => customSearchCompany_ID(item, searchValue));
                        }

                        return Promise.resolve(result);
                    },
                    byKey: function(key) {
                        return Promise.resolve((data || []).find(i => i.ID === key));
                    }
   })
            });
        }

        async function processAddNewCompany_ID(newValue) {
            if (!newValue || !newValue.trim()) return;

            InstanceCompany_IDP1D531D804E6F493BAF505C302A7A5760.option("disabled", true);

            const dataJSON = JSON.stringify([Company_IDP1D531D804E6F493BAF505C302A7A5760TableAddNew, [Company_IDP1D531D804E6F493BAF505C302A7A5760ColumnAddNew], [newValue.trim()]]);
            const idValsJSON = JSON.stringify([[], []]);

            try {
                const json = await saveFunction(dataJSON, idValsJSON);
                const dtError = json.data[json.data.length - 1] || [];
                if (dtError.length > 0 && dtError[0].Status === "ERROR") {
                    if ("0" === "1") {
                        uiManager.showAlert({ type: "error", message: dtError[0]?.Message || "Lỗi thêm mới" });
                    }
                } else {
                    if ("0" === "1") {
                        uiManager.showAlert({ type: "success", message: "Đã thêm mới: " + newValue });
                    }

                    if (Company_IDP1D531D804E6F493BAF505C302A7A5760DataSourceSP && Company_IDP1D531D804E6F493BAF505C302A7A5760DataSourceSP !== "") {
                     loadDataSourceCommon("Company_ID", Company_IDP1D531D804E6F493BAF505C302A7A5760DataSourceSP, function(data) {
                            InstanceCompany_IDP1D531D804E6F493BAF505C302A7A5760.option("dataSource", getDataSourceConfigCompany_IDP1D531D804E6F493BAF505C302A7A5760(data));
                            const newItem = data.find(x => x.Name === newValue.trim());
                            if (newItem) {
                                InstanceCompany_IDP1D531D804E6F493BAF505C302A7A5760.option("value", newItem.ID);
                                InstanceCompany_IDP1D531D804E6F493BAF505C302A7A5760.option("searchValue", "");
                                Company_IDP1D531D804E6F493BAF505C302A7A5760CurrentSearch = "";
                            }
                        });
                    }
                }
            } catch (e) {
                console.error(e);
                if ("0" === "1") uiManager.showAlert({ type: "error", message: "Có lỗi khi thêm mới" });
            } finally {
                InstanceCompany_IDP1D531D804E6F493BAF505C302A7A5760.option("disabled", false);
                InstanceCompany_IDP1D531D804E6F493BAF505C302A7A5760.close();
            }
        }

        function highlightTextCompany_ID(text, search) {
            if (!search || !text) return text;
            const regex = new RegExp("(" + search.replace(/[.*+?^${}()|[\]\\]/g, "\\$&") + ")", "gi");
            return text.replace(regex, "<mark class=\"bg-warning fw-bold px-1 rounded\">$1</mark>");
        }

        function customSearchCompany_ID(item, searchValue) {
            if (!searchValue) return true;

            // Chuẩn hóa searchValue - loại bỏ dấu và chuyển thành lowercase
            let searchNormalized = searchValue.toLowerCase();

            if (typeof RemoveToneMarks_Js === "function") {
                searchNormalized = RemoveToneMarks_Js(searchValue).toLowerCase();
            }

            const fields = ["ID", "Name", "Code", "Description"];

            for (let i = 0; i < fields.length; i++) {
                const fieldValue = item[fields[i]];

                if (fieldValue) {
                    // Chuẩn hóa fieldValue - loại bỏ dấu và chuyển thành lowercase
                    let fieldNormalized = String(fieldValue).toLowerCase();

                    if (typeof RemoveToneMarks_Js === "function") {
                        fieldNormalized = RemoveToneMarks_Js(String(fieldValue)).toLowerCase();
                    }

                    const matchIndex = fieldNormalized.indexOf(searchNormalized);

                    // So sánh sau khi đã chuẩn hóa
                    if (matchIndex !== -1) {
                        return true;
                    }
                }
            }

            return false;
        }

        InstanceCompany_IDP1D531D804E6F493BAF505C302A7A5760 = $(cellElement + currentRecordID_Company_ID).dxSelectBox({
            readOnly: _readOnlyCompany_IDP1D531D804E6F493BAF505C302A7A5760,
            dataSource: getDataSourceConfigCompany_IDP1D531D804E6F493BAF505C302A7A5760(window["DataSource_Company_ID"]),
            valueExpr: "ID",
            displayExpr: "Name",
            onOptionChanged: function(e) {},
            onContentReady: function(e) {},
            placeholder: "Tìm kiếm hoặc chọn...",
            searchEnabled: true,
            searchTimeout: 300,
            minSearchLength: 0,
            showDataBeforeSearch: true,
            showClearButton: false,
            stylingMode: "outlined",
            dropDownOptions: {
                showTitle: false,
                closeOnOutsideClick: true,
                height: "auto",
                maxHeight: 400,
                minWidth: 320,
                onShowing: function(e) {
                    if (!Company_IDP1D531D804E6F493BAF505C302A7A5760IsDataLoaded && Company_IDP1D531D804E6F493BAF505C302A7A5760DataSourceSP && Company_IDP1D531D804E6F493BAF505C302A7A5760DataSourceSP !== "") {
                        loadDataSourceCommon("Company_ID", Company_IDP1D531D804E6F493BAF505C302A7A5760DataSourceSP, function(data) {
                            Company_IDP1D531D804E6F493BAF505C302A7A5760IsDataLoaded = true;
                            InstanceCompany_IDP1D531D804E6F493BAF505C302A7A5760.option("dataSource", getDataSourceConfigCompany_IDP1D531D804E6F493BAF505C302A7A5760(data));
                        });
                    }
                }
            },
            itemTemplate: function(data, index) {
                if (data.IsAddNew) {
                    const $item = $("<div>")
                        .addClass("d-flex align-items-center gap-2 px-3 py-2 text-primary fw-bold")
                        .css({ cursor: "pointer", borderTop: "1px dashed #dee2e6" });

                    $("<i>").addClass("bi bi-plus-circle-fill fs-5").appendTo($item);
                    $("<span>").text("Thêm mới: \"" + data.Name + "\"").appendTo($item);

                    $item.on("dxclick", async function(e) {
                        e.stopPropagation();
                        if (InstanceCompany_IDP1D531D804E6F493BAF505C302A7A5760 && InstanceCompany_IDP1D531D804E6F493BAF505C302A7A5760.blur) InstanceCompany_IDP1D531D804E6F493BAF505C302A7A5760.blur();
                        await processAddNewCompany_ID(data.Name);
                    });

                    return $item;
                }

                const $item = $("<div>")
                    .addClass("d-flex align-items-center gap-3 px-3 py-2 my-1 mx-2 rounded")
                    .css({
                        cursor: "pointer",
                        transition: "all 0.2s ease",
                        border: "1px solid transparent"
                    });

                $item.on("mouseenter", function() {
                    $(this).css({
                        transform: "translateX(4px)",
                        borderColor: "#90caf9",
                        boxShadow: "0 2px 8px rgba(0,0,0,0.08)"
                    });
                }).on("mouseleave", function() {
                    $(this).css({
                        background: "",
                        transform: "",
                        borderColor: "transparent",
                        boxShadow: ""
                    });
                });

                const $content = $("<div>").addClass("flex-fill").css("minWidth", "0");
                const searchValue = InstanceCompany_IDP1D531D804E6F493BAF505C302A7A5760.option("searchValue") || "";

                const displayName = (data.ID !== undefined ? data.ID + " - " : "") + (data.Name || "");
                $("<div>")
                    .addClass("fw-semibold")
                    .css({
                        fontSize: "14px",
                        lineHeight: "1.4",
                        overflow: "hidden",
                        textOverflow: "ellipsis",
                        whiteSpace: "nowrap"
                    })
                    .html(highlightTextCompany_ID(displayName, searchValue))
                    .appendTo($content);

                if (data.Description || data.Code) {
                    $("<div>")
                        .addClass("small text-muted")
                        .css({
                            fontSize: "12px",
                            overflow: "hidden",
                            textOverflow: "ellipsis",
                            whiteSpace: "nowrap"
                        })
                        .text(data.Code || data.Description)
                        .appendTo($content);
                }

                $content.appendTo($item);

                if (data.Status) {
                    const badgeClass = data.Status === "Active" ? "bg-success" : "bg-secondary";
                    $("<span>")
                        .addClass("badge " + badgeClass + " text-uppercase")
                        .css({
                            fontSize: "9px",
                            padding: "4px 8px",
                            letterSpacing: "0.5px",
                            flexShrink: "0"
                        })
                        .text(data.Status)
                        .appendTo($item);
                }

                setTimeout(() => {
                    $item.css({
                        opacity: "0",
                        transform: "translateX(-10px)"
                    }).animate({
                        opacity: 1
                    }, {
                        duration: 300,
                        step: function(now) {
                            $(this).css("transform", "translateX(" + (-10 + (now * 10)) + "px)");
                        },
                        delay: index * 30
                    });
                }, 10);

                return $item;
            },
            onOpened: function(e) {
                // Style dropdown
                $(e.component._popup.content()).parent()
                    .addClass("shadow-lg border rounded hpa-responsive")
                    .css({
                        borderRadius: "12px",
                        padding: "8px 0",
                        borderColor: "#dee2e6"
                    });
            },
            onFocusIn: function(e) {
                InstanceCompany_IDP1D531D804E6F493BAF505C302A7A5760.option("showClearButton", true);
            },
            onFocusOut: function(e) {
                InstanceCompany_IDP1D531D804E6F493BAF505C302A7A5760.option("showClearButton", false);
            },
            onKeyDown: function(e) {
                if (e.key === "Enter" || e.key === "Tab") {
                    InstanceCompany_IDP1D531D804E6F493BAF505C302A7A5760.option("showClearButton", false);
                }
            },
            onValueChanged: async function(e) {
                if (!e.event) return;

                // Feature: Check Instance AutoSave Flag
                if (_autoSaveCompany_IDP1D531D804E6F493BAF505C302A7A5760) {
                     // Nếu người dùng tìm kiếm rỗng và kết quả trả về là 0/empty/null (Copy from AutoSave mode)
                    if (e.value === "" || e.value == null || e.value === 0 || e.value === "0") {
                        InstanceCompany_IDP1D531D804E6F493BAF505C302A7A5760.option("value", _initialCompany_IDP1D531D804E6F493BAF505C302A7A5760);
                        return;
                    }

                    $(cellElement + currentRecordID_Company_ID).find(".dx-texteditor-input").blur();
                    if (InstanceCompany_IDP1D531D804E6F493BAF505C302A7A5760 && InstanceCompany_IDP1D531D804E6F493BAF505C302A7A5760.blur) InstanceCompany_IDP1D531D804E6F493BAF505C302A7A5760.blur();

                    const $el = $(e.element);
                    $el.css({
                        transform: "scale(1.02)",
                        boxShadow: "0 0 0 3px rgba(28, 151, 94, 0.2)",
                        transition: "all 0.2s ease"
                    });
                    setTimeout(() => {
                        $el.css({ transform: "", boxShadow: "" });
                    }, 300);

                    if (typeof window["onSelectBoxChanged_Company_ID"] === "function") {
                        window["onSelectBoxChanged_Company_ID"](e.value, InstanceCompany_IDP1D531D804E6F493BAF505C302A7A5760, e);
                    }

                    const val = e.value;
                    const dataJSON = JSON.stringify(["1758526346", ["Company_ID"], [val || ""]]);

                    // Context-aware record IDs
                    let id1 = currentRecordID_ContracID;
                    if (typeof cellInfo !== "undefined" && cellInfo && cellInfo.data) {
                        id1 = cellInfo.data["ContracID"] || id1;
                    }
                    let currentRecordIDValue = [id1];
                    let currentRecordID = ["ContracID"];

                    if ("Company_ID" && "Company_ID".trim() !== "") {
                        let id2 = currentRecordID_Company_ID;
                        if (typeof cellInfo !== "undefined" && cellInfo && cellInfo.data) {
                            id2 = cellInfo.data["Company_ID"] || id2;
                        }
                        currentRecordIDValue.push(id2);
                        currentRecordID.push("Company_ID");
                    }
                    const idValsJSON = JSON.stringify([currentRecordIDValue, currentRecordID]);

                    try {
                        const json = await saveFunction(dataJSON, idValsJSON);
                        const dtError = json.data[json.data.length - 1] || [];
                        if (dtError.length > 0 && dtError[0].Status === "ERROR") {
                            if ("0" === "1") {
                                uiManager.showAlert({ type: "error", message: dtError[0]?.Message || "Lưu thất bại" });
                            }
                            InstanceCompany_IDP1D531D804E6F493BAF505C302A7A5760.option("value", _initialCompany_IDP1D531D804E6F493BAF505C302A7A5760);
                        } else {
                            if (typeof cellInfo !== "undefined" && cellInfo && cellInfo.component) {
                                try {
                                    const grid = cellInfo.component;
                                    grid.cellValue(cellInfo.rowIndex, "Company_ID", val);
                                    grid.repaint();
                                } catch (syncErr) {
                                    console.warn("[Grid Sync] SelectBox Company_IDP1D531D804E6F493BAF505C302A7A5760: Không thể sync grid:", syncErr);
                                }
                            }
                            if ("0" === "1") {
                                uiManager.showAlert({ type: "success", message: "Lưu thành công" });
                            }
                            _initialCompany_IDP1D531D804E6F493BAF505C302A7A5760 = val;
                        }
                    } catch (err) {
                        if ("0" === "1") {
                            uiManager.showAlert({ type: "error", message: "Có lỗi xảy ra khi lưu" });
                        }
                        InstanceCompany_IDP1D531D804E6F493BAF505C302A7A5760.option("value", _initialCompany_IDP1D531D804E6F493BAF505C302A7A5760);
                        console.error("SelectBox Save Error:", err);
                    }
                    return;
                }

                // Normal Manual Mode Logic (No API)
                const $el = $(e.element);
                $el.css({
                    transform: "scale(1.02)",
                    boxShadow: "0 0 0 3px rgba(28, 151, 94, 0.2)",
                    transition: "all 0.2s ease"
                });
                setTimeout(() => {
                    $el.css({ transform: "", boxShadow: "" });
                }, 300);

                if (typeof window["onSelectBoxChanged_Company_ID"] === "function") {
                    window["onSelectBoxChanged_Company_ID"](e.value, InstanceCompany_IDP1D531D804E6F493BAF505C302A7A5760, e);
                }

                if (typeof cellInfo !== "undefined" && cellInfo && cellInfo.component) {
                    try {
                        const grid = cellInfo.component;
                        grid.cellValue(cellInfo.rowIndex, "Company_ID", e.value);
                        grid.repaint();
                    } catch (syncErr) {
                        console.warn("[Grid Sync] Không thể sync grid:", syncErr);
                    }
                }
            }
        }).dxSelectBox("instance");

        let _initialCompany_IDP1D531D804E6F493BAF505C302A7A5760 = InstanceCompany_IDP1D531D804E6F493BAF505C302A7A5760.option("value");

                            // Set initial value
                            if (cellInfo.value !== undefined && cellInfo.value !== null && InstanceCompany_IDP1D531D804E6F493BAF505C302A7A5760) {
                                InstanceCompany_IDP1D531D804E6F493BAF505C302A7A5760.option("value", cellInfo.value);
                            }
                        },
            },

            {
                dataField: "ContractID",
                caption: "Loại hợp đồng",
                width: 200,
                allowSorting: true,
                allowFiltering: true,
                cellTemplate: function(cellElement, cellInfo){
                            const val = cellInfo.value;

                            if (val === undefined || val === null || val === "") {
                                $("<div>").addClass("dx-placeholder").text("--").appendTo(cellElement);
                                return;
                            }

                            const ds = window["DataSource_ContractID"];
                            if (ds && Array.isArray(ds)) {
                                const f = ds.find(x => x.id == val || x.ID == val);
                                if (f) {
                                    $("<div>").text(f.Text || f.Name || "").appendTo(cellElement);
                                    return;
                                }
                            }

                            $("<div>").text(cellInfo.displayValue ?? val).appendTo(cellElement);
                        },
                        allowEditing: true,
                        editCellTemplate: function(cellElement, cellInfo) {
                            // Cập nhật record context ID cho row hiện tại
                            let rowID = null;
                            if (cellInfo.key !== undefined && cellInfo.key !== null) {
                                rowID = cellInfo.key;
                            } else if (cellInfo.data && cellInfo.data["ContracID"] !== undefined) {
                                rowID = cellInfo.data["ContracID"];
                            }

                            if (rowID !== null) {
                                currentRecordID_ContracID = rowID;
                            }

                            if ("Company_ID" && "Company_ID".trim() !== "" && cellInfo.data && cellInfo.data["Company_ID"] !== undefined) {
                                currentRecordID_Company_ID = cellInfo.data["Company_ID"];
                            }


        window["DataSource_ContractID"] = window["DataSource_ContractID"] || [];

        let ContractIDP1D531D804E6F493BAF505C302A7A5760DataSourceSP = "";
        let ContractIDP1D531D804E6F493BAF505C302A7A5760IsLoading = false;
        let ContractIDP1D531D804E6F493BAF505C302A7A5760IsDataLoaded = false;
        let _autoSaveContractIDP1D531D804E6F493BAF505C302A7A5760 = false;
        let _readOnlyContractIDP1D531D804E6F493BAF505C302A7A5760 = false;
        let ContractIDP1D531D804E6F493BAF505C302A7A5760TableAddNew = "";
        let ContractIDP1D531D804E6F493BAF505C302A7A5760ColumnAddNew = "";
        let ContractIDP1D531D804E6F493BAF505C302A7A5760CurrentSearch = "";
        let InstanceContractIDP1D531D804E6F493BAF505C302A7A5760 = null;

        function getDataSourceConfigContractIDP1D531D804E6F493BAF505C302A7A5760(data) {
            return new DevExpress.data.DataSource({
                store: new DevExpress.data.CustomStore({
                    key: "ID",
                    load: function(loadOptions) {
                        // LẤY searchValue từ INSTANCE (option "text" hoặc "searchValue")
                        const searchValue = (InstanceContractIDP1D531D804E6F493BAF505C302A7A5760 && InstanceContractIDP1D531D804E6F493BAF505C302A7A5760.option)
                            ? (InstanceContractIDP1D531D804E6F493BAF505C302A7A5760.option("text") || InstanceContractIDP1D531D804E6F493BAF505C302A7A5760.option("searchValue") || "")
                            : (loadOptions.searchValue || "");

                        let result = data || [];

                        if (searchValue && searchValue.trim()) {
                            result = result.filter(item => customSearchContractID(item, searchValue));
                        }

                        return Promise.resolve(result);
                    },
                    byKey: function(key) {
                        return Promise.resolve((data || []).find(i => i.ID === key));
                    }
   })
            });
        }

        async function processAddNewContractID(newValue) {
            if (!newValue || !newValue.trim()) return;

            InstanceContractIDP1D531D804E6F493BAF505C302A7A5760.option("disabled", true);

            const dataJSON = JSON.stringify([ContractIDP1D531D804E6F493BAF505C302A7A5760TableAddNew, [ContractIDP1D531D804E6F493BAF505C302A7A5760ColumnAddNew], [newValue.trim()]]);
            const idValsJSON = JSON.stringify([[], []]);

            try {
                const json = await saveFunction(dataJSON, idValsJSON);
                const dtError = json.data[json.data.length - 1] || [];
                if (dtError.length > 0 && dtError[0].Status === "ERROR") {
                    if ("0" === "1") {
                        uiManager.showAlert({ type: "error", message: dtError[0]?.Message || "Lỗi thêm mới" });
                    }
                } else {
                    if ("0" === "1") {
                        uiManager.showAlert({ type: "success", message: "Đã thêm mới: " + newValue });
                    }

                    if (ContractIDP1D531D804E6F493BAF505C302A7A5760DataSourceSP && ContractIDP1D531D804E6F493BAF505C302A7A5760DataSourceSP !== "") {
                        loadDataSourceCommon("ContractID", ContractIDP1D531D804E6F493BAF505C302A7A5760DataSourceSP, function(data) {
                            InstanceContractIDP1D531D804E6F493BAF505C302A7A5760.option("dataSource", getDataSourceConfigContractIDP1D531D804E6F493BAF505C302A7A5760(data));
                            const newItem = data.find(x => x.Name === newValue.trim());
                            if (newItem) {
                                InstanceContractIDP1D531D804E6F493BAF505C302A7A5760.option("value", newItem.ID);
                                InstanceContractIDP1D531D804E6F493BAF505C302A7A5760.option("searchValue", "");
                                ContractIDP1D531D804E6F493BAF505C302A7A5760CurrentSearch = "";
                            }
                        });
                    }
                }
            } catch (e) {
                console.error(e);
                if ("0" === "1") uiManager.showAlert({ type: "error", message: "Có lỗi khi thêm mới" });
            } finally {
                InstanceContractIDP1D531D804E6F493BAF505C302A7A5760.option("disabled", false);
                InstanceContractIDP1D531D804E6F493BAF505C302A7A5760.close();
            }
        }

        function highlightTextContractID(text, search) {
            if (!search || !text) return text;
            const regex = new RegExp("(" + search.replace(/[.*+?^${}()|[\]\\]/g, "\\$&") + ")", "gi");
            return text.replace(regex, "<mark class=\"bg-warning fw-bold px-1 rounded\">$1</mark>");
        }

        function customSearchContractID(item, searchValue) {
            if (!searchValue) return true;

            // Chuẩn hóa searchValue - loại bỏ dấu và chuyển thành lowercase
            let searchNormalized = searchValue.toLowerCase();

            if (typeof RemoveToneMarks_Js === "function") {
                searchNormalized = RemoveToneMarks_Js(searchValue).toLowerCase();
            }

            const fields = ["ID", "Name", "Code", "Description"];

            for (let i = 0; i < fields.length; i++) {
                const fieldValue = item[fields[i]];

                if (fieldValue) {
                    // Chuẩn hóa fieldValue - loại bỏ dấu và chuyển thành lowercase
                    let fieldNormalized = String(fieldValue).toLowerCase();

                    if (typeof RemoveToneMarks_Js === "function") {
                        fieldNormalized = RemoveToneMarks_Js(String(fieldValue)).toLowerCase();
                    }

                    const matchIndex = fieldNormalized.indexOf(searchNormalized);

                    // So sánh sau khi đã chuẩn hóa
                    if (matchIndex !== -1) {
                        return true;
                    }
                }
            }

            return false;
        }

        InstanceContractIDP1D531D804E6F493BAF505C302A7A5760 = $(cellElement + currentRecordID_Company_ID).dxSelectBox({
            readOnly: _readOnlyContractIDP1D531D804E6F493BAF505C302A7A5760,
            dataSource: getDataSourceConfigContractIDP1D531D804E6F493BAF505C302A7A5760(window["DataSource_ContractID"]),
            valueExpr: "ID",
            displayExpr: "Name",
            onOptionChanged: function(e) {},
            onContentReady: function(e) {},
            placeholder: "Tìm kiếm hoặc chọn...",
            searchEnabled: true,
            searchTimeout: 300,
            minSearchLength: 0,
            showDataBeforeSearch: true,
            showClearButton: false,
            stylingMode: "outlined",
            dropDownOptions: {
                showTitle: false,
                closeOnOutsideClick: true,
                height: "auto",
                maxHeight: 400,
                minWidth: 320,
                onShowing: function(e) {
                    if (!ContractIDP1D531D804E6F493BAF505C302A7A5760IsDataLoaded && ContractIDP1D531D804E6F493BAF505C302A7A5760DataSourceSP && ContractIDP1D531D804E6F493BAF505C302A7A5760DataSourceSP !== "") {
                        loadDataSourceCommon("ContractID", ContractIDP1D531D804E6F493BAF505C302A7A5760DataSourceSP, function(data) {
                            ContractIDP1D531D804E6F493BAF505C302A7A5760IsDataLoaded = true;
                            InstanceContractIDP1D531D804E6F493BAF505C302A7A5760.option("dataSource", getDataSourceConfigContractIDP1D531D804E6F493BAF505C302A7A5760(data));
                        });
                    }
                }
            },
            itemTemplate: function(data, index) {
                if (data.IsAddNew) {
                    const $item = $("<div>")
                        .addClass("d-flex align-items-center gap-2 px-3 py-2 text-primary fw-bold")
                        .css({ cursor: "pointer", borderTop: "1px dashed #dee2e6" });

                    $("<i>").addClass("bi bi-plus-circle-fill fs-5").appendTo($item);
                    $("<span>").text("Thêm mới: \"" + data.Name + "\"").appendTo($item);

                    $item.on("dxclick", async function(e) {
                        e.stopPropagation();
                        if (InstanceContractIDP1D531D804E6F493BAF505C302A7A5760 && InstanceContractIDP1D531D804E6F493BAF505C302A7A5760.blur) InstanceContractIDP1D531D804E6F493BAF505C302A7A5760.blur();
                        await processAddNewContractID(data.Name);
                    });

                    return $item;
                }

                const $item = $("<div>")
                    .addClass("d-flex align-items-center gap-3 px-3 py-2 my-1 mx-2 rounded")
                    .css({
                        cursor: "pointer",
                        transition: "all 0.2s ease",
                        border: "1px solid transparent"
                    });

                $item.on("mouseenter", function() {
                    $(this).css({
                        transform: "translateX(4px)",
                        borderColor: "#90caf9",
                        boxShadow: "0 2px 8px rgba(0,0,0,0.08)"
                    });
                }).on("mouseleave", function() {
                    $(this).css({
                        background: "",
                        transform: "",
                        borderColor: "transparent",
                        boxShadow: ""
                    });
                });

                const $content = $("<div>").addClass("flex-fill").css("minWidth", "0");
                const searchValue = InstanceContractIDP1D531D804E6F493BAF505C302A7A5760.option("searchValue") || "";

                const displayName = (data.ID !== undefined ? data.ID + " - " : "") + (data.Name || "");
                $("<div>")
                    .addClass("fw-semibold")
                    .css({
                        fontSize: "14px",
                        lineHeight: "1.4",
                        overflow: "hidden",
                        textOverflow: "ellipsis",
                        whiteSpace: "nowrap"
                    })
                    .html(highlightTextContractID(displayName, searchValue))
                    .appendTo($content);

                if (data.Description || data.Code) {
                    $("<div>")
                        .addClass("small text-muted")
                        .css({
                            fontSize: "12px",
                            overflow: "hidden",
                            textOverflow: "ellipsis",
                            whiteSpace: "nowrap"
                        })
                        .text(data.Code || data.Description)
                        .appendTo($content);
                }

                $content.appendTo($item);

                if (data.Status) {
                    const badgeClass = data.Status === "Active" ? "bg-success" : "bg-secondary";
                    $("<span>")
                        .addClass("badge " + badgeClass + " text-uppercase")
                        .css({
                            fontSize: "9px",
                            padding: "4px 8px",
                            letterSpacing: "0.5px",
                            flexShrink: "0"
                        })
                        .text(data.Status)
                        .appendTo($item);
                }

                setTimeout(() => {
                    $item.css({
                        opacity: "0",
                        transform: "translateX(-10px)"
                    }).animate({
                        opacity: 1
                    }, {
                        duration: 300,
                        step: function(now) {
                            $(this).css("transform", "translateX(" + (-10 + (now * 10)) + "px)");
                        },
                        delay: index * 30
                    });
                }, 10);

                return $item;
            },
            onOpened: function(e) {
                // Style dropdown
                $(e.component._popup.content()).parent()
                    .addClass("shadow-lg border rounded hpa-responsive")
                    .css({
                        borderRadius: "12px",
                        padding: "8px 0",
                        borderColor: "#dee2e6"
                    });
            },
            onFocusIn: function(e) {
                InstanceContractIDP1D531D804E6F493BAF505C302A7A5760.option("showClearButton", true);
            },
            onFocusOut: function(e) {
                InstanceContractIDP1D531D804E6F493BAF505C302A7A5760.option("showClearButton", false);
            },
            onKeyDown: function(e) {
                if (e.key === "Enter" || e.key === "Tab") {
                    InstanceContractIDP1D531D804E6F493BAF505C302A7A5760.option("showClearButton", false);
                }
            },
            onValueChanged: async function(e) {
                if (!e.event) return;

                // Feature: Check Instance AutoSave Flag
                if (_autoSaveContractIDP1D531D804E6F493BAF505C302A7A5760) {
                     // Nếu người dùng tìm kiếm rỗng và kết quả trả về là 0/empty/null (Copy from AutoSave mode)
                    if (e.value === "" || e.value == null || e.value === 0 || e.value === "0") {
                        InstanceContractIDP1D531D804E6F493BAF505C302A7A5760.option("value", _initialContractIDP1D531D804E6F493BAF505C302A7A5760);
                        return;
                    }

                    $(cellElement + currentRecordID_Company_ID).find(".dx-texteditor-input").blur();
                    if (InstanceContractIDP1D531D804E6F493BAF505C302A7A5760 && InstanceContractIDP1D531D804E6F493BAF505C302A7A5760.blur) InstanceContractIDP1D531D804E6F493BAF505C302A7A5760.blur();

                    const $el = $(e.element);
                    $el.css({
                        transform: "scale(1.02)",
                        boxShadow: "0 0 0 3px rgba(28, 151, 94, 0.2)",
                        transition: "all 0.2s ease"
                    });
                    setTimeout(() => {
                        $el.css({ transform: "", boxShadow: "" });
                    }, 300);

                    if (typeof window["onSelectBoxChanged_ContractID"] === "function") {
                        window["onSelectBoxChanged_ContractID"](e.value, InstanceContractIDP1D531D804E6F493BAF505C302A7A5760, e);
                    }

                    const val = e.value;
                    const dataJSON = JSON.stringify(["1758526346", ["ContractID"], [val || ""]]);

                    // Context-aware record IDs
                    let id1 = currentRecordID_ContracID;
                    if (typeof cellInfo !== "undefined" && cellInfo && cellInfo.data) {
                        id1 = cellInfo.data["ContracID"] || id1;
                    }
                    let currentRecordIDValue = [id1];
                    let currentRecordID = ["ContracID"];

                    if ("Company_ID" && "Company_ID".trim() !== "") {
                        let id2 = currentRecordID_Company_ID;
                        if (typeof cellInfo !== "undefined" && cellInfo && cellInfo.data) {
                            id2 = cellInfo.data["Company_ID"] || id2;
                        }
                        currentRecordIDValue.push(id2);
                        currentRecordID.push("Company_ID");
                    }
                    const idValsJSON = JSON.stringify([currentRecordIDValue, currentRecordID]);

                    try {
                        const json = await saveFunction(dataJSON, idValsJSON);
                        const dtError = json.data[json.data.length - 1] || [];
                        if (dtError.length > 0 && dtError[0].Status === "ERROR") {
                            if ("0" === "1") {
                                uiManager.showAlert({ type: "error", message: dtError[0]?.Message || "Lưu thất bại" });
                            }
                            InstanceContractIDP1D531D804E6F493BAF505C302A7A5760.option("value", _initialContractIDP1D531D804E6F493BAF505C302A7A5760);
                        } else {
                            if (typeof cellInfo !== "undefined" && cellInfo && cellInfo.component) {
                                try {
                                    const grid = cellInfo.component;
                                    grid.cellValue(cellInfo.rowIndex, "ContractID", val);
                                    grid.repaint();
                                } catch (syncErr) {
                                    console.warn("[Grid Sync] SelectBox ContractIDP1D531D804E6F493BAF505C302A7A5760: Không thể sync grid:", syncErr);
                                }
                            }
                            if ("0" === "1") {
                                uiManager.showAlert({ type: "success", message: "Lưu thành công" });
                            }
                            _initialContractIDP1D531D804E6F493BAF505C302A7A5760 = val;
                        }
                    } catch (err) {
                        if ("0" === "1") {
                            uiManager.showAlert({ type: "error", message: "Có lỗi xảy ra khi lưu" });
                        }
                        InstanceContractIDP1D531D804E6F493BAF505C302A7A5760.option("value", _initialContractIDP1D531D804E6F493BAF505C302A7A5760);
                        console.error("SelectBox Save Error:", err);
                    }
                    return;
                }

                // Normal Manual Mode Logic (No API)
                const $el = $(e.element);
                $el.css({
                    transform: "scale(1.02)",
                    boxShadow: "0 0 0 3px rgba(28, 151, 94, 0.2)",
                    transition: "all 0.2s ease"
                });
                setTimeout(() => {
                    $el.css({ transform: "", boxShadow: "" });
                }, 300);

                if (typeof window["onSelectBoxChanged_ContractID"] === "function") {
                    window["onSelectBoxChanged_ContractID"](e.value, InstanceContractIDP1D531D804E6F493BAF505C302A7A5760, e);
                }

                if (typeof cellInfo !== "undefined" && cellInfo && cellInfo.component) {
                    try {
                        const grid = cellInfo.component;
                        grid.cellValue(cellInfo.rowIndex, "ContractID", e.value);
                        grid.repaint();
                    } catch (syncErr) {
                        console.warn("[Grid Sync] Không thể sync grid:", syncErr);
                    }
                }
            }
        }).dxSelectBox("instance");

        let _initialContractIDP1D531D804E6F493BAF505C302A7A5760 = InstanceContractIDP1D531D804E6F493BAF505C302A7A5760.option("value");

                            // Set initial value
                            if (cellInfo.value !== undefined && cellInfo.value !== null && InstanceContractIDP1D531D804E6F493BAF505C302A7A5760) {
                                InstanceContractIDP1D531D804E6F493BAF505C302A7A5760.option("value", cellInfo.value);
                            }
                        },
            },

            {
                dataField: "StartDate",
                caption: "Ngày bắt đầu",
                width: 200,
                allowSorting: true,
                allowFiltering: true,
                cellTemplate: function(cellElement, cellInfo){
                            const val = cellInfo.value;
                            if (!val) {
                                $("<div>").addClass("dx-placeholder").text("--").appendTo(cellElement);
                                return;
                            }

                            const d = new Date(val);
                            let text = "";


                                    text = DevExpress.localization.formatDate(d, "dd/MM/yyyy");


                            $("<div>").text(text).appendTo(cellElement);
                        },
                        allowEditing: true,
                        editCellTemplate: function(cellElement, cellInfo) {
                            // Cập nhật record context ID cho row hiện tại
                            let rowID = null;
                            if (cellInfo.key !== undefined && cellInfo.key !== null) {
                                rowID = cellInfo.key;
                            } else if (cellInfo.data && cellInfo.data["ContracID"] !== undefined) {
                                rowID = cellInfo.data["ContracID"];
                            }

                            if (rowID !== null) {
                                currentRecordID_ContracID = rowID;
                            }

                            if ("Company_ID" && "Company_ID".trim() !== "" && cellInfo.data && cellInfo.data["Company_ID"] !== undefined) {
                                currentRecordID_Company_ID = cellInfo.data["Company_ID"];
                            }


        let InstanceStartDateP1D531D804E6F493BAF505C302A7A5760 = null;
        let StartDateTimeOut;
        let _autoSaveStartDateP1D531D804E6F493BAF505C302A7A5760 = false;
        let _readOnlyStartDateP1D531D804E6F493BAF505C302A7A5760 = false;

        async function DateboxSaveLogicStartDate() {
            let val = InstanceStartDateP1D531D804E6F493BAF505C302A7A5760.option("value");
            let valToSave = val ? DevExpress.localization.formatDate(new Date(val), "yyyy/MM/dd") : null;
            const dataJSON = JSON.stringify(["1758526346", ["StartDate"], [valToSave]]);

            // Context-aware record IDs
            let id1 = currentRecordID_ContracID;
            if (typeof cellInfo !== "undefined" && cellInfo && cellInfo.data) {
                id1 = cellInfo.data["ContracID"] || id1;
            }
            let currentRecordIDValue = [id1];
            let currentRecordID = ["ContracID"];

            if ("Company_ID" && "Company_ID".trim() !== "") {
                let id2 = currentRecordID_Company_ID;
                if (typeof cellInfo !== "undefined" && cellInfo && cellInfo.data) {
                    id2 = cellInfo.data["Company_ID"] || id2;
                }
                currentRecordIDValue.push(id2);
                currentRecordID.push("Company_ID");
            }

            const idValsJSON = JSON.stringify([currentRecordIDValue, currentRecordID]);

            try {
                const json = await saveFunction(dataJSON, idValsJSON);
                const dtError = json.data[json.data.length - 1] || [];
                if (dtError.length > 0 && dtError[0].Status === "ERROR") {
                    if ("0" === "1") {
                        uiManager.showAlert({ type: "error", message: dtError[0]?.Message || "Lưu thất bại" });
                    }
                } else {
                    if ("0" === "1") {
                        uiManager.showAlert({ type: "success", message: "Lưu thành công" });
                    }
                }

                if (typeof cellInfo !== "undefined" && cellInfo && cellInfo.component) {
                    try {
                        const grid = cellInfo.component;
                        grid.cellValue(cellInfo.rowIndex, "StartDate", val);
                        grid.repaint();
                    } catch (syncErr) {
                        console.warn("[Grid Sync] DateBox StartDateP1D531D804E6F493BAF505C302A7A5760: Error", syncErr);
                    }
                }
            } catch (err) {
                console.error("DateBox Save Error:", err);
            }
        }

        InstanceStartDateP1D531D804E6F493BAF505C302A7A5760 = $(cellElement + currentRecordID_Company_ID).dxDateBox({
            value: new Date(),
            type: "date",
            displayFormat: "dd/MM/yyyy",
            useMaskBehavior: true,
            openOnFieldClick: true,
            showClearButton: false,
            dateSerializationFormat: "yyyy-MM-dd",
            width: "100%",
            elementAttr: { class: "hpa-dx-datebox-inline" },
            readOnly: _readOnlyStartDateP1D531D804E6F493BAF505C302A7A5760,
            onValueChanged: async (e) => {
                if (_autoSaveStartDateP1D531D804E6F493BAF505C302A7A5760) {
                    clearTimeout(StartDateTimeOut);
                 e.event && await DateboxSaveLogicStartDate();
                } else {
                    if (typeof cellInfo !== "undefined" && cellInfo && cellInfo.component) {
                        const grid = cellInfo.component;
                        grid.cellValue(cellInfo.rowIndex, "StartDate", e.value);
                    }
                }
            },
            onKeyUp: (e) => {
                if (_autoSaveStartDateP1D531D804E6F493BAF505C302A7A5760) {
                    clearTimeout(StartDateTimeOut);
                    StartDateTimeOut = setTimeout(async () => DateboxSaveLogicStartDate(), 1000);
                }
            }
        }).dxDateBox("instance");

                            // Set initial value
                            if (cellInfo.value !== undefined && cellInfo.value !== null && InstanceStartDateP1D531D804E6F493BAF505C302A7A5760) {
                                InstanceStartDateP1D531D804E6F493BAF505C302A7A5760.option("value", cellInfo.value);
                            }
                        },
            },

            {
                dataField: "EndDate",
                caption: "Ngày kết thúc",
                width: 200,
                allowSorting: true,
                allowFiltering: true,
                cellTemplate: function(cellElement, cellInfo){
                            const val = cellInfo.value;
                            if (!val) {
                                $("<div>").addClass("dx-placeholder").text("--").appendTo(cellElement);
                                return;
                            }

                            const d = new Date(val);
                            let text = "";


                                    text = DevExpress.localization.formatDate(d, "dd/MM/yyyy");


                            $("<div>").text(text).appendTo(cellElement);
                        },
                        allowEditing: true,
                        editCellTemplate: function(cellElement, cellInfo) {
                            // Cập nhật record context ID cho row hiện tại
                            let rowID = null;
                            if (cellInfo.key !== undefined && cellInfo.key !== null) {
                                rowID = cellInfo.key;
                            } else if (cellInfo.data && cellInfo.data["ContracID"] !== undefined) {
                                rowID = cellInfo.data["ContracID"];
                            }

                            if (rowID !== null) {
                                currentRecordID_ContracID = rowID;
                            }

                            if ("Company_ID" && "Company_ID".trim() !== "" && cellInfo.data && cellInfo.data["Company_ID"] !== undefined) {
                                currentRecordID_Company_ID = cellInfo.data["Company_ID"];
                            }


        let InstanceEndDateP1D531D804E6F493BAF505C302A7A5760 = null;
        let EndDateTimeOut;
        let _autoSaveEndDateP1D531D804E6F493BAF505C302A7A5760 = false;
        let _readOnlyEndDateP1D531D804E6F493BAF505C302A7A5760 = false;

        async function DateboxSaveLogicEndDate() {
            let val = InstanceEndDateP1D531D804E6F493BAF505C302A7A5760.option("value");
            let valToSave = val ? DevExpress.localization.formatDate(new Date(val), "yyyy/MM/dd") : null;
            const dataJSON = JSON.stringify(["1758526346", ["EndDate"], [valToSave]]);

            // Context-aware record IDs
            let id1 = currentRecordID_ContracID;
            if (typeof cellInfo !== "undefined" && cellInfo && cellInfo.data) {
                id1 = cellInfo.data["ContracID"] || id1;
            }
            let currentRecordIDValue = [id1];
            let currentRecordID = ["ContracID"];

            if ("Company_ID" && "Company_ID".trim() !== "") {
                let id2 = currentRecordID_Company_ID;
                if (typeof cellInfo !== "undefined" && cellInfo && cellInfo.data) {
                    id2 = cellInfo.data["Company_ID"] || id2;
                }
                currentRecordIDValue.push(id2);
                currentRecordID.push("Company_ID");
            }

            const idValsJSON = JSON.stringify([currentRecordIDValue, currentRecordID]);

            try {
                const json = await saveFunction(dataJSON, idValsJSON);
                const dtError = json.data[json.data.length - 1] || [];
                if (dtError.length > 0 && dtError[0].Status === "ERROR") {
                    if ("0" === "1") {
                        uiManager.showAlert({ type: "error", message: dtError[0]?.Message || "Lưu thất bại" });
                    }
                } else {
                    if ("0" === "1") {
                        uiManager.showAlert({ type: "success", message: "Lưu thành công" });
                    }
                }

                if (typeof cellInfo !== "undefined" && cellInfo && cellInfo.component) {
                    try {
                        const grid = cellInfo.component;
                        grid.cellValue(cellInfo.rowIndex, "EndDate", val);
                        grid.repaint();
                    } catch (syncErr) {
                        console.warn("[Grid Sync] DateBox EndDateP1D531D804E6F493BAF505C302A7A5760: Error", syncErr);
                    }
                }
            } catch (err) {
                console.error("DateBox Save Error:", err);
            }
        }

        InstanceEndDateP1D531D804E6F493BAF505C302A7A5760 = $(cellElement + currentRecordID_Company_ID).dxDateBox({
            value: new Date(),
            type: "date",
            displayFormat: "dd/MM/yyyy",
            useMaskBehavior: true,
            openOnFieldClick: true,
            showClearButton: false,
            dateSerializationFormat: "yyyy-MM-dd",
            width: "100%",
            elementAttr: { class: "hpa-dx-datebox-inline" },
            readOnly: _readOnlyEndDateP1D531D804E6F493BAF505C302A7A5760,
            onValueChanged: async (e) => {
                if (_autoSaveEndDateP1D531D804E6F493BAF505C302A7A5760) {
                    clearTimeout(EndDateTimeOut);
                    e.event && await DateboxSaveLogicEndDate();
                } else {
                    if (typeof cellInfo !== "undefined" && cellInfo && cellInfo.component) {
                        const grid = cellInfo.component;
                        grid.cellValue(cellInfo.rowIndex, "EndDate", e.value);
                    }
                }
            },
            onKeyUp: (e) => {
                if (_autoSaveEndDateP1D531D804E6F493BAF505C302A7A5760) {
                    clearTimeout(EndDateTimeOut);
                    EndDateTimeOut = setTimeout(async () => DateboxSaveLogicEndDate(), 1000);
                }
            }
        }).dxDateBox("instance");

                            // Set initial value
                            if (cellInfo.value !== undefined && cellInfo.value !== null && InstanceEndDateP1D531D804E6F493BAF505C302A7A5760) {
                                InstanceEndDateP1D531D804E6F493BAF505C302A7A5760.option("value", cellInfo.value);
                            }
                        },
            },

                            ],
                            onCellClick: function(e) {
                                // Nếu multiSelect k`hông bật và IsOpenDetailRowGrid không bật
                                if (0 === 0) {
                                    return;
                                }

                                // Nếu bật IsOpenDetailRowGrid
                                if (0 === 1) {
// CHỈ CHO PHÉP click vào cột đầu tiên (index 0) - thường là cột ID/Mã
                                    if (e.columnIndex === 0) {
                                        const recordID = e.key || (e.data && e.data["ContracID"]);
                                        if (recordID !== undefined && recordID !== null && recordID !== "") {
                                            window.currentRecordID_ContracID = recordID;

                                            if (typeof openDetailContracID === "function") {
                                                console.log("ContracID")
                                                openDetailContracID(recordID);
                                            }
                                        }
                                    }
                                }
                            },
                            onRowPrepared: function(e) {
                                if (e.rowType === "data") {
                                    // Nếu multiSelect không bật và IsOpenDetailRowGrid không bật
                                    if (0 === 0 && 0 === 0) {
                                        return;
                                    }

                                    // Nếu bật IsOpenDetailRowGrid - CHỈ highlight cột đầu tiên
                                    if (0 === 1 && 0 === 0) {
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
                            },
                            onContentReady: function(e) {
                                const grid = e.component;
                                // Wait for search panel to be rendered
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
                                }, 100);
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
                                const tableName = "sp_CRM_ContractHistory_html";
                                // Lưu trữ cấu hình ban đầu
                                if (!window._FullColumnConfig_gridContractHistory) {
                                    window._FullColumnConfig_gridContractHistory = JSON.parse(JSON.stringify(grid.option("columns")));
                                }

                                // Khôi phục cấu hình cột
                                loadGridColumnConfig(tableName, function (config) {
                                    if (Array.isArray(config.visibleColumns) || Array.isArray(config.columnOrder)) {
                                        let currentColumns = grid.getVisibleColumns(); // Lấy danh sách cột hiện tại

                                        // Lấy lại cấu hình đầy đủ từ _FullColumnConfig_gridContractHistory
                                        let fullColumns = window._FullColumnConfig_gridContractHistory || [];

                                        // Xây dựng lại mảng columns với tất cả các thuộc tính, bao gồm cellTemplate và editCellTemplate
                                        let finalColumns = fullColumns.map(col => {
                                            if (typeof col === "string") return col;

                                            let newCol = { ...col };

                                            // Cập nhật visible
                                            newCol.visible = config.visibleColumns ? config.visibleColumns.includes(col.dataField) : true;

                                            // Cập nhật order nếu cần
                                            if (Array.isArray(config.columnOrder)) {
                                                // (Nếu cần, có thể thêm logic sắp xếp ở đây, nhưng thường không cần vì grid tự quản lý)
                                            }

                                            // Quan trọng: Thiết lập lại cellTemplate và editCellTemplate nếu chúng tồn tại trong config ban đầu
                                            // Kiểm tra xem cột này có chứa template không (dựa vào tên cột và dữ liệu từ #temptable)
                                            // Đây là bước quan trọng để khắc phục lỗi!
                                            if (newCol.cellTemplate || newCol.editCellTemplate) {
                                                // Nếu đã có template trong config ban đầu, giữ nguyên
                                                // Hoặc bạn có thể gọi lại hàm tạo template ở đây nếu cần
                                            } else {
                                                // Nếu không có, có thể thiết lập lại từ dữ liệu trong #temptable (nếu có sẵn)
                                                // Ví dụ: newCol.cellTemplate = function(...) { ... };
                                            }

                                            return newCol;
                                        });

                                        // Áp dụng cấu hình mới
                                        grid.option("columns", finalColumns);

                                        // Sau khi áp dụng cấu hình, buộc grid phải render lại để các template được áp dụng
                                        grid.repaint();
                                    }
                                });
                            },
                            onOptionChanged: function(e) {
                                if (e.fullName.startsWith("columns[")) {
                                    clearTimeout(window.__saveGridColumnTimeout__gridContractHistory);
                                    window.__saveGridColumnTimeout__gridContractHistory = setTimeout(() => {
                                        const cols = e.component.getVisibleColumns();
                                        saveGridColumnConfig("sp_CRM_ContractHistory_html", cols);
                                    }, 800);
                                }
                            }
                        }).dxDataGrid("instance");

        window["DataSource_Company_ID"] = window["DataSource_Company_ID"] || [];

        let Company_IDP53E5F56DC72B4F08904E976C0EACEF0BDataSourceSP = "sp_getCompanyInfo";
        let Company_IDP53E5F56DC72B4F08904E976C0EACEF0BIsLoading = false;
        let Company_IDP53E5F56DC72B4F08904E976C0EACEF0BIsDataLoaded = false;
        let _autoSaveCompany_IDP53E5F56DC72B4F08904E976C0EACEF0B = false;
        let _readOnlyCompany_IDP53E5F56DC72B4F08904E976C0EACEF0B = false;
        let Company_IDP53E5F56DC72B4F08904E976C0EACEF0BTableAddNew = "";
        let Company_IDP53E5F56DC72B4F08904E976C0EACEF0BColumnAddNew = "";
        let Company_IDP53E5F56DC72B4F08904E976C0EACEF0BCurrentSearch = "";
        let InstanceCompany_IDP53E5F56DC72B4F08904E976C0EACEF0B = null;

        function getDataSourceConfigCompany_IDP53E5F56DC72B4F08904E976C0EACEF0B(data) {
            return new DevExpress.data.DataSource({
                store: new DevExpress.data.CustomStore({
                    key: "ID",
                    load: function(loadOptions) {
                        // LẤY searchValue từ INSTANCE (option "text" hoặc "searchValue")
                        const searchValue = (InstanceCompany_IDP53E5F56DC72B4F08904E976C0EACEF0B && InstanceCompany_IDP53E5F56DC72B4F08904E976C0EACEF0B.option)
                            ? (InstanceCompany_IDP53E5F56DC72B4F08904E976C0EACEF0B.option("text") || InstanceCompany_IDP53E5F56DC72B4F08904E976C0EACEF0B.option("searchValue") || "")
                            : (loadOptions.searchValue || "");

                        let result = data || [];

                        if (searchValue && searchValue.trim()) {
                            result = result.filter(item => customSearchCompany_ID(item, searchValue));
                        }

                        return Promise.resolve(result);
                    },
                    byKey: function(key) {
                        return Promise.resolve((data || []).find(i => i.ID === key));
                    }
   })
            });
        }

        async function processAddNewCompany_ID(newValue) {
            if (!newValue || !newValue.trim()) return;

            InstanceCompany_IDP53E5F56DC72B4F08904E976C0EACEF0B.option("disabled", true);

            const dataJSON = JSON.stringify([Company_IDP53E5F56DC72B4F08904E976C0EACEF0BTableAddNew, [Company_IDP53E5F56DC72B4F08904E976C0EACEF0BColumnAddNew], [newValue.trim()]]);
            const idValsJSON = JSON.stringify([[], []]);

            try {
                const json = await saveFunction(dataJSON, idValsJSON);
                const dtError = json.data[json.data.length - 1] || [];
                if (dtError.length > 0 && dtError[0].Status === "ERROR") {
                    if ("0" === "1") {
                        uiManager.showAlert({ type: "error", message: dtError[0]?.Message || "Lỗi thêm mới" });
                    }
                } else {
                    if ("0" === "1") {
                        uiManager.showAlert({ type: "success", message: "Đã thêm mới: " + newValue });
                    }

                    if (Company_IDP53E5F56DC72B4F08904E976C0EACEF0BDataSourceSP && Company_IDP53E5F56DC72B4F08904E976C0EACEF0BDataSourceSP !== "") {
                        loadDataSourceCommon("Company_ID", Company_IDP53E5F56DC72B4F08904E976C0EACEF0BDataSourceSP, function(data) {
                            InstanceCompany_IDP53E5F56DC72B4F08904E976C0EACEF0B.option("dataSource", getDataSourceConfigCompany_IDP53E5F56DC72B4F08904E976C0EACEF0B(data));
                            const newItem = data.find(x => x.Name === newValue.trim());
                            if (newItem) {
                                InstanceCompany_IDP53E5F56DC72B4F08904E976C0EACEF0B.option("value", newItem.ID);
                                InstanceCompany_IDP53E5F56DC72B4F08904E976C0EACEF0B.option("searchValue", "");
                                Company_IDP53E5F56DC72B4F08904E976C0EACEF0BCurrentSearch = "";
                            }
                        });
                    }
                }
            } catch (e) {
                console.error(e);
                if ("0" === "1") uiManager.showAlert({ type: "error", message: "Có lỗi khi thêm mới" });
            } finally {
                InstanceCompany_IDP53E5F56DC72B4F08904E976C0EACEF0B.option("disabled", false);
                InstanceCompany_IDP53E5F56DC72B4F08904E976C0EACEF0B.close();
            }
        }

        function highlightTextCompany_ID(text, search) {
            if (!search || !text) return text;
            const regex = new RegExp("(" + search.replace(/[.*+?^${}()|[\]\\]/g, "\\$&") + ")", "gi");
            return text.replace(regex, "<mark class=\"bg-warning fw-bold px-1 rounded\">$1</mark>");
        }

        function customSearchCompany_ID(item, searchValue) {
            if (!searchValue) return true;

            // Chuẩn hóa searchValue - loại bỏ dấu và chuyển thành lowercase
            let searchNormalized = searchValue.toLowerCase();

            if (typeof RemoveToneMarks_Js === "function") {
                searchNormalized = RemoveToneMarks_Js(searchValue).toLowerCase();
            }

            const fields = ["ID", "Name", "Code", "Description"];

            for (let i = 0; i < fields.length; i++) {
                const fieldValue = item[fields[i]];

                if (fieldValue) {
                    // Chuẩn hóa fieldValue - loại bỏ dấu và chuyển thành lowercase
                    let fieldNormalized = String(fieldValue).toLowerCase();

                    if (typeof RemoveToneMarks_Js === "function") {
                        fieldNormalized = RemoveToneMarks_Js(String(fieldValue)).toLowerCase();
                    }

                    const matchIndex = fieldNormalized.indexOf(searchNormalized);

                    // So sánh sau khi đã chuẩn hóa
                    if (matchIndex !== -1) {
                        return true;
                    }
                }
            }

            return false;
        }

        InstanceCompany_IDP53E5F56DC72B4F08904E976C0EACEF0B = $("#P53E5F56DC72B4F08904E976C0EACEF0B" + currentRecordID_Company_ID).dxSelectBox({
            readOnly: _readOnlyCompany_IDP53E5F56DC72B4F08904E976C0EACEF0B,
            dataSource: getDataSourceConfigCompany_IDP53E5F56DC72B4F08904E976C0EACEF0B(window["DataSource_Company_ID"]),
            valueExpr: "ID",
            displayExpr: "Name",
            onOptionChanged: function(e) {},
            onContentReady: function(e) {},
            placeholder: "Tìm kiếm hoặc chọn...",
            searchEnabled: true,
            searchTimeout: 300,
            minSearchLength: 0,
            showDataBeforeSearch: true,
            showClearButton: false,
            stylingMode: "outlined",
            dropDownOptions: {
                showTitle: false,
                closeOnOutsideClick: true,
                height: "auto",
                maxHeight: 400,
                minWidth: 320,
                onShowing: function(e) {
                    if (!Company_IDP53E5F56DC72B4F08904E976C0EACEF0BIsDataLoaded && Company_IDP53E5F56DC72B4F08904E976C0EACEF0BDataSourceSP && Company_IDP53E5F56DC72B4F08904E976C0EACEF0BDataSourceSP !== "") {
                        loadDataSourceCommon("Company_ID", Company_IDP53E5F56DC72B4F08904E976C0EACEF0BDataSourceSP, function(data) {
                            Company_IDP53E5F56DC72B4F08904E976C0EACEF0BIsDataLoaded = true;
                            InstanceCompany_IDP53E5F56DC72B4F08904E976C0EACEF0B.option("dataSource", getDataSourceConfigCompany_IDP53E5F56DC72B4F08904E976C0EACEF0B(data));
                        });
                    }
                }
            },
            itemTemplate: function(data, index) {
                if (data.IsAddNew) {
                    const $item = $("<div>")
                        .addClass("d-flex align-items-center gap-2 px-3 py-2 text-primary fw-bold")
                        .css({ cursor: "pointer", borderTop: "1px dashed #dee2e6" });

                    $("<i>").addClass("bi bi-plus-circle-fill fs-5").appendTo($item);
                    $("<span>").text("Thêm mới: \"" + data.Name + "\"").appendTo($item);

                    $item.on("dxclick", async function(e) {
                        e.stopPropagation();
                        if (InstanceCompany_IDP53E5F56DC72B4F08904E976C0EACEF0B && InstanceCompany_IDP53E5F56DC72B4F08904E976C0EACEF0B.blur) InstanceCompany_IDP53E5F56DC72B4F08904E976C0EACEF0B.blur();
                        await processAddNewCompany_ID(data.Name);
                    });

                    return $item;
                }

                const $item = $("<div>")
                    .addClass("d-flex align-items-center gap-3 px-3 py-2 my-1 mx-2 rounded")
                    .css({
                        cursor: "pointer",
                        transition: "all 0.2s ease",
                        border: "1px solid transparent"
                    });

                $item.on("mouseenter", function() {
                    $(this).css({
                        transform: "translateX(4px)",
                        borderColor: "#90caf9",
                        boxShadow: "0 2px 8px rgba(0,0,0,0.08)"
                    });
                }).on("mouseleave", function() {
                    $(this).css({
                        background: "",
                        transform: "",
                        borderColor: "transparent",
                        boxShadow: ""
                    });
                });

                const $content = $("<div>").addClass("flex-fill").css("minWidth", "0");
                const searchValue = InstanceCompany_IDP53E5F56DC72B4F08904E976C0EACEF0B.option("searchValue") || "";

                const displayName = (data.ID !== undefined ? data.ID + " - " : "") + (data.Name || "");
                $("<div>")
                    .addClass("fw-semibold")
                    .css({
                        fontSize: "14px",
                        lineHeight: "1.4",
                        overflow: "hidden",
                        textOverflow: "ellipsis",
                        whiteSpace: "nowrap"
                    })
                    .html(highlightTextCompany_ID(displayName, searchValue))
                    .appendTo($content);

                if (data.Description || data.Code) {
    $("<div>")
                        .addClass("small text-muted")
                        .css({
                            fontSize: "12px",
                            overflow: "hidden",
                            textOverflow: "ellipsis",
                            whiteSpace: "nowrap"
                        })
                        .text(data.Code || data.Description)
                        .appendTo($content);
                }

                $content.appendTo($item);

                if (data.Status) {
                    const badgeClass = data.Status === "Active" ? "bg-success" : "bg-secondary";
                    $("<span>")
                        .addClass("badge " + badgeClass + " text-uppercase")
                        .css({
                            fontSize: "9px",
                            padding: "4px 8px",
                            letterSpacing: "0.5px",
                            flexShrink: "0"
                        })
                        .text(data.Status)
                        .appendTo($item);
                }

                setTimeout(() => {
                    $item.css({
                        opacity: "0",
                        transform: "translateX(-10px)"
                    }).animate({
                        opacity: 1
                    }, {
                        duration: 300,
                        step: function(now) {
                            $(this).css("transform", "translateX(" + (-10 + (now * 10)) + "px)");
                        },
                        delay: index * 30
                    });
                }, 10);

                return $item;
            },
            onOpened: function(e) {
                // Style dropdown
                $(e.component._popup.content()).parent()
                    .addClass("shadow-lg border rounded hpa-responsive")
                    .css({
                        borderRadius: "12px",
                        padding: "8px 0",
                        borderColor: "#dee2e6"
                    });
            },
            onFocusIn: function(e) {
                InstanceCompany_IDP53E5F56DC72B4F08904E976C0EACEF0B.option("showClearButton", true);
            },
            onFocusOut: function(e) {
                InstanceCompany_IDP53E5F56DC72B4F08904E976C0EACEF0B.option("showClearButton", false);
            },
            onKeyDown: function(e) {
                if (e.key === "Enter" || e.key === "Tab") {
                    InstanceCompany_IDP53E5F56DC72B4F08904E976C0EACEF0B.option("showClearButton", false);
                }
            },
            onValueChanged: async function(e) {
                if (!e.event) return;

                // Feature: Check Instance AutoSave Flag
                if (_autoSaveCompany_IDP53E5F56DC72B4F08904E976C0EACEF0B) {
                     // Nếu người dùng tìm kiếm rỗng và kết quả trả về là 0/empty/null (Copy from AutoSave mode)
                    if (e.value === "" || e.value == null || e.value === 0 || e.value === "0") {
                        InstanceCompany_IDP53E5F56DC72B4F08904E976C0EACEF0B.option("value", _initialCompany_IDP53E5F56DC72B4F08904E976C0EACEF0B);
                        return;
                    }

                    $("#P53E5F56DC72B4F08904E976C0EACEF0B" + currentRecordID_Company_ID).find(".dx-texteditor-input").blur();
                    if (InstanceCompany_IDP53E5F56DC72B4F08904E976C0EACEF0B && InstanceCompany_IDP53E5F56DC72B4F08904E976C0EACEF0B.blur) InstanceCompany_IDP53E5F56DC72B4F08904E976C0EACEF0B.blur();

                    const $el = $(e.element);
                    $el.css({
                        transform: "scale(1.02)",
                        boxShadow: "0 0 0 3px rgba(28, 151, 94, 0.2)",
                        transition: "all 0.2s ease"
                    });
                    setTimeout(() => {
      $el.css({ transform: "", boxShadow: "" });
                    }, 300);

                    if (typeof window["onSelectBoxChanged_Company_ID"] === "function") {
                        window["onSelectBoxChanged_Company_ID"](e.value, InstanceCompany_IDP53E5F56DC72B4F08904E976C0EACEF0B, e);
                    }

                    const val = e.value;
                    const dataJSON = JSON.stringify(["1758526346", ["Company_ID"], [val || ""]]);

                    // Context-aware record IDs
                    let id1 = currentRecordID_ContracID;
                    if (typeof cellInfo !== "undefined" && cellInfo && cellInfo.data) {
                        id1 = cellInfo.data["ContracID"] || id1;
                    }
                    let currentRecordIDValue = [id1];
                    let currentRecordID = ["ContracID"];

                    if ("Company_ID" && "Company_ID".trim() !== "") {
                        let id2 = currentRecordID_Company_ID;
                        if (typeof cellInfo !== "undefined" && cellInfo && cellInfo.data) {
                            id2 = cellInfo.data["Company_ID"] || id2;
                        }
                        currentRecordIDValue.push(id2);
                        currentRecordID.push("Company_ID");
                    }
                    const idValsJSON = JSON.stringify([currentRecordIDValue, currentRecordID]);

                    try {
                        const json = await saveFunction(dataJSON, idValsJSON);
                        const dtError = json.data[json.data.length - 1] || [];
                        if (dtError.length > 0 && dtError[0].Status === "ERROR") {
                            if ("0" === "1") {
                                uiManager.showAlert({ type: "error", message: dtError[0]?.Message || "Lưu thất bại" });
                            }
                            InstanceCompany_IDP53E5F56DC72B4F08904E976C0EACEF0B.option("value", _initialCompany_IDP53E5F56DC72B4F08904E976C0EACEF0B);
                        } else {
                            if (typeof cellInfo !== "undefined" && cellInfo && cellInfo.component) {
                                try {
                                    const grid = cellInfo.component;
                                    grid.cellValue(cellInfo.rowIndex, "Company_ID", val);
                                    grid.repaint();
                                } catch (syncErr) {
                                    console.warn("[Grid Sync] SelectBox Company_IDP53E5F56DC72B4F08904E976C0EACEF0B: Không thể sync grid:", syncErr);
                                }
                            }
                            if ("0" === "1") {
                                uiManager.showAlert({ type: "success", message: "Lưu thành công" });
                            }
                            _initialCompany_IDP53E5F56DC72B4F08904E976C0EACEF0B = val;
                        }
                    } catch (err) {
                        if ("0" === "1") {
                            uiManager.showAlert({ type: "error", message: "Có lỗi xảy ra khi lưu" });
                        }
                        InstanceCompany_IDP53E5F56DC72B4F08904E976C0EACEF0B.option("value", _initialCompany_IDP53E5F56DC72B4F08904E976C0EACEF0B);
                        console.error("SelectBox Save Error:", err);
                    }
                    return;
                }

                // Normal Manual Mode Logic (No API)
                const $el = $(e.element);
                $el.css({
                    transform: "scale(1.02)",
                    boxShadow: "0 0 0 3px rgba(28, 151, 94, 0.2)",
                    transition: "all 0.2s ease"
                });
                setTimeout(() => {
                    $el.css({ transform: "", boxShadow: "" });
                }, 300);

                if (typeof window["onSelectBoxChanged_Company_ID"] === "function") {
                    window["onSelectBoxChanged_Company_ID"](e.value, InstanceCompany_IDP53E5F56DC72B4F08904E976C0EACEF0B, e);
                }

                if (typeof cellInfo !== "undefined" && cellInfo && cellInfo.component) {
                    try {
                        const grid = cellInfo.component;
                        grid.cellValue(cellInfo.rowIndex, "Company_ID", e.value);
                        grid.repaint();
                    } catch (syncErr) {
                        console.warn("[Grid Sync] Không thể sync grid:", syncErr);
                    }
                }
            }
        }).dxSelectBox("instance");

        let _initialCompany_IDP53E5F56DC72B4F08904E976C0EACEF0B = InstanceCompany_IDP53E5F56DC72B4F08904E976C0EACEF0B.option("value");

        window["DataSource_ContractID"] = window["DataSource_ContractID"] || [];

        let ContractIDPBE8BE54C38914BAEA0646C9B6A1DD6A2DataSourceSP = "sp_CRM_getContractType";
        let ContractIDPBE8BE54C38914BAEA0646C9B6A1DD6A2IsLoading = false;
        let ContractIDPBE8BE54C38914BAEA0646C9B6A1DD6A2IsDataLoaded = false;
        let _autoSaveContractIDPBE8BE54C38914BAEA0646C9B6A1DD6A2 = false;
        let _readOnlyContractIDPBE8BE54C38914BAEA0646C9B6A1DD6A2 = false;
        let ContractIDPBE8BE54C38914BAEA0646C9B6A1DD6A2TableAddNew = "";
        let ContractIDPBE8BE54C38914BAEA0646C9B6A1DD6A2ColumnAddNew = "";
        let ContractIDPBE8BE54C38914BAEA0646C9B6A1DD6A2CurrentSearch = "";
        let InstanceContractIDPBE8BE54C38914BAEA0646C9B6A1DD6A2 = null;

        function getDataSourceConfigContractIDPBE8BE54C38914BAEA0646C9B6A1DD6A2(data) {
            return new DevExpress.data.DataSource({
                store: new DevExpress.data.CustomStore({
                    key: "ID",
                    load: function(loadOptions) {
                        // LẤY searchValue từ INSTANCE (option "text" hoặc "searchValue")
                        const searchValue = (InstanceContractIDPBE8BE54C38914BAEA0646C9B6A1DD6A2 && InstanceContractIDPBE8BE54C38914BAEA0646C9B6A1DD6A2.option)
                            ? (InstanceContractIDPBE8BE54C38914BAEA0646C9B6A1DD6A2.option("text") || InstanceContractIDPBE8BE54C38914BAEA0646C9B6A1DD6A2.option("searchValue") || "")
                            : (loadOptions.searchValue || "");

                        let result = data || [];

                        if (searchValue && searchValue.trim()) {
                            result = result.filter(item => customSearchContractID(item, searchValue));
                        }

                        return Promise.resolve(result);
                    },
                    byKey: function(key) {
                        return Promise.resolve((data || []).find(i => i.ID === key));
                    }
   })
            });
        }

        async function processAddNewContractID(newValue) {
            if (!newValue || !newValue.trim()) return;

            InstanceContractIDPBE8BE54C38914BAEA0646C9B6A1DD6A2.option("disabled", true);

            const dataJSON = JSON.stringify([ContractIDPBE8BE54C38914BAEA0646C9B6A1DD6A2TableAddNew, [ContractIDPBE8BE54C38914BAEA0646C9B6A1DD6A2ColumnAddNew], [newValue.trim()]]);
            const idValsJSON = JSON.stringify([[], []]);

            try {
                const json = await saveFunction(dataJSON, idValsJSON);
                const dtError = json.data[json.data.length - 1] || [];
                if (dtError.length > 0 && dtError[0].Status === "ERROR") {
                    if ("0" === "1") {
                        uiManager.showAlert({ type: "error", message: dtError[0]?.Message || "Lỗi thêm mới" });
                    }
                } else {
                    if ("0" === "1") {
                        uiManager.showAlert({ type: "success", message: "Đã thêm mới: " + newValue });
}

                    if (ContractIDPBE8BE54C38914BAEA0646C9B6A1DD6A2DataSourceSP && ContractIDPBE8BE54C38914BAEA0646C9B6A1DD6A2DataSourceSP !== "") {
                        loadDataSourceCommon("ContractID", ContractIDPBE8BE54C38914BAEA0646C9B6A1DD6A2DataSourceSP, function(data) {
                            InstanceContractIDPBE8BE54C38914BAEA0646C9B6A1DD6A2.option("dataSource", getDataSourceConfigContractIDPBE8BE54C38914BAEA0646C9B6A1DD6A2(data));
                            const newItem = data.find(x => x.Name === newValue.trim());
                            if (newItem) {
                                InstanceContractIDPBE8BE54C38914BAEA0646C9B6A1DD6A2.option("value", newItem.ID);
                                InstanceContractIDPBE8BE54C38914BAEA0646C9B6A1DD6A2.option("searchValue", "");
                                ContractIDPBE8BE54C38914BAEA0646C9B6A1DD6A2CurrentSearch = "";
                            }
                        });
                    }
                }
            } catch (e) {
                console.error(e);
                if ("0" === "1") uiManager.showAlert({ type: "error", message: "Có lỗi khi thêm mới" });
            } finally {
                InstanceContractIDPBE8BE54C38914BAEA0646C9B6A1DD6A2.option("disabled", false);
                InstanceContractIDPBE8BE54C38914BAEA0646C9B6A1DD6A2.close();
            }
        }

        function highlightTextContractID(text, search) {
            if (!search || !text) return text;
            const regex = new RegExp("(" + search.replace(/[.*+?^${}()|[\]\\]/g, "\\$&") + ")", "gi");
            return text.replace(regex, "<mark class=\"bg-warning fw-bold px-1 rounded\">$1</mark>");
        }

        function customSearchContractID(item, searchValue) {
            if (!searchValue) return true;

            // Chuẩn hóa searchValue - loại bỏ dấu và chuyển thành lowercase
            let searchNormalized = searchValue.toLowerCase();

            if (typeof RemoveToneMarks_Js === "function") {
                searchNormalized = RemoveToneMarks_Js(searchValue).toLowerCase();
            }

            const fields = ["ID", "Name", "Code", "Description"];

            for (let i = 0; i < fields.length; i++) {
                const fieldValue = item[fields[i]];

                if (fieldValue) {
                    // Chuẩn hóa fieldValue - loại bỏ dấu và chuyển thành lowercase
                    let fieldNormalized = String(fieldValue).toLowerCase();

                    if (typeof RemoveToneMarks_Js === "function") {
                        fieldNormalized = RemoveToneMarks_Js(String(fieldValue)).toLowerCase();
                    }

                    const matchIndex = fieldNormalized.indexOf(searchNormalized);

                    // So sánh sau khi đã chuẩn hóa
                    if (matchIndex !== -1) {
                        return true;
                    }
                }
            }

            return false;
        }

        InstanceContractIDPBE8BE54C38914BAEA0646C9B6A1DD6A2 = $("#PBE8BE54C38914BAEA0646C9B6A1DD6A2" + currentRecordID_Company_ID).dxSelectBox({
            readOnly: _readOnlyContractIDPBE8BE54C38914BAEA0646C9B6A1DD6A2,
            dataSource: getDataSourceConfigContractIDPBE8BE54C38914BAEA0646C9B6A1DD6A2(window["DataSource_ContractID"]),
            valueExpr: "ID",
            displayExpr: "Name",
            onOptionChanged: function(e) {},
            onContentReady: function(e) {},
            placeholder: "Tìm kiếm hoặc chọn...",
            searchEnabled: true,
            searchTimeout: 300,
            minSearchLength: 0,
            showDataBeforeSearch: true,
            showClearButton: false,
            stylingMode: "outlined",
            dropDownOptions: {
                showTitle: false,
                closeOnOutsideClick: true,
                height: "auto",
                maxHeight: 400,
         minWidth: 320,
                onShowing: function(e) {
                    if (!ContractIDPBE8BE54C38914BAEA0646C9B6A1DD6A2IsDataLoaded && ContractIDPBE8BE54C38914BAEA0646C9B6A1DD6A2DataSourceSP && ContractIDPBE8BE54C38914BAEA0646C9B6A1DD6A2DataSourceSP !== "") {
                        loadDataSourceCommon("ContractID", ContractIDPBE8BE54C38914BAEA0646C9B6A1DD6A2DataSourceSP, function(data) {
                            ContractIDPBE8BE54C38914BAEA0646C9B6A1DD6A2IsDataLoaded = true;
                            InstanceContractIDPBE8BE54C38914BAEA0646C9B6A1DD6A2.option("dataSource", getDataSourceConfigContractIDPBE8BE54C38914BAEA0646C9B6A1DD6A2(data));
                        });
                    }
                }
            },
            itemTemplate: function(data, index) {
                if (data.IsAddNew) {
                    const $item = $("<div>")
                        .addClass("d-flex align-items-center gap-2 px-3 py-2 text-primary fw-bold")
                        .css({ cursor: "pointer", borderTop: "1px dashed #dee2e6" });

                    $("<i>").addClass("bi bi-plus-circle-fill fs-5").appendTo($item);
                    $("<span>").text("Thêm mới: \"" + data.Name + "\"").appendTo($item);

                    $item.on("dxclick", async function(e) {
                        e.stopPropagation();
                        if (InstanceContractIDPBE8BE54C38914BAEA0646C9B6A1DD6A2 && InstanceContractIDPBE8BE54C38914BAEA0646C9B6A1DD6A2.blur) InstanceContractIDPBE8BE54C38914BAEA0646C9B6A1DD6A2.blur();
                        await processAddNewContractID(data.Name);
                    });

                    return $item;
                }

                const $item = $("<div>")
                    .addClass("d-flex align-items-center gap-3 px-3 py-2 my-1 mx-2 rounded")
                    .css({
                        cursor: "pointer",
                        transition: "all 0.2s ease",
                        border: "1px solid transparent"
                    });

                $item.on("mouseenter", function() {
                    $(this).css({
                        transform: "translateX(4px)",
                        borderColor: "#90caf9",
                        boxShadow: "0 2px 8px rgba(0,0,0,0.08)"
                    });
                }).on("mouseleave", function() {
                    $(this).css({
                        background: "",
                        transform: "",
                        borderColor: "transparent",
                        boxShadow: ""
                    });
                });

                const $content = $("<div>").addClass("flex-fill").css("minWidth", "0");
                const searchValue = InstanceContractIDPBE8BE54C38914BAEA0646C9B6A1DD6A2.option("searchValue") || "";

                const displayName = (data.ID !== undefined ? data.ID + " - " : "") + (data.Name || "");
                $("<div>")
                    .addClass("fw-semibold")
                    .css({
                        fontSize: "14px",
                        lineHeight: "1.4",
                        overflow: "hidden",
                        textOverflow: "ellipsis",
                        whiteSpace: "nowrap"
                    })
                    .html(highlightTextContractID(displayName, searchValue))
                    .appendTo($content);

                if (data.Description || data.Code) {
                    $("<div>")
                        .addClass("small text-muted")
                        .css({
                            fontSize: "12px",
                            overflow: "hidden",
                            textOverflow: "ellipsis",
                            whiteSpace: "nowrap"
                        })
                        .text(data.Code || data.Description)
                        .appendTo($content);
                }

                $content.appendTo($item);

                if (data.Status) {
                    const badgeClass = data.Status === "Active" ? "bg-success" : "bg-secondary";
                    $("<span>")
                        .addClass("badge " + badgeClass + " text-uppercase")
                        .css({
                            fontSize: "9px",
                            padding: "4px 8px",
                            letterSpacing: "0.5px",
                            flexShrink: "0"
                        })
                        .text(data.Status)
                        .appendTo($item);
                }

                setTimeout(() => {
                    $item.css({
                        opacity: "0",
                        transform: "translateX(-10px)"
                    }).animate({
                        opacity: 1
                    }, {
                        duration: 300,
                        step: function(now) {
                            $(this).css("transform", "translateX(" + (-10 + (now * 10)) + "px)");
                        },
                        delay: index * 30
                    });
                }, 10);

                return $item;
            },
            onOpened: function(e) {
                // Style dropdown
                $(e.component._popup.content()).parent()
                    .addClass("shadow-lg border rounded hpa-responsive")
                    .css({
                        borderRadius: "12px",
                        padding: "8px 0",
                        borderColor: "#dee2e6"
                    });
            },
            onFocusIn: function(e) {
                InstanceContractIDPBE8BE54C38914BAEA0646C9B6A1DD6A2.option("showClearButton", true);
            },
            onFocusOut: function(e) {
                InstanceContractIDPBE8BE54C38914BAEA0646C9B6A1DD6A2.option("showClearButton", false);
            },
            onKeyDown: function(e) {
                if (e.key === "Enter" || e.key === "Tab") {
                    InstanceContractIDPBE8BE54C38914BAEA0646C9B6A1DD6A2.option("showClearButton", false);
                }
            },
            onValueChanged: async function(e) {
                if (!e.event) return;

                // Feature: Check Instance AutoSave Flag
                if (_autoSaveContractIDPBE8BE54C38914BAEA0646C9B6A1DD6A2) {
                     // Nếu người dùng tìm kiếm rỗng và kết quả trả về là 0/empty/null (Copy from AutoSave mode)
                    if (e.value === "" || e.value == null || e.value === 0 || e.value === "0") {
                        InstanceContractIDPBE8BE54C38914BAEA0646C9B6A1DD6A2.option("value", _initialContractIDPBE8BE54C38914BAEA0646C9B6A1DD6A2);
                        return;
                    }

                    $("#PBE8BE54C38914BAEA0646C9B6A1DD6A2" + currentRecordID_Company_ID).find(".dx-texteditor-input").blur();
                    if (InstanceContractIDPBE8BE54C38914BAEA0646C9B6A1DD6A2 && InstanceContractIDPBE8BE54C38914BAEA0646C9B6A1DD6A2.blur) InstanceContractIDPBE8BE54C38914BAEA0646C9B6A1DD6A2.blur();

                    const $el = $(e.element);
                    $el.css({
                        transform: "scale(1.02)",
                        boxShadow: "0 0 0 3px rgba(28, 151, 94, 0.2)",
                        transition: "all 0.2s ease"
                    });
                    setTimeout(() => {
                        $el.css({ transform: "", boxShadow: "" });
                    }, 300);

                    if (typeof window["onSelectBoxChanged_ContractID"] === "function") {
                        window["onSelectBoxChanged_ContractID"](e.value, InstanceContractIDPBE8BE54C38914BAEA0646C9B6A1DD6A2, e);
                    }

                    const val = e.value;
                    const dataJSON = JSON.stringify(["1758526346", ["ContractID"], [val || ""]]);

             // Context-aware record IDs
                    let id1 = currentRecordID_ContracID;
                    if (typeof cellInfo !== "undefined" && cellInfo && cellInfo.data) {
                        id1 = cellInfo.data["ContracID"] || id1;
                    }
                    let currentRecordIDValue = [id1];
                    let currentRecordID = ["ContracID"];

                    if ("Company_ID" && "Company_ID".trim() !== "") {
                        let id2 = currentRecordID_Company_ID;
                        if (typeof cellInfo !== "undefined" && cellInfo && cellInfo.data) {
                            id2 = cellInfo.data["Company_ID"] || id2;
                        }
                        currentRecordIDValue.push(id2);
                        currentRecordID.push("Company_ID");
                    }
                    const idValsJSON = JSON.stringify([currentRecordIDValue, currentRecordID]);

                    try {
                        const json = await saveFunction(dataJSON, idValsJSON);
                        const dtError = json.data[json.data.length - 1] || [];
                        if (dtError.length > 0 && dtError[0].Status === "ERROR") {
                            if ("0" === "1") {
                                uiManager.showAlert({ type: "error", message: dtError[0]?.Message || "Lưu thất bại" });
                            }
                            InstanceContractIDPBE8BE54C38914BAEA0646C9B6A1DD6A2.option("value", _initialContractIDPBE8BE54C38914BAEA0646C9B6A1DD6A2);
                        } else {
                            if (typeof cellInfo !== "undefined" && cellInfo && cellInfo.component) {
                                try {
                                    const grid = cellInfo.component;
                                    grid.cellValue(cellInfo.rowIndex, "ContractID", val);
                                    grid.repaint();
                                } catch (syncErr) {
                                    console.warn("[Grid Sync] SelectBox ContractIDPBE8BE54C38914BAEA0646C9B6A1DD6A2: Không thể sync grid:", syncErr);
                                }
                            }
                            if ("0" === "1") {
                                uiManager.showAlert({ type: "success", message: "Lưu thành công" });
                            }
                            _initialContractIDPBE8BE54C38914BAEA0646C9B6A1DD6A2 = val;
                        }
                    } catch (err) {
                        if ("0" === "1") {
                            uiManager.showAlert({ type: "error", message: "Có lỗi xảy ra khi lưu" });
                        }
                        InstanceContractIDPBE8BE54C38914BAEA0646C9B6A1DD6A2.option("value", _initialContractIDPBE8BE54C38914BAEA0646C9B6A1DD6A2);
                        console.error("SelectBox Save Error:", err);
                    }
                    return;
                }

                // Normal Manual Mode Logic (No API)
                const $el = $(e.element);
                $el.css({
                    transform: "scale(1.02)",
                    boxShadow: "0 0 0 3px rgba(28, 151, 94, 0.2)",
                    transition: "all 0.2s ease"
                });
                setTimeout(() => {
                    $el.css({ transform: "", boxShadow: "" });
                }, 300);

                if (typeof window["onSelectBoxChanged_ContractID"] === "function") {
                    window["onSelectBoxChanged_ContractID"](e.value, InstanceContractIDPBE8BE54C38914BAEA0646C9B6A1DD6A2, e);
                }

                if (typeof cellInfo !== "undefined" && cellInfo && cellInfo.component) {
                    try {
                        const grid = cellInfo.component;
                        grid.cellValue(cellInfo.rowIndex, "ContractID", e.value);
                        grid.repaint();
                    } catch (syncErr) {
                        console.warn("[Grid Sync] Không thể sync grid:", syncErr);
                    }
                }
            }
        }).dxSelectBox("instance");

        let _initialContractIDPBE8BE54C38914BAEA0646C9B6A1DD6A2 = InstanceContractIDPBE8BE54C38914BAEA0646C9B6A1DD6A2.option("value");

        let InstanceStartDateP6F1F5081B8A146988DA1C280BACFF0FA = null;
        let StartDateTimeOut;
        let _autoSaveStartDateP6F1F5081B8A146988DA1C280BACFF0FA = false;
        let _readOnlyStartDateP6F1F5081B8A146988DA1C280BACFF0FA = false;

        async function DateboxSaveLogicStartDate() {
            let val = InstanceStartDateP6F1F5081B8A146988DA1C280BACFF0FA.option("value");
            let valToSave = val ? DevExpress.localization.formatDate(new Date(val), "yyyy/MM/dd") : null;
            const dataJSON = JSON.stringify(["1758526346", ["StartDate"], [valToSave]]);

            // Context-aware record IDs
            let id1 = currentRecordID_ContracID;
            if (typeof cellInfo !== "undefined" && cellInfo && cellInfo.data) {
                id1 = cellInfo.data["ContracID"] || id1;
            }
            let currentRecordIDValue = [id1];
            let currentRecordID = ["ContracID"];

            if ("Company_ID" && "Company_ID".trim() !== "") {
                let id2 = currentRecordID_Company_ID;
                if (typeof cellInfo !== "undefined" && cellInfo && cellInfo.data) {
                    id2 = cellInfo.data["Company_ID"] || id2;
                }
                currentRecordIDValue.push(id2);
                currentRecordID.push("Company_ID");
            }

            const idValsJSON = JSON.stringify([currentRecordIDValue, currentRecordID]);

            try {
                const json = await saveFunction(dataJSON, idValsJSON);
                const dtError = json.data[json.data.length - 1] || [];
                if (dtError.length > 0 && dtError[0].Status === "ERROR") {
                    if ("0" === "1") {
                        uiManager.showAlert({ type: "error", message: dtError[0]?.Message || "Lưu thất bại" });
                    }
                } else {
                    if ("0" === "1") {
                        uiManager.showAlert({ type: "success", message: "Lưu thành công" });
                    }
                }

                if (typeof cellInfo !== "undefined" && cellInfo && cellInfo.component) {
                    try {
                        const grid = cellInfo.component;
                        grid.cellValue(cellInfo.rowIndex, "StartDate", val);
                        grid.repaint();
                    } catch (syncErr) {
                        console.warn("[Grid Sync] DateBox StartDateP6F1F5081B8A146988DA1C280BACFF0FA: Error", syncErr);
                    }
                }
            } catch (err) {
                console.error("DateBox Save Error:", err);
            }
        }

        InstanceStartDateP6F1F5081B8A146988DA1C280BACFF0FA = $("#P6F1F5081B8A146988DA1C280BACFF0FA" + currentRecordID_Company_ID).dxDateBox({
            value: new Date(),
            type: "date",
            displayFormat: "dd/MM/yyyy",
            useMaskBehavior: true,
            openOnFieldClick: true,
            showClearButton: false,
            dateSerializationFormat: "yyyy-MM-dd",
            width: "100%",
            elementAttr: { class: "hpa-dx-datebox-inline" },
            readOnly: _readOnlyStartDateP6F1F5081B8A146988DA1C280BACFF0FA,
            onValueChanged: async (e) => {
                if (_autoSaveStartDateP6F1F5081B8A146988DA1C280BACFF0FA) {
                    clearTimeout(StartDateTimeOut);
                    e.event && await DateboxSaveLogicStartDate();
                } else {
                    if (typeof cellInfo !== "undefined" && cellInfo && cellInfo.component) {
            const grid = cellInfo.component;
                        grid.cellValue(cellInfo.rowIndex, "StartDate", e.value);
                    }
                }
            },
            onKeyUp: (e) => {
                if (_autoSaveStartDateP6F1F5081B8A146988DA1C280BACFF0FA) {
                    clearTimeout(StartDateTimeOut);
                    StartDateTimeOut = setTimeout(async () => DateboxSaveLogicStartDate(), 1000);
                }
            }
        }).dxDateBox("instance");

        let InstanceEndDateP6A9B5A5B2C704EF5A0C9CE949993E245 = null;
        let EndDateTimeOut;
        let _autoSaveEndDateP6A9B5A5B2C704EF5A0C9CE949993E245 = false;
        let _readOnlyEndDateP6A9B5A5B2C704EF5A0C9CE949993E245 = false;

        async function DateboxSaveLogicEndDate() {
            let val = InstanceEndDateP6A9B5A5B2C704EF5A0C9CE949993E245.option("value");
            let valToSave = val ? DevExpress.localization.formatDate(new Date(val), "yyyy/MM/dd") : null;
            const dataJSON = JSON.stringify(["1758526346", ["EndDate"], [valToSave]]);

            // Context-aware record IDs
            let id1 = currentRecordID_ContracID;
            if (typeof cellInfo !== "undefined" && cellInfo && cellInfo.data) {
                id1 = cellInfo.data["ContracID"] || id1;
            }
            let currentRecordIDValue = [id1];
            let currentRecordID = ["ContracID"];

            if ("Company_ID" && "Company_ID".trim() !== "") {
                let id2 = currentRecordID_Company_ID;
                if (typeof cellInfo !== "undefined" && cellInfo && cellInfo.data) {
                    id2 = cellInfo.data["Company_ID"] || id2;
                }
                currentRecordIDValue.push(id2);
                currentRecordID.push("Company_ID");
            }

            const idValsJSON = JSON.stringify([currentRecordIDValue, currentRecordID]);

            try {
                const json = await saveFunction(dataJSON, idValsJSON);
                const dtError = json.data[json.data.length - 1] || [];
                if (dtError.length > 0 && dtError[0].Status === "ERROR") {
                    if ("0" === "1") {
                        uiManager.showAlert({ type: "error", message: dtError[0]?.Message || "Lưu thất bại" });
                    }
                } else {
                    if ("0" === "1") {
                        uiManager.showAlert({ type: "success", message: "Lưu thành công" });
                    }
                }

                if (typeof cellInfo !== "undefined" && cellInfo && cellInfo.component) {
                    try {
                        const grid = cellInfo.component;
                        grid.cellValue(cellInfo.rowIndex, "EndDate", val);
                        grid.repaint();
                    } catch (syncErr) {
                        console.warn("[Grid Sync] DateBox EndDateP6A9B5A5B2C704EF5A0C9CE949993E245: Error", syncErr);
                    }
                }
            } catch (err) {
                console.error("DateBox Save Error:", err);
            }
        }

        InstanceEndDateP6A9B5A5B2C704EF5A0C9CE949993E245 = $("#P6A9B5A5B2C704EF5A0C9CE949993E245" + currentRecordID_Company_ID).dxDateBox({
            value: new Date(),
            type: "date",
            displayFormat: "dd/MM/yyyy",
            useMaskBehavior: true,
            openOnFieldClick: true,
            showClearButton: false,
            dateSerializationFormat: "yyyy-MM-dd",
            width: "100%",
            elementAttr: { class: "hpa-dx-datebox-inline" },
            readOnly: _readOnlyEndDateP6A9B5A5B2C704EF5A0C9CE949993E245,
            onValueChanged: async (e) => {
                if (_autoSaveEndDateP6A9B5A5B2C704EF5A0C9CE949993E245) {
                    clearTimeout(EndDateTimeOut);
                    e.event && await DateboxSaveLogicEndDate();
   } else {
                    if (typeof cellInfo !== "undefined" && cellInfo && cellInfo.component) {
                        const grid = cellInfo.component;
                        grid.cellValue(cellInfo.rowIndex, "EndDate", e.value);
                    }
                }
            },
            onKeyUp: (e) => {
                if (_autoSaveEndDateP6A9B5A5B2C704EF5A0C9CE949993E245) {
                    clearTimeout(EndDateTimeOut);
                    EndDateTimeOut = setTimeout(async () => DateboxSaveLogicEndDate(), 1000);
                }
            }
        }).dxDateBox("instance");

             window.currentRecordID_ContracID = null;

            // =============== GRID COLUMN CONFIG PERSISTENCE ===============
            function saveGridColumnConfig(tableName, columns) {
                const visibleColumns = columns
                    .filter(col => col.visible !== false && col.dataField)
                    .map(col => col.dataField);
                const columnOrder = columns
                    .filter(col => col.dataField)
                    .map(col => col.dataField);

                const config = { visibleColumns, columnOrder };

                AjaxHPAParadise({
                    data: {
                        name: "sp_SaveGridColumnConfig",
                        param: [
                            "LoginID", LoginID,
                            "TableName", tableName,
                            "ColumnConfigJson", JSON.stringify(config)
                        ]
                    }
                });
            }
            function loadGridColumnConfig(tableName, callback) {
                AjaxHPAParadise({
                    data: {
                        name: "sp_GetGridColumnConfig",
                        param: ["LoginID", LoginID, "TableName", tableName]
                    },
                    async: false,
                    success: function(res) {
                        let config = {};
                        try {
                            const json = typeof res === "string" ? JSON.parse(res) : res;
                            if (json.data[0][0].ColumnConfigJson) {
                                const raw = json.data[0][0].ColumnConfigJson;
                                config = typeof raw === "string" ? JSON.parse(raw) : raw;
                            }
                        } catch (e) {
                            console.warn("Failed to parse grid column config", e);
                        }
                        if (typeof callback === "function") callback(config);
                    }
                });
            }


            function ReloadData() {
                AjaxHPAParadise({
                    data: {
                        name: "sp_CRM_getConntracHistory",
                        param: []
                    },
                    success: function (res) {
                        const json = typeof res === "string" ? JSON.parse(res) : res;
                        const results = Array.isArray(json?.data?.[0])
                            ? json.data[0]
                            : (json?.data?.[0] ? [json.data[0]] : []);

                        const obj = results.length === 1 ? results[0] : (results[0] || null);


            // Xử lý cho grid layout
            const gridInstance = InstancegridContractHistoryP1D531D804E6F493BAF505C302A7A5760;
            const gridConfig = window.getGridConfig_gridContractHistory(results);

            gridInstance.beginUpdate();

            gridInstance.option("scrolling", {
                mode: "standard",
                showScrollbar: "onHover"
            });

            gridInstance.option("remoteOperations", false);  // Client-side cho <= 1000

            // Set paging config
            gridInstance.option("paging.enabled", true);
            gridInstance.option("paging.pageSize", gridConfig.pageSize);
            gridInstance.option("pager.allowedPageSizes", gridConfig.allowedPageSizes);
            gridInstance.pageIndex(0);

            gridInstance.option("dataSource", results);

            gridInstance.endUpdate();

                         if (obj) { window.currentRecordID_ContracID = (obj.ContracID !== undefined && obj.ContracID !== null) ? obj.ContracID : window.currentRecordID_ContracID; }
                        DataSource = results;

            // Smart Load: Check số dòng - nếu > 1000 thì dùng API, còn không thì load bình thường
            var spLoadDataGridName = "sp_getCompanyInfo";
            var isSmartLoadNeeded = false;

            // Kiểm tra xem có cần smart load hay không (chỉ cho các control có datasource)
            if (spLoadDataGridName && spLoadDataGridName.trim() !== "") {
                // Lấy data source từ window nếu đã load
                var dataSource = window["DataSource_Company_ID"];

                // Nếu chưa load hoặc dữ liệu trống, thì skip smart load cho lần này
                if (dataSource && Array.isArray(dataSource) && dataSource.length > 1000) {
                    isSmartLoadNeeded = true;
                }
            }

            // Nếu smart load, thì set flag để control sẽ tự động load qua API
            if (isSmartLoadNeeded) {
                window["UseAPILoad_Company_ID"] = true;
                return;
            }

            // Load bình thường (dữ liệu nhỏ <= 1000)
            InstanceCompany_IDP53E5F56DC72B4F08904E976C0EACEF0B._suppressValueChangeAction();
            InstanceCompany_IDP53E5F56DC72B4F08904E976C0EACEF0B.option("value", obj.Company_ID);
            InstanceCompany_IDP53E5F56DC72B4F08904E976C0EACEF0B._resumeValueChangeAction();

            // Smart Load: Check số dòng - nếu > 1000 thì dùng API, còn không thì load bình thường
            var spLoadDataGridName = "sp_CRM_getContractType";
            var isSmartLoadNeeded = false;

            // Kiểm tra xem có cần smart load hay không (chỉ cho các control có datasource)
            if (spLoadDataGridName && spLoadDataGridName.trim() !== "") {
                // Lấy data source từ window nếu đã load
                var dataSource = window["DataSource_ContractID"];

                // Nếu chưa load hoặc dữ liệu trống, thì skip smart load cho lần này
                if (dataSource && Array.isArray(dataSource) && dataSource.length > 1000) {
                    isSmartLoadNeeded = true;
                }
            }

            // Nếu smart load, thì set flag để control sẽ tự động load qua API
            if (isSmartLoadNeeded) {
                window["UseAPILoad_ContractID"] = true;
                return;
            }

            // Load bình thường (dữ liệu nhỏ <= 1000)
            InstanceContractIDPBE8BE54C38914BAEA0646C9B6A1DD6A2._suppressValueChangeAction();
            InstanceContractIDPBE8BE54C38914BAEA0646C9B6A1DD6A2.option("value", obj.ContractID);
            InstanceContractIDPBE8BE54C38914BAEA0646C9B6A1DD6A2._resumeValueChangeAction();

            // Smart Load: Check số dòng - nếu > 1000 thì dùng API, còn không thì load bình thường
            var spLoadDataGridName = "";
            var isSmartLoadNeeded = false;

            // Kiểm tra xem có cần smart load hay không (chỉ cho các control có datasource)
            if (spLoadDataGridName && spLoadDataGridName.trim() !== "") {
                // Lấy data source từ window nếu đã load
                var dataSource = window["DataSource_StartDate"];

                // Nếu chưa load hoặc dữ liệu trống, thì skip smart load cho lần này
                if (dataSource && Array.isArray(dataSource) && dataSource.length > 1000) {
                    isSmartLoadNeeded = true;
                }
            }

            // Nếu smart load, thì set flag để control sẽ tự động load qua API
            if (isSmartLoadNeeded) {
                window["UseAPILoad_StartDate"] = true;
                return;
            }

            // Load bình thường (dữ liệu nhỏ <= 1000)
            InstanceStartDateP6F1F5081B8A146988DA1C280BACFF0FA._suppressValueChangeAction();
            InstanceStartDateP6F1F5081B8A146988DA1C280BACFF0FA.option("value", obj.StartDate);
            InstanceStartDateP6F1F5081B8A146988DA1C280BACFF0FA._resumeValueChangeAction();

            // Smart Load: Check số dòng - nếu > 1000 thì dùng API, còn không thì load bình thường
            var spLoadDataGridName = "";
            var isSmartLoadNeeded = false;

            // Kiểm tra xem có cần smart load hay không (chỉ cho các control có datasource)
            if (spLoadDataGridName && spLoadDataGridName.trim() !== "") {
                // Lấy data source từ window nếu đã load
                var dataSource = window["DataSource_EndDate"];

                // Nếu chưa load hoặc dữ liệu trống, thì skip smart load cho lần này
                if (dataSource && Array.isArray(dataSource) && dataSource.length > 1000) {
                    isSmartLoadNeeded = true;
                }
            }

            // Nếu smart load, thì set flag để control sẽ tự động load qua API
            if (isSmartLoadNeeded) {
                window["UseAPILoad_EndDate"] = true;
                return;
            }

            // Load bình thường (dữ liệu nhỏ <= 1000)
            InstanceEndDateP6A9B5A5B2C704EF5A0C9CE949993E245._suppressValueChangeAction();
            InstanceEndDateP6A9B5A5B2C704EF5A0C9CE949993E245.option("value", obj.EndDate);
            InstanceEndDateP6A9B5A5B2C704EF5A0C9CE949993E245._resumeValueChangeAction();

                    }
                })
            }
            ReloadData()
        })();
    </script>

'
select @html html
--exec sp_GenerateHTMLScript_new 'sp_CRM_ContractHistory_html'
GO

sp_CRM_ContractHistory_html