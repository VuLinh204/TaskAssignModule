GO
IF OBJECT_ID('[dbo].[sp_hpaControlSelectEmployee]') IS NULL
    EXEC ('CREATE PROCEDURE [dbo].[sp_hpaControlSelectEmployee] AS SELECT 1')
GO

ALTER PROCEDURE [dbo].[sp_hpaControlSelectEmployee]
    @TableName VARCHAR(256) = ''
AS
BEGIN

    -- =============================================
    -- 1. READONLY MODE
    -- =============================================
    UPDATE #temptable SET
        loadUI = N'
            window.GlobalEmployeeAvatarCache = window.GlobalEmployeeAvatarCache || {};
            window.GlobalEmployeeAvatarLoading = window.GlobalEmployeeAvatarLoading || {};
            let Instance%ColumnName%%UID% = {};

            function loadGlobalAvatarIfNeeded%ColumnName%%UID%(employeeId, storeImgName, paramImg, callbackFn) {
                const idStr = String(employeeId);

                if (window.GlobalEmployeeAvatarCache[idStr]) {
                    if (callbackFn) callbackFn(window.GlobalEmployeeAvatarCache[idStr]);
                    return window.GlobalEmployeeAvatarCache[idStr];
                }

                if (window.GlobalEmployeeAvatarLoading[idStr]) {
                    if (callbackFn) {
                        window.GlobalEmployeeAvatarLoading[idStr].callbacks = 
                            window.GlobalEmployeeAvatarLoading[idStr].callbacks || [];
                        window.GlobalEmployeeAvatarLoading[idStr].callbacks.push(callbackFn);
                    }
                    return null;
                }

                if (!storeImgName) {
                    return null;
                }

                window.GlobalEmployeeAvatarLoading[idStr] = {
                    loading: true,
                    callbacks: callbackFn ? [callbackFn] : []
                };

                let paramArray = [];
                if (paramImg) {
                    try {
                        const decoded = decodeURIComponent(paramImg);
                        paramArray = JSON.parse(decoded);
                    } catch (e) {
                        paramArray = [];
                    }
                }

                AjaxHPAParadise({
                    data: {
                        name: storeImgName,
                        param: paramArray
                    },
                    xhrFields: { responseType: "blob" },
                    cache: true,
                    success: function (blob) {
                        const callbacks = window.GlobalEmployeeAvatarLoading[idStr]?.callbacks || [];
                        delete window.GlobalEmployeeAvatarLoading[idStr];

                        if (blob && blob.size > 0) {
                            const url = URL.createObjectURL(blob);
                            window.GlobalEmployeeAvatarCache[idStr] = url;
                            
                            callbacks.forEach(cb => {
                                try { cb(url); } catch (e) { console.error(e); }
                            });
                        } else {
                            callbacks.forEach(cb => {
                                try { cb(null); } catch (e) { console.error(e); }
                            });
                        }
                    },
                    error: function () {
                        const callbacks = window.GlobalEmployeeAvatarLoading[idStr]?.callbacks || [];
                        delete window.GlobalEmployeeAvatarLoading[idStr];
                        
                        callbacks.forEach(cb => {
                            try { cb(null); } catch (e) { console.error(e); }
                        });
                    }
                });

                return null;
            }

            window["DataSource_%ColumnName%"] = window["DataSource_%ColumnName%"] || [];
            let spNameDSE%ColumnName%%UID% = "%DataSourceSP%";
            let %ColumnName%%UID%DataSourceLoaded = false;

            let %ColumnName%%UID%SelectedIds = [];
            const MAX_VISIBLE_%ColumnName% = 3;

            // Sử dụng hàm loadDataSourceCommon từ sptblCommonControlType_Signed
            if (spNameDSE%ColumnName%%UID% && spNameDSE%ColumnName%%UID%.trim() !== "") {
                loadDataSourceCommon("%ColumnName%", spNameDSE%ColumnName%%UID%, function(data) {
                    window["DataSource_%ColumnName%"] = data || [];
                    // Bắt đầu load ảnh cho tất cả nhân viên
                    if (Array.isArray(data) && data.length > 0) {
                        data.forEach(emp => {
                            if (emp.ID && emp.StoreImgName) {
                                loadGlobalAvatarIfNeeded%ColumnName%%UID%(emp.ID, emp.StoreImgName, emp.ImgParamV);
                            }
                        });
                    }
                    // Gọi render một lần duy nhất từ callback
                    if (typeof renderDisplay%ColumnName% === "function") {
                        renderDisplay%ColumnName%();
                    }
                });
            }

            function getInitials%ColumnName%(name) {
                if (!name) return "?";
                const words = name.trim().split(/\s+/);
                if (words.length >= 2) return (words[0][0] + words[words.length - 1][0]).toUpperCase();
                return name.substring(0, 2).toUpperCase();
            }

            function getColorForId%ColumnName%(id) {
                const colors = [
                    { bg: "#e3f2fd", text: "#1976d2" },
                    { bg: "#f3e5f5", text: "#7b1fa2" },
                    { bg: "#e8f5e9", text: "#388e3c" },
                    { bg: "#fff3e0", text: "#f57c00" },
                    { bg: "#fce4ec", text: "#c2185b" }
                ];
                return colors[Math.abs(id) % colors.length];
            }

            function renderDisplay%ColumnName%() {
                const $container%ColumnName% = $("#%UID%");
                $container%ColumnName%.empty();
                const $wrapper = $("<div>").css({
                    borderRadius: "8px",
                    padding: "0 6px",
                    minHeight: "40px",
                    display: "flex",
                    alignItems: "center",
                    gap: "8px",
                    flexWrap: "wrap"
                });

                if (%ColumnName%%UID%SelectedIds.length === 0) {
                    $wrapper.append($("<span>").addClass("text-muted").text("Chưa có nhân viên"));
                } else {
                    const visible = %ColumnName%%UID%SelectedIds.slice(0, MAX_VISIBLE_%ColumnName%);
                    const $group = $("<div>").css({ display: "flex", alignItems: "center" });

                    visible.forEach((id, i) => {
                        const item = window["DataSource_%ColumnName%"].find(e => String(e.ID) === String(id));
                        const name = item ? (item.Name || item.FullName || "?") : "?";
                        const $av = $("<div>").css({
                            width: "36px", height: "36px", borderRadius: "50%",
                            border: "3px solid #fff",
                            boxShadow: "0 2px 6px rgba(0,0,0,0.15)",
                            marginLeft: i === 0 ? "0" : "-10px",
                            zIndex: 10 - i,
                            display: "flex", alignItems: "center", justifyContent: "center",
                            fontWeight: "600", fontSize: "13px",
                            position: "relative", overflow: "hidden"
                        }).attr("title", name);

                        const cachedUrl = window.GlobalEmployeeAvatarCache[String(id)];

                        if (cachedUrl) {
                            $av.append($("<img>")
                                .attr("src", cachedUrl)
                                .css({ width: "100%", height: "100%", objectFit: "cover" })
                            );
                        } else if (item && item.storeImgName) {
                            loadGlobalAvatarIfNeeded%ColumnName%%UID%(id, item.storeImgName, item.paramImg, function(url) {
                                renderDisplay%ColumnName%();
                            });
                            
                            const color = getColorForId%ColumnName%(id);
                            const initials = getInitials%ColumnName%(name);
                            $av.css({ background: color.bg, color: color.text }).text(initials);
                        } else {
                            const color = getColorForId%ColumnName%(id);
                            const initials = getInitials%ColumnName%(name);
                            $av.css({ background: color.bg, color: color.text }).text(initials);
                        }

                        $group.append($av);
                    });

                    if (%ColumnName%%UID%SelectedIds.length > MAX_VISIBLE_%ColumnName%) {
                        const more = %ColumnName%%UID%SelectedIds.length - MAX_VISIBLE_%ColumnName%;
                        $group.append($("<div>").css({
                            width: "36px", height: "36px", borderRadius: "50%",
                            border: "3px solid #fff", marginLeft: "-10px",
                            display: "flex", alignItems: "center", justifyContent: "center",
                            fontWeight: "700", fontSize: "12px"
                        }).text("+" + more).attr("title", "Còn " + more + " người nữa"));
                    }

                    $wrapper.append($group);
                }
                $container%ColumnName%.append($wrapper);
            }

            Instance%ColumnName%%UID% = {
                setValue: function(val) {
                    if (typeof val === "string" && val.trim()) {
                        %ColumnName%%UID%SelectedIds = val.split(",").map(v => v.trim()).filter(v => v);
                    } else if (Array.isArray(val)) {
                        %ColumnName%%UID%SelectedIds = val.map(String);
                    } else {
                        %ColumnName%%UID%SelectedIds = [];
                    }
                    renderDisplay%ColumnName%();
                },
                getValue: () => %ColumnName%%UID%SelectedIds,
                getValueAsString: () => %ColumnName%%UID%SelectedIds.join(","),
                repaint: renderDisplay%ColumnName%,
                option: function(name, value) {
                    if (arguments.length === 2 && name === "value") {
                        this.setValue(value);
                    } else if (arguments.length === 1 && name === "value") {
                        return this.getValueAsString();
                    }
                    return undefined;
                },
                _suppressValueChangeAction: function() {},
                _resumeValueChangeAction: function() {}
            };
        '
    WHERE [Type] = 'hpaControlSelectEmployee' AND [ReadOnly] = 1;

    -- =============================================
    -- 2. AUTOSAVE MODE
    -- =============================================
    UPDATE #temptable SET
        loadUI = N'
            window.GlobalEmployeeAvatarCache = window.GlobalEmployeeAvatarCache || {};
            window.GlobalEmployeeAvatarLoading = window.GlobalEmployeeAvatarLoading || {};
            let Instance%ColumnName%%UID% = {};

            function loadGlobalAvatarIfNeeded%ColumnName%%UID%(employeeId, storeImgName, paramImg, callbackFn) {
                const idStr = String(employeeId);

                if (window.GlobalEmployeeAvatarCache[idStr]) {
                    if (callbackFn) callbackFn(window.GlobalEmployeeAvatarCache[idStr]);
                    return window.GlobalEmployeeAvatarCache[idStr];
                }

                if (window.GlobalEmployeeAvatarLoading[idStr]) {
                    if (callbackFn) {
                        window.GlobalEmployeeAvatarLoading[idStr].callbacks = 
                            window.GlobalEmployeeAvatarLoading[idStr].callbacks || [];
                        window.GlobalEmployeeAvatarLoading[idStr].callbacks.push(callbackFn);
                    }
                    return null;
                }

                if (!storeImgName) {
                    return null;
                }

                window.GlobalEmployeeAvatarLoading[idStr] = {
                    loading: true,
                    callbacks: callbackFn ? [callbackFn] : []
                };

                let paramArray = [];
                if (paramImg) {
                    try {
                        const decoded = decodeURIComponent(paramImg);
                        paramArray = JSON.parse(decoded);
                    } catch (e) {
                        paramArray = [];
                    }
                }

                AjaxHPAParadise({
                    data: {
                        name: storeImgName,
                        param: paramArray
                    },
                    xhrFields: { responseType: "blob" },
                    cache: true,
                    success: function (blob) {
                        const callbacks = window.GlobalEmployeeAvatarLoading[idStr]?.callbacks || [];
                        delete window.GlobalEmployeeAvatarLoading[idStr];

                        if (blob && blob.size > 0) {
                            const url = URL.createObjectURL(blob);
                            window.GlobalEmployeeAvatarCache[idStr] = url;
                            
                            callbacks.forEach(cb => {
                                try { cb(url); } catch (e) { console.error(e); }
                            });
                        } else {
                            callbacks.forEach(cb => {
                                try { cb(null); } catch (e) { console.error(e); }
                            });
                        }
                    },
                    error: function () {
                        const callbacks = window.GlobalEmployeeAvatarLoading[idStr]?.callbacks || [];
                        delete window.GlobalEmployeeAvatarLoading[idStr];
                        
                        callbacks.forEach(cb => {
                            try { cb(null); } catch (e) { console.error(e); }
                        });
                    }
                });

                return null;
            }

            window["DataSource_%ColumnName%"] = window["DataSource_%ColumnName%"] || [];
            let %ColumnName%%UID%DataSourceLoaded = false;
            let spNameDSE%ColumnName%%UID% = "%DataSourceSP%";

            
            // Sử dụng hàm loadDataSourceCommon từ sptblCommonControlType_Signed
            if (spNameDSE%ColumnName%%UID% && spNameDSE%ColumnName%%UID%.trim() !== "") {
                loadDataSourceCommon("%ColumnName%", spNameDSE%ColumnName%%UID%, function(data) {
                    window["DataSource_%ColumnName%"] = data || [];
                    // Bắt đầu load ảnh cho tất cả nhân viên
                    if (Array.isArray(data) && data.length > 0) {
                        data.forEach(emp => {
                            if (emp.ID && emp.StoreImgName) {
                                loadGlobalAvatarIfNeeded%ColumnName%%UID%(emp.ID, emp.StoreImgName, emp.ImgParamV);
                            }
                        });
                    }
                    // Gọi render một lần duy nhất từ callback
                    if (typeof renderDisplayBox%ColumnName% === "function") {
                        renderDisplayBox%ColumnName%();
                    }
                });
            }

            let %ColumnName%%UID%SelectedIds = [], %ColumnName%%UID%SelectedIdsOriginal = [];
            let %ColumnName%%UID%IsSaving = false;
            const MAX_VISIBLE_%ColumnName% = 3;

            function getInitials%ColumnName%(name) {
                if (!name) return "?";
                const words = name.trim().split(/\s+/);
                if (words.length >= 2) return (words[0][0] + words[words.length - 1][0]).toUpperCase();
                return name.substring(0, 2).toUpperCase();
            }

            function getColorForId%ColumnName%(id) {
                const colors = [
                    { bg: "#e3f2fd", text: "#1976d2" },
                    { bg: "#f3e5f5", text: "#7b1fa2" },
                    { bg: "#e8f5e9", text: "#388e3c" },
                    { bg: "#fff3e0", text: "#f57c00" },
                    { bg: "#fce4ec", text: "#c2185b" }
                ];
                return colors[Math.abs(id) % colors.length];
            }

            function renderDisplayBox%ColumnName%() {
                const $displayBox%ColumnName% = $("#%ColumnName%%UID%_display");
                if (!$displayBox%ColumnName%.length) return;
                $displayBox%ColumnName%.empty();

                const $wrapper = $("<div>").css({
                    border: "1px solid #dee2e6",
                    borderRadius: "8px",
                    padding: "0 6px",
                    minHeight: "40px",
                    display: "flex",
                    alignItems: "center",
                    cursor: "pointer"
                }).hover(
                    () => $wrapper.css({ borderColor: "#0d6efd", boxShadow: "0 0 0 0.2rem rgba(13,110,253,.15)" }),
                    () => $wrapper.css({ borderColor: "#dee2e6", boxShadow: "none" })
                );

                if (%ColumnName%%UID%SelectedIds.length === 0) {
                    $wrapper.append($("<span>").addClass("text-muted").html("<i class=\"bi bi-person-plus me-2\"></i>Chọn nhân viên..."));
                } else {
                    const displayIds = %ColumnName%%UID%SelectedIds.slice(0, MAX_VISIBLE_%ColumnName%);
                    const $group = $("<div>").css({ display: "flex", alignItems: "center" });

                    displayIds.forEach((id, index) => {
                        const item = window["DataSource_%ColumnName%"].find(e => String(e.ID) === String(id));
                        if (!item) return;

                        const $chip = $("<div>").css({
                            width: "36px", height: "36px", borderRadius: "50%",
                            border: "3px solid #fff",
                            boxShadow: "0 2px 6px rgba(0,0,0,0.15)",
                            marginLeft: index === 0 ? "0" : "-10px",
                            zIndex: MAX_VISIBLE_%ColumnName% - index,
                            display: "flex", alignItems: "center", justifyContent: "center",
                            fontWeight: "600", fontSize: "13px",
                            position: "relative", overflow: "hidden"
                        }).attr("title", item.Name || item.FullName || "");

                        const cachedUrl = window.GlobalEmployeeAvatarCache[String(id)];

                        if (cachedUrl) {
                            $chip.append($("<img>")
                                .attr("src", cachedUrl)
                                .css({ width: "100%", height: "100%", objectFit: "cover" })
                            );
                        } else if (item.storeImgName) {
                            loadGlobalAvatarIfNeeded%ColumnName%%UID%(id, item.storeImgName, item.paramImg, function(url) {
                                renderDisplayBox%ColumnName%();
                            });
                            
                            const color = getColorForId%ColumnName%(id);
                            const initials = getInitials%ColumnName%(item.Name || item.FullName);
                            $chip.css({ background: color.bg, color: color.text }).text(initials);
                        } else {
                            const color = getColorForId%ColumnName%(id);
                            const initials = getInitials%ColumnName%(item.Name || item.FullName);
                            $chip.css({ background: color.bg, color: color.text }).text(initials);
                        }

                        $group.append($chip);
                    });

                    if (%ColumnName%%UID%SelectedIds.length > MAX_VISIBLE_%ColumnName%) {
                        const remaining = %ColumnName%%UID%SelectedIds.length - MAX_VISIBLE_%ColumnName%;
                        $group.append($("<div>").css({
                            width: "36px", height: "36px", borderRadius: "50%",
                            border: "3px solid #fff", marginLeft: "-10px",
                            display: "flex", alignItems: "center", justifyContent: "center",
                            fontWeight: "700", fontSize: "12px"
                        }).text("+" + remaining).attr("title", "Còn " + remaining + " người nữa"));
                    }

                    $wrapper.append($group);
                }

                $displayBox%ColumnName%.append($wrapper);
                $wrapper.off("click").on("click", () => {
                    if (!popup%ColumnName%) {
                        initPopup%ColumnName%();
                        // Đợi popup init xong rồi mới show
                        setTimeout(() => {
                            popup%ColumnName%.show();
                        }, 0);
                    } else {
                        popup%ColumnName%.show();
                    }
                });
            }

            const $container%ColumnName% = $("#%UID%");
            $container%ColumnName%.empty();
            const $displayBox%ColumnName% = $("<div>").attr("id", "%ColumnName%%UID%_display");
            $container%ColumnName%.append($displayBox%ColumnName%);

            let popup%ColumnName%;
            let popup%ColumnName%Once = false;
            let %ColumnName%%UID%GridContainer = null;
            function initPopup%ColumnName%() {
                if (popup%ColumnName%Once) {
                    popup%ColumnName%.show();
                    return;
                }
                popup%ColumnName%Once = true;
                popup%ColumnName% = $("<div>").attr("id", "%ColumnName%%UID%_popup")
                    .appendTo(document.body)
                    .addClass("hpa-responsive")
                    .dxPopup({
                        width: 750,
                        height: "auto",
                        animation: null,
                        showTitle: true,
                        title: "Chọn nhân viên",
                        dragEnabled: true,
                        closeOnOutsideClick: true,
                        showCloseButton: true,
                        toolbarItems: [
                            {
                                widget: "dxButton",
                                location: "after",
                                toolbar: "bottom",
                                options: {
                                    text: "Hủy",
                                    onClick: () => {
                                        popup%ColumnName%._isCancelling = true;
                                        %ColumnName%%UID%SelectedIds = [...%ColumnName%%UID%SelectedIdsOriginal];
                                        popup%ColumnName%.hide();
                                    }
                                }
                            },
                            {
                                widget: "dxButton",
                                location: "after",
                                toolbar: "bottom",
                                options: {
                                    text: "Lưu",
                                    type: "success",
                                    onClick: async () => {
                                        await saveValue%ColumnName%();
                                        popup%ColumnName%.hide();
                                    }
                                }
                            }
                        ],
                        contentTemplate: function (contentElement) {
                            %ColumnName%%UID%GridContainer = $("<div>");
                            contentElement.append(%ColumnName%%UID%GridContainer);
                        },
                        onShown: () => {
                            setTimeout(() => {
                                const $popupContent = $("#%ColumnName%%UID%_popup").closest(".dx-popup-wrapper");
                                $popupContent.off("mousedown.preventClose").on("mousedown.preventClose", function(e) {
                                    e.stopPropagation();
                                });
                            }, 100);

                            const sortedData = window["DataSource_%ColumnName%"].sort((a, b) => {
                                const aSelected = %ColumnName%%UID%SelectedIds.includes(String(a.ID));
                                const bSelected = %ColumnName%%UID%SelectedIds.includes(String(b.ID));
                                return bSelected - aSelected;
                            });

                            try {
                                const existingInstance = %ColumnName%%UID%GridContainer.dxDataGrid("instance");
                                if (existingInstance) {
                                    existingInstance.dispose();
                                }
                            } catch (e) {
                                // Instance chưa tồn tại hoặc đã bị destroy
                            }

                            %ColumnName%%UID%GridContainer
                            .empty()
                            .dxDataGrid({
                                dataSource: sortedData,
                                keyExpr: "ID",
                                remoteOperations: false,
                                columnAutoWidth: true,
                                allowColumnResizing: true,
                                selection: { mode: "multiple", showCheckBoxesMode: "always" },
                                selectedRowKeys: %ColumnName%%UID%SelectedIds,
                                columns: [
                                    {
                                        caption: "Ảnh",
                                        width: 80,
                                        alignment: "center",
                                        cellTemplate: function(container, options) {
                                            const item = options.data;
                                            const $cell = $("<div>").css({
                                                display: "flex",
                                                justifyContent: "center",
                                                alignItems: "center",
                                                height: "100%"
                                            });

                                            const cachedUrl = window.GlobalEmployeeAvatarCache[String(item.ID)];

                                            if (cachedUrl) {
                                                $cell.append($("<img>")
                                                    .attr("src", cachedUrl)
                                                    .css({
                                                        width: "40px",
                                                        height: "40px",
                                                        borderRadius: "50%",
                                                        objectFit: "cover",
                                                        border: "2px solid #fff",
                                                        boxShadow: "0 2px 4px rgba(0,0,0,0.1)"
                                                    })
                                                );
                                            } else if (item.storeImgName) {
                                                loadGlobalAvatarIfNeeded%ColumnName%%UID%(item.ID, item.storeImgName, item.paramImg, function(url) {
                                                    %ColumnName%%UID%GridContainer.dxDataGrid("instance").refresh();
                                                });
                                                
                                                const initials = getInitials%ColumnName%(item.Name || item.FullName || "?");
                                                const color = getColorForId%ColumnName%(item.ID);
                                                $cell.append($("<div>")
                                                    .text(initials)
                                                    .css({
                                                        width: "40px",
                                                        height: "40px",
                                                        borderRadius: "50%",
                                                        background: color.bg,
                                                        color: color.text,
                                                        display: "flex",
                                                        justifyContent: "center",
                                                        alignItems: "center",
                                                        fontWeight: "600",
                                                        fontSize: "14px",
                                                        boxShadow: "0 2px 4px rgba(0,0,0,0.1)"
                                                    })
                                                );
                                            } else {
                                                const initials = getInitials%ColumnName%(item.Name || item.FullName || "?");
                                                const color = getColorForId%ColumnName%(item.ID);
                                                $cell.append($("<div>")
                                                    .text(initials)
                                                    .css({
                                                        width: "40px",
                                                        height: "40px",
                                                        borderRadius: "50%",
                                                        background: color.bg,
                                                        color: color.text,
                                                        display: "flex",
                                                        justifyContent: "center",
                                                        alignItems: "center",
                                                        fontWeight: "600",
                                                        fontSize: "14px",
                                                        boxShadow: "0 2px 4px rgba(0,0,0,0.1)"
                                                    })
                                                );
                                            }

                                            container.append($cell);
                                        }
                                    },
                                    { dataField: "Name", caption: "Họ tên" },
                                    { dataField: "Email", caption: "Email" },
                                    { dataField: "Position", caption: "Chức vụ" }
                                ],
                                searchPanel: { 
                                    visible: true
                                },
                                onContentReady: function(e) {
                                    const grid = e.component;
                                    
                                    // Clear default search behavior
                                    grid.option("searchPanel.text", "");
                                    
                                    const searchBox = grid.getView("headerPanel")._$element.find(".dx-datagrid-search-panel input");
                                    
                                    if (searchBox.length) {
                                        const $searchWrapper = searchBox.parent();
                                        if (!$("#custom-search-style-%ColumnName%%UID%").length) {
                                            $("<style>")
                                                .attr("id", "custom-search-style-%ColumnName%%UID%")
                                                .text(`
                                                    .dx-datagrid-search-panel input:not(:placeholder-shown) {
                                                        color: #000 !important;
                                                    }
                                                    .dx-datagrid-search-panel input::placeholder {
                                                        color: #999 !important;
                                                        opacity: 1 !important;
                                                    }
                                                `)
                                                .appendTo("head");
                                        }
                                        
                                        // Unbind ALL events
                                        searchBox.off();
                                        
                                        // Bind custom event
                                        searchBox.on("input", function() {
                                            const searchValue = $(this).val();
                                            
                                            if (!searchValue) {
                                                grid.clearFilter();
                                                return;
                                            }
                                            
                                            const searchNormalized = RemoveToneMarks_Js(searchValue);

                                            grid.filter(function(item) {
                                                const fields = ["Name", "Email", "Position"];
                                                for (let i = 0; i < fields.length; i++) {
                                                    const fieldValue = item[fields[i]];
                                                    if (fieldValue) {
                                                        const fieldNormalized = RemoveToneMarks_Js(String(fieldValue));
                                                        if (fieldNormalized.indexOf(searchNormalized) !== -1) {
                                                            return true;
                                                        }
                                                    }
                                                }
                                                return false;
                                            });
                                        });
                                    }
                                },
                                paging: { 
                                    enabled: true,
                                    pageSize: 5,
                                    pageIndex: 0
                                },
                                pager: {
                                    visible: true,
                                    allowedPageSizes: [5, 10],
                                    showPageSizeSelector: true,
                                    showInfo: true,
                                    showNavigationButtons: true
                                },
                                onSelectionChanged: e => %ColumnName%%UID%SelectedIds = e.selectedRowKeys || []
                            });
                        },
                        onHidden: () => {
                            const $popupContent = $("#%ColumnName%%UID%_popup").closest(".dx-popup-wrapper");
                            $popupContent.off("mousedown.preventClose");
                            
                            // Dispose grid instance
                            try {
                                const gridInstance = %ColumnName%%UID%GridContainer.dxDataGrid("instance");
                                if (gridInstance) {
                                    gridInstance.dispose();
                                }
                            } catch (e) {
                                // Grid chưa được khởi tạo hoặc đã dispose
                            }
                            
                            // Reset position của popup về default
                            popup%ColumnName%.option("position", { my: "center", at: "center", of: window });
                            
                            renderDisplayBox%ColumnName%();
                        }
                    }).dxPopup("instance");
                
                // Tự động save khi đóng popup (trừ khi bấm Hủy)
                popup%ColumnName%.on("hiding", async function(e) {
                    // Skip nếu đang lưu hoặc đã hủy
                    if (%ColumnName%%UID%IsSaving || e.component._isCancelling) {
                        delete e.component._isCancelling;
                        return;
                    }
                    
                    const original = %ColumnName%%UID%SelectedIdsOriginal.slice().sort().join(",");
                    const current = %ColumnName%%UID%SelectedIds.slice().sort().join(",");
                    
                    if (original !== current) {
                        e.cancel = true;
                        await saveValue%ColumnName%();
                        e.component.hide();
                    }
                });
            }

            async function saveValue%ColumnName%() {
                const original = %ColumnName%%UID%SelectedIdsOriginal.slice().sort().join(",");
                const current = %ColumnName%%UID%SelectedIds.slice().sort().join(",");
                if (original === current || %ColumnName%%UID%IsSaving) return;

                %ColumnName%%UID%IsSaving = true;
                try {
                    const newValue = %ColumnName%%UID%SelectedIds.join(",");
                    const dataJSON = JSON.stringify(["%tableId%", ["%ColumnName%"], [newValue || null]]);

                    // Context-aware record IDs
                    let id1 = currentRecordID_%ColumnIDName%;
                    if (typeof cellInfo !== "undefined" && cellInfo && cellInfo.data) {
                        id1 = cellInfo.data["%ColumnIDName%"] || id1;
                    }
                    let idValues = [id1];
                    let idFields = ["%ColumnIDName%"];
                    
                    if ("%ColumnIDName2%" && "%ColumnIDName2%".trim() !== "") {
                        let id2 = currentRecordID_%ColumnIDName2%;
                        if (typeof cellInfo !== "undefined" && cellInfo && cellInfo.data) {
                            id2 = cellInfo.data["%ColumnIDName2%"] || id2;
                        }
                        idValues.push(id2);
                        idFields.push("%ColumnIDName2%");
                    }
                    const idValsJSON = JSON.stringify([idValues, idFields]);

                    const json = await saveFunction(dataJSON, idValsJSON);
                    const errors = json.data?.[json.data.length - 1] || [];
                    if (errors.length > 0 && errors[0].Status === "ERROR") {
                        if ("%IsAlert%" === "1") {
                            uiManager.showAlert({ type: "error", message: errors[0].Message || "Lưu thất bại" });
                        }
                        return;
                    }

                    // SYNC GRID
                    if (typeof cellInfo !== "undefined" && cellInfo && cellInfo.component) {
                        try {
                            const grid = cellInfo.component;
                            grid.cellValue(cellInfo.rowIndex, "%ColumnName%", newValue);
                            grid.repaint();
                        } catch (syncErr) {
                            console.warn("[Grid Sync] SelectBox %ColumnName%%UID%: Không thể sync grid:", syncErr);
                        }
                    }

                    %ColumnName%%UID%SelectedIdsOriginal = [...%ColumnName%%UID%SelectedIds];
                    if ("%IsAlert%" === "1") {
                        uiManager.showAlert({ type: "success", message: "Lưu thành công" });
                    }
                    renderDisplayBox%ColumnName%();
                } catch (err) {
                    if ("%IsAlert%" === "1") {
                        uiManager.showAlert({ type: "error", message: "Có lỗi khi lưu" });
                    }
                } finally {
                    %ColumnName%%UID%IsSaving = false;
                }
            }

            Instance%ColumnName%%UID% = {
                setValue: function(val) {
                    if (typeof val === "string" && val.trim()) {
                        %ColumnName%%UID%SelectedIds = val.split(",").map(v => v.trim()).filter(v => v);
                    } else if (Array.isArray(val)) {
                        %ColumnName%%UID%SelectedIds = val.map(String);
                    } else {
                        %ColumnName%%UID%SelectedIds = [];
                    }
                    %ColumnName%%UID%SelectedIdsOriginal = [...%ColumnName%%UID%SelectedIds];
                    renderDisplayBox%ColumnName%();
                },
                getValue: () => %ColumnName%%UID%SelectedIds,
                getValueAsString: () => %ColumnName%%UID%SelectedIds.join(","),
                setDataSource: data => {
                    window["DataSource_%ColumnName%"] = data || [];
                },
                repaint: renderDisplayBox%ColumnName%,
                option: function(name, value) {
                    if (arguments.length === 2 && name === "value") {
                        this.setValue(value);
                    } else if (arguments.length === 1) {
                        if (name === "value") return this.getValueAsString();
                        if (name === "dataSource") return window["DataSource_%ColumnName%"];
                    }
                    return undefined;
                },
                _suppressValueChangeAction: function() {},
                _resumeValueChangeAction: function() {}
            };
        '
    WHERE [Type] = 'hpaControlSelectEmployee' AND [AutoSave] = 1 AND [ReadOnly] = 0 AND ([IsMultiSelectEmployee] = 1 OR [IsMultiSelectEmployee] IS NULL);

    -- =============================================
    -- 3. MANUAL MODE (No AutoSave)
    -- =============================================
    UPDATE #temptable SET
        loadUI = N'
            window.GlobalEmployeeAvatarCache = window.GlobalEmployeeAvatarCache || {};
            window.GlobalEmployeeAvatarLoading = window.GlobalEmployeeAvatarLoading || {};
            let Instance%ColumnName%%UID% = {};

            function loadGlobalAvatarIfNeeded%ColumnName%%UID%(employeeId, storeImgName, paramImg, callbackFn) {
                const idStr = String(employeeId);

                if (window.GlobalEmployeeAvatarCache[idStr]) {
                    if (callbackFn) callbackFn(window.GlobalEmployeeAvatarCache[idStr]);
                    return window.GlobalEmployeeAvatarCache[idStr];
                }

                if (window.GlobalEmployeeAvatarLoading[idStr]) {
                    if (callbackFn) {
                        window.GlobalEmployeeAvatarLoading[idStr].callbacks = 
                            window.GlobalEmployeeAvatarLoading[idStr].callbacks || [];
                        window.GlobalEmployeeAvatarLoading[idStr].callbacks.push(callbackFn);
                    }
                    return null;
                }

                if (!storeImgName) {
                    return null;
                }

                window.GlobalEmployeeAvatarLoading[idStr] = {
                    loading: true,
                    callbacks: callbackFn ? [callbackFn] : []
                };

                let paramArray = [];
                if (paramImg) {
                    try {
                        const decoded = decodeURIComponent(paramImg);
                        paramArray = JSON.parse(decoded);
                    } catch (e) {
                        paramArray = [];
                    }
                }

                AjaxHPAParadise({
                    data: {
                        name: storeImgName,
                        param: paramArray
                    },
                    xhrFields: { responseType: "blob" },
                    cache: true,
                    success: function (blob) {
                        const callbacks = window.GlobalEmployeeAvatarLoading[idStr]?.callbacks || [];
                        delete window.GlobalEmployeeAvatarLoading[idStr];

                        if (blob && blob.size > 0) {
                            const url = URL.createObjectURL(blob);
                            window.GlobalEmployeeAvatarCache[idStr] = url;
                            
                            callbacks.forEach(cb => {
                                try { cb(url); } catch (e) { console.error(e); }
                            });
                        } else {
                            callbacks.forEach(cb => {
                                try { cb(null); } catch (e) { console.error(e); }
                            });
                        }
                    },
                    error: function () {
                        const callbacks = window.GlobalEmployeeAvatarLoading[idStr]?.callbacks || [];
                        delete window.GlobalEmployeeAvatarLoading[idStr];
                        
                        callbacks.forEach(cb => {
                            try { cb(null); } catch (e) { console.error(e); }
                        });
                    }
                });

                return null;
            }

            window["DataSource_%ColumnName%"] = window["DataSource_%ColumnName%"] || [];
            let %ColumnName%%UID%DataSourceLoaded = false;
            let spNameDSE%ColumnName%%UID% = "%DataSourceSP%";
            let %ColumnName%%UID%SelectedIds = [], %ColumnName%%UID%SelectedIdsOriginal = [];
            const MAX_VISIBLE_%ColumnName% = 3;

            
            // Sử dụng hàm loadDataSourceCommon từ sptblCommonControlType_Signed
            if (spNameDSE%ColumnName%%UID% && spNameDSE%ColumnName%%UID%.trim() !== "") {
                loadDataSourceCommon("%ColumnName%", spNameDSE%ColumnName%%UID%, function(data) {
                    window["DataSource_%ColumnName%"] = data || [];
                    // Bắt đầu load ảnh cho tất cả nhân viên
                    if (Array.isArray(data) && data.length > 0) {
                        data.forEach(emp => {
                            if (emp.ID && emp.StoreImgName) {
                                loadGlobalAvatarIfNeeded%ColumnName%%UID%(emp.ID, emp.StoreImgName, emp.ImgParamV);
                            }
                        });
                    }
                    // Gọi render một lần duy nhất từ callback
                    if (typeof renderDisplayBox%ColumnName% === "function") {
                        renderDisplayBox%ColumnName%();
                    }
                });
            }

            function getInitials%ColumnName%(name) {
                if (!name) return "?";
                const words = name.trim().split(/\s+/);
                if (words.length >= 2) return (words[0][0] + words[words.length - 1][0]).toUpperCase();
                return name.substring(0, 2).toUpperCase();
            }

            function getColorForId%ColumnName%(id) {
                const colors = [
                    { bg: "#e3f2fd", text: "#1976d2" },
                    { bg: "#f3e5f5", text: "#7b1fa2" },
                    { bg: "#e8f5e9", text: "#388e3c" },
                    { bg: "#fff3e0", text: "#f57c00" },
                    { bg: "#fce4ec", text: "#c2185b" }
                ];
                return colors[Math.abs(id) % colors.length];
            }

            function renderDisplayBox%ColumnName%() {
                const $displayBox%ColumnName% = $("#%ColumnName%%UID%_display");
                if (!$displayBox%ColumnName%.length) return;
                $displayBox%ColumnName%.empty();

                const $wrapper = $("<div>").css({
                    border: "1px solid #dee2e6",
                    borderRadius: "8px",
                    padding: "0 6px",
                    minHeight: "40px",
                    display: "flex",
                    alignItems: "center",
                    cursor: "pointer"
                }).hover(
                    () => $wrapper.css({ borderColor: "#0d6efd", boxShadow: "0 0 0 0.2rem rgba(13,110,253,.15)" }),
                    () => $wrapper.css({ borderColor: "#dee2e6", boxShadow: "none" })
                );

                if (%ColumnName%%UID%SelectedIds.length === 0) {
                    $wrapper.append($("<span>").addClass("text-muted").html("<i class=\"bi bi-person-plus me-2\"></i>Chọn nhân viên..."));
                } else {
                    const displayIds = %ColumnName%%UID%SelectedIds.slice(0, MAX_VISIBLE_%ColumnName%);
                    const $group = $("<div>").css({ display: "flex", alignItems: "center" });

                    displayIds.forEach((id, index) => {
                        const item = window["DataSource_%ColumnName%"].find(e => String(e.ID) === String(id));
                        if (!item) return;

                        const $chip = $("<div>").css({
                            width: "36px", height: "36px", borderRadius: "50%",
                            border: "3px solid #fff",
                            boxShadow: "0 2px 6px rgba(0,0,0,0.15)",
                            marginLeft: index === 0 ? "0" : "-10px",
                            zIndex: MAX_VISIBLE_%ColumnName% - index,
                            display: "flex", alignItems: "center", justifyContent: "center",
                            fontWeight: "600", fontSize: "13px",
                            position: "relative", overflow: "hidden"
                        }).attr("title", item.Name || item.FullName || "");

                        const cachedUrl = window.GlobalEmployeeAvatarCache[String(id)];

                        if (cachedUrl) {
                            $chip.append($("<img>")
                                .attr("src", cachedUrl)
                                .css({ width: "100%", height: "100%", objectFit: "cover" })
                            );
                        } else if (item.storeImgName) {
                            loadGlobalAvatarIfNeeded%ColumnName%%UID%(id, item.storeImgName, item.paramImg, function(url) {
                                renderDisplayBox%ColumnName%();
                            });
                            
                            const color = getColorForId%ColumnName%(id);
                            const initials = getInitials%ColumnName%(item.Name || item.FullName);
                            $chip.css({ background: color.bg, color: color.text }).text(initials);
                        } else {
                            const color = getColorForId%ColumnName%(id);
                            const initials = getInitials%ColumnName%(item.Name || item.FullName);
                            $chip.css({ background: color.bg, color: color.text }).text(initials);
                        }

                        $group.append($chip);
                    });

                    if (%ColumnName%%UID%SelectedIds.length > MAX_VISIBLE_%ColumnName%) {
                        const remaining = %ColumnName%%UID%SelectedIds.length - MAX_VISIBLE_%ColumnName%;
                        $group.append($("<div>").css({
                            width: "36px", height: "36px", borderRadius: "50%",
                            border: "3px solid #fff", marginLeft: "-10px",
                            display: "flex", alignItems: "center", justifyContent: "center",
                            fontWeight: "700", fontSize: "12px"
                        }).text("+" + remaining).attr("title", "Còn " + remaining + " người nữa"));
                    }

                    $wrapper.append($group);
                }

                $displayBox%ColumnName%.append($wrapper);
                $wrapper.off("click").on("click", () => {
                    if (!popup%ColumnName%) {
                        initPopup%ColumnName%();
                        // Đợi popup init xong rồi mới show
                        setTimeout(() => {
                            popup%ColumnName%.show();
                        }, 0);
                    } else {
                        popup%ColumnName%.show();
                    }
                });
            }

            const $container%ColumnName% = $("#%UID%");
            $container%ColumnName%.empty();
            const $displayBox%ColumnName% = $("<div>").attr("id", "%ColumnName%%UID%_display");
            $container%ColumnName%.append($displayBox%ColumnName%);

            let popup%ColumnName%;
            let popup%ColumnName%Once = false;
            let %ColumnName%%UID%GridContainer = null;
            function initPopup%ColumnName%() {
                if (popup%ColumnName%Once) {
                    popup%ColumnName%.show();
                    return;
                }
                popup%ColumnName%Once = true;
                popup%ColumnName% = $("<div>").attr("id", "%ColumnName%%UID%_popup")
                    .appendTo(document.body)
                    .addClass("hpa-responsive")
                    .dxPopup({
                        width: 750,
                        height: "auto",
                        animation: null,
                        showTitle: true,
                        title: "Chọn nhân viên",
                        dragEnabled: true,
                        closeOnOutsideClick: true,
                        showCloseButton: true,
                        toolbarItems: [
                            {
                                widget: "dxButton",
                                location: "after",
                                toolbar: "bottom",
                                options: {
                                    text: "Hủy",
                                    onClick: () => {
                                        %ColumnName%%UID%SelectedIds = [...%ColumnName%%UID%SelectedIdsOriginal];
                                        popup%ColumnName%.hide();
                                    }
                                }
                            },
                            {
                                widget: "dxButton",
                                location: "after",
                                toolbar: "bottom",
                                options: {
                                    text: "Lưu",
                                    type: "success",
                                    onClick: () => {
                                        %ColumnName%%UID%SelectedIdsOriginal = [...%ColumnName%%UID%SelectedIds];
                                        popup%ColumnName%.hide();
                                    }
                                }
                            }
                        ],
                        contentTemplate: function (contentElement) {
                            %ColumnName%%UID%GridContainer = $("<div>");
                            contentElement.append(%ColumnName%%UID%GridContainer);
                        },
                        onShown: () => {
                            const sortedData = window["DataSource_%ColumnName%"].sort((a, b) => {
                                const aSelected = %ColumnName%%UID%SelectedIds.includes(String(a.ID));
                                const bSelected = %ColumnName%%UID%SelectedIds.includes(String(b.ID));
                                return bSelected - aSelected;
                            });

                            try {
                                const existingInstance = %ColumnName%%UID%GridContainer.dxDataGrid("instance");
                                if (existingInstance) {
                                    existingInstance.dispose();
                                }
                            } catch (e) {
                                // Instance chưa tồn tại hoặc đã bị destroy
                            }

                            %ColumnName%%UID%GridContainer
                            .empty()
                            .dxDataGrid({
                                dataSource: sortedData,
                                keyExpr: "ID",
                                remoteOperations: false,
                                columnAutoWidth: true,
                                allowColumnResizing: true,
                                selection: { mode: "multiple", showCheckBoxesMode: "always" },
                                selectedRowKeys: %ColumnName%%UID%SelectedIds,
                                columns: [
                                    {
                                        caption: "Ảnh",
                                        width: 80,
                                        alignment: "center",
                                        cellTemplate: function(container, options) {
                                            const item = options.data;
                                            const $cell = $("<div>").css({
                                                display: "flex",
                                                justifyContent: "center",
                                                alignItems: "center",
                                                height: "100%"
                                            });

                                            const cachedUrl = window.GlobalEmployeeAvatarCache[String(item.ID)];

                                            if (cachedUrl) {
                                                $cell.append($("<img>")
                                                    .attr("src", cachedUrl)
                                                    .css({
                                                        width: "40px",
                                                        height: "40px",
                                                        borderRadius: "50%",
                                                        objectFit: "cover",
                                                        border: "2px solid #fff",
                                                        boxShadow: "0 2px 4px rgba(0,0,0,0.1)"
                                                    })
                                                );
                                            } else if (item.storeImgName) {
                                                loadGlobalAvatarIfNeeded%ColumnName%%UID%(item.ID, item.storeImgName, item.paramImg, function(url) {
                                                    %ColumnName%%UID%GridContainer.dxDataGrid("instance").refresh();
                                                });
                                                
                                                const initials = getInitials%ColumnName%(item.Name || item.FullName || "?");
                                                const color = getColorForId%ColumnName%(item.ID);
                                                $cell.append($("<div>")
                                                    .text(initials)
                                                    .css({
                                                        width: "40px",
                                                        height: "40px",
                                                        borderRadius: "50%",
                                                        background: color.bg,
                                                        color: color.text,
                                                        display: "flex",
                                                        justifyContent: "center",
                                                        alignItems: "center",
                                                        fontWeight: "600",
                                                        fontSize: "14px",
                                                        boxShadow: "0 2px 4px rgba(0,0,0,0.1)"
                                                    })
                                                );
                                            } else {
                                                const initials = getInitials%ColumnName%(item.Name || item.FullName || "?");
                                                const color = getColorForId%ColumnName%(item.ID);
                                                $cell.append($("<div>")
                                                    .text(initials)
                                                    .css({
                                                        width: "40px",
                                                        height: "40px",
                                                        borderRadius: "50%",
                                                        background: color.bg,
                                                        color: color.text,
                                                        display: "flex",
                                                        justifyContent: "center",
                                                        alignItems: "center",
                                                        fontWeight: "600",
                                                        fontSize: "14px",
                                                        boxShadow: "0 2px 4px rgba(0,0,0,0.1)"
                                                    })
                                                );
                                            }

                                            container.append($cell);
                                        }
                                    },
                                    { dataField: "Name", caption: "Họ tên" },
                                    { dataField: "Email", caption: "Email" },
                                    { dataField: "Position", caption: "Chức vụ" }
                                ],
                                searchPanel: { 
                                    visible: true
                                },
                                onContentReady: function(e) {
                                    const grid = e.component;
                                    
                                    // Clear default search behavior
                                    grid.option("searchPanel.text", "");
                                    
                                    const searchBox = grid.getView("headerPanel")._$element.find(".dx-datagrid-search-panel input");
                                    
                                    if (searchBox.length) {
                                        const $searchWrapper = searchBox.parent();
                                        if (!$("#custom-search-style-%ColumnName%%UID%").length) {
                                            $("<style>")
                                                .attr("id", "custom-search-style-%ColumnName%%UID%")
                                                .text(`
                                                    .dx-datagrid-search-panel input:not(:placeholder-shown) {
                                                        color: #000 !important;
                                                    }
                                                    .dx-datagrid-search-panel input::placeholder {
                                                        color: #999 !important;
                                                        opacity: 1 !important;
                                                    }
                                                `)
                                                .appendTo("head");
                                        }
                                        
                                        // Unbind ALL events
                                        searchBox.off();
                                        
                                        // Bind custom event
                                        searchBox.on("input", function() {
                                            const searchValue = $(this).val();
                                            
                                            if (!searchValue) {
                                                grid.clearFilter();
                                                return;
                                            }
                                            
                                            const searchNormalized = RemoveToneMarks_Js(searchValue);

                                            grid.filter(function(item) {
                                                const fields = ["Name", "Email", "Position"];
                                                for (let i = 0; i < fields.length; i++) {
                                                    const fieldValue = item[fields[i]];
                                                    if (fieldValue) {
                                                        const fieldNormalized = RemoveToneMarks_Js(String(fieldValue));
                                                        if (fieldNormalized.indexOf(searchNormalized) !== -1) {
                                                            return true;
                                                        }
                                                    }
                                                }
                                                return false;
                                            });
                                        });
                                    }
                                },
                                paging: { 
                                    enabled: true,
                                    pageSize: 5,
                                    pageIndex: 0
                                },
                                pager: {
                                    visible: true,
                                    allowedPageSizes: [5, 10],
                                    showPageSizeSelector: true,
                                    showInfo: true,
                                    showNavigationButtons: true
                                },
                                onSelectionChanged: e => %ColumnName%%UID%SelectedIds = e.selectedRowKeys || []
                            });
                        },
                        onHidden: () => {
                            // Dispose grid instance
                            try {
                                const gridInstance = %ColumnName%%UID%GridContainer.dxDataGrid("instance");
                                if (gridInstance) {
                                    gridInstance.dispose();
                                }
                            } catch (e) {
                                // Grid chưa được khởi tạo hoặc đã dispose
                            }
                            
                            // Reset position của popup về default
                            popup%ColumnName%.option("position", { my: "center", at: "center", of: window });
                            
                            renderDisplayBox%ColumnName%();
                        }
                    }).dxPopup("instance");
            }

            Instance%ColumnName%%UID% = {
                setValue: function(val) {
                    if (typeof val === "string" && val.trim()) {
                        %ColumnName%%UID%SelectedIds = val.split(",").map(v => v.trim()).filter(v => v);
                    } else if (Array.isArray(val)) {
                        %ColumnName%%UID%SelectedIds = val.map(String);
                    } else {
                        %ColumnName%%UID%SelectedIds = [];
                    }
                    %ColumnName%%UID%SelectedIdsOriginal = [...%ColumnName%%UID%SelectedIds];
                    renderDisplayBox%ColumnName%();
                },
                getValue: () => %ColumnName%%UID%SelectedIds,
                getValueAsString: () => %ColumnName%%UID%SelectedIds.join(","),
                setDataSource: data => {
                    window["DataSource_%ColumnName%"] = data || [];
                },
                repaint: renderDisplayBox%ColumnName%,
                option: function(name, value) {
                    if (arguments.length === 2 && name === "value") {
                        this.setValue(value);
                    } else if (arguments.length === 1) {
                        if (name === "value") return this.getValueAsString();
                        if (name === "dataSource") return window["DataSource_%ColumnName%"];
                    }
                    return undefined;
                },
                _suppressValueChangeAction: function() {},
                _resumeValueChangeAction: function() {}
            };
        '
    WHERE [Type] = 'hpaControlSelectEmployee' AND [AutoSave] = 0 AND [ReadOnly] = 0 AND ([IsMultiSelectEmployee] = 1 OR [IsMultiSelectEmployee] IS NULL);

    -- =============================================
    -- 4. AUTOSAVE MODE - SINGLE SELECT (IsMultiSelectEmployee = 0)
    -- =============================================
    UPDATE #temptable SET
        loadUI = N'
            window.GlobalEmployeeAvatarCache = window.GlobalEmployeeAvatarCache || {};
            window.GlobalEmployeeAvatarLoading = window.GlobalEmployeeAvatarLoading || {};
            let Instance%ColumnName%%UID% = {};

            function loadGlobalAvatarIfNeeded%ColumnName%%UID%(employeeId, storeImgName, paramImg, callbackFn) {
                const idStr = String(employeeId);

                if (window.GlobalEmployeeAvatarCache[idStr]) {
                    if (callbackFn) callbackFn(window.GlobalEmployeeAvatarCache[idStr]);
                    return window.GlobalEmployeeAvatarCache[idStr];
                }

                if (window.GlobalEmployeeAvatarLoading[idStr]) {
                    if (callbackFn) {
                        window.GlobalEmployeeAvatarLoading[idStr].callbacks = 
                            window.GlobalEmployeeAvatarLoading[idStr].callbacks || [];
                        window.GlobalEmployeeAvatarLoading[idStr].callbacks.push(callbackFn);
                    }
                    return null;
                }

                if (!storeImgName) {
                    return null;
                }

                window.GlobalEmployeeAvatarLoading[idStr] = {
                    loading: true,
                    callbacks: callbackFn ? [callbackFn] : []
                };

                let paramArray = [];
                if (paramImg) {
                    try {
                        const decoded = decodeURIComponent(paramImg);
                        paramArray = JSON.parse(decoded);
                    } catch (e) {
                        paramArray = [];
                    }
                }

                AjaxHPAParadise({
                    data: {
                        name: storeImgName,
                        param: paramArray
                    },
                    xhrFields: { responseType: "blob" },
                    cache: true,
                    success: function (blob) {
                        const callbacks = window.GlobalEmployeeAvatarLoading[idStr]?.callbacks || [];
                        delete window.GlobalEmployeeAvatarLoading[idStr];

                        if (blob && blob.size > 0) {
                            const url = URL.createObjectURL(blob);
                            window.GlobalEmployeeAvatarCache[idStr] = url;
                            
                            callbacks.forEach(cb => {
                                try { cb(url); } catch (e) { console.error(e); }
                            });
                        } else {
                            callbacks.forEach(cb => {
                                try { cb(null); } catch (e) { console.error(e); }
                            });
                        }
                    },
                    error: function () {
                        const callbacks = window.GlobalEmployeeAvatarLoading[idStr]?.callbacks || [];
                        delete window.GlobalEmployeeAvatarLoading[idStr];
                        
                        callbacks.forEach(cb => {
                            try { cb(null); } catch (e) { console.error(e); }
                        });
                    }
                });

                return null;
            }

            window["DataSource_%ColumnName%"] = window["DataSource_%ColumnName%"] || [];
            let spNameDSE%ColumnName%%UID% = "%DataSourceSP%";
            let %ColumnName%%UID%SelectedId = null, %ColumnName%%UID%SelectedIdOriginal = null;

            
            // Sử dụng hàm loadDataSourceCommon từ sptblCommonControlType_Signed
            if (spNameDSE%ColumnName%%UID% && spNameDSE%ColumnName%%UID%.trim() !== "") {
                loadDataSourceCommon("%ColumnName%", spNameDSE%ColumnName%%UID%, function(data) {
                    window["DataSource_%ColumnName%"] = data || [];
                    // Bắt đầu load ảnh cho tất cả nhân viên
                    if (Array.isArray(data) && data.length > 0) {
                        data.forEach(emp => {
                            if (emp.ID && emp.StoreImgName) {
                                loadGlobalAvatarIfNeeded%ColumnName%%UID%(emp.ID, emp.StoreImgName, emp.ImgParamV);
                            }
                        });
                    }
                    // Gọi render một lần duy nhất từ callback
                    if (typeof renderDisplayBox%ColumnName% === "function") {
                        renderDisplayBox%ColumnName%();
                    }
                });
            }

            function getInitials%ColumnName%(name) {
                if (!name) return "?";
                const words = name.trim().split(/\s+/);
                if (words.length >= 2) return (words[0][0] + words[words.length - 1][0]).toUpperCase();
                return name.substring(0, 2).toUpperCase();
            }

            function getColorForId%ColumnName%(id) {
                const colors = [
                    { bg: "#e3f2fd", text: "#1976d2" },
                    { bg: "#f3e5f5", text: "#7b1fa2" },
                    { bg: "#e8f5e9", text: "#388e3c" },
                    { bg: "#fff3e0", text: "#f57c00" },
                    { bg: "#fce4ec", text: "#c2185b" }
                ];
                return colors[Math.abs(id) % colors.length];
            }

            function renderDisplayBox%ColumnName%() {
                const $displayBox%ColumnName% = $("#%ColumnName%%UID%_display");
                if (!$displayBox%ColumnName%.length) return;
                $displayBox%ColumnName%.empty();

                const $wrapper = $("<div>").css({
                    border: "1px solid #dee2e6",
                    borderRadius: "8px",
                    padding: "0 6px",
                    minHeight: "40px",
                    display: "flex",
                    alignItems: "center",
                    gap: "10px",
                    cursor: "pointer"
                }).hover(
                    () => $wrapper.css({ borderColor: "#0d6efd", boxShadow: "0 0 0 0.2rem rgba(13,110,253,.15)" }),
                    () => $wrapper.css({ borderColor: "#dee2e6", boxShadow: "none" })
                );

                if (!%ColumnName%%UID%SelectedId) {
                    $wrapper.append($("<span>").addClass("text-muted").html("<i class=\"bi bi-person-plus me-2\"></i>Chọn nhân viên..."));
                } else {
                    const item = window["DataSource_%ColumnName%"].find(e => String(e.ID) === String(%ColumnName%%UID%SelectedId));
                    if (!item) {
                        $wrapper.append($("<span>").addClass("text-muted").text("Nhân viên không tồn tại"));
                    } else {
                        const name = item.Name || item.FullName || "?";
                        
                        const $avatar = $("<div>").css({
                            width: "40px", height: "40px", borderRadius: "50%",
                            boxShadow: "0 2px 6px rgba(0,0,0,0.15)",
                            display: "flex", alignItems: "center", justifyContent: "center",
                            fontWeight: "600", fontSize: "14px",
                            position: "relative", overflow: "hidden",
                            flexShrink: 0
                        });

                        const cachedUrl = window.GlobalEmployeeAvatarCache[String(%ColumnName%%UID%SelectedId)];

                        if (cachedUrl) {
                            $avatar.append($("<img>")
                                .attr("src", cachedUrl)
                                .css({ width: "100%", height: "100%", objectFit: "cover" })
                            );
                        } else if (item.storeImgName) {
                            loadGlobalAvatarIfNeeded%ColumnName%%UID%(%ColumnName%%UID%SelectedId, item.storeImgName, item.paramImg, function(url) {
                                renderDisplayBox%ColumnName%();
                            });
                            
                            const color = getColorForId%ColumnName%(%ColumnName%%UID%SelectedId);
                            const initials = getInitials%ColumnName%(name);
                            $avatar.css({ background: color.bg, color: color.text }).text(initials);
                        } else {
                            const color = getColorForId%ColumnName%(%ColumnName%%UID%SelectedId);
                            const initials = getInitials%ColumnName%(name);
                            $avatar.css({ background: color.bg, color: color.text }).text(initials);
                        }

                        const $info = $("<div>").css({ flex: 1, overflow: "hidden" });
                        $info.append($("<div>").css({ fontWeight: "500", fontSize: "14px", overflow: "hidden", textOverflow: "ellipsis", whiteSpace: "nowrap" }).text(name));
                        if (item.Position) {
                            $info.append($("<div>").css({ fontSize: "12px", color: "#6c757d", overflow: "hidden", textOverflow: "ellipsis", whiteSpace: "nowrap" }).text(item.Position));
                        }

                        $wrapper.append($avatar).append($info);
                    }
                }

                $displayBox%ColumnName%.append($wrapper);
                $wrapper.off("click").on("click", () => {
                    if (!popup%ColumnName%) {
                        initPopup%ColumnName%();
                        // Đợi popup init xong rồi mới show
                        setTimeout(() => {
                            popup%ColumnName%.show();
                        }, 0);
                    } else {
                        popup%ColumnName%.show();
                    }
                });
            }

            const $container%ColumnName% = $("#%UID%");
            $container%ColumnName%.empty();
            const $displayBox%ColumnName% = $("<div>").attr("id", "%ColumnName%%UID%_display");
            $container%ColumnName%.append($displayBox%ColumnName%);

            let popup%ColumnName%;
            let popup%ColumnName%Once = false;
            let %ColumnName%%UID%GridContainer = null;
            function initPopup%ColumnName%() {
                if (popup%ColumnName%Once) {
                    popup%ColumnName%.show();
                    return;
                }
                popup%ColumnName%Once = true;
                popup%ColumnName% = $("<div>").attr("id", "%ColumnName%%UID%_popup")
                    .appendTo(document.body)
                    .addClass("hpa-responsive")
                    .dxPopup({
                        width: 750,
                        height: "auto",
                        animation: null,
                        showTitle: true,
                        title: "Chọn nhân viên",
                        dragEnabled: true,
                        closeOnOutsideClick: true,
                        showCloseButton: true,
                        toolbarItems: [
                            {
                                widget: "dxButton",
                                location: "after",
                                toolbar: "bottom",
                                options: {
                                    text: "Hủy",
                                    onClick: () => {
                                        popup%ColumnName%._isCancelling = true;
                                        %ColumnName%%UID%SelectedId = %ColumnName%%UID%SelectedIdOriginal;
                                        popup%ColumnName%.hide();
                                    }
                                }
                            },
                            {
                                widget: "dxButton",
                                location: "after",
                                toolbar: "bottom",
                                options: {
                                    text: "Lưu",
                                    type: "success",
                                    onClick: async () => {
                                        await saveValue%ColumnName%();
                                        popup%ColumnName%.hide();
                                    }
                                }
                            }
                        ],
                        contentTemplate: function (contentElement) {
                            %ColumnName%%UID%GridContainer = $("<div>");
                            contentElement.append(%ColumnName%%UID%GridContainer);
                        },
                        onShown: () => {
                            setTimeout(() => {
                                const $popupContent = $("#%ColumnName%%UID%_popup").closest(".dx-popup-wrapper");
                                $popupContent.off("mousedown.preventClose").on("mousedown.preventClose", function(e) {
                                    e.stopPropagation();
                                });
                            }, 100);

                            const sortedData = window["DataSource_%ColumnName%"].sort((a, b) => {
                                const aSelected = String(a.ID) === String(%ColumnName%%UID%SelectedId);
                                const bSelected = String(b.ID) === String(%ColumnName%%UID%SelectedId);
                                return bSelected - aSelected;
                            });

                            // Destroy instance cũ nếu tồn tại
                            try {
                                const existingInstance = %ColumnName%%UID%GridContainer.dxDataGrid("instance");
                                if (existingInstance) {
                                    existingInstance.dispose();
                                }
                            } catch (e) {
                                // Instance chưa tồn tại hoặc đã bị destroy
                            }

                            %ColumnName%%UID%GridContainer
                            .empty()
                            .dxDataGrid({
                                dataSource: sortedData,
                                keyExpr: "ID",
                                remoteOperations: false,
                                columnAutoWidth: true,
                                allowColumnResizing: true,
                                selection: { mode: "single" },
                                selectedRowKeys: %ColumnName%%UID%SelectedId ? [%ColumnName%%UID%SelectedId] : [],
                                hoverStateEnabled: true,
                                onRowPrepared: function(e) {
                                    if (e.rowType === "data") {
                                        e.rowElement.css("cursor", "pointer");
                                    }
                                },
                                columns: [
                                    {
                                        caption: "Ảnh",
                                        width: 80,
                                        alignment: "center",
                                        cellTemplate: function(container, options) {
                                            const item = options.data;
                                            const $cell = $("<div>").css({
                                                display: "flex",
                                                justifyContent: "center",
                                                alignItems: "center",
                                                height: "100%"
                                            });

                                            const cachedUrl = window.GlobalEmployeeAvatarCache[String(item.ID)];

                                            if (cachedUrl) {
                                                $cell.append($("<img>")
                                                    .attr("src", cachedUrl)
                                                    .css({
                                                        width: "40px",
                                                        height: "40px",
                                                        borderRadius: "50%",
                                                        objectFit: "cover",
                                                        border: "2px solid #fff",
                                                        boxShadow: "0 2px 4px rgba(0,0,0,0.1)"
                                                    })
                                                );
                                            } else if (item.storeImgName) {
                                                loadGlobalAvatarIfNeeded%ColumnName%%UID%(item.ID, item.storeImgName, item.paramImg, function(url) {
                                                    %ColumnName%%UID%GridContainer.dxDataGrid("instance").refresh();
                                                });
                                                
                                                const initials = getInitials%ColumnName%(item.Name || item.FullName || "?");
                                                const color = getColorForId%ColumnName%(item.ID);
                                                $cell.append($("<div>")
                                                    .text(initials)
                                                    .css({
                                                        width: "40px",
                                                        height: "40px",
                                                        borderRadius: "50%",
                                                        background: color.bg,
                                                        color: color.text,
                                                        display: "flex",
                                                        justifyContent: "center",
                                                        alignItems: "center",
                                                        fontWeight: "600",
                                                        fontSize: "14px",
                                                        boxShadow: "0 2px 4px rgba(0,0,0,0.1)"
                                                    })
                                                );
                                            } else {
                                                const initials = getInitials%ColumnName%(item.Name || item.FullName || "?");
                                                const color = getColorForId%ColumnName%(item.ID);
                                                $cell.append($("<div>")
                                                    .text(initials)
                                                    .css({
                                                        width: "40px",
                                                        height: "40px",
                                                        borderRadius: "50%",
                                                        background: color.bg,
                                                        color: color.text,
                                                        display: "flex",
                                                        justifyContent: "center",
                                                        alignItems: "center",
                                                        fontWeight: "600",
                                                        fontSize: "14px",
                                                        boxShadow: "0 2px 4px rgba(0,0,0,0.1)"
                                                    })
                                                );
                                            }

                                            container.append($cell);
                                        }
                                    },
                                    { dataField: "Name", caption: "Họ tên" },
                                    { dataField: "Email", caption: "Email" },
                                    { dataField: "Position", caption: "Chức vụ" }
                                ],
                                searchPanel: { 
                                    visible: true
                                },
                                onContentReady: function(e) {
                                    const grid = e.component;
                                    
                                    // Clear default search behavior
                                    grid.option("searchPanel.text", "");
                                    
                                    const searchBox = grid.getView("headerPanel")._$element.find(".dx-datagrid-search-panel input");
                                    
                                    if (searchBox.length) {
                                        const $searchWrapper = searchBox.parent();
                                        if (!$("#custom-search-style-%ColumnName%%UID%").length) {
                                            $("<style>")
                                                .attr("id", "custom-search-style-%ColumnName%%UID%")
                                                .text(`
                                                    .dx-datagrid-search-panel input:not(:placeholder-shown) {
                                                        color: #000 !important;
                                                    }
                                                    .dx-datagrid-search-panel input::placeholder {
                                                        color: #999 !important;
                                                        opacity: 1 !important;
                                                    }
                                                `)
                                                .appendTo("head");
                                        }
                                        
                                        // Unbind ALL events
                                        searchBox.off();
                                        
                                        // Bind custom event
                                        searchBox.on("input", function() {
                                            const searchValue = $(this).val();
                                            
                                            if (!searchValue) {
                                                grid.clearFilter();
                                                return;
                                            }
                                            
                                            const searchNormalized = RemoveToneMarks_Js(searchValue);

                                            grid.filter(function(item) {
                                                const fields = ["Name", "Email", "Position"];
                                                for (let i = 0; i < fields.length; i++) {
                                                    const fieldValue = item[fields[i]];
                                                    if (fieldValue) {
                                                        const fieldNormalized = RemoveToneMarks_Js(String(fieldValue));
                                                        if (fieldNormalized.indexOf(searchNormalized) !== -1) {
                                                            return true;
                                                        }
                                                    }
                                                }
                                                return false;
                                            });
                                        });
                                    }
                                },
                                paging: { 
                                    enabled: true,
                                    pageSize: 5,
                                    pageIndex: 0
                                },
                                pager: {
                                    visible: true,
                                    allowedPageSizes: [5, 10],
                                    showPageSizeSelector: true,
                                    showInfo: true,
                                    showNavigationButtons: true
                                },
                                onSelectionChanged: e => {
                                    const keys = e.selectedRowKeys || [];
                                    %ColumnName%%UID%SelectedId = keys.length > 0 ? String(keys[0]) : null;
                                }
                            });
                        },
                        onHidden: () => {
                            const $popupContent = $("#%ColumnName%%UID%_popup").closest(".dx-popup-wrapper");
                            $popupContent.off("mousedown.preventClose");
                            
                            try {
                                const gridInstance = %ColumnName%%UID%GridContainer.dxDataGrid("instance");
                                if (gridInstance) {
                                    gridInstance.dispose();
                                }
                            } catch (e) {
                                // Grid chưa được khởi tạo hoặc đã dispose
                            }
                            
                            // Reset position của popup về default
                            popup%ColumnName%.option("position", { my: "center", at: "center", of: window });

                            renderDisplayBox%ColumnName%();
                        }
                    }).dxPopup("instance");
                
                popup%ColumnName%.on("hiding", async function(e) {
                    if (e.component._isCancelling) {
                        delete e.component._isCancelling;
                        return;
                    }
                    
                    const original = String(%ColumnName%%UID%SelectedIdOriginal || "");
                    const current = String(%ColumnName%%UID%SelectedId || "");
                    
                    if (original !== current) {
                        e.cancel = true;
                        await saveValue%ColumnName%();
                        e.component.hide();
                    }
                });
            }

            async function saveValue%ColumnName%() {
                const original = String(%ColumnName%%UID%SelectedIdOriginal || "");
                const current = String(%ColumnName%%UID%SelectedId || "");
                if (original === current) return;

                try {
                    const newValue = %ColumnName%%UID%SelectedId || null;
                    const dataJSON = JSON.stringify(["%tableId%", ["%ColumnName%"], [newValue]]);

                    // Context-aware record IDs
                    let id1 = currentRecordID_%ColumnIDName%;
                    if (typeof cellInfo !== "undefined" && cellInfo && cellInfo.data) {
                        id1 = cellInfo.data["%ColumnIDName%"] || id1;
                    }
                    let idValues = [id1];
                    let idFields = ["%ColumnIDName%"];
                    
                    if ("%ColumnIDName2%" && "%ColumnIDName2%".trim() !== "") {
                        let id2 = currentRecordID_%ColumnIDName2%;
                        if (typeof cellInfo !== "undefined" && cellInfo && cellInfo.data) {
                            id2 = cellInfo.data["%ColumnIDName2%"] || id2;
                        }
                        idValues.push(id2);
                        idFields.push("%ColumnIDName2%");
                    }
                    const idValsJSON = JSON.stringify([idValues, idFields]);

                    const json = await saveFunction(dataJSON, idValsJSON);
                    const errors = json.data?.[json.data.length - 1] || [];
                    if (errors.length > 0 && errors[0].Status === "ERROR") {
                        if ("%IsAlert%" === "1") {
                            uiManager.showAlert({ type: "error", message: errors[0].Message || "Lưu thất bại" });
                        }
                        return;
                    }

                    // SYNC GRID
                    if (typeof cellInfo !== "undefined" && cellInfo && cellInfo.component) {
                        try {
                            const grid = cellInfo.component;
                            grid.cellValue(cellInfo.rowIndex, "%ColumnName%", newValue);
                            grid.repaint();
                        } catch (syncErr) {
                            console.warn("[Grid Sync] SelectBox %ColumnName%%UID%: Không thể sync grid:", syncErr);
                        }
                    }

                    %ColumnName%%UID%SelectedIdOriginal = %ColumnName%%UID%SelectedId;
                    if ("%IsAlert%" === "1") {
                        uiManager.showAlert({ type: "success", message: "Lưu thành công" });
                    }
                    renderDisplayBox%ColumnName%();
                } catch (err) {
                    if ("%IsAlert%" === "1") {
                        uiManager.showAlert({ type: "error", message: "Có lỗi khi lưu" });
                    }
                }
            }

            Instance%ColumnName%%UID% = {
                setValue: function(val) {
                    if (val !== null && val !== undefined && val !== "") {
                        %ColumnName%%UID%SelectedId = String(val);
                    } else {
                        %ColumnName%%UID%SelectedId = null;
                    }
                    %ColumnName%%UID%SelectedIdOriginal = %ColumnName%%UID%SelectedId;
                    renderDisplayBox%ColumnName%();
                },
                getValue: () => %ColumnName%%UID%SelectedId,
                getValueAsString: () => %ColumnName%%UID%SelectedId || "",
                setDataSource: data => {
                    window["DataSource_%ColumnName%"] = data || [];
                },
                repaint: renderDisplayBox%ColumnName%,
                option: function(name, value) {
                    if (arguments.length === 2 && name === "value") {
                        this.setValue(value);
                    } else if (arguments.length === 1) {
                        if (name === "value") return this.getValueAsString();
                        if (name === "dataSource") return window["DataSource_%ColumnName%"];
                    }
                    return undefined;
                },
                _suppressValueChangeAction: function() {},
                _resumeValueChangeAction: function() {}
            };
        '
    WHERE [Type] = 'hpaControlSelectEmployee' AND [AutoSave] = 1 AND [ReadOnly] = 0 AND [IsMultiSelectEmployee] = 0;

    -- =============================================
    -- 5. MANUAL MODE (No AutoSave) - SINGLE SELECT (IsMultiSelectEmployee = 0)
    -- =============================================
    UPDATE #temptable SET
        loadUI = N'
            window.GlobalEmployeeAvatarCache = window.GlobalEmployeeAvatarCache || {};
            window.GlobalEmployeeAvatarLoading = window.GlobalEmployeeAvatarLoading || {};
            let Instance%ColumnName%%UID% = {};

            function loadGlobalAvatarIfNeeded%ColumnName%%UID%(employeeId, storeImgName, paramImg, callbackFn) {
                const idStr = String(employeeId);

                if (window.GlobalEmployeeAvatarCache[idStr]) {
                    if (callbackFn) callbackFn(window.GlobalEmployeeAvatarCache[idStr]);
                    return window.GlobalEmployeeAvatarCache[idStr];
                }

                if (window.GlobalEmployeeAvatarLoading[idStr]) {
                    if (callbackFn) {
                        window.GlobalEmployeeAvatarLoading[idStr].callbacks = 
                            window.GlobalEmployeeAvatarLoading[idStr].callbacks || [];
                        window.GlobalEmployeeAvatarLoading[idStr].callbacks.push(callbackFn);
                    }
                    return null;
                }

                if (!storeImgName) {
                    return null;
                }

                window.GlobalEmployeeAvatarLoading[idStr] = {
                    loading: true,
                    callbacks: callbackFn ? [callbackFn] : []
                };

                let paramArray = [];
                if (paramImg) {
                    try {
                        const decoded = decodeURIComponent(paramImg);
                        paramArray = JSON.parse(decoded);
                    } catch (e) {
                        paramArray = [];
                    }
                }

                AjaxHPAParadise({
                    data: {
                        name: storeImgName,
                        param: paramArray
                    },
                    xhrFields: { responseType: "blob" },
                    cache: true,
                    success: function (blob) {
                        const callbacks = window.GlobalEmployeeAvatarLoading[idStr]?.callbacks || [];
                        delete window.GlobalEmployeeAvatarLoading[idStr];

                        if (blob && blob.size > 0) {
                            const url = URL.createObjectURL(blob);
                            window.GlobalEmployeeAvatarCache[idStr] = url;
                            
                            callbacks.forEach(cb => {
                                try { cb(url); } catch (e) { console.error(e); }
                            });
                        } else {
                            callbacks.forEach(cb => {
                                try { cb(null); } catch (e) { console.error(e); }
                            });
                        }
                    },
                    error: function () {
                        const callbacks = window.GlobalEmployeeAvatarLoading[idStr]?.callbacks || [];
                        delete window.GlobalEmployeeAvatarLoading[idStr];
                        
                        callbacks.forEach(cb => {
                            try { cb(null); } catch (e) { console.error(e); }
                        });
                    }
                });

                return null;
            }

            window["DataSource_%ColumnName%"] = window["DataSource_%ColumnName%"] || [];
            let spNameDSE%ColumnName%%UID% = "%DataSourceSP%";
            let %ColumnName%%UID%SelectedId = null, %ColumnName%%UID%SelectedIdOriginal = null;
            let _autoSave%ColumnName%%UID% = false;
            let _readOnly%ColumnName%%UID% = false;
            
            // Sử dụng hàm loadDataSourceCommon từ sptblCommonControlType_Signed
            if (spNameDSE%ColumnName%%UID% && spNameDSE%ColumnName%%UID%.trim() !== "") {
                loadDataSourceCommon("%ColumnName%", spNameDSE%ColumnName%%UID%, function(data) {
                    window["DataSource_%ColumnName%"] = data || [];
                    // Bắt đầu load ảnh cho tất cả nhân viên
                    if (Array.isArray(data) && data.length > 0) {
                        data.forEach(emp => {
                            if (emp.ID && emp.StoreImgName) {
                                loadGlobalAvatarIfNeeded%ColumnName%%UID%(emp.ID, emp.StoreImgName, emp.ImgParamV);
                            }
                        });
                    }
                    // Gọi render một lần duy nhất từ callback
                    if (typeof renderDisplayBox%ColumnName% === "function") {
                        renderDisplayBox%ColumnName%();
                    }
                });
            }

            function getInitials%ColumnName%(name) {
                if (!name) return "?";
                const words = name.trim().split(/\s+/);
                if (words.length >= 2) return (words[0][0] + words[words.length - 1][0]).toUpperCase();
                return name.substring(0, 2).toUpperCase();
            }

            function getColorForId%ColumnName%(id) {
                const colors = [
                    { bg: "#e3f2fd", text: "#1976d2" },
                    { bg: "#f3e5f5", text: "#7b1fa2" },
                    { bg: "#e8f5e9", text: "#388e3c" },
                    { bg: "#fff3e0", text: "#f57c00" },
                    { bg: "#fce4ec", text: "#c2185b" }
                ];
                return colors[Math.abs(id) % colors.length];
            }

            function renderDisplayBox%ColumnName%() {
                const $displayBox%ColumnName% = $("#%ColumnName%%UID%_display");
                if (!$displayBox%ColumnName%.length) return;
                $displayBox%ColumnName%.empty();

                const $wrapper = $("<div>").css({
                    border: "1px solid #dee2e6",
                    borderRadius: "8px",
                    padding: "0 6px",
                    minHeight: "40px",
                    display: "flex",
                    alignItems: "center",
                    gap: "10px",
                    cursor: "pointer"
                }).hover(
                    () => $wrapper.css({ borderColor: "#0d6efd", boxShadow: "0 0 0 0.2rem rgba(13,110,253,.15)" }),
                    () => $wrapper.css({ borderColor: "#dee2e6", boxShadow: "none" })
                );

                if (!%ColumnName%%UID%SelectedId) {
                    $wrapper.append($("<span>").addClass("text-muted").html("<i class=\"bi bi-person-plus me-2\"></i>Chọn nhân viên..."));
                } else {
                    const item = window["DataSource_%ColumnName%"].find(e => String(e.ID) === String(%ColumnName%%UID%SelectedId));
                    if (!item) {
                        $wrapper.append($("<span>").addClass("text-muted").text("Nhân viên không tồn tại"));
                    } else {
                        const name = item.Name || item.FullName || "?";
                        
                        const $avatar = $("<div>").css({
                            width: "40px", height: "40px", borderRadius: "50%",
                            boxShadow: "0 2px 6px rgba(0,0,0,0.15)",
                            display: "flex", alignItems: "center", justifyContent: "center",
                            fontWeight: "600", fontSize: "14px",
                            position: "relative", overflow: "hidden",
                            flexShrink: 0
                        });

                        const cachedUrl = window.GlobalEmployeeAvatarCache[String(%ColumnName%%UID%SelectedId)];

                        if (cachedUrl) {
                            $avatar.append($("<img>")
                                .attr("src", cachedUrl)
                                .css({ width: "100%", height: "100%", objectFit: "cover" })
                            );
                        } else if (item.storeImgName) {
                            loadGlobalAvatarIfNeeded%ColumnName%%UID%(%ColumnName%%UID%SelectedId, item.storeImgName, item.paramImg, function(url) {
                                renderDisplayBox%ColumnName%();
                            });
                            
                            const color = getColorForId%ColumnName%(%ColumnName%%UID%SelectedId);
                            const initials = getInitials%ColumnName%(name);
                            $avatar.css({ background: color.bg, color: color.text }).text(initials);
                        } else {
                            const color = getColorForId%ColumnName%(%ColumnName%%UID%SelectedId);
                            const initials = getInitials%ColumnName%(name);
                            $avatar.css({ background: color.bg, color: color.text }).text(initials);
                        }

                        const $info = $("<div>").css({ flex: 1, overflow: "hidden" });
                        $info.append($("<div>").css({ fontWeight: "500", fontSize: "14px", overflow: "hidden", textOverflow: "ellipsis", whiteSpace: "nowrap" }).text(name));
                        if (item.Position) {
                            $info.append($("<div>").css({ fontSize: "12px", color: "#6c757d", overflow: "hidden", textOverflow: "ellipsis", whiteSpace: "nowrap" }).text(item.Position));
                        }

                        $wrapper.append($avatar).append($info);
                    }
                }

                $displayBox%ColumnName%.append($wrapper);
                $wrapper.off("click").on("click", () => {
                    // Feature: ReadOnly Check
                    if (_readOnly%ColumnName%%UID%) return;
                    
                    if (!popup%ColumnName%) {
                        initPopup%ColumnName%();
                        // Đợi popup init xong rồi mới show
                        setTimeout(() => {
                            popup%ColumnName%.show();
                        }, 0);
                    } else {
                        popup%ColumnName%.show();
                    }
                });
            }

            const $container%ColumnName% = $("#%UID%");
            $container%ColumnName%.empty();
            const $displayBox%ColumnName% = $("<div>").attr("id", "%ColumnName%%UID%_display");
            $container%ColumnName%.append($displayBox%ColumnName%);

            let popup%ColumnName%;
            let popup%ColumnName%Once = false;
            let %ColumnName%%UID%GridContainer = null;
            function initPopup%ColumnName%() {
                if (popup%ColumnName%Once) {
                    popup%ColumnName%.show();
                    return;
                }
                popup%ColumnName%Once = true;
                popup%ColumnName% = $("<div>").attr("id", "%ColumnName%%UID%_popup")
                    .appendTo(document.body)
                    .addClass("hpa-responsive")
                    .dxPopup({
                        width: 750,
                        height: "auto",
                        animation: null,
                        showTitle: true,
                        title: "Chọn nhân viên",
                        dragEnabled: true,
                        closeOnOutsideClick: true,
                        showCloseButton: true,
                        toolbarItems: [
                            {
                                widget: "dxButton",
                                location: "after",
                                toolbar: "bottom",
                                options: {
                                    text: "Hủy",
                                    onClick: () => {
                                        %ColumnName%%UID%SelectedId = %ColumnName%%UID%SelectedIdOriginal;
                                        popup%ColumnName%.hide();
                                    }
                                }
                            },
                            {
                                widget: "dxButton",
                                location: "after",
                                toolbar: "bottom",
                                options: {
                                    text: "Lưu",
                                    type: "success",
                                    onClick: async () => {
                                        // Feature: AutoSave Check
                                        if (_autoSave%ColumnName%%UID% && typeof saveValue%ColumnName% === "function") {
                                            await saveValue%ColumnName%(); 
                                        } else {
                                            // Local Save (Sync Grid)
                                            if (typeof cellInfo !== "undefined" && cellInfo && cellInfo.component) {
                                                try {
                                                    const grid = cellInfo.component;
                                                    grid.cellValue(cellInfo.rowIndex, "%ColumnName%", %ColumnName%%UID%SelectedId || null);
                                                    grid.repaint();
                                                } catch (e) { console.warn(e); }
                                            }
                                            %ColumnName%%UID%SelectedIdOriginal = %ColumnName%%UID%SelectedId;
                                            renderDisplayBox%ColumnName%();
                                        }
                                        popup%ColumnName%.hide();
                                    }
                                }
                            }
                        ],
                        contentTemplate: function (contentElement) {
                            %ColumnName%%UID%GridContainer = $("<div>");
                            contentElement.append(%ColumnName%%UID%GridContainer);
                        },
                        onShown: () => {
                            const sortedData = window["DataSource_%ColumnName%"].sort((a, b) => {
                                const aSelected = String(a.ID) === String(%ColumnName%%UID%SelectedId);
                                const bSelected = String(b.ID) === String(%ColumnName%%UID%SelectedId);
                                return bSelected - aSelected;
                            });

                            // Destroy instance cũ nếu tồn tại
                            try {
                                const existingInstance = %ColumnName%%UID%GridContainer.dxDataGrid("instance");
                                if (existingInstance) {
                                    existingInstance.dispose();
                                }
                            } catch (e) {
                                // Instance chưa tồn tại hoặc đã bị destroy
                            }

                            %ColumnName%%UID%GridContainer
                            .empty()
                            .dxDataGrid({
                                dataSource: sortedData,
                                keyExpr: "ID",
                                remoteOperations: false,
                                columnAutoWidth: true,
                                allowColumnResizing: true,
                                selection: { mode: "single" },
                                selectedRowKeys: %ColumnName%%UID%SelectedId ? [%ColumnName%%UID%SelectedId] : [],
                                hoverStateEnabled: true,
                                onRowPrepared: function(e) {
                                    if (e.rowType === "data") {
                                        e.rowElement.css("cursor", "pointer");
                                    }
                                },
                                columns: [
                                    {
                                        caption: "Ảnh",
                                        width: 80,
                                        alignment: "center",
                                        cellTemplate: function(container, options) {
                                            const item = options.data;
                                            const $cell = $("<div>").css({
                                                display: "flex",
                                                justifyContent: "center",
                                                alignItems: "center",
                                                height: "100%"
                                            });

                                            const cachedUrl = window.GlobalEmployeeAvatarCache[String(item.ID)];

                                            if (cachedUrl) {
                                                $cell.append($("<img>")
                                                    .attr("src", cachedUrl)
                                                    .css({
                                                        width: "40px",
                                                        height: "40px",
                                                        borderRadius: "50%",
                                                        objectFit: "cover",
                                                        border: "2px solid #fff",
                                                        boxShadow: "0 2px 4px rgba(0,0,0,0.1)"
                                                    })
                                                );
                                            } else if (item.storeImgName) {
                                                loadGlobalAvatarIfNeeded%ColumnName%%UID%(item.ID, item.storeImgName, item.paramImg, function(url) {
                                                    %ColumnName%%UID%GridContainer.dxDataGrid("instance").refresh();
                                                });
                                                
                                                const initials = getInitials%ColumnName%(item.Name || item.FullName || "?");
                                                const color = getColorForId%ColumnName%(item.ID);
                                                $cell.append($("<div>")
                                                    .text(initials)
                                                    .css({
                                                        width: "40px",
                                                        height: "40px",
                                                        borderRadius: "50%",
                                                        background: color.bg,
                                                        color: color.text,
                                                        display: "flex",
                                                        justifyContent: "center",
                                                        alignItems: "center",
                                                        fontWeight: "600",
                                                        fontSize: "14px",
                                                        boxShadow: "0 2px 4px rgba(0,0,0,0.1)"
                                                    })
                                                );
                                            } else {
                                                const initials = getInitials%ColumnName%(item.Name || item.FullName || "?");
                                                const color = getColorForId%ColumnName%(item.ID);
                                                $cell.append($("<div>")
                                                    .text(initials)
                                                    .css({
                                                        width: "40px",
                                                        height: "40px",
                                                        borderRadius: "50%",
                                                        background: color.bg,
                                                        color: color.text,
                                                        display: "flex",
                                                        justifyContent: "center",
                                                        alignItems: "center",
                                                        fontWeight: "600",
                                                        fontSize: "14px",
                                                        boxShadow: "0 2px 4px rgba(0,0,0,0.1)"
                                                    })
                                                );
                                            }

                                            container.append($cell);
                                        }
                                    },
                                    { dataField: "Name", caption: "Họ tên" },
                                    { dataField: "Email", caption: "Email" },
                                    { dataField: "Position", caption: "Chức vụ" }
                                ],
                                searchPanel: { 
                                    visible: true
                                },
                                onContentReady: function(e) {
                                    const grid = e.component;
                                    
                                    // Clear default search behavior
                                    grid.option("searchPanel.text", "");
                                    
                                    const searchBox = grid.getView("headerPanel")._$element.find(".dx-datagrid-search-panel input");
                                    
                                    if (searchBox.length) {
                                        const $searchWrapper = searchBox.parent();
                                        if (!$("#custom-search-style-%ColumnName%%UID%").length) {
                                            $("<style>")
                                                .attr("id", "custom-search-style-%ColumnName%%UID%")
                                                .text(`
                                                    .dx-datagrid-search-panel input:not(:placeholder-shown) {
                                                        color: #000 !important;
                                                    }
                                                    .dx-datagrid-search-panel input::placeholder {
                                                        color: #999 !important;
                                                        opacity: 1 !important;
                                                    }
                                                `)
                                                .appendTo("head");
                                        }
                                        
                                        // Unbind ALL events
                                        searchBox.off();
                                        
                                        // Bind custom event
                                        searchBox.on("input", function() {
                                            const searchValue = $(this).val();
                                            
                                            if (!searchValue) {
                                                grid.clearFilter();
                                                return;
                                            }
                                            
                                            const searchNormalized = RemoveToneMarks_Js(searchValue);

                                            grid.filter(function(item) {
                                                const fields = ["Name", "Email", "Position"];
                                                for (let i = 0; i < fields.length; i++) {
                                                    const fieldValue = item[fields[i]];
                                                    if (fieldValue) {
                                                        const fieldNormalized = RemoveToneMarks_Js(String(fieldValue));
                                                        if (fieldNormalized.indexOf(searchNormalized) !== -1) {
                                                            return true;
                                                        }
                                                    }
                                                }
                                                return false;
                                            });
                                        });
                                    }
                                },
                                paging: { 
                                    enabled: true,
                                    pageSize: 5,
                                    pageIndex: 0
                                },
                                pager: {
                                    visible: true,
                                    allowedPageSizes: [5, 10],
                                    showPageSizeSelector: true,
                                    showInfo: true,
                                    showNavigationButtons: true
                                },
                                onSelectionChanged: e => %ColumnName%%UID%SelectedId = (e.selectedRowKeys && e.selectedRowKeys[0]) || null
                            });
                        },
                        onHidden: () => {
                            // Dispose grid instance
                            try {
                                const gridInstance = %ColumnName%%UID%GridContainer.dxDataGrid("instance");
                                if (gridInstance) {
                                    gridInstance.dispose();
                                }
                            } catch (e) {
                                // Grid chưa được khởi tạo hoặc đã dispose
                            }
                            
                            // Reset position của popup về default
                            popup%ColumnName%.option("position", { my: "center", at: "center", of: window });
                            
                            renderDisplayBox%ColumnName%();
                        }
                    }).dxPopup("instance");
            }

            async function saveValue%ColumnName%() {
                const original = String(%ColumnName%%UID%SelectedIdOriginal || "");
                const current = String(%ColumnName%%UID%SelectedId || "");
                if (original === current) return;

                try {
                    const newValue = %ColumnName%%UID%SelectedId || null;
                    const dataJSON = JSON.stringify(["%tableId%", ["%ColumnName%"], [newValue]]);

                    let idValues = [currentRecordID_%ColumnIDName%];
                    let idFields = ["%ColumnIDName%"];
                    if ("%ColumnIDName2%" && "%ColumnIDName2%".trim() !== "") {
                        idValues.push(currentRecordID_%ColumnIDName2%);
                        idFields.push("%ColumnIDName2%");
                    }
                    const idValsJSON = JSON.stringify([idValues, idFields]);

                    const json = await saveFunction(dataJSON, idValsJSON);
                    const errors = json.data?.[json.data.length - 1] || [];
                    if (errors.length > 0 && errors[0].Status === "ERROR") {
                        if ("%IsAlert%" === "1") {
                            uiManager.showAlert({ type: "error", message: errors[0].Message || "Lưu thất bại" });
                        }
                        return;
                    }

                    // SYNC GRID: Cập nhật lại giá trị trong Grid sau khi save thành công
                    if (typeof cellInfo !== "undefined" && cellInfo && cellInfo.component) {
                        try {
                            const grid = cellInfo.component;
                            grid.cellValue(cellInfo.rowIndex, "%ColumnName%", newValue);
                            grid.repaint();
                        } catch (syncErr) {
                            console.warn("[Grid Sync] SelectBox %ColumnName%%UID%: Không thể sync grid:", syncErr);
                        }
                    }

                    %ColumnName%%UID%SelectedIdOriginal = %ColumnName%%UID%SelectedId;
                    if ("%IsAlert%" === "1") {
                        uiManager.showAlert({ type: "success", message: "Lưu thành công" });
                    }
                    renderDisplayBox%ColumnName%();
                } catch (err) {
                    if ("%IsAlert%" === "1") {
                        uiManager.showAlert({ type: "error", message: "Có lỗi khi lưu" });
                    }
                }
            }

            Instance%ColumnName%%UID% = {
                setValue: function(val) {
                    if (val !== null && val !== undefined && val !== "") {
                        %ColumnName%%UID%SelectedId = String(val);
                    } else {
                        %ColumnName%%UID%SelectedId = null;
                    }
                    %ColumnName%%UID%SelectedIdOriginal = %ColumnName%%UID%SelectedId;
                    renderDisplayBox%ColumnName%();
                },
                getValue: () => %ColumnName%%UID%SelectedId,
                getValueAsString: () => %ColumnName%%UID%SelectedId || "",
                setDataSource: data => {
                    window["DataSource_%ColumnName%"] = data || [];
                },
                repaint: renderDisplayBox%ColumnName%,
                option: function(name, value) {
                    if (arguments.length === 2 && name === "value") {
                        this.setValue(value);
                    } else if (arguments.length === 1) {
                        if (name === "value") return this.getValueAsString();
                        if (name === "dataSource") return window["DataSource_%ColumnName%"];
                    }
                    return undefined;
                },
                _suppressValueChangeAction: function() {},
                _resumeValueChangeAction: function() {}
            };
        '
    WHERE [Type] = 'hpaControlSelectEmployee' AND [AutoSave] = 0 AND [ReadOnly] = 0 AND [IsMultiSelectEmployee] = 0;
END