USE Paradise_Beta_Tai2
GO
if object_id('[dbo].[sp_BirthDay_Moblie_html]') is null
	EXEC ('CREATE PROCEDURE [dbo].[sp_BirthDay_Moblie_html] as select 1')
GO

ALTER PROCEDURE [dbo].[sp_BirthDay_Moblie_html]
	 @LoginID int = null,
	 @LanguageID varchar(2) = 'VN',
	 @EmployeeID Varchar(20) = null
AS
BEGIN
	SET NOCOUNT ON;
    DECLARE @html nvarchar(max);
	set @html=N'
<style>
	#sp_BirthDay_Moblie {
        font-family: "Segoe UI", -apple-system, BlinkMacSystemFont, avenir next, avenir, helvetica neue, helvetica, Cantarell, Ubuntu, roboto, noto, arial, sans-serif;
    }

	#sp_BirthDay_Moblie #overlay-vts {
		display: none !important;
	}

	.dark-mode #sp_BirthDay_Moblie #overlay-vts {
		display: none !important;
	}

    #sp_BirthDay_Moblie .container {
        padding: 0px 0px 80px 0px !important;
        background: linear-gradient(135deg, #FFECF5 0%, #E6FFFA 100%);
        position: relative;
        overflow: hidden;
        z-index: 1;
        min-height: 100vh;
        height: 100% !important;
        max-width: 100% !important;
    }

    #sp_BirthDay_Moblie .header,
    #sp_BirthDay_Moblie .birthday-section {
        position: relative;
        z-index: 2;
    }

    #sp_BirthDay_Moblie  .stars-container {
        position: absolute;
        top: 0;
        left: 0;
        width: 100%;
        height: 100%;
        z-index: 1000;
        pointer-events: none;
    }


    #sp_BirthDay_Moblie  .star {
        position: absolute;
        width: 3px;
        height: 3px;
        background: #FFD700;
        border-radius: 50%;
        opacity: 0;
        animation: firework-effect 1.5s ease-out infinite;
        box-shadow: 0 0 5px #FFD700, 0 0 10px #FFD700;
        z-index: 11;
    }

    @keyframes firework-effect {
        0% {
            transform: scale(0.5) translate(0, 0);
            opacity: 0;
        }
        50% {
            opacity: 1; /* Hiện rõ ở giữa */
        }
        100% {
            transform: scale(1) translate(calc(var(--x-end) * 50px), calc(var(--y-end) * 50px));
            opacity: 0; /* Mờ dần khi bay ra */
        }
    }


    #sp_BirthDay_Moblie .star-1 { top: 20%; left: 30%; --x-end: 1; --y-end: -1; animation-delay: 0s; }
    #sp_BirthDay_Moblie .star-2 { top: 20%; left: 30%; --x-end: -1; --y-end: -1; animation-delay: 0s; }
    #sp_BirthDay_Moblie .star-3 { top: 20%; left: 30%; --x-end: 1; --y-end: 1; animation-delay: 0s; }
    #sp_BirthDay_Moblie .star-4 { top: 20%; left: 30%; --x-end: -1; --y-end: 1; animation-delay: 0s; }
    #sp_BirthDay_Moblie .star-5 { top: 40%; left: 70%; --x-end: 1; --y-end: -1; animation-delay: 0.5s; }
    #sp_BirthDay_Moblie .star-6 { top: 40%; left: 70%; --x-end: -1; --y-end: -1; animation-delay: 0.5s; }
    #sp_BirthDay_Moblie .star-7 { top: 40%; left: 70%; --x-end: 1; --y-end: 1; animation-delay: 0.5s; }
    #sp_BirthDay_Moblie .star-8 { top: 40%; left: 70%; --x-end: -1; --y-end: 1; animation-delay: 0.5s; }
    #sp_BirthDay_Moblie .star-9 { top: 60%; left: 20%; --x-end: 1; --y-end: 0; animation-delay: 1s; }
    #sp_BirthDay_Moblie .star-10 { top: 60%; left: 20%; --x-end: -1; --y-end: 0; animation-delay: 1s; }
    #sp_BirthDay_Moblie .star-11 { top: 60%; left: 20%; --x-end: 0; --y-end: 1; animation-delay: 1s; }
    #sp_BirthDay_Moblie .star-12 { top: 60%; left: 20%; --x-end: 0; --y-end: -1; animation-delay: 1s; }

    #sp_BirthDay_Moblie .bubbles-container {
        position: absolute;
        top: 0;
        left: 0;
        width: 100%;
        height: 100%;
        z-index: 1001;
        pointer-events: none;
        overflow: hidden;
    }

    #sp_BirthDay_Moblie  .bubble {
        position: absolute;
        bottom: -50px;
        width: 40px;
        height: 40px;
        background-color: rgba(255, 192, 203, 0.4);
        border-radius: 50%;
        opacity: 0.6;
        animation: rise 10s infinite ease-in;
        z-index: 10;
    }

    #sp_BirthDay_Moblie .bubble:nth-child(2) { left: 10%; background-color: rgba(255, 255, 0, 1); /* Vàng */ animation-duration: 7s; animation-delay: 2s; }
    #sp_BirthDay_Moblie .bubble:nth-child(3) { left: 20%; background-color: rgba(173, 216, 230, 1); /* Xanh */ animation-duration: 11s; animation-delay: 1s; }
#sp_BirthDay_Moblie .bubble:nth-child(4) { left: 30%; background-color: rgba(255, 182, 193, 1); /* Hồng đậm */ animation-duration: 8s; animation-delay: 3s; }
    #sp_BirthDay_Moblie .bubble:nth-child(5) { left: 40%; background-color: rgba(255, 218, 185, 1); /* Cam */ animation-duration: 10s; animation-delay: 5s; }
    #sp_BirthDay_Moblie .bubble:nth-child(6) { left: 50%; background-color: rgba(255, 255, 0, 1); /* Cam */ animation-duration: 9s; animation-delay: 2s; }
    #sp_BirthDay_Moblie .bubble:nth-child(7) { left: 60%; background-color: rgba(173, 216, 230, 1); /* Cam */ animation-duration: 12s; animation-delay: 4s; }
    #sp_BirthDay_Moblie .bubble:nth-child(8) { left: 70%; background-color: rgba(255, 218, 185, 1); /* Cam */ animation-duration: 6s; animation-delay: 1s; }
    #sp_BirthDay_Moblie .bubble:nth-child(9) { left: 80%; background-color: rgba(255, 182, 193, 1); /* Cam */ animation-duration: 7s; animation-delay: 3s; }
    #sp_BirthDay_Moblie .bubble:nth-child(10) { left: 90%; background-color: rgba(255, 255, 0, 1); /* Cam */ animation-duration: 11s; animation-delay: 5s; }

    @keyframes rise {
        0% { transform: translateY(0) translateX(0); opacity: 0.6; }
        50% { transform: translateX(20px); }
        100% { transform: translateY(-100vh) translateX(-20px); opacity: 0; }
    }

    #sp_BirthDay_Moblie  .confetti-container {
        position: absolute;
        top: 0;
        left: 0;
        width: 100%;
        height: 100%;
        z-index: 1002;
        pointer-events: none;
        overflow: hidden;
    }

    #sp_BirthDay_Moblie  .confetti {
        width: 10px;
        height: 10px;
        background-color: #ffd700;
        position: absolute;
        top: -50px;
        opacity: 0;
        animation: confetti-fall 5s linear infinite
    }

    #sp_BirthDay_Moblie .confetti:nth-child(2) { background-color: #f44336; left: 10%; animation-delay: 0.5s; }
    #sp_BirthDay_Moblie .confetti:nth-child(3) { background-color: #2196f3; left: 20%; animation-delay: 4.5s; }
    #sp_BirthDay_Moblie .confetti:nth-child(4) { background-color: #4caf50; left: 30%; animation-delay: 2s; }
    #sp_BirthDay_Moblie .confetti:nth-child(5) { background-color: #ff9800; left: 40%; animation-delay: 3; }
    #sp_BirthDay_Moblie .confetti:nth-child(6) { background-color: #e91e63; left: 50%; animation-delay: 4s; }
    #sp_BirthDay_Moblie .confetti:nth-child(7) { background-color: #9c27b0; left: 60%; animation-delay: 1.5s; }
    #sp_BirthDay_Moblie .confetti:nth-child(8) { background-color: #00bcd4; left: 70%; animation-delay: 2.5s; }
    #sp_BirthDay_Moblie .confetti:nth-child(9) { background-color: #cddc39; left: 80%; animation-delay: 3; }
    #sp_BirthDay_Moblie .confetti:nth-child(10) { background-color: #ffeb3b; left: 90%; animation-delay: 1s; }

    @keyframes confetti-fall {
        0% { transform: translateY(0) rotate(0deg); opacity: 1; }
        100% { transform: translateY(100vh) rotate(720deg); opacity: 0; }
    }

	#sp_BirthDay_Moblie .header {
        display: grid;
        grid-template-columns: auto 1fr auto;
        align-items: center;
        position: relative;
        padding: 0 10px;
    }

    #sp_BirthDay_Moblie .header h5 {
        margin: 0;
        color: #D946EF;
        font-weight: bold;
        position: absolute;
        left: 50%;
        transform: translateX(-50%);
        width: 100%;
        text-align: center;
        pointer-events: none;
        font-size: 24px;
    }

    #sp_BirthDay_Moblie .header .btn-back {
        color: black;
        margin-right: 4px !important;
        font-size: 24px;
        color: #D946EF;
    }

    #sp_BirthDay_Moblie .header .back-btn {
        margin-right: 0px !important;
    }

    #sp_BirthDay_Moblie .birthday-section {
     margin: 8px 8px 24px 0px;
    }

    #sp_BirthDay_Moblie .section-title {
        font-size: 18px;
        font-weight: 600;
        margin-bottom: 12px;
        display: flex;
        align-items: center;
        gap: 8px;
        justify-content: center;
    }

    #sp_BirthDay_Moblie #todaySection .section-title {
        color: red;
    }

    #sp_BirthDay_Moblie #upcomingSection .section-title {
        color: #ff778f;
    }

    #sp_BirthDay_Moblie .section-title i {
        font-size: 24px;
    }

    #sp_BirthDay_Moblie .birthday-card {
        background: white;
        border-radius: 16px;
        padding: 16px;
        margin-bottom: 12px;
        box-shadow: 0 4px 12px rgba(0, 0, 0, 0.1);
        display: flex;
        align-items: center;
        gap: 16px;
        transition: transform 0.2s, box-shadow 0.2s;
    }

    #sp_BirthDay_Moblie .birthday-card:active {
        transform: scale(0.98);
    }

    #sp_BirthDay_Moblie .birthday-info {
        flex: 1;
        line-height: 1.5;
    }

    #sp_BirthDay_Moblie .birthday-name {
        font-size: 16px;
        font-weight: 600;
        color: #333;
        margin-bottom: 4px;
    }

    #sp_BirthDay_Moblie .birthday-date {
        font-size: 14px;
        color: #666;
        display: flex;
        align-items: center;
        gap: 4px;
    }

    #sp_BirthDay_Moblie .birthday-date span {
        display: flex;
        align-items: center;
    }

    #sp_BirthDay_Moblie .birthday-typecustomer {
        font-size: 14px;
        color: #666;
    }

    #sp_BirthDay_Moblie .birthday-type {
        display: inline-block;
        padding: 4px 12px;
        border-radius: 12px;
        font-size: 12px;
        font-weight: 500;
        margin-top: 4px;
    }

    #sp_BirthDay_Moblie .type-customer {
        background: #e3f2fd;
        color: #1976d2;
    }

    #sp_BirthDay_Moblie .type-employee {
        background: #f3e5f5;
        color: #7b1fa2;
    }

    #sp_BirthDay_Moblie .birthday-icon {
        font-size: 24px;
        color: #ffd700;
    }

    #sp_BirthDay_Moblie .empty-state {
        text-align: center;
        padding: 40px 20px;
        color: gray;
    }

    #sp_BirthDay_Moblie .empty-state i {
        font-size: 64px;
        opacity: 0.5;
        margin-bottom: 16px;
    }

    #sp_BirthDay_Moblie .empty-state p {
        font-size: 16px;
        opacity: 0.8;
    }

    #sp_BirthDay_Moblie .today-badge {
        background: linear-gradient(135deg, #ff6b6b, #ee5a6f);
        color: white;
        padding: 2px 8px;
        border-radius: 8px;
        font-size: 11px;
        font-weight: 600;
        margin-left: 8px;
        animation: pulse 2s infinite;
    }

    #sp_BirthDay_Moblie .days-badge {
        background: linear-gradient(135deg, #667eea, #764ba2);
        color: white;
        padding: 2px 8px;
        border-radius: 8px;
        font-size: 11px;
        font-weight: 600;
        margin-left: 8px;
    }

    @keyframes pulse {
        0%, 100% { opacity: 1; }
        50% { opacity: 0.7; }
    }

    #sp_BirthDay_Moblie .loading {
        text-align: center;
        padding: 40px;
        color: white;
    }

    #sp_BirthDay_Moblie .loading i {
        font-size: 48px;
        animation: spin 1s linear infinite;
    }

    @keyframes spin {
        0% { transform: rotate(0deg); }
        100% { transform: rotate(360deg); }
    }

    #sp_BirthDay_Moblie .img_background {
        border-radius: 50%;
        width: 25%;
        aspect-ratio: 1; /* Đảm bảo hình vuông hoàn hảo */
        background: linear-gradient(315deg, rgb(245, 167, 240) 3%, rgb(72 156 243) 38%, rgb(22 230 216) 90%, rgb(241 232 232) 98%);
        animation: gradient 3s ease infinite;
        background-size: 400% 400%;
        padding: 4px; /* Độ dày của viền gradient */
        display: flex;
align-items: center;
        justify-content: center;
        position: relative;
    }

    #sp_BirthDay_Moblie .img_background::after {
  content: "🎉";
        position: absolute;
        top: -4px;
        right: -4px;
        font-size: 20px;
        animation: tada 1.5s infinite;
    }

    #sp_BirthDay_Moblie .img_background img {
       width: 100%;
        height: 100%;
        object-fit: cover;
        border-radius: 50%;
    }

    #sp_BirthDay_Moblie #todayList .birthday-card {
        background: #FFECF5
    }

    #sp_BirthDay_Moblie #upcomingList .birthday-card {
        background: #E6FFFA
    }

    @keyframes tada {
		0% {transform: scale(1);}
		10%, 20% {transform: scale(0.9) rotate(-3deg);}
		30%, 50%, 70%, 90% {transform: scale(1.1) rotate(3deg);}
		40%, 60%, 80% {transform: scale(1.1) rotate(-3deg);}
		100% {transform: scale(1) rotate(0);}
	}

    #sp_BirthDay_Moblie .is-today-card::before {
        content: "🎈";
        position: absolute;
        font-size: 50px;
        right: 5px;
        top: -20px;
        opacity: 0.1;
        transform: rotate(-15deg);
    }

    .dark-mode #sp_BirthDay_Moblie .container {
            background: linear-gradient(135deg, #2b1055 0%, #7597de 100%);
    }

    .dark-mode #sp_BirthDay_Moblie #todayList .birthday-card {
        background-color: #5A2E53;
    }

    .dark-mode #sp_BirthDay_Moblie #upcomingList .birthday-card {
        background-color: #00876c;
    }

    .dark-mode #sp_BirthDay_Moblie .birthday-name {
        color: white;
    }

    .dark-mode #sp_BirthDay_Moblie #todayList .birthday-date,
    .dark-mode #sp_BirthDay_Moblie #todayList .birthday-typecustomer {
        color: #bdbdbd;
    }

    .dark-mode #sp_BirthDay_Moblie #upcomingList .birthday-date,
    .dark-mode #sp_BirthDay_Moblie #upcomingList .birthday-typecustomer {
        color: #bdbdbd;
    }

     @media screen and (min-width: 1024px) {
        #sp_BirthDay_Moblie .header {
            display: none;
        }

        #sp_BirthDay_Moblie #todaySection .section-title,
        #sp_BirthDay_Moblie #upcomingSection .section-title {
            font-size: 32px;
        }

        #sp_BirthDay_Moblie #todayList,
        #sp_BirthDay_Moblie #upcomingList {
            display: grid;
            grid-template-columns: repeat(3, 1fr);
            grid-template-rows: auto;
            gap: 20px;
            margin: 20px;
        }

        #sp_BirthDay_Moblie #todayList .empty-state,
        #sp_BirthDay_Moblie #upcomingList .empty-state {
            grid-column: 2 / 3; /* Nằm ở cột giữa (cột 2) */
        }

        #sp_BirthDay_Moblie .img_background {
            width: 25%;
        }

        #sp_BirthDay_Moblie .birthday-name,
        #sp_BirthDay_Moblie .birthday-date,
        #sp_BirthDay_Moblie .birthday-typecustomer {
            font-size: 18px;
        }
     }
     #sp_BirthDay_Moblie .list-birthday {
        margin: 8px;
    }

    #sp_BirthDay_Moblie .birthday-month-section {
        margin-bottom: 16px;
        background: white;
        border-radius: 12px;
        box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
        overflow: hidden;
    }

    #sp_BirthDay_Moblie .month-header {
        display: flex;
        justify-content: space-between;
        align-items: center;
        padding: 12px 16px;
        cursor: pointer;
        transition: all 0.3s ease;
    }

    #sp_BirthDay_Moblie .month-header:active {
        transform: scale(0.98);
    }

    #sp_BirthDay_Moblie .month-title {
        font-size: 16px;
        font-weight: 600;
        color: #D946EF;
        margin: 0;
        display: flex;
        align-items: center;
        gap: 8px;
    }

    #sp_BirthDay_Moblie .month-count {
        font-size: 14px;
        color: #666;
        margin-left: 8px;
    }

    #sp_BirthDay_Moblie .month-content {
        display: none;
        padding: 0 12px 12px 12px;
    }

    #sp_BirthDay_Moblie .month-content.show {
        display: block;
    }

    #sp_BirthDay_Moblie .month-member-list {
        display: flex;
        gap: 15px;
        overflow-x: auto;
        padding-bottom: 10px;
    }

    #sp_BirthDay_Moblie .month-member-list::-webkit-scrollbar {
        height: 6px;
    }

    #sp_BirthDay_Moblie .month-member-list::-webkit-scrollbar-thumb {
        background: #D946EF;
        border-radius: 3px;
    }

    #sp_BirthDay_Moblie .month-member-item {
        text-align: center;
        min-width: 80px;
        flex-shrink: 0;
    }

    #sp_BirthDay_Moblie .month-member-avatar {
        width: 60px;
        height: 60px;
        border-radius: 50%;
        margin: 0 auto 8px;
        background: linear-gradient(315deg, rgb(245, 167, 240) 3%, rgb(72 156 243) 38%, rgb(22 230 216) 90%, rgb(241 232 232) 98%);
        animation: gradient 3s ease infinite;
        background-size: 400% 400%;
        padding: 3px;
        display: flex;
        align-items: center;
        justify-content: center;
    }

    #sp_BirthDay_Moblie .month-member-avatar img {
        width: 100%;
        height: 100%;
        border-radius: 50%;
        object-fit: cover;
    }

    #sp_BirthDay_Moblie .month-member-name {
        font-size: 12px;
        font-weight: 500;
        color: #333;
        margin-bottom: 4px;
        word-wrap: break-word;
    }

    #sp_BirthDay_Moblie .month-member-date {
        font-size: 11px;
        color: #666;
    }

.dark-mode #sp_BirthDay_Moblie .month-header,
.dark-mode #sp_BirthDay_Moblie .month-content {
    background: #2a3242;
}

.dark-mode #sp_BirthDay_Moblie .month-member-name {
    color: white;
}

.dark-mode #sp_BirthDay_Moblie .month-member-date {
    color: #bdbdbd;
}
</style>
<div id="sp_BirthDay_Moblie">
	<div class="container">
        <div class="stars-container">
            <div class="star star-1"></div>
            <div class="star star-2"></div>
            <div class="star star-3"></div>
            <div class="star star-4"></div>
            <div class="star star-5"></div>
            <div class="star star-6"></div>
            <div class="star star-7"></div>
            <div class="star star-8"></div>
            <div class="star star-9"></div>
            <div class="star star-10"></div>
            <div class="star star-11"></div>
            <div class="star star-12"></div>
        </div>
        <div class="bubbles-container">
            <div class="bubble"></div>
            <div class="bubble"></div>
            <div class="bubble"></div>
            <div class="bubble"></div>
            <div class="bubble"></div>
            <div class="bubble"></div>
            <div class="bubble"></div>
            <div class="bubble"></div>
            <div class="bubble"></div>
            <div class="bubble"></div>
        </div>
        <div class="confetti-container">
            <div class="confetti"></div>
            <div class="confetti"></div>
            <div class="confetti"></div>
            <div class="confetti"></div>
            <div class="confetti"></div>
            <div class="confetti"></div>
            <div class="confetti"></div>
     <div class="confetti"></div>
            <div class="confetti"></div>
            <div class="confetti"></div>
        </div>
		<div class="header">
			<button class="back-btn" id="backFromDashBoard" onclick="backMenuFromStack()">
				<i class="btn-back bi bi-arrow-left"></i>
			</button>
			<h5><i class="bi bi-balloon" style="font-size: 20px; margin-right: 8px;"></i>Danh sách sinh nhật</h5>
		</div>
        <div class="birthday-section" id="todaySection">
            <div class="section-title">
                <i class="bi bi-gift-fill"></i>
           <span>Sinh nhật hôm nay</span>
            </div>
            <div id="todayList">

            </div>
        </div>
        <div class="birthday-section" id="upcomingSection">
            <div class="section-title">
    <i class="bi bi-box2-heart"></i>
              <span>Sinh nhật sắp tới</span>
            </div>
            <div id="upcomingList"></div>
        </div>
        <div class="list-birthday">
            <div class="birthday-month-section" data-month="1">
                <div class="month-header" onclick="toggleMonth(1)">
                    <div>
                        <h5 class="month-title">
                            <i class="bi bi-calendar-month"></i>
                            Tháng 1
                            <span class="month-count">(0)</span>
                        </h5>
                    </div>
                </div>
                <div class="month-content show" id="monthContent1">
                    <div class="month-member-list" id="monthList1"></div>
                </div>
            </div>

            <div class="birthday-month-section" data-month="2">
                <div class="month-header" onclick="toggleMonth(2)">
                    <div>
                        <h5 class="month-title">
                            <i class="bi bi-calendar-month"></i>
                            Tháng 2
                            <span class="month-count">(0)</span>
                        </h5>
                    </div>

                </div>
                <div class="month-content show" id="monthContent2">
                    <div class="month-member-list" id="monthList2"></div>
                </div>
            </div>

            <div class="birthday-month-section" data-month="3">
                <div class="month-header" onclick="toggleMonth(3)">
                    <div>
                        <h5 class="month-title">
                            <i class="bi bi-calendar-month"></i>
                            Tháng 3
                            <span class="month-count">(0)</span>
                        </h5>
                    </div>

                </div>
                <div class="month-content show" id="monthContent3">
                    <div class="month-member-list" id="monthList3"></div>
                </div>
            </div>

            <div class="birthday-month-section" data-month="4">
                <div class="month-header" onclick="toggleMonth(4)">
                    <div>
                        <h5 class="month-title">
                            <i class="bi bi-calendar-month"></i>
                            Tháng 4
                            <span class="month-count">(0)</span>
                        </h5>
                    </div>

                </div>
                <div class="month-content show" id="monthContent4">
                    <div class="month-member-list" id="monthList4"></div>
                </div>
            </div>

            <div class="birthday-month-section" data-month="5">
                <div class="month-header" onclick="toggleMonth(5)">
                    <div>
                        <h5 class="month-title">
                            <i class="bi bi-calendar-month"></i>
                            Tháng 5
                            <span class="month-count">(0)</span>
                        </h5>
                    </div>

                </div>
                <div class="month-content show" id="monthContent5">
                    <div class="month-member-list" id="monthList5"></div>
  </div>
            </div>

            <div class="birthday-month-section" data-month="6">
                <div class="month-header" onclick="toggleMonth(6)">
                    <div>
                        <h5 class="month-title">
                            <i class="bi bi-calendar-month"></i>
                            Tháng 6
                            <span class="month-count">(0)</span>
  </h5>
                    </div>

                </div>
                <div class="month-content show" id="monthContent6">
                    <div class="month-member-list" id="monthList6"></div>
                </div>
            </div>

            <div class="birthday-month-section" data-month="7">
                <div class="month-header" onclick="toggleMonth(7)">
                    <div>
                        <h5 class="month-title">
                            <i class="bi bi-calendar-month"></i>
                            Tháng 7
                            <span class="month-count">(0)</span>
                        </h5>
                    </div>

                </div>
                <div class="month-content show" id="monthContent7">
                    <div class="month-member-list" id="monthList7"></div>
                </div>
            </div>

            <div class="birthday-month-section" data-month="8">
                <div class="month-header" onclick="toggleMonth(8)">
                    <div>
                        <h5 class="month-title">
                            <i class="bi bi-calendar-month"></i>
                            Tháng 8
                            <span class="month-count">(0)</span>
                        </h5>
                    </div>

                </div>
                <div class="month-content show" id="monthContent8">
                    <div class="month-member-list" id="monthList8"></div>
                </div>
            </div>

            <div class="birthday-month-section" data-month="9">
                <div class="month-header" onclick="toggleMonth(9)">
                    <div>
                        <h5 class="month-title">
                            <i class="bi bi-calendar-month"></i>
                            Tháng 9
                            <span class="month-count">(0)</span>
                        </h5>
                    </div>

                </div>
                <div class="month-content show" id="monthContent9">
                    <div class="month-member-list" id="monthList9"></div>
                </div>
            </div>

            <div class="birthday-month-section" data-month="10">
                <div class="month-header" onclick="toggleMonth(10)">
                    <div>
                        <h5 class="month-title">
                            <i class="bi bi-calendar-month"></i>
                            Tháng 10
                            <span class="month-count">(0)</span>
                        </h5>
                    </div>

                </div>
                <div class="month-content show" id="monthContent10">
                    <div class="month-member-list" id="monthList10"></div>
                </div>
            </div>

            <div class="birthday-month-section" data-month="11">
                <div class="month-header" onclick="toggleMonth(11)">
                    <div>
                        <h5 class="month-title">
                            <i class="bi bi-calendar-month"></i>
                            Tháng 11
                            <span class="month-count">(0)</span>
                        </h5>
                    </div>

                </div>
                <div class="month-content show" id="monthContent11">
                    <div class="month-member-list" id="monthList11"></div>
                </div>
            </div>

            <div class="birthday-month-section" data-month="12">
                <div class="month-header" onclick="toggleMonth(12)">
                    <div>
                        <h5 class="month-title">
                            <i class="bi bi-calendar-month"></i>
                            Tháng 12
                            <span class="month-count">(0)</span>
                </h5>
                    </div>

                </div>
              <div class="month-content show" id="monthContent12">
                    <div class="month-member-list" id="monthList12"></div>
       </div>
            </div>
        </div>
	</div>
</div>
<script>
	//CÁC HÀM KHỞI TẠO
		//Khai báo biến
			var birthdaytoday = []
			var birthdaynext = []
            var birthdaymonth1 = []
            var birthdaymonth2 = []
            var birthdaymonth3 = []
            var birthdaymonth4 = []
            var birthdaymonth5 = []
            var birthdaymonth6 = []
            var birthdaymonth7 = []
            var birthdaymonth8 = []
            var birthdaymonth9 = []
            var birthdaymonth10 = []
            var birthdaymonth11 = []
            var birthdaymonth12 = []
            var DEFAULT_AVATAR_SVG_BirthDay = `
                <svg class="avatar" viewBox="0 0 200 200" xmlns="http://www.w3.org/2000/svg" role="img" aria-label="Default user avatar">
                    <rect width="200" height="200" fill="#ebf6ff"/>
                    <circle cx="100" cy="235" r="100" fill="#a4c3f5" stroke="#7192c7" stroke-width="6"/>
                    <circle cx="100" cy="76" r="43" fill="#fde69a" stroke="#e0b958" stroke-width="6"/>
                </svg>
            `;


		//DarkMode
            function initDarkMode_BirthDay_Moblie() {
		        const savedDarkMode = localStorage.getItem(''darkMode_BirthDay_Moblie'');
		        if (savedDarkMode === ''true'') {
			        document.body.classList.add(''dark-mode'');
		        }
	        }


		//Chỉnh giao diện
			function start_BirthDay_Moblie() {
				return new Promise((resolve) => {
					$("#header_sp_BirthDay_Moblie").addClass("d-none");
					$("#contentContainer_sp_BirthDay_Moblie").css("height", "calc(100vh - 60px)");
					$("#overlay-vts").css("display", "none");
					$(''#overlay-vts'').removeClass(''show'');
					$(''#overlay-vts'').addClass(''hidden'');
				resolve();
				});
			}


		//Hàm khởi tạo
			async function init_sp_BirthDay_Moblie() {
				await Promise.all([
					start_BirthDay_Moblie()
				]);
				await loadCustomerBirthday();
				renderBirthdayLists();
                renderMonthBirthdays();
                initDarkMode_BirthDay_Moblie();
			}
			init_sp_BirthDay_Moblie()





	//TẢI DỮ LIỆU
		//Tải dữ liệu khách hàng
			function loadCustomerBirthday() {
				return new Promise((resolve, reject) => {
                    AjaxHPAParadise({
                        data: {
                            name: "sp_GetCustomersBirthday",
                            param: ["LoginID", UserID,
                                    "LanguageID", LanguageID]
                        },
                        success: function(result) {
							birthdaytoday = JSON.parse(result).data[0];
							birthdaynext = JSON.parse(result).data[1];
                            birthdaymonth1 = JSON.parse(result).data[2];
                            birthdaymonth2 = JSON.parse(result).data[3];
                            birthdaymonth3 = JSON.parse(result).data[4];
                            birthdaymonth4 = JSON.parse(result).data[5];
                            birthdaymonth5 = JSON.parse(result).data[6];
           birthdaymonth6 = JSON.parse(result).data[7];
                            birthdaymonth7 = JSON.parse(result).data[8];
                            birthdaymonth8 = JSON.parse(result).data[9];
                            birthdaymonth9 = JSON.parse(result).data[10];
                            birthdaymonth10 = JSON.parse(result).data[11];
                            birthdaymonth11 = JSON.parse(result).data[12];
                            birthdaymonth12 = JSON.parse(result).data[13];
                            resolve()
						}
					})
				})
			}





    //RENDER GIAO DIỆN
        //Tạo thẻ sinh nhật
            function createBirthdayCard(person, isToday) {
            const date = formatDate(person.Birthday);
                let badge = ""
            if (isToday) {
                    badge = "<span class=\"today-badge\">HÔM NAY</span>";
                } else {
                    const daysUntil = getDaysUntilBirthday(person.Birthday);
                    if (daysUntil !== null) {
       badge = `<span class="days-badge">${daysUntil} ngày nữa</span>`;
                    }
                }
                return `
                    <div class="birthday-card ${isToday ? ''is-today-card'' : ''''}">
                        <div class="img_background ratio-1">
                            <img alt="Profile Picture"
                                 class="profile-img customer-avatar-birthday"
                                 _name="${person.storeImgName || ''''}"
                                 _param="${person.paramImg || ''''}"
                                 data-employee-id="${person.EmployeeID}"
                                 loading=''lazy'' />
                        </div>
                        <div class="birthday-info">
                            <div class="birthday-name">${person.FullName || "Không có tên"}</div>
                            <div class="birthday-date">
                                <i class="bi bi-calendar3"></i>
                                <span>${date}${badge}</span>
                            </div>
                            <div class = "birthday-typecustomer">
                                ${person.EmployeeTypeName}
                            </div>
                        </div>
                        <div class="birthday-icon">
                            <i class="bi bi-balloon-heart-fill"></i>
                        </div>
                    </div>
                `;
            }


        //Render dữ liệu vào thẻ
            function renderBirthdayLists() {
                if (birthdaytoday && birthdaytoday.length > 0) {
                    let todayHtml = "";
                    birthdaytoday.forEach(person => {
                        todayHtml += createBirthdayCard(person, true);
                    });
                    $("#todayList").html(todayHtml);
                } else {
                    $("#todayList").html(`
                        <div class="empty-state">
                            <i class="bi bi-emoji-smile"></i>
                            <p>Không có sinh nhật hôm nay</p>
                        </div>
                    `);
                }
                if (birthdaynext && birthdaynext.length > 0) {
                    let upcomingHtml = "";
                    birthdaynext.forEach(person => {
                        upcomingHtml += createBirthdayCard(person, false);
                    });
                    $("#upcomingList").html(upcomingHtml);
                } else {
                    $("#upcomingList").html(`
                        <div class="empty-state">
                            <i class="bi bi-calendar-x"></i>
                            <p>Không có sinh nhật sắp tới</p>
                        </div>
                    `);
                }
                setTimeout(() => {
 const imgs = document.querySelectorAll(''.customer-avatar-birthday'');
                    callImg_BirthDay(imgs);
                }, 100);
            }


            function callImg_BirthDay(a) {
                if (window.pendingImageRequests) {
                    window.pendingImageRequests.forEach(xhr => {
                        if (xhr && xhr.abort) xhr.abort();
                    });
                }
                window.pendingImageRequests = [];
                let observer = new IntersectionObserver((entries) => {
                    entries.forEach(entry => {
                        if (entry.isIntersecting) {
                            let img = entry.target;
                            observer.unobserve(img);
                            loadSingleImage_BirthDay(img);
                        }
                    });
                }, {
                    rootMargin: ''200px''
                });
                for (let i = 0; i < a.length; i++) {
                    let img = a[i];
img.src = "data:image/svg+xml;base64," + btoa(DEFAULT_AVATAR_SVG_BirthDay);
                    observer.observe(img);
                }
            }


            function loadSingleImage_BirthDay(imgElement) {
                let self = $(imgElement);
                let name = self.attr("_name");
                if (!name || name.length === 0 || name === ''null'' || name === ''undefined'') {
                    return;
                }
                let paramStr = self.attr("_param") || "{}";
                let param;
                try {
                    param = JSON.parse(decodeURIComponent(paramStr));
                } catch(e) {
                    try {
                        param = JSON.parse(paramStr);
                    } catch(e2) {
                        return;
                    }
                }
                let success = function (blob, status, xhr) {
                    if (blob && blob.size > 0) {
                        try {
                            var url = URL?.createObjectURL(blob);
                            if (url) {
                                self.attr("src", url);
                                self.one(''load'', function() {
                                setTimeout(() => URL.revokeObjectURL(url), 1000);
                                });
                }
                        } catch(e) {}
                    }
                }
                let error = function(xhr, status, error) {
                }
                let ajaxRequest = AjaxHPAParadise({
                    data: { name: name, param: param },
                    xhrFields: { responseType: "blob" },
                    cache: true,
                    success: success,
                    error: error
                });
                if (ajaxRequest && ajaxRequest.abort) {
                    window.pendingImageRequests.push(ajaxRequest);
                }
            }


        //Render danh sách sinh nhật theo tháng
            function renderMonthBirthdays() {
                var monthData = [
                    { month: 1, data: birthdaymonth1 },
                    { month: 2, data: birthdaymonth2 },
                    { month: 3, data: birthdaymonth3 },
                    { month: 4, data: birthdaymonth4 },
                    { month: 5, data: birthdaymonth5 },
                    { month: 6, data: birthdaymonth6 },
                    { month: 7, data: birthdaymonth7 },
                    { month: 8, data: birthdaymonth8 },
                    { month: 9, data: birthdaymonth9 },
                    { month: 10, data: birthdaymonth10 },
                    { month: 11, data: birthdaymonth11 },
                    { month: 12, data: birthdaymonth12 }
                ];

                monthData.forEach(function(item) {
                    var monthList = $("#monthList" + item.month);
                    var monthCount = $(''.birthday-month-section[data-month="'' + item.month + ''"] .month-count'');

                    if (item.data && item.data.length > 0) {
                        monthCount.text("(" + item.data.length + ")");
                        var html = "";
                        item.data.forEach(function(person) {
                            var paramImg = person.paramImg;
                            var decoded_param = decodeURIComponent(paramImg);
                            var FullNamePPPP = person.FullName ? person.FullName : "Avatar";
                            var FullNameAAAA = person.FullName ? person.FullName : "Không có tên";
                            var birthdayPPPP =  formatDate(person.Birthday)

 html += `<div class="month-member-item">`;
                            html += `<div class="month-member-avatar">`;
                            html += `<img alt="${FullNamePPPP}"`;
                            html += `class="month-avatar-img" `;
                            html += `_name="${person.storeImgName}" `;
                            html += `_param=''${decoded_param}'' `;
                            html += `data-employee-id="${person.EmployeeID}" />`;
                            html += `</div>`;
                            html += `<div class="month-member-name">${FullNameAAAA}</div>`;
                            html += `<div class="month-member-date">${birthdayPPPP}</div>`;
                            html += `</div>`;
                        });
                        monthList.html(html);
                    } else {
                        monthCount.text("(0)");
                        monthList.html(''<div style="text-align: center; padding: 20px; color: #999;">Không có sinh nhật</div>'');
                    }
                });

                setTimeout(function() {
                    var imgs = document.querySelectorAll(''.month-avatar-img'');
                    callImg_BirthDay(imgs);
                }, 100);
            }

    //HÀM CHỨC NĂNG
        //Format dạng ngày
            function formatDate(dateStr) {
                if (!dateStr) return "";
                const date = new Date(dateStr);
                const day = date.getDate().toString().padStart(2, "0");
                const month = (date.getMonth() + 1).toString().padStart(2, "0");
                return day + "/" + month;
            }


        //Tính số ngày còn lại đến sinh nhật
            function getDaysUntilBirthday(birthdayStr) {
                if (!birthdayStr) return null;
                const today = new Date();
                const birthday = new Date(birthdayStr);
                const thisYearBirthday = new Date(today.getFullYear(), birthday.getMonth(), birthday.getDate());
                const diffTime = thisYearBirthday - today;
                const diffDays = Math.ceil(diffTime / (1000 * 60 * 60 * 24));
                return diffDays;
            }


        //Toggle hiển thị/ẩn nội dung tháng
            function toggleMonth(monthNumber) {
                var content = $("#monthContent" + monthNumber);
                var arrow = $(''.birthday-month-section[data-month="'' + monthNumber + ''"] .month-arrow'');

                if (content.hasClass(''show'')) {
                    content.removeClass(''show'');
                    arrow.removeClass(''expanded'');
                } else {
                    content.addClass(''show'');
                    arrow.addClass(''expanded'');
                }
            }

		uiManager.hideLoading()
</script>
'
--exec sp_GenerateHTMLScript 'sp_BirthDay_Moblie_html'
select @html as html
END
GO