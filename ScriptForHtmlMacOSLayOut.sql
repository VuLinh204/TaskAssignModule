USE Paradise_Beta_Tai2
GO
if object_id('[dbo].[ScriptForHtmlMacOSLayOut]') is null
	EXEC ('CREATE PROCEDURE [dbo].[ScriptForHtmlMacOSLayOut] as select 1')
GO
ALTER PROCEDURE [dbo].[ScriptForHtmlMacOSLayOut]
    @LoginID int,
    @SriptHtml NVARCHAR(MAX) OUTPUT,  -- Output parameter
	@LanguageID varchar(5) = 'VN',
	@isWeb int = 0
AS
BEGIN
		DECLARE @HtmlLanguage nvarchar(max),@EmptyHtml nvarchar(max) = ''
		DECLARE @ShortcutKeysList nvarchar(max) = '';
		SELECT @ShortcutKeysList += CONCAT(
		'{MenuID: `',
			MenuID, '`, ClassName:`', ClassName,'`, ContentVN: `', mVN.Content, '`, ContentEN: `', mEN.Content,
			'`, ShortcutKeys: `', ShortcutKeys, '`},'
		)
		FROM MEN_Menu mn
		left join tblMD_Message m on mn.MenuID=m.MessageID and m.Language=@LanguageID
         left join tblMD_Message mVN on mn.MenuID=mVN.MessageID and mVN.Language='VN'
         left join tblMD_Message mEN on mn.MenuID=mEN.MessageID and mEN.Language='EN'
		where isnull(ShortcutKeys,'') <> '' and IsVisible = 1
		DECLARE @DockMenu nvarchar(max) = '';
		SELECT @DockMenu += CONCAT(
		'{id: `',
			MenuID, '`, name:`', Content,
			'`, keywords: `', Content, '`, img:`', Data,
			'`, Level:', LevelID, ', className: `', ClassName,
			'`, ParentMenuID: `', ParentMenuID, '`},'
		)
		FROM #tmpMenuListData where Menuid not in ('MnuSCR000','MnuSCR041','MnuSCR610')
		
		declare @LaunchPadMenu nvarchar(max) = '';
		select @LaunchPadMenu += CONCAT(
		'{id: `',
			MenuID, '`, name:`', Content,'`, showDialog: `', showDialog,
			'`, keywords: `', Content, '`, img:`', data,
			'`, Level:', LevelID , ', className: `', ClassName,
			'`, ParentMenuID: `', ParentMenuID,'`, IconBackColor: `',IconBackColor,'`, IconForeColor: `',IconForeColor, '`, ObjectID: ', ObjectID, '},'
		)
		from #tmpMenuListData a where LevelID <> 0
		and  Menuid not in ('MnuSCR000','MnuSCR041','MnuSCR610')
		order by a.ParentMenuID,a.Priority

		
		create table #tmpDataRightCustom (FullAccess varchar(50),ObjectName nvarchar(200),LoginID int,ObjectID int)
		 exec SC_LoadFullRightObject @LoginID,'#tmpDataRightCustom'

		declare @FullRightObject nvarchar(max) = '';
		select @FullRightObject += CONCAT(
		'{ObjectID: `',
			ObjectID, '`, ObjectName:`', ObjectName,
			'`, FullAccess: ', FullAccess, '},'
		)
		from #tmpDataRightCustom
		
		--Start Generate app dock
		declare @TempModuleDockApp nvarchar(2000) = '';
		select @TempModuleDockApp += '`' + MenuID +'`,' from #tmpMenuListData where LevelID = 0 order by Priority
		
		
		--Hieu: nếu chưa có trong bảng pin/recent thì thêm vào
		declare @MenuPinList nvarchar(2000) = '``', @MenuRecentList nvarchar(2000),
		@StringDockApp NVARCHAR(MAX), @StartIndex int, @EndIndex int,@LimitAppInDock int = 5;
		if not exists (select 1 from tblCommonSettingEditable  where @LoginID  = LoginID)
		begin
			insert into tblCommonSettingEditable(LoginID,LastChangeddate,LanguageID,SimpleUI,MenuPinList,MenuRecentList)
			select @LoginID,GETDATE(),@LanguageID,1,'``','``'
		end
		select @MenuPinList = MenuPinList, @MenuRecentList = MenuRecentList  from tblCommonSettingEditable where LoginID = @LoginID
		--MenuPinList Default if column MenuPinList null
		select @LimitAppInDock = [Value] from tblParameter where Code = 'LimitAppInDock' and [Value] <> ''
	
		if ISNULL(@MenuPinList,'``') = '``'
		begin
			declare @DefaultPinDock nvarchar(2000) = '';
			--tạm thời lấy 5 menu đầu tiên, sẽ tuyển chọn sau
			select top (@LimitAppInDock) @DefaultPinDock = @DefaultPinDock + '`' + MenuID + '`,'
			from #tmpMenuListData WHERE LevelID <> 0 ORDER BY LevelID,Priority;
			IF RIGHT(@DefaultPinDock, 1) = ','
				SET @DefaultPinDock = SUBSTRING(@DefaultPinDock, 1, LEN(@DefaultPinDock) - 1);

			set @MenuPinList = @DefaultPinDock
			
		    update tblCommonSettingEditable SET MenuPinList = @MenuPinList, MenuRecentList = '``'  where LoginID = @LoginID

		end

		set @StringDockApp = '[' + @TempModuleDockApp + isnull(@MenuPinList,'') + ',' + isnull(@MenuRecentList,'') + ']';
		
		--select @StringDockApp,@MenuPinList
	
	exec sp_calculateStartEndIndex @LoginID = @LoginID, @StringDockApp = @StringDockApp, @StartIndex = @StartIndex output, @EndIndex = @EndIndex output,
		@MenuPinList = @MenuPinList, @MenuRecentList = @MenuRecentList
		declare @MenuIDLaunPad nvarchar(MAX) = 'MnuHRS238';
		select @MenuIDLaunPad = [Value] from tblParameter where Code = 'MenuIDLaunPad' and [Value] <> ''
	 --select @ShortcutKeysList
		--set @StartIndex = 5
		--set @EndIndex = 8

	EXEC [dbo].[sp_LanguageWeb]
        @LoginID = @LoginID,
        @LanguageID = @LanguageID,
        @HtmlLanguage = @HtmlLanguage OUTPUT;
		set @SriptHtml =
		
		N'
			  <script>
        // Get the apps as an array of objects with image and name
           const apps = [
    '+@LaunchPadMenu+ N'

    ];

	 let appsDock = [
	 '+@DockMenu+N'
	 ];
	 let ShortcutKeysList = ['+@ShortcutKeysList+'];
	 let fullRightObject = [
	 '+ISNULL(@FullRightObject, '')+N'
	 ];

	// console.log(''Render firsttime'');

    </script>
		'
		+
		N'
		
		    <script>
	let orderDockApp = ' + @StringDockApp + N';

	const itemsPerPage = 28;
	const firtHrElement = ' + cast(@StartIndex as nvarchar) + N';
    let secondHrElement = '+ cast(@EndIndex as nvarchar)+N';
    let currentPage = 1;
    let filteredApps = apps;
    let totalPages = 0;
	let currentSelectedMenu = null;
	let currentSelectedMenuName = null;
	const currentAppIdOpen = new Set();

   // const prevButton = document.querySelector(''.prev-button'');
  //  const nextButton = document.querySelector(''.next-button'');


	 // Right click to desktop
     document.onclick = hideMenu;

	 function shortenString(str, maxLength = 20) {
    // Check if the string is already shorter than or equal to the maxLength
		if (str.length <= maxLength) {
			return str;
		}

		// Split the string into words
		//let words = str.split(" ");

		// Take the first two words and the last word, and join them with "..."
		//let shortenedStr = `${words[0]} ${words[1]}...${words[words.length - 1]}`;
		let shortenedStr = `${str.slice(0,17)}...`;

		return shortenedStr;
	}



    function hideMenu() {
      hideMenuLaunchPad();
      hideMenuDock();
	  hideMenuContextTab();
    }

	 function hideMenuContextTab() {
      var menu = document.getElementById("contextMenuTab");
	   if(menu){
      menu.style.zIndex = "-1";
      menu.style.opacity = "0";
	  }
    }

    function hideMenuLaunchPad() {
      var menu = document.getElementById("contextMenu");
	  if(menu)
	  {
      menu.style.zIndex = "-1";
      menu.style.opacity = "0";
	  }
    }

    function hideMenuDock() {
      var menu = document.getElementById("contextMenuDock");
	   if(menu)
	   {
      menu.style.zIndex = "-1";
      menu.style.opacity = "0";
	  }
    }

   // Right click to app desktop

	// Handle right-click for both desktop and dock
	function handleRightClick(e, appId, menuId) {
	  e.preventDefault();

	  const menu = document.getElementById(menuId);

	  if (menu.style.opacity === "1") {
		hideMenu();
	  } else {
		menu.style.zIndex = "10001";
		menu.style.opacity = "1";
		menu.style.left = `${e.pageX}px`;
		menu.style.top = `${e.pageY}px`;
		currentSelectedMenu = appId;
	  }
	}
	
   // Right-click handlers for context tab menu
	function rightClickTab(e, appId, appName) {
	  currentSelectedMenuName = appName;
	  handleRightClick(e, appId, "contextMenuTab");
	}

	// Right-click handlers for app desktop and dock
	function rightClick(e, appId) {
	  handleRightClick(e, appId, "contextMenu");
	}

	function rightClickDock(e, appId) {
	  handleRightClick(e, appId, "contextMenuDock");
	}


    function findAppLaunchPad(id){

      return apps.find(app => app.id === id);
    }

    function findAppDock(id){
      return appsDock.find(app => app.id === id);
    }

    function findAppById(id) {
      let app = findAppLaunchPad(id);
      if (app === undefined){
        app = findAppDock(id);
  }

        return app;
    }

	 function removeButtonAtIndex(index) {
			const container = document.querySelector(''.dock'');
			const buttons = container.getElementsByTagName(''button'');

			if (index >= 0 && index < buttons.length) {
			  container.removeChild(buttons[index]);
			} else {
			  console.log("Invalid index");
			}
		}

	function openAppContext(){
	  OpenAppInSidebar(currentSelectedMenu);
	}
	function handleUnpinToTaskbarClick(isUpdateLayout){
	  const indexAppDock = appsDock.findIndex(app => app.id === currentSelectedMenu);
      appsDock = appsDock.filter(app => app.id !== currentSelectedMenu);
      removeButtonAtIndex(indexAppDock);
	  secondHrElement--;

	   updateStyleDock();

	  if(isUpdateLayout){
	
	  //UpdateLayOutApi(''EndIndexPin'',`${secondHrElement}`);
	  //const DockOrder = appsDock.map(app => app.id);
	 // const arrayString = ''[`'' + DockOrder.map(item => item).join(''`, `'') + ''`]'';
	  //UpdateLayOutApi(''DockOrder'', arrayString);
	  UpdateDockOrderApp();

	  console.log(''Get response'');
	
	  }

    }


    function handlePinToTaskbarClick(isInsertAtTheEnd) {
    const appToAdd = findAppById(currentSelectedMenu);
    const appsDockContainer = document.querySelector(''.dock'');

    if (!appToAdd) return;

    const existsInPinned = appsDock.slice(0, secondHrElement).some(app => app.id === appToAdd.id);
    const indexInDock = appsDock.findIndex(app => app.id === appToAdd.id);


    if (indexInDock >= secondHrElement && isInsertAtTheEnd) {
        // Không làm gì cả, giữ nguyên vị trí trong recent
        return;
    }


    if (!existsInPinned) {
        if (indexInDock !== -1) {

            appsDock = appsDock.filter(app => app.id !== currentSelectedMenu);
            removeButtonAtIndex(indexInDock);
        }

        if (isInsertAtTheEnd) {
            appsDock.splice(secondHrElement, 0, appToAdd);
        } else {
            if (currentAppIdOpen.has(appToAdd.id)) {
                currentAppIdOpen.delete(appToAdd.id);
            }
            insertAppAtIndex(findSecondHrIndex(appsDockContainer) - 1, appToAdd);
        }
    } else {
        return;
    }


    const appButton = document.createElement(''button'');
    appButton.classList.add(''icon'', appToAdd.id);
    appButton.innerHTML = `
        ${appToAdd.img}
        <span class="point" id="point-${appToAdd.id}"></span>
    `;
    appButton.classList.add(`open-${appToAdd.id}`);


    if (!appButton._hasClickListener) {
        appButton.addEventListener(''click'', function(e) {
            insertEmployeeWindow(appToAdd.id, appToAdd.name, appToAdd.className);
            openMenu(appToAdd);
            if (appToAdd.className) {
                document.querySelector(`#point-${appToAdd.id}`).style.display = ''block'';
            }
            const appsDockContainer2 = document.querySelector(''.dock'');
            const indexOfApp = Array.prototype.indexOf.call(appsDockContainer2.children, this);
            const indexOfHr = Array.prototype.indexOf.call(appsDockContainer2.children, appsDockContainer2.children[secondHrElement + 1]);

            if (indexOfApp < indexOfHr) {
                ChangePositionRecent(appToAdd.id);

                return;
            }
            highLightApp(appToAdd.id);

        });
        appButton._hasClickListener = true;
    }


    if (!appButton._hasContextMenuListener) {
        appButton.addEventListener(''contextmenu'', function(event) {
            if (isInsertAtTheEnd) {
                rightClick(event, appToAdd.id);
            } else {
                rightClickDock(event, appToAdd.id);
            }
        });
        appButton._hasContextMenuListener = true;
    }


    const allHrElements = appsDockContainer.querySelectorAll(''hr'');
    const secondHr = allHrElements[1];
    if (isInsertAtTheEnd) {
        appsDockContainer.insertBefore(appButton, secondHr.nextSibling);
    } else {
 appsDockContainer.insertBefore(appButton, secondHr);
        secondHrElement++;
    }

    updateStyleDock();
    limitAppInDock();
    UpdateDockOrderApp();
}

	  function updateStyleDock(){

      const existingStyle = document.querySelector(''#dockStyles''); // Look for the existing style tag with a specific id



      if (existingStyle) {
          // Remove old style if it exists
          existingStyle.remove();
      }

      const style = document.createElement(''style'');
style.id = ''dockStyles'';
      let styleDock = '''';

      let appIndex = 0;
        appsDock.forEach(app =>{
   const topOffset = -3;
      if(appIndex  === firtHrElement || appIndex === secondHrElement){
            styleDock += `
      .dock .icon:nth-child(${appIndex + 1}):hover::after {
              content: "${app.name}";
              top: ${-topOffset}vh;
      }
      .dock .icon:nth-child(${appIndex + 1}):hover::before {
              display: none;

            }

 .dock .icon:nth-child(${appIndex + 1})::before {
              content: "${shortenString(app.name)}";

            }
        `
        appIndex++;
          }
          styleDock += `
            .dock .icon:nth-child(${appIndex + 1}):hover::after {
              content: "${app.name}";
        top: ${-topOffset}vh;
            }

      .dock .icon:nth-child(${appIndex + 1}):hover::before {
              display: none;




            }

      .dock .icon:nth-child(${appIndex + 1})::before {
              content: "${shortenString(app.name)}";

            }
          `

          appIndex ++;
      });

      style.innerHTML = styleDock;
      document.head.append(style);
    }


   function limitAppInDock(){
      const numberOfApp = '+CAST(@LimitAppInDock as varchar)+N';
      limitAppPinInDock(numberOfApp);
      limitAppRecentInDock(numberOfApp);
    }

    function limitAppPinInDock(numberOfApp){
      if((secondHrElement - (firtHrElement + 1)) > numberOfApp ){
        currentSelectedMenu = appsDock[(firtHrElement + 1)].id;
        handleUnpinToTaskbarClick(true);
      }

   }

   function limitAppRecentInDock(numberOfApp){
      if((appsDock.length - secondHrElement) > numberOfApp ){
          currentSelectedMenu = appsDock[(appsDock.length- 1)].id;
          handleRemoveAppEndInDock();
		 // secondHrElement++;
        }

    }

  function ChangePositionRecent(menu_id){
		//const indexAppDock = appsDock.findIndex(app => app.id === currentSelectedMenu);
		//appsDock = appsDock.filter(app => app.id !== currentSelectedMenu);
		//removeButtonAtIndex(indexAppDock);
		
		currentSelectedMenu = menu_id;
		console.log(currentSelectedMenu)
        handlePinToTaskbarClick(true);
		highLightApp(menu_id);

  }

  function highLightApp(menu_id){
		const elementApp = document.querySelector(`.dock .icon.${menu_id}`);
		if(elementApp){
	    elementApp.classList.add(`highLightApp`);
		}


		const allElements = document.querySelectorAll(''.dock .icon.highLightApp'');
		allElements.forEach((element) => {
			
			if (!element.closest(`.icon.${menu_id}`)) {
				element.classList.remove(''highLightApp'');
			}
		});
  }

  function handleRemoveAppEndInDock(){
	const indexAppDock = appsDock.findIndex(app => app.id === currentSelectedMenu);
		appsDock = appsDock.filter(app => app.id !== currentSelectedMenu);
		removeButtonAtIndex(indexAppDock);
	}

	function insertAppAtIndex(index, appToAdd) {
     if (index < 0 || index > appsDock.length) {
console.error(''Index out of bounds'');
   return;
      }

      // Insert the item at the specified index
      appsDock.splice(index, 0, appToAdd);
  }



  function findSecondHrIndex(container) {
    // Get all <hr> elements within the container
      const hrElements = container.querySelectorAll(''hr'');

   // Check if there is a second <hr> element
      if (hrElements.length >= 2) {
          // Get the second <hr> element
          const secondHr = hrElements[1];




          const dockChildrenArray = Array.from(container.children);

          // Get the index of the second <hr> element
          return dockChildrenArray.indexOf(secondHr);
      } else {
          // Less than two <hr> elements found
 return -1;
      }
  }
	
	 function insertStyle(id, cssdata, append = false) {
		const existingStyle = document.querySelector(`#${id}`);
		if (existingStyle) {
			if (append) {
				existingStyle.innerHTML += cssdata; // Append the new styles
			} else {
				existingStyle.innerHTML = cssdata; // Replace with new styles
			}
		} else {
			const style = document.createElement(''style'');
			style.id = `${id}`;
			style.innerHTML = cssdata;
			document.head.append(style);
		}
	}


	function renderAppsCarousel(){
	
	  const carouselContainer = document.querySelector(''.carousel'');
	  carouselContainer.innerHTML = ``;

	  const existingStyle = document.querySelector(`#appHoverStyles`);
	  if(existingStyle){
		existingStyle.innerHTML = ``;
	  }
	

	  const numberPageOfApp = Math.ceil(filteredApps.length / itemsPerPage);

	  for(let i = 1; i <= numberPageOfApp ; i++){
		renderApps(i);
	  }
	
	  firstImg = carousel.querySelectorAll(".Apps-container")[0];
	
	}

    // Function to render apps based on the current page
    function renderApps(page) {

        const start = (page - 1) * itemsPerPage;
        const end = start + itemsPerPage;
        //const appsContainer = document.querySelector(''.Apps-page-container'');
		const carouselContainer = document.querySelector(''.carousel'');

		const appsContainerParent = document.createElement(''div'');
		appsContainerParent.classList.add(''Apps-container'')
        appsContainerParent.innerHTML = '''';

		const appsContainer = document.createElement(''div'');
		appsContainer.classList.add(''Apps-page-container'')
        appsContainer.innerHTML = '''';

        const paginatedApps = filteredApps.slice(start, end);
        if (totalPages != Math.ceil(filteredApps.length / itemsPerPage)){
          totalPages = Math.ceil(filteredApps.length / itemsPerPage);
          currentPage = 1;
        }
		let styleApp = '''';
        paginatedApps.forEach(app => {
            const appDiv = document.createElement(''div'');
  appDiv.classList.add(''child-launchpad'',''hover-span'',`${app.id}`);
   appDiv.setAttribute(''data-keywords'', app.keywords);
            appDiv.innerHTML = `
${app.img}
    <span>${shortenString(app.name)}</span>
            `;

			styleApp += `
			 .launchpad .${app.id}.hover-span::after {
					content: "${app.name}";
				}
			.launchpad .${app.id} i{
				color: ${app.IconForeColor};
				background: ${app.IconBackColor};
			}
			  `

			appDiv.classList.add(`open-${app.id}`);
			Array.from(appDiv.children).forEach(function(child) {
            child.addEventListener(''click'', (e) => handleAppLaunchPadInteraction(e, app));
            child.addEventListener(''pointerup'', (e) => handleAppLaunchPadInteraction(e, app));

			  });

			 // Add event listener for right-click (contextmenu event)
				 appDiv.addEventListener(''contextmenu'', function(event) {
				 rightClick(event, app.id);
            });

            appsContainer.appendChild(appDiv);
			appsContainerParent.appendChild(appsContainer);
			carouselContainer.appendChild(appsContainerParent);
        });
         //console.log(apps.length);
		insertStyle(''appHoverStyles'',styleApp,true);
       // prevButton.style.display = currentPage === 1 ? ''none'' : ''block'';
       // nextButton.style.display = currentPage === totalPages ? ''none'' : ''block'';
        // prevButton.disabled = currentPage === 1;
        // nextButton.disabled = currentPage === totalPages;
    }

	function handleAppLaunchPadInteraction(e, app) {
		insertEmployeeWindow(`${app.id}`,`${app.name}`,`${app.className}`);
			openMenu(app);
 const windown = document.querySelector(`.window.${app.id}`);

			    if(!appsDock.some(appItem => appItem.id === app.id)){
                currentAppIdOpen.add(app.id);
              }






			  ChangePositionRecent(app.id);

              //currentSelectedMenu = app.id;
 //handlePinToTaskbarClick(true);
			  if(app.className){
			   document.querySelector(`#point-${app.id}`).style.display = ''block'';
			   }
			 // open_window(windown, null, null);
	}

	function OpenAppInSidebar(menuId, param = ``){
		const app = findAppById(menuId);
		openMenu(`${app.className}`)
		insertEmployeeWindow(`${app.id}`,`${app.name}`,`${app.className}`, param);
		if(!appsDock.some(appItem => appItem.id === app.id)){
        currentAppIdOpen.add(app.id);
        }
		ChangePositionRecent(app.id);
		if(app.className){
		document.querySelector(`#point-${app.id}`).style.display = ''block'';
		}
	}


	  function renderAppsDock(){
      const appsDockContainer = document.querySelector(''.dock'');
	  const existingStyle = document.querySelector(''#dockStyles''); // Look for the existing style tag with a specific id

      if (existingStyle) {
          // Remove old style if it exists
          existingStyle.remove();
      }
      const style = document.createElement(''style'');
	  style.id = ''dockStyles'';

      let styleDock = '''';
	   appsDockContainer.innerHTML = '''';
      // appsDockContainer.innerHTML = '''';
      let appIndex = 0;
	  let elementIndex = 0;
       appsDock.forEach(app =>{
          const appButton = document.createElement(''button'');
       appButton.classList.add(''icon'',`${app.id}`);
	if(`${app.id}`  === `'+@MenuIDLaunPad+N'`){
            appButton.classList.add(''open-lunchpad'');
	
          }else{
            appButton.classList.add(`open-${app.id}`);

            appButton.addEventListener(''click'', function(e){
			
              insertEmployeeWindow(`${app.id}`,`${app.name}`,`${app.className}`);
			  openMenu(app);

              const windown = document.querySelector(`.window.${app.id}`);

			  ChangePositionRecent(app.id);
			  //currentSelectedMenu = app.id;
              //handlePinToTaskbarClick(true);
			  if(app.className){
			   document.querySelector(`#point-${app.id}`).style.display = ''block'';
			   }
              //open_window(windown, null, null)
            });

          }
          appButton.innerHTML  = `
           ${app.img}
		    <span class="point" id="point-${app.id}" ></span>
          `;

		 if(elementIndex > firtHrElement + 1 && elementIndex < secondHrElement + 1){
           // Add event listener for right-click (contextmenu event)
            appButton.addEventListener(''contextmenu'', function(event) {
            rightClickDock(event,app.id);
            });
          }
          else if (elementIndex > secondHrElement + 1){
  // Add event listener for right-click (contextmenu event)
             appButton.addEventListener(''contextmenu'', function(event) {
              rightClick(event,app.id);
     });
          }

		  const topOffset = -3;
          appsDockContainer.appendChild(appButton);
          if(elementIndex  === firtHrElement || elementIndex === secondHrElement){
		   if(secondHrElement === firtHrElement + 1){
		
			    const hr = document.createElement(''hr'');
			   hr.classList.add(''column'',''hidden'');
			   appsDockContainer.appendChild(hr);
				  styleDock += `
				 .dock .icon:nth-child(${elementIndex + 1}):hover::after {

				  content: "${app.name}";
				   top: ${-topOffset}vh;
				}
		
			  `
				elementIndex++;
		   }
		    const hr = document.createElement(''hr'');
			 hr.classList.add(''column'',''hidden'');
   appsDockContainer.appendChild(hr);
			  styleDock += `
            .dock .icon:nth-child(${elementIndex + 1}):hover::after {
       content: "${app.name}";
               top: ${-topOffset}vh;
  }

			 .dock .icon:nth-child(${elementIndex + 1}):hover::before {
              display: none;

            }

			.dock .icon:nth-child(${elementIndex + 1})::before {
 content: "${shortenString(app.name)}";

            }
          `
            elementIndex++;
          }
		
          styleDock += `
             .dock .icon:nth-child(${elementIndex + 1}):hover::after {
              content: "${app.name}";
			   top: ${-topOffset}vh;
            }

			 .dock .icon:nth-child(${elementIndex + 1}):hover::before {
              display: none;

            }

		   .dock .icon:nth-child(${elementIndex + 1})::before {
              content: "${shortenString(app.name)}";

            }
          `
		  appIndex++;
          elementIndex ++;
       });

       style.innerHTML = styleDock;
       document.head.append(style);
      // console.log(styleDock);



    }


    function renderPagination() {
        totalPages = Math.ceil(filteredApps.length / itemsPerPage);


   // prevButton.disabled = currentPage === 1;
        // nextButton.disabled = currentPage === totalPages;

       // prevButton.style.display = currentPage === 1 ? ''none'' : ''block'';
       // nextButton.style.display = currentPage === totalPages ? ''none'' : ''block'';

       // prevButton.addEventListener(''click'', () => {
      //      currentPage = currentPage - 1;
    // renderApps(currentPage);
     //   });

        nextButton.addEventListener(''click'', () => {
 currentPage = currentPage + 1;
            renderApps(currentPage);

   });

}



    // Debounce function to limit the number of search executions

    function debounce(func, delay) {
        let timeout;
        return function(...args) {
            clearTimeout(timeout);
            timeout = setTimeout(() => func.apply(this, args), delay);
        };
    }

  // Function to calculate fuzzy match score (Levenshtein distance algorithm)
    function fuzzyMatch(query, keyword) {
        const threshold = 3; // Max number of character differences allowed
        return getLevenshteinDistance(query, keyword) <= threshold;
    }

    // Helper function: Levenshtein distance algorithm
    function getLevenshteinDistance(a, b) {
        const matrix = [];
        for (let i = 0; i <= b.length; i++) {
            matrix[i] = [i];
        }
        for (let j = 0; j <= a.length; j++) {
            matrix[0][j] = j;
        }
     for (let i = 1; i <= b.length; i++) {
            for (let j = 1; j <= a.length; j++) {
                if (b.charAt(i - 1) === a.charAt(j - 1)) {
                    matrix[i][j] = matrix[i - 1][j - 1];
            } else {
                    matrix[i][j] = Math.min(matrix[i - 1][j - 1] + 1, matrix[i][j - 1] + 1, matrix[i - 1][j] + 1);
                }
   }
  }
        return matrix[b.length][a.length];
    }

    // Search function with fuzzy and partial matching
    function searchApps(query) {
		
        if (query === '''') {
		//Hiếu: nếu query rỗng thì in ra tất cả
            filteredApps = apps;
		//Hiếu: Phân trang nè
            totalPages = Math.ceil(filteredApps.length / itemsPerPage);
            currentPage = 1;
        } else {
             //Hiếu: cho tất cả về chữ thường
             const queryLower = toLowerCaseNonAccentVietnamese(query);
            filteredApps = apps.filter(app => {
                const keywords = toLowerCaseNonAccentVietnamese(app.keywords).split('','');
				
                const name = toLowerCaseNonAccentVietnamese(app.name);
				const id = toLowerCaseNonAccentVietnamese(app.id)
				const sp = toLowerCaseNonAccentVietnamese(app.className)
         return (
                    keywords.some(keyword => keyword.includes(queryLower)) ||
name.includes(queryLower) || id.includes(queryLower) || sp.includes(queryLower) ||
                    fuzzyMatch(queryLower, name)
                );
});

		
        }
 currentPage = 1; // Reset to first page
		if(filteredApps.length === 0){
				 //   prevButton.style.display = ''none'';
				// nextButton.style.display = ''none'';
				 // return;
			
			  arrowIcons[1].style.display = "none";
           } else {
			arrowIcons[1].style.display = "block";

		   }
       // renderApps(currentPage);
		renderAppsCarousel();
		
    }

	  function addResultApp(id,name, details, icon, className, app) {
        // Select the result container
        const resultContainer = document.querySelector(''.result'');

        // Create a new div for the result-app
  const resultApp = document.createElement(''div'');
        resultApp.classList.add(''result-app'');
        resultApp.setAttribute(''data-name'', name);

        // Create the app-info section
        const appInfo = document.createElement(''div'');
        appInfo.classList.add(''app-info'');

        const appName = document.createElement(''div'');
        appName.classList.add(''app-name'');
      appName.textContent = name;

    const appDetails = document.createElement(''div'');
        appDetails.classList.add(''app-details'');
        appDetails.textContent = details;

        // Append the app name and details to app-info
        appInfo.appendChild(appName);
        appInfo.appendChild(appDetails);

      // Append the icon and info to result-app
        resultApp.innerHTML = icon;
        resultApp.appendChild(appInfo);

		 resultApp.addEventListener(''click'', function(e){
        insertEmployeeWindow(`${id}`,`${name}`,`${className}`);
		openMenu(app);
        const windown = document.querySelector(`.window.${id}`);


		if(!appsDock.some(appItem => appItem.id === id)){
      currentAppIdOpen.add(id);
        }

		ChangePositionRecent(id);
       // currentSelectedMenu = id;
       // handlePinToTaskbarClick(true);
	   if(className){
	    document.querySelector(`#point-${id}`).style.display = ''block'';
		}
		//open_window(windown, null, null);

        });

        // Append the new result-app to the result container

        resultContainer.appendChild(resultApp);
    }

	const searchInputSpotlight = document.querySelector(''.spotlight_search-bar'');
    searchInputSpotlight.addEventListener(''input'',()=>{

      const resultContainer = document.querySelector(''.result'');
      resultContainer.innerHTML = '''';
      resultContainer.style.display = ''none'';

      const query = event.target.value;
      if (query !== '''') {

             const queryLower = query.toLowerCase().normalize("NFD").replace(/[\u0300-\u036f]/g, "");

            const filteredApps = apps.filter(app => {
			const keywords = app.keywords.toLowerCase().normalize("NFD").replace(/[\u0300-\u036f]/g, "").split('','');
                const name = app.name.toLowerCase().normalize("NFD").replace(/[\u0300-\u036f]/g, "");

     return (
         keywords.some(keyword => keyword.includes(queryLower)) ||

       name.includes(queryLower) ||
                    fuzzyMatch(queryLower, name)
                );
            });

            if(filteredApps.length > 0){
              resultContainer.style.display = ''block'';
              filteredApps.slice(0, 5).forEach( item => {
            addResultApp(
			 `${item.id}`,
              `${item.name}`,
              "5.6 MB · PDF Document · Modified yesterday",
			  `${item.img}`,
			  `${item.className}`,
			  item
            );
          })
        }
        }

    } );


	
function UpdateLayOutApi(typeSetting, valueSetting){
		
		//UpdateDockOrderApp();
		
        $.ajax({
          url: window.APPLICATION_ADDRESS + ''/api/hpa/Paradise'',
          type: ''GET'', // Explicitly specifying the request type
      data: {
            user: UserName,
  PassWord: HashPass,
            name: ''sp_SaveWebLayOutSetting'',
            param: JSON.stringify(["TypeSetting", typeSetting, "NewValueSetting", valueSetting]) // Convert the param array to a string
          },
          success: function (result) {
         //   console.log(valueSetting);
          },
          error: function (error) {
            console.error("Error", error);
          }
        });


    }

	function UpdateDockOrderApp(){
		 const DockOrder = appsDock.map(app => app.id);
		 const MenuPinList = ''`'' + DockOrder.slice(firtHrElement + 1,secondHrElement).map(item => item).join(''`, `'') + ''`'';
		 const MenuRecentList = ''`'' + DockOrder.slice(secondHrElement).map(item => item).join(''`, `'') + ''`'';

		 AjaxHPAParadise({
			data: {
				name: "sp_DockOrderApp",
				param: ["LoginID", '+cast(@LoginID as nvarchar)+N', "MenuPinList", MenuPinList, "MenuRecentList", MenuRecentList]
			},
			success: function (resultData) {
				
        	},
        	error: function (xhr, status, error) {
				console.error("Error", error);
        	}
		});
		
		  //$.ajax({
          //url: window.APPLICATION_ADDRESS + ''/api/hpa/Paradise'',
          //type: ''GET'',  // Explicitly specifying the request type
          //data: {
          //  user: UserName,
          //  PassWord: HashPass,
          //  name: ''sp_DockOrderApp'',
          //  param: JSON.stringify(["LoginID", '+cast(@LoginID as nvarchar)+N', "MenuPinList", MenuPinList, "MenuRecentList", MenuRecentList])  // Convert the param array to a string
          //},
        //success: function (result) {
         //   console.log(valueSetting);
          //},
          //error: function (error) {
          //  console.error("Error", error);
		//}
        //});
	
	}

	

    // Combine both app arrays
	let combinedApp = [...apps, ...appsDock];
		combinedApp = Array.from(new Map(combinedApp.map(app => [app.id, app])).values());
		combinedApp = combinedApp.filter(app =>
		orderDockApp.includes(app.id)
	  );

	function sortArrayByOrder(orginalArray, orderDockApp) {

		  return orginalArray.sort((a, b) => {
			const indexA = orderDockApp.indexOf(a.id);
			const indexB = orderDockApp.indexOf(b.id);
			return indexA - indexB; // Sort according to order
		  });
		}

	   appsDock = sortArrayByOrder(combinedApp, orderDockApp);

    // Initial render
    //testApi();
	//UpdateLayOutApi(''DockOrder'',''[`MnuHRS000`, `MnuHRS238`, `MnuHRS245`, `MnuHRS246`, `MnuHRS249`, `MnuMDT000`, `MnuPRL000`, `MnuRPT001`, `MnuSCR000`, `MnuTAD000`, `MnuTM000`, `MnuWPT000`]'');
    renderAppsCarousel();
	//renderApps(currentPage);
	renderAppsDock();
   // renderPagination();

    // Debounced search
    const searchInput = document.querySelector(''.search-input'');
	searchInput.addEventListener(''input'', debounce((event) => {
        searchApps(event.target.value);
    }, 300));


	      function insertOrUpdateStyles(styleId, innerHTMLStyle) {
		// Check if the style element with a unique id already exists
		let styleElement = document.getElementById(`${styleId}`);

		// If the style element doesnt exist, create a new one
		if (!styleElement) {
			styleElement = document.createElement(''style'');
			styleElement.id = `${styleId}`;
			document.head.appendChild(styleElement);
		}

		// Update the inner content of the style element
		styleElement.innerHTML = `
			${innerHTMLStyle}
		`;
	}



			// console.log(''Render firsttime'');

			  /********** ELEMENTS **********/
			const elements = {
			  body: document.querySelector("body"),
			  navbar: document.querySelector(".navbar"),
			  open_spotlight: document.querySelector(".open_Search"),
			  spotlight_search: document.querySelector(".spotlight_serach"),
			  brightness_range: document.getElementById("brightness"),
			  sound_range: document.getElementById("sound"),
			  clockElement: document.getElementById("clock"),
			 clockWrapper: document.querySelector(".clock"),
			  widgetsPanel: document.querySelector(".widgets-panel"),
			  batteryButton: document.querySelector(".battery"),
			  batteryText: document.querySelector(".battery__text"),
			  batteryPopup: document.querySelector(".battery__popup"),
			  batteryPopupText: document.querySelector(".battery__popup header span"),
			  batteryProgress: document.querySelector(".battery__progress"),
			  batteryIsChargingLogo: document.querySelector(".is-charging"),

			  powerSource: document.querySelector(".power-source"),
			};



			// Launchpad
			const launchpad = {
			  container: document.querySelector(".container__Window"),
			  window: document.querySelector(".launchpad"),
			  searchbox: document.querySelector(".launchpad .searchbox"),
			 app_container: document.querySelector(".Apps-container"),
			  point: document.querySelector("#point-launchpad"),
			  opening: document.querySelector(".open-lunchpad")
			};

			/********** LISTENERS **********/

			'+@EmptyHtml+N'


			// Spotlight
			function handleopen_spotlight() {
			  if (elements.spotlight_search.style.display === "none") {
				elements.spotlight_search.style.display = "flex";
			 } else {
				elements.spotlight_search.style.display = "none";
			  }
			}

			  function isMinimized(element) {
				const maxWidth = window.getComputedStyle(element).maxWidth;
				const minWidth = window.getComputedStyle(element).minWidth;

				return maxWidth === "50%" && minWidth === "50%";
			  }

			
		  function handleHide(hide) {
			hide.style.transform = ''scale(0.1) translate(0%, 1850%)'';
			hide.style.opacity = ''0'';
			hide.style.width = ''150px'';
			hide.style.height = ''100px'';

			setTimeout(() => {
			  hide.style.display = ''none'';
		  }, 700);
		
		  }



			function handleMinimize(Minimize) {
			  Minimize.style.maxWidth = "50%";
			  Minimize.style.minWidth = "50%";
			  Minimize.style.height = "430px";


			  insertOrUpdateStyles(`sizeWindown_${Minimize.classList[1]}`, `
				
				.${Minimize.classList[1]} .window__taskbar--actions button:nth-child(3)::after {
         content: "🗖" !important;
				}

				`);
			}

			function handleFullScreen(maximize) {
			  maximize.style.maxWidth = "100%";
			  maximize.style.minWidth = "100%";
			  maximize.style.height = "93.62%";

			

			  insertOrUpdateStyles(`sizeWindown_${maximize.classList[1]}`, `

			    .${maximize.classList[1]} .window__taskbar--actions button:nth-child(3)::after {
				content: "🗗" !important;
					
				}

				`);

			}

			function close_window(close, point, appName) {
			  close.style.display = "none";
			 // point.style.display = "none";
			 // appName.style.display = "none";
			}

		function open_window(open, point, appName) {
			  // Ensure the open element is displayed
			  document.querySelector(`#point-${open.classList[1]}`).style.display = ''block'';

			  open.style.display = "block";
			  open.style.position = "absolute"; // Allow absolute positioning
			  setTimeout(() => {
			 open.style.transform = ''scale(1) translate(0, 0)'';
			  open.style.opacity = ''1'';

			  }, 1);

			  const centerX = 0;
			  const centerY = 0;

			  // Position the window in the center of the screen
			  open.style.left = `${centerX}px`;
			  // open.style.top = `${centerY}px`;

			  // Show other UI elements
			  launchpad.container.style.display = "flex";
			  launchpad.window.style.display = "none";
			  elements.spotlight_search.style.display = "block";
			  elements.widgetsPanel.style.display = "block";

			  if(isMinimized(open)){
					insertOrUpdateStyles(`sizeWindown_${open.classList[1]}`, `

				.${open.classList[1]} .window__taskbar--actions button:nth-child(3)::after {
				content: "🗖" !important;
					
				}

				`);
			  } else {

			  		insertOrUpdateStyles(`sizeWindown_${open.classList[1]}`, `

				.${open.classList[1]} .window__taskbar--actions button:nth-child(3)::after {
				
				content: "🗗" !important;
					
				}

				`);
			
			  }

	


			}


			
			 // Function to insert the style, checking if it already exists
			function insertSmallTextDockStyle() {
				const styleId = ''hide-icon-before-style'';
				// Check if the style element already exists
				if (!document.getElementById(styleId)) {
					const style = document.createElement(''style'');

					style.id = styleId;
					style.textContent = ''.dock .icon::before { display: none !important; }'';

					document.head.appendChild(style);
				}
			}

			// Function to remove the style by id, checking if it exists
			function removeSmallTextDockStyle() {
				const styleId = ''hide-icon-before-style'';
				const style = document.getElementById(styleId);
				if (style) {
					style.parentNode.removeChild(style);
				}
			}

			// Launchpad function start
			launchpad.opening.addEventListener("click", handleOpenLaunching);

			function handleOpenLaunching() {
			
			  if (launchpad.window.style.display === "none" || document.querySelector(`.master-tabs`).style.display === "block") {
		
			   elements.spotlight_search.style.display = "none";
			   elements.widgetsPanel.style.display = "none";
				launchpad.window.style.display = "block";
				document.querySelector(`.master-tabs`).style.display = ''none'';
				document.querySelector(`.home-sidebar`).style.display = ''none'';
				 insertSmallTextDockStyle();
				//elements.navbar.style.display = "none";
				//launchpad.point.style.display = "block";
			  } else {
			
			   elements.spotlight_search.style.display = "block";
			   elements.widgetsPanel.style.display = "block";
				launchpad.window.style.display = "none";
				// document.querySelector(`.master-tabs`).style.display = ''block'';
				//document.querySelector(`.home-sidebar`).style.display = ''block'';
				 removeSmallTextDockStyle() ;
				
				// elements.navbar.style.display = "flex";
				//launchpad.point.style.display = "none";
			  }
			  // launchpad.container.style.display = "none";
			}

			function handleLaunchpadSearch(e) {
			 for (let app of launchpad.app_container.children) {
				if (e.target.value) {
				  app.style.display = "none";
				  if (app.dataset.keywords.includes(e.target.value)) {

					app.style.display = "flex";
				  }
				} else app.style.display = "flex";
			  }
			}


		function toLowerCaseNonAccentVietnamese(str) {
			str = str.toLowerCase();
		//     We can also use this instead of from line 11 to line 17
		//     str = str.replace(/\u00E0|\u00E1|\u1EA1|\u1EA3|\u00E3|\u00E2|\u1EA7|\u1EA5|\u1EAD|\u1EA9|\u1EAB|\u0103|\u1EB1|\u1EAF|\u1EB7|\u1EB3|\u1EB5/g, "a");
		//     str = str.replace(/\u00E8|\u00E9|\u1EB9|\u1EBB|\u1EBD|\u00EA|\u1EC1|\u1EBF|\u1EC7|\u1EC3|\u1EC5/g, "e");
		//     str = str.replace(/\u00EC|\u00ED|\u1ECB|\u1EC9|\u0129/g, "i");
		//     str = str.replace(/\u00F2|\u00F3|\u1ECD|\u1ECF|\u00F5|\u00F4|\u1ED3|\u1ED1|\u1ED9|\u1ED5|\u1ED7|\u01A1|\u1EDD|\u1EDB|\u1EE3|\u1EDF|\u1EE1/g, "o");
		//     str = str.replace(/\u00F9|\u00FA|\u1EE5|\u1EE7|\u0169|\u01B0|\u1EEB|\u1EE9|\u1EF1|\u1EED|\u1EEF/g, "u");
		//     str = str.replace(/\u1EF3|\u00FD|\u1EF5|\u1EF7|\u1EF9/g, "y");
		//     str = str.replace(/\u0111/g, "d");
			str = str.replace(/à|á|ạ|ả|ã|â|ầ|ấ|ậ|ẩ|ẫ|ă|ằ|ắ|ặ|ẳ|ẵ/g, "a");
			str = str.replace(/è|é|ẹ|ẻ|ẽ|ê|ề|ế|ệ|ể|ễ/g, "e");
			str = str.replace(/ì|í|ị|ỉ|ĩ/g, "i");
			str = str.replace(/ò|ó|ọ|ỏ|õ|ô|ồ|ố|ộ|ổ|ỗ|ơ|ờ|ớ|ợ|ở|ỡ/g, "o");
			str = str.replace(/ù|ú|ụ|ủ|ũ|ư|ừ|ứ|ự|ử|ữ/g, "u");
			str = str.replace(/ỳ|ý|ỵ|ỷ|ỹ/g, "y");
			str = str.replace(/đ/g, "d");
			// Some system encode vietnamese combining accent as individual utf-8 characters
			str = str.replace(`/\u0300|\u0301|\u0303|\u0309|\u0323/g`, ""); // Huyền sắc hỏi ngã nặng

			str = str.replace(`/\u02C6|\u0306|\u031B/g`, ""); // Â, Ê, Ă, Ơ, Ư
			return str;
		}

			// Launchpad function end




		
			//handleopen_spotlight();
			handleOpenLaunching();

			document.addEventListener(''keydown'', function (event) {

    if (event.ctrlKey && event.key === ''f'') {
     event.preventDefault();
	
		  setTimeout(function () {
		$(''#launchpad'').fadeIn();
	}, 333);

// Delay 0.5 giây để thực hiện cả hai sự kiện hide
setTimeout(function () {
    $(''#MainSideBar'').hide();
    $(''#master-tabs'').hide();
}, 333);

setTimeout(function () {
  let $searchInput = $(''.search-input'');
    $searchInput.val('''');
	searchApps("");
    $searchInput.focus();
}, 335);


    }
});
'+@EmptyHtml+N'
			</script>
			<script>
function showLoadingByClassOrID(target, text = "Loading...", spinnerColor = "black", textColor = "white") {



    const targetElement = document.querySelector(target);
    if (targetElement) {
        if (!targetElement.querySelector(".custom-spinner-container")) {
            targetElement.style.position = "relative"; // Đảm bảo phần tử có position để chứa overlay đúng

            const overlay = document.createElement("div");
            overlay.classList.add("custom-overlay");

            const spinnerContainer = document.createElement("div");
            spinnerContainer.classList.add("custom-spinner-container");

            const spinner = document.createElement("div");
            spinner.classList.add("spinner-border");
            spinner.setAttribute("role", "status");
            spinner.style.color = spinnerColor;

            const spinnerText = document.createElement("div");
            spinnerText.classList.add("custom-spinner-text");
            spinnerText.innerText = text;
            spinnerText.style.color = textColor;

            spinnerContainer.appendChild(spinner);
            spinnerContainer.appendChild(spinnerText);

            targetElement.appendChild(overlay);
            targetElement.appendChild(spinnerContainer);
        }
    }
}

'set @SriptHtml +=N'
        // Hàm ẩn loading
        function HideLoadingByClassOrID(target) {
            const targetElement = document.querySelector(target);
			console.log(targetElement)
            if (targetElement) {

                const spinner = targetElement.querySelector(''.custom-spinner-container'');
                const overlay = targetElement.querySelector(''.custom-overlay'');
                if (spinner) {
                    spinner.remove();
                }
                if (overlay) {
                    overlay.remove();
                }
            }
        }
			
			</script>

			<script>
				function createDropDownButtonControl(div, config, paramsControl, optionsControl) {
					if (!div) div = $("<div>");
					else div = $(div);
					div[0].option = config;
					div.dxDropDownButton(div[0].option);
					if (paramsControl) {
						paramsControl[config.ControlNameParam] = div.dxDropDownButton("instance");
						if (config.Params)
							paramsControl[config.ControlNameParam].Params = config.Params;
					}
					if (optionsControl) optionsControl[config.ControlNameParam] = div[0].option;
					return div;
				}

				function runSPActionFunction(
					funcitonName = "",
					funcitonNameParam = "",
					classNameParam = "",
					spObject = {},
					actionSuccess = (a) => { },
					actionError = (a) => { }
				) {
					if (!funcitonNameParam) {
						funcitonNameParam = Object.keys(spObject).find(
							(x) => x.toLowerCase().replace("_", "") == "functionname"
						);
					}

					if (!classNameParam) {
						classNameParam = Object.keys(spObject).find(
							(x) => x.toLowerCase().replace("_", "") == "classname"
						);
					}

					let className = spObject[classNameParam];

					if (!funcitonName) funcitonName = spObject[funcitonNameParam];

					delete spObject[funcitonNameParam];
					delete spObject[classNameParam];

					CallMethod(funcitonName.toLowerCase()=="runjs" ? "" : className, funcitonName, Object.values(spObject));

					//AjaxHPAParadiseParadise({
					//	data: {
					//		name: funcitonName,
					//		param: Object.values(spObject),
					//	},

					//	success: function (resultData) {
					//		let jsonData =
					//			typeof resultData === "string" ? JSON.parse(resultData) : resultData;
					//		if (actionSuccess) actionSuccess(jsonData);
					//	},
					//	error: function (xhr, status, error) {
					//		if (actionError) actionError(error);
					//	},
					//});
				}

				async function runSPActionFunctionAsync(
					funcitonName = "",
					funcitonNameParam = "",
					classNameParam = "",
					spObject = {},
					actionSuccess = (a) => { },
					actionError = (a) => { }
				) {
					if (!funcitonNameParam) {
						funcitonNameParam = Object.keys(spObject).find(
							(x) => x.toLowerCase().replace("_", "") == "functionname"
						);
					}

					if (!classNameParam) {
						classNameParam = Object.keys(spObject).find(
							(x) => x.toLowerCase().replace("_", "") == "classname"
						);
					}

					let className = spObject[classNameParam];

					if (!funcitonName) funcitonName = spObject[funcitonNameParam];

					delete spObject[funcitonNameParam];
					delete spObject[classNameParam];

					CallMethod(funcitonName.toLowerCase()=="runjs" ? "" : className, funcitonName, Object.values(spObject));

					//await AjaxHPAParadiseParadiseAsync({
					//	data: {
					//		name: funcitonName,
					//		param: Object.values(spObject),
					//	},
					//	success: function (resultData) {
					//		let jsonData =
					//			typeof resultData === "string" ? JSON.parse(resultData) : resultData;
					//		if (actionSuccess) actionSuccess(jsonData);
					//	},
					//	error: function (xhr, status, error) {
					//		if (actionError) actionError(error);
					//	},
					//});
				}
		
		
			</script>
			<script>
				var shortcutMap = {};
				let pressedKeys = new Set();
				function loadShortcuts() {
					shortcutMap = {};

					$.each(ShortcutKeysList, function(index, shortcut) {
						shortcutMap[shortcut.ShortcutKeys.toUpperCase()] = shortcut.ClassName;
					});
				}
			loadShortcuts();
			$(document).on("keydown", function(event) {
			 if (event.repeat) return;
				if ($(".modal.show").length > 0 && isShortcutModeActive === true) {
						event.preventDefault();
						event.stopPropagation();
					return;
				}
				if ($(".modal.show").length > 0 && isShortcutModeActive === true && event.key === "F1") {
						event.preventDefault();
						event.stopPropagation();
					
					return;
				}
					
				
					if (event.ctrlKey) pressedKeys.add("CONTROL");
					if (event.altKey) pressedKeys.add("ALT");
					if (event.shiftKey) pressedKeys.add("SHIFT");
					pressedKeys.add(event.key.toUpperCase());
					 let keyCombination = Array.from(pressedKeys).join("+");
					
					if (shortcutMap[keyCombination]) {
						
						event.preventDefault();
						event.stopPropagation();
						openFormParam(shortcutMap[keyCombination], {
							EmployeeID: "-1",
							LoginID: "+cast(@LoginID as varchar(20))+",
							TableName: "-1",
							Isweb: 1
						});
					}
				});
		$(document).on("keyup", function(event) {
		let key = event.key.toUpperCase();
		pressedKeys.delete(key);
    if (key === "CONTROL" || key === "ALT" || key === "SHIFT") {
        pressedKeys.clear();
    }
});
				function updateShortcuts(newList) {
					ShortcutKeysList = newList;
					loadShortcuts();
				}
				    function addStyles(menuId) {
        const style = `
                <style>
                    #settingsModal-$ {
                        menuId
                    }



                    #settingsModal-$ {
                        menuId
                    }

                     #settingsModal-$ .modal-content {
   width: auto;
                        max-width: 200%;
                        margin: 0 auto;
                    }

                   .modal-backdrop {
                        z-index: 999 !important
       }

      .modal-dialog {
             z-index: 1 !important;
                    }

                     .modal-content {
                        z-index: 1 !important;
                    }


                     #settingsModal-$ .modal {
                  width: 700px

                 }

                     #settingsModal-$ .custom-list {
list-style: none;
                        padding-left: 20px;
                    }

                     #settingsModal-$ .custom-list li {
                        display: flex;
						align-items: center;
      gap: 10px;
           margin-bottom: 8px;
                        font-size: 16px;
                        user-select: text;
                        /* Cho phép chọn và copy */
                    }

                     #settingsModal-$ .custom-list i {
                        color: #007bff;
                        font-size: 16px;
                        flex-shrink: 0;

                        user-select: none;

                    }
                </style>
`;
        $(''head'').append(style);
    }
    function apiName(className) {
        const apiNamess = $(`#${className} script`)
            .toArray()
            .map(x => x.innerHTML)
            .join("\\p")
            .match(/AjaxHPAParadise\([\s\S]*?\)/g);

        if (!apiNamess || apiNamess.length === 0) {

            return [];
        }
        const apiNames = apiNamess
            .map(api => {
                const nameMatch = api.match(/name\s*:\s*[''''"]([^''''"]+)[''''"]/);
                return nameMatch ? nameMatch[1] : null;
            })
            .filter(name => name !== null)
            .filter((value, index, self) => self.indexOf(value) === index);
        return apiNames;
    }
	function apiNameWithDescription(apiNames, apiData) {
    if (!apiNames || !apiData) {
        console.error("Dữ liệu không hợp lệ!");
        return [];
    }

    return apiNames.map(api => {
        let matchedApi = apiData.find(item => item.ApiName === api);
        return { ApiName: api, Description: matchedApi?.Description || "" };
    });
}
    //Hiếu: tạo modal setting
    var isShortcutModeActive = false;
    let keysPressed = [];
    function createModalSetting(menuId, menuName, className) {
		
        addStyles(menuId);
        let apiNames = [] //apiName(className);

        //Hiếu: tìm phím tắt của tab đó
        let shortcut = ShortcutKeysList.find(s => s.MenuID === menuId);
        let shortcutText = shortcut ? "PHÍM TẮT HIỆN TẠI: " + shortcut.ShortcutKeys : "CHƯA THIẾT LẬP PHÍM TẮT";

        // Khởi tạo modalHtml
        let modalHtml = `
                <div style="background-color: rgba(0, 0, 0, 0.5) !important;" class="modal fade" id="settingsModal-${menuId}"
                    tabindex="-1" aria-labelledby="settingsModalLabel-${menuId}" aria-hidden="true" data-bs-backdrop="static"
                    data-bs-keyboard="false">
                    <div class="modal-dialog" style ="display: flex;align-items: center;  justify-content: center;
					min-height: 90vh;margin: 0 auto; max-width: 850px; width: 100%;
					">
                        <div class="modal-content">
                            <div class="modal-header">
                                <h5 class="modal-title" id="settingsModalLabel-${menuId}">${menuName}</h5>
                                <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                            </div>
                            <div class="modal-body">
                                <h6>Thông tin menu</h6>

									<ul class="custom-list" style="list-style: none; padding-left: 20px;">
										<li style="display: flex; align-items: center; gap: 10px; margin-bottom: 8px; font-size: 16px; user-select: text;">
											<i class="bi bi-gear" style="color: #007bff; font-size: 16px; flex-shrink: 0; user-select: none;"></i>
											<b>Tên menu:</b> <span class="copy-text">${menuName}</span>
										</li>
										<li style="display: flex; align-items: center; gap: 10px; margin-bottom: 8px; font-size: 16px; user-select: text;">
											<i class="bi bi-card-list" style="color: #007bff; font-size: 16px; flex-shrink: 0; user-select: none;"></i>
											<b>MenuID:</b> <span class="copy-text">${menuId}</span>
										</li>
										<li style="display: flex; align-items: center; gap: 10px; margin-bottom: 8px; font-size: 16px; user-select: text;">
											<i class="bi bi-folder" style="color: #007bff; font-size: 16px; flex-shrink: 0; user-select: none;"></i>
											<b>Tên thủ tục:</b> <span class="copy-text">${className}</span>
										</li>
									</ul>


							<h6>Thiết lập phím tắt</h6>
							<div class="shortcut-container" style="display: block; align-items: center; gap: 10px;">
								<button class="btn btn-primary mb-3" id="setShortcutBtn-${menuId}">Nhấn để thiết lập phím tắt</button>
								<button class="btn btn-danger mb-3 " id="delShortcutBtn-${menuId}" data-menu-id ="${menuId}">Hủy phím tắt</button>
								<p class="text-primary" style="margin-left: 10px" id="shortcutDisplay-${menuId}">
									${shortcutText.toUpperCase()}
								</p>
							</div>
							<div class="alert alert-warning d-flex align-items-center d-none" id="shortcutWarning-${menuId}" >
								Cảnh báo: Phím tắt này đã được sử dụng!
							</div>
							<div class="alert alert-success d-flex align-items-center d-none" id="shortcutSuccess-${menuId}">
								Ghi đè thành công!
							</div>


                                <div class="d-flex align-items-center justify-content-between mb-3">
                                    <h6 class="mb-0">Danh sách các API được sử dụng</h6>
                                    <input type="text" id="apiSearch-${menuId}" class="form-control" style="width: 200px;"
                                        placeholder="Tìm kiếm API">
                                </div>
                                <div id="api-all-${menuId}" class="api-all">
                    `;

					// Thêm các API vào modal
					apiNames.forEach((apiName, index) => {
						modalHtml += `
								<div class="api-list">
									<div class="api-item">
										<input type="text" class="form-control" id="api-${apiName}" value="${apiName}" readonly>
									</div>
									<div class="api-item">
										<input style="width: 222%;" type="text" class="form-control" id="func${apiName}"
											placeholder="Chức năng cho ${apiName}">
									</div>
								</div>
								`;
					});

					// Đóng div và modal
					modalHtml += `
										</div>
									</div>
								</div>
							</div>
							<style>
								#settingsModal-$ {
									menuId
								}

								.api-list {
									display: flex;
									gap: 120px;
								}

								#settingsModal-$ {
									menuId
								}

								.api-item {
									flex: 1;
								}

								#settingsModal-$ {
									menuId
								}

								.modal-content {
									width: 150%;
								}

								#settingsModal-$ {
									menuId
								}

								.api-all {
									display: flex;
									gap: 15px;
									flex-wrap: wrap;
									max-height: 300px;
									overflow-y: auto;
									padding-right: 15px;
								}

								#setShortcutBtn-$ {
									menuId
								}


								#settingsModal-$ {
									menuId
								}

								.shortcut-container {
									display: flex;
									align-items: center;
									padding: 20px 20px 0px 20px;
								}
							</style>

							`;

        $(`#dynamic-pane-${menuId}`).append(modalHtml);
		 let shortcutDisplay = $(`#shortcutDisplay-${menuId}`);
		let buttonDel = $(`#delShortcutBtn-${menuId}`);
        let tempShortcut;
		let shortCutCur;
        $(`#apiSearch-${menuId}`).on("input", function () {
  let searchTerm = $(this).val().toLowerCase();
       $(`#api-all-${menuId} .api-list`).each(function () {
                let apiName = $(this).find(".api-item input").first().val().toLowerCase();
                if (apiName.includes(searchTerm)) {

         $(this).show();
                } else {
              $(this).hide();
                }
            });
        });
	
    document.querySelectorAll(".custom-list span").forEach(span => {
        span.addEventListener("click", function () {
            let text = this.innerText.trim();
let tempTextarea = document.createElement("textarea");
            document.body.appendChild(tempTextarea);
            tempTextarea.value = text;
            tempTextarea.select();
            document.execCommand("copy");
            document.body.removeChild(tempTextarea);



        });
    });



	$(document).on("keydown", function (e) {
		if (e.key === "F1") {
			e.preventDefault();
			e.stopPropagation();

        const activeTab = $(".nav-link.active");
		
        if (activeTab.length > 0) {
            const tabId = activeTab.filter("button").attr("id");
			const menuIdd = tabId.split("-").pop();
			var APIListCur;
            if (tabId) {
			if(isShortcutModeActive === true){
				
				return
			}
                //Hiếu: danh danh sách phím tắt mới nhất
                AjaxHPAParadise({
                    data: {
                        name: "api_getShortKeys",
                        param: ["MenuID",menuIdd]
                    },
                    success: function (result) {
                        var data = JSON.parse(result).data[0][0];
						if(!data){
							buttonDel.hide();
						}else{
							buttonDel.show();
						}
                        //ShortcutKeysList = data;
                        shortcut = data //ShortcutKeysList.find(s => s.MenuID === menuId);
                        shortcutText = shortcut ? "PHÍM TẮT HIỆN TẠI: " + shortcut.ShortcutKeys : "CHƯA THIẾT LẬP PHÍM TẮT";
						shortCutCur = shortcut?.ShortcutKeys ?? null;
                        $(`#shortcutWarning-${menuIdd}`).addClass("d-none");
                        shortcutDisplay.text(shortcutText);
						tempShortcut = shortcutText;
						//gọi api để lấy mô tả danh sách api
						 AjaxHPAParadise({
							data: {
								name: "api_getApiDecription",
								param: [
									"MenuID", menuIdd,
								]
							},
							success: function (result) {
							 try {
								let parsedResult = JSON.parse(result);
								if (parsedResult?.data?.length > 0 && parsedResult.data[0]?.length > 0 && parsedResult.data[0][0]?.ApiList) {
									APIListCur = parsedResult.data[0][0].ApiList;
								} else {
									APIListCur = "[]";
								}
							} catch (error) {
								console.error("Lỗi khi parse JSON:", error);
								APIListCur = "[]"; // Gán rỗng khi lỗi parse JSON
							}
							apiNames = apiName(className);
						
						var APIListFull =  apiNameWithDescription(apiNames,JSON.parse(APIListCur))

                        let apiListHtml = "";
						if (APIListFull.length > 0) {
							APIListFull.forEach((api, index) => {
								apiListHtml += `
								<div class="api-list">
									<div class="api-item">
										<input style="width: 150%;" type="text" class="form-control" id="api-${api.ApiName}" value="${api.ApiName}" readonly>
									</div>
									<div class="api-item">
										<input style="width: 222%;" type="text" class="form-control" id="func-${api.ApiName}"
											placeholder="Thêm mô tả cho ${api.ApiName}" value="${api.Description}">

									</div>
								</div>
								`;
							});
						} else {
							apiListHtml += `
							<span class="text-secondary">Không có API được sử dụng trong menu</span>
							`;
						}

						 $(`#api-all-${menuId}`).html(apiListHtml);
                        $(`#settingsModal-${menuIdd}`).modal("show");
							}
						});
						

           }
                });
       }
   }
  }
});
	let buttontemp;

		 $(document).on("hidden.bs.modal", `#settingsModal-${menuId}`, function () {
			isShortcutModeActive = false;
			keysPressed = [];
			

			let btns = document.querySelectorAll(''[id^="setShortcutBtn-"].active'');

			if (btns.length > 0) {
				btns.forEach(btn => {


					
					btn.classList.remove("active");
					btn.textContent = "Nhấp để thiết lập phím tắt";
					btn.style.backgroundColor = "#0d6efd";
				});
			}


			saveApiData(menuId);
		});

		//Hiếu: lưu mô tả các api

		function saveApiData(menuId) {
    let apiData = [];

    $(`#api-all-${menuId} .api-item input`).each(function () {
        let id = $(this).attr("id");
        let value = $(this).val();

        if (id.startsWith("api-")) {
            apiData.push({ ApiName: id.replace("api-", ""), Description: "" });
        } else if (id.startsWith("func-")) {
            let apiName = id.replace("func-", "");
            let existingApi = apiData.find(api => api.ApiName === apiName);
            if (existingApi) {
                existingApi.Description = value;
            }
        }
    });

    AjaxHPAParadise({
        data: {
            name: "api_saveApiDecription",
            param: [
                "MenuID", menuId,
                "ApiList", JSON.stringify(apiData)
            ]
        },
        success: function (result) {
            var data = JSON.parse(result).data[0];
			
        }
    });
}


        $(`#setShortcutBtn-${menuId}`).click(function () {
  let menuId = $(this).attr("id").split("-")[1];
            let button = $(this);
			buttontemp = button;
            if (!isShortcutModeActive) {
                isShortcutModeActive = true;
                button.addClass("active").text("Đang thiết lập phím tắt...").css("background-color", "red");
                shortcutDisplay.text("");
                $(`#shortcutWarning-${menuId}`).hide();
                var ShortcutKeys;
                keysPressed = [];
                $(document).off("keydown.shortcut").on("keydown.shortcut", function (e) {
                    e.preventDefault();
                    e.stopPropagation();
                    let key = e.key.toUpperCase();
                    if (key !== "ESCAPE" && !keysPressed.includes(key) && keysPressed.length < 3) {
                        keysPressed.push(key);
                        shortcutDisplay.text(keysPressed.join(" + "));
                        ShortcutKeys = keysPressed.join(" +");
                    } else if (key === "ESCAPE") { keysPressed = []; shortcutDisplay.text(''''); }
					if (keysPressed.length >= 3) {
                        /*AjaxHPAParadise({
                            data: {
                                name: "api_saveShortKeys",
                                param: [
                                    "MenuID", menuId,
                                    "ShortcutKeys", ShortcutKeys
                                ]
                            },
                            success: function (result) {
                                var data = JSON.parse(result).data[0]
                                ShortcutKeysList = data
                                //Hiếu: cập nhật lại phím tắt khi save
                                updateShortcuts(ShortcutKeysList)
                                shortcut = ShortcutKeysList.find(s => s.MenuID === menuId);
                                shortcutText = shortcut ? "PHÍM TẮT HIỆN TẠI: " + shortcut.ShortcutKeys : "CHƯA THIẾT LẬP PHÍM TẮT";

                            }
                        });*/
                        $(document).off("keydown.shortcut");
                    }
                });
            } else {
			
                isShortcutModeActive = false;
				let warningElement = $(`#shortcutWarning-${menuId}`);
     $(document).off("keydown.shortcut");
             let foundMenu = null;
          button.removeClass("active").text("Nhấn để thiết lập phím tắt").css("background-color","#0d6efd");
                ShortcutKeys = keysPressed.join("+")
				if (ShortcutKeys === shortCutCur) {
					
       shortcutDisplay.text(shortcutText)
                    warningElement
					.html(`
						Cảnh báo: Phím tắt "${ShortcutKeys}" đã được sử dụng cho menu hiện tại, vui lòng chọn phím khác"!
					`)
					.removeClass("d-none")
					.show();

        return;
                }
                if (ShortcutKeys === "CONTROL+F") {
                     shortcutDisplay.text(shortcutText)
                    warningElement
					.html(`
						Cảnh báo: Phím tắt Ctrl+F đã được sử dụng cho chức năng tìm menu của hệ thống, vui lòng chọn phím kahc1!
					`)
					.removeClass("d-none")
					.show();


                    return;
                }

                if (ShortcutKeys === "F1") {
                    shortcutDisplay.text(shortcutText)
					 warningElement
					.html(`
						Phím tắt F1 đã được sử dụng cho chức năng phím tắt của hệ thống, vui lòng chọn phím khác!
					`)
					.removeClass("d-none")
					.show();


                    return;
                }
 '+@EmptyHtml+N'

			let foundMenuID = null;

			$.each(ShortcutKeysList, function (index, existingKeys) {
				if (existingKeys.ShortcutKeys === ShortcutKeys) {
				
					foundMenu = existingKeys.ContentVN;
					foundMenuID = existingKeys.MenuID;
					
					return false;
				}
			});

			if (foundMenuID) {
				let warningElement = $(`#shortcutWarning-${menuId}`);
				var tempContent = ShortcutKeysList.find(s => s.MenuID === foundMenuID).ContentVN;
				warningElement
					.html(`
						Cảnh báo: Phím tắt "${ShortcutKeys}" đã được sử dụng trong menu "${tempContent}"!
						<button class="btn btn-sm btn-warning ms-2 overwrite-btn"
								data-menu-id="${menuId}" data-found-id="${foundMenuID}" data-shortkey="${ShortcutKeys}">
							Ghi đè
						</button>
					`)
					.removeClass("d-none")
					.show();

    // Chỉ gán sự kiện khi nút đã được render ra DOM
    warningElement.find(".overwrite-btn").off("click").on("click", function () {
        let menuId = $(this).data("menu-id");
        let foundMenuID = $(this).data("found-id");
        let shortKeyCur = $(this).data("shortkey");

        AjaxHPAParadise({
            data: {
                name: "api_overwriteShortKeys",
                param: [
                    "MenuIDCur", menuId,
                    "MenuIDOld", foundMenuID,
                    "ShortKey", shortKeyCur
                ]
            },
            success: function (result) {
                var data = JSON.parse(result).data[0];
                ShortcutKeysList = data;

                // Hiếu: cập nhật lại phím tắt khi save
                updateShortcuts(ShortcutKeysList);
                shortcut = ShortcutKeysList.find(s => s.MenuID === menuId);
                shortcutText = shortcut ? "PHÍM TẮT HIỆN TẠI: " + shortcut.ShortcutKeys : "CHƯA THIẾT LẬP PHÍM TẮT";
                shortcutDisplay.text(shortcutText);
                tempShortcut = shortcutText;
				buttonDel.show();
                // Ẩn cảnh báo
                warningElement.addClass("d-none");
				let successAlert = $(`#shortcutSuccess-${menuId}`);
				successAlert.removeClass("d-none");

				// Ẩn sau 2 giây
				setTimeout(() => {
					successAlert.addClass("d-none");
				}, 1000);
   }
        });
    });

    return;
}

// Nếu không có phím trùng, ẩn cảnh báo
$(`#shortcutWarning-${menuId}`).addClass("d-none");


                if (keysPressed.length > 0) {
                    shortcutDisplay.text("PHÍM TẮT HIỆN TẠI: " + keysPressed.join(" + "));
                } else {
                    if (tempShortcut) {
      shortcutDisplay.text(tempShortcut)
     return;
        } else {
    shortcutDisplay.text("CHƯA THIẾT LẬP PHÍM TẮT")
               return
             }
                }
                AjaxHPAParadise({
                    data: {
                name: "api_saveShortKeys",
           param: [
                            "MenuID", menuId,
  "ShortcutKeys", ShortcutKeys
                        ]
                    },
                    success: function (result) {
           var data = JSON.parse(result).data[0]
                        ShortcutKeysList = data
                        //Hiếu: cập nhật lại phím tắt khi save
						buttonDel.show();
                        updateShortcuts(ShortcutKeysList)
                        shortcut = ShortcutKeysList.find(s => s.MenuID === menuId);
                        shortcutText = shortcut ? "PHÍM TẮT HIỆN TẠI: " + shortcut.ShortcutKeys : "CHƯA THIẾT LẬP PHÍM TẮT";
						tempShortcut = shortcut ? "PHÍM TẮT HIỆN TẠI: " + shortcut.ShortcutKeys : "";
					
                    }
                });
            }
        });

		//Hiếu:xóa phím tắt
		$(document).on("click", `[id^="delShortcutBtn-"]`, function (event) {
			let menuIdDel = $(this).data("menu-id");
			delShortCut(menuIdDel);
		});
		var delShortCut = (menuIdDel) =>{
			AjaxHPAParadise({
                            data: {
                                name: "api_delShortKeys",
                                param: [
                                    "MenuID", menuIdDel
                                ]
                            },
                            success: function (result) {
								 var data = JSON.parse(result).data[0]
								 //Hiếu: cập nhật lại phím tắt sau khi xóa
								 ShortcutKeysList = data
								 updateShortcuts(ShortcutKeysList);
                                 shortcut = ShortcutKeysList.find(s => s.MenuID === menuId);
                                 shortcutText = shortcut ? "PHÍM TẮT HIỆN TẠI: " + shortcut.ShortcutKeys : "CHƯA THIẾT LẬP PHÍM TẮT";
								 tempShortcut = "CHƯA THIẾT LẬP PHÍM TẮT";
								 shortcutDisplay.text(tempShortcut)
								 $(`#delShortcutBtn-${menuIdDel}`).hide();
								
                            }
                        });
		            }
                }
	
				window.currentTheme = document.documentElement.getAttribute("data-bs-theme") === "dark" ? "dark" : "light";

			if(UserID != 23)
			{
				
					$(''#launchpad'').fadeIn();
				
			}

			// Linh: Hàm control sửa input và textarea
			function hpaControlEditableRow(el, config) {
                const $el = $(el);
                // Simplified config: only requires tableName, columnName, idColumnName, idValue, displayId
                const cfg = {
                    type: config.type || "input",                             // "input" | "textarea"
                    tableName: config.tableName,                              // table to update
                    columnName: config.columnName,                            // column name to update
                    idColumnName: config.idColumnName,                        // ID column name (e.g., "TaskID")
                    idValue: config.idValue,                                  // ID value (e.g., taskId)
                    silent: config.silent || false,                           // suppress toast
                    allowAdd: config.allowAdd || false,                       // Có cho phép xóa hết text chuyển từ 
                    onSave: config.onSave || null,     // callback after save
                    language: config.language || "VN"
                };
                if (!cfg.columnName || !cfg.tableName || !cfg.idColumnName) return console.error("thiếu columnName, tableName, idColumnName");

                // Kiểm tra đã inject CSS chưa
                if (!window.__hpaEditableRowCSSInjected) {
                    const style = document.createElement("style");
                    style.textContent = `
                        .hpa-editable-row.control-editable {
                            cursor: pointer;
                            padding: 12px 6px;
                            border-radius: 4px;
                            transition: all 0.2s;
                            display: inline-block;
                            height: 100%;
                            width: 100%;
                        }
                        .hpa-editable-row.control-editable.editing {
                            padding: 4px 8px;
                            z-index: 100;
                            width: 100%;
                            height: 100%;
                        }
                        .hpa-editable-row.control-editable.editing input,
                        .hpa-editable-row.control-editable.editing textarea,
                        .hpa-editable-row.control-editable.editing select {
                            width: 100% !important;
                            min-width: 300px;
                            font-size: inherit;
                            font-weight: inherit;
                            padding: 6px 10px;
                            border: 1px solid #1c975e !important;
                        }
                        .hpa-editable-row.control-editable .edit-actions {
                            position: absolute;
                            top: 110%;
                            display: inline-flex;
                            gap: 4px;
                            margin-left: 6px;
                            align-items: center;
                        }
                        .hpa-editable-row.control-editable .btn-edit {
                            width: 28px;
                            height: 28px;
                            padding: 0;
                            display: inline-flex;
                            align-items: center;
                            justify-content: center;
                            border-radius: 4px;
                            border: 1px solid #e8eaed;
                            background: white;
                            cursor: pointer;
                            transition: all 0.2s;
                            font-size: 14px;
                        }
                        .hpa-editable-row.control-editable .btn-edit:hover {
                            transform: scale(1.1);
                        }
                        .hpa-editable-row.control-editable .btn-edit.btn-save {
                            background: #2E7D32;
                            color: white;
                            border-color: #2E7D32;
                        }
                        .hpa-editable-row.control-editable .btn-edit.btn-save:hover {
                            background: #1c975e;
                        }
                        .hpa-editable-row.control-editable .btn-edit.btn-cancel {
                            background: #fff;
                            color: #676879;
                        }
                        .hpa-editable-row.control-editable .btn-edit.btn-cancel:hover {
                            background: #f5f5f5;
                            color: #E53935;
                        }
                    `;
                    document.head.appendChild(style);
                    window.__hpaEditableRowCSSInjected = true;
                }

                $el.addClass("hpa-editable-row control-editable")
                    .off("click.control-editable")
                    .on("click.control-editable", function (e) {
                        e.stopPropagation();
                        e.preventDefault();

                        $(".hpa-editable-row.control-editable.editing").each(function () {
                            if (this !== $el[0]) {
                                $(this).find(".btn-save").trigger("click");
                            }
                        });

                        if ($el.hasClass("editing")) return false;

                    const curVal = $el.text().trim();
                    let $input;

                    if (cfg.type === "textarea") {
                        $input = $("<textarea class=\"form-control form-control-sm\" rows=\"3\">").val(curVal);
                    } else {
                        $input = $("<input type=\"text\" class=\"form-control form-control-sm\">").val(curVal);
                    }

                    let isAddMode = false;
                    let recordId = cfg.idValue;

                    const $save = $("<button class=\"btn-edit btn-save\" title=\"Lưu\"><i class=\"bi bi-check-lg\"></i></button>");
                    const $cancel = $("<button class=\"btn-edit btn-cancel\" title=\"Hủy\"><i class=\"bi bi-x-lg\"></i></button>");

                    const updateButtonState = () => {
                        const isEmpty = !$input.val() || $input.val().trim().length === 0;

                        // Chỉ cho phép chuyển sang add mode khi cfg.allowAdd = true
                        if (cfg.allowAdd && isEmpty && !isAddMode) {
                            isAddMode = true;
                            recordId = null;
                            $save.html(`<i class="bi bi-plus-lg"></i>`).attr("title", "Thêm");
                        }
                    };


                    const $actions = $("<div class=\"edit-actions\"></div>").append($save).append($cancel);
                    const $wrap = $("<div class=\"d-flex align-items-end gap-1 w-100 flex-column position-relative\"></div>").append($input).append($actions);
                    $el.addClass("editing").html("").append($wrap);

                    setTimeout(() => {
                        const el = $input[0];
                        el.focus();
                        const len = el.value.length;
                        el.setSelectionRange(len, len);   // đặt con trỏ cuối
                    }, 50);

                    const finish = (saveIt) => {
                        const newVal = $input.val().trim();

                        $save.off("click");
                        $cancel.off("click");
                        $input.off("click keydown input");
                        $(document).off("click.hpaEditable");

                        $el.removeClass("editing").off("keydown");
                        if (!saveIt || (newVal === curVal && !isAddMode)) {
                            $el.text(curVal);
                            return;
                        }

                        const params = [
                            "LoginID", LoginID,
                            "LanguageID", cfg.language,
                            "TableName", cfg.tableName,
                            "ColumnName", cfg.columnName,
                            "IDColumnName", cfg.idColumnName,
                            "ColumnValue", newVal,
                            "ID_Value", recordId
                        ];

                        AjaxHPAParadise({
                            data: { name: "sp_Common_SaveDataTable", param: params },
                            success: () => {
                                const display = newVal;
                                $el.text(display);
                                if (cfg.silent) uiManager.showAlert({ type: "success", message: isAddMode ? "%AddSuccess%" : "%UpdateSuccess%" });
                                if (cfg.onSave) cfg.onSave(newVal, isAddMode, recordId);
                            },
                            error: () => {
                            uiManager.showAlert({ type: "error", message: "Lưu thất bại!" });
                                $el.text(curVal);
                            }
                        });
                    };

                    $save.on("click", function(e) {
                        e.stopPropagation();
                        $(document).off("click.hpaEditable");
                        finish(true);
                    });

                    $cancel.on("click", (e) => { e.stopPropagation(); e.preventDefault(); finish(false); return false; });
                    $input.on("input", updateButtonState);
                    $input.on("keydown", (e) => {
                        if (e.key === "Enter" && cfg.type !== "textarea") { e.preventDefault(); finish(true); }
                        if (e.key === "Escape") finish(false);
                    });
                    $(document).one("click.hpaEditable", (e) => {
                        if (!$(e.target).closest($el).length) finish(true);
                    });
                });
            }
			
			</script>

			'+isnull(@HtmlLanguage,'')+'
			'

END;


--declare @dataHtml nvarchar(max) = '';
--exec HtmlDashboard @Html = @dataHtml

--select @dataHtml
GO

declare @dataHtml nvarchar(max) = '';
exec HtmlDashboard @Html = @dataHtml