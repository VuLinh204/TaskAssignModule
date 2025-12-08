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
            // Reusable Employee Selector Control
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
                    useApi: true,  // Load data từ API hay không
                    multi: true,   // Allow multiple selection
                    showAvatar: true,  // Show avatar chips
                    placeholder: "Chọn nhân viên",  // Placeholder text
                    apiData: null,  // Local data nếu không dùng API
                    pageSize: 10,   // Kích thước page cho API loading
                    take: 10,       // Số record tải lần đầu
                    skip: 0         // Offset record
                };
                
                const config = { ...defaults, ...options };
                const SVG_PLACEHOLDER = "data:image/svg+xml,%3Csvg xmlns=%22http://www.w3.org/2000/svg%22 viewBox=%220 0 100 100%22%3E%3Ccircle cx=%2250%22 cy=%2250%22 r=%2250%22 fill=%22%23e0e0e0%22/%3E%3C/svg%3E";
                const avatarCache = {};
                let allEmployees = [];
                let selectedIds = config.selectedIds;
                let dataGridInstance = null;
                let totalCount = 0;  // Tổng số record từ API
                let currentSkip = 0; // Track current offset
                let isLoadingApiData = false; // Flag để tránh load duplicate

                // Load employee list - Paged API loading (giống file test)
                function loadEmployeeList(skip, take) {
                    const deferred = $.Deferred();
                    
                    // Nếu có local data, sử dụng nó
                    if (config.apiData && Array.isArray(config.apiData)) {
                        allEmployees = config.apiData;
                        totalCount = allEmployees.length;
                        console.log("✓ [EmployeeSelector] Using LOCAL data (apiData config)", {
                            source: "apiData",
                            count: allEmployees.length,
                            data: allEmployees
                        });
                        deferred.resolve(allEmployees);
                        return deferred.promise();
                    }
                    
                    // Nếu không sử dụng API, return empty
                    if (!config.useApi) {
                        allEmployees = [];
                        totalCount = 0;
                        console.log("✓ [EmployeeSelector] No API loading (useApi=false)", {
                            source: "local",
                            useApi: false,
                            count: 0
                        });
                        deferred.resolve(allEmployees);
                        return deferred.promise();
                    }
                    
                    // Nếu đã load toàn bộ data, không cần load thêm
                    if (allEmployees.length >= totalCount && totalCount > 0) {
                        console.log(`✓ [EmployeeSelector] All data loaded (${allEmployees.length}/${totalCount} records)`);
                        deferred.resolve(allEmployees);
                        return deferred.promise();
                    }
                    
                    // Nếu đang load, chờ
                    if (isLoadingApiData) {
                        console.log("⏳ [EmployeeSelector] Loading in progress, waiting...");
                        // Vẫn resolve với data hiện tại để grid không bị block
                        deferred.resolve(allEmployees);
                        return deferred.promise();
                    }
                    
                    // Sử dụng API với paging
                    skip = skip || 0;
                    take = take || config.take;
                    isLoadingApiData = true;
                    
                    let extraparam = [];
                    extraparam.push("@ProcName");
                    extraparam.push(config.dataSource);
                    extraparam.push("@ProcParam");
                    extraparam.push(`@LoginID=${config.loginId},@LanguageID=''${config.languageId}''`);
                    
                    // Thêm paging params
                    extraparam.push("@Take");
                    extraparam.push(take);
                    extraparam.push("@Skip");
                    extraparam.push(skip);
                    
                    // Request tổng số record
                    extraparam.push("@RequireTotalCount");
                    extraparam.push(1);
                    
                    console.log("📡 [EmployeeSelector] Loading from API", {
                        dataSource: config.dataSource,
                        take: take,
                        skip: skip,
                        loginId: config.loginId,
                        languageId: config.languageId
                    });
                    
                    AjaxHPAParadise({
                        data: {
                            name: "sp_LoadGridUsingAPI",
                            param: extraparam
                        },
                        success: function (resultData) {
                            try {
                                let jsonData = typeof resultData === "string" ? JSON.parse(resultData) : resultData;
                                if (jsonData.reason == "error") throw new Error(jsonData.reason ?? "Lỗi bất thường");
                                
                                // Lấy dữ liệu từ bảng tạm (data[0])
                                const newData = (jsonData.data && jsonData.data[0]) ? jsonData.data[0] : [];
                                
                                // Merge với data cũ (tránh duplicate)
                                const existingIds = new Set(allEmployees.map(e => e.EmployeeID));
                                const uniqueNewData = newData.filter(e => !existingIds.has(e.EmployeeID));
                                allEmployees = [...allEmployees, ...uniqueNewData];
                                
                                // Lấy tổng số record từ data[1]
                                if (jsonData.data && jsonData.data[1] && jsonData.data[1][0]) {
                                    totalCount = jsonData.data[1][0].TotalCount || 0;
                                }
                                
                                currentSkip = skip;
                                isLoadingApiData = false;
                                
                                console.log("✓ [EmployeeSelector] API loaded successfully", {
                                    source: "API",
                                    dataSource: config.dataSource,
                                    newRecords: uniqueNewData.length,
                                    totalLoaded: allEmployees.length,
                                    totalCount: totalCount,
                                    skip: skip,
                                    take: take
                                });
                                
                                deferred.resolve(allEmployees);
                            } catch (error) {
                                isLoadingApiData = false;
                                console.error("✗ [EmployeeSelector] Error loading employee data:", error);
                                deferred.reject("Data Loading Error");
                            }
                        },
                        error: function (xhr, status, error) {
                            isLoadingApiData = false;
                            console.error("✗ [EmployeeSelector] API request failed:", {status, error});
                            deferred.reject("Data Loading Error");
                        }
                    });
                    return deferred.promise();
                }

                // Load single image
                function loadEmployeeImage(employee) {
                    if (!config.showAvatar || !employee.storeImgName || !employee.paramImg) {
                        return SVG_PLACEHOLDER;
                    }

                    const cacheKey = employee.EmployeeID;
                    
                    // Kiểm tra cache - nếu có rồi thì không load lại
                    if (avatarCache[cacheKey]) {
                        console.log(`✓ [Image] Cache HIT for employee ${cacheKey} (${employee.FullName})`);
                        return avatarCache[cacheKey];
                    }

                    try {
                        const decoded = decodeURIComponent(employee.paramImg);
                        const paramArray = JSON.parse(decoded);
                        
                        if (Array.isArray(paramArray) && paramArray.length > 1) {
                            console.log(`📡 [Image] Loading image for employee ${cacheKey} (${employee.FullName})`, {
                                storeImgName: employee.storeImgName,
                                params: paramArray
                            });
                            
                            AjaxHPAParadise({
                                data: {
                                    name: employee.storeImgName,
                                    param: paramArray
                                },
                                xhrFields: { responseType: "blob" },
                                cache: true,
                                success: function(blob) {
                                    if (blob && blob.size > 0) {
                                        try {
                                            const imgUrl = URL.createObjectURL(blob);
                                            avatarCache[cacheKey] = imgUrl;
                                            
                                            console.log(`✓ [Image] Cached successfully for employee ${cacheKey}`, {
                                                blobSize: blob.size,
                                                imageUrl: imgUrl.substring(0, 50) + "..."
                                            });
                                            
                                            // Update all chip images
                                            $(`#${config.containerId} .employee-selector-chip[data-emp-id="${cacheKey}"] img`).attr("src", imgUrl);
                                            $(`#${config.dropdownId} .grid-employee-image[data-emp-id="${cacheKey}"]`).attr("src", imgUrl);
                                            
                                            // Revoke after 5 minutes
                                            setTimeout(() => {
                                                URL.revokeObjectURL(imgUrl);
                                                delete avatarCache[cacheKey];
                                                console.log(`🗑 [Image] Cache cleared for employee ${cacheKey} (5min timeout)`);
                                            }, 5 * 60 * 1000);
                                        } catch(e) {
                                            console.error("Error creating object URL:", e);
                                        }
                                    }
                                }
                            });
                        }
                    } catch (e) {
                        console.error("Error loading image:", e);
                    }

                    return SVG_PLACEHOLDER;
                }

                // Helper: Get 2 letter initials from full name
                function getInitials(fullName) {
                    if (!fullName) return "?";
                    const words = fullName.trim().split(/\s+/);
                    if (words.length >= 2) {
                        return (words[0][0] + words[words.length - 1][0]).toUpperCase();
                    }
                    return (fullName.substring(0, 2)).toUpperCase();
                }
                
                // Render selector button
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
                            visibleEmps.forEach((emp, idx) => {
                                const imgUrl = avatarCache[emp.EmployeeID] || loadEmployeeImage(emp);
                                html += `
                                    <div class="employee-selector-chip" data-emp-id="${emp.EmployeeID}" title="${emp.FullName}">
                                        <img src="${imgUrl}" alt="${emp.FullName}" class="chip-avatar-img" />
                                    </div>
                                `;
                            });
                        } else {
                            // Show 2-letter initials chips when showAvatar=false
                            visibleEmps.forEach((emp, idx) => {
                                const initials = getInitials(emp.FullName);
                                html += `
                                    <div class="employee-selector-chip-text" data-emp-id="${emp.EmployeeID}" title="${emp.FullName}">
                                        ${initials}
                                    </div>
                                `;
                            });
                        }

                        if (selectedEmps.length > maxVisible) {
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
                    
                    // Attach click handler
                    $(`#${config.containerId} #employeeSelectorBtn`).off("click").on("click", function(e) {
                        e.stopPropagation();
                        toggleDropdown();
                    });
                    
                    // Preload images nếu showAvatar=true
                    if (config.showAvatar) {
                        selectedEmps.forEach(emp => {
                            if (!avatarCache[emp.EmployeeID] && emp.storeImgName && emp.paramImg) {
                                loadEmployeeImage(emp);
                            }
                        });
                    }
                }

                // Show/hide dropdown
                function toggleDropdown() {
                    const $dropdown = $(`#${config.dropdownId}`);
                    const isVisible = $dropdown.is(":visible");
                    
                    if (isVisible) {
                        $dropdown.hide();
                    } else {
                        $dropdown.show();
                        
                        // Nếu grid chưa tạo, tạo mới
                        if (!dataGridInstance) {
                            createDataGrid();
                        }
                        // Nếu đã có grid, chỉ focus input, không refresh (tránh load lại API)
                        
                        setTimeout(() => {
                            $(`#${config.dropdownId} #employeeSearchInput`).focus();
                        }, 100);
                    }
                }

                // Filter employees
                function filterEmployees(searchText) {
                    if (!dataGridInstance) return;
                    
                    const searchLower = searchText.toLowerCase().trim();
                    if (!searchLower) {
                        dataGridInstance.clearFilter();
                    } else {
                        dataGridInstance.filter(["FullName", "contains", searchLower]);
                    }
                }

                // Create DataGrid với infinite scroll
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
                    
                    // Tạo CustomStore để support infinite scroll
                    const gridStore = new DevExpress.data.CustomStore({
                        key: "EmployeeID",
                        load: function(loadOptions) {
                            const deferred = $.Deferred();
                            
                            const skip = (loadOptions.skip || 0);
                            const take = loadOptions.take || config.take;
                            
                            console.log(`📄 [Grid.load] skip=${skip}, take=${take}, cached=${allEmployees.length}/${totalCount}`);
                            
                            if (config.useApi && !config.apiData) {
                                // Tính API skip từ số records đã load
                                const apiSkip = allEmployees.length;
                                
                                // Nếu cần load thêm dữ liệu từ API
                                // Chỉ load nếu: chưa load bất kì record nào, hoặc còn record chưa load
                                const needLoadApi = allEmployees.length === 0 || (totalCount > 0 && allEmployees.length < totalCount);
                                
                                if (needLoadApi) {
                                    console.log(`📡 [Grid.load] Fetching from API: apiSkip=${apiSkip}, take=${take}, totalCount=${totalCount}`);
                                    
                                    // Gọi API từ vị trí hiện tại (tự động merge vào allEmployees)
                                    loadEmployeeList(apiSkip, take).then(() => {
                                        const sorted = getSortedEmployees();
                                        const pageData = sorted.slice(skip, skip + take);
                                        
                                        console.log(`✓ [Grid.load] Resolved: skip=${skip}, returning ${pageData.length} items from sorted ${sorted.length} total`);
                                        
                                        deferred.resolve({
                                            data: pageData,
                                            totalCount: totalCount
                                        });
                                    }).catch(err => {
                                        console.error("Error loading:", err);
                                        deferred.reject(err);
                                    });
                                } else {
                                    // Đã có dữ liệu, chỉ sort
                                    console.log(`✓ [Grid.load] Using cached data (${allEmployees.length} records)`);
                                    const sorted = getSortedEmployees();
                                    const pageData = sorted.slice(skip, skip + take);
                                    
                                    deferred.resolve({
                                        data: pageData,
                                        totalCount: totalCount || allEmployees.length
                                    });
                                }
                            } else {
                                // Local data
                                const sorted = getSortedEmployees();
                                const pageData = sorted.slice(skip, skip + take);
                                
                                deferred.resolve({
                                    data: pageData,
                                    totalCount: allEmployees.length
                                });
                            }
                            
                            return deferred.promise();
                        }
                    });
                    
                    // Helper function: Sort employees (selected lên đầu)
                    function getSortedEmployees() {
                        return [...allEmployees].sort((a, b) => {
                            const aSelected = selectedIds.includes(String(a.EmployeeID));
                            const bSelected = selectedIds.includes(String(b.EmployeeID));
                            
                            // Nhân viên được chọn lên trước
                            if (aSelected && !bSelected) return -1;
                            if (!aSelected && bSelected) return 1;
                            
                            return 0;
                        });
                    }
                    
                    const gridColumns = [{
                        type: "selection",
                        width: 40,
                        alignment: "center"
                    }];
                    
                    // Thêm avatar column nếu showAvatar=true
                    if (config.showAvatar) {
                        gridColumns.push({
                            dataField: "storeImgName",
                            caption: "Avatar",
                            width: 60,
                            cellTemplate(container, options) {
                                const emp = options.data;
                                // Kiểm tra cache trước - nếu có rồi thì dùng cache, không load lại
                                let imgUrl = avatarCache[emp.EmployeeID];
                                if (!imgUrl) {
                                    imgUrl = loadEmployeeImage(emp);
                                }
                                const $img = $(`<img class="grid-employee-image" data-emp-id="${emp.EmployeeID}" src="${imgUrl}" alt="${emp.FullName}" style="width:32px;height:32px;border-radius:50%;object-fit:cover;" />`);
                                container.html($img);
                            }
                        });
                    }
                    
                    gridColumns.push({
                        dataField: "FullName",
                        caption: "Tên nhân viên",
                        width: "auto"
                    });
                    
                    const gridConfig = {
                        dataSource: gridStore,
                        keyExpr: "EmployeeID",
                        columns: gridColumns,
                        remoteOperations: true,  // ← Quan trọng: cho phép grid tự động gọi load khi scroll
                        paging: { 
                            enabled: true, 
                            pageSize: config.take
                        },
                        scrolling: { mode: "virtual" },  // ← Virtual scroll sẽ trigger load() tự động
                        height: 345,
                        selection: { 
                            mode: config.multi ? "multiple" : "single", 
                            selectAllMode: config.multi ? "allPages" : "page" 
                        },
                        selectedRowKeys: selectedIds,
                        onSelectionChanged(selectedItems) {
                            selectedIds = config.multi ? selectedItems.selectedRowKeys : [selectedItems.selectedRowKeys[0]];
                            if (config.onChange) config.onChange(selectedIds);
                            renderSelectorButton();
                            
                            // Refresh grid để sắp xếp lại theo selected employees
                            setTimeout(() => {
                                if (dataGridInstance) {
                                    dataGridInstance.refresh();
                                }
                            }, 50);
                        }
                    };
                    
                    $(`#${config.dropdownId} #employeeGridInner`).dxDataGrid(gridConfig);
                    dataGridInstance = $(`#${config.dropdownId} #employeeGridInner`).dxDataGrid("instance");
                    
                    // Refresh grid khi selection thay đổi để update sort order
                    const originalOnSelectionChanged = gridConfig.onSelectionChanged;
                    const refreshGrid = () => {
                        setTimeout(() => {
                            if (dataGridInstance) {
                                dataGridInstance.refresh();
                            }
                        }, 100);
                    };
                    
                    // Set selection
                    setTimeout(() => {
                        if (dataGridInstance) {
                            dataGridInstance.selectRows(selectedIds);
                            // Scroll to top to show selected employees
                            dataGridInstance.navigateToRow(0);
                        }
                    }, 100);
                    
                    // Search handler
                    $(`#${config.dropdownId} #employeeSearchInput`).off("keyup").on("keyup", function() {
                        filterEmployees($(this).val());
                    });
                }

                // Close on outside click
                $(document).off("click.employeeSelector").on("click.employeeSelector", function(e) {
                    if (!$(e.target).closest(`#${config.containerId}, #${config.dropdownId}`).length) {
                        $(`#${config.dropdownId}`).hide();
                    }
                });

                // Initialize
                // Chỉ load lần đầu nếu cần (dùng API)
                if (config.useApi && !config.apiData) {
                    loadEmployeeList(0, config.take).then(() => {
                        renderSelectorButton();
                    });
                } else {
                    renderSelectorButton();
                }
                
                // Return public API
                return {
                    getSelectedIds: () => selectedIds,
                    setSelectedIds: (ids) => {
                        selectedIds = ids;
                        renderSelectorButton();
                    }
                };
            }

            // Initialize the control
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