USE Paradise_Beta_Tai2
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

            function loadGlobalAvatarIfNeeded%columnName%(employeeId, storeImgName, paramImg, callbackFn) {
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
            let spNameDSE%columnName% = "%DataSourceSP%";
            let %columnName%DataSourceLoaded = false;



            let %columnName%SelectedIds = [];
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

            function renderDisplay%ColumnName%() {
                const $container%ColumnName% = $("#%UID%");
                $container%ColumnName%.empty();
                const $wrapper = $("<div>").css({
                    padding: "10px 12px",
                    borderRadius: "8px",
                    minHeight: "44px",
                    display: "flex",
                    alignItems: "center",
                    gap: "8px",
                    flexWrap: "wrap"
                });

                if (%columnName%SelectedIds.length === 0) {
                    $wrapper.append($("<span>").addClass("text-muted").text("Chưa gán nhân viên"));
                } else {
                    const visible = %columnName%SelectedIds.slice(0, MAX_VISIBLE_%ColumnName%);
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
                            loadGlobalAvatarIfNeeded%columnName%(id, item.storeImgName, item.paramImg, function(url) {
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

                    if (%columnName%SelectedIds.length > MAX_VISIBLE_%ColumnName%) {
                        const more = %columnName%SelectedIds.length - MAX_VISIBLE_%ColumnName%;
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

            window.Instance%columnName% = {
                setValue: function(val) {
                    if (typeof val === "string" && val.trim()) {
                        %columnName%SelectedIds = val.split(",").map(v => v.trim()).filter(v => v);
                    } else if (Array.isArray(val)) {
                        %columnName%SelectedIds = val.map(String);
                    } else {
                        %columnName%SelectedIds = [];
                    }
                    renderDisplay%ColumnName%();
                },
                getValue: () => %columnName%SelectedIds,
                getValueAsString: () => %columnName%SelectedIds.join(","),
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

            renderDisplay%ColumnName%();
        '
    WHERE [Type] = 'hpaControlSelectEmployee' AND [ReadOnly] = 1;

    -- =============================================
    -- 2. AUTOSAVE MODE
    -- =============================================
    UPDATE #temptable SET
        loadUI = N'
            window.GlobalEmployeeAvatarCache = window.GlobalEmployeeAvatarCache || {};
            window.GlobalEmployeeAvatarLoading = window.GlobalEmployeeAvatarLoading || {};

            function loadGlobalAvatarIfNeeded%columnName%(employeeId, storeImgName, paramImg, callbackFn) {
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
            let %columnName%DataSourceLoaded = false;
            let spNameDSE%columnName% = "%DataSourceSP%";

            window.Instance%columnName% = {};
            let %columnName%SelectedIds = [], %columnName%SelectedIdsOriginal = [];
            let %columnName%IsSaving = false;
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
                const $displayBox%ColumnName% = $("#%columnName%_display");
                if (!$displayBox%ColumnName%.length) return;
                $displayBox%ColumnName%.empty();

                const $wrapper = $("<div>").css({
                    border: "1px solid #dee2e6",
                    borderRadius: "8px",
                    padding: "10px 12px",
                    minHeight: "44px",
                    display: "flex",
                    alignItems: "center",
                    cursor: "pointer"
                }).hover(
                    () => $wrapper.css({ borderColor: "#0d6efd", boxShadow: "0 0 0 0.2rem rgba(13,110,253,.15)" }),
                    () => $wrapper.css({ borderColor: "#dee2e6", boxShadow: "none" })
                );

                if (%columnName%SelectedIds.length === 0) {
                    $wrapper.append($("<span>").addClass("text-muted").html("<i class=\"bi bi-person-plus me-2\"></i>Chọn nhân viên..."));
                } else {
                    const displayIds = %columnName%SelectedIds.slice(0, MAX_VISIBLE_%ColumnName%);
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
                            loadGlobalAvatarIfNeeded%columnName%(id, item.storeImgName, item.paramImg, function(url) {
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

                    if (%columnName%SelectedIds.length > MAX_VISIBLE_%ColumnName%) {
                        const remaining = %columnName%SelectedIds.length - MAX_VISIBLE_%ColumnName%;
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
            const $displayBox%ColumnName% = $("<div>").attr("id", "%columnName%_display");
            $container%ColumnName%.append($displayBox%ColumnName%);

            let popup%ColumnName%;
            let popup%ColumnName%Once = false;
            let %columnName%GridContainer = null;
            function initPopup%ColumnName%() {
                if (popup%ColumnName%Once) {
                    popup%ColumnName%.show();
                    return;
                }
                popup%ColumnName%Once = true;
                popup%ColumnName% = $("<div>").attr("id", "%columnName%_popup")
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
                                        %columnName%SelectedIds = [...%columnName%SelectedIdsOriginal];
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
                            %columnName%GridContainer = $("<div>");
                            contentElement.append(%columnName%GridContainer);
                        },
                        onShown: () => {
                            setTimeout(() => {
                                const $popupContent = $("#%columnName%_popup").closest(".dx-popup-wrapper");
                                $popupContent.off("mousedown.preventClose").on("mousedown.preventClose", function(e) {
                                    console.log("Preventing popup close on outside click");
                                    e.stopPropagation();
                                });
                            }, 100);

                            const sortedData = window["DataSource_%ColumnName%"].sort((a, b) => {
                                const aSelected = %columnName%SelectedIds.includes(String(a.ID));
                                const bSelected = %columnName%SelectedIds.includes(String(b.ID));
                                return bSelected - aSelected;
                            });

                            try {
                                const existingInstance = %columnName%GridContainer.dxDataGrid("instance");
                                if (existingInstance) {
                                    existingInstance.dispose();
                                }
                            } catch (e) {
                                // Instance chưa tồn tại hoặc đã bị destroy
                            }

                            %columnName%GridContainer
                            .empty()
                            .dxDataGrid({
                                dataSource: sortedData,
                                keyExpr: "ID",
                                remoteOperations: false,
                                columnAutoWidth: true,
                                allowColumnResizing: true,
                                selection: { mode: "multiple", showCheckBoxesMode: "always" },
                                selectedRowKeys: %columnName%SelectedIds,
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
                                                loadGlobalAvatarIfNeeded%columnName%(item.ID, item.storeImgName, item.paramImg, function(url) {
                                                    %columnName%GridContainer.dxDataGrid("instance").refresh();
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
                                searchPanel: { visible: true },
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
                                onSelectionChanged: e => %columnName%SelectedIds = e.selectedRowKeys || []
                            });
                        },
                        onHidden: () => {
                            const $popupContent = $("#%columnName%_popup").closest(".dx-popup-wrapper");
                            $popupContent.off("mousedown.preventClose");
                            
                            // Dispose grid instance
                            try {
                                const gridInstance = %columnName%GridContainer.dxDataGrid("instance");
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
                    if (%columnName%IsSaving || e.component._isCancelling) {
                        delete e.component._isCancelling;
                        return;
                    }
                    
                    const original = %columnName%SelectedIdsOriginal.slice().sort().join(",");
                    const current = %columnName%SelectedIds.slice().sort().join(",");
                    
                    if (original !== current) {
                        e.cancel = true;
                        await saveValue%ColumnName%();
                        e.component.hide();
                    }
                });
            }

            async function saveValue%ColumnName%() {
                const original = %columnName%SelectedIdsOriginal.slice().sort().join(",");
                const current = %columnName%SelectedIds.slice().sort().join(",");
                if (original === current || %columnName%IsSaving) return;

                %columnName%IsSaving = true;
                try {
                    const newValue = %columnName%SelectedIds.join(",");
                    const dataJSON = JSON.stringify(["%tableId%", ["%columnName%"], [newValue || null]]);

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
                    if (%columnName%CellInfo && %columnName%CellInfo.component) {
                        try {
                            const grid = %columnName%CellInfo.component;
                            const rowKey = %columnName%CellInfo.key || %columnName%CellInfo.data["%ColumnIDName%"];
                            
                            // Cập nhật cell value trong grid
                            grid.cellValue(%columnName%CellInfo.rowIndex, "%columnName%", newValue);
                            
                            // Refresh cell để hiển thị giá trị mới
                            grid.repaint();

                            console.log("[Grid Sync] SelectBox %columnName%: Updated value =", newValue, "for row", rowKey);
                        } catch (syncErr) {
                            console.warn("[Grid Sync] SelectBox %columnName%: Không thể sync grid:", syncErr);
                        }
                    }

                    %columnName%SelectedIdsOriginal = [...%columnName%SelectedIds];
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

            window.Instance%columnName% = {
                setValue: function(val) {
                    if (typeof val === "string" && val.trim()) {
                        %columnName%SelectedIds = val.split(",").map(v => v.trim()).filter(v => v);
                    } else if (Array.isArray(val)) {
                        %columnName%SelectedIds = val.map(String);
                    } else {
                        %columnName%SelectedIds = [];
                    }
                    %columnName%SelectedIdsOriginal = [...%columnName%SelectedIds];
                    renderDisplayBox%ColumnName%();
                },
                getValue: () => %columnName%SelectedIds,
                getValueAsString: () => %columnName%SelectedIds.join(","),
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

            renderDisplayBox%ColumnName%();
        '
    WHERE [Type] = 'hpaControlSelectEmployee' AND [AutoSave] = 1 AND [ReadOnly] = 0 AND ([IsMultiSelectEmployee] = 1 OR [IsMultiSelectEmployee] IS NULL);

    -- =============================================
    -- 3. MANUAL MODE (No AutoSave)
    -- =============================================
    UPDATE #temptable SET
        loadUI = N'
            window.GlobalEmployeeAvatarCache = window.GlobalEmployeeAvatarCache || {};
            window.GlobalEmployeeAvatarLoading = window.GlobalEmployeeAvatarLoading || {};

            function loadGlobalAvatarIfNeeded%columnName%(employeeId, storeImgName, paramImg, callbackFn) {
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
            let %columnName%DataSourceLoaded = false;
            let spNameDSE%columnName% = "%DataSourceSP%";

            // Sử dụng hàm loadDataSourceCommon từ sptblCommonControlType_Signed
            if (spNameDSE%columnName% && spNameDSE%columnName%.trim() !== "") {
                loadDataSourceCommon("%ColumnName%", spNameDSE%columnName%, function(data) {
                    if (Instance%columnName% && typeof Instance%columnName%.setDataSource === "function") {
                        Instance%columnName%.setDataSource(data);
                    }
                });
            }

            let %columnName%SelectedIds = [], %columnName%SelectedIdsOriginal = [];
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
                const $displayBox%ColumnName% = $("#%columnName%_display");
                if (!$displayBox%ColumnName%.length) return;
                $displayBox%ColumnName%.empty();

                const $wrapper = $("<div>").css({
                    border: "1px solid #dee2e6",
                    borderRadius: "8px",
                    padding: "10px 12px",
                    minHeight: "44px",
                    display: "flex",
                    alignItems: "center",
                    cursor: "pointer"
                }).hover(
                    () => $wrapper.css({ borderColor: "#0d6efd", boxShadow: "0 0 0 0.2rem rgba(13,110,253,.15)" }),
                    () => $wrapper.css({ borderColor: "#dee2e6", boxShadow: "none" })
                );

                if (%columnName%SelectedIds.length === 0) {
                    $wrapper.append($("<span>").addClass("text-muted").html("<i class=\"bi bi-person-plus me-2\"></i>Chọn nhân viên..."));
                } else {
                    const displayIds = %columnName%SelectedIds.slice(0, MAX_VISIBLE_%ColumnName%);
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
                            loadGlobalAvatarIfNeeded%columnName%(id, item.storeImgName, item.paramImg, function(url) {
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

                    if (%columnName%SelectedIds.length > MAX_VISIBLE_%ColumnName%) {
                        const remaining = %columnName%SelectedIds.length - MAX_VISIBLE_%ColumnName%;
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
            const $displayBox%ColumnName% = $("<div>").attr("id", "%columnName%_display");
            $container%ColumnName%.append($displayBox%ColumnName%);

            let popup%ColumnName%;
            let popup%ColumnName%Once = false;
            let %columnName%GridContainer = null;
            function initPopup%ColumnName%() {
                if (popup%ColumnName%Once) {
                    popup%ColumnName%.show();
                    return;
                }
                popup%ColumnName%Once = true;
                popup%ColumnName% = $("<div>").attr("id", "%columnName%_popup")
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
                                        %columnName%SelectedIds = [...%columnName%SelectedIdsOriginal];
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
                                        %columnName%SelectedIdsOriginal = [...%columnName%SelectedIds];
                                        popup%ColumnName%.hide();
                                    }
                                }
                            }
                        ],
                        contentTemplate: function (contentElement) {
                            %columnName%GridContainer = $("<div>");
                            contentElement.append(%columnName%GridContainer);
                        },
                        onShown: () => {
                            const sortedData = window["DataSource_%ColumnName%"].sort((a, b) => {
                                const aSelected = %columnName%SelectedIds.includes(String(a.ID));
                                const bSelected = %columnName%SelectedIds.includes(String(b.ID));
                                return bSelected - aSelected;
                            });

                            try {
                                const existingInstance = %columnName%GridContainer.dxDataGrid("instance");
                                if (existingInstance) {
                                    existingInstance.dispose();
                                }
                            } catch (e) {
                                // Instance chưa tồn tại hoặc đã bị destroy
                            }

                            %columnName%GridContainer
                            .empty()
                            .dxDataGrid({
                                dataSource: sortedData,
                                keyExpr: "ID",
                                remoteOperations: false,
                                columnAutoWidth: true,
                                allowColumnResizing: true,
                                selection: { mode: "multiple", showCheckBoxesMode: "always" },
                                selectedRowKeys: %columnName%SelectedIds,
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
                                                loadGlobalAvatarIfNeeded%columnName%(item.ID, item.storeImgName, item.paramImg, function(url) {
                                                    %columnName%GridContainer.dxDataGrid("instance").refresh();
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
                                searchPanel: { visible: true },
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
                                onSelectionChanged: e => %columnName%SelectedIds = e.selectedRowKeys || []
                            });
                        },
                        onHidden: () => {
                            // Dispose grid instance
                            try {
                                const gridInstance = %columnName%GridContainer.dxDataGrid("instance");
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

            window.Instance%columnName% = {
                setValue: function(val) {
                    if (typeof val === "string" && val.trim()) {
                        %columnName%SelectedIds = val.split(",").map(v => v.trim()).filter(v => v);
                    } else if (Array.isArray(val)) {
                        %columnName%SelectedIds = val.map(String);
                    } else {
                        %columnName%SelectedIds = [];
                    }
                    %columnName%SelectedIdsOriginal = [...%columnName%SelectedIds];
                    renderDisplayBox%ColumnName%();
                },
                getValue: () => %columnName%SelectedIds,
                getValueAsString: () => %columnName%SelectedIds.join(","),
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

            renderDisplayBox%ColumnName%();
        '
    WHERE [Type] = 'hpaControlSelectEmployee' AND [AutoSave] = 0 AND [ReadOnly] = 0 AND ([IsMultiSelectEmployee] = 1 OR [IsMultiSelectEmployee] IS NULL);

    -- =============================================
    -- 4. AUTOSAVE MODE - SINGLE SELECT (IsMultiSelectEmployee = 0)
    -- =============================================
    UPDATE #temptable SET
        loadUI = N'
            window.GlobalEmployeeAvatarCache = window.GlobalEmployeeAvatarCache || {};
            window.GlobalEmployeeAvatarLoading = window.GlobalEmployeeAvatarLoading || {};

            function loadGlobalAvatarIfNeeded%columnName%(employeeId, storeImgName, paramImg, callbackFn) {
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
            let spNameDSE%columnName% = "%DataSourceSP%";

            window.Instance%columnName% = {};
            %columnName%SelectedId = null, %columnName%SelectedIdOriginal = null;

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
                const $displayBox%ColumnName% = $("#%columnName%_display");
                if (!$displayBox%ColumnName%.length) return;
                $displayBox%ColumnName%.empty();

                const $wrapper = $("<div>").css({
                    border: "1px solid #dee2e6",
                    borderRadius: "8px",
                    padding: "10px 12px",
                    minHeight: "44px",
                    display: "flex",
                    alignItems: "center",
                    gap: "10px",
                    cursor: "pointer"
                }).hover(
                    () => $wrapper.css({ borderColor: "#0d6efd", boxShadow: "0 0 0 0.2rem rgba(13,110,253,.15)" }),
                    () => $wrapper.css({ borderColor: "#dee2e6", boxShadow: "none" })
                );

                if (!%columnName%SelectedId) {
                    $wrapper.append($("<span>").addClass("text-muted").html("<i class=\"bi bi-person-plus me-2\"></i>Chọn nhân viên..."));
                } else {
                    const item = window["DataSource_%ColumnName%"].find(e => String(e.ID) === String(%columnName%SelectedId));
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

                        const cachedUrl = window.GlobalEmployeeAvatarCache[String(%columnName%SelectedId)];

                        if (cachedUrl) {
                            $avatar.append($("<img>")
                                .attr("src", cachedUrl)
                                .css({ width: "100%", height: "100%", objectFit: "cover" })
                            );
                        } else if (item.storeImgName) {
                            loadGlobalAvatarIfNeeded%columnName%(%columnName%SelectedId, item.storeImgName, item.paramImg, function(url) {
                                renderDisplayBox%ColumnName%();
                            });
                            
                            const color = getColorForId%ColumnName%(%columnName%SelectedId);
                            const initials = getInitials%ColumnName%(name);
                            $avatar.css({ background: color.bg, color: color.text }).text(initials);
                        } else {
                            const color = getColorForId%ColumnName%(%columnName%SelectedId);
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
            const $displayBox%ColumnName% = $("<div>").attr("id", "%columnName%_display");
            $container%ColumnName%.append($displayBox%ColumnName%);

            let popup%ColumnName%;
            let popup%ColumnName%Once = false;
            let %columnName%GridContainer = null;
            function initPopup%ColumnName%() {
                if (popup%ColumnName%Once) {
                    popup%ColumnName%.show();
                    return;
                }
                popup%ColumnName%Once = true;
                popup%ColumnName% = $("<div>").attr("id", "%columnName%_popup")
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
                                        %columnName%SelectedId = %columnName%SelectedIdOriginal;
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
                            %columnName%GridContainer = $("<div>");
                            contentElement.append(%columnName%GridContainer);
                        },
                        onShown: () => {
                            setTimeout(() => {
                                const $popupContent = $("#%columnName%_popup").closest(".dx-popup-wrapper");
                                $popupContent.off("mousedown.preventClose").on("mousedown.preventClose", function(e) {
                                    e.stopPropagation();
                                });
                            }, 100);

                            const sortedData = window["DataSource_%ColumnName%"].sort((a, b) => {
                                const aSelected = String(a.ID) === String(%columnName%SelectedId);
                                const bSelected = String(b.ID) === String(%columnName%SelectedId);
                                return bSelected - aSelected;
                            });

                            // Destroy instance cũ nếu tồn tại
                            try {
                                const existingInstance = %columnName%GridContainer.dxDataGrid("instance");
                                if (existingInstance) {
                                    existingInstance.dispose();
                                }
                            } catch (e) {
                                // Instance chưa tồn tại hoặc đã bị destroy
                            }

                            %columnName%GridContainer
                            .empty()
                            .dxDataGrid({
                                dataSource: sortedData,
                                keyExpr: "ID",
                                remoteOperations: false,
                                columnAutoWidth: true,
                                allowColumnResizing: true,
                                selection: { mode: "single" },
                                selectedRowKeys: %columnName%SelectedId ? [%columnName%SelectedId] : [],
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
                                                loadGlobalAvatarIfNeeded%columnName%(item.ID, item.storeImgName, item.paramImg, function(url) {
                                                    %columnName%GridContainer.dxDataGrid("instance").refresh();
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
                                searchPanel: { visible: true },
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
                                    %columnName%SelectedId = keys.length > 0 ? String(keys[0]) : null;
                                }
                            });
                        },
                        onHidden: () => {
                            const $popupContent = $("#%columnName%_popup").closest(".dx-popup-wrapper");
                            $popupContent.off("mousedown.preventClose");
                            
                            try {
                                const gridInstance = %columnName%GridContainer.dxDataGrid("instance");
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
                    
                    const original = String(%columnName%SelectedIdOriginal || "");
                    const current = String(%columnName%SelectedId || "");
                    
                    if (original !== current) {
                        e.cancel = true;
                        await saveValue%ColumnName%();
                        e.component.hide();
                    }
                });
            }

            async function saveValue%ColumnName%() {
                const original = String(%columnName%SelectedIdOriginal || "");
                const current = String(%columnName%SelectedId || "");
                if (original === current) return;

                try {
                    const newValue = %columnName%SelectedId || null;
                    const dataJSON = JSON.stringify(["%tableId%", ["%columnName%"], [newValue]]);

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
                    if (%columnName%CellInfo && %columnName%CellInfo.component) {
                        try {
                            const grid = %columnName%CellInfo.component;
                            const rowKey = %columnName%CellInfo.key || %columnName%CellInfo.data["%ColumnIDName%"];
                            
                            grid.cellValue(%columnName%CellInfo.rowIndex, "%columnName%", newValue);
                            grid.repaint();

                            console.log("[Grid Sync] SelectBox %columnName%: Updated value =", newValue, "for row", rowKey);
                        } catch (syncErr) {
                            console.warn("[Grid Sync] SelectBox %columnName%: Không thể sync grid:", syncErr);
                        }
                    }

                    %columnName%SelectedIdOriginal = %columnName%SelectedId;
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

            window.Instance%columnName% = {
                setValue: function(val) {
                    if (val !== null && val !== undefined && val !== "") {
                        %columnName%SelectedId = String(val);
                    } else {
                        %columnName%SelectedId = null;
                    }
                    %columnName%SelectedIdOriginal = %columnName%SelectedId;
                    renderDisplayBox%ColumnName%();
                },
                getValue: () => %columnName%SelectedId,
                getValueAsString: () => %columnName%SelectedId || "",
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

            renderDisplayBox%ColumnName%();
        '
    WHERE [Type] = 'hpaControlSelectEmployee' AND [AutoSave] = 1 AND [ReadOnly] = 0 AND [IsMultiSelectEmployee] = 0;

    -- =============================================
    -- 5. MANUAL MODE (No AutoSave) - SINGLE SELECT (IsMultiSelectEmployee = 0)
    -- =============================================
    UPDATE #temptable SET
        loadUI = N'
            window.GlobalEmployeeAvatarCache = window.GlobalEmployeeAvatarCache || {};
            window.GlobalEmployeeAvatarLoading = window.GlobalEmployeeAvatarLoading || {};

            function loadGlobalAvatarIfNeeded%columnName%(employeeId, storeImgName, paramImg, callbackFn) {
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
            let spNameDSE%columnName% = "%DataSourceSP%";

            window.Instance%columnName% = {};
            let %columnName%SelectedId = null, %columnName%SelectedIdOriginal = null;

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
                const $displayBox%ColumnName% = $("#%columnName%_display");
                if (!$displayBox%ColumnName%.length) return;
                $displayBox%ColumnName%.empty();

                const $wrapper = $("<div>").css({
                    border: "1px solid #dee2e6",
                    borderRadius: "8px",
                    padding: "10px 12px",
                    minHeight: "44px",
                    display: "flex",
                    alignItems: "center",
                    gap: "10px",
                    cursor: "pointer"
                }).hover(
                    () => $wrapper.css({ borderColor: "#0d6efd", boxShadow: "0 0 0 0.2rem rgba(13,110,253,.15)" }),
                    () => $wrapper.css({ borderColor: "#dee2e6", boxShadow: "none" })
                );

                if (!%columnName%SelectedId) {
                    $wrapper.append($("<span>").addClass("text-muted").html("<i class=\"bi bi-person-plus me-2\"></i>Chọn nhân viên..."));
                } else {
                    const item = window["DataSource_%ColumnName%"].find(e => String(e.ID) === String(%columnName%SelectedId));
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

                        const cachedUrl = window.GlobalEmployeeAvatarCache[String(%columnName%SelectedId)];

                        if (cachedUrl) {
                            $avatar.append($("<img>")
                                .attr("src", cachedUrl)
                                .css({ width: "100%", height: "100%", objectFit: "cover" })
                            );
                        } else if (item.storeImgName) {
                            loadGlobalAvatarIfNeeded%columnName%(%columnName%SelectedId, item.storeImgName, item.paramImg, function(url) {
                                renderDisplayBox%ColumnName%();
                            });
                            
                            const color = getColorForId%ColumnName%(%columnName%SelectedId);
                            const initials = getInitials%ColumnName%(name);
                            $avatar.css({ background: color.bg, color: color.text }).text(initials);
                        } else {
                            const color = getColorForId%ColumnName%(%columnName%SelectedId);
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
            const $displayBox%ColumnName% = $("<div>").attr("id", "%columnName%_display");
            $container%ColumnName%.append($displayBox%ColumnName%);

            let popup%ColumnName%;
            let popup%ColumnName%Once = false;
            let %columnName%GridContainer = null;
            function initPopup%ColumnName%() {
                if (popup%ColumnName%Once) {
                    popup%ColumnName%.show();
                    return;
                }
                popup%ColumnName%Once = true;
                popup%ColumnName% = $("<div>").attr("id", "%columnName%_popup")
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
                                        %columnName%SelectedId = %columnName%SelectedIdOriginal;
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
                                        popup%ColumnName%.hide();
                                    }
                                }
                            }
                        ],
                        contentTemplate: function (contentElement) {
                            %columnName%GridContainer = $("<div>");
                            contentElement.append(%columnName%GridContainer);
                        },
                        onShown: () => {
                            const sortedData = window["DataSource_%ColumnName%"].sort((a, b) => {
                                const aSelected = String(a.ID) === String(%columnName%SelectedId);
                                const bSelected = String(b.ID) === String(%columnName%SelectedId);
                                return bSelected - aSelected;
                            });

                            // Destroy instance cũ nếu tồn tại
                            try {
                                const existingInstance = %columnName%GridContainer.dxDataGrid("instance");
                                if (existingInstance) {
                                    existingInstance.dispose();
                                }
                            } catch (e) {
                                // Instance chưa tồn tại hoặc đã bị destroy
                            }

                            %columnName%GridContainer
                            .empty()
                            .dxDataGrid({
                                dataSource: sortedData,
                                keyExpr: "ID",
                                remoteOperations: false,
                                columnAutoWidth: true,
                                allowColumnResizing: true,
                                selection: { mode: "single" },
                                selectedRowKeys: %columnName%SelectedId ? [%columnName%SelectedId] : [],
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
                                                loadGlobalAvatarIfNeeded%columnName%(item.ID, item.storeImgName, item.paramImg, function(url) {
                                                    %columnName%GridContainer.dxDataGrid("instance").refresh();
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
                                searchPanel: { visible: true },
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
                                onSelectionChanged: e => %columnName%SelectedId = (e.selectedRowKeys && e.selectedRowKeys[0]) || null
                            });
                        },
                        onHidden: () => {
                            // Dispose grid instance
                            try {
                                const gridInstance = %columnName%GridContainer.dxDataGrid("instance");
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

            window.Instance%columnName% = {
                setValue: function(val) {
                    if (val !== null && val !== undefined && val !== "") {
                        %columnName%SelectedId = String(val);
                    } else {
                        %columnName%SelectedId = null;
                    }
                    %columnName%SelectedIdOriginal = %columnName%SelectedId;
                    renderDisplayBox%ColumnName%();
                },
                getValue: () => %columnName%SelectedId,
                getValueAsString: () => %columnName%SelectedId || "",
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

            renderDisplayBox%ColumnName%();
        '
    WHERE [Type] = 'hpaControlSelectEmployee' AND [AutoSave] = 0 AND [ReadOnly] = 0 AND [IsMultiSelectEmployee] = 0;
END