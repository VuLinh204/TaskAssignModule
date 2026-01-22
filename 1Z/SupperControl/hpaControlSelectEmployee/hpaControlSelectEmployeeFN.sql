// ==================== EMPLOYEE SELECTOR TEMPLATE (Compact Horizontal Layout) ====================
let %ColumnName%Instance = null;
let %ColumnName%SelectedIds = [];
let %ColumnName%SelectedIdsOriginal = [];

// Config: Số lượng avatar hiển thị (mặc định 3)
const %ColumnName%_MAX_VISIBLE_AVATARS = 3;

const %ColumnName%EmployeesData = [
    { EmployeeID: 1, FullName: "Nguyễn Văn An", Email: "nva@company.com", Position: "Developer", AvatarUrl: "https://i.pravatar.cc/150?img=11" },
    { EmployeeID: 2, FullName: "Trần Thị Bình", Email: "ttb@company.com", Position: "Designer", AvatarUrl: "" },
    { EmployeeID: 3, FullName: "Lê Văn Cường", Email: "lvc@company.com", Position: "Tester", AvatarUrl: "https://i.pravatar.cc/150?img=13" },
    { EmployeeID: 4, FullName: "Phạm Thị Dung", Email: "ptd@company.com", Position: "BA", AvatarUrl: "https://i.pravatar.cc/150?img=5" },
    { EmployeeID: 5, FullName: "Hoàng Văn Em", Email: "hve@company.com", Position: "PM", AvatarUrl: "" },
    { EmployeeID: 6, FullName: "Vũ Minh Quân", Email: "vmq@company.com", Position: "DevOps", AvatarUrl: "https://i.pravatar.cc/150?img=15" },
    { EmployeeID: 7, FullName: "Đỗ Thị Hoa", Email: "dth@company.com", Position: "QA", AvatarUrl: "" }
];

// ==================== HELPER FUNCTIONS ====================
function %ColumnName%_getInitials(name) {
    const words = name.trim().split(/\s+/);
    if (words.length >= 2) {
        return (words[0][0] + words[words.length - 1][0]).toUpperCase();
    }
    return name.substring(0, 2).toUpperCase();
}

function %ColumnName%_getColorForId(id) {
    const colors = [
        { bg: "#e3f2fd", text: "#1976d2" },
        { bg: "#f3e5f5", text: "#7b1fa2" },
        { bg: "#e8f5e9", text: "#388e3c" },
        { bg: "#fff3e0", text: "#f57c00" },
        { bg: "#fce4ec", text: "#c2185b" }
    ];
    return colors[id % colors.length];
}

// ==================== LOAD UI ====================
function loadUI%ColumnName%() {
    const $container = $("#%ColumnName%");
    const uniqueId = "%ColumnName%_" + Date.now();
    
    const $displayBox = $("<div>").attr("id", uniqueId + "_display");
    $container.append($displayBox);

    function renderDisplayBox() {
        $displayBox.empty();
        
        const $wrapper = $("<div>").css({
            border: "1px solid #dee2e6",
            borderRadius: "4px",
            padding: "8px 12px",
            backgroundColor: "#fff",
            cursor: "pointer",
            minHeight: "42px",
            display: "flex",
            alignItems: "center"
        });

        if (%ColumnName%SelectedIds.length === 0) {
            $wrapper.append(
                $("<span>").addClass("text-muted").html(
                    "<i class=\"bi bi-person-plus me-1\"></i>Chọn nhân viên..."
                )
            );
        } else {
            const $avatarGroup = $("<div>").css({
                display: "flex",
                alignItems: "center",
                position: "relative"
            });
            
            const displayIds = %ColumnName%SelectedIds.slice(0, %ColumnName%_MAX_VISIBLE_AVATARS);
            
            displayIds.forEach((id, index) => {
                const emp = %ColumnName%EmployeesData.find(e => e.EmployeeID === id);
                if (!emp) return;
                
                const $chip = $("<div>").css({
                    display: "inline-flex",
                    alignItems: "center",
                    justifyContent: "center",
                    width: "32px",
                    height: "32px",
                    borderRadius: "50%",
                    border: "2px solid #fff",
                    boxShadow: "0 2px 4px rgba(0,0,0,0.1)",
                    position: "relative",
                    marginLeft: index === 0 ? "0" : "-8px",
                    zIndex: %ColumnName%_MAX_VISIBLE_AVATARS - index,
                    transition: "transform 0.2s ease"
                }).attr("title", emp.FullName);
                
                // Hover effect
                $chip.hover(
                    function() { $(this).css("transform", "translateY(-2px) scale(1.05)"); },
                    function() { $(this).css("transform", "translateY(0) scale(1)"); }
                );
                
                if (emp.AvatarUrl && emp.AvatarUrl.trim() !== "") {
                    $chip.css({
                        background: "#f8f9fa",
                        overflow: "hidden"
                    }).append(
                        $("<img>").attr({
                            src: emp.AvatarUrl,
                            alt: emp.FullName
                        }).css({
                            width: "100%",
                            height: "100%",
                            objectFit: "cover"
                        })
                    );
                } else {
                    const initials = %ColumnName%_getInitials(emp.FullName);
                    const color = %ColumnName%_getColorForId(emp.EmployeeID);
                    $chip.css({
                        background: color.bg,
                        color: color.text,
                        fontWeight: "600",
                        fontSize: "12px"
                    }).text(initials);
                }
                
                $avatarGroup.append($chip);
            });
            
            if (%ColumnName%SelectedIds.length > %ColumnName%_MAX_VISIBLE_AVATARS) {
                const remaining = %ColumnName%SelectedIds.length - %ColumnName%_MAX_VISIBLE_AVATARS;
                const $remainingBadge = $("<div>").css({
                    display: "inline-flex",
                    alignItems: "center",
                    justifyContent: "center",
                    width: "32px",
                    height: "32px",
                    borderRadius: "50%",
                    border: "2px solid #fff",
                    background: "#6c757d",
                    color: "#fff",
                    fontWeight: "600",
                    fontSize: "12px",
                    boxShadow: "0 2px 4px rgba(0,0,0,0.1)",
                    marginLeft: "-8px",
                    zIndex: "0",
                    transition: "transform 0.2s ease"
                }).text(`+${remaining}`).attr("title", `Còn ${remaining} người nữa`);
                
                $remainingBadge.hover(
                    function() { $(this).css("transform", "translateY(-2px) scale(1.05)"); },
                    function() { $(this).css("transform", "translateY(0) scale(1)"); }
                );
                
                $avatarGroup.append($remainingBadge);
            }
            
            $wrapper.append($avatarGroup);
        }

        $displayBox.append($wrapper);
        
        $wrapper.off("click").on("click", function() {
            popup.show();
        });
    }

    const popup = $("<div>").attr("id", uniqueId + "_popup").appendTo($container).dxPopup({
        width: 700,
        height: 600,
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
                    text: "Xác nhận",
                    type: "success",
                    onClick: async function() {
                        await save%ColumnName%();
                        popup.hide();
                    }
                }
            }
        ],
        contentTemplate: function() {
            const $gridContainer = $("<div>").attr("id", uniqueId + "_grid");
            return $gridContainer;
        },
        onShown: function() {
            $(`#${uniqueId}_grid`).dxDataGrid({
                dataSource: %ColumnName%EmployeesData,
                keyExpr: "EmployeeID",
                selection: {
                    mode: "multiple",
                    showCheckBoxesMode: "always"
                },
                selectedRowKeys: %ColumnName%SelectedIds,
                columns: [
                    {
                        caption: "",
                        width: 70,
                        alignment: "center",
                        cellTemplate: function(container, options) {
                            const emp = options.data;
                            const $cell = $("<div>").addClass("d-flex justify-content-center");
                            
                            if (emp.AvatarUrl && emp.AvatarUrl.trim() !== "") {
                                $cell.append(
                                    $("<div>").addClass("d-flex align-items-center justify-content-center bg-light border").css({
                                        width: "40px",
                                        height: "40px",
                                        borderRadius: "50%",
                                        overflow: "hidden",
                                        boxShadow: "0 2px 4px rgba(0,0,0,0.1)"
                                    }).append(
                                        $("<img>").attr({
                                            src: emp.AvatarUrl,
                                            alt: emp.FullName
                                        }).css({
                                            width: "100%",
                                            height: "100%",
                                            objectFit: "cover"
                                        })
                                    )
                                );
                            } else {
                                const initials = %ColumnName%_getInitials(emp.FullName);
                                const color = %ColumnName%_getColorForId(emp.EmployeeID);
                                $cell.append(
                                    $("<div>").addClass("d-flex align-items-center justify-content-center border").css({
                                        width: "40px",
                                        height: "40px",
                                        borderRadius: "50%",
                                        background: color.bg,
                                        color: color.text,
                                        fontWeight: 600,
                                        fontSize: "14px",
                                        boxShadow: "0 2px 4px rgba(0,0,0,0.1)"
                                    }).text(initials)
                                );
                            }
                            
                            container.append($cell);
                        }
                    },
                    {
                        dataField: "FullName",
                        caption: "Họ tên",
                        cellTemplate: function(container, options) {
                            const emp = options.data;
                            container.append(
                                $("<div>").append(
                                    $("<div>").addClass("fw-semibold").text(emp.FullName),
                                    $("<div>").addClass("small text-muted").text(emp.Position)
                                )
                            );
                        }
                    },
                    {
                        dataField: "Email",
                        caption: "Email"
                    }
                ],
                showBorders: true,
                showRowLines: true,
                rowAlternationEnabled: true,
                hoverStateEnabled: true,
                searchPanel: {
                    visible: true,
                    placeholder: "Tìm kiếm nhân viên..."
                },
                paging: {
                    pageSize: 10
                },
                onSelectionChanged: function(e) {
                    %ColumnName%SelectedIds = e.selectedRowKeys;
                }
            });
        },
        onHidden: function() {
            renderDisplayBox();
        }
    }).dxPopup("instance");

    %ColumnName%Instance = {
        renderDisplay: renderDisplayBox,
        popup: popup
    };

    renderDisplayBox();
}

// ==================== SAVE ====================
async function save%ColumnName%() {
    if (JSON.stringify(%ColumnName%SelectedIds.sort()) === JSON.stringify(%ColumnName%SelectedIdsOriginal.sort())) {
        return;
    }

    try {
        const dataJSON = JSON.stringify([%TableID%, ["%ColumnName%"], [%ColumnName%SelectedIds.join(",")]]);
        const idValues = %IDValues%;
        
        console.log("Saving %ColumnName% with IDValues:", idValues);
        console.log("Saving %ColumnName% with dataJSON:", dataJSON);
        
        const json = await saveFunction(dataJSON, idValues);
        %ColumnName%SelectedIdsOriginal = [...%ColumnName%SelectedIds];
        
        uiManager.showAlert({
            type: "success",
            message: "Lưu thành công"
        });

        // Callback (optional)
        if (typeof window.on%ColumnName%Saved === "function") {
            window.on%ColumnName%Saved(%ColumnName%SelectedIds, json);
        }
    } catch (err) {
        console.error("Save error:", err);
        uiManager.showAlert({
            type: "error",
            message: "Có lỗi xảy ra khi lưu"
        });
    }
}