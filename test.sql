USE Paradise_Beta_Tai2
GO
if object_id('[dbo].[sp_MakeupHoursTest_html]') is null
	EXEC ('CREATE PROCEDURE [dbo].[sp_MakeupHoursTest_html] as select 1')
GO


ALTER PROCEDURE [dbo].[sp_MakeupHoursTest_html]

AS
BEGIN
	SET NOCOUNT ON;
	DECLARE @html nvarchar(max),
	@GroupButton nvarchar(max) = ''
	exec sp_getGroupButtonRequest @html = @GroupButton OUTPUT

	SET @html = N'
	<style>
        textarea#ghiChuNguoiDuyet2 {
            color: gray;
        }
		#sp_MakeupHoursTest .error-message-beta.text-danger {
			display: none !important;
		}
		#sp_MakeupHoursTest #P45F7F1E5554A45BEAA6C80B69630FD33 {
			background-color: transparent;
			border: var(--bs-border-width) solid var(--bs-border-color);
			border-radius: 10px;
		}

		#sp_MakeupHoursTest .dx-tab.dx-tab-selected .dx-tab-text,
		#sp_MakeupHoursTest .dx-tab.dx-tab-selected .dx-tab-text-span {
			color: #198754 !important;
			font-weight: 700;
		}

		#sp_MakeupHoursTest .dx-texteditor.dx-state-readonly {
			background-color: #e9ecef !important;
			height: 40px !important;
		}

		#sp_MakeupHoursTest .dx-texteditor.dx-editor-filled {
			background-color: transparent;
			border: var(--bs-border-width) solid var(--bs-border-color);
			border-radius: 12px;
			height: 40px !important;
		}

		#sp_MakeupHoursTest .dx-texteditor.dx-editor-outlined {
			background-color: transparent;
		}

		#sp_MakeupHoursTest .dx-texteditor.dx-editor-filled {
			background-color: transparent;
			border: var(--bs-border-width) solid var(--bs-border-color);
			border-radius: 12px;
		}

		#sp_MakeupHoursTest .container_sp_MakeupHours {
			max-width: 768px;
			margin-left: auto;
			margin-right: auto;
		}

        #sp_MakeupHoursTest .col-form-label {
            font-size: 0.9rem;
            color: gray;
        }

		#sp_MakeupHoursTest .col-sm-2 {
			width: 100% !important;
		}

		#sp_MakeupHoursTest .col-sm-6 {
			width: 100% !important;
		}

		#sp_MakeupHoursTest .card {
			overflow: auto;
        }

        #sp_MakeupHoursTest .form-label {
            font-size: 0.9rem;
            color: gray;
        }

        #sp_MakeupHoursTest .from_day2 {
            width: 100%;
            margin-bottom: 1rem;
        }

        #sp_MakeupHoursTest .to_day2 {
            width: 50%;
        }

		#sp_MakeupHoursTest .date-text {
			font-size: 0.9rem;
			color: gray;
			font-weight: 400;
		}

        #sp_MakeupHoursTest span#add-time {
			display: flex;
            justify-content: center;
            align-items: center;
            font-size: 1.6rem;
            border-color: var(--paradise-color-input-border);
            height: 40px;
            width: 40px;
            margin-left: 10px;
            border-radius: 10px;
        }

        #sp_MakeupHoursTest span.bi.bi-trash.remove-time {
            color: red;
            font-size: 1.5rem;
            margin-left: 10px;
            height: 40px;
            width: 40px;
            display: flex;
            align-items: center;
            justify-content: center;
            border-radius: 10px;
        }

		#sp_MakeupHoursTest .custom-tabs {
			display: flex;
			justify-content: center;
			border-bottom: 1.5px solid #e0e0e0;
			margin-bottom: 18px;
			width: 100%;
			margin-left: auto;
			margin-right: auto;
			height: 50px;
		}

		#sp_MakeupHoursTest .back-button {
			background: none;
            border: none;
            color: #00673b;
            font-size: 20px;
			margin-left: 12px;
            margin-right: 12px;
            padding: 5px;
            border-radius: 50%;
            transition: background-color 0.3s;
        }

		#sp_MakeupHoursTest .custom-tab-btn {
			background: none;
			border: none;
			outline: none;
			font-size: 14px;
			color: #7b8794;
			font-weight: 400;
			position: relative;
			transition: color 0.2s;
			margin-bottom: -2px;
			flex: 1 1 0;
			text-align: center;
			width: 50%;

		}

		#sp_MakeupHoursTest  .custom-tab-btn.active {
			color: #0b6b3a;
			font-weight: bold;
		}

		#sp_MakeupHoursTest  .custom-tab-btn.active::after {
			content: "";
			display: block;
			height: 3px;
			width: 90%;
			background: #0b6b3a;
			border-radius: 2px;
			position: absolute;
			left: 5%;
			bottom: -2px;
		}

		#sp_MakeupHoursTest .custom-tabs {
			position: relative;
			padding-left: 60px;
		}

		#sp_MakeupHoursTest .back-button {
			position: absolute;
			left: 12px;
			top: 50%;
			transform: translateY(-50%);
		}

		#sp_MakeupHoursTest #historyCardBody {
			min-height: 400px;
		}

		#sp_MakeupHoursTest .history-card {
		    display: flex !important;
            justify-content: space-between;
            padding: 16px 20px;
            transition: all 0.2s ease;
            border: var(--bs-border-width) solid var(--bs-border-color);
            flex-direction: row;
            align-items: center;
            overflow: visible !important; /* Tắt chế độ cuộn bên trong thẻ */
            flex-shrink: 0; /* Đảm bảo thẻ không bị co lại khi danh sách dài */
            width: 100%; /* Đảm bảo thẻ chiếm hết chiều ngang */
		}

		#sp_MakeupHoursTest .history-card:last-child {
			margin-bottom: 50px;
		}
		
		#sp_MakeupHoursTest .employee-info {
			width: 60%;
		}
		
		#sp_MakeupHoursTest .status-container {
			margin-left: auto;
		}

		#sp_MakeupHoursTest .status-pending {
		    background: #fff;
		    color: #007bff;
		    border: 1px solid #007bff;
		    padding: 8px 16px;
		    border-radius: 20px;
		    font-size: 13px;
		    font-weight: 500;
		    cursor: pointer;
		    transition: all 0.2s ease;
		}

		#sp_MakeupHoursTest .dx-texteditor.dx-state-readonly {
			background-color: #e9ecef !important;
			height: 40px !important;
		}
		
		#sp_MakeupHoursTest .status-approved {
		    background: #fff;
		    color: #28a745;
		    border: 1px solid #28a745;
		    padding: 8px 16px;
		    border-radius: 20px;
		    font-size: 13px;
		    font-weight: 500;
		}
		
		#sp_MakeupHoursTest .status-rejected {
		    background: #fff;
		    color: #dc3545;
		    border: 1px solid #dc3545;
		    padding: 8px 16px;
		    border-radius: 20px;
		    font-size: 13px;
		    font-weight: 500;
		}
		
		#sp_MakeupHoursTest .status-cancelled {
		    background: #fff;
		    color: #6c757d;
		    border: 1px solid #6c757d;
		    padding: 8px 16px;
		    border-radius: 20px;
		    font-size: 13px;
		    font-weight: 500;
		}
		
		#sp_MakeupHoursTest .status-unknown {
		    background: #fff;
		    color: #6c757d;
		    border: 1px solid #6c757d;
		    padding: 8px 16px;
		    border-radius: 20px;
		    font-size: 13px;
		    font-weight: 500;
		}
		
		@media (max-width: 768px) {
		    #sp_MakeupHoursTest .history-card {
		        flex-direction: column;
		        align-items: flex-start;
		        padding: 8px 0px;
		    }
		}
    </style>

<div id="sp_MakeupHoursTest">
	<div class="card container_sp_MakeupHours" style="border: 0px">
		<div class="custom-tabs" style="position: relative; display: flex; align-items: center; border-bottom: 1px solid #e0e0e0; margin-bottom: 18px;">
			<button class="back-button" onclick="backMenuFromStack()" style="border: none; background: transparent; font-size: 20px; color: #00673b; margin-right: 10px;">
				<i class="bi bi-arrow-left"></i>
			</button>
			<div id="tab-header" style="flex: 1;"></div>
		</div>
		<div class="Information" id="tab-0" style="display:block;">
			<div class="card-body">
				<div class="mb-3 row" id="fromtoday1">
					<div id="employeeDetailInfo" class="col-12 mb-3 mt-2">
					</div>
					<div class="from_day2 required">
						<label for="pickedDay" class="col-sm-2 col-form-label">
							<i class="bi bi-calendar3 me-1"></i>
							<label class="date-text">%Date%</label>
							(*)
						</label>
						<div id="P02B8C28FE62A4AAB99889B2EB3F13685">
						<div class="col-sm-4">
							<div class="validate_error_date0 active" style="color: red"></div>
						</div>
					</div>
					<div class="mb-2 time-entry d-flex required">
						<div class="to_day2" style="padding-right: calc(var(--bs-gutter-x) * 0.5)">
							<label for="pickedTime" class="col-sm-2 col-form-label">
								<i class="bi bi-door-open-fill me-1"></i>
								<label class="checkinout-text">%CheckinOut%</label>
								(*)
							</label>
							<div class="col-sm-6">
								<div class="d-flex">
									<div id="PE62CC3EDB59347F79CE538A442F781EC" style="width: 100%"></div>
								</div>
							</div>
						</div>
						<div class="to_day2 required" style="padding-left: calc(var(--bs-gutter-x) * 0.5)">
							<label for="pickedTime" class="col-sm-2 col-form-label">
								<i class="bi bi-calendar3 me-1"></i>
								<label class="time-text">%Time%</label>
								(*)
							</label>
							<div class="col-sm-6">
								<div class="d-flex">
									<div id="PBAA9E7B649CB48579B888623DC5F8605"></div>
									<span class="add-time bi bi-plus" id="add-time"></span>
								</div>
								<div class="validate_error_date1 active" style="color: red"></div>
							</div>
						</div>
						<div class="validate_error_date active required" style="color: red">
							<span class="validate-date-text"></span>
						</div>
					</div>
					<div id="extra-time-fields" class="col-sm-6 mt-3"></div>
				</div>
				<div class="mb-3 required" id="divLyDo1">
					<label for="lyDo2" class="form-label">
						<i class="bi bi-emoji-smile me-1"></i>
						<label class="reason-text">%Reason%</label>
						(*)
					</label>
					<div id="P45F7F1E5554A45BEAA6C80B69630FD33"></div>
				</div>
				<div class="mb-3">
					<label for="pickedDay" class="col-sm-2 col-form-label">
						<i class="bi bi-file-earmark me-1"></i>
						<label class="date-text">%Attachment%</label>
					</label>
					<div id="P8F40626F791B4E2AA8C742EBA80794D6"></div>
				</div>
				<div class="mb-3">
					<i class="fas fa-user-check"></i>
					<label class="section-title form-label">%Approval_Process%</label>
					<div class="timeline parent-timeline" id="container_approval_process">
					</div>	
                </div>
				<div class="mb-3 row mt-0">
					<div class="trangThai2">
						<label for="trangThai2" class="form-label">
							<i class="bi bi-airplane-fill me-1"></i>
							<label class="status-text">%Status%</label>
						</label>
						<input type="text" class="form-control" id="trangThai2" readonly placeholder="Nháp" />
					</div>
				</div>
				'+@GroupButton+N'
			</div>
		</div>
		</div>
		<div class="container px-2" id="tab-1" style="display: none;">
			 <div id="historyCardBody" class="pt-2 request-CardList "></div>
		</div>
		<div class="modal fade shadow" id="modalApproveAttendanceRequest" data-bs-backdrop="static" data-bs-keyboard="false" tabindex="-1" aria-labelledby="staticBackdropLabel" aria-hidden="true">
			<div class="modal-dialog modal-dialog-centered">
				<div class="modal-content">
					<div class="modal-body">
						<div class="mb-3">
							<label for="exampleFormControlTextarea1" class="form-label">%colNote%</label>
							<textarea class="form-control" id="ghiChuNguoiDuyet2" rows="3" style="height: 127px"></textarea>
						</div>
					</div>
					<div class="modal-footer">
						<button type="button" class="btn" id="btnApproveModalRemake">%Approved%</button>
						<button type="button" class="btn btn-secondary" onClick="HideModalRemake()"  data-bs-dismiss="modal">%btnClose%</button>
					</div>
				</div>
			</div>
		</div>
		<div class="modal fade shadow" id="modalRejectAttendanceRequest" data-bs-backdrop="static" data-bs-keyboard="false" tabindex="-1" aria-labelledby="staticBackdropLabel" aria-hidden="true">
			<div class="modal-dialog modal-dialog-centered">
				<div class="modal-content">
					<div class="modal-body">
						<div class="mb-3">
							<label for="exampleFormControlTextarea1" class="form-label">%colNote%</label>
							<textarea class="form-control" id="remake " rows="3" style="height: 127px"></textarea>
		 </div>
					</div>
					<div class="modal-footer">
						<button type="button" class="btn" id="btnRejectModalRemake">%Approved%</button>
						<button type="button" class="btn btn-secondary" onClick="HideModalRemake()"  data-bs-dismiss="modal">%btnClose%</button>
					</div>
				</div>
			</div>
		</div>
		<div class="modal fade shadow" id="modalCancelAttendanceRequest" data-bs-backdrop="static" data-bs-keyboard="false" tabindex="-1" aria-labelledby="staticBackdropLabel" aria-hidden="true">
			<div class="modal-dialog modal-dialog-centered">
				<div class="modal-content">
					<div class="modal-body">
						<div class="mb-3">
							<label for="exampleFormControlTextarea1" class="form-label">%colNote%</label>
							<textarea class="form-control" id="NoteCancel" rows="3" style="height: 127px"></textarea>
		                </div>
					</div>
					<div class="modal-footer">
						<button type="button" class="btn btn-danger" id="btnCancelModalRemake">%confirm%</button>
						<button type="button" class="btn btn-secondary" onClick="HideModalRemake()"  data-bs-dismiss="modal">%btnClose%</button>
					</div>
				</div>
			</div>
		</div>
	</div>
</div>

<script>
(() => {
	//CÁC HÀM KHỞI TẠO
		//Khai báo biến
			var NewIdentityID
			var IDTime = 1
			var IsViewMode = false;
			var TargetEmployeeID = "";
			let currentRecordID_ID = 1;
			let currentRecordID_IdentityID


		//Hàm tạo 1 hàng dữ liệu mới để sử dụng control
			function CreateNewData_sp_MakeupHours() {
				AjaxHPAParadise({
					data: {
						name: "sp_CreateNewRowData",
						param: ["LoginID", UserID]
					},
					success: function (result) {
						var data = JSON.parse(result).data[0];
						NewIdentityID = data[0].Column1 || data[0].NewIdentityID
						currentRecordID_IdentityID = NewIdentityID
						LoadData_sp_MakeupHours();
					}
				})
			}


		//Hàm xóa phần header mặc định của hệ thống
			function start_sp_MakeupHours() {
				$("#header_sp_MakeupHoursTest").addClass("d-none");
				$("#contentContainer_sp_MakeupHoursTest").css("height", "calc(100vh - 60px)");
			}


		//Khởi tạo tab
			$("#tab-header").dxTabs({
				dataSource: [
					{ text: ''%MnuHRS034%''},
					{ text: ''%HistoryRequest%''}
				],
				width: ''100%'',
				selectedIndex: 0,
				onItemClick: function(e) {
					$("#sp_MakeupHoursTest #tab-0").hide();
					$("#sp_MakeupHoursTest #tab-1").hide();
					$("#sp_MakeupHoursTest #tab-" + e.itemIndex).show();

					if (e.itemIndex === 1) {
						LoadAttendanceHistory();
					}
				}
			});


		//Hàm khởi tạo
			function init_sp_MakeupHours() {
				start_sp_MakeupHours();
				if (typeof sp_MakeupHoursTest_param !== ''undefined'' && sp_MakeupHoursTest_param && sp_MakeupHoursTest_param.IdentityID) {
					NewIdentityID = sp_MakeupHoursTest_param.IdentityID;
					if (typeof NewIdentityID === ''string'') {
						NewIdentityID = NewIdentityID.toUpperCase();
					}
					ViewDetail_sp_MakeupHours(NewIdentityID);
					checkApprovalPermission(NewIdentityID);
					checkCancelPermission(NewIdentityID);
				} else {
					CreateNewData_sp_MakeupHours();
					getTimelineqlbeta("", 5, "container_approval_process", "employeeDetailInfo");
				}
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
                        "Instance" + columnName.charAt(0).toUpperCase() + columnName.slice(1) + "P02B8C28FE62A4AAB99889B2EB3F13685",
                        "Instance" + columnName + "P02B8C28FE62A4AAB99889B2EB3F13685",
                        "instance" + columnName.charAt(0).toUpperCase() + columnName.slice(1) + "P02B8C28FE62A4AAB99889B2EB3F13685"
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


	//CÁC HÀM KHỞI TẠO CONTROL VÀ LOGIC LƯU
		//Hàm tạo control date và lưu
            ' + (select loadUI from tblCommonControlType_Signed where UID = 'P02B8C28FE62A4AAB99889B2EB3F13685')
			  + (select loadUI from tblCommonControlType_Signed where UID = 'PBAA9E7B649CB48579B888623DC5F8605')
			  + (select loadUI from tblCommonControlType_Signed where UID = 'P45F7F1E5554A45BEAA6C80B69630FD33')
			  + (select loadUI from tblCommonControlType_Signed where UID = 'PE62CC3EDB59347F79CE538A442F781EC')+ N'		


	//CÁC HÀM TẢI DỮ LIỆU
		//Hàm tải dữ liệu
			function LoadData_sp_MakeupHours() {
				AjaxHPAParadise({
					data: {
						name: "sp_LoadDataMakeupHours",
						param: ["IdentityID", NewIdentityID]
					},
					success: function (result) {
						var obj = JSON.parse(result).data[0][0];
						var datahistory = JSON.parse(result).data[1];
						TargetEmployeeID = obj.EmployeeID;
						let canEdit = (obj.Approve_Status == 0);
						currentRecordID_IdentityID = obj.IdentityID || currentRecordID_IdentityID;
						'
						+ (select loadData from tblCommonControlType_Signed where UID = 'P02B8C28FE62A4AAB99889B2EB3F13685')
						+ (select loadData from tblCommonControlType_Signed where UID = 'PBAA9E7B649CB48579B888623DC5F8605')
						+ (select loadData from tblCommonControlType_Signed where UID = 'P45F7F1E5554A45BEAA6C80B69630FD33')
						+ (select loadData from tblCommonControlType_Signed where UID = 'PE62CC3EDB59347F79CE538A442F781EC') + N'
						var statusText = "";
						switch (obj.Approve_Status) {
							case 0: statusText = "Nháp"; break;
							case 1: statusText = "Đang chờ duyệt"; break;
							case 2: statusText = "Đã duyệt"; break;
							case 3: statusText = "Từ chối"; break;
							case 4: statusText = "Hủy thành công"; break;
							case 5: statusText = "Xin đăng ký hủy"; break;
							default: statusText = ""; break;
						}
						$("#trangThai2").val(statusText);
						if (canEdit) {
							 $("#sp_MakeupHoursTest .btnRegister").show();
							 $("#add-time").css("pointer-events", "auto").css("opacity", "1");
							 InstanceAttDateP02B8C28FE62A4AAB99889B2EB3F13685.option("readOnly", !canEdit);
							 InstanceTimePBAA9E7B649CB48579B888623DC5F8605.option("readOnly", !canEdit);
							 InstanceTypeCheckInCheckOutPE62CC3EDB59347F79CE538A442F781EC.option("readOnly", !canEdit);
							 InstanceRemarkP45F7F1E5554A45BEAA6C80B69630FD33.option("readOnly", !canEdit);
						} else {
							 $("#sp_MakeupHoursTest .btnRegister").hide();
							 $("#add-time").hide()
							 InstanceAttDateP02B8C28FE62A4AAB99889B2EB3F13685.option("readOnly", !canEdit);
							 InstanceTimePBAA9E7B649CB48579B888623DC5F8605.option("readOnly", !canEdit);
							 InstanceTypeCheckInCheckOutPE62CC3EDB59347F79CE538A442F781EC.option("readOnly", !canEdit);
							 InstanceRemarkP45F7F1E5554A45BEAA6C80B69630FD33.option("readOnly", !canEdit);
						}
						var extraFields = document.getElementById("extra-time-fields");
						if (extraFields) extraFields.innerHTML = "";
						if (datahistory && datahistory.length > 0) {
							var firstItem = datahistory[0];
							var staticCheckIn = $("#PE62CC3EDB59347F79CE538A442F781EC").dxSelectBox("instance");
							staticCheckIn.option("value", firstItem.TypeCheckInCheckOut);
							staticCheckIn.option("readOnly", !canEdit);

							var staticTime = $("#PBAA9E7B649CB48579B888623DC5F8605").dxDateBox("instance");
							staticTime.option("value", firstItem.Time ? new Date("1970/01/01 " + firstItem.Time) : null);
							staticTime.option("readOnly", !canEdit);

							for (var i = 1; i < datahistory.length; i++) {
								renderLoadedDetailItem(datahistory[i], i, canEdit);
							}
						}
						var idTimeline = (obj.Approve_Status == 0) ? "" : NewIdentityID;
						getTimelineqlbeta(idTimeline, 5, ''container_approval_process'', ''employeeDetailInfo'');
					}
				})
			}


		//Tải dữ liệu tab lịch sử
			function LoadAttendanceHistory() {
				console.log(TargetEmployeeID)
				AjaxHPAParadise({
					data: {
						name: "sp_GetAttendanceHistoryTest",
						param: ["LanguageID", LanguageID,
								"LoginID", UserID,
								"EmployeeID", TargetEmployeeID]
					},
					success: function (result) {
						var data = JSON.parse(result).data;
						var list = data[0] || [];
						renderAttendanceHistory(list);
					}
				})
			}





	//CÁC HÀM RENDER GIAO DIỆN
		//Hàm render danh sách lịch sử ra giao diện
			function renderAttendanceHistory(list) {
				var $historyCardBody = $("#historyCardBody");
				$historyCardBody.empty();
				if (!list || list.length === 0) {
					$historyCardBody.append("<div class=''text-center mt-3''>%NoData%</div>");
					return;
				}

				list.forEach(item => {
					if (item.IsShow === 0) return;
					var shiftName = item.ShiftName || "%NoInformation%";
					var dateStr = item.AttDate;
					if(dateStr) {
						var d = new Date(dateStr);
						dateStr = d.getDate().toString().padStart(2, ''0'') + ''/'' + (d.getMonth() + 1).toString().padStart(2, ''0'') + ''/'' + d.getFullYear();
					}
					var statusHtml = viewStatus(item.Approve_Status, item.ApproveStatusDescription);
					var card = $("<div class=''card history-card'' style=''cursor:pointer;''></div>")
						.click(function() {
							ViewDetail_sp_MakeupHours(item.IdentityID);
						})
						.html(`
							<div class="employee-info">
								<div class="request-subtitle mt-2">
									<b>%Date%:</b> ${dateStr || ''Không có thông tin''}
								</div>
								<div class="request-subtitle">
									<b>%ShiftName%:</b> ${shiftName || ''Không có thông tin''}
								</div>
								<div class="request-subtitle">
									<b>%Note%:</b> ${item.Remark || ''Không có thông tin''}
								</div>
								<div class="request-subtitle">
									<b>%Time%:</b> ${item.ViewTime || ''Không có thông tin''}
								</div>
							</div>
							${statusHtml}
						`);
					$historyCardBody.append(card);
				});
			}


		//Render đơn lịch sử
			function renderLoadedDetailItem(obj, index, canEdit) {
				var extraTimeFields = document.getElementById(''extra-time-fields'');
				var newTimeField = document.createElement(''div'');
				newTimeField.className = ''mb-2 time-entry'';
				// Lấy ID của dòng chi tiết
				let currentRecordID_ID = obj.ID
				let currentRecordID_IdentityID = NewIdentityID; // ID của phiếu lớn
				var divSelectID = ''PE62CC3EDB59347F79CE538A442F781EC'' + currentRecordID_ID;
				var divTimeID = ''PBAA9E7B649CB48579B888623DC5F8605'' + currentRecordID_ID;
				
				newTimeField.innerHTML = `
				<div class="row" data-id="${currentRecordID_ID}">
					<div class="to_day2" style="padding-right: calc(var(--bs-gutter-x) * 0.5)">
						<label class="col-sm-2 col-form-label">
							<span class="bi bi-door-open-fill me-1"></span>${`%CheckinOut%`} (*)
						</label>
						<div class="col-sm-6">
							<div class="d-flex">
								<div id="${divSelectID}" style="width: 100%"></div>
							</div>
						</div>
					</div>
					<div class="to_day2" style="padding-left: calc(var(--bs-gutter-x) * 0.5)">
						<label class="col-sm-2 col-form-label">
							<span class="bi bi-calendar3 me-1"></span>${`%Time%`} (*)
						</label>
						<div class="col-sm-6 d-flex">
							<div id="${divTimeID}" class="extra-time" style="width: ${canEdit ? ''85%'' : ''100%''};"></div>
							${canEdit ? `<span class="bi bi-trash remove-time" style="cursor:pointer;"></span>` : ``}
						</div>
					</div>
				</div>
				`;
				extraTimeFields.appendChild(newTimeField);
				'+ (select loadUI from tblCommonControlType_Signed where UID = 'PBAA9E7B649CB48579B888623DC5F8605')
				+ (select loadUI from tblCommonControlType_Signed where UID = 'PE62CC3EDB59347F79CE538A442F781EC')
				+ (select loadData from tblCommonControlType_Signed where UID = 'PBAA9E7B649CB48579B888623DC5F8605')
				+ (select loadData from tblCommonControlType_Signed where UID = 'PE62CC3EDB59347F79CE538A442F781EC') + N'
				if (!canEdit) {
					InstanceTimePBAA9E7B649CB48579B888623DC5F8605.option("readOnly", !canEdit);
					InstanceTypeCheckInCheckOutPE62CC3EDB59347F79CE538A442F781EC.option("readOnly", !canEdit);
				}
				// --- 3. Xử lý nút Xóa ---
				if (canEdit) {
					newTimeField.querySelector(''.remove-time'').addEventListener(''click'', function () {
						showConfirmPopup({
							title: "%ConfirmDelete%",
							message: "%ConfirmDeleteMessage%", // Hoặc text cố định
							icon: "bi bi-question-circle",
							onYes: function() {
								DeteleDataDetail_sp_MakeupHours(currentRecordID_ID);
								newTimeField.remove();
							}
						});
					});
				}
			}


		//Hàm xem lịch sử đơn
			function ViewDetail_sp_MakeupHours(identityID) {
				IsViewMode = true;
				NewIdentityID = identityID;
				var tabsInstance = $("#tab-header").dxTabs("instance");
				if(tabsInstance) tabsInstance.option("selectedIndex", 0);
				$("#sp_MakeupHoursTest #tab-0").show();
				$("#sp_MakeupHoursTest #tab-1").hide();
				$("#sp_MakeupHoursTest .btnRegister").hide();
				LoadData_sp_MakeupHours();
				checkApprovalPermission(identityID);
				checkCancelPermission(identityID);
			}


		//Hàm tạo trạng thái đơn
			function viewStatus(status, text) {
				var className = ''status-unknown'';
				var statusText = text || ''Wait'';
				if (status == 1) className = ''status-pending'';
				else if (status == 2) className = ''status-approved'';
				else if (status == 3) className = ''status-rejected'';
				else if (status == 100) className = ''status-cancelled'';
				return `<div class="status-container">
							<span class="${className}">${statusText}</span>
						</div>`;
			}





	//CÁC HÀM CHỨC NĂNG	
		//Thêm hàng dữ liệu mới vào data detail
			function AddNewDataDetail_sp_MakeupHours(callback) {
				AjaxHPAParadise({
					data: {
						name: "sp_AddNewDataDetail",
						param: ["IdentityID", NewIdentityID.toUpperCase()]
					},
					success: function (result) {
						var data = JSON.parse(result).data[0][0];
						if (callback) callback(data.ID);

					}
				})
			}


		//Hàm xóa trạng thái vào ra và giờ
			function DeteleDataDetail_sp_MakeupHours(idToDelete) {
				AjaxHPAParadise({
					data: {
						name: "sp_DeleteDataDetail",
						param: ["IdentityID", NewIdentityID,
								"ID", idToDelete]
					},
					success: function (result) {}
				})
			}


		//Hàm thêm và xóa mục vào ra
			document.getElementById(''add-time'').addEventListener(''click'', function (e) {
			var btn = $(this);
			if (btn.prop(''disabled'')) {
				e.preventDefault();
				return;
			}
			var extraTimeFields = document.getElementById(''extra-time-fields'');
			var currentTimeFields = extraTimeFields.querySelectorAll(''.time-entry'');

			if (currentTimeFields.length < 20) {
				AddNewDataDetail_sp_MakeupHours(function(newIdItem) {
					let currentRecordID_IdentityID = NewIdentityID;
					let currentRecordID_ID = newIdItem;

					let selectInputID = "PE62CC3EDB59347F79CE538A442F781EC" + currentRecordID_ID;
					let timeInputID = "PBAA9E7B649CB48579B888623DC5F8605" + currentRecordID_ID;
					var newTimeField = document.createElement(''div'');
					newTimeField.className = ''mb-2 time-entry'';
					var index = currentTimeFields.length;

					newTimeField.innerHTML = `
					<div class="row" data-id="${newIdItem}">
						<div class="to_day2" style="padding-right: calc(var(--bs-gutter-x) * 0.5)">
							<label class="col-sm-2 col-form-label">
								<span class="bi bi-door-open-fill me-1"></span>${`%CheckinOut%`} (*)
							</label>
							<div class="col-sm-6">
								<div class="d-flex">
									<div id="${selectInputID}" style="width: 100%"></div>
								</div>
							</div>
						</div>
						<div class="to_day2" style="padding-left: calc(var(--bs-gutter-x) * 0.5)">
							<label for="${timeInputID}" class="col-sm-2 col-form-label">
								<span class="bi bi-calendar3 me-1"></span>${`%Time%`} (*)
							</label>
							<div class="col-sm-6 d-flex">
								<div id="${timeInputID}" class="extra-time" style="width:85%;"></div>
								<span class="bi bi-trash remove-time" style="cursor:pointer;"></span>
							</div>
						</div>
					</div>
					`;
					extraTimeFields.appendChild(newTimeField);
					'+ (select loadUI from tblCommonControlType_Signed where UID = 'PBAA9E7B649CB48579B888623DC5F8605')
					 + (select loadUI from tblCommonControlType_Signed where UID = 'PE62CC3EDB59347F79CE538A442F781EC')+ N'


					// --- SỰ KIỆN XÓA (CODE CŨ) ---
					newTimeField.querySelector(''.remove-time'').addEventListener(''click'', function () {
						DeteleDataDetail_sp_MakeupHours(newIdItem);
						newTimeField.remove();
					});
				});
			} else {
				MainToast.ShowToast(`%Max8Time%`, ''error'');
			}
		});




		

	//CÁC HÀM VALIDATION VÀ HELPER

			





	//CÁC HÀM XỬ LÍ ĐƠN
		//Nộp đơn
			function SubmitRequestMakeupHoursTest() {
				var employeeID = UserID;
				var approveStatus = 0;
				showConfirmPopup({
					title: "%ConfirmRegister%",
					message: "%ConfirmRegisterDeatail%?",
					icon: "bi bi-question-circle",
					onYes: function() {	
						AjaxHPAParadise({
							data: {
								name: "sp_SubmitMakeupHours",
								param: [
									"LoginID", UserID,
									"IdentityID", currentRecordID_IdentityID
								]
							},
							success: function (result) {
								uiManager.showAlert({ type: "success", message: "%RegistedSuccsess%" });
								getTimelineqlbeta(currentRecordID_IdentityID, 5, ''container_approval_process'', ''employeeDetailInfo'');
								$("#sp_MakeupHoursTest .btnRegister").hide();
								LoadData_sp_MakeupHours(currentRecordID_IdentityID)
								checkApprovalPermission(currentRecordID_IdentityID);
								checkCancelPermission(currentRecordID_IdentityID);
							}
						});
					}
				});
			}
		//Kích hoạt nút lưu khi nhấn
			$("#sp_MakeupHoursTest .btnRegister").on("click", function() {SubmitRequestMakeupHoursTest()});





	//CÁC HÀM PHÊ DUYỆT / TỪ CHỐI
		// Hàm xử lí ẩn hiện của từng modal
			function HideModalRemake() {
				$("#btnApproveModalRemake").removeClass("btn-success btn-danger");
				$("#btnRejectModalRemake").removeClass("btn-success btn-danger");
				$(''#modalApproveAttendanceRequest'').modal(''hide'');
				$(''#modalRejectAttendanceRequest'').modal(''hide'');
				$(''#modalCancelAttendanceRequest'').modal(''hide'');
				$("#approveRemakeForExpenses").val("")
			}


		// Hàm kiểm tra cấp duyệt để duyệt đơn hiện tại và hiển thị nút
			function checkApprovalPermission(identityID) {
				AjaxHPAParadise({
					data: {
						name: "sp_CheckApprovalPermission",
						param: [
							"IdentityID", identityID,
							"LoginID", UserID
						]
					},
					success: function(result) {
						try {
							var data = JSON.parse(result).data[0];
							if (data[0].Approve_Status === 1 && data[0].Approve_StatusRequest === 1) {
								$("#sp_MakeupHoursTest .btnApprove").removeClass("d-none");
								$("#sp_MakeupHoursTest .btnReject").removeClass("d-none");
								$("#sp_MakeupHoursTest .btnApprove").off("click").on("click",function(){
									$("#btnApproveModalRemake").attr("data-action", "approve");
									$("#btnApproveModalRemake").text("%IsApproval%");
									$("#btnApproveModalRemake").addClass("btn btn-success");
									$("#modalApproveAttendanceRequest").modal(''show'')		
								})
								$("#sp_MakeupHoursTest .btnReject").off("click").on("click",function(){
									$("#btnApproveModalRemake").attr("data-action", "reject");
									$("#btnApproveModalRemake").text("%Deny%");
									$("#btnApproveModalRemake").addClass("btn btn-danger");
									$("#modalApproveAttendanceRequest").modal(''show'')			
								})
							} else if (data[0].Approve_Status === 1 && data[0].Approve_StatusRequest === 5) {
								$("#sp_MakeupHoursTest .btnApprove").removeClass("d-none");
								$("#sp_MakeupHoursTest .btnReject").removeClass("d-none");
								$("#sp_MakeupHoursTest .btnApprove").off("click").on("click",function(){
									$("#btnRejectModalRemake").attr("data-action", "approve");
									$("#btnRejectModalRemake").text("%IsApproval%");
									$("#btnRejectModalRemake").addClass("btn btn-success");
									$("#modalRejectAttendanceRequest").modal(''show'')		
								})
								$("#sp_MakeupHoursTest .btnReject").off("click").on("click",function(){
									$("#btnRejectModalRemake").attr("data-action", "reject");
									$("#btnRejectModalRemake").text("%Deny%");
									$("#btnRejectModalRemake").addClass("btn btn-danger");
									$("#modalRejectAttendanceRequest").modal(''show'')		
								})
							} else {
								$("#sp_MakeupHoursTest .btnApprove").addClass("d-none");
								$("#sp_MakeupHoursTest .btnReject").addClass("d-none");
							}
						} catch (error) {
							$("#sp_MakeupHoursTest .btnApprove").addClass("d-none");
						}
					},
					error: function(error) {
						$("#sp_MakeupHoursTest .btnApprove").addClass("d-none");
						$("#sp_MakeupHoursTest .btnReject").addClass("d-none");
					}
				});
			}


		// Hàm xử lý phê duyệt đuyệt đơn
			function ApproveAttendanceRequest(identityID) {
				var Remark = document.getElementById("ghiChuNguoiDuyet2").value;
				var checkInOutType = InstanceTypeCheckInCheckOutPE62CC3EDB59347F79CE538A442F781EC ? InstanceTypeCheckInCheckOutPE62CC3EDB59347F79CE538A442F781EC.option("value") : 1;
				var timeVal = InstanceTimePBAA9E7B649CB48579B888623DC5F8605 ? InstanceTimePBAA9E7B649CB48579B888623DC5F8605.option("value") : null;
				var timeInOut = timeVal ? DevExpress.localization.formatDate(timeVal, "HH:mm") : "";
				var allTimeData = [
					{ inout: checkInOutType, time: timeInOut }
				];
				var jsonTime = JSON.stringify(allTimeData);
				AjaxHPAParadise({
					data: {
						name: "sp_ApproveAttendanceRequest",
						param: ["IdentityID", identityID,
							"LoginID", UserID,
							"Remark", Remark,
							"JsonTime", jsonTime]
					},
					success: function(result) {
						uiManager.showAlert({ type: "success", message: "%ApproveSuccess%" });
						LoadData_sp_MakeupHours();
						checkApprovalPermission(identityID);
						checkCancelPermission(identityID);
						HideModalRemake()
					},
					error: function(err) {
						uiManager.showAlert({ type: "error", message: "%ApproveFailed%" });
					}
				});
			}


		// Hàm xử lý từ chối duyệt đơn
			function RejectAttendanceRequest(identityID) {
				var Remark = document.getElementById("ghiChuNguoiDuyet2").value;
				AjaxHPAParadise({
					data: {
						name: "sp_RejectAttendanceRequest",
						param: ["IdentityID", identityID,
								"LoginID", UserID,
								"Reason", Remark]
					},
					success: function(result) {
						uiManager.showAlert({ type: "success", message: "%RejectSuccess%" });
						LoadData_sp_MakeupHours();
						checkApprovalPermission(identityID);
						checkCancelPermission(identityID);
						$("#sp_MakeupHoursTest .btnRegister").hide();
						HideModalRemake()
					},
					error: function(err) {
						uiManager.showAlert({ type: "error", message: "%CannotRejectRequest%" });
					}
				});
			}


		// Hàm xử lí nút phê duyệt cho đơn
			var btnApprove = document.getElementById(''btnApproveModalRemake'');
			if (btnApprove) {
				btnApprove.addEventListener(''click'', function() {
					HandleApproveAttendanceRequest();
				});
			}

			var btnReject = document.getElementById(''btnRejectModalRemake'');
			if (btnReject) {
				btnReject.addEventListener(''click'', function() {
					HandleRejectAttendanceRequest();
				});
			}

			var btnCancel = document.getElementById(''btnCancelModalRemake'');
			if (btnCancel) {
				btnCancel.addEventListener(''click'', function() {
					HandleCancelAttendanceRequest();
				});
			}
			function HandleApproveAttendanceRequest () {
				var dataaction = $("#btnApproveModalRemake").attr("data-action");
				if (dataaction === ''reject'') {
					RejectAttendanceRequest(NewIdentityID)
				} else {
					ApproveAttendanceRequest(NewIdentityID);
				}
			}

			function HandleRejectAttendanceRequest () {
				var dataaction = $("#btnRejectModalRemake").attr("data-action");
				if (dataaction === ''reject'') {
					RejectCancelAttendanceRequest(NewIdentityID)
				} else {
					ApproveCancelAttendanceRequest(NewIdentityID);
				}
			}


		// Hàm kiểm tra để hiển thị nút hủy đơn
			function checkCancelPermission(identityID) {
				AjaxHPAParadise({
					data: {
						name: "sp_CheckCancelPermission",
						param: [
							"IdentityID", identityID,
							"LoginID", UserID
						]
					},
					success: function(result) {		
						var data = JSON.parse(result).data[0];
						var lengthdata = data.length
						if (lengthdata >= 1) {
							$("#sp_MakeupHoursTest .btnDestroy").removeClass("d-none");
							$("#sp_MakeupHoursTest .btnDestroy").off("click").on("click",function(){
								$("#btnActionModalRemake").attr("data-action", "approve");
								$("#btnActionModalRemake").text("%IsApproval%");
								$("#btnActionModalRemake").addClass("btn btn-success");
								$("#modalCancelAttendanceRequest").modal(''show'')		
							})					
						} else {
							$("#sp_MakeupHoursTest .btnDestroy").addClass("d-none");
						}	
					},
					error: function(error) {
						$("#sp_MakeupHoursTest .btnDestroy").addClass("d-none");
					}
				});
			}
		
		
		// Hàm gửi yêu cầu hủy đơn
			function SentCancelAttendanceRequest(identityID) {
				var reason = document.getElementById("NoteCancel").value;
				AjaxHPAParadise({
					data: {
						name: "sp_SentCancelAttendanceRequest",
						param: ["IdentityID", identityID,
								"Reason", reason]
					},
					success: function(result) {
						uiManager.showAlert({ type: "success", message: "%SubmitCancelRequestSuccess%" });
						LoadData_sp_MakeupHours();
						$("#sp_MakeupHoursTest .btnRegister").hide();
						HideModalRemake();
					}
				})
			}


		// Hàm xử lí hủy đơn
			function HandleCancelAttendanceRequest () {
				var reason = document.getElementById("NoteCancel").value;
				if (!reason || reason.trim() === '''') {	
					uiManager.showAlert({ type: "error", message: "Vui lòng nhập lý do hủy đơn" });
					document.getElementById("NoteCancel").style.border = "1px solid red";
					document.getElementById("NoteCancel").focus();
					return;
				}
				document.getElementById("NoteCancel").style.border = "";
				SentCancelAttendanceRequest(NewIdentityID);
			}


		// Hàm phê duyệt hủy đơn
			function ApproveCancelAttendanceRequest(identityID) {
				var Remark = document.getElementById("ghiChuNguoiDuyet2").value;
				AjaxHPAParadise({
					data: {
						name: "sp_ApproveAttendanceRequest",
						param: ["IdentityID", identityID,
								"LoginID", UserID,
								"Remark", Remark]
					},
					success: function(result) {
						uiManager.showAlert({ type: "success", message: "%ApproveCancelRequest%" });
						LoadData_sp_MakeupHours();
						checkApprovalPermission(identityID);
						checkCancelPermission(identityID);
						$("#sp_MakeupHoursTest .btnRegister").hide();
						HideModalRemake()
					},
					error: function(err) {
						uiManager.showAlert({ type: "error", message: "%ErrorCancelRequest%" });
					}
				});
			}


		// Hàm từ chối phê duyệt hủy đơn
			function RejectCancelAttendanceRequest(identityID) {
				var Remark = document.getElementById("ghiChuNguoiDuyet2").value;
				AjaxHPAParadise({
					data: {
						name: "sp_RejectAttendanceRequest",
						param: ["IdentityID", identityID,
								"LoginID", UserID,
								"Reason", Remark]
					},
					success: function(result) {
						uiManager.showAlert({ type: "success", message: "%SuccessCancelRequest%" });
						LoadData_sp_MakeupHours();
						checkApprovalPermission(identityID);
						checkCancelPermission(identityID);
						$("#sp_MakeupHoursTest .btnRegister").hide();
						HideModalRemake()
					},
					error: function(err) {
						uiManager.showAlert({ type: "error", message: "%RejectCancelRequest%" });
					}
				});
			}
init_sp_MakeupHours();
})();
    </script>



    ';
	SELECT @html as html
	--exec sp_GenerateHTMLScript 'sp_MakeupHoursTest_html'
END
GO
exec sp_GenerateHTMLScript 'sp_MakeupHoursTest_html'