USE Paradise_Beta_Tai2
GO
if object_id('[dbo].[sp_hpaControlSelectBox]') is null
	EXEC ('CREATE PROCEDURE [dbo].[sp_hpaControlSelectBox] as select 1')
GO

ALTER PROCEDURE [dbo].[sp_hpaControlSelectBox]
    @TableName VARCHAR(256) = ''
AS
BEGIN
    -- =========================================================================
    -- hpaControlSelectBox - READONLY MODE
    -- =========================================================================
    UPDATE #temptable SET
        loadUI = N'
        window["DataSource_%ColumnName%"] = window["DataSource_%ColumnName%"] || [];

        window.Instance%ColumnName% = $("#%UID%").dxSelectBox({
            dataSource: window["DataSource_%ColumnName%"],
            valueExpr: "ID",
            displayExpr: "Name",
            placeholder: "Chọn...",
            disabled: true,
            stylingMode: "outlined"
            }).dxSelectBox("instance");

            const _initial%ColumnName% = Instance%ColumnName%.option("value");

        if ("%DataSourceSP%" !== "") {
            AjaxHPAParadise({
                data: {
                    name: "%DataSourceSP%",
                    param: ["LoginID", LoginID, "LanguageID", LanguageID]
                },
                success: function (res) {
                    const json = typeof res === "string" ? JSON.parse(res) : res;
                    window["DataSource_%ColumnName%"] = (json.data && json.data[0]) || [];
                    Instance%ColumnName%.option("dataSource", window["DataSource_%ColumnName%"]);
                }
            });
        }
        '
    WHERE [Type] = 'hpaControlSelectBox' AND [ReadOnly] = 1;

    -- =========================================================================
    -- hpaControlSelectBox - AUTOSAVE MODE + GRID SYNC
    -- =========================================================================
	UPDATE #temptable SET
		loadUI = N'
		window["DataSource_%ColumnName%"] = window["DataSource_%ColumnName%"] || [];

		let %columnName%DataSourceSP = "%DataSourceSP%";
        let %columnName%IsLoading = false;
        let %columnName%IsDataLoaded = false;
        let %columnName%CellInfo = null; // Biến lưu cellInfo để sync Grid

        function highlightText%ColumnName%(text, search) {
            if (!search || !text) return text;
            const regex = new RegExp("(" + search.replace(/[.*+?^${}()|[\]\\]/g, "\\$&") + ")", "gi");
            return text.replace(regex, "<mark class=\"bg-warning fw-bold px-1 rounded\">$1</mark>");
        }

		window.Instance%ColumnName% = $("#%UID%").dxSelectBox({
			dataSource: window["DataSource_%ColumnName%"],
            valueExpr: "ID",
            displayExpr: "Name",
            placeholder: "Tìm kiếm hoặc chọn...",
            searchEnabled: true,
            searchMode: "contains",
            searchExpr: ["Name", "Code", "Description"],
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
                minWidth: 280,
                onShowing: function(e) {
                    if (!%columnName%IsDataLoaded && %columnName%DataSourceSP && %columnName%DataSourceSP !== "") {
                        load%columnName%DataSource();
                    }
                }
            },
            itemTemplate: function(data, index) {
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
                const searchValue = Instance%ColumnName%.option("searchValue") || "";

                $("<div>")
                    .addClass("fw-semibold")
                    .css({
                        fontSize: "14px",
                        lineHeight: "1.4",
                        overflow: "hidden",
                        textOverflow: "ellipsis",
                        whiteSpace: "nowrap"
                    })
                    .html(highlightText%ColumnName%(data.Name || "", searchValue))
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
                $(e.component._popup.content()).parent()
                    .addClass("shadow-lg border rounded hpa-responsive")
                    .css({
                        borderRadius: "12px",
                        padding: "8px 0",
                        borderColor: "#dee2e6"
                    });
            },
            onFocusIn: function(e) {
                Instance%ColumnName%.option("showClearButton", true);
            },
            onFocusOut: function(e) {
                Instance%ColumnName%.option("showClearButton", false);
            },
            onKeyDown: function(e) {
                if (e.key === "Enter" || e.key === "Tab") {
                    Instance%ColumnName%.option("showClearButton", false);
                }
            },
            onValueChanged: async function(e) {
                if (!e.event) return;

                // Nếu người dùng tìm kiếm rỗng và kết quả trả về là 0/empty/null,
                // không thực hiện lưu và giữ lại giá trị hiện tại.
                if (e.value === "" || e.value == null || e.value === 0 || e.value === "0") {
                    Instance%ColumnName%.option("value", _initial%ColumnName%);
                    return;
                }

                $("#%UID%").find(".dx-texteditor-input").blur();
                if (Instance%ColumnName% && Instance%ColumnName%.blur) Instance%ColumnName%.blur();

                const $el = $(e.element);
                $el.css({
                    transform: "scale(1.02)",
                    boxShadow: "0 0 0 3px rgba(28, 151, 94, 0.2)",
                    transition: "all 0.2s ease"
                });
                setTimeout(() => {
                    $el.css({
                        transform: "",
                        boxShadow: ""
                    });
                }, 300);

                // Gọi hàm callback onSelectBoxChanged nếu có
                if (typeof window["onSelectBoxChanged_%ColumnName%"] === "function") {
                    console.log("Calling onSelectBoxChanged_%ColumnName% callback");
                    window["onSelectBoxChanged_%ColumnName%"](e.value, Instance%ColumnName%, e);
                }

				const val = e.value;
				const dataJSON = JSON.stringify(["%tableId%", ["%columnName%"], [val || ""]]);
				
				let currentRecordIDValue = [currentRecordID_%ColumnIDName%];
                let currentRecordID = ["%ColumnIDName%"];

				if ("%ColumnIDName2%" && "%ColumnIDName2%".trim() !== "") {
					currentRecordIDValue.push(currentRecordID_%ColumnIDName2%);
					currentRecordID.push("%ColumnIDName2%");
				}
				const idValsJSON = JSON.stringify([currentRecordIDValue, currentRecordID]);
				
				try {
					const json = await saveFunction(dataJSON, idValsJSON);
					const dtError = json.data[json.data.length - 1] || [];
                    if (dtError.length > 0 && dtError[0].Status === "ERROR") {
                        if ("%IsAlert%" === "1") {
                            uiManager.showAlert({ type: "error", message: dtError[0]?.Message || "Lưu thất bại" });
                        }
                        Instance%ColumnName%.option("value", _initial%ColumnName%);
                    } else {
                        // SYNC GRID: Cập nhật lại giá trị trong Grid sau khi save thành công
                        if (%columnName%CellInfo && %columnName%CellInfo.component) {
                            try {
                                const grid = %columnName%CellInfo.component;
                                const rowKey = %columnName%CellInfo.key || %columnName%CellInfo.data["%ColumnIDName%"];
                                
                                // Cập nhật cell value trong grid
                                grid.cellValue(%columnName%CellInfo.rowIndex, "%columnName%", val);
                                
                                // Refresh cell để hiển thị giá trị mới
                                grid.repaint();
                                
                                console.log("[Grid Sync] SelectBox %columnName%: Updated value =", val, "for row", rowKey);
                            } catch (syncErr) {
                                console.warn("[Grid Sync] SelectBox %columnName%: Không thể sync grid:", syncErr);
                            }
                        }

                        if ("%IsAlert%" === "1") {
                            uiManager.showAlert({ type: "success", message: "Lưu thành công" });
                        }
                    }
                } catch (err) {
                    if ("%IsAlert%" === "1") {
                        uiManager.showAlert({ type: "error", message: "Có lỗi xảy ra khi lưu" });
                    }
                    Instance%ColumnName%.option("value", _initial%ColumnName%);
                    console.error("SelectBox Save Error:", err);
                }
			}
            }).dxSelectBox("instance");

            const _initial%ColumnName% = Instance%ColumnName%.option("value");

        function load%columnName%DataSource() {
            if (!%columnName%DataSourceSP || %columnName%DataSourceSP === "") {
                console.warn("SelectBox %columnName%: No DataSourceSP");
                return;
            }

            if (%columnName%IsLoading || %columnName%IsDataLoaded) return;

            %columnName%IsLoading = true;
            Instance%ColumnName%.option("placeholder", "Đang tải dữ liệu...");

            const $input = $("#%UID%").find(".dx-texteditor-input");
            const gradientAnim = setInterval(() => {
                if (!%columnName%IsLoading) {
                    clearInterval(gradientAnim);
                    $input.css("background", "");
                    return;
                }
                $input.css({
                    backgroundSize: "200% 100%",
                    animation: "none"
                });
            }, 100);

            AjaxHPAParadise({
                data: {
                    name: %columnName%DataSourceSP,
                    param: ["LoginID", LoginID, "LanguageID", LanguageID]
                },
                success: function(res) {
                    const json = typeof res === "string" ? JSON.parse(res) : res;
                    const data = (json.data && json.data[0]) || [];

                    window["DataSource_%ColumnName%"] = data;
                    
                    // Smart Load: Check dữ liệu > 1000 dòng
                    if (data.length > 1000) {
                        console.log("[SmartLoad] SelectBox %ColumnName%: Dữ liệu " + data.length + " dòng - Kích hoạt API load");
                        window["UseAPILoad_%ColumnName%"] = true;
                        Instance%ColumnName%.option("placeholder", "Sử dụng tìm kiếm để load dữ liệu (API)");
                    } else {
                        Instance%ColumnName%.option("dataSource", data);
                        Instance%ColumnName%.repaint();
                        Instance%ColumnName%.option("placeholder", "Tìm kiếm hoặc chọn...");
                    }

                    %columnName%IsLoading = false;
                    %columnName%IsDataLoaded = true;
                    clearInterval(gradientAnim);
                    $input.css("background", "");

                    console.log("SelectBox %columnName%: Loaded", data.length, "items");
                },
                error: function(err) {
                    %columnName%IsLoading = false;
                    clearInterval(gradientAnim);
                    $input.css("background", "");
                    Instance%ColumnName%.option("placeholder", "Lỗi tải dữ liệu");
                    console.error("SelectBox %columnName% error:", err);
                }
            });
        }

        if (%columnName%DataSourceSP && %columnName%DataSourceSP !== "") {
            load%columnName%DataSource();
        }

        // Thêm method setCellInfo vào Instance để nhận cellInfo từ Grid
        Instance%ColumnName%.setCellInfo = function(cellInfo) {
            %columnName%CellInfo = cellInfo;
            console.log("[SelectBox %columnName%] Received cellInfo:", cellInfo);
        };
		'
	WHERE [Type] = 'hpaControlSelectBox' AND [AutoSave] = 1 AND [ReadOnly] = 0;

    -- =========================================================================
    -- hpaControlSelectBox - MANUAL MODE (No AutoSave)
    -- =========================================================================
	UPDATE #temptable SET
		loadUI = N'
		window["DataSource_%ColumnName%"] = window["DataSource_%ColumnName%"] || [];

		let %columnName%DataSourceSP = "%DataSourceSP%";
        let %columnName%IsLoading = false;
        let %columnName%IsDataLoaded = false;

        function highlightText%ColumnName%(text, search) {
            if (!search || !text) return text;
            const regex = new RegExp("(" + search.replace(/[.*+?^${}()|[\]\\]/g, "\\$&") + ")", "gi");
            return text.replace(regex, "<mark class=\"bg-warning fw-bold px-1 rounded\">$1</mark>");
        }

		window.Instance%ColumnName% = $("#%UID%").dxSelectBox({
			dataSource: window["DataSource_%ColumnName%"],
            valueExpr: "ID",
            displayExpr: "Name",
            placeholder: "Tìm kiếm hoặc chọn...",
            searchEnabled: true,
            searchMode: "contains",
            searchExpr: ["Name", "Code", "Description"],
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
                minWidth: 280,
                onShowing: function(e) {
                    if (!%columnName%IsDataLoaded && %columnName%DataSourceSP && %columnName%DataSourceSP !== "") {
                        load%columnName%DataSource();
                    }
                }
            },
            itemTemplate: function(data, index) {
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
                const searchValue = Instance%ColumnName%.option("searchValue") || "";

                $("<div>")
                    .addClass("fw-semibold")
                    .css({
                        fontSize: "14px",
                        lineHeight: "1.4",
                        overflow: "hidden",
                        textOverflow: "ellipsis",
                        whiteSpace: "nowrap"
                    })
                    .html(highlightText%ColumnName%(data.Name || "", searchValue))
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
                $(e.component._popup.content()).parent()
                    .addClass("shadow-lg border rounded hpa-responsive")
                    .css({
                        borderRadius: "12px",
                        padding: "8px 0",
                        borderColor: "#dee2e6"
                    });
            },
            onFocusIn: function(e) {
                Instance%ColumnName%.option("showClearButton", true);
            },
            onFocusOut: function(e) {
                Instance%ColumnName%.option("showClearButton", false);
            },
            onKeyDown: function(e) {
                if (e.key === "Enter" || e.key === "Tab") {
                    Instance%ColumnName%.option("showClearButton", false);
                }
            },
			onValueChanged: function(e) {
                if (!e.event) return;

                $("#%UID%").find(".dx-texteditor-input").blur();
                if (Instance%ColumnName% && Instance%ColumnName%.blur) Instance%ColumnName%.blur();

                // Chỉ visual feedback, không save API
                const $el = $(e.element);
                $el.css({
                    transform: "scale(1.02)",
                    boxShadow: "0 0 0 3px rgba(28, 151, 94, 0.2)",
                    transition: "all 0.2s ease"
                });
                setTimeout(() => {
                    $el.css({
                        transform: "",
                        boxShadow: ""
                    });
                }, 300);

                // Gọi hàm callback onSelectBoxChanged nếu có
                if (typeof window["onSelectBoxChanged_%ColumnName%"] === "function") {
                    console.log("Calling onSelectBoxChanged_%ColumnName% callback");
                    window["onSelectBoxChanged_%ColumnName%"](e.value, Instance%ColumnName%, e);
                }

                // Sync grid cell nếu được gọi từ grid
                if (cellInfo && cellInfo.component) {
                    try {
                        const grid = cellInfo.component;
                        grid.cellValue(cellInfo.rowIndex, "%columnName%", e.value);
                        grid.repaint();
                    } catch (syncErr) {
                        console.warn("[Grid Sync] Không thể sync grid:", syncErr);
                    }
                }
			}
		}).dxSelectBox("instance");

        function load%columnName%DataSource() {
            if (!%columnName%DataSourceSP || %columnName%DataSourceSP === "") {
                console.warn("SelectBox %columnName%: No DataSourceSP");
                return;
            }

            if (%columnName%IsLoading || %columnName%IsDataLoaded) return;

            %columnName%IsLoading = true;
            Instance%ColumnName%.option("placeholder", "Đang tải dữ liệu...");

            const $input = $("#%UID%").find(".dx-texteditor-input");
            const gradientAnim = setInterval(() => {
                if (!%columnName%IsLoading) {
                    clearInterval(gradientAnim);
                    $input.css("background", "");
                    return;
                }
                $input.css({
                    backgroundSize: "200% 100%",
                    animation: "none"
                });
            }, 100);

            AjaxHPAParadise({
                data: {
                    name: %columnName%DataSourceSP,
                    param: ["LoginID", LoginID, "LanguageID", LanguageID]
                },
                success: function(res) {
                    const json = typeof res === "string" ? JSON.parse(res) : res;
                    const data = (json.data && json.data[0]) || [];

                    window["DataSource_%ColumnName%"] = data;
                    
                    // Smart Load: Check dữ liệu > 1000 dòng
                    if (data.length > 1000) {
                        console.log("[SmartLoad] SelectBox %ColumnName%: Dữ liệu " + data.length + " dòng - Kích hoạt API load");
                        window["UseAPILoad_%ColumnName%"] = true;
                        Instance%ColumnName%.option("placeholder", "Sử dụng tìm kiếm để load dữ liệu (API)");
                        // Không set dataSource toàn bộ, sẽ load qua API khi user search
                    } else {
                        // Load bình thường cho dữ liệu nhỏ
                        Instance%ColumnName%.option("dataSource", data);
                        Instance%ColumnName%.repaint();
                        Instance%ColumnName%.option("placeholder", "Tìm kiếm hoặc chọn...");
                    }

                    %columnName%IsLoading = false;
                    %columnName%IsDataLoaded = true;
                    clearInterval(gradientAnim);
                    $input.css("background", "");

                    console.log("SelectBox %columnName%: Loaded", data.length, "items");
                },
                error: function(err) {
                    %columnName%IsLoading = false;
                    clearInterval(gradientAnim);
                    $input.css("background", "");
                    Instance%ColumnName%.option("placeholder", "Lỗi tải dữ liệu");
                    console.error("SelectBox %columnName% error:", err);
                }
            });
        }

        if (%columnName%DataSourceSP && %columnName%DataSourceSP !== "") {
            load%columnName%DataSource();
        }
		'
	WHERE [Type] = 'hpaControlSelectBox' AND [AutoSave] = 0 AND [ReadOnly] = 0;
END
GO