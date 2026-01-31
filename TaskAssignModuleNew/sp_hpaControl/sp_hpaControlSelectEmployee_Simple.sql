USE Paradise_Dev
GO
if object_id('[dbo].[sp_hpaControlSelectEmployee]') is null
	EXEC ('CREATE PROCEDURE [dbo].[sp_hpaControlSelectEmployee] as select 1')
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
            let Instance%ColumnName%%UID% = {};
            window["DataSource_%ColumnName%"] = window["DataSource_%ColumnName%"] || [];
            let %ColumnName%%UID%SelectedIds = [];
            const MAX_VISIBLE_%ColumnName% = 3;

            // Load datasource
            if ("%DataSourceSP%".trim()) {
                loadDataSourceCommon("%ColumnName%", "%DataSourceSP%", function(data) {
                    window["DataSource_%ColumnName%"] = data || [];
                    if (Array.isArray(data)) {
                        data.forEach(emp => hpaUtils.loadAvatar(emp.ID, emp.StoreImgName, emp.ImgParamV));
                    }
                    render%ColumnName%();
                });
            }

            function render%ColumnName%() {
                const $c = $("#%UID%");
                if (!$c.length) return;
                
                $c.empty();
                
                if (!%ColumnName%%UID%SelectedIds.length) {
                    $c.append(`<div style="border-radius:8px;padding:0 6px;min-height:40px;display:flex;align-items:center">
                        <span class="text-muted">Chưa có nhân viên</span>
                    </div>`);
                    return;
                }

                const visible = %ColumnName%%UID%SelectedIds.slice(0, MAX_VISIBLE_%ColumnName%);
                const ds = window["DataSource_%ColumnName%"];
                
                let html = `<div style="border-radius:8px;padding:0 6px;min-height:40px;display:flex;align-items:center;gap:8px;flex-wrap:wrap">
                    <div style="display:flex;align-items:center">`;
                
                visible.forEach((id, i) => {
                    const item = ds.find(e => String(e.ID) === String(id));
                    const name = item ? (item.Name || item.FullName || "?") : "?";
                    const cachedUrl = window.GlobalEmployeeAvatarCache?.[String(id)];
                    const zIndex = 10 - i;
                    const ml = i === 0 ? "0" : "-10px";
                    
                    if (cachedUrl) {
                        html += `<div style="width:36px;height:36px;border-radius:50%;border:3px solid #fff;box-shadow:0 2px 6px rgba(0,0,0,0.15);margin-left:${ml};z-index:${zIndex};overflow:hidden" title="${name}">
                            <img src="${cachedUrl}" style="width:100%;height:100%;object-fit:cover"/>
                        </div>`;
                    } else {
                        const color = hpaUtils.getColorForId(id);
                        const initials = hpaUtils.getInitials(name);
                        html += `<div style="width:36px;height:36px;border-radius:50%;border:3px solid #fff;box-shadow:0 2px 6px rgba(0,0,0,0.15);margin-left:${ml};z-index:${zIndex};background:${color.bg};color:${color.text};display:flex;align-items:center;justify-content:center;font-weight:600;font-size:13px" title="${name}">${initials}</div>`;
                        
                        if (item?.storeImgName) {
                            hpaUtils.loadAvatar(id, item.storeImgName, item.paramImg, () => render%ColumnName%());
                        }
                    }
                });

                if (%ColumnName%%UID%SelectedIds.length > MAX_VISIBLE_%ColumnName%) {
                    const more = %ColumnName%%UID%SelectedIds.length - MAX_VISIBLE_%ColumnName%;
                    html += `<div style="width:36px;height:36px;border-radius:50%;border:3px solid #fff;margin-left:-10px;display:flex;align-items:center;justify-content:center;font-weight:700;font-size:12px" title="Còn ${more} người nữa">+${more}</div>`;
                }
                
                html += `</div></div>`;
                $c.html(html);
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
                    render%ColumnName%();
                },
                getValue: () => %ColumnName%%UID%SelectedIds,
                getValueAsString: () => %ColumnName%%UID%SelectedIds.join(","),
                repaint: render%ColumnName%,
                option: function(name, value) {
                    if (arguments.length === 2 && name === "value") this.setValue(value);
                    else if (arguments.length === 1 && name === "value") return this.getValueAsString();
                },
                _suppressValueChangeAction: () => {},
                _resumeValueChangeAction: () => {}
            };
        '
    WHERE [Type] = 'hpaControlSelectEmployee' AND [ReadOnly] = 1;

    -- =============================================
    -- 2. AUTOSAVE MODE - MULTI SELECT
    -- =============================================
    UPDATE #temptable SET
        loadUI = N'
            window.GlobalEmployeeAvatarCache = window.GlobalEmployeeAvatarCache || {};
            window.GlobalEmployeeAvatarLoading = window.GlobalEmployeeAvatarLoading || {};
            let Instance%ColumnName%%UID% = {};

            window["DataSource_%ColumnName%"] = window["DataSource_%ColumnName%"] || [];
            let %ColumnName%%UID%SelectedIds = [], %ColumnName%%UID%SelectedIdsOriginal = [];
            let %ColumnName%%UID%IsSaving = false;
            const MAX_VISIBLE_%ColumnName% = 3;

            // Load datasource
            if ("%DataSourceSP%".trim()) {
                loadDataSourceCommon("%ColumnName%", "%DataSourceSP%", function(data) {
                    window["DataSource_%ColumnName%"] = data || [];
                    if (Array.isArray(data)) {
                        data.forEach(emp => hpaUtils.loadAvatar(emp.ID, emp.StoreImgName, emp.ImgParamV));
                    }
                    renderDisplay%ColumnName%();
                });
            }

            function renderDisplay%ColumnName%() {
                const $box = $("#%ColumnName%%UID%_display");
                if (!$box.length) return;
                
                $box.empty();
                const $w = $("<div>").css({
                    border: "1px solid #dee2e6",
                    borderRadius: "8px",
                    padding: "0 6px",
                    minHeight: "40px",
                    display: "flex",
                    alignItems: "center",
                    cursor: "pointer"
                })
                .attr("tabIndex", "0")
                .on("keydown", e => {
                    if (e.key === "Enter" || e.key === " ") {
                        e.preventDefault();
                        showPopup%ColumnName%();
                    }
                })
                .on("focus", () => $w.css({ borderColor: "#0d6efd", boxShadow: "0 0 0 0.2rem rgba(13,110,253,.15)" }))
                .on("blur", () => $w.css({ borderColor: "#dee2e6", boxShadow: "none" }))
                .hover(
                    () => $w.css({ borderColor: "#0d6efd", boxShadow: "0 0 0 0.2rem rgba(13,110,253,.15)" }),
                    () => $w.css({ borderColor: "#dee2e6", boxShadow: "none" })
                )
                .on("click", showPopup%ColumnName%);

                if (!%ColumnName%%UID%SelectedIds.length) {
                    $w.html(\'<span class="text-muted"><i class="bi bi-person-plus me-2"></i>Chọn nhân viên...</span>\');
                } else {
                    const visible = %ColumnName%%UID%SelectedIds.slice(0, MAX_VISIBLE_%ColumnName%);
                    const ds = window["DataSource_%ColumnName%"];
                    const $g = $("<div>").css({ display: "flex", alignItems: "center" });

                    visible.forEach((id, i) => {
                        const item = ds.find(e => String(e.ID) === String(id));
                        if (!item) return;

                        const $av = $("<div>").css({
                            width: "36px", height: "36px", borderRadius: "50%",
                            border: "3px solid #fff", boxShadow: "0 2px 6px rgba(0,0,0,0.15)",
                            marginLeft: i === 0 ? "0" : "-10px", zIndex: MAX_VISIBLE_%ColumnName% - i,
                            display: "flex", alignItems: "center", justifyContent: "center",
                            fontWeight: "600", fontSize: "13px", overflow: "hidden"
                        }).attr("title", item.Name || item.FullName || "");

                        const cachedUrl = window.GlobalEmployeeAvatarCache[String(id)];
                        if (cachedUrl) {
                            $av.append(`<img src="${cachedUrl}" style="width:100%;height:100%;object-fit:cover"/>`);
                        } else {
                            const color = hpaUtils.getColorForId(id);
                            const initials = hpaUtils.getInitials(item.Name || item.FullName);
                            $av.css({ background: color.bg, color: color.text }).text(initials);
                            
                            if (item.storeImgName) {
                                hpaUtils.loadAvatar(id, item.storeImgName, item.paramImg, () => renderDisplay%ColumnName%());
                            }
                        }
                        $g.append($av);
                    });

                    if (%ColumnName%%UID%SelectedIds.length > MAX_VISIBLE_%ColumnName%) {
                        const more = %ColumnName%%UID%SelectedIds.length - MAX_VISIBLE_%ColumnName%;
                        $g.append($("<div>").css({
                            width: "36px", height: "36px", borderRadius: "50%",
                            border: "3px solid #fff", marginLeft: "-10px",
                            display: "flex", alignItems: "center", justifyContent: "center",
                            fontWeight: "700", fontSize: "12px"
                        }).text("+" + more).attr("title", "Còn " + more + " người nữa"));
                    }
                    $w.append($g);
                }
                $box.append($w);
            }

            const $container%ColumnName% = $("#%UID%");
            $container%ColumnName%.html(\'<div id="%ColumnName%%UID%_display"></div>\');

            let popup%ColumnName%, popupInit%ColumnName% = false, gridContainer%ColumnName%;

            function showPopup%ColumnName%() {
                if (!popup%ColumnName%) {
                    initPopup%ColumnName%();
                    setTimeout(() => popup%ColumnName%.show(), 0);
                } else {
                    popup%ColumnName%.show();
                }
            }

            function initPopup%ColumnName%() {
                if (popupInit%ColumnName%) return;
                popupInit%ColumnName% = true;

                popup%ColumnName% = $("<div>").attr("id", "%ColumnName%%UID%_popup")
                    .appendTo(document.body)
                    .addClass("hpa-responsive")
                    .dxPopup({
                        width: 750, height: "auto", animation: null,
                        showTitle: true, title: "Chọn nhân viên",
                        dragEnabled: true, closeOnOutsideClick: true, showCloseButton: true,
                        toolbarItems: [
                            {
                                widget: "dxButton", location: "after", toolbar: "bottom",
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
                                widget: "dxButton", location: "after", toolbar: "bottom",
                                options: {
                                    text: "Lưu", type: "success",
                                    onClick: async () => {
                                        await saveValue%ColumnName%();
                                        popup%ColumnName%.hide();
                                    }
                                }
                            }
                        ],
                        contentTemplate: function (el) {
                            gridContainer%ColumnName% = $("<div>");
                            el.append(gridContainer%ColumnName%);
                        },
                        onShown: () => {
                            const sorted = window["DataSource_%ColumnName%"].sort((a, b) => {
                                const aSel = %ColumnName%%UID%SelectedIds.includes(String(a.ID));
                                const bSel = %ColumnName%%UID%SelectedIds.includes(String(b.ID));
                                return bSel - aSel;
                            });

                            try {
                                gridContainer%ColumnName%.dxDataGrid("instance")?.dispose();
                            } catch (e) {}

                            gridContainer%ColumnName%.empty().dxDataGrid({
                                dataSource: sorted,
                                keyExpr: "ID",
                                remoteOperations: false,
                                columnAutoWidth: true,
                                allowColumnResizing: true,
                                selection: { mode: "multiple", showCheckBoxesMode: "always" },
                                selectedRowKeys: %ColumnName%%UID%SelectedIds,
                                hoverStateEnabled: true,
                                columns: [
                                    {
                                        caption: "Ảnh", width: 80, alignment: "center",
                                        cellTemplate: (c, o) => {
                                            const item = o.data;
                                            const cachedUrl = window.GlobalEmployeeAvatarCache[String(item.ID)];
                                            
                                            if (cachedUrl) {
                                                c.append(`<div style="display:flex;justify-content:center;align-items:center;height:100%">
                                                    <img src="${cachedUrl}" style="width:40px;height:40px;border-radius:50%;object-fit:cover;border:2px solid #fff;box-shadow:0 2px 4px rgba(0,0,0,0.1)"/>
                                                </div>`);
                                            } else {
                                                const color = hpaUtils.getColorForId(item.ID);
                                                const initials = hpaUtils.getInitials(item.Name || item.FullName || "?");
                                                c.append(`<div style="display:flex;justify-content:center;align-items:center;height:100%">
                                                    <div style="width:40px;height:40px;border-radius:50%;background:${color.bg};color:${color.text};display:flex;justify-content:center;align-items:center;font-weight:600;font-size:14px;box-shadow:0 2px 4px rgba(0,0,0,0.1)">${initials}</div>
                                                </div>`);
                                                
                                                if (item.storeImgName) {
                                                    hpaUtils.loadAvatar(item.ID, item.storeImgName, item.paramImg, () => {
                                                        gridContainer%ColumnName%.dxDataGrid("instance").refresh();
                                                    });
                                                }
                                            }
                                        }
                                    },
                                    { dataField: "Name", caption: "Họ tên" },
                                    { dataField: "Email", caption: "Email" },
                                    { dataField: "Position", caption: "Chức vụ" }
                                ],
                                searchPanel: { visible: true },
                                onContentReady: function(e) {
                                    const grid = e.component;
                                    const searchBox = grid.getView("headerPanel")._$element.find(".dx-datagrid-search-panel input");
                                    
                                    if (searchBox.length) {
                                        searchBox.off("input keyup").on("input", function() {
                                            const val = $(this).val();
                                            if (!val) {
                                                grid.clearFilter();
                                                return;
                                            }
                                            const norm = RemoveToneMarks_Js(val);
                                            grid.filter(item => {
                                                const fields = ["Name", "Email", "Position"];
                                                return fields.some(f => {
                                                    const fv = item[f];
                                                    return fv && RemoveToneMarks_Js(String(fv)).indexOf(norm) !== -1;
                                                });
                                            });
                                        });
                                    }
                                },
                                paging: { enabled: true, pageSize: 5 },
                                pager: { visible: true, allowedPageSizes: [5, 10], showPageSizeSelector: true },
                                onSelectionChanged: e => %ColumnName%%UID%SelectedIds = e.selectedRowKeys || []
                            });
                        },
                        onHidden: () => {
                            try {
                                gridContainer%ColumnName%.dxDataGrid("instance")?.dispose();
                            } catch (e) {}
                            renderDisplay%ColumnName%();
                        }
                    }).dxPopup("instance");

                popup%ColumnName%.on("hiding", async function(e) {
                    if (%ColumnName%%UID%IsSaving || e.component._isCancelling) {
                        delete e.component._isCancelling;
                        return;
                    }
                    const orig = %ColumnName%%UID%SelectedIdsOriginal.slice().sort().join(",");
                    const curr = %ColumnName%%UID%SelectedIds.slice().sort().join(",");
                    if (orig !== curr) {
                        e.cancel = true;
                        await saveValue%ColumnName%();
                        e.component.hide();
                    }
                });
            }

            async function saveValue%ColumnName%() {
                const orig = %ColumnName%%UID%SelectedIdsOriginal.slice().sort().join(",");
                const curr = %ColumnName%%UID%SelectedIds.slice().sort().join(",");
                if (orig === curr || %ColumnName%%UID%IsSaving) return;

                %ColumnName%%UID%IsSaving = true;
                try {
                    const newVal = %ColumnName%%UID%SelectedIds.join(",");
                    const dataJSON = JSON.stringify(["%tableId%", ["%ColumnName%"], [newVal || null]]);

                    let id1 = currentRecordID_%ColumnIDName%;
                    if (typeof cellInfo !== "undefined" && cellInfo?.data) {
                        id1 = cellInfo.data["%ColumnIDName%"] || id1;
                    }
                    let idVals = [id1], idFields = ["%ColumnIDName%"];

                    if ("%ColumnIDName2%".trim()) {
                        let id2 = currentRecordID_%ColumnIDName2%;
                        if (typeof cellInfo !== "undefined" && cellInfo?.data) {
                            id2 = cellInfo.data["%ColumnIDName2%"] || id2;
                        }
                        idVals.push(id2);
                        idFields.push("%ColumnIDName2%");
                    }
                    const idValsJSON = JSON.stringify([idVals, idFields]);

                    const json = await saveFunction(dataJSON, idValsJSON);
                    const errors = json.data?.[json.data.length - 1] || [];
                    if (errors.length > 0 && errors[0].Status === "ERROR") {
                        uiManager.showAlert({ type: "error", message: errors[0].Message || "%SaveErrorMessage%" });
                        return;
                    }

                    if (typeof cellInfo !== "undefined" && cellInfo?.component) {
                        try {
                            cellInfo.component.cellValue(cellInfo.rowIndex, "%ColumnName%", newVal);
                            cellInfo.component.repaint();
                        } catch (e) {}
                    }

                    %ColumnName%%UID%SelectedIdsOriginal = [...%ColumnName%%UID%SelectedIds];
                    renderDisplay%ColumnName%();
                } catch (err) {
                    uiManager.showAlert({ type: "error", message: "%SaveErrorMessage%" });
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
                    renderDisplay%ColumnName%();
                },
                getValue: () => %ColumnName%%UID%SelectedIds,
                getValueAsString: () => %ColumnName%%UID%SelectedIds.join(","),
                setDataSource: data => { window["DataSource_%ColumnName%"] = data || []; },
                repaint: renderDisplay%ColumnName%,
                option: function(name, value) {
                    if (arguments.length === 2 && name === "value") this.setValue(value);
                    else if (arguments.length === 1) {
                        if (name === "value") return this.getValueAsString();
                        if (name === "dataSource") return window["DataSource_%ColumnName%"];
                    }
                },
                _suppressValueChangeAction: () => {},
                _resumeValueChangeAction: () => {}
            };
        '
    WHERE [Type] = 'hpaControlSelectEmployee' AND [AutoSave] = 1 AND [ReadOnly] = 0 AND ([IsMultiSelectEmployee] = 1 OR [IsMultiSelectEmployee] IS NULL);

    -- =============================================
    -- 3. MANUAL MODE - MULTI SELECT
    -- =============================================
    UPDATE #temptable SET
        loadUI = N'
            window.GlobalEmployeeAvatarCache = window.GlobalEmployeeAvatarCache || {};
            window.GlobalEmployeeAvatarLoading = window.GlobalEmployeeAvatarLoading || {};
            let Instance%ColumnName%%UID% = {};

            window["DataSource_%ColumnName%"] = window["DataSource_%ColumnName%"] || [];
            let %ColumnName%%UID%SelectedIds = [], %ColumnName%%UID%SelectedIdsOriginal = [];
            const MAX_VISIBLE_%ColumnName% = 3;

            // Load datasource
            if ("%DataSourceSP%".trim()) {
                loadDataSourceCommon("%ColumnName%", "%DataSourceSP%", function(data) {
                    window["DataSource_%ColumnName%"] = data || [];
                    if (Array.isArray(data)) {
                        data.forEach(emp => hpaUtils.loadAvatar(emp.ID, emp.StoreImgName, emp.ImgParamV));
                    }
                    renderDisplay%ColumnName%();
                });
            }

            function renderDisplay%ColumnName%() {
                const $box = $("#%ColumnName%%UID%_display");
                if (!$box.length) return;
                
                $box.empty();
                const $w = $("<div>").css({
                    border: "1px solid #dee2e6",
                    borderRadius: "8px",
                    padding: "0 6px",
                    minHeight: "40px",
                    display: "flex",
                    alignItems: "center",
                    cursor: "pointer"
                })
                .attr("tabIndex", "0")
                .on("keydown", e => {
                    if (e.key === "Enter" || e.key === " ") {
                        e.preventDefault();
                        showPopup%ColumnName%();
                    }
                })
                .on("focus", () => $w.css({ borderColor: "#0d6efd", boxShadow: "0 0 0 0.2rem rgba(13,110,253,.15)" }))
                .on("blur", () => $w.css({ borderColor: "#dee2e6", boxShadow: "none" }))
                .hover(
                    () => $w.css({ borderColor: "#0d6efd", boxShadow: "0 0 0 0.2rem rgba(13,110,253,.15)" }),
                    () => $w.css({ borderColor: "#dee2e6", boxShadow: "none" })
                )
                .on("click", showPopup%ColumnName%);

                if (!%ColumnName%%UID%SelectedIds.length) {
                    $w.html(\'<span class="text-muted"><i class="bi bi-person-plus me-2"></i>Chọn nhân viên...</span>\');
                } else {
                    const visible = %ColumnName%%UID%SelectedIds.slice(0, MAX_VISIBLE_%ColumnName%);
                    const ds = window["DataSource_%ColumnName%"];
                    const $g = $("<div>").css({ display: "flex", alignItems: "center" });

                    visible.forEach((id, i) => {
                        const item = ds.find(e => String(e.ID) === String(id));
                        if (!item) return;

                        const $av = $("<div>").css({
                            width: "36px", height: "36px", borderRadius: "50%",
                            border: "3px solid #fff", boxShadow: "0 2px 6px rgba(0,0,0,0.15)",
                            marginLeft: i === 0 ? "0" : "-10px", zIndex: MAX_VISIBLE_%ColumnName% - i,
                            display: "flex", alignItems: "center", justifyContent: "center",
                            fontWeight: "600", fontSize: "13px", overflow: "hidden"
                        }).attr("title", item.Name || item.FullName || "");

                        const cachedUrl = window.GlobalEmployeeAvatarCache[String(id)];
                        if (cachedUrl) {
                            $av.append(`<img src="${cachedUrl}" style="width:100%;height:100%;object-fit:cover"/>`);
                        } else {
                            const color = hpaUtils.getColorForId(id);
                            const initials = hpaUtils.getInitials(item.Name || item.FullName);
                            $av.css({ background: color.bg, color: color.text }).text(initials);
                            
                            if (item.storeImgName) {
                                hpaUtils.loadAvatar(id, item.storeImgName, item.paramImg, () => renderDisplay%ColumnName%());
                            }
                        }
                        $g.append($av);
                    });

                    if (%ColumnName%%UID%SelectedIds.length > MAX_VISIBLE_%ColumnName%) {
                        const more = %ColumnName%%UID%SelectedIds.length - MAX_VISIBLE_%ColumnName%;
                        $g.append($("<div>").css({
                            width: "36px", height: "36px", borderRadius: "50%",
                            border: "3px solid #fff", marginLeft: "-10px",
                            display: "flex", alignItems: "center", justifyContent: "center",
                            fontWeight: "700", fontSize: "12px"
                        }).text("+" + more).attr("title", "Còn " + more + " người nữa"));
                    }
                    $w.append($g);
                }
                $box.append($w);
            }

            const $container%ColumnName% = $("#%UID%");
            $container%ColumnName%.html(\'<div id="%ColumnName%%UID%_display"></div>\');

            let popup%ColumnName%, popupInit%ColumnName% = false, gridContainer%ColumnName%;

            function showPopup%ColumnName%() {
                if (!popup%ColumnName%) {
                    initPopup%ColumnName%();
                    setTimeout(() => popup%ColumnName%.show(), 0);
                } else {
                    popup%ColumnName%.show();
                }
            }

            function initPopup%ColumnName%() {
                if (popupInit%ColumnName%) return;
                popupInit%ColumnName% = true;

                popup%ColumnName% = $("<div>").attr("id", "%ColumnName%%UID%_popup")
                    .appendTo(document.body)
                    .addClass("hpa-responsive")
                    .dxPopup({
                        width: 750, height: "auto", animation: null,
                        showTitle: true, title: "Chọn nhân viên",
                        dragEnabled: true, closeOnOutsideClick: true, showCloseButton: true,
                        toolbarItems: [
                            {
                                widget: "dxButton", location: "after", toolbar: "bottom",
                                options: {
                                    text: "Hủy",
                                    onClick: () => {
                                        %ColumnName%%UID%SelectedIds = [...%ColumnName%%UID%SelectedIdsOriginal];
                                        popup%ColumnName%.hide();
                                    }
                                }
                            },
                            {
                                widget: "dxButton", location: "after", toolbar: "bottom",
                                options: {
                                    text: "Lưu", type: "success",
                                    onClick: () => {
                                        if (typeof cellInfo !== "undefined" && cellInfo?.component) {
                                            try {
                                                const newVal = %ColumnName%%UID%SelectedIds.join(",");
                                                cellInfo.component.cellValue(cellInfo.rowIndex, "%ColumnName%", newVal || null);
                                                cellInfo.component.repaint();
                                            } catch (e) {}
                                        }
                                        %ColumnName%%UID%SelectedIdsOriginal = [...%ColumnName%%UID%SelectedIds];
                                        renderDisplay%ColumnName%();
                                        popup%ColumnName%.hide();
                                    }
                                }
                            }
                        ],
                        contentTemplate: function (el) {
                            gridContainer%ColumnName% = $("<div>");
                            el.append(gridContainer%ColumnName%);
                        },
                        onShown: () => {
                            const sorted = window["DataSource_%ColumnName%"].sort((a, b) => {
                                const aSel = %ColumnName%%UID%SelectedIds.includes(String(a.ID));
                                const bSel = %ColumnName%%UID%SelectedIds.includes(String(b.ID));
                                return bSel - aSel;
                            });

                            try {
                                gridContainer%ColumnName%.dxDataGrid("instance")?.dispose();
                            } catch (e) {}

                            gridContainer%ColumnName%.empty().dxDataGrid({
                                dataSource: sorted,
                                keyExpr: "ID",
                                remoteOperations: false,
                                columnAutoWidth: true,
                                allowColumnResizing: true,
                                selection: { mode: "multiple", showCheckBoxesMode: "always" },
                                selectedRowKeys: %ColumnName%%UID%SelectedIds,
                                hoverStateEnabled: true,
                                columns: [
                                    {
                                        caption: "Ảnh", width: 80, alignment: "center",
                                        cellTemplate: (c, o) => {
                                            const item = o.data;
                                            const cachedUrl = window.GlobalEmployeeAvatarCache[String(item.ID)];
                                            
                                            if (cachedUrl) {
                                                c.append(`<div style="display:flex;justify-content:center;align-items:center;height:100%">
                                                    <img src="${cachedUrl}" style="width:40px;height:40px;border-radius:50%;object-fit:cover;border:2px solid #fff;box-shadow:0 2px 4px rgba(0,0,0,0.1)"/>
                                                </div>`);
                                            } else {
                                                const color = hpaUtils.getColorForId(item.ID);
                                                const initials = hpaUtils.getInitials(item.Name || item.FullName || "?");
                                                c.append(`<div style="display:flex;justify-content:center;align-items:center;height:100%">
                                                    <div style="width:40px;height:40px;border-radius:50%;background:${color.bg};color:${color.text};display:flex;justify-content:center;align-items:center;font-weight:600;font-size:14px;box-shadow:0 2px 4px rgba(0,0,0,0.1)">${initials}</div>
                                                </div>`);
                                                
                                                if (item.storeImgName) {
                                                    hpaUtils.loadAvatar(item.ID, item.storeImgName, item.paramImg, () => {
                                                        gridContainer%ColumnName%.dxDataGrid("instance").refresh();
                                                    });
                                                }
                                            }
                                        }
                                    },
                                    { dataField: "Name", caption: "Họ tên" },
                                    { dataField: "Email", caption: "Email" },
                                    { dataField: "Position", caption: "Chức vụ" }
                                ],
                                searchPanel: { visible: true },
                                onContentReady: function(e) {
                                    const grid = e.component;
                                    const searchBox = grid.getView("headerPanel")._$element.find(".dx-datagrid-search-panel input");
                                    
                                    if (searchBox.length) {
                                        searchBox.off("input keyup").on("input", function() {
                                            const val = $(this).val();
                                            if (!val) {
                                                grid.clearFilter();
                                                return;
                                            }
                                            const norm = RemoveToneMarks_Js(val);
                                            grid.filter(item => {
                                                const fields = ["Name", "Email", "Position"];
                                                return fields.some(f => {
                                                    const fv = item[f];
                                                    return fv && RemoveToneMarks_Js(String(fv)).indexOf(norm) !== -1;
                                                });
                                            });
                                        });
                                    }
                                },
                                paging: { enabled: true, pageSize: 5 },
                                pager: { visible: true, allowedPageSizes: [5, 10], showPageSizeSelector: true },
                                onSelectionChanged: e => %ColumnName%%UID%SelectedIds = e.selectedRowKeys || []
                            });
                        },
                        onHidden: () => {
                            try {
                                gridContainer%ColumnName%.dxDataGrid("instance")?.dispose();
                            } catch (e) {}
                            renderDisplay%ColumnName%();
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
                    renderDisplay%ColumnName%();
                },
                getValue: () => %ColumnName%%UID%SelectedIds,
                getValueAsString: () => %ColumnName%%UID%SelectedIds.join(","),
                setDataSource: data => { window["DataSource_%ColumnName%"] = data || []; },
                repaint: renderDisplay%ColumnName%,
                option: function(name, value) {
                    if (arguments.length === 2 && name === "value") this.setValue(value);
                    else if (arguments.length === 1) {
                        if (name === "value") return this.getValueAsString();
                        if (name === "dataSource") return window["DataSource_%ColumnName%"];
                    }
                },
                _suppressValueChangeAction: () => {},
                _resumeValueChangeAction: () => {}
            };
        '
    WHERE [Type] = 'hpaControlSelectEmployee' AND [AutoSave] = 0 AND [ReadOnly] = 0 AND ([IsMultiSelectEmployee] = 1 OR [IsMultiSelectEmployee] IS NULL);

    -- =============================================
    -- 4. AUTOSAVE MODE - SINGLE SELECT
    -- =============================================
    UPDATE #temptable SET
        loadUI = N'
            window.GlobalEmployeeAvatarCache = window.GlobalEmployeeAvatarCache || {};
            window.GlobalEmployeeAvatarLoading = window.GlobalEmployeeAvatarLoading || {};
            let Instance%ColumnName%%UID% = {};

            window["DataSource_%ColumnName%"] = window["DataSource_%ColumnName%"] || [];
            let %ColumnName%%UID%SelectedId = null, %ColumnName%%UID%SelectedIdOriginal = null;

            // Load datasource
            if ("%DataSourceSP%".trim()) {
                loadDataSourceCommon("%ColumnName%", "%DataSourceSP%", function(data) {
                    window["DataSource_%ColumnName%"] = data || [];
                    if (Array.isArray(data)) {
                        data.forEach(emp => hpaUtils.loadAvatar(emp.ID, emp.StoreImgName, emp.ImgParamV));
                    }
                    renderDisplay%ColumnName%();
                });
            }

            function renderDisplay%ColumnName%() {
                const $box = $("#%ColumnName%%UID%_display");
                if (!$box.length) return;
                
                $box.empty();
                const $w = $("<div>").css({
                    border: "1px solid #dee2e6",
                    borderRadius: "8px",
                    padding: "0 6px",
                    minHeight: "40px",
                    display: "flex",
                    alignItems: "center",
                    gap: "10px",
                    cursor: "pointer"
                })
                .attr("tabIndex", "0")
                .on("keydown", e => {
                    if (e.key === "Enter" || e.key === " ") {
                        e.preventDefault();
                        showPopup%ColumnName%();
                    }
                })
                .on("focus", () => $w.css({ borderColor: "#0d6efd", boxShadow: "0 0 0 0.2rem rgba(13,110,253,.15)" }))
                .on("blur", () => $w.css({ borderColor: "#dee2e6", boxShadow: "none" }))
                .hover(
                    () => $w.css({ borderColor: "#0d6efd", boxShadow: "0 0 0 0.2rem rgba(13,110,253,.15)" }),
                    () => $w.css({ borderColor: "#dee2e6", boxShadow: "none" })
                )
                .on("click", showPopup%ColumnName%);

                if (!%ColumnName%%UID%SelectedId) {
                    $w.html(\'<span class="text-muted"><i class="bi bi-person-plus me-2"></i>Chọn nhân viên...</span>\');
                } else {
                    const item = window["DataSource_%ColumnName%"].find(e => String(e.ID) === String(%ColumnName%%UID%SelectedId));
                    if (!item) {
                        $w.html(\'<span class="text-muted">Nhân viên không tồn tại</span>\');
                    } else {
                        const name = item.Name || item.FullName || "?";
                        const cachedUrl = window.GlobalEmployeeAvatarCache[String(%ColumnName%%UID%SelectedId)];

                        const $av = $("<div>").css({
                            width: "40px", height: "40px", borderRadius: "50%",
                            boxShadow: "0 2px 6px rgba(0,0,0,0.15)",
                            display: "flex", alignItems: "center", justifyContent: "center",
                            fontWeight: "600", fontSize: "14px",
                            overflow: "hidden", flexShrink: 0
                        });

                        if (cachedUrl) {
                            $av.append(`<img src="${cachedUrl}" style="width:100%;height:100%;object-fit:cover"/>`);
                        } else {
                            const color = hpaUtils.getColorForId(%ColumnName%%UID%SelectedId);
                            const initials = hpaUtils.getInitials(name);
                            $av.css({ background: color.bg, color: color.text }).text(initials);
                            
                            if (item.storeImgName) {
                                hpaUtils.loadAvatar(%ColumnName%%UID%SelectedId, item.storeImgName, item.paramImg, () => renderDisplay%ColumnName%());
                            }
                        }

                        const $info = $("<div>").css({ flex: 1, overflow: "hidden" });
                        $info.append($("<div>").css({ fontWeight: "500", fontSize: "14px", overflow: "hidden", textOverflow: "ellipsis", whiteSpace: "nowrap" }).text(name));
                        if (item.Position) {
                            $info.append($("<div>").css({ fontSize: "12px", color: "#6c757d", overflow: "hidden", textOverflow: "ellipsis", whiteSpace: "nowrap" }).text(item.Position));
                        }

                        $w.append($av).append($info);
                    }
                }
                $box.append($w);
            }

            const $container%ColumnName% = $("#%UID%");
            $container%ColumnName%.html(\'<div id="%ColumnName%%UID%_display"></div>\');

            let popup%ColumnName%, popupInit%ColumnName% = false, gridContainer%ColumnName%;

            function showPopup%ColumnName%() {
                if (!popup%ColumnName%) {
                    initPopup%ColumnName%();
                    setTimeout(() => popup%ColumnName%.show(), 0);
                } else {
                    popup%ColumnName%.show();
                }
            }

            function initPopup%ColumnName%() {
                if (popupInit%ColumnName%) return;
                popupInit%ColumnName% = true;

                popup%ColumnName% = $("<div>").attr("id", "%ColumnName%%UID%_popup")
                    .appendTo(document.body)
                    .addClass("hpa-responsive")
                    .dxPopup({
                        width: 750, height: "auto", animation: null,
                        showTitle: true, title: "Chọn nhân viên",
                        dragEnabled: true, closeOnOutsideClick: true, showCloseButton: true,
                        toolbarItems: [
                            {
                                widget: "dxButton", location: "after", toolbar: "bottom",
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
                                widget: "dxButton", location: "after", toolbar: "bottom",
                                options: {
                                    text: "Lưu", type: "success",
                                    onClick: async () => {
                                        await saveValue%ColumnName%();
                                        popup%ColumnName%.hide();
                                    }
                                }
                            }
                        ],
                        contentTemplate: function (el) {
                            gridContainer%ColumnName% = $("<div>");
                            el.append(gridContainer%ColumnName%);
                        },
                        onShown: () => {
                            const sorted = window["DataSource_%ColumnName%"].sort((a, b) => {
                                const aSel = String(a.ID) === String(%ColumnName%%UID%SelectedId);
                                const bSel = String(b.ID) === String(%ColumnName%%UID%SelectedId);
                                return bSel - aSel;
                            });

                            try {
                                gridContainer%ColumnName%.dxDataGrid("instance")?.dispose();
                            } catch (e) {}

                            gridContainer%ColumnName%.empty().dxDataGrid({
                                dataSource: sorted,
                                keyExpr: "ID",
                                remoteOperations: false,
                                columnAutoWidth: true,
                                allowColumnResizing: true,
                                selection: { mode: "single" },
                                selectedRowKeys: %ColumnName%%UID%SelectedId ? [%ColumnName%%UID%SelectedId] : [],
                                hoverStateEnabled: true,
                                onRowPrepared: e => { if (e.rowType === "data") e.rowElement.css("cursor", "pointer"); },
                                columns: [
                                    {
                                        caption: "Ảnh", width: 80, alignment: "center",
                                        cellTemplate: (c, o) => {
                                            const item = o.data;
                                            const cachedUrl = window.GlobalEmployeeAvatarCache[String(item.ID)];
                                            
                                            if (cachedUrl) {
                                                c.append(`<div style="display:flex;justify-content:center;align-items:center;height:100%">
                                                    <img src="${cachedUrl}" style="width:40px;height:40px;border-radius:50%;object-fit:cover;border:2px solid #fff;box-shadow:0 2px 4px rgba(0,0,0,0.1)"/>
                                                </div>`);
                                            } else {
                                                const color = hpaUtils.getColorForId(item.ID);
                                                const initials = hpaUtils.getInitials(item.Name || item.FullName || "?");
                                                c.append(`<div style="display:flex;justify-content:center;align-items:center;height:100%">
                                                    <div style="width:40px;height:40px;border-radius:50%;background:${color.bg};color:${color.text};display:flex;justify-content:center;align-items:center;font-weight:600;font-size:14px;box-shadow:0 2px 4px rgba(0,0,0,0.1)">${initials}</div>
                                                </div>`);
                                                
                                                if (item.storeImgName) {
                                                    hpaUtils.loadAvatar(item.ID, item.storeImgName, item.paramImg, () => {
                                                        gridContainer%ColumnName%.dxDataGrid("instance").refresh();
                                                    });
                                                }
                                            }
                                        }
                                    },
                                    { dataField: "Name", caption: "Họ tên" },
                                    { dataField: "Email", caption: "Email" },
                                    { dataField: "Position", caption: "Chức vụ" }
                                ],
                                searchPanel: { visible: true },
                                onContentReady: function(e) {
                                    const grid = e.component;
                                    const searchBox = grid.getView("headerPanel")._$element.find(".dx-datagrid-search-panel input");
                                    
                                    if (searchBox.length) {
                                        searchBox.off().on("input", function() {
                                            const val = $(this).val();
                                            if (!val) {
                                                grid.clearFilter();
                                                return;
                                            }
                                            const norm = RemoveToneMarks_Js(val);
                                            grid.filter(item => {
                                                const fields = ["Name", "Email", "Position"];
                                                return fields.some(f => {
                                                    const fv = item[f];
                                                    return fv && RemoveToneMarks_Js(String(fv)).indexOf(norm) !== -1;
                                                });
                                            });
                                        });
                                    }
                                },
                                paging: { enabled: true, pageSize: 5 },
                                pager: { visible: true, allowedPageSizes: [5, 10], showPageSizeSelector: true },
                                onSelectionChanged: e => {
                                    const keys = e.selectedRowKeys || [];
                                    %ColumnName%%UID%SelectedId = keys.length > 0 ? String(keys[0]) : null;
                                }
                            });
                        },
                        onHidden: () => {
                            try {
                                gridContainer%ColumnName%.dxDataGrid("instance")?.dispose();
                            } catch (e) {}
                            renderDisplay%ColumnName%();
                        }
                    }).dxPopup("instance");

                popup%ColumnName%.on("hiding", async function(e) {
                    if (e.component._isCancelling) {
                        delete e.component._isCancelling;
                        return;
                    }
                    const orig = String(%ColumnName%%UID%SelectedIdOriginal || "");
                    const curr = String(%ColumnName%%UID%SelectedId || "");
                    if (orig !== curr) {
                        e.cancel = true;
                        await saveValue%ColumnName%();
                        e.component.hide();
                    }
                });
            }

            async function saveValue%ColumnName%() {
                const orig = String(%ColumnName%%UID%SelectedIdOriginal || "");
                const curr = String(%ColumnName%%UID%SelectedId || "");
                if (orig === curr) return;

                try {
                    const newVal = %ColumnName%%UID%SelectedId || null;
                    const dataJSON = JSON.stringify(["%tableId%", ["%ColumnName%"], [newVal]]);

                    let id1 = currentRecordID_%ColumnIDName%;
                    if (typeof cellInfo !== "undefined" && cellInfo?.data) {
                        id1 = cellInfo.data["%ColumnIDName%"] || id1;
                    }
                    let idVals = [id1], idFields = ["%ColumnIDName%"];

                    if ("%ColumnIDName2%".trim()) {
                        let id2 = currentRecordID_%ColumnIDName2%;
                        if (typeof cellInfo !== "undefined" && cellInfo?.data) {
                            id2 = cellInfo.data["%ColumnIDName2%"] || id2;
                        }
                        idVals.push(id2);
                        idFields.push("%ColumnIDName2%");
                    }
                    const idValsJSON = JSON.stringify([idVals, idFields]);

                    const json = await saveFunction(dataJSON, idValsJSON);
                    const errors = json.data?.[json.data.length - 1] || [];
                    if (errors.length > 0 && errors[0].Status === "ERROR") {
                        uiManager.showAlert({ type: "error", message: errors[0].Message || "%SaveErrorMessage%" });
                        return;
                    }

                    if (typeof cellInfo !== "undefined" && cellInfo?.component) {
                        try {
                            cellInfo.component.cellValue(cellInfo.rowIndex, "%ColumnName%", newVal);
                            cellInfo.component.repaint();
                        } catch (e) {}
                    }

                    %ColumnName%%UID%SelectedIdOriginal = %ColumnName%%UID%SelectedId;
                    renderDisplay%ColumnName%();
                } catch (err) {
                    uiManager.showAlert({ type: "error", message: "%SaveErrorMessage%" });
                }
            }

            Instance%ColumnName%%UID% = {
                setValue: function(val) {
                    %ColumnName%%UID%SelectedId = (val !== null && val !== undefined && val !== "") ? String(val) : null;
                    %ColumnName%%UID%SelectedIdOriginal = %ColumnName%%UID%SelectedId;
                    renderDisplay%ColumnName%();
                },
                getValue: () => %ColumnName%%UID%SelectedId,
                getValueAsString: () => %ColumnName%%UID%SelectedId || "",
                setDataSource: data => { window["DataSource_%ColumnName%"] = data || []; },
                repaint: renderDisplay%ColumnName%,
                option: function(name, value) {
                    if (arguments.length === 2 && name === "value") this.setValue(value);
                    else if (arguments.length === 1) {
                        if (name === "value") return this.getValueAsString();
                        if (name === "dataSource") return window["DataSource_%ColumnName%"];
                    }
                },
                _suppressValueChangeAction: () => {},
                _resumeValueChangeAction: () => {}
            };
        '
    WHERE [Type] = 'hpaControlSelectEmployee' AND [AutoSave] = 1 AND [ReadOnly] = 0 AND [IsMultiSelectEmployee] = 0;

    -- =============================================
    -- 5. MANUAL MODE - SINGLE SELECT
    -- =============================================
    UPDATE #temptable SET
        loadUI = N'
            window.GlobalEmployeeAvatarCache = window.GlobalEmployeeAvatarCache || {};
            window.GlobalEmployeeAvatarLoading = window.GlobalEmployeeAvatarLoading || {};
            let Instance%ColumnName%%UID% = {};

            window["DataSource_%ColumnName%"] = window["DataSource_%ColumnName%"] || [];
            let %ColumnName%%UID%SelectedId = null, %ColumnName%%UID%SelectedIdOriginal = null;
            let _autoSave%ColumnName%%UID% = false;
            let _readOnly%ColumnName%%UID% = false;

            // Load datasource
            if ("%DataSourceSP%".trim()) {
                loadDataSourceCommon("%ColumnName%", "%DataSourceSP%", function(data) {
                    window["DataSource_%ColumnName%"] = data || [];
                    if (Array.isArray(data)) {
                        data.forEach(emp => hpaUtils.loadAvatar(emp.ID, emp.StoreImgName, emp.ImgParamV));
                    }
                    renderDisplay%ColumnName%();
                });
            }

            function renderDisplay%ColumnName%() {
                const $box = $("#%ColumnName%%UID%_display");
                if (!$box.length) return;
                
                $box.empty();
                const $w = $("<div>").css({
                    border: "1px solid #dee2e6",
                    borderRadius: "8px",
                    padding: "0 6px",
                    minHeight: "40px",
                    display: "flex",
                    alignItems: "center",
                    gap: "10px",
                    cursor: _readOnly%ColumnName%%UID% ? "default" : "pointer"
                })
                .attr("tabIndex", _readOnly%ColumnName%%UID% ? -1 : 0);

                if (!_readOnly%ColumnName%%UID%) {
                    $w.on("keydown", e => {
                        if (e.key === "Enter" || e.key === " ") {
                            e.preventDefault();
                            showPopup%ColumnName%();
                        }
                    })
                    .on("focus", () => $w.css({ borderColor: "#0d6efd", boxShadow: "0 0 0 0.2rem rgba(13,110,253,.15)" }))
                    .on("blur", () => $w.css({ borderColor: "#dee2e6", boxShadow: "none" }))
                    .hover(
                        () => $w.css({ borderColor: "#0d6efd", boxShadow: "0 0 0 0.2rem rgba(13,110,253,.15)" }),
                        () => $w.css({ borderColor: "#dee2e6", boxShadow: "none" })
                    )
                    .on("click", showPopup%ColumnName%);
                }

                if (!%ColumnName%%UID%SelectedId) {
                    $w.html(\'<span class="text-muted"><i class="bi bi-person-plus me-2"></i>Chọn nhân viên...</span>\');
                } else {
                    const item = window["DataSource_%ColumnName%"].find(e => String(e.ID) === String(%ColumnName%%UID%SelectedId));
                    if (!item) {
                        $w.html(\'<span class="text-muted">Nhân viên không tồn tại</span>\');
                    } else {
                        const name = item.Name || item.FullName || "?";
                        const cachedUrl = window.GlobalEmployeeAvatarCache[String(%ColumnName%%UID%SelectedId)];

                        const $av = $("<div>").css({
                            width: "40px", height: "40px", borderRadius: "50%",
                            boxShadow: "0 2px 6px rgba(0,0,0,0.15)",
                            display: "flex", alignItems: "center", justifyContent: "center",
                            fontWeight: "600", fontSize: "14px",
                            overflow: "hidden", flexShrink: 0
                        });

                        if (cachedUrl) {
                            $av.append(`<img src="${cachedUrl}" style="width:100%;height:100%;object-fit:cover"/>`);
                        } else {
                            const color = hpaUtils.getColorForId(%ColumnName%%UID%SelectedId);
                            const initials = hpaUtils.getInitials(name);
                            $av.css({ background: color.bg, color: color.text }).text(initials);
                            
                            if (item.storeImgName) {
                                hpaUtils.loadAvatar(%ColumnName%%UID%SelectedId, item.storeImgName, item.paramImg, () => renderDisplay%ColumnName%());
                            }
                        }

                        const $info = $("<div>").css({ flex: 1, overflow: "hidden" });
                        $info.append($("<div>").css({ fontWeight: "500", fontSize: "14px", overflow: "hidden", textOverflow: "ellipsis", whiteSpace: "nowrap" }).text(name));
                        if (item.Position) {
                            $info.append($("<div>").css({ fontSize: "12px", color: "#6c757d", overflow: "hidden", textOverflow: "ellipsis", whiteSpace: "nowrap" }).text(item.Position));
                        }

                        $w.append($av).append($info);
                    }
                }
                $box.append($w);
            }

            const $container%ColumnName% = $("#%UID%");
            $container%ColumnName%.html(\'<div id="%ColumnName%%UID%_display"></div>\');

            let popup%ColumnName%, popupInit%ColumnName% = false, gridContainer%ColumnName%;

            function showPopup%ColumnName%() {
                if (_readOnly%ColumnName%%UID%) return;
                if (!popup%ColumnName%) {
                    initPopup%ColumnName%();
                    setTimeout(() => popup%ColumnName%.show(), 0);
                } else {
                    popup%ColumnName%.show();
                }
            }

            function initPopup%ColumnName%() {
                if (popupInit%ColumnName%) return;
                popupInit%ColumnName% = true;

                popup%ColumnName% = $("<div>").attr("id", "%ColumnName%%UID%_popup")
                    .appendTo(document.body)
                    .addClass("hpa-responsive")
                    .dxPopup({
                        width: 750, height: "auto", animation: null,
                        showTitle: true, title: "Chọn nhân viên",
                        dragEnabled: true, closeOnOutsideClick: true, showCloseButton: true,
                        toolbarItems: [
                            {
                                widget: "dxButton", location: "after", toolbar: "bottom",
                                options: {
                                    text: "Hủy",
                                    onClick: () => {
                                        %ColumnName%%UID%SelectedId = %ColumnName%%UID%SelectedIdOriginal;
                                        popup%ColumnName%.hide();
                                    }
                                }
                            },
                            {
                                widget: "dxButton", location: "after", toolbar: "bottom",
                                options: {
                                    text: "Lưu", type: "success",
                                    onClick: async () => {
                                        if (_autoSave%ColumnName%%UID% && typeof saveValue%ColumnName% === "function") {
                                            await saveValue%ColumnName%();
                                        } else {
                                            if (typeof cellInfo !== "undefined" && cellInfo?.component) {
                                                try {
                                                    cellInfo.component.cellValue(cellInfo.rowIndex, "%ColumnName%", %ColumnName%%UID%SelectedId || null);
                                                    cellInfo.component.repaint();
                                                } catch (e) {}
                                            }
                                            %ColumnName%%UID%SelectedIdOriginal = %ColumnName%%UID%SelectedId;
                                            renderDisplay%ColumnName%();
                                        }
                                        popup%ColumnName%.hide();
                                    }
                                }
                            }
                        ],
                        contentTemplate: function (el) {
                            gridContainer%ColumnName% = $("<div>");
                            el.append(gridContainer%ColumnName%);
                        },
                        onShown: () => {
                            const sorted = window["DataSource_%ColumnName%"].sort((a, b) => {
                                const aSel = String(a.ID) === String(%ColumnName%%UID%SelectedId);
                                const bSel = String(b.ID) === String(%ColumnName%%UID%SelectedId);
                                return bSel - aSel;
                            });

                            try {
                                gridContainer%ColumnName%.dxDataGrid("instance")?.dispose();
                            } catch (e) {}

                            gridContainer%ColumnName%.empty().dxDataGrid({
                                dataSource: sorted,
                                keyExpr: "ID",
                                remoteOperations: false,
                                columnAutoWidth: true,
                                allowColumnResizing: true,
                                selection: { mode: "single" },
                                selectedRowKeys: %ColumnName%%UID%SelectedId ? [%ColumnName%%UID%SelectedId] : [],
                                hoverStateEnabled: true,
                                onRowPrepared: e => { if (e.rowType === "data") e.rowElement.css("cursor", "pointer"); },
                                columns: [
                                    {
                                        caption: "Ảnh", width: 80, alignment: "center",
                                        cellTemplate: (c, o) => {
                                            const item = o.data;
                                            const cachedUrl = window.GlobalEmployeeAvatarCache[String(item.ID)];
                                            
                                            if (cachedUrl) {
                                                c.append(`<div style="display:flex;justify-content:center;align-items:center;height:100%">
                                                    <img src="${cachedUrl}" style="width:40px;height:40px;border-radius:50%;object-fit:cover;border:2px solid #fff;box-shadow:0 2px 4px rgba(0,0,0,0.1)"/>
                                                </div>`);
                                            } else {
                                                const color = hpaUtils.getColorForId(item.ID);
                                                const initials = hpaUtils.getInitials(item.Name || item.FullName || "?");
                                                c.append(`<div style="display:flex;justify-content:center;align-items:center;height:100%">
                                                    <div style="width:40px;height:40px;border-radius:50%;background:${color.bg};color:${color.text};display:flex;justify-content:center;align-items:center;font-weight:600;font-size:14px;box-shadow:0 2px 4px rgba(0,0,0,0.1)">${initials}</div>
                                                </div>`);
                                                
                                                if (item.storeImgName) {
                                                    hpaUtils.loadAvatar(item.ID, item.storeImgName, item.paramImg, () => {
                                                        gridContainer%ColumnName%.dxDataGrid("instance").refresh();
                                                    });
                                                }
                                            }
                                        }
                                    },
                                    { dataField: "Name", caption: "Họ tên" },
                                    { dataField: "Email", caption: "Email" },
                                    { dataField: "Position", caption: "Chức vụ" }
                                ],
                                searchPanel: { visible: true },
                                onContentReady: function(e) {
                                    const grid = e.component;
                                    const searchBox = grid.getView("headerPanel")._$element.find(".dx-datagrid-search-panel input");
                                    
                                    if (searchBox.length) {
                                        searchBox.off().on("input", function() {
                                            const val = $(this).val();
                                            if (!val) {
                                                grid.clearFilter();
                                                return;
                                            }
                                            const norm = RemoveToneMarks_Js(val);
                                            grid.filter(item => {
                                                const fields = ["Name", "Email", "Position"];
                                                return fields.some(f => {
                                                    const fv = item[f];
                                                    return fv && RemoveToneMarks_Js(String(fv)).indexOf(norm) !== -1;
                                                });
                                            });
                                        });
                                    }
                                },
                                paging: { enabled: true, pageSize: 5 },
                                pager: { visible: true, allowedPageSizes: [5, 10], showPageSizeSelector: true },
                                onSelectionChanged: e => %ColumnName%%UID%SelectedId = (e.selectedRowKeys?.[0]) || null
                            });
                        },
                        onHidden: () => {
                            try {
                                gridContainer%ColumnName%.dxDataGrid("instance")?.dispose();
                            } catch (e) {}
                            renderDisplay%ColumnName%();
                        }
                    }).dxPopup("instance");
            }

            async function saveValue%ColumnName%() {
                const orig = String(%ColumnName%%UID%SelectedIdOriginal || "");
                const curr = String(%ColumnName%%UID%SelectedId || "");
                if (orig === curr) return;

                try {
                    const newVal = %ColumnName%%UID%SelectedId || null;
                    const dataJSON = JSON.stringify(["%tableId%", ["%ColumnName%"], [newVal]]);

                    let idVals = [currentRecordID_%ColumnIDName%], idFields = ["%ColumnIDName%"];
                    if ("%ColumnIDName2%".trim()) {
                        idVals.push(currentRecordID_%ColumnIDName2%);
                        idFields.push("%ColumnIDName2%");
                    }
                    const idValsJSON = JSON.stringify([idVals, idFields]);

                    const json = await saveFunction(dataJSON, idValsJSON);
                    const errors = json.data?.[json.data.length - 1] || [];
                    if (errors.length > 0 && errors[0].Status === "ERROR") {
                        uiManager.showAlert({ type: "error", message: errors[0].Message || "%SaveErrorMessage%" });
                        return;
                    }

                    if (typeof cellInfo !== "undefined" && cellInfo?.component) {
                        try {
                            cellInfo.component.cellValue(cellInfo.rowIndex, "%ColumnName%", newVal);
                            cellInfo.component.repaint();
                        } catch (e) {}
                    }

                    %ColumnName%%UID%SelectedIdOriginal = %ColumnName%%UID%SelectedId;
                    renderDisplay%ColumnName%();
                } catch (err) {
                    uiManager.showAlert({ type: "error", message: "%SaveErrorMessage%" });
                }
            }

            Instance%ColumnName%%UID% = {
                setValue: function(val) {
                    %ColumnName%%UID%SelectedId = (val !== null && val !== undefined && val !== "") ? String(val) : null;
                    %ColumnName%%UID%SelectedIdOriginal = %ColumnName%%UID%SelectedId;
                    renderDisplay%ColumnName%();
                },
                getValue: () => %ColumnName%%UID%SelectedId,
                getValueAsString: () => %ColumnName%%UID%SelectedId || "",
                setDataSource: data => { window["DataSource_%ColumnName%"] = data || []; },
                repaint: renderDisplay%ColumnName%,
                option: function(name, value) {
                    if (arguments.length === 2 && name === "value") this.setValue(value);
                    else if (arguments.length === 1) {
                        if (name === "value") return this.getValueAsString();
                        if (name === "dataSource") return window["DataSource_%ColumnName%"];
                    }
                },
                _suppressValueChangeAction: () => {},
                _resumeValueChangeAction: () => {}
            };
        '
    WHERE [Type] = 'hpaControlSelectEmployee' AND [AutoSave] = 0 AND [ReadOnly] = 0 AND [IsMultiSelectEmployee] = 0;
END
GO