USE Paradise_Beta_Tai2
GO
if object_id('[dbo].[sp_CRM_Customer_html]') is null
	EXEC ('CREATE PROCEDURE [dbo].[sp_CRM_Customer_html] as select 1')
GO

ALTER PROCEDURE [dbo].[sp_CRM_Customer_html]
	@LoginID INT = 3,
	@LanguageID VARCHAR(2) = 'VN'
AS
BEGIN
	SET NOCOUNT ON;
	DECLARE @html nvarchar(max)

	SET @html = N'
<style>
	#sp_CRM_Customer .crm-grid-container {
		display: grid;
		grid-template-columns: repeat(4, 1fr);
		gap: 20px;
		padding: 10px 20px;
	}

	#sp_CRM_Customer .CRM_info {
		display: flex;
		align-items: center;
		width: 100%;
	}

	#sp_CRM_Customer .result-count {
		text-align: center;
		padding: 12px;
		font-size: 14px;
		color: #666;
		border-radius: 8px;
		margin: 12px 16px;
	}

	#sp_CRM_Customer .modal-search {
		display: flex;
		padding: 8px 16px;
		align-items: center;
		gap: 10px;
		margin-top: 8px;
	}

	#sp_CRM_Customer .search-container {
		position: relative;
		display: flex;
		width: 90%;
		margin-left: 0px !important;
	}

	#sp_CRM_Customer .search-input {
		width: 100%;
		padding: 8px 16px 8px 45px;
		border: 1px solid #e0e0e0;
		border-radius: 32px !important;
		font-size: 14px;
		background-color: #f8f9fa;
		transition: all 0.3s ease;
		box-sizing: border-box;
	}

	#sp_CRM_Customer .search-input:focus {
		outline: none;
		border-color: #00994c;
		background-color: #fff;
		box-shadow: 0 0 0 3px rgba(0, 153, 76, 0.1);
	}

	#sp_CRM_Customer .search-input::placeholder {
		color: #999;
	}

	#sp_CRM_Customer .search-icon {
		position: absolute;
		left: 16px;
		top: 50%;
		transform: translateY(-50%);
		color: #666;
		font-size: 16px;
		pointer-events: none;
	}

	#sp_CRM_Customer .clear-btn {
		position: absolute;
		right: 12px;
		top: 50%;
		transform: translateY(-50%);
		background: none;
		border: none;
		color: #999;
		font-size: 20px;
		cursor: pointer;
		padding: 4px;
		border-radius: 50%;
		display: none;
		transition: all 0.2s ease;
	}

	#sp_CRM_Customer .clear-btn:hover {
		color: #333;
	}

	#sp_CRM_Customer .btn-add-new {
		display: flex;
		align-items: center;
		justify-content: center;
		width: 40px;
		height: 40px;
		min-width: 40px;
		border-radius: 50%;
		border: none;
		color: #00994c;
		font-size: 24px;
		cursor: pointer;
	}

	#sp_CRM_Customer .crm-card {
		background: #fff;
		border-radius: 12px;
		border: 1px solid #e0e0e0;
		box-shadow: 0 4px 6px rgba(0,0,0,0.02);
		transition: all 0.3s ease;
		display: flex;
		flex-direction: column;
		overflow: hidden;
	}

	#sp_CRM_Customer .crm-card:hover {
		transform: translateY(-5px);
		box-shadow: 0 10px 20px rgba(0,0,0,0.08);
		border-color: #b0b0b0;
	}

	#sp_CRM_Customer .crm-card-header {
		padding: 15px;
		border-bottom: 1px solid #f0f0f0;
		background: #fafafa;
		display: flex;
		justify-content: space-between;
		align-items: center;
	}

	#sp_CRM_Customer .crm-code {
		font-size: 12px;
		font-weight: 600;
		color: #666;
		background: #e0e0e0;
		padding: 2px 8px;
		border-radius: 4px;
	}

	#sp_CRM_Customer .crm-score-badge {
		font-weight: bold;
		color: #ff9800;
		display: flex;
		align-items: center;
		gap: 4px;
	}

	#sp_CRM_Customer .crm-card-body {
		padding: 15px;
		flex: 1;
	}

	#sp_CRM_Customer .crm-company-name {
		font-size: 18px;
		font-weight: 700;
		color: #2c3e50;
		margin-bottom: 12px;
		display: -webkit-box;
		-webkit-line-clamp: 2;
		-webkit-box-orient: vertical;
		overflow: hidden;
	}

	#sp_CRM_Customer .crm-info-row {
		display: flex;
		align-items: center;
		font-size: 14px;
		color: #555;
	}

	#sp_CRM_Customer .crm-icon {
		width: 20px;
		margin-right: 8px;
		color: #888;
		text-align: center;
	}

	#sp_CRM_Customer .crm-card-footer {
		padding: 12px 15px;
		border-top: 1px solid #f0f0f0;
		display: flex;
		justify-content: space-between;
		align-items: center;
	}

	#sp_CRM_Customer .crm-type-tag {
		padding: 4px 10px;
		border-radius: 12px;
		font-size: 12px;
		font-weight: 600;
		background: #e3f2fd;
		color: #1565c0;
	}

	#sp_CRM_Customer .btn-delete-card {
		color: #dc3545;
		cursor: pointer;
		font-size: 16px;
		transition: transform 0.2s, color 0.2s;
		padding: 4px;
	}

	#sp_CRM_Customer .btn-delete-card:hover {
		color: #bb2d3b;
		transform: scale(1.2);
	}

	#sp_CRM_Customer .crm-editable {
		cursor: pointer;
		transition: all 0.2s;
		border-radius: 4px;
		padding: 2px 4px;
		border: 1px dashed transparent;
	}

	#sp_CRM_Customer .crm-editable:empty {
		display: inline-block;
		align-items: center;
		height: 1.2em;
		vertical-align: bottom;
		height: 100%;
		margin-left: 4px;
	}

	#sp_CRM_Customer .crm-editable:empty::before {
		content: ''Không có dữ liệu'';
		color: #999;
		font-style: italic;
	}
	
	#sp_CRM_Customer .pagination-container {
		display: flex;
		justify-content: center;
		align-items: center;
		gap: 8px;
		margin: 20px 0;
		flex-wrap: wrap;
	}

	#sp_CRM_Customer .page-btn {
		padding: 6px 12px;
		border: 1px solid #e0e0e0;
		background-color: #fff;
		color: #333;
		border-radius: 50%;
		cursor: pointer;
		transition: all 0.2s;
		font-size: 14px;
	}

	#sp_CRM_Customer .page-btn:hover:not(:disabled) {
		background-color: #f0f0f0;
		border-color: #d0d0d0;
	}

	#sp_CRM_Customer .page-btn.active {
		background-color: #00994c;
		color: white;
		border-color: #00994c;
	}

	#sp_CRM_Customer .page-btn:disabled {
		background-color: #f9f9f9;
		color: #ccc;
		cursor: not-allowed;
	}

	#sp_CRM_Customer .sort-wrapper {
		display: flex;
		align-items: center;
		padding: 0 16px;
		border: 1px solid #e0e0e0;
		border-radius: 32px;
		background-color: #f8f9fa;
		transition: all 0.3s ease;
		min-width: 180px;
		position: relative;
	}

	#sp_CRM_Customer .sort-wrapper:hover,
	#sp_CRM_Customer .sort-wrapper:focus-within {
		border-color: #00994c;
		background-color: #fff;
		box-shadow: 0 0 0 3px rgba(0, 153, 76, 0.1);
	}

	#sp_CRM_Customer .sort-icon-deco {
		color: #666;
		font-size: 18px;
		margin-right: 8px;
		pointer-events: none;
	}

	#sp_CRM_Customer .sort-select {
		border: none;
		background: transparent;
		font-size: 14px;
		color: #333;
		width: 100%;
		outline: none;
		cursor: pointer;
		padding: 8px 0;
		appearance: none;
		-webkit-appearance: none;
		-moz-appearance: none;
	}

	#sp_CRM_Customer .bi-chevron-down {
		display: none;
	}



	/* Tùy chỉnh cho giao diện mobile */
	@media screen and (max-width: 768px) {
		#sp_CRM_Customer .modal-search {
			flex-wrap: wrap;
			padding: 8px 10px;
		}

		#sp_CRM_Customer .search-container {
			width: 100% !important;
			order: 1;
			margin-bottom: 10px;
		}

		#sp_CRM_Customer .crm-grid-container {
			grid-template-columns: repeat(1, 1fr);
			padding: 10px;
			gap: 15px;
		}

		#sp_CRM_Customer .sort-wrapper {
			order: 2;
			flex: 1;
			min-width: auto;
		}

		#sp_CRM_Customer .btn-add-new {
			order: 3;
			margin-left: 10px;
		}

		#sp_CRM_Customer .page-btn {
			padding: 6px 10px;
		}
	}



	/* Tùy chỉnh cho giao diện mobile */
	@media screen and (min-width: 768px) and (max-width: 1023px) {
		#sp_CRM_Customer .crm-grid-container {
			grid-template-columns: repeat(2, 1fr); /* 2 cột */
			gap: 15px;
		}
		
		#sp_CRM_Customer .crm-company-name {
			font-size: 16px;
		}
	}



	/* Dark mode overrides */
	.dark-mode #sp_CRM_Customer .crm-card {
		background: #252b31;
		border-color: #3e444a;
		box-shadow: 0 4px 6px rgba(0,0,0,0.2);
	}

	.dark-mode #sp_CRM_Customer .crm-card:hover {
		border-color: #666;
		box-shadow: 0 10px 20px rgba(0,0,0,0.4);
	}

	.dark-mode #sp_CRM_Customer .crm-card-header {
		background: #2d3339;
		border-bottom-color: #3e444a;
	}

	.dark-mode #sp_CRM_Customer .crm-card-footer {
		border-top-color: #3e444a;
		background: transparent;
	}

	.dark-mode #sp_CRM_Customer .crm-company-name {
		color: #e0e0e0;
	}

	.dark-mode #sp_CRM_Customer .crm-info-row {
		color: #b0b0b0;
	}

	.dark-mode #sp_CRM_Customer .crm-editable {
		color: #f0f0f0;
	}

	.dark-mode #sp_CRM_Customer .CRM_info b {
		color: #6c757d;
	}

	.dark-mode #sp_CRM_Customer .crm-icon {
		color: #a0a0a0;
	}

	.dark-mode #sp_CRM_Customer .crm-code {
		background: #3e444a;
		color: #ccc;
	}

	.dark-mode #sp_CRM_Customer .crm-type-tag {
		background: #1a3b5c;
		color: #90caf9;
	}

	.dark-mode #sp_CRM_Customer .crm-editable:empty::before {
		color: #666;
	}

	.dark-mode #sp_CRM_Customer .search-input {
		background-color: #2d3339;
		border-color: #555;
		color: #fff;
	}

	.dark-mode #sp_CRM_Customer .btn-add-new {
		color: #2ea043;
	}
	
	.dark-mode #sp_CRM_Customer .page-btn {
		background-color: #2d3339;
		border-color: #3e444a;
		color: #e0e0e0;
	}
	
	.dark-mode #sp_CRM_Customer .page-btn:hover:not(:disabled) {
		background-color: #3e444a;
	}
	
	.dark-mode #sp_CRM_Customer .page-btn.active {
		background-color: #2ea043;
		border-color: #2ea043;
	}

	.dark-mode #sp_CRM_Customer .sort-wrapper {
		background-color: #2d3339;
		border-color: #555;
	}
	
	.dark-mode #sp_CRM_Customer .sort-icon-deco {
		color: #aaa;
	}

	.dark-mode #sp_CRM_Customer .sort-select {
		color: #fff;
	}
	
	.dark-mode #sp_CRM_Customer .sort-select option {
		background-color: #404040;
		color: #fff;
	}
</style>
<div class="sp_CRM_Customer">
	<div class="modal-search">
		<div class="search-container">
			<input
			type="text"
				class="search-input"
				id="searchInput_AttendanceLocationAssignment"
				placeholder="Nhập từ khóa để tìm kiếm...">
			<i class="bi bi-search search-icon"></i>
			<button class="clear-btn" id="clearBtn_AttendanceLocationAssignment">
				<i class="bi bi-x"></i>
			</button>
		</div>
		<div class="sort-wrapper" title="Sắp xếp danh sách">
			<i class="bi bi-filter-left sort-icon-deco"></i>
			<select id="crm_sort_select" class="sort-select" onchange="CRM_Customer_Sort()">
				<option value="id_desc">Mới nhất</option>
				<option value="id_asc">Cũ nhất</option>
				<option value="date_desc">Ngày liên hệ (Gần nhất)</option>
				<option value="date_asc">Ngày liên hệ (Xa nhất)</option>
				<option value="score_desc">Điểm số (Cao &rarr; Thấp)</option>
				<option value="score_asc">Điểm số (Thấp &rarr; Cao)</option>
			</select>
		</div>
		<button class="btn-add-new" onclick="CRM_Customer_CreateNewCard()" title="Thêm mới">
			<i class="bi bi-plus"></i>
		</button>
	</div>
	<div id="crm_card_list" class="crm-grid-container">
	</div>
	<div id="pagination_controls" class="pagination-container">
	</div>
	<div class="result-count" id="result-count-bottom">Hiển thị 0 kết quả</div>
</div>
<script>
	//CÁC HÀM KHỞI TẠO
		//Khai báo biến
			var CRM_Data = [];
			var currentDatas = [];
			var currentPages = 1;
			var itemsPerPages = 8;


		//DarkMode
			function initDarkMode_CRM_Customer() {
				const savedDarkMode = localStorage.getItem(''darkMode_CRM_Customer'');
				if (savedDarkMode === ''true'') {
					document.body.classList.add(''dark-mode'');
				}
			}


		//Hàm khởi tạo
			function init_sp_CRM_Customer() {
				initDarkMode_CRM_Customer();
				CRM_Customer_LoadData();
				initSearchEvents_CRM_Customer();
			}
			init_sp_CRM_Customer()





	//CÁC HÀM TẢI DỮ LIỆU
		//Tải dữ liệu chính
			function CRM_Customer_LoadData() {
				AjaxHPAParadise({
					data: {
						name: "sp_CRM_Customer_Loaddata",
						param: []
					},
					success: function(result) {
						CRM_Data = JSON.parse(result).data[0];
						currentDatas = CRM_Data;
						currentPages = 1;
						CRM_Customer_Sort();
					}
				})
			}





	//RENDER dữ liệu
		//Render thẻ chính và logic phân trang
			function CRM_Customer_Render() {
				var container = document.getElementById(''crm_card_list'');
				var paginationContainer = document.getElementById(''pagination_controls'');
				var resultCount = document.getElementById(''result-count-bottom'');
				
				//Kiểm tra dữ liệu
				if (!currentDatas || currentDatas.length === 0) {
					container.innerHTML = ''<div style="text-align:center; width:100%; color:#888; grid-column: 1/-1;">Không có dữ liệu</div>'';
					paginationContainer.innerHTML = '''';
					resultCount.textContent = ''Hiển thị 0 kết quả'';
					return;
				}

				// Tính toán slice cho phân trang
				var startIndex = (currentPages - 1) * itemsPerPages;
				var endIndex = startIndex + itemsPerPages;
				var dataToRender = currentDatas.slice(startIndex, endIndex);
				var html = '''';
				
				//Duyệt mảng data đã slice để tạo HTML
				dataToRender.forEach(function(item) {
					var typeClass = ''crm-type-tag'';
					html += `
						<div class="crm-card" onclick="CRM_Customer_OpenDetail(${item.CRM_ID})">
							<div class="crm-card-header">
								<span class="crm-code">Mã CRM: ${item.CRM_ID || ''###''}</span>
								<div class="crm-score-badge">
									<span>★</span>
									<span>${item.CustomerScore || 0}/100</span>
								</div>
							</div>
							<div class="crm-card-body">
								<div class="crm-info-row">
									<span class="crm-icon"><i class="bi bi-building"></i></span>
									<span class="CRM_info"><b>Công ty: </b><span id="company_${item.CRM_ID}" class="crm-editable">${item.Company || ''''}</span></span>
								</div>
								<div class="crm-info-row">
									<span class="crm-icon"><i class="bi bi-person-fill-gear"></i></span>
									<span class="CRM_info"><b>Phụ trách: </b><span id="fullname_${item.CRM_ID}" class="crm-editable">${item.FullName || ''''}</span></span>
								</div>
								<div class="crm-info-row">
									<span class="crm-icon"><i class="bi bi-person-vcard"></i></span>
									<span class="CRM_info"><b>Người liên hệ: </b><span id="contact_${item.CRM_ID}" class="crm-editable">${item.InchargePerson || ''''}</span></span>
								</div>
								<div class="crm-info-row">
									<span class="crm-icon"><i class="bi bi-envelope"></i></span>
									<span class="CRM_info"><b>Email: </b><span id="email_${item.CRM_ID}" class="crm-editable">${item.IP_Email || ''''}</span></span>
								</div>
								<div class="crm-info-row">
									<span class="crm-icon"><i class="bi bi-telephone"></i></span>
									<span class="CRM_info"><b>Điện thoại: </b><span id="phone_${item.CRM_ID}" class="crm-editable">${item.IP_Phone || ''''}</span></span>
								</div>
								<div class="crm-info-row">
									<span class="crm-icon"><i class="bi bi-calendar-check"></i></span>
									<span class="CRM_info"><b>Bắt đầu liên hệ: </b><span id="date_contact_${item.CRM_ID}" class="crm-editable">${formatDateSafe(item.FirstContactDate) || ''''}</span></span>
								</div>
							</div>
							<div class="crm-card-footer">
								<span class="${typeClass}">${item.CustomerSegment || ''Khách hàng tiềm năng''}</span>
								<i class="bi bi-trash3 btn-delete-card"
								   title="Xóa CRM"
								   onclick="event.stopPropagation(); CRM_Customer_DeleteRow(${item.CRM_ID})">
								</i>
							</div>
						</div>
					`;
				});
				container.innerHTML = html;
				resultCount.textContent = `Hiển thị ${dataToRender.length} / ${currentDatas.length} kết quả (Trang ${currentPages})`;
				renderPaginationControls(paginationContainer);
				dataToRender.forEach(function(item) {
					hpaControlDateBox(''#date_contact_'' + item.CRM_ID, {
						tableSN: "-12039912",
						columnName: "FirstContactDate",
						idColumnName: "CRM_ID",
						idValue: item.CRM_ID,
						language: "VN",
						onSave: function(newDate) {
							console.log("Đã cập nhật ngày:", newDate);
						}
					});
				});
			}


		//Hàm render nút phân trang
			function renderPaginationControls(container) {
				var totalPages = Math.ceil(currentDatas.length / itemsPerPages);
				if (totalPages <= 1) {
					container.innerHTML = '''';
					return;
				}
				var html = '''';
				html += `<button class="page-btn" onclick="CRM_Customer_ChangePage(${currentPages - 1})" ${currentPages === 1 ? ''disabled'' : ''''}>&laquo;</button>`;
				for (var i = 1; i <= totalPages; i++) {
					if (i === 1 || i === totalPages || (i >= currentPages - 1 && i <= currentPages + 1)) {
						html += `<button class="page-btn ${i === currentPages ? ''active'' : ''''}" onclick="CRM_Customer_ChangePage(${i})">${i}</button>`;
					} else if (i === currentPages - 2 || i === currentPages + 2) {
						html += `<span style="padding: 0 4px; color: #999;">...</span>`;
					}
				}
				html += `<button class="page-btn" onclick="CRM_Customer_ChangePage(${currentPages + 1})" ${currentPages === totalPages ? ''disabled'' : ''''}>&raquo;</button>`;
				container.innerHTML = html;
			}


				


	//TÌM KIẾM VÀ SẮP XẾP
		//Hàm khởi tạo sự kiện tìm kiếm
			function initSearchEvents_CRM_Customer() {
				var searchInput = document.getElementById(''searchInput_AttendanceLocationAssignment'');
				var clearBtn = document.getElementById(''clearBtn_AttendanceLocationAssignment'');
				searchInput.addEventListener(''input'', CRM_Customer_Search);
				clearBtn.addEventListener(''click'', function() {
					searchInput.value = '''';
					clearBtn.style.display = ''none'';
					
					// Reset lại data đầy đủ
					currentDatas = CRM_Data;
					currentPages = 1;
					CRM_Customer_Render();
				});
			}


		//Hàm tìm kiếm
			function CRM_Customer_Search() {
				var searchValue = document.getElementById(''searchInput_AttendanceLocationAssignment'').value;
				var clearBtn = document.getElementById(''clearBtn_AttendanceLocationAssignment'');
				if (searchValue) {
					clearBtn.style.display = ''block'';
				} else {
					clearBtn.style.display = ''none'';
				}
				if (!searchValue.trim()) {
					currentDatas = CRM_Data; // Không tìm thấy gì thì lấy data gốc
				} else {
					// Logic lọc dữ liệu
					var keywords = searchValue.split('';'').map(k => removeVietnameseTones(k.trim())).filter(k => k);
					currentDatas = CRM_Data.filter(function(item) {
						var searchText = removeVietnameseTones([
							item.Company || '''',
							item.FullName || '''',
							item.InchargePerson || '''',
							item.IP_Email || '''',
							item.IP_Phone || '''',
							item.FirstContactDate || '''',
							item.CustomerSegment || '''',
							item.CRM_ID || ''''
						].join('' ''));
						return keywords.some(function(keyword) {
							return searchText.includes(keyword);
						});
					});
				}
				currentPages = 1;
				CRM_Customer_Sort();
			}


		//Hàm sắp xếp
			function CRM_Customer_Sort() {
				var sortType = document.getElementById(''crm_sort_select'').value;
				currentDatas.sort(function(a, b) {
					switch(sortType) {
						case ''id_asc'':
							return (parseInt(a.CRM_ID) || 0) - (parseInt(b.CRM_ID) || 0);
						case ''id_desc'':
							return (parseInt(b.CRM_ID) || 0) - (parseInt(a.CRM_ID) || 0);
						case ''score_asc'':
							return (parseFloat(a.CustomerScore) || 0) - (parseFloat(b.CustomerScore) || 0);
						case ''score_desc'':
							return (parseFloat(b.CustomerScore) || 0) - (parseFloat(a.CustomerScore) || 0);
						case ''date_asc'':
							return parseDateVal(a.FirstContactDate) - parseDateVal(b.FirstContactDate);
						case ''date_desc'':
							return parseDateVal(b.FirstContactDate) - parseDateVal(a.FirstContactDate);
						default: return 0;
					}
				});
				currentPages = 1;
				CRM_Customer_Render();
			}


		//Hàm phụ trợ parse ngày tháng (Hỗ trợ ISO và dd/mm/yyyy)
			function parseDateVal(dateStr) {
				if (!dateStr) return -8640000000000000; // Giá trị rất nhỏ nếu null
				
				// Thử tạo Date chuẩn
				var d = new Date(dateStr);
				if (!isNaN(d.getTime())) return d.getTime();
				
				// Nếu định dạng VN: dd/mm/yyyy
				if (dateStr.includes(''/'')) {
					var parts = dateStr.split(''/'');
					if (parts.length === 3) {
						// Chuyển thành yyyy, mm-1, dd
						return new Date(parts[2], parts[1] - 1, parts[0]).getTime();
					}
				}
				return 0;
			}





	//CÁC CHỨC NĂNG KHÁC
		//Lấy mã CRM tiếp theo
			function CRM_Customer_GetNextCRMID() {
				var maxID = 0;
				if (CRM_Data && CRM_Data.length > 0) {
					CRM_Data.forEach(function(item) {
						var currentID = parseInt(item.CRM_ID) || 0;
						if (currentID > maxID) {
							maxID = currentID;
						}
					});
				}
				return maxID + 1;
			}


		//Hàm thêm mới dòng
			function CRM_Customer_CreateNewCard() {
				var crmID = CRM_Customer_GetNextCRMID();
				var newItem = {
					CRM_ID: crmID,
					Company: '''',
					FullName: '''',
					InchargePerson: '''',
					IP_Email: '''',
					IP_Phone: '''',
					FirstContactDate: '''',
					CustomerScore: 0,
					CustomerSegment: ''Khách hàng tiềm năng''
				};
				CRM_Data.unshift(newItem);
				// Reset search và về trang 1 để thấy item mới
				document.getElementById(''searchInput_AttendanceLocationAssignment'').value = '''';
				document.getElementById(''clearBtn_AttendanceLocationAssignment'').style.display = ''none'';
				currentDatas = CRM_Data;
				currentPages = 1;
				CRM_Customer_Render();
			}


		//Hàm xóa thẻ
			function CRM_Customer_DeleteRow(id) {
				showConfirmPopup({
					title: "Xóa dữ liệu",
					message: "Bạn có chắn chắn muốn xóa dữ liệu CRM này?",
					icon: "bi bi-question-circle",
					YesText: "Xác nhận",
					NoText: "Từ chối",
					onYes: function() {
						AjaxHPAParadise({
							data: {
								name: "sp_CRM_Customer_DeleteRow",
								param: ["CRM_ID", id]
							},
							success: function(result) {
								CRM_Data = CRM_Data.filter(x => x.CRM_ID != id);
								currentDatas = currentDatas.filter(x => x.CRM_ID != id);
								var totalPages = Math.ceil(currentDatas.length / itemsPerPages);
								if (currentPages > totalPages && totalPages > 0) {
									currentPages = totalPages;
								}
								CRM_Customer_Render();
							}
						});
					}
				})
			}


		//Hàm loại bỏ dấu tiếng việt
			function removeVietnameseTones(str) {
				if (!str) return '''';
				str = str.toLowerCase();
				str = str.replace(/à|á|ạ|ả|ã|â|ầ|ấ|ậ|ẩ|ẫ|ă|ằ|ắ|ặ|ẳ|ẵ/g, ''a'');
				str = str.replace(/è|é|ẹ|ẻ|ẽ|ê|ề|ế|ệ|ể|ễ/g, ''e'');
				str = str.replace(/ì|í|ị|ỉ|ĩ/g, ''i'');
				str = str.replace(/ò|ó|ọ|ỏ|õ|ô|ồ|ố|ộ|ổ|ỗ|ơ|ờ|ớ|ợ|ở|ỡ/g, ''o'');
				str = str.replace(/ù|ú|ụ|ủ|ũ|ư|ừ|ứ|ự|ử|ữ/g, ''u'');
				str = str.replace(/ỳ|ý|ỵ|ỷ|ỹ/g, ''y'');
				str = str.replace(/đ/g, ''d'');
				return str;
			}

	
		//Hàm định dạng ngày
			function formatDateSafe(input) {
				if (!input) return "";
				if (typeof input === "string") {
					if (input.trim() === "") return "";
					if (input.indexOf("/") > -1) return input;
					if (input.indexOf("-") > -1 && input.length >= 10) {
						return input.substring(0, 10).split("-").reverse().join("/");
					}
					return input;
				}
				if (input instanceof Date) {
					if (isNaN(input.getTime())) return "";
					const day = ("0" + input.getDate()).slice(-2);
					const month = ("0" + (input.getMonth() + 1)).slice(-2);
					const year = input.getFullYear();
					if (cfg.type === "datetime") {
						 const h = ("0" + input.getHours()).slice(-2);
						 const m = ("0" + input.getMinutes()).slice(-2);
						 return day + "/" + month + "/" + year + " " + h + ":" + m;
					}
					return day + "/" + month + "/" + year;
				}
				return "";
			};


		//Hàm đổi trang
			function CRM_Customer_ChangePage(page) {
				var totalPages = Math.ceil(currentDatas.length / itemsPerPages);
				if (page < 1 || page > totalPages) return;
				currentPages = page;
				CRM_Customer_Render(); // Render lại với trang mới
			}


		//Hàm mở trang chi tiết CRM
			function CRM_Customer_OpenDetail(CRM_ID) {
				//Xử lí các trường hợp không mở chi tiết
				if (event.target.closest(''.crm-editable'') ||
					event.target.closest(''b'') ||
					event.target.closest(''i'')) {
					return;
				}
				if ([''Android'', ''iOS''].includes(getMobileOperatingSystem())) {
					OpenFormParamMobile(`sp_CRM_CustomerDetail`, {CRM_ID: `${CRM_ID}`, LanguageID: `${LanguageID}`})
				} else {
					openFormParam(`sp_CRM_CustomerDetail`, {CRM_ID: `${CRM_ID}`, LanguageID: `${LanguageID}`})
				}
			}
</script>
	';
	SELECT @html as html
	--EXEC sp_GenerateHTMLScript 'sp_CRM_Customer_html'
END
GO