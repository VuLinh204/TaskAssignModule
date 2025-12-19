function saveDataTableCommon(config) {
    const {
        tableSN,
        columns, // array: ["Col1"]
        values, // array: ["val1"]
        types = [], // optional: ["text", "int", ...]
        idValue = null, // null nếu insert mới
        idColumnName = "ID",
        onSuccess = null,
        onError = null,
    } = config;

    if (!columns || columns.length === 0) {
        if (onError) onError("Thiếu columns");
        return;
    }

    const fullTypes = columns.map((_, i) => types[i] || "text");

    const dataJSON = JSON.stringify([tableSN, columns, values.map((v) => String(v || "")), fullTypes]);

    let idValuesJSON = null;
    if (idValue !== null && idValue !== undefined && String(idValue).trim() !== "") {
        idValuesJSON = JSON.stringify([[String(idValue)], idColumnName]);
    }

    AjaxHPAParadise({
        data: {
            name: "sp_Common_SaveDataTable",
            param: [
                "LoginID",
                window.LoginID || 0,
                "LanguageID",
                typeof LanguageID !== "undefined" ? LanguageID : "VN",
                "DataJSON",
                dataJSON,
                "IDValues",
                idValuesJSON,
            ],
        },
        success: function (res) {
            try {
                const json = typeof res === "string" ? JSON.parse(res) : res;
                const results = (json.data && json.data[0]) || [];
                const errorRow = results.find((r) => r.Status === "ERROR");
                if (errorRow) {
                    if (onError) onError(errorRow.Message || "Lưu thất bại");
                    return;
                }
                const newIdRow = results.find((r) => !idValue && r.IDValue);
                const returnedId = newIdRow ? newIdRow.IDValue : idValue;
                if (onSuccess) onSuccess(returnedId);
            } catch (e) {
                console.error("Parse response error:", e);
                if (onError) onError("Parse kết quả lỗi");
            }
        },
        error: function () {
            if (onError) onError("Lỗi kết nối");
        },
    });
}

// Linh: Hàm control sửa input và textarea
function hpaControlEditableRow(el, config) {
    const $el = $(el);
    const cfg = {
        type: config.type || "input",
        tableSN: config.tableSN,
        columnName: config.columnName,
        idColumnName: config.idColumnName || "ID",
        idValue: config.idValue,
        silent: config.silent || false,
        allowAdd: config.allowAdd || false,
        onSave: config.onSave || null,
        language: config.language || "VN",
        width: config.width,
    };
    if (!cfg.columnName || !cfg.tableSN || !cfg.idColumnName) return console.error("thiếu columnName, tableSN, idColumnName");

    if (!window.__hpaEditableRowCSSInjected) {
        const style = document.createElement("style");
        style.textContent = `
            .hpa-editable-row.control-editable { cursor: pointer; padding: 8px 4px; border-radius: 4px; transition: all 0.2s; display: inline-block; vertical-align: middle; box-sizing: border-box; }
            .hpa-editable-row.control-editable.editing { padding: 4px 8px; z-index: 100 !important; }
            .hpa-editable-row.control-editable.editing input,
            .hpa-editable-row.control-editable.editing textarea,
            .hpa-editable-row.control-editable.editing select { width: 100% !important; font-size: inherit; font-weight: inherit; padding: 6px 10px; border: 1px solid #1c975e !important; box-sizing: border-box; }
            .hpa-editable-row.control-editable .edit-actions { position: absolute; top: 110%; display: inline-flex; gap: 4px; margin-left: 6px; align-items: center; z-index: 100 !important; right: 0; }
            .hpa-editable-row.control-editable .btn-edit { width: 28px; height: 28px; padding: 0; display: inline-flex; align-items: center; justify-content: center; border-radius: 4px; border: 1px solid #e8eaed; background: white; cursor: pointer; transition: all 0.2s; font-size: 14px; }
            .hpa-editable-row.control-editable .btn-edit:hover { transform: scale(1.1); }
            .hpa-editable-row.control-editable .btn-edit.btn-save { background: #2E7D32; color: white; border-color: #2E7D32; }
            .hpa-editable-row.control-editable .btn-edit.btn-save:hover { background: #1c975e; }
            .hpa-editable-row.control-editable .btn-edit.btn-cancel { background: #fff; color: #676879; }
            .hpa-editable-row.control-editable .btn-edit.btn-cancel:hover { background: #f5f5f5; color: #E53935; }
        `;
        document.head.appendChild(style);
        window.__hpaEditableRowCSSInjected = true;
    }
    $el.addClass("hpa-editable-row control-editable");
    if (cfg.width) {
        $el.css({ width: cfg.width, "min-width": cfg.width });
        if (cfg.type !== "textarea") {
            $el.css({ "white-space": "nowrap", overflow: "hidden", "text-overflow": "ellipsis" });
        }
    }
    $el.off("click.control-editable").on("click.control-editable", function (e) {
        $(".hpa-editable-row.editing, .hpa-editable-row-number.editing").not($el).find(".btn-save").trigger("click");
        if ($(".hpa-editable-row-date.editing-date, .hpa-editable-row-time.editing-time").not($el).length > 0) {
            $("body").trigger("click");
        }
        e.stopPropagation();
        e.preventDefault();
        $(".hpa-editable-row.control-editable.editing").each(function () {
            if (this !== $el[0]) {
                $(this).find(".btn-save").trigger("click");
            }
        });
        if ($el.hasClass("editing")) return false;
        const curVal = $el.text().trim();
        if (cfg.width) $el.css("overflow", "visible");
        let $input;
        if (cfg.type === "textarea") {
            $input = $(`<textarea class="form-control form-control-sm" rows="3">`).val(curVal);
        } else {
            $input = $(`<input type="text" class="form-control form-control-sm">`).val(curVal);
        }
        let isAddMode = false;
        let recordId = cfg.idValue;
        const $save = $(`<button class="btn-edit btn-save" title="Lưu"><i class="bi bi-check-lg"></i></button>`);
        const $cancel = $(`<button class="btn-edit btn-cancel" title="Hủy"><i class="bi bi-x-lg"></i></button>`);
        const updateButtonState = () => {
            const isEmpty = !$input.val() || $input.val().trim().length === 0;
            if (cfg.allowAdd && isEmpty && !isAddMode) {
                isAddMode = true;
                recordId = null;
                $save.html(`<i class="bi bi-plus-lg"></i>`).attr("title", "Thêm");
            }
        };
        const $actions = $(`<div class="edit-actions"></div>`).append($save).append($cancel);
        const $wrap = $(`<div class="d-flex align-items-end gap-1 w-100 flex-column position-relative"></div>`).append($input).append($actions);
        $el.addClass("editing").html("").append($wrap);
        setTimeout(() => {
            const el = $input[0];
            el.focus();
            const len = el.value.length;
            el.setSelectionRange(len, len);
        }, 50);
        const finish = (saveIt) => {
            const newVal = $input.val().trim();
            $save.off("click");
            $cancel.off("click");
            $input.off("click keydown input");
            $(document).off("click.hpaEditable");
            $el.removeClass("editing").off("keydown");
            if (cfg.width && cfg.type !== "textarea") {
                $el.css("overflow", "hidden");
            }
            if (!saveIt || (newVal === curVal && !isAddMode)) {
                $el.text(curVal);
                return;
            }
            saveDataTableCommon({
                tableSN: cfg.tableSN,
                columns: [cfg.columnName],
                values: [newVal],
                types: ["text"],
                idValue: isAddMode ? null : recordId,
                idColumnName: cfg.idColumnName,
                onSuccess: (returnedId) => {
                    const display = newVal;
                    $el.text(display);
                    if (!cfg.silent) uiManager.showAlert({ type: "success", message: isAddMode ? "%AddSuccess%" : "%UpdateSuccess%" });
                    if (cfg.onSave) cfg.onSave(newVal, isAddMode, returnedId || recordId);
                },
                onError: () => {
                    uiManager.showAlert({ type: "error", message: "Lưu thất bại!" });
                    $el.text(curVal);
                },
            });
        };
        $save.on("click", function (e) {
            e.stopPropagation();
            $(document).off("click.hpaEditable");
            finish(true);
        });
        $cancel.on("click", (e) => {
            e.stopPropagation();
            e.preventDefault();
            finish(false);
            return false;
        });
        $input.on("input", updateButtonState);
        $input.on("keydown", (e) => {
            if (e.key === "Enter" && cfg.type !== "textarea") {
                e.preventDefault();
                finish(true);
            }
            if (e.key === "Escape") finish(false);
        });
        $(document).one("click.hpaEditable", (e) => {
            if (!$(e.target).closest($el).length) finish(true);
        });
    });
}

// Linh: Hàm control Selectbox + Combobox
function hpaControlField(el, config) {
    const $el = $(el);
    if (!$el.length) return null;
    config = config || {};
    const cfg = {
        searchable: config.hasOwnProperty("searchable") ? !!config.searchable : !!config.useApi === true,
        placeholder: config.placeholder || "Chọn...",
        searchMode: config.searchMode || "local",
        multi: !!config.multi,
        options: config.options || config.staticOptions || [],
        selected: config.selected,
        useApi: !!config.useApi,
        ajaxListName: config.ajaxListName || null,
        take: typeof config.take === "number" ? config.take : config.useApi ? 20 : config.take || 200,
        skip: typeof config.skip === "number" ? config.skip : 0,
        dataSource: config.dataSource || null,
        silent: config.silent !== false,
        tableSN: config.tableSN || null,
        columnName: config.columnName || config.field || null,
        idColumnName: config.idColumnName || null,
        idValue: config.idValue || null,
        onChange: config.onChange || null,
        ajaxGetCombobox: !!config.ajaxGetCombobox,
        sourceTableName: config.sourceTableName || null,
        sourceColumnName: config.sourceColumnName || null,
        sourceIdColumnName: config.sourceIdColumnName || null,
        whereClause: config.whereClause || "",
        columns: config.columns || null,
        displayTemplate: config.displayTemplate || null,
        searchColumns: config.searchColumns || null,
        valueField: config.valueField || null,
        textField: config.textField || null,
    };

    let _fetchedItems = [];
    let _fetchedMap = Object.create(null);
    let _hasMore = true;
    let _lastFilter = null;
    let _currentSkip = 0;
    let loadingMore = false;
    let _initialized = false;
    let _renderedCount = 0;
    let selected = Array.isArray(config.selectedValues)
        ? config.selectedValues.map(String)
        : config.selected !== undefined
        ? Array.isArray(config.selected)
            ? config.selected.map(String)
            : [String(config.selected)]
        : [];

    try {
        if ((!cfg.options || cfg.options.length === 0) && $el.length) {
            if ($el.is("select")) {
                const domOpts = [];
                $el.find("option").each(function () {
                    domOpts.push({ value: $(this).attr("value"), text: $(this).text() });
                });
                if (domOpts.length) cfg.options = domOpts;
                if ((!selected || selected.length === 0) && $el.val() !== undefined && $el.val() !== null) {
                    const val = $el.val();
                    selected = Array.isArray(val) ? val.map(String) : val ? [String(val)] : [];
                }
            }
        }
    } catch (e) {}

    if (!window.__hpaControlFieldCSS) {
        window.__hpaControlFieldCSS = true;
        const style = document.createElement("style");
        style.textContent = `
                        .hpa-field-wrapper{position:relative;width:100%}
                        .hpa-field-display{display:flex;align-items:center;gap:8px;padding:8px 12px;border:1px solid var(--border-color);border-radius:6px;cursor:pointer;transition:all 0.2s}
                        .hpa-field-display.focused{border-color:var(--task-primary);box-shadow:0 0 0 4px rgba(46,125,94,0.06)}
                        .hpa-field-display.searching{padding:0 !important}
                        .hpa-field-display.searching .hpa-field-inline-search{width:100%;padding:8px 12px;border:none;outline:none;background:transparent;font-size:inherit}
                        .hpa-field-display.searching .bi-chevron-down{display:none}
                        .hpa-field-placeholder{color:var(--text-muted)}
                        .hpa-field-dropdown{position:absolute;top:calc(100% + 8px);left:0;right:0;backdrop-filter:blur(50px);border:1px solid var(--border-color);border-radius:6px;box-shadow:var(--shadow-sm);max-height:320px;overflow:auto;display:none;z-index:3000;padding:8px}
                        .hpa-field-item{padding:8px;border-radius:4px;cursor:pointer;display:flex;align-items:center;gap:8px}
                        .hpa-field-item:hover{background:#f6fbff}
                        .hpa-field-item.selected{background:var(--task-primary);color:#fff;font-weight:600}
                        .hpa-field-item.selected:hover{background:var(--task-primary)}
                        .hpa-field-chip{display:inline-flex;align-items:center;padding:4px 8px;border-radius:16px;background:#f1f5f9;margin-right:6px}
                        .hpa-field-column-header{display:flex;gap:8px;padding:8px;border-bottom:1px solid var(--border-color);margin-bottom:4px;font-weight:600;font-size:12px;color:var(--text-muted)}
                        .hpa-field-column-row{display:flex;gap:8px;align-items:center}
                        .hpa-field-column-cell{overflow:hidden;text-overflow:ellipsis;white-space:nowrap}
                    `;
        document.head.appendChild(style);
    }

    const wrapper = $(`<div class="hpa-field-wrapper"></div>`);
    const display = $(`<div class="hpa-field-display"><div class="hpa-field-text"></div><i class="bi bi-chevron-down" style="margin-left:auto"></i></div>`);
    const dropdown = $(`<div class="hpa-field-dropdown"></div>`);
    const itemsContainer = $(`<div class="hpa-field-items"></div>`);
    wrapper.append(display).append(dropdown);
    dropdown.append(itemsContainer);
    $el.empty().append(wrapper);

    function escapeHtml(s) {
        if (s === null || s === undefined) return "";
        return String(s).replace(/&/g, "&amp;").replace(/</g, "&lt;").replace(/>/g, "&gt;").replace(/""/g, "&quot;").replace(/"/g, "&#039;");
    }
    function debounce(fn, wait) {
        let timer = null;
        return function () {
            const ctx = this,
                args = arguments;
            if (timer) clearTimeout(timer);
            timer = setTimeout(() => {
                fn.apply(ctx, args);
                timer = null;
            }, wait);
        };
    }

    function getActualSearchMode() {
        if (cfg.searchMode === "local") return "local";
        if (cfg.searchMode === "api") return "api";
        if (cfg.useApi && (cfg.ajaxListName || cfg.ajaxGetCombobox)) return "api";
        return "local";
    }

    function getItemValue(item) {
        if (cfg.valueField) return item[cfg.valueField];
        return item.TaskID || item.EmployeeID || item.ID || item.value;
    }

    function getItemText(item) {
        if (cfg.displayTemplate && typeof cfg.displayTemplate === "function") return cfg.displayTemplate(item);
        if (cfg.textField) return item[cfg.textField];
        return item.TaskName || item.FullName || item.Name || item.text;
    }

    function itemMatchesSearch(item, searchText) {
        if (!searchText) return true;
        const search = searchText.toLowerCase();
        const searchNoTone = typeof RemoveToneMarks === "function" ? RemoveToneMarks(search) : search;
        const textMatches = (text) => {
            if (!text) return false;
            const textLower = String(text).toLowerCase();
            const textNoTone = typeof RemoveToneMarks === "function" ? RemoveToneMarks(textLower) : textLower;
            return textLower.includes(search) || textNoTone.includes(searchNoTone);
        };
        if (cfg.searchColumns && cfg.searchColumns.length) {
            return cfg.searchColumns.some((col) => textMatches(item[col]));
        }
        return textMatches(getItemText(item));
    }

    function renderDisplay() {
        const $t = display.find(".hpa-field-text");
        if (!cfg.multi) {
            const v = selected[0];
            if (!v) {
                $t.html(`<span class="hpa-field-placeholder">${escapeHtml(cfg.placeholder)}</span>`);
            } else {
                const opt = _fetchedItems.find((o) => String(getItemValue(o)) === String(v)) || (cfg.options || []).find((o) => String(o.value) === String(v));
                $t.text(opt ? getItemText(opt) : v);
            }
        } else {
            if (!selected || selected.length === 0) {
                $t.html(`<span class="hpa-field-placeholder">${escapeHtml(cfg.placeholder)}</span>`);
            } else {
                const texts = selected.map((id) => {
                    const o =
                        _fetchedItems.find((x) => String(getItemValue(x)) === String(id)) || (cfg.options || []).find((x) => String(x.value) === String(id));
                    return escapeHtml(o ? getItemText(o) : id);
                });
                $t.text(texts.join(", "));
            }
        }
    }

    function openDropdown() {
        $(".hpa-field-dropdown").not(dropdown).hide();
        dropdown.show();
        display.addClass("focused");
        dropdown.scrollTop(0);
    }

    function closeDropdown() {
        display.removeClass("focused searching");
        renderDisplay();
        setTimeout(() => dropdown.hide(), 120);
    }

    function toggleValue(val, keep) {
        val = String(val);
        const idx = selected.indexOf(val);
        if (keep) {
            if (idx === -1) selected.push(val);
        } else {
            if (idx !== -1) selected.splice(idx, 1);
        }
        renderDisplay();
        if (typeof cfg.onChange === "function") {
            const item = _fetchedItems.find((x) => String(getItemValue(x)) === val);
            cfg.onChange(cfg.multi ? selected.slice() : selected[0] || null, item);
        }
        try {
            saveToDB(cfg.multi ? selected : selected[0] || null);
        } catch (e) {}
    }

    function selectSingle(val) {
        selected = val === undefined || val === null ? [] : [String(val)];
        renderDisplay();
        if (typeof cfg.onChange === "function") {
            const item = _fetchedItems.find((x) => String(getItemValue(x)) === val);
            cfg.onChange(selected[0] || null, item);
        }
        try {
            saveToDB(cfg.multi ? selected : selected[0] || null);
        } catch (e) {}
        closeDropdown();
    }

    function defaultCreateNew(keyword) {
        return new Promise(function (resolve, reject) {
            const kw = String(keyword || "").trim();
            if (!kw) return reject(new Error("Empty keyword"));
            saveDataTableCommon({
                tableSN: cfg.tableSN || "",
                columns: [cfg.sourceColumnName || cfg.columnName || cfg.field || ""],
                values: [kw],
                types: ["text"],
                idValue: null,
                idColumnName: cfg.sourceIdColumnName || cfg.idColumnName || "ID",
                onSuccess: (newId) => {
                    resolve({ value: newId || null, text: kw });
                },
                onError: (msg) => reject(new Error(msg || "Ajax Error")),
            });
        });
    }

    function handleNewItem(newItem) {
        const standardItem = cfg.columns
            ? newItem
            : {
                value: newItem.value,
                text: newItem.text,
                ID: newItem.value,
                Name: newItem.text,
                ...newItem,
            };
        const itemValue = String(getItemValue(standardItem));
        if (!_fetchedMap[itemValue]) {
            _fetchedMap[itemValue] = true;
            _fetchedItems.unshift(standardItem);
        }
        if (!cfg.options) cfg.options = [];
        cfg.options.unshift(standardItem);
        if (cfg.multi) {
            if (!selected.includes(itemValue)) selected.push(itemValue);
        } else {
            selected = [itemValue];
        }
        renderDisplay();
        if (typeof cfg.onChange === "function") {
            cfg.onChange(cfg.multi ? selected.slice() : selected[0] || null, standardItem);
        }
        try {
            saveToDB(cfg.multi ? selected : selected[0] || null);
        } catch (e) {}
        if (cfg.useApi && cfg.ajaxListName) {
            AjaxHPAParadise({
                data: {
                    name: "sp_ClearTableCacheForControlField",
                    param: [
                        "@ProcName",
                        cfg.ajaxListName,
                        "@LoginID",
                        window.LoginID || 0,
                        "@LanguageID",
                        typeof LanguageID !== "undefined" ? LanguageID : "VN",
                    ],
                },
                success: () => {},
            });
        }
        closeDropdown();
    }

    function fetchPage(filterVal, skipVal, isAddFlag = false) {
        return new Promise((resolve, reject) => {
            if (cfg.ajaxGetCombobox) {
                const p = [
                    "@LoginID",
                    window.LoginID || 0,
                    "@LanguageID",
                    typeof LanguageID !== "undefined" ? LanguageID : "VN",
                    "@TableName",
                    cfg.sourceTableName || cfg.tableSN || "",
                    "@ColumnName",
                    cfg.sourceColumnName || cfg.textField || "Name",
                    "@IDColumnName",
                    cfg.sourceIdColumnName || cfg.valueField || "ID",
                    "@WhereClause",
                    cfg.whereClause || "",
                ];

                AjaxHPAParadise({
                    data: { name: "sp_Common_GetComboBox", param: p },
                    success: (res) => {
                        try {
                            const json = typeof res === "string" ? JSON.parse(res) : res;
                            let rows = json?.data?.[0] || [];

                            if (filterVal) {
                                const search = filterVal.toLowerCase();
                                rows = rows.filter((x) => {
                                    const name = x.Name || x[cfg.textField] || "";
                                    return String(name).toLowerCase().includes(search);
                                });
                            }

                            const start = skipVal || 0;
                            const end = start + cfg.take;
                            const paginatedRows = rows.slice(start, end);

                            const mapped = paginatedRows.map((x) => {
                                if (cfg.columns) return x;
                                return {
                                    value: x.ID || x[cfg.valueField],
                                    text: x.Name || x[cfg.textField],
                                    ...x,
                                };
                            });

                            mapped._totalCount = rows.length;
                            resolve(mapped);
                        } catch (err) {
                            reject(err);
                        }
                    },
                    error: () => reject(new Error("Ajax Error")),
                });
                return;
            }

            const p = [
                "@ProcName",
                cfg.ajaxListName,
                "@Take",
                cfg.take,
                "@Skip",
                skipVal || 0,
                "@SearchValue",
                filterVal || "",
                "@ColumnSearch",
                cfg.searchColumns ? cfg.searchColumns.join(",") : "",
                "@LanguageID",
                typeof LanguageID !== "undefined" ? LanguageID : "VN",
                "@IsAdd",
                isAddFlag ? 1 : 0,
            ];

            AjaxHPAParadise({
                data: { name: "sp_LoadGridUsingAPI", param: p },
                success: (res) => {
                    try {
                        const json = typeof res === "string" ? JSON.parse(res) : res;
                        const rows = json?.data?.[0] || [];
                        const mapped = cfg.columns
                            ? rows
                            : rows.map((x) => ({
                                value: x.TaskID || x.EmployeeID || x.ID || x.value,
                                text: x.TaskName || x.FullName || x.Name || x.text,
                                ...x,
                            }));
                        resolve(mapped);
                    } catch (err) {
                        reject(err);
                    }
                },
                error: () => reject(new Error("Ajax Error")),
            });
        });
    }

    function addToCache(list) {
        list.forEach((it) => {
            const val = getItemValue(it);
            if (!_fetchedMap[val]) {
                _fetchedMap[val] = true;
                _fetchedItems.push(it);
            }
        });
    }

    function showLoading() {
        itemsContainer.append(`<div class="hpa-field-item" style="color:var(--text-muted)">Đang tải...</div>`);
    }

    function showError(msg) {
        itemsContainer.html(`<div class="hpa-field-item" style="color:var(--text-muted)">${msg}</div>`);
    }

    function backgroundPreloadAll() {
        if (!cfg.useApi || (!cfg.ajaxListName && !cfg.ajaxGetCombobox)) return;
        if (cfg.searchMode === "api") return; // Không preload nếu dùng API search

        let skipCount = _currentSkip;

        function loadNextBatch() {
            if (!_hasMore) {
                return;
            }

            fetchPage("", skipCount)
                .then((data) => {
                    const totalCount = data._totalCount;
                    delete data._totalCount;

                    if (!data.length) {
                        _hasMore = false;
                        return;
                    }

                    // Merge vào cache (không render)
                    let newCount = 0;
                    data.forEach((it) => {
                        const val = getItemValue(it);
                        if (!_fetchedMap[val]) {
                            _fetchedMap[val] = true;
                            _fetchedItems.push(it);
                            newCount++;
                        }
                    });

                    skipCount += data.length;

                    // Check hasMore
                    if (cfg.ajaxGetCombobox && totalCount !== undefined) {
                        _hasMore = skipCount < totalCount;
                    } else {
                        _hasMore = data.length >= cfg.take;
                    }

                    // Load tiếp batch sau 200ms
                    if (_hasMore) {
                        setTimeout(loadNextBatch, 200);
                    } else {
                    }
                })
                .catch((err) => {
                    console.error("Background preload error:", err);
                });
        }

        // Bắt đầu load sau 500ms (để UI render xong)
        setTimeout(loadNextBatch, 500);
    }

    function initialApiLoad(filter) {
        showLoading();

        fetchPage(filter, 0)
            .then((data) => {
                const totalCount = data._totalCount;
                delete data._totalCount;

                const actualSearchMode = getActualSearchMode();
                let renderItems;

                if (actualSearchMode === "local") {
                    data.forEach((it) => {
                        const val = getItemValue(it);
                        if (!_fetchedMap[val]) {
                            _fetchedMap[val] = true;
                            _fetchedItems.push(it);
                        }
                    });

                    let filteredItems = _fetchedItems;
                    if (filter) {
                        filteredItems = _fetchedItems.filter((item) => itemMatchesSearch(item, filter));
                    }

                    // Sắp xếp: Đưa selected lên đầu
                    const selectedSet = new Set(selected.map(String));
                    const selectedItems = [];
                    const otherItems = [];
                    filteredItems.forEach((item) => {
                        const val = String(getItemValue(item));
                        if (selectedSet.has(val)) {
                            selectedItems.push(item);
                        } else {
                            otherItems.push(item);
                        }
                    });
                    renderItems = [...selectedItems, ...otherItems];

                    renderList(renderItems, false);
                    backgroundPreloadAll();
                } else {
                    _fetchedItems = data.slice();
                    _fetchedMap = Object.create(null);
                    _fetchedItems.forEach((it) => (_fetchedMap[getItemValue(it)] = true));

                    // Sắp xếp: Đưa selected lên đầu
                    const selectedSet = new Set(selected.map(String));
                    const selectedItems = [];
                    const otherItems = [];
                    _fetchedItems.forEach((item) => {
                        const val = String(getItemValue(item));
                        if (selectedSet.has(val)) {
                            selectedItems.push(item);
                        } else {
                            otherItems.push(item);
                        }
                    });
                    renderItems = [...selectedItems, ...otherItems];

                    renderList(renderItems, false);
                }

                _currentSkip = data.length;

                if (cfg.ajaxGetCombobox && totalCount !== undefined) {
                    _hasMore = _currentSkip < totalCount;
                } else {
                    _hasMore = data.length >= cfg.take;
                }
            })
            .catch(() => showError("Lỗi kết nối"));
    }
    function loadMoreRender(list) {
        const BATCH_SIZE = 20;
        const startIdx = _renderedCount;
        const endIdx = Math.min(startIdx + BATCH_SIZE, list.length);
        const batch = list.slice(startIdx, endIdx);

        if (batch.length === 0) return;

        batch.forEach((o) => {
            const val = getItemValue(o);
            const isSel = selected.includes(String(val));

            if (cfg.columns && cfg.columns.length) {
                if (cfg.multi) {
                    const row = $(`<div class="hpa-field-item">
                                    <label style="display:flex;align-items:center;gap:8px;width:100%">
                                        <input type="checkbox" ${isSel ? "checked" : ""}/>
                                        <div class="hpa-field-column-row" style="flex:1;"></div>
                                    </label>
                                </div>`);

                    const colRow = row.find(".hpa-field-column-row");
                    cfg.columns.forEach((col) => {
                        colRow.append(`<div class="hpa-field-column-cell" style="width:${col.width || "auto"}">${escapeHtml(o[col.field] || "")}</div>`);
                    });

                    row.find("input").on("change", () => toggleValue(val, row.find("input").is(":checked")));
                    itemsContainer.append(row);
                } else {
                    const row = $(`<div class="hpa-field-item ${isSel ? "selected" : ""}" data-value="${val}">
                                    <div class="hpa-field-column-row" style="width:100%;"></div>
                                </div>`);

                    const colRow = row.find(".hpa-field-column-row");
                    cfg.columns.forEach((col) => {
                        colRow.append(`<div class="hpa-field-column-cell" style="width:${col.width || "auto"}">${escapeHtml(o[col.field] || "")}</div>`);
                    });

                    row.on("click", () => selectSingle(val));
                    itemsContainer.append(row);
                }
            } else {
                if (cfg.multi) {
                    const row = $(`<div class="hpa-field-item">
                                    <label style="display:flex;align-items:center;gap:8px;width:100%">
                                        <input type="checkbox" ${isSel ? "checked" : ""}/>
                                        <span style="flex:1">${escapeHtml(getItemText(o))}</span>
                                    </label>
                                </div>`);
                    row.find("input").on("change", () => toggleValue(val, row.find("input").is(":checked")));
                    itemsContainer.append(row);
                } else {
                    const row = $(`<div class="hpa-field-item ${isSel ? "selected" : ""}" data-value="${val}">${escapeHtml(getItemText(o))}</div>`);
                    row.on("click", () => selectSingle(val));
                    itemsContainer.append(row);
                }
            }
        });

        _renderedCount = endIdx;
    }
    dropdown.on("scroll", function () {
        const el = this;
        if (el.scrollHeight - (el.scrollTop + el.clientHeight) <= 100) {
            // Lấy filter từ inline search
            const $inlineSearch = display.find(".hpa-field-inline-search");
            const curFilter = $inlineSearch.length ? $inlineSearch.val() || "" : "";

            // Tìm list hiện tại đang hiển thị
            let currentList = _fetchedItems;
            if (curFilter) {
                currentList = _fetchedItems.filter((item) => itemMatchesSearch(item, curFilter));
            }

            // Nếu còn items chưa render thì render tiếp
            if (_renderedCount < currentList.length) {
                loadMoreRender(currentList);
            }
        }
    });
    function renderList(list, append) {
        if (!append) {
            itemsContainer.empty();
            _renderedCount = 0;

            if (cfg.columns && cfg.columns.length) {
                const headerRow = $(`<div class="hpa-field-column-header"></div>`);
                cfg.columns.forEach((col) => {
                    headerRow.append(`<div class="hpa-field-column-cell" style="width:${col.width || "auto"}">${escapeHtml(col.label || col.field)}</div>`);
                });
                itemsContainer.append(headerRow);
            }
        }

        if (!list || list.length === 0) {
            if (!append) {
                itemsContainer.append(`<div class="hpa-field-item" style="color:var(--text-muted)">Không có dữ liệu</div>`);
            }
            return;
        }

        // Render batch đầu tiên
        loadMoreRender(list);
    }
    function renderCreateRow(filter) {
        const keyword = String(filter || "").trim();
        if (!keyword) return;

        const row = $(`<div class="hpa-field-item hpa-field-create-row" style="font-weight:600;color:var(--task-primary);cursor:pointer;">
                        Thêm mới: <span style="margin-left:6px;opacity:0.95;">${escapeHtml(keyword)}</span>
                    </div>`);

        row.on("click", () => {
            row.css("opacity", 0.6).text("Đang tạo...");
            defaultCreateNew(keyword)
                .then((newItem) => {
                    row.css("opacity", 1).text("Thêm mới: " + keyword);
                    handleNewItem(newItem);
                })
                .catch(() => {
                    row.css("opacity", 1).text("Thêm mới: " + keyword);
                    uiManager?.showAlert?.({ type: "error", message: "Tạo thất bại" });
                });
        });

        itemsContainer.prepend(row);
    }
    function renderDropdown(filter, appendMode) {
        if (filter === undefined || filter === null) {
            const $inlineSearch = display.find(".hpa-field-inline-search");
            filter = $inlineSearch.length ? $inlineSearch.val() || "" : "";
        }

        const q = (filter || "").toLowerCase();
        const actualSearchMode = getActualSearchMode();

        // ===== LOCAL SEARCH MODE =====
        if (actualSearchMode === "local") {
            if (!appendMode) itemsContainer.empty();

            // Merge cả _fetchedItems (items được tạo mới) và cfg.options
            let allItems = [..._fetchedItems];
            (cfg.options || []).forEach((opt) => {
                const val = getItemValue(opt);
                if (!_fetchedMap[val]) {
                    allItems.push(opt);
                }
            });

            let filteredOpts = allItems;
            if (q) {
                filteredOpts = allItems.filter((o) => itemMatchesSearch(o, q));
            }

            // ĐƯA SELECTED LÊN ĐẦU
            const selectedSet = new Set(selected.map(String));
            const selectedItems = [];
            const otherItems = [];
            filteredOpts.forEach((item) => {
                const val = String(getItemValue(item));
                if (selectedSet.has(val)) {
                    selectedItems.push(item);
                } else {
                    otherItems.push(item);
                }
            });
            const sortedItems = [...selectedItems, ...otherItems];

            renderList(sortedItems, false);

            if (q) {
                renderCreateRow(filter);
            }

            return;
        }

        // ===== API SEARCH MODE =====
        if (cfg.useApi && (cfg.ajaxListName || cfg.ajaxGetCombobox)) {
            if (appendMode) {
                return;
            }
            if (_lastFilter !== filter) {
                _currentSkip = 0;
                _hasMore = true;
                if (actualSearchMode === "api") {
                    _fetchedItems = [];
                    _fetchedMap = Object.create(null);
                }
                loadingMore = false;
            }
            _lastFilter = filter;
            if (actualSearchMode === "api" || _fetchedItems.length === 0) {
                initialApiLoad(filter);
            } else {
                let filteredItems = _fetchedItems;
                if (q) {
                    filteredItems = _fetchedItems.filter((item) => itemMatchesSearch(item, q));
                }

                // ĐƯA SELECTED LÊN ĐẦU — giống như trong initialApiLoad
                const selectedSet = new Set(selected.map(String));
                const selectedItems = [];
                const otherItems = [];
                filteredItems.forEach((item) => {
                    const val = String(getItemValue(item));
                    if (selectedSet.has(val)) {
                        selectedItems.push(item);
                    } else {
                        otherItems.push(item);
                    }
                });
                const sortedItems = [...selectedItems, ...otherItems];

                itemsContainer.empty();
                renderList(sortedItems, false);
            }
            return;
        }

        // ===== STATIC/DATASOURCE MODE =====
        if (!appendMode) itemsContainer.empty();

        let filteredOpts = cfg.options || [];
        if (q) {
            filteredOpts = filteredOpts.filter((o) => itemMatchesSearch(o, q));
        }

        renderList(filteredOpts, false);

        if (q) {
            renderCreateRow(filter);
        }
    }

    function saveToDB(val) {
        if (!cfg.tableSN || cfg.idValue === null || cfg.idValue === undefined) return;
        const valueStr = cfg.multi ? (val || []).join(",") : val || "";
        saveDataTableCommon({
            tableSN: cfg.tableSN,
            columns: [cfg.columnName || cfg.field],
            values: [valueStr],
            types: ["text"],
            idValue: cfg.idValue,
            idColumnName: cfg.idColumnName || "ID",
            onSuccess: () => {
                if (!cfg.silent) uiManager?.showAlert?.({ type: "success", message: "%UpdateSuccess%" });
            },
            onError: () => {
                uiManager?.showAlert?.({ type: "error", message: "Lưu thất bại!" });
            },
        });
    }

    display.on("click", (e) => {
        e.stopPropagation();
        if (display.hasClass("searching")) return;

        // === RESET STATE (giữ lại `selected`) ===
        _initialized = false;
        _fetchedItems = [];
        _fetchedMap = Object.create(null);
        _hasMore = true;
        _currentSkip = 0;
        _renderedCount = 0;
        _lastFilter = null;
        loadingMore = false;
        // =======================================

        display.addClass("searching");
        const $inlineSearch = $(`<input type="text" class="hpa-field-inline-search" placeholder="${cfg.placeholder}" />`);
        display.find(".hpa-field-text").html("").append($inlineSearch);
        setTimeout(() => $inlineSearch.focus(), 10);

        openDropdown();

        // KHÔNG GỌI renderDropdown ở đây nếu dùng API
        if (cfg.useApi && (cfg.ajaxListName || cfg.ajaxGetCombobox)) {
            initialApiLoad(""); // → sẽ tự gọi renderList khi xong
        } else {
            // Với local/static → có thể render ngay
            renderDropdown("", false);
        }

        // Xử lý input
        const actualMode = getActualSearchMode();
        if (actualMode === "local") {
            $inlineSearch.on("input", function () {
                const val = $(this).val() || "";
                renderDropdown(val, false);
            });
        } else {
            const debouncedRender = debounce((val) => renderDropdown(val, false), 500);
            $inlineSearch.on("input", function () {
                debouncedRender($(this).val() || "");
            });
        }

        // Xử lý phím tắt
        $inlineSearch.on("keydown", function (e) {
            if (e.key === "Escape") {
                closeDropdown();
            }
            if (e.key === "ArrowDown") {
                e.preventDefault();
                itemsContainer.find(".hpa-field-item:not(.hpa-field-create-row)").first().trigger("click");
            }
            if (e.key === "Enter" && !cfg.multi) {
                e.preventDefault();
                itemsContainer.find(".hpa-field-item:not(.hpa-field-create-row)").first().trigger("click");
            }
        });
    });
    // Close dropdown khi click bên ngoài
    $(document).on("click.hpaField", (e) => {
        if (!wrapper.is(e.target) && wrapper.has(e.target).length === 0) closeDropdown();
    });

    renderDisplay();

    return {
        setValue(v) {
            selected = cfg.multi ? (Array.isArray(v) ? v.map(String) : v ? [String(v)] : []) : v ? [String(v)] : [];
            renderDisplay();
            saveToDB(cfg.multi ? selected : selected[0] || null);
        },
        getValue() {
            return cfg.multi ? selected.slice() : selected[0] || null;
        },
        getSelectedItem() {
            if (!selected.length) return null;
            const id = selected[0];
            return _fetchedItems.find((x) => String(getItemValue(x)) === String(id));
        },
        getText() {
            if (!selected.length) return null;
            const id = selected[0];
            const o = _fetchedItems.find((x) => String(getItemValue(x)) === String(id)) || (cfg.options || []).find((x) => String(x.value) === String(id));
            return o ? getItemText(o) : id;
        },
        destroy() {
            $(document).off("click.hpaField");
            wrapper.remove();
        },
        reload() {
            _initialized = false;
            _fetchedItems = [];
            _fetchedMap = Object.create(null);
            _hasMore = true;
            _currentSkip = 0;
            _renderedCount = 0;
            renderDisplay();
        },
    };
}

// Linh: Control chọn nhân viên dạng dropdown với DevExtreme Grid
function hpaControlEmployeeSelector(el, config) {
    const $el = $(el);
    if (!$el.length) return null;
    const defaults = {
        containerId: null,
        dropdownId: null,
        placeholder: "Chọn nhân viên",
        maxVisibleChips: 3,
        avatarWidth: 32,
        avatarHeight: 32,
        width: 350,
        height: 400,
        showAvatar: true,
        ajaxListName: "EmployeeListAll_DataSetting_Custom",
        selectedIds: [],
        apiData: null,
        useApi: true,
        pageSize: 10,
        take: config.take || 20,
        skip: 0,
        multi: true,
        searchable: true,
        tableSN: null,
        columnName: null,
        idColumnName: null,
        idValue: null,
        silent: true,
        onChange: null,
    };
    const cfg = { ...defaults, ...config };

    const uniqueId = `emp-dropdown-${Date.now()}-${Math.random().toString(36).substr(2, 9)}`;
    cfg.containerId = cfg.containerId || `${uniqueId}-container`;
    cfg.dropdownId = cfg.dropdownId || `${uniqueId}-dropdown`;

    // ===== STATE VARIABLES =====
    const SVG_PLACEHOLDER =
        "data:image/svg+xml,%3Csvg xmlns=%22http://www.w3.org/2000/svg%22 viewBox=%220 0 100 100%22%3E%3Ccircle cx=%2250%22 cy=%2250%22 r=%2250%22 fill=%22%23e0e0e0%22/%3E%3C/svg%3E";

    const avatarCache = {};
    let allEmployees = [];
    let selectedIds = [...cfg.selectedIds].map(String);
    let dataGridInstance = null;
    let totalCount = 0;
    let currentSkip = 0;
    let isLoadingApiData = false;
    let backgroundLoadScheduled = false;
    let apiQueue = Promise.resolve();
    let selectedLoaded = false;
    let selectedLoadPromise = null;
    let selectedCache = [];
    let currentSearchText = "";
    let snapshotEmployees = [];
    let isGridInitializing = true;
    let isDropdownOpen = false;

    // ===== HELPER FUNCTIONS =====
    function normalizeSearchText(text) {
        if (!text) return "";
        return RemoveToneMarks(String(text).toLowerCase().trim());
    }

    function escapeHtml(s) {
        if (s === null || s === undefined) return "";
        return String(s).replace(/&/g, "&amp;").replace(/</g, "&lt;").replace(/>/g, "&gt;").replace(/""/g, "&quot;").replace(/"/g, "&#039;");
    }

    function getInitials(fullName) {
        if (!fullName) return "?";
        const words = fullName.trim().split(/\s+/);
        if (words.length >= 2) {
            return (words[0][0] + words[words.length - 1][0]).toUpperCase();
        }
        return fullName.substring(0, 2).toUpperCase();
    }

    function getAvatarStyle() {
        return `width:${cfg.avatarWidth}px;height:${cfg.avatarHeight}px;`;
    }

    function getChipFontSize() {
        const size = Math.min(cfg.avatarWidth, cfg.avatarHeight);
        return Math.max(8, Math.floor(size * 0.4));
    }

    function getImageCacheKey(employee) {
        try {
            var store = (employee && employee.storeImgName) || "";
            var param = (employee && employee.paramImg) || "";
            return store + "|" + param;
        } catch (e) {
            return ((employee && employee.storeImgName) || "") + "|" + ((employee && employee.paramImg) || "");
        }
    }

    // ===== CSS INJECTION =====
    if (!window.__hpaEmployeeDropdownCSS) {
        window.__hpaEmployeeDropdownCSS = true;
        const style = document.createElement("style");
        style.textContent = `
                        .hpa-emp-dropdown-wrapper { position: relative; display: inline-block; width: 100%; }

                        .hpa-emp-dropdown-btn {
                            display: inline-flex;
                            align-items: center;
                            gap: 6px;
                            padding: 6px 8px;
                            border: 1px solid #e6edf3;
                            border-radius: 20px;
                            cursor: pointer;
                            transition: all 0.12s ease;
                            font-size: 13px;
                            white-space: nowrap;
                            background: #fff;
                            box-shadow: 0 1px 2px rgba(16,24,40,0.04);
                            width: 100%;
                        }
                        .hpa-emp-dropdown-btn:hover {
                            border-color: #c7d2da;
                            transform: translateY(-1px);
                        }

                        .hpa-emp-dropdown-chips {
                            display: flex;
                            align-items: center;
                            gap: 0;
                            flex: 1;
                            min-width: 0;
                        }

                        .hpa-emp-dropdown-chip {
                            border-radius: 50%;
                            overflow: hidden;
                            flex-shrink: 0;
                            border: 2px solid white;
                            box-shadow: 0 2px 4px rgba(0,0,0,0.12);
                            margin-left: -8px;
                            transition: all 0.2s;
                        }
                        .hpa-emp-dropdown-chip:first-child { margin-left: 0; }
                        .hpa-emp-dropdown-chip:hover { transform: scale(1.1); z-index: 10; }
                        .hpa-emp-dropdown-chip img { width: 100%; height: 100%; object-fit: cover; }

                        .hpa-emp-dropdown-chip-text {
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
                            font-weight: 600;
                            background: #e9ecef;
                        }
                        .hpa-emp-dropdown-chip-text:first-child { margin-left: 0; }
                        .hpa-emp-dropdown-chip-text:hover { transform: scale(1.1); z-index: 10; }

                        .hpa-emp-dropdown-count {
                            font-weight: 600;
                            color: #495057;
                            margin-left: 4px;
                        }

                        .hpa-emp-dropdown-icon {
                            margin-left: auto;
                            color: #6c757d;
                            transition: transform 0.2s;
                        }

                        .hpa-emp-dropdown-btn.open .hpa-emp-dropdown-icon {
                            transform: rotate(180deg);
                        }

                        .hpa-emp-dropdown-container {
                            display: none;
                            position: fixed;
                            z-index: 9999;
                            border: 1px solid #dee2e6;
                            border-radius: 8px;
                            box-shadow: 0 8px 24px rgba(0,0,0,0.15);
                            overflow: hidden;
                            background: #fff;
                        }

                        .hpa-emp-dropdown-container.open {
                            display: block;
                        }

                        .hpa-emp-dropdown-header {
                            padding: 12px;
                            border-bottom: 1px solid #dee2e6;
                            background: #f8f9fa;
                        }

                        .hpa-emp-dropdown-search {
                            width: 100%;
                            padding: 8px 12px;
                            border: 1px solid #dee2e6;
                            border-radius: 4px;
                            font-size: 13px;
                            outline: none;
                            box-sizing: border-box;
                        }
                        .hpa-emp-dropdown-search:focus {
                            border-color: #2E7D32;
                            box-shadow: 0 0 0 3px rgba(46, 125, 50, 0.1);
                        }

                        .hpa-emp-dropdown-body {
                            overflow-y: auto;
                            background: #fff;
                        }

                        .hpa-emp-dropdown-container .dx-datagrid { border: none !important; }
                        .hpa-emp-dropdown-container .dx-datagrid-headers { display: none; }
                        .hpa-emp-dropdown-container .dx-checkbox { margin: 0; }

                        .grid-employee-cell {
                            display: flex !important;
                            align-items: center;
                            gap: 8px;
                            padding: 4px 0;
                        }

                        .grid-employee-image {
                            border-radius: 50%;
                            object-fit: cover;
                            flex-shrink: 0;
                        }

                        /* Backdrop overlay khi dropdown mở */
                        .hpa-emp-dropdown-backdrop {
                            position: fixed;
                            top: 0;
                            left: 0;
                            right: 0;
                            bottom: 0;
                            background: transparent;
                            z-index: 9998;
                            display: none;
                        }

                        .hpa-emp-dropdown-backdrop.open {
                            display: block;
                        }
                    `;
        document.head.appendChild(style);
    }

    // ===== DATA LOADING FUNCTIONS =====

    function loadEmployeeList(skip, take) {
        const jqDeferred = $.Deferred();

        if (cfg.apiData && Array.isArray(cfg.apiData)) {
            allEmployees = cfg.apiData;
            totalCount = allEmployees.length;
            jqDeferred.resolve(allEmployees);
            return jqDeferred.promise();
        }

        if (!cfg.useApi) {
            allEmployees = [];
            totalCount = 0;
            jqDeferred.resolve(allEmployees);
            return jqDeferred.promise();
        }

        if (allEmployees.length >= totalCount && totalCount > 0) {
            jqDeferred.resolve(allEmployees);
            return jqDeferred.promise();
        }

        skip = skip || 0;
        take = take || cfg.take;

        const extraparam = [];
        extraparam.push("@ProcName");
        extraparam.push(cfg.ajaxListName);
        extraparam.push("@Take");
        extraparam.push(take);
        extraparam.push("@Skip");
        extraparam.push(skip);
        extraparam.push("@LanguageID");
        extraparam.push(typeof LanguageID !== "undefined" ? LanguageID : "VN");

        const runFetch = () =>
            new Promise((resolveFetch, rejectFetch) => {
                isLoadingApiData = true;
                backgroundLoadScheduled = true;
                AjaxHPAParadise({
                    data: {
                        name: "sp_LoadGridUsingAPI",
                        param: extraparam,
                    },
                    success: function (resultData) {
                        try {
                            let jsonData = typeof resultData === "string" ? JSON.parse(resultData) : resultData;
                            if (jsonData.reason == "error") throw new Error("Data error");

                            const newData = jsonData.data && jsonData.data[0] ? jsonData.data[0] : [];
                            const existingIds = new Set(allEmployees.map((e) => e.EmployeeID));
                            const uniqueNewData = newData.filter((e) => !existingIds.has(e.EmployeeID));
                            allEmployees = [...allEmployees, ...uniqueNewData];

                            if (jsonData.data && jsonData.data[1] && jsonData.data[1][0]) {
                                totalCount = jsonData.data[1][0].TotalCount || 0;
                            }

                            currentSkip = skip;
                            isLoadingApiData = false;
                            backgroundLoadScheduled = false;
                            resolveFetch(allEmployees);
                        } catch (error) {
                            isLoadingApiData = false;
                            backgroundLoadScheduled = false;
                            rejectFetch("Data Loading Error");
                        }
                    },
                    error: function () {
                        isLoadingApiData = false;
                        backgroundLoadScheduled = false;
                        rejectFetch("Data Loading Error");
                    },
                });
            });

        apiQueue = apiQueue.then(() => runFetch());

        apiQueue
            .then(function () {
                jqDeferred.resolve(allEmployees);
            })
            .catch(function (err) {
                jqDeferred.reject(err);
            });

        return jqDeferred.promise();
    }

    function loadSelectedEmployees() {
        const jqDeferred = $.Deferred();

        if (!cfg.useApi || !selectedIds || selectedIds.length === 0) {
            selectedLoaded = true;
            selectedCache = [];
            jqDeferred.resolve([]);
            return jqDeferred.promise();
        }

        if (selectedLoaded && Array.isArray(selectedCache)) {
            const existingIds = new Set(allEmployees.map((e) => String(e.EmployeeID)));
            selectedCache.forEach((s) => {
                if (!existingIds.has(String(s.EmployeeID))) allEmployees.push(s);
            });
            jqDeferred.resolve(allEmployees);
            return jqDeferred.promise();
        }

        if (cfg.apiData && Array.isArray(cfg.apiData)) {
            const sel = cfg.apiData.filter((e) => selectedIds.includes(String(e.EmployeeID)));
            const existingIds = new Set(allEmployees.map((e) => String(e.EmployeeID)));
            sel.forEach((s) => {
                if (!existingIds.has(String(s.EmployeeID))) allEmployees.push(s);
            });
            selectedCache = sel.slice();
            selectedLoaded = true;
            jqDeferred.resolve(allEmployees);
            return jqDeferred.promise();
        }

        window.__hpaEmployeeSelectedPromises = window.__hpaEmployeeSelectedPromises || {};
        window.__hpaEmployeeSelectedCache = window.__hpaEmployeeSelectedCache || {};

        const selKey = selectedIds.slice().map(String).sort().join(",");

        if (window.__hpaEmployeeSelectedCache[selKey]) {
            const cached = window.__hpaEmployeeSelectedCache[selKey] || [];
            const existingIds = new Set(allEmployees.map((e) => String(e.EmployeeID)));
            cached.forEach((s) => {
                if (!existingIds.has(String(s.EmployeeID))) allEmployees.push(s);
            });
            selectedCache = cached.slice();
            selectedLoaded = true;
            totalCount = Math.max(totalCount, allEmployees.length);
            jqDeferred.resolve(allEmployees);
            return jqDeferred.promise();
        }

        if (window.__hpaEmployeeSelectedPromises[selKey]) {
            window.__hpaEmployeeSelectedPromises[selKey]
                .then((selData) => {
                    const cached = window.__hpaEmployeeSelectedCache[selKey] || [];
                    const existingIds = new Set(allEmployees.map((e) => String(e.EmployeeID)));
                    cached.forEach((s) => {
                        if (!existingIds.has(String(s.EmployeeID))) allEmployees.push(s);
                    });
                    selectedCache = cached.slice();
                    selectedLoaded = true;
                    totalCount = Math.max(totalCount, allEmployees.length);
                    jqDeferred.resolve(allEmployees);
                })
                .catch(() => {
                    selectedLoaded = true;
                    selectedCache = [];
                    jqDeferred.resolve(allEmployees);
                });
            return jqDeferred.promise();
        }

        const nativePromise = new Promise((resolveNative, rejectNative) => {
            const extraparam = [];
            extraparam.push("@ProcName");
            extraparam.push(cfg.ajaxListName || "EmployeeListAll_DataSetting_Custom");
            extraparam.push("@Take");
            extraparam.push(cfg.take);
            extraparam.push("@Skip");
            extraparam.push(0);
            extraparam.push("@LanguageID");
            extraparam.push(LanguageID || "VN");

            AjaxHPAParadise({
                data: {
                    name: "sp_LoadGridUsingAPI",
                    param: extraparam,
                },
                success: function (resultData) {
                    try {
                        let jsonData = typeof resultData === "string" ? JSON.parse(resultData) : resultData;
                        if (jsonData.reason == "error") throw new Error("Data error");

                        const selData = jsonData.data && jsonData.data[0] ? jsonData.data[0] : [];
                        window.__hpaEmployeeSelectedCache[selKey] = selData.slice();

                        const existingIds = new Set(allEmployees.map((e) => String(e.EmployeeID)));
                        const uniqueNew = selData.filter((e) => !existingIds.has(String(e.EmployeeID)));
                        allEmployees = [...allEmployees, ...uniqueNew];

                        selectedCache = selData.slice();
                        selectedLoaded = true;
                        totalCount = Math.max(totalCount, allEmployees.length);

                        resolveNative(allEmployees);
                    } catch (e) {
                        console.error("Error loading selected employees:", e);
                        window.__hpaEmployeeSelectedCache[selKey] = [];
                        selectedLoaded = true;
                        selectedCache = [];
                        resolveNative(allEmployees);
                    } finally {
                        delete window.__hpaEmployeeSelectedPromises[selKey];
                    }
                },
                error: function () {
                    window.__hpaEmployeeSelectedCache[selKey] = [];
                    selectedLoaded = true;
                    selectedCache = [];
                    delete window.__hpaEmployeeSelectedPromises[selKey];
                    rejectNative("API Error");
                },
            });
        });

        window.__hpaEmployeeSelectedPromises[selKey] = nativePromise;

        nativePromise
            .then(() => {
                const cached = window.__hpaEmployeeSelectedCache[selKey] || [];
                const existingIds = new Set(allEmployees.map((e) => String(e.EmployeeID)));
                cached.forEach((s) => {
                    if (!existingIds.has(String(s.EmployeeID))) allEmployees.push(s);
                });
                selectedCache = cached.slice();
                selectedLoaded = true;
                totalCount = Math.max(totalCount, allEmployees.length);
                jqDeferred.resolve(allEmployees);
            })
            .catch(() => {
                selectedLoaded = true;
                selectedCache = [];
                jqDeferred.resolve(allEmployees);
            });

        return jqDeferred.promise();
    }

    function loadEmployeeImage(employee) {
        if (!cfg.showAvatar || !employee.storeImgName || !employee.paramImg) {
            return SVG_PLACEHOLDER;
        }

        var cacheKey = getImageCacheKey(employee);
        window.__paradisefile_cache = window.__paradisefile_cache || {};
        window.__paradisefile_promises = window.__paradisefile_promises || {};

        if (window.__paradisefile_cache[cacheKey]) {
            var cachedUrl = window.__paradisefile_cache[cacheKey];
            avatarCache[employee.EmployeeID] = cachedUrl;
            return cachedUrl;
        }

        if (window.__paradisefile_promises[cacheKey]) {
            window.__paradisefile_promises[cacheKey]
                .then(function (url) {
                    try {
                        avatarCache[employee.EmployeeID] = url;
                        $(`#${cfg.containerId} .hpa-emp-dropdown-chip[data-emp-id="${employee.EmployeeID}"] img`).attr("src", url);
                        $(`#${cfg.dropdownId} .grid-employee-image[data-emp-id="${employee.EmployeeID}"]`).attr("src", url);
                    } catch (e) {}
                })
                .catch(function () {});
            return SVG_PLACEHOLDER;
        }

        try {
            const decoded = decodeURIComponent(employee.paramImg);
            const paramArray = JSON.parse(decoded);
            if (Array.isArray(paramArray) && paramArray.length > 1) {
                var native = new Promise(function (resolveNative) {
                    AjaxHPAParadise({
                        data: {
                            name: employee.storeImgName,
                            param: paramArray,
                        },
                        xhrFields: { responseType: "blob" },
                        cache: true,
                        success: function (blob) {
                            try {
                                if (blob && blob.size > 0) {
                                    const imgUrl = URL.createObjectURL(blob);
                                    window.__paradisefile_cache[cacheKey] = imgUrl;
                                    avatarCache[employee.EmployeeID] = imgUrl;

                                    try {
                                        $(`#${cfg.containerId} .hpa-emp-dropdown-chip img[data-img-key="${cacheKey}"]`).attr("src", imgUrl);
                                        $(`#${cfg.containerId} .hpa-emp-dropdown-chip[data-emp-id="${employee.EmployeeID}"] img`).attr("src", imgUrl);
                                        $(`#${cfg.dropdownId} .grid-employee-image[data-img-key="${cacheKey}"]`).attr("src", imgUrl);
                                        $(`#${cfg.dropdownId} .grid-employee-image[data-emp-id="${employee.EmployeeID}"]`).attr("src", imgUrl);
                                    } catch (e) {}

                                    resolveNative(imgUrl);
                                } else {
                                    resolveNative(null);
                                }
                            } catch (e) {
                                resolveNative(null);
                            }
                        },
                        error: function () {
                            resolveNative(null);
                        },
                    });
                });

                window.__paradisefile_promises[cacheKey] = native;
                native.finally(function () {
                    delete window.__paradisefile_promises[cacheKey];
                });
            }
        } catch (e) {}

        return SVG_PLACEHOLDER;
    }

    // ===== RENDER FUNCTIONS =====

    function renderSelectorButton() {
        let html = `
                        <div class="hpa-emp-dropdown-wrapper">
                            <button type="button" class="hpa-emp-dropdown-btn" id="empDropdownBtn_${cfg.containerId}">
                                <div class="hpa-emp-dropdown-chips">
                    `;

        const selectedEmps = selectedIds.map((id) => allEmployees.find((e) => String(e.EmployeeID) === String(id))).filter((e) => e);

        const maxVisible = cfg.maxVisibleChips;
        const visibleEmps = selectedEmps.slice(0, maxVisible);
        const remainingCount = selectedEmps.length - maxVisible;

        if (selectedEmps.length === 0) {
            html += `<span class="hpa-emp-dropdown-count">${cfg.placeholder}</span>`;
        } else {
            if (cfg.showAvatar) {
                visibleEmps.forEach((emp) => {
                    const imgKey = getImageCacheKey(emp);
                    const imgUrl =
                        (window.__paradisefile_cache && window.__paradisefile_cache[imgKey]) || avatarCache[emp.EmployeeID] || loadEmployeeImage(emp);
                    html += `
                                    <div class="hpa-emp-dropdown-chip" data-emp-id="${emp.EmployeeID}" data-img-key="${imgKey}" title="${escapeHtml(
                        emp.FullName
                    )}" style="${getAvatarStyle()}">
                                        <img data-img-key="${imgKey}" src="${imgUrl}" alt="${escapeHtml(emp.FullName)}" />
                                    </div>
                                `;
                });
            } else {
                visibleEmps.forEach((emp) => {
                    const initials = getInitials(emp.FullName);
                    html += `
                                    <div class="hpa-emp-dropdown-chip-text" data-emp-id="${emp.EmployeeID}" title="${escapeHtml(
                        emp.FullName
                    )}" style="${getAvatarStyle()}font-size:${getChipFontSize()}px;">
                                        ${initials}
                                    </div>
                                `;
                });
            }

            if (remainingCount > 0) {
                html += `<span class="hpa-emp-dropdown-count">+${remainingCount}</span>`;
            }
        }

        html += `
                                </div>
                                <span class="hpa-emp-dropdown-icon"><i class="bi bi-chevron-down"></i></span>
                            </button>
                        </div>
                    `;

        $(`#${cfg.containerId}`).html(html);

        // Attach click handler
        $(`#empDropdownBtn_${cfg.containerId}`)
            .off("click")
            .on("click", function (e) {
                e.stopPropagation();
                toggleDropdown();
            });

        if (cfg.showAvatar) {
            selectedEmps.forEach((emp) => {
                if (!avatarCache[emp.EmployeeID] && emp.storeImgName && emp.paramImg) {
                    loadEmployeeImage(emp);
                }
            });
        }
    }

    function initDropdownContainer() {
        const $dropdown = $(`#${cfg.dropdownId}`);
        $dropdown.addClass("hpa-emp-dropdown-container");
        $dropdown.css({
            width: cfg.width + "px",
            display: "none",
        });

        // Create backdrop
        if (!$(`#${cfg.dropdownId}-backdrop`).length) {
            $("body").append(`<div id="${cfg.dropdownId}-backdrop" class="hpa-emp-dropdown-backdrop"></div>`);
        }
    }

    function positionDropdown() {
        const $btn = $(`#empDropdownBtn_${cfg.containerId}`);
        const $dropdown = $(`#${cfg.dropdownId}`);

        if ($btn.length === 0) return;

        if ($dropdown.parent().prop("tagName") !== "BODY") {
            $dropdown.appendTo(document.body);
        }

        const btnOffset = $btn.offset();
        const btnHeight = $btn.outerHeight();
        const dropdownHeight = cfg.height;
        const windowHeight = $(window).height();
        const scrollTop = $(window).scrollTop();

        const spaceBelow = windowHeight - (btnOffset.top - scrollTop + btnHeight);
        const spaceAbove = btnOffset.top - scrollTop;

        let top;
        if (spaceBelow >= dropdownHeight || spaceBelow >= spaceAbove) {
            // Open below
            top = btnOffset.top + btnHeight + 4;
        } else {
            // Open above
            top = btnOffset.top - dropdownHeight - 4;
        }

        $dropdown.css({
            position: "fixed",
            top: top + "px",
            left: btnOffset.left + "px",
            zIndex: 9999,
        });
    }

    function toggleDropdown() {
        const $dropdown = $(`#${cfg.dropdownId}`);
        const $backdrop = $(`#${cfg.dropdownId}-backdrop`);
        const $btn = $(`#empDropdownBtn_${cfg.containerId}`);

        if (isDropdownOpen) {
            closeDropdown();
        } else {
            openDropdown();
        }
    }

    function openDropdown() {
        const $dropdown = $(`#${cfg.dropdownId}`);
        const $backdrop = $(`#${cfg.dropdownId}-backdrop`);
        const $btn = $(`#empDropdownBtn_${cfg.containerId}`);

        // Close other dropdowns
        $(".hpa-emp-dropdown-container").not($dropdown).removeClass("open").hide();
        $(".hpa-emp-dropdown-backdrop").not($backdrop).removeClass("open").hide();
        $(".hpa-emp-dropdown-btn").not($btn).removeClass("open");

        isDropdownOpen = true;
        $btn.addClass("open");
        $backdrop.addClass("open").show();

        positionDropdown();
        $dropdown.addClass("open").show();

        if (!dataGridInstance) {
            isLoadingApiData = true;
            backgroundLoadScheduled = true;
            createDataGrid();

            loadEmployeeList(0, cfg.take)
                .then(() => {
                    snapshotEmployees = getSortedEmployees();
                    if (dataGridInstance) {
                        dataGridInstance.beginUpdate();
                        dataGridInstance.getDataSource().reload();
                        dataGridInstance.endUpdate();

                        if (selectedLoaded && Array.isArray(selectedCache) && selectedCache.length > 0) {
                            const cachedIds = selectedCache.map((e) => String(e.EmployeeID));
                            const toSelect = selectedIds.filter((id) => cachedIds.includes(String(id)));
                            if (toSelect.length > 0) {
                                dataGridInstance.option("selectedRowKeys", toSelect);
                            }
                        }
                    }
                })
                .catch(() => {});
        } else {
            if (allEmployees.length < totalCount) {
                if (!backgroundLoadScheduled) {
                    isLoadingApiData = true;
                    backgroundLoadScheduled = true;
                    loadEmployeeList(allEmployees.length, cfg.take)
                        .then(() => {
                            backgroundLoadScheduled = false;
                            snapshotEmployees = getSortedEmployees();
                            if (dataGridInstance) {
                                dataGridInstance.beginUpdate();
                                dataGridInstance.getDataSource().reload();
                                dataGridInstance.endUpdate();

                                if (selectedLoaded && Array.isArray(selectedCache) && selectedCache.length > 0) {
                                    const cachedIds = selectedCache.map((e) => String(e.EmployeeID));
                                    const toSelect = selectedIds.filter((id) => cachedIds.includes(String(id)));
                                    if (toSelect.length > 0) {
                                        dataGridInstance.option("selectedRowKeys", toSelect);
                                    }
                                }
                            }
                        })
                        .catch(() => {});
                }
            }
        }

        setTimeout(() => {
            $(`#${cfg.dropdownId} .hpa-emp-dropdown-search`).focus();
        }, 100);
    }

    function closeDropdown() {
        const $dropdown = $(`#${cfg.dropdownId}`);
        const $backdrop = $(`#${cfg.dropdownId}-backdrop`);
        const $btn = $(`#empDropdownBtn_${cfg.containerId}`);

        isDropdownOpen = false;
        $btn.removeClass("open");
        $backdrop.removeClass("open").hide();
        $dropdown.removeClass("open").hide();
    }

    function filterEmployees(searchText) {
        if (!dataGridInstance || isGridInitializing) return;

        currentSearchText = searchText.trim();

        if (currentSearchText) {
            const searchNormalized = normalizeSearchText(currentSearchText);

            // Filter with Vietnamese tone-insensitive search
            dataGridInstance.filter(function (employee) {
                const fullName = employee.FullName || "";
                const fullNameNormalized = normalizeSearchText(fullName);

                const employeeId = String(employee.EmployeeID || "");
                const title = normalizeSearchText(employee.Title || employee.PositionName || "");

                return fullNameNormalized.includes(searchNormalized) || employeeId.includes(currentSearchText) || title.includes(searchNormalized);
            });
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

    function getSortedEmployees() {
        let data = [...allEmployees];
        if (currentSearchText.trim()) {
            const searchNormalized = normalizeSearchText(currentSearchText);
            data = data.filter((emp) => {
                const fullName = normalizeSearchText(emp.FullName || "");
                const employeeId = String(emp.EmployeeID || "");
                const title = normalizeSearchText(emp.Title || emp.PositionName || "");

                return fullName.includes(searchNormalized) || employeeId.includes(currentSearchText) || title.includes(searchNormalized);
            });
        }
        return data.sort((a, b) => {
            const aSelected = selectedIds.includes(String(a.EmployeeID));
            const bSelected = selectedIds.includes(String(b.EmployeeID));
            if (aSelected && !bSelected) return -1;
            if (!aSelected && bSelected) return 1;
            return 0;
        });
    }

    function createDataGrid() {
        const headerHeight = 50;
        const bodyHeight = cfg.height - headerHeight;

        const html = `
                        <div class="hpa-emp-dropdown-header">
                            <input type="text" class="hpa-emp-dropdown-search" placeholder="Tìm kiếm..." />
                        </div>
                        <div class="hpa-emp-dropdown-body" style="height:${bodyHeight}px;max-height:${bodyHeight}px;">
                            <div class="employee-grid-inner"></div>
                        </div>
                    `;

        $(`#${cfg.dropdownId}`).html(html);

        if (snapshotEmployees.length === 0 && allEmployees.length > 0) {
            snapshotEmployees = getSortedEmployees();
        }

        const gridStore = new DevExpress.data.CustomStore({
            key: "EmployeeID",
            load: function (loadOptions) {
                const deferred = $.Deferred();
                const skip = loadOptions.skip || 0;
                const take = loadOptions.take || cfg.take;

                let gridData = getGridData();
                const needsMoreData = skip + take > gridData.length && allEmployees.length < totalCount;

                if (needsMoreData && !isLoadingApiData) {
                    const apiSkip = allEmployees.length;
                    loadEmployeeList(apiSkip, cfg.take)
                        .then(() => {
                            snapshotEmployees = getSortedEmployees();
                            gridData = snapshotEmployees;
                            const pageData = gridData.slice(skip, skip + take);
                            const finalTotalCount = totalCount > 0 ? totalCount : gridData.length;
                            deferred.resolve({ data: pageData, totalCount: finalTotalCount });
                        })
                        .catch((err) => deferred.reject(err));
                    return deferred.promise();
                }

                const pageData = gridData.slice(skip, skip + take);
                const finalTotalCount = totalCount > 0 ? totalCount : gridData.length;
                deferred.resolve({ data: pageData, totalCount: finalTotalCount });
                return deferred.promise();
            },
        });

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
        let fixedColumnsWidth = 40;

        if (cfg.showAvatar) {
            gridColumns.push({
                dataField: "storeImgName",
                caption: "",
                width: cfg.avatarWidth + 16,
                cellTemplate: function (container, options) {
                    const emp = options.data;
                    const imgKey = getImageCacheKey(emp);
                    let imgUrl = (window.__paradisefile_cache && window.__paradisefile_cache[imgKey]) || avatarCache[emp.EmployeeID] || loadEmployeeImage(emp);
                    const $img = $(
                        `<img class="grid-employee-image" data-emp-id="${emp.EmployeeID}" data-img-key="${imgKey}" src="${imgUrl}" alt="${escapeHtml(
                            emp.FullName
                        )}" style="${getAvatarStyle()}border-radius:50%;object-fit:cover;" />`
                    );
                    container.html($img);
                },
            });
            fixedColumnsWidth += cfg.avatarWidth + 16;
        }

        const nameColumnWidth = `calc(100% - ${fixedColumnsWidth}px)`;
        gridColumns.push({
            dataField: "FullName",
            caption: "Tên nhân viên",
            width: nameColumnWidth,
            cellTemplate: function (container, options) {
                const emp = options.data || {};
                const name = escapeHtml(emp.FullName || emp.EmployeeName || emp.DisplayName || "");
                const title = emp.Title || emp.PositionName || "";
                const html = `<div class="grid-employee-cell"><div style="flex:1;min-width:0"><span class="hpa-emp-name" data-empid="${
                    emp.EmployeeID
                }" title="${name}${title ? " - " + escapeHtml(title) : ""}" style="cursor:pointer;display:inline-block;width:100%;">${name}</span></div></div>`;
                container.html(html);
            },
        });

        const gridConfig = {
            dataSource: gridStore,
            keyExpr: "EmployeeID",
            columns: gridColumns,
            showColumnHeaders: false,
            remoteOperations: true,
            paging: { enabled: true, pageSize: cfg.take },
            scrolling: { mode: "virtual" },
            height: bodyHeight,
            width: "100%",
            selection: {
                mode: cfg.multi ? "multiple" : "single",
                selectAllMode: cfg.multi ? "allPages" : "page",
            },
            selectedRowKeys: selectedIds,
            onSelectionChanged: function (selectedItems) {
                const newSelectedIds = cfg.multi ? selectedItems.selectedRowKeys : [selectedItems.selectedRowKeys[0]];
                const hasChanged = JSON.stringify([...selectedIds].sort()) !== JSON.stringify([...newSelectedIds].sort());

                if (!hasChanged) return;

                selectedIds = newSelectedIds.map(String);

                if (cfg.onChange) cfg.onChange(selectedIds);

                if (cfg.tableSN && cfg.idValue) {
                    saveToDB(cfg.multi ? selectedIds : selectedIds[0] || null);
                }

                snapshotEmployees = getSortedEmployees();

                if (currentSearchText) {
                    currentSearchText = "";
                    $(`#${cfg.dropdownId} .hpa-emp-dropdown-search`).val("");
                }

                setTimeout(() => {
                    if (dataGridInstance) {
                        dataGridInstance.beginUpdate();
                        dataGridInstance.getDataSource().reload();
                        dataGridInstance.endUpdate();
                        renderSelectorButton();
                    }
                }, 50);
            },
        };

        $(`#${cfg.dropdownId} .employee-grid-inner`).dxDataGrid(gridConfig);
        dataGridInstance = $(`#${cfg.dropdownId} .employee-grid-inner`).dxDataGrid("instance");

        // Click handler for name toggle
        $(document)
            .off(`click.empNameToggle_${cfg.containerId}`)
            .on(`click.empNameToggle_${cfg.containerId}`, `#${cfg.dropdownId} .hpa-emp-name`, function (e) {
                e.stopPropagation();
                try {
                    if (!dataGridInstance) return;
                    const id = $(this).data("empid");
                    if (id === undefined || id === null) return;
                    const current = dataGridInstance.option("selectedRowKeys") || [];
                    const asStr = current.map(String);
                    const exists = asStr.indexOf(String(id)) !== -1;
                    let newSel;
                    if (exists) {
                        newSel = asStr.filter(function (x) {
                            return x !== String(id);
                        });
                    } else {
                        newSel = asStr.concat([String(id)]);
                    }
                    dataGridInstance.option("selectedRowKeys", newSel);
                } catch (e) {}
            });

        setTimeout(() => {
            if (dataGridInstance) {
                let foundSelectedEmps = [];
                if (selectedLoaded && Array.isArray(selectedCache) && selectedCache.length > 0) {
                    const cachedIds = selectedCache.map((e) => String(e.EmployeeID));
                    foundSelectedEmps = selectedIds.filter((id) => cachedIds.includes(String(id)));
                } else {
                    foundSelectedEmps = selectedIds.filter((id) => allEmployees.some((e) => String(e.EmployeeID) === String(id)));
                }

                if (foundSelectedEmps.length > 0) {
                    dataGridInstance.option("selectedRowKeys", foundSelectedEmps);
                }
            }
        }, 100);

        // Scroll handler
        function attachScrollHandlers() {
            const onScrollLoadMore = function () {
                try {
                    const el = this;
                    const $el = $(el);
                    const scrollTop = typeof el.scrollTop === "number" ? el.scrollTop : $el.scrollTop();
                    const scrollHeight = typeof el.scrollHeight === "number" ? el.scrollHeight : $el.prop("scrollHeight") || 0;
                    const clientHeight = typeof el.clientHeight === "number" ? el.clientHeight : $el.innerHeight() || 0;
                    const distanceFromBottom = scrollHeight - (scrollTop + clientHeight);

                    if (distanceFromBottom < 140 && allEmployees.length < totalCount && !isLoadingApiData) {
                        const apiSkip = allEmployees.length;
                        loadEmployeeList(apiSkip, cfg.take)
                            .then(() => {
                                snapshotEmployees = getSortedEmployees();
                                if (dataGridInstance) {
                                    dataGridInstance.beginUpdate();
                                    dataGridInstance.getDataSource().reload();
                                    dataGridInstance.endUpdate();

                                    if (selectedLoaded && Array.isArray(selectedCache) && selectedCache.length > 0) {
                                        const cachedIds = selectedCache.map((e) => String(e.EmployeeID));
                                        const toSelect = selectedIds.filter((id) => cachedIds.includes(String(id)));
                                        if (toSelect.length > 0) dataGridInstance.option("selectedRowKeys", toSelect);
                                    }
                                }
                            })
                            .catch(() => {});
                    }
                } catch (err) {}
            };

            const tryBind = (attempt) => {
                attempt = attempt || 0;
                try {
                    var $scrollEl = null;

                    var scrollable = dataGridInstance && dataGridInstance.getScrollable ? dataGridInstance.getScrollable() : null;
                    if (scrollable && typeof scrollable.element === "function") {
                        try {
                            $scrollEl = $(scrollable.element());
                        } catch (e) {
                            $scrollEl = null;
                        }
                    }

                    if ((!$scrollEl || $scrollEl.length === 0) && $(`#${cfg.dropdownId} .dx-viewport`).length) {
                        $scrollEl = $(`#${cfg.dropdownId} .dx-viewport`);
                    }

                    if ((!$scrollEl || $scrollEl.length === 0) && $(`#${cfg.dropdownId} .hpa-emp-dropdown-body`).length) {
                        $scrollEl = $(`#${cfg.dropdownId} .hpa-emp-dropdown-body`);
                    }

                    if ($scrollEl && $scrollEl.length > 0) {
                        $scrollEl.off("scroll.hpa").on("scroll.hpa", onScrollLoadMore);
                        return true;
                    }
                } catch (e) {}

                if (attempt < 12) {
                    setTimeout(() => tryBind(attempt + 1), 120);
                }
                return false;
            };

            tryBind(0);
        }
        attachScrollHandlers();

        // Search input handler with debounce
        let searchTimeout;
        $(`#${cfg.dropdownId} .hpa-emp-dropdown-search`)
            .off("keyup")
            .on("keyup", function (e) {
                // Handle Escape key
                if (e.key === "Escape" || e.keyCode === 27) {
                    closeDropdown();
                    return;
                }

                clearTimeout(searchTimeout);
                searchTimeout = setTimeout(() => {
                    filterEmployees($(this).val());
                }, 300);
            });

        // Prevent dropdown close when clicking inside
        $(`#${cfg.dropdownId}`)
            .off("click")
            .on("click", function (e) {
                e.stopPropagation();
            });

        setTimeout(() => {
            isGridInitializing = false;
        }, 100);

        $(`#${cfg.dropdownId} .hpa-emp-dropdown-body`)
            .off("scroll")
            .on("scroll", function () {
                const scrollTop = $(this).scrollTop();
                const scrollHeight = this.scrollHeight;
                const clientHeight = this.clientHeight;
                const distanceFromBottom = scrollHeight - (scrollTop + clientHeight);

                if (distanceFromBottom < 100 && allEmployees.length < totalCount && !isLoadingApiData) {
                    const apiSkip = allEmployees.length;
                    loadEmployeeList(apiSkip, cfg.take).then(() => {
                        snapshotEmployees = getSortedEmployees();
                        if (dataGridInstance) {
                            dataGridInstance.beginUpdate();
                            dataGridInstance.getDataSource().reload();
                            dataGridInstance.endUpdate();

                            if (selectedLoaded && Array.isArray(selectedCache) && selectedCache.length > 0) {
                                const cachedIds = selectedCache.map((e) => String(e.EmployeeID));
                                const toSelect = selectedIds.filter((id) => cachedIds.includes(String(id)));
                                if (toSelect.length > 0) dataGridInstance.option("selectedRowKeys", toSelect);
                            }
                        }
                    });
                }
            });
    }

    function saveToDB(val) {
        if (!cfg.tableSN || !cfg.idValue) return;
        const valueStr = cfg.multi ? (val || []).join(",") : val || "";
        saveDataTableCommon({
            tableSN: cfg.tableSN,
            columns: [cfg.columnName],
            values: [valueStr],
            types: ["text"],
            idValue: cfg.idValue,
            idColumnName: cfg.idColumnName || "ID",
            onSuccess: () => {
                if (!cfg.silent && typeof uiManager !== "undefined") {
                    uiManager.showAlert({ type: "success", message: "%UpdateSuccess%" });
                }
            },
            onError: () => {
                if (typeof uiManager !== "undefined") {
                    uiManager.showAlert({ type: "error", message: "Lưu thất bại!" });
                }
            },
        });
    }

    // Click outside to close
    $(document)
        .off(`click.employeeDropdown_${cfg.containerId}`)
        .on(`click.employeeDropdown_${cfg.containerId}`, function (e) {
            if (isDropdownOpen && !$(e.target).closest(`#${cfg.containerId}, #${cfg.dropdownId}`).length) {
                closeDropdown();
            }
        });

    // Click backdrop to close
    $(document)
        .off(`click.employeeBackdrop_${cfg.containerId}`)
        .on(`click.employeeBackdrop_${cfg.containerId}`, `#${cfg.dropdownId}-backdrop`, function (e) {
            closeDropdown();
        });

    // Window resize handler
    $(window)
        .off(`resize.employeeDropdown_${cfg.containerId}`)
        .on(`resize.employeeDropdown_${cfg.containerId}`, function () {
            if (isDropdownOpen) {
                positionDropdown();
            }
        });

    // Window scroll handler
    $(window)
        .off(`scroll.employeeDropdown_${cfg.containerId}`)
        .on(`scroll.employeeDropdown_${cfg.containerId}`, function () {
            if (isDropdownOpen) {
                positionDropdown();
            }
        });

    // ===== INITIALIZATION =====

    const containerHtml = `
                    <div id="${cfg.containerId}"></div>
                    <div id="${cfg.dropdownId}"></div>
                `;
    $el.html(containerHtml);

    initDropdownContainer();
    renderSelectorButton();

    if (cfg.useApi && !cfg.apiData) {
        if (selectedIds && selectedIds.length > 0) {
            loadSelectedEmployees()
                .then(() => {
                    renderSelectorButton();
                })
                .catch(() => {
                    renderSelectorButton();
                });
        }
    } else {
        renderSelectorButton();
    }

    return {
        getSelectedIds: () => selectedIds,
        setSelectedIds: (ids) => {
            selectedIds = ids.map(String);
            selectedLoaded = false;
            selectedCache = [];
            renderSelectorButton();
            if (dataGridInstance) {
                dataGridInstance.option("selectedRowKeys", selectedIds);
            }
        },
        refresh: () => {
            if (dataGridInstance) dataGridInstance.refresh();
        },
        open: () => {
            if (!isDropdownOpen) openDropdown();
        },
        close: () => {
            if (isDropdownOpen) closeDropdown();
        },
        destroy: () => {
            $(document).off(`click.employeeDropdown_${cfg.containerId}`);
            $(document).off(`click.employeeBackdrop_${cfg.containerId}`);
            $(document).off(`click.empNameToggle_${cfg.containerId}`);
            $(window).off(`resize.employeeDropdown_${cfg.containerId}`);
            $(window).off(`scroll.employeeDropdown_${cfg.containerId}`);
            $(`#${cfg.dropdownId}-backdrop`).remove();
            $el.empty();
        },
    };
}