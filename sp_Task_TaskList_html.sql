USE Paradise_Beta_Tai2
GO
if object_id('[dbo].[sp_Task_TaskList_html]') is null
	EXEC ('CREATE PROCEDURE [dbo].[sp_Task_TaskList_html] as select 1')
GO

    ALTER PROCEDURE [dbo].[sp_Task_TaskList_html]
        @LoginID INT = 3,
        @LanguageID VARCHAR(2) = 'VN',
        @isWeb INT = 1
    AS
    BEGIN
        set noCount on;
    declare @html nVarchar(max) =N'';
    set @html += N'
    <div class="demo-container" style="position: relative;">
        <div id="employeeSelector" style="margin-bottom: 8px;"></div>
        <div id="employeeDropdownGrid" style="display:none; position:absolute; z-index:1000; top: 100%; left: 0;"></div>
    </div>
    <style>
        .demo-container {
            position: relative;
            display: inline-block;
        }
        .employee-cell {
            display: flex;
            align-items: center;
            gap: 8px;
        }
        .employee-image {
            width: 32px;
            height: 32px;
            border-radius: 50%;
            object-fit: cover;
            border: 2px solid white;
            box-shadow: 0 2px 4px rgba(0,0,0,0.1);
        }
        .employee-name {
            font-weight: 500;
        }
        
        /* Employee Selector Control Style - giống hpaControlEmployeeSelector */
        .employee-selector-wrapper {
            position: relative;
            display: inline-block;
            width: auto;
        }
        
        .employee-selector-btn {
            display: inline-flex;
            align-items: center;
            gap: 6px;
            padding: 6px 12px;
            border: 1px solid #dee2e6;
            border-radius: 4px;
            cursor: pointer;
            transition: all 0.2s;
            font-size: 13px;
            white-space: nowrap;
            position: relative;
            z-index: 100;
        }
        
        .employee-selector-btn:hover {
            border-color: #adb5bd;
        }
        
        .employee-selector-chips {
            display: flex;
            align-items: center;
            gap: 0;
            margin-right: 8px;
        }
        
        .employee-selector-chip {
            width: 28px;
            height: 28px;
            border-radius: 50%;
            overflow: hidden;
            flex-shrink: 0;
            border: 2px solid white;
            box-shadow: 0 2px 4px rgba(0,0,0,0.12);
            margin-left: -8px;
            transition: all 0.2s;
        }
        
        .employee-selector-chip:first-child {
            margin-left: 0;
        }
        
        .employee-selector-chip:hover {
            transform: scale(1.1);
            z-index: 10;
        }
        
        .employee-selector-chip img {
            width: 100%;
            height: 100%;
            object-fit: cover;
        }
        
        .employee-selector-chip-text {
            width: 28px;
            height: 28px;
            border-radius: 50%;
            overflow: hidden;
            flex-shrink: 0;
            border: 2px solid white;
            box-shadow: 0 2px 4px rgba(0,0,0,0.12);
            margin-left: -8px;
            transition: all 0.2s;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 11px;
            font-weight: 600;
        }
        
        .employee-selector-chip-text:first-child {
            margin-left: 0;
        }
        
        .employee-selector-chip-text:hover {
            transform: scale(1.1);
            z-index: 10;
        }
        
        .employee-selector-count {
            font-weight: 600;
            color: #495057;
        }
        
        .employee-selector-icon {
            margin-left: 4px;
            color: #6c757d;
        }
        
        /* Dropdown Grid */
        #employeeDropdownGrid {
            border: 1px solid #dee2e6;
            border-radius: 4px;
            box-shadow: 0 4px 12px rgba(0,0,0,0.15);
            overflow: hidden;
            width: 300px;
        }
        
        .employee-dropdown-header {
            padding: 12px;
            border-bottom: 1px solid #dee2e6;
        }
        
        .employee-dropdown-search {
            width: 100%;
            padding: 8px 12px;
            border: 1px solid #dee2e6;
            border-radius: 4px;
            font-size: 13px;
            outline: none;
        }
        
        .employee-dropdown-search:focus {
            border-color: #2E7D32;
            box-shadow: 0 0 0 3px rgba(46, 125, 50, 0.1);
        }
        
        .employee-dropdown-body {
            max-height: 400px;
            overflow-y: auto;
        }
        
        #employeeGridInner {
            width: 100% !important;
        }
        
        #employeeDropdownGrid .dx-datagrid {
            border: none !important;
        }
        
        #employeeDropdownGrid .dx-datagrid-headers {
            border-bottom: 1px solid #dee2e6;
        }
        
        #employeeDropdownGrid .dx-checkbox {
            margin: 0;
        }
        
        .grid-employee-cell {
            display: flex !important;
            align-items: center;
            gap: 8px;
            padding: 4px 0;
        }
        
        .grid-employee-image {
            width: 28px;
            height: 28px;
            border-radius: 50%;
            object-fit: cover;
            flex-shrink: 0;
        }
        
        .selected-count {
            margin-left: auto;
            font-size: 12px;
            color: #676879;
            font-weight: 600;
        }
    </style>
    <script>
        $(() => {
            function hpaControlEmployeeSelector(options) {
                const defaults = {
                    containerId: "employeeSelector",
                    dropdownId: "employeeDropdownGrid",
                    dataSource: "EmployeeListAll_DataSetting_Custom",
                    loginId: 3,
                    languageId: "VN",
                    selectedIds: [],
                    maxVisibleChips: 3,
                    onChange: null,
                    useApi: true,
                    multi: true,
                    showAvatar: true,
                    placeholder: "Chọn nhân viên",
                    apiData: null,
                    pageSize: 10,
                    take: 10,
                    skip: 0
                };
                const config = { ...defaults, ...options };
                const SVG_PLACEHOLDER = "data:image/svg+xml,%3Csvg xmlns=%22http://www.w3.org/2000/svg%22 viewBox=%220 0 10 hpaControlEmployeeSelector0%22%3E%3Ccircle cx=%2250%22 cy=%2250%22 r=%2250%22 fill=%22%23e0e0e0%22/%3E%3C/svg%3E";
                const avatarCache = {};
                let allEmployees = [];
                let selectedIds = config.selectedIds;
                let dataGridInstance = null;
                let totalCount = 0;
                let currentSkip = 0;
                let isLoadingApiData = false;
                let currentSearchText = "";
                let snapshotEmployees = [];
                let isGridInitializing = true;

                function loadEmployeeList(skip, take) {
                    const deferred = $.Deferred();
                    if (config.apiData && Array.isArray(config.apiData)) {
                        allEmployees = config.apiData;
                        totalCount = allEmployees.length;
                        deferred.resolve(allEmployees);
                        return deferred.promise();
                    }
                    if (!config.useApi) {
                        allEmployees = [];
                        totalCount = 0;
                        deferred.resolve(allEmployees);
                        return deferred.promise();
                    }
                    if (allEmployees.length >= totalCount && totalCount > 0) {
                        deferred.resolve(allEmployees);
                        return deferred.promise();
                    }
                    if (isLoadingApiData) {
                        deferred.resolve(allEmployees);
                        return deferred.promise();
                    }

                    skip = skip || 0;
                    take = take || config.take;
                    isLoadingApiData = true;
                    let extraparam = [];
                    extraparam.push("@ProcName");
                    extraparam.push(config.dataSource);
                    extraparam.push("@ProcParam");
                    extraparam.push(`@LoginID=${config.loginId},@LanguageID=''${config.languageId}''`);
                    extraparam.push("@Take");
                    extraparam.push(take);
                    extraparam.push("@Skip");
                    extraparam.push(skip);
                    extraparam.push("@RequireTotalCount");
                    extraparam.push(1);

                    AjaxHPAParadise({
                        data: {
                            name: "sp_LoadGridUsingAPI",
                            param: extraparam
                        },
                        success: function (resultData) {
                            try {
                                let jsonData = typeof resultData === "string" ? JSON.parse(resultData) : resultData;
                                if (jsonData.reason == "error") throw new Error("Data error");
                                const newData = (jsonData.data && jsonData.data[0]) ? jsonData.data[0] : [];
                                const existingIds = new Set(allEmployees.map(e => e.EmployeeID));
                                const uniqueNewData = newData.filter(e => !existingIds.has(e.EmployeeID));
                                allEmployees = [...allEmployees, ...uniqueNewData];
                                if (jsonData.data && jsonData.data[1] && jsonData.data[1][0]) {
                                    totalCount = jsonData.data[1][0].TotalCount || 0;
                                }
                                currentSkip = skip;
                                isLoadingApiData = false;
                                deferred.resolve(allEmployees);
                            } catch (error) {
                                isLoadingApiData = false;
                                deferred.reject("Data Loading Error");
                            }
                        },
                        error: function () {
                            isLoadingApiData = false;
                            deferred.reject("Data Loading Error");
                        }
                    });
                    return deferred.promise();
                }

                function loadEmployeeImage(employee) {
                    if (!config.showAvatar || !employee.storeImgName || !employee.paramImg) {
                        return SVG_PLACEHOLDER;
                    }
                    const cacheKey = employee.EmployeeID;
                    if (avatarCache[cacheKey]) {
                        return avatarCache[cacheKey];
                    }
                    try {
                        const decoded = decodeURIComponent(employee.paramImg);
                        const paramArray = JSON.parse(decoded);
                        if (Array.isArray(paramArray) && paramArray.length > 1) {
                            AjaxHPAParadise({
                                data: {
                                    name: employee.storeImgName,
                                    param: paramArray
                                },
                                xhrFields: { responseType: "blob" },
                                cache: true,
                                success: function(blob) {
                                    if (blob && blob.size > 0) {
                                        const imgUrl = URL.createObjectURL(blob);
                                        avatarCache[cacheKey] = imgUrl;
                                        $(`#${config.containerId} .employee-selector-chip[data-emp-id="${cacheKey}"] img`).attr("src", imgUrl);
                                        $(`#${config.dropdownId} .grid-employee-image[data-emp-id="${cacheKey}"]`).attr("src", imgUrl);
                                        setTimeout(() => {
                                            URL.revokeObjectURL(imgUrl);
                                            delete avatarCache[cacheKey];
                                        }, 300000);
                                    }
                                }
                            });
                        }
                    } catch (e) {}
                    return SVG_PLACEHOLDER;
                }

                function getInitials(fullName) {
                    if (!fullName) return "?";
                    const words = fullName.trim().split(/\s+/);
                    if (words.length >= 2) {
                        return (words[0][0] + words[words.length - 1][0]).toUpperCase();
                    }
                    return (fullName.substring(0, 2)).toUpperCase();
                }

                function renderSelectorButton() {
                    let html = `
                        <div class="employee-selector-wrapper">
                            <button type="button" class="employee-selector-btn" id="employeeSelectorBtn">
                                <div class="employee-selector-chips">
                    `;
                    const selectedEmps = selectedIds
                        .map(id => allEmployees.find(e => String(e.EmployeeID) === String(id)))
                        .filter(e => e);
                    const maxVisible = config.maxVisibleChips;
                    const visibleEmps = selectedEmps.slice(0, maxVisible);
                    const remainingCount = selectedEmps.length - maxVisible;

                    if (selectedEmps.length === 0) {
                        html += `<span class="employee-selector-count">${config.placeholder}</span>`;
                    } else {
                        if (config.showAvatar) {
                            visibleEmps.forEach(emp => {
                                const imgUrl = avatarCache[emp.EmployeeID] || loadEmployeeImage(emp);
                                html += `
                                    <div class="employee-selector-chip" data-emp-id="${emp.EmployeeID}" title="${emp.FullName}">
                                        <img src="${imgUrl}" alt="${emp.FullName}" />
                                    </div>
                                `;
                            });
                        } else {
                            visibleEmps.forEach(emp => {
                                const initials = getInitials(emp.FullName);
                                html += `
                                    <div class="employee-selector-chip-text" data-emp-id="${emp.EmployeeID}" title="${emp.FullName}">
                                        ${initials}
                                    </div>
                                `;
                            });
                        }
                        if (remainingCount > 0) {
                            html += `<span class="employee-selector-count">+${remainingCount}</span>`;
                        }
                    }
                    html += `
                                </div>
                                <span class="employee-selector-icon">▼</span>
                            </button>
                        </div>
                    `;
                    $(`#${config.containerId}`).html(html);
                    $(`#${config.containerId} #employeeSelectorBtn`).off("click").on("click", function(e) {
                        e.stopPropagation();
                        toggleDropdown();
                    });
                    if (config.showAvatar) {
                        selectedEmps.forEach(emp => {
                            if (!avatarCache[emp.EmployeeID] && emp.storeImgName && emp.paramImg) {
                                loadEmployeeImage(emp);
                            }
                        });
                    }
                }

                function toggleDropdown() {
                    const $dropdown = $(`#${config.dropdownId}`);
                    const isVisible = $dropdown.is(":visible");
                    if (isVisible) {
                        $dropdown.hide();
                    } else {
                        $dropdown.show();
                        if (!dataGridInstance) {
                            loadEmployeeList(0, config.take).then(() => {
                                createDataGrid();
                            });
                        }
                        setTimeout(() => {
                            $(`#${config.dropdownId} #employeeSearchInput`).focus();
                        }, 100);
                    }
                }

                function filterEmployees(searchText) {
                    if (!dataGridInstance || isGridInitializing) return;
                    currentSearchText = searchText.trim();
                    if (currentSearchText) {
                        const searchLower = currentSearchText.toLowerCase();
                        dataGridInstance.filter(["FullName", "contains", searchLower]);
                    } else {
                        dataGridInstance.clearFilter();
                    }
                    setTimeout(() => {
                        if (dataGridInstance) {
                            dataGridInstance.beginUpdate();
                            dataGridInstance.getDataSource().reload();
                            dataGridInstance.endUpdate();
                        }
                    }, 50);
                }

                function createDataGrid() {
                    const html = `
                        <div class="employee-dropdown-header">
                            <input type="text" id="employeeSearchInput" class="employee-dropdown-search" placeholder="Tìm..." />
                        </div>
                        <div class="employee-dropdown-body">
                            <div id="employeeGridInner"></div>
                        </div>
                    `;
                    $(`#${config.dropdownId}`).html(html);

                    if (snapshotEmployees.length === 0 && allEmployees.length > 0) {
                        snapshotEmployees = getSortedEmployees();
                    }

                    const gridStore = new DevExpress.data.CustomStore({
                        key: "EmployeeID",
                        load: function(loadOptions) {
                            const deferred = $.Deferred();
                            const skip = loadOptions.skip || 0;
                            const take = loadOptions.take || config.take;
                            let gridData = getGridData();
                            const needsMoreData = (skip + take) > gridData.length && allEmployees.length < totalCount;
                            if (needsMoreData && !isLoadingApiData) {
                                const apiSkip = allEmployees.length;
                                loadEmployeeList(apiSkip, config.take).then(() => {
                                    snapshotEmployees = getSortedEmployees();
                                    gridData = snapshotEmployees;
                                    const pageData = gridData.slice(skip, skip + take);
                                    const finalTotalCount = totalCount > 0 ? totalCount : gridData.length;
                                    deferred.resolve({ data: pageData, totalCount: finalTotalCount });
                                }).catch(err => deferred.reject(err));
                                return deferred.promise();
                            }
                            const pageData = gridData.slice(skip, skip + take);
                            const finalTotalCount = totalCount > 0 ? totalCount : gridData.length;
                            deferred.resolve({ data: pageData, totalCount: finalTotalCount });
                            return deferred.promise();
                        }
                    });

                    function getSortedEmployees() {
                        let data = [...allEmployees];
                        if (currentSearchText.trim()) {
                            const searchLower = currentSearchText.toLowerCase().trim();
                            data = data.filter(emp => emp.FullName && emp.FullName.toLowerCase().includes(searchLower));
                        }
                        return data.sort((a, b) => {
                            const aSelected = selectedIds.includes(String(a.EmployeeID));
                            const bSelected = selectedIds.includes(String(b.EmployeeID));
                            if (aSelected && !bSelected) return -1;
                            if (!aSelected && bSelected) return 1;
                            return 0;
                        });
                    }

                    function getGridData() {
                        if (currentSearchText.trim()) {
                            return getSortedEmployees();
                        }
                        if (snapshotEmployees.length > 0) {
                            return snapshotEmployees;
                        }
                        return getSortedEmployees();
                    }

                    const gridColumns = [{ type: "selection", width: 40, alignment: "center" }];

                    if (config.showAvatar) {
                        gridColumns.push({
                            dataField: "storeImgName",
                            caption: "Avatar",
                            width: 60,
                            cellTemplate: function(container, options) {
                                const emp = options.data;
                                let imgUrl = avatarCache[emp.EmployeeID] || loadEmployeeImage(emp);
                                const $img = $(`<img class="grid-employee-image" data-emp-id="${emp.EmployeeID}" src="${imgUrl}" alt="${emp.FullName}" style="width:32px;height:32px;border-radius:50%;object-fit:cover;" />`);
                                container.html($img);
                            }
                        });
                    }

                    gridColumns.push({ dataField: "FullName", caption: "Tên nhân viên", width: "auto" });

                    const gridConfig = {
                        dataSource: gridStore,
                        keyExpr: "EmployeeID",
                        columns: gridColumns,
                        remoteOperations: true,
                        paging: { enabled: true, pageSize: config.take },
                        scrolling: { mode: "virtual" },
                        height: 345,
                        selection: { 
                            mode: config.multi ? "multiple" : "single", 
                            selectAllMode: config.multi ? "allPages" : "page" 
                        },
                        selectedRowKeys: selectedIds,
                        onSelectionChanged: function(selectedItems) {
                            const newSelectedIds = config.multi ? selectedItems.selectedRowKeys : [selectedItems.selectedRowKeys[0]];
                            const hasChanged = JSON.stringify([...selectedIds].sort()) !== JSON.stringify([...newSelectedIds].sort());
                            if (!hasChanged) return;
                            selectedIds = newSelectedIds;
                            if (config.onChange) config.onChange(selectedIds);
                            snapshotEmployees = getSortedEmployees();
                            if (currentSearchText) {
                                currentSearchText = "";
                                $(`#${config.dropdownId} #employeeSearchInput`).val("");
                            }
                            setTimeout(() => {
                                if (dataGridInstance) {
                                    dataGridInstance.beginUpdate();
                                    dataGridInstance.getDataSource().reload();
                                    dataGridInstance.endUpdate();
                                    renderSelectorButton();
                                }
                            }, 50);
                        }
                    };

                    $(`#${config.dropdownId} #employeeGridInner`).dxDataGrid(gridConfig);
                    dataGridInstance = $(`#${config.dropdownId} #employeeGridInner`).dxDataGrid("instance");

                    setTimeout(() => {
                        if (dataGridInstance) {
                            const foundSelectedEmps = selectedIds.filter(id => 
                                allEmployees.some(e => String(e.EmployeeID) === String(id))
                            );
                            if (foundSelectedEmps.length > 0) {
                                dataGridInstance.option("selectedRowKeys", foundSelectedEmps);
                            }
                        }
                    }, 100);

                    $(`#${config.dropdownId} #employeeSearchInput`).off("keyup").on("keyup", function() {
                        filterEmployees($(this).val());
                    });

                    setTimeout(() => {
                        isGridInitializing = false;
                    }, 100);

                    $(`#${config.dropdownId} .employee-dropdown-body`).off("scroll").on("scroll", function() {
                        const scrollTop = $(this).scrollTop();
                        const scrollHeight = this.scrollHeight;
                        const clientHeight = this.clientHeight;
                        const distanceFromBottom = scrollHeight - (scrollTop + clientHeight);
                        if (distanceFromBottom < 100 && allEmployees.length < totalCount && !isLoadingApiData) {
                            const apiSkip = allEmployees.length;
                            loadEmployeeList(apiSkip, config.take).then(() => {
                                snapshotEmployees = getSortedEmployees();
                                if (dataGridInstance) {
                                    dataGridInstance.beginUpdate();
                                    dataGridInstance.getDataSource().reload();
                                    dataGridInstance.endUpdate();
                                }
                            });
                        }
                    });
                }

                $(document).off("click.employeeSelector").on("click.employeeSelector", function(e) {
                    if (!$(e.target).closest(`#${config.containerId}, #${config.dropdownId}`).length) {
                        $(`#${config.dropdownId}`).hide();
                    }
                });

                renderSelectorButton();
                if (config.useApi && !config.apiData) {
                    loadEmployeeList(0, config.take).then(() => {
                        renderSelectorButton();
                    });
                }

                return {
                    getSelectedIds: () => selectedIds,
                    setSelectedIds: (ids) => {
                        selectedIds = ids;
                        renderSelectorButton();
                    }
                };
            }

            window.employeeSelector = hpaControlEmployeeSelector({
                containerId: "employeeSelector",
                dropdownId: "employeeDropdownGrid",
                selectedIds: ["044", "045", "046"],
                onChange: (selectedIds) => {
                    console.log("Selected employees changed:", selectedIds);
                }
            });
        });
    </script>
    ';
        SELECT @html AS html;
        -- EXEC sp_GenerateHTMLScript 'sp_Task_TaskList_html'
    END
GO

EXEC sp_GenerateHTMLScript 'sp_Task_TaskList_html'