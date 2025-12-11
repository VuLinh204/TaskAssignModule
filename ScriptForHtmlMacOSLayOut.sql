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
				// Simplified config
				const cfg = {
					type: config.type || "input",
					tableName: config.tableName,
					columnName: config.columnName,
					idColumnName: config.idColumnName,
					idValue: config.idValue,
					silent: config.silent || false,
					allowAdd: config.allowAdd || false,
					onSave: config.onSave || null,
					language: config.language || "VN",
					width: config.width
				};

				if (!cfg.columnName || !cfg.tableName || !cfg.idColumnName) return console.error("thiếu columnName, tableName, idColumnName");

				// Kiểm tra đã inject CSS chưa
				if (!window.__hpaEditableRowCSSInjected) {
					const style = document.createElement("style");
					style.textContent = `
						.hpa-editable-row.control-editable {
							cursor: pointer;
							padding: 8px 4px;
							border-radius: 4px;
							transition: all 0.2s;
							display: inline-block;
							vertical-align: middle;
							box-sizing: border-box;
						}
						.hpa-editable-row.control-editable.editing {
							padding: 4px 8px;
							z-index: 100 !important;
						}
						.hpa-editable-row.control-editable.editing input,
						.hpa-editable-row.control-editable.editing textarea,
						.hpa-editable-row.control-editable.editing select {
							width: 100% !important;
							font-size: inherit;
							font-weight: inherit;
							padding: 6px 10px;
							border: 1px solid #1c975e !important;
							box-sizing: border-box;
						}
						.hpa-editable-row.control-editable .edit-actions {
							position: absolute;
							top: 110%;
							display: inline-flex;
							gap: 4px;
							margin-left: 6px;
							align-items: center;
							z-index: 100 !important;
							right: 0;
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

				$el.addClass("hpa-editable-row control-editable");

				if (cfg.width) {
					$el.css({
						"width": cfg.width,
						"min-width": cfg.width
					});

					// Nếu là view mode (không phải textarea), có thể thêm cắt dòng nếu muốn gọn
					if (cfg.type !== "textarea") {
						$el.css({
							"white-space": "nowrap",
							"overflow": "hidden",
							"text-overflow": "ellipsis"
						});
					}
				}

				$el.off("click.control-editable")
					.on("click.control-editable", function (e) {
						$(".hpa-editable-row.editing, .hpa-editable-row-number.editing").not($el).find(".btn-save").trigger("click");
						if ($(".hpa-editable-row-date.editing-date, .hpa-editable-row-time.editing-time").not($el).length > 0) {
							$("body").trigger("click");
						}
						e.stopPropagation();
						e.preventDefault();

						// Đóng các ô đang sửa khác
						$(".hpa-editable-row.control-editable.editing").each(function () {
							if (this !== $el[0]) {
								$(this).find(".btn-save").trigger("click");
							}
						});

						if ($el.hasClass("editing")) return false;

						const curVal = $el.text().trim();

						// Khi vào chế độ sửa, tạm thời bỏ overflow hidden để nút bấm không bị che
						if (cfg.width) $el.css("overflow", "visible");

						let $input;

						// [NOTE] Sử dụng ngoặc kép " " cho attribute HTML để tránh lỗi SQL
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

							if (cfg.allowAdd && isEmpty && !isAddMode) {
								isAddMode = true;
								recordId = null;
								$save.html("<i class=\"bi bi-plus-lg\"></i>").attr("title", "Thêm");
							}
						};

						const $actions = $("<div class=\"edit-actions\"></div>").append($save).append($cancel);
						// position-relative để nút bấm bám theo div cha
						const $wrap = $("<div class=\"d-flex align-items-end gap-1 w-100 flex-column position-relative\"></div>").append($input).append($actions);

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

							// [UPDATE 3] Trả lại style overflow nếu có width sau khi sửa xong
							if (cfg.width && cfg.type !== "textarea") {
								$el.css("overflow", "hidden");
							}

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

							// [NOTE] AjaxHPAParadise call
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

            // Linh: Hàm control Selectbox + Combobox
            function hpaControlField(el, config) {
                const $el = $(el);
                if (!$el.length) return null;

                config = config || {};
                const cfg = {
                    // -- OPTION BẬT SEARCH INPUT
                    searchable: config.hasOwnProperty("searchable") ? !!config.searchable : (!!config.useApi === true),
                    placeholder: config.placeholder || "Chọn...",
                    searchMode: config.searchMode || "local", // -- Mode tìm kiếm bằng api hay local  "api" | "local"

                    multi: !!config.multi,  // -- OPTION bật checkbox để chọn nhiều
                    options: config.options || config.staticOptions || [],  // -- Mảng các options mặc định có sẵn
                    selected: config.selected,  // -- Selected vô item nào

                    useApi: !!config.useApi,  // -- Có bật load dữ liệu bằng Api hay không
                    ajaxListName: config.ajaxListName || null, // -- Thủ tục load lên dữ liệu (Phải xem các mẫu có sẵn)
                    take: typeof config.take === "number" ? config.take : (config.useApi ? 20 : (config.take || 200)), // -- Lấy lên bao nhiêu item 1 lượt
                    skip: typeof config.skip === "number" ? config.skip : 0, // -- Bỏ qua và lấy item từ vị trí thứ bnhieu
                    dataSource: config.dataSource || null, // -- Mảng dữ liệu từ 1 nguồn có sẵn (Chưa thiết kế)

                    silent: config.silent !== false, // -- Mode bật thông báo

                    // -- CÁC OPTIONS cho việc lưu dữ liệu vào đâu
                    tableName: config.tableName || null,
                    columnName: config.columnName || config.field || null,
                    idColumnName: config.idColumnName || null,
                    idValue: config.idValue || null,

                   onChange: config.onChange || null, // -- Action khi thay đổi (Tùy chỉnh)

                    ajaxGetCombobox: !!config.ajaxGetCombobox, // -- Bật load dữ liệu từ bảng đã có
                    sourceTableName: config.sourceTableName || null, // -- Tên bảng load dữ liệu và thêm sửa trực tiếp bảng đó
                    sourceColumnName: config.sourceColumnName || null, // -- Tên cột cần thêm
                    sourceIdColumnName: config.sourceIdColumnName || null,
                    whereClause: config.whereClause || "", // -- Vị trí lấy

                    // -- CÁC OPTIONS HỖ TRỢ XỬ LÝ NHIỀU CỘT
                    columns: config.columns || null,
                    displayTemplate: config.displayTemplate || null,
                    searchColumns: config.searchColumns || null,
                    valueField: config.valueField || null,
                    textField: config.textField || null
                };

                // ===== STATE VARIABLES =====
                let _fetchedItems = [];
                let _fetchedMap = Object.create(null);
                let _hasMore = true;
                let _lastFilter = null;
                let _currentSkip = 0;
                let loadingMore = false;
                let _initialized = false;
                let _renderedCount = 0; // Số items đã render

                let selected = Array.isArray(config.selectedValues) ? config.selectedValues.map(String) : (config.selected !== undefined ? (Array.isArray(config.selected) ? config.selected.map(String) : [String(config.selected)]) : []);

                // Đọc option từ <select> cũ nếu có
                try {
                    if ((!cfg.options || cfg.options.length === 0) && $el.length) {
                        if ($el.is("select")) {
                            const domOpts = [];
                            $el.find("option").each(function () { domOpts.push({ value: $(this).attr("value"), text: $(this).text() }); });
                            if (domOpts.length) cfg.options = domOpts;
                            if ((!selected || selected.length === 0) && $el.val() !== undefined && $el.val() !== null) {
                                const val = $el.val();
                                selected = Array.isArray(val) ? val.map(String) : (val ? [String(val)] : []);
                            }
                        }
                    }
                } catch (e) {}

                // CSS
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

                function escapeHtml(s) { if (s === null || s === undefined) return ""; return String(s).replace(/&/g, "&amp;").replace(/</g, "&lt;").replace(/>/g, "&gt;").replace(/""/g, "&quot;").replace(/"/g, "&#039;"); }

                function debounce(fn, wait) {
                    let timer = null;
                    return function () {
                        const ctx = this, args = arguments;
                        if (timer) clearTimeout(timer);
                        timer = setTimeout(() => { fn.apply(ctx, args); timer = null; }, wait);
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
                        return cfg.searchColumns.some(col => textMatches(item[col]));
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
                            const opt = _fetchedItems.find(o => String(getItemValue(o)) === String(v)) || (cfg.options || []).find(o => String(o.value) === String(v));
                            $t.text(opt ? getItemText(opt) : v);
                        }
                    } else {
                        if (!selected || selected.length === 0) {
                            $t.html(`<span class="hpa-field-placeholder">${escapeHtml(cfg.placeholder)}</span>`);
                        } else {
                            const texts = selected.map(id => {
                                const o = _fetchedItems.find(x => String(getItemValue(x)) === String(id)) || (cfg.options || []).find(x => String(x.value) === String(id));
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
                        const item = _fetchedItems.find(x => String(getItemValue(x)) === val);
                        cfg.onChange(cfg.multi ? selected.slice() : (selected[0] || null), item);
                    }
                    try { saveToDB(cfg.multi ? selected : selected[0] || null); } catch (e) {}
                }
                function selectSingle(val) {
                    selected = val === undefined || val === null ? [] : [String(val)];
                    renderDisplay();
                    if (typeof cfg.onChange === "function") {
                        const item = _fetchedItems.find(x => String(getItemValue(x)) === val);
                        cfg.onChange(selected[0] || null, item);
                    }
                    try { saveToDB(cfg.multi ? selected : selected[0] || null); } catch (e) {}
                    closeDropdown();
                }
                function defaultCreateNew(keyword){
                    return new Promise(function(resolve, reject){
                        const kw = String(keyword||"").trim();
                        if (!kw) return reject(new Error("Empty keyword"));
                        const params = [];
                        params.push("LoginID"); params.push(window.LoginID||0);
                        params.push("LanguageID"); params.push(typeof LanguageID !== "undefined" ? LanguageID : "VN");
                        params.push("TableName"); params.push(cfg.sourceTableName || cfg.tableName || "");
                        params.push("ColumnName"); params.push(cfg.sourceColumnName || cfg.columnName || cfg.field || "");
          params.push("IDColumnName"); params.push(cfg.sourceIdColumnName || cfg.idColumnName || "ID");
                        params.push("ColumnValue"); params.push(kw);
                        AjaxHPAParadise({
                            data: { name: "sp_Common_SaveDataTable", param: params },
                            success: function(res){
                                try{
                                    const json = typeof res === "string" ? JSON.parse(res) : res;
                                    let newId = null;
                                    if (json && json.data && Array.isArray(json.data) && json.data.length > 0) {
                                        let firstRow = json.data[0];
                                        if (Array.isArray(firstRow) && firstRow.length > 0) {
                                            const firstItem = firstRow[0];
                                            if (typeof firstItem === "object" && firstItem !== null) {
                                                newId = firstItem.ID || firstItem.NewID || firstItem.IDValue || null;
                                            } else {
                                                newId = firstItem; // fallback cho mảng thô
                                            }
                                        } else if (typeof firstRow === "object" && firstRow !== null) {
                                            newId = firstRow.ID || firstRow.NewID || firstRow.IDValue || null;
                                        }
                                    }
                                    resolve({ value: newId || null, text: kw });
                                }catch(e){
                                    console.error("Parse ID error:", e);
                                    resolve({ value: null, text: kw });
                                }
                            },
                            error: function(){ reject(new Error("Ajax Error")); }
                        });
                    });
                }
                function handleNewItem(newItem) {
                    // Tạo object item chuẩn
                    const standardItem = cfg.columns ? newItem : {
                        value: newItem.value,
                        text: newItem.text,
                        ID: newItem.value,
                        Name: newItem.text,
                        ...newItem
                    };

                    const itemValue = String(getItemValue(standardItem));

                    // Thêm vào đầu cache
                    if (!_fetchedMap[itemValue]) {
                        _fetchedMap[itemValue] = true;
                        _fetchedItems.unshift(standardItem); // unshift = thêm vào đầu
                    }

                    // Thêm vào static options (khởi tạo nếu chưa có)
                    if (!cfg.options) cfg.options = [];
                    cfg.options.unshift(standardItem);

                    // Selected item mới
                    if (cfg.multi) {
                        if (!selected.includes(itemValue)) {
                            selected.push(itemValue);
                        }
                    } else {
                        selected = [itemValue];
                    }

                    // Render lại display
                    renderDisplay();

                    // Gọi onChange callback
                    if (typeof cfg.onChange === "function") {
                        cfg.onChange(cfg.multi ? selected.slice() : (selected[0] || null), standardItem);
                    }

                    // Lưu vào DB
                    try {
                        saveToDB(cfg.multi ? selected : selected[0] || null);
       } catch (e) {}

                    // Clear cache API nếu cần
                    if (cfg.useApi && cfg.ajaxListName) {
                        AjaxHPAParadise({
                            data: {
                                name: "sp_ClearTableCacheForControlField",
                                param: ["@ProcName", cfg.ajaxListName, "@LoginID", window.LoginID || 0, "@LanguageID", typeof LanguageID !== "undefined" ? LanguageID : "VN"]
                            },
                            success: () => {
                            }
                        });
                    }

                    closeDropdown();
                }
                // ==================== FETCH PAGE ====================
                function fetchPage(filterVal, skipVal, isAddFlag = false) {
                    return new Promise((resolve, reject) => {
                        if (cfg.ajaxGetCombobox) {
                            const p = [
                                "@LoginID", window.LoginID || 0,
                                "@LanguageID", typeof LanguageID !== "undefined" ? LanguageID : "VN",
                                "@TableName", cfg.sourceTableName || cfg.tableName || "",
                                "@ColumnName", cfg.sourceColumnName || cfg.textField || "Name",
                                "@IDColumnName", cfg.sourceIdColumnName || cfg.valueField || "ID",
                                "@WhereClause", cfg.whereClause || ""
                            ];

                            AjaxHPAParadise({
                                data: { name: "sp_Common_GetComboBox", param: p },
                                success: res => {
                                    try {
                                        const json = typeof res === "string" ? JSON.parse(res) : res;
                                        let rows = json?.data?.[0] || [];

                                        if (filterVal) {
                                            const search = filterVal.toLowerCase();
                                            rows = rows.filter(x => {
                                                const name = x.Name || x[cfg.textField] || "";
                                                return String(name).toLowerCase().includes(search);
                                            });
                                        }

                                        const start = skipVal || 0;
                                        const end = start + cfg.take;
                                        const paginatedRows = rows.slice(start, end);

                                        const mapped = paginatedRows.map(x => {
                                            if (cfg.columns) return x;
                                            return {
                                                value: x.ID || x[cfg.valueField],
                                                text: x.Name || x[cfg.textField],
                                                ...x
                                            };
                                        });

                                        mapped._totalCount = rows.length;
                                        resolve(mapped);
                                    } catch (err) { reject(err); }
                                },
                                error: () => reject(new Error("Ajax Error"))
                            });
                            return;
                        }

                        const p = [
                            "@ProcName", cfg.ajaxListName,
                            "@Take", cfg.take,
                       "@Skip", skipVal || 0,
                            "@SearchValue", filterVal || "",
                            "@ColumnSearch", cfg.searchColumns ? cfg.searchColumns.join(",") : "",
                            "@LanguageID", typeof LanguageID !== "undefined" ? LanguageID : "VN",
                            "@IsAdd", isAddFlag ? 1 : 0
                        ];

                        AjaxHPAParadise({
                            data: { name: "sp_LoadGridUsingAPI", param: p },
                            success: res => {
                                try {
                                    const json = typeof res === "string" ? JSON.parse(res) : res;
                                    const rows = json?.data?.[0] || [];
                                    const mapped = cfg.columns ? rows : rows.map(x => ({
                                        value: x.TaskID || x.EmployeeID || x.ID || x.value,
                                        text: x.TaskName || x.FullName || x.Name || x.text,
                                        ...x
                                    }));
                                    resolve(mapped);
                                } catch (err) { reject(err); }
                            },
                            error: () => reject(new Error("Ajax Error"))
                        });
                    });
                }
                function addToCache(list) {
                    list.forEach(it => {
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
                // ==================== BACKGROUND PRELOAD ALL DATA ====================
                function backgroundPreloadAll() {
                    if (!cfg.useApi || (!cfg.ajaxListName && !cfg.ajaxGetCombobox)) return;
                    if (cfg.searchMode === "api") return; // Không preload nếu dùng API search

                    let skipCount = _currentSkip;

                    function loadNextBatch() {
                        if (!_hasMore) {
                            return;
                        }

                        fetchPage("", skipCount).then(data => {
                            const totalCount = data._totalCount;
                            delete data._totalCount;

                            if (!data.length) {
                                _hasMore = false;
                                return;
                            }

                            // Merge vào cache (không render)
                            let newCount = 0;
                            data.forEach(it => {
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
                        }).catch(err => {
                            console.error("Background preload error:", err);
                        });
                    }

                    // Bắt đầu load sau 500ms (để UI render xong)
                    setTimeout(loadNextBatch, 500);
                }
     // ==================== INITIAL API LOAD ====================
                function initialApiLoad(filter) {
                    showLoading();

                    fetchPage(filter, 0).then(data => {
                        const totalCount = data._totalCount;
                        delete data._totalCount;

                        const actualSearchMode = getActualSearchMode();
                        let renderItems;

                        if (actualSearchMode === "local") {
                            data.forEach(it => {
                                const val = getItemValue(it);
                                if (!_fetchedMap[val]) {
                                    _fetchedMap[val] = true;
                                    _fetchedItems.push(it);
                                }
                            });

                            let filteredItems = _fetchedItems;
                            if (filter) {
                                filteredItems = _fetchedItems.filter(item => itemMatchesSearch(item, filter));
                            }

                            // Sắp xếp: Đưa selected lên đầu
                            const selectedSet = new Set(selected.map(String));
                            const selectedItems = [];
                            const otherItems = [];
                            filteredItems.forEach(item => {
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
                            _fetchedItems.forEach(it => _fetchedMap[getItemValue(it)] = true);

                            // Sắp xếp: Đưa selected lên đầu
                            const selectedSet = new Set(selected.map(String));
                            const selectedItems = [];
                            const otherItems = [];
                            _fetchedItems.forEach(item => {
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
                    }).catch(() => showError("Lỗi kết nối"));
                }
                // ==================== LOAD MORE (Render thêm items) ====================
                function loadMoreRender(list) {
                    const BATCH_SIZE = 20;
                    const startIdx = _renderedCount;
                    const endIdx = Math.min(startIdx + BATCH_SIZE, list.length);
                    const batch = list.slice(startIdx, endIdx);

                    if (batch.length === 0) return;

                    batch.forEach(o => {
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
                                cfg.columns.forEach(col => {
                                    colRow.append(`<div class="hpa-field-column-cell" style="width:${col.width || "auto"}">${escapeHtml(o[col.field] || "")}</div>`);
                                });

                                row.find("input").on("change", () => toggleValue(val, row.find("input").is(":checked")));
                                itemsContainer.append(row);
                            } else {
                                const row = $(`<div class="hpa-field-item ${isSel ? "selected" : ""}" data-value="${val}">
                                    <div class="hpa-field-column-row" style="width:100%;"></div>
                                </div>`);

                                const colRow = row.find(".hpa-field-column-row");
                                cfg.columns.forEach(col => {
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
                // ==================== SCROLL HANDLER ====================
                dropdown.on("scroll", function() {
                    const el = this;
                    if (el.scrollHeight - (el.scrollTop + el.clientHeight) <= 100) {
                        // Lấy filter từ inline search
                        const $inlineSearch = display.find(".hpa-field-inline-search");
                        const curFilter = $inlineSearch.length ? ($inlineSearch.val() || "") : "";

                        // Tìm list hiện tại đang hiển thị
                        let currentList = _fetchedItems;
                        if (curFilter) {
                            currentList = _fetchedItems.filter(item => itemMatchesSearch(item, curFilter));
                        }

                        // Nếu còn items chưa render thì render tiếp
                        if (_renderedCount < currentList.length) {
                            loadMoreRender(currentList);
                        }
                    }
                });
                // ==================== RENDER LIST ====================
                function renderList(list, append) {
                    if (!append) {
                        itemsContainer.empty();
                        _renderedCount = 0;

                        if (cfg.columns && cfg.columns.length) {
                            const headerRow = $(`<div class="hpa-field-column-header"></div>`);
                            cfg.columns.forEach(col => {
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
                // ==================== RENDER CREATE ROW ====================
                function renderCreateRow(filter) {
                    const keyword = String(filter || "").trim();
                    if (!keyword) return;

                    const row = $(`<div class="hpa-field-item hpa-field-create-row" style="font-weight:600;color:var(--task-primary);cursor:pointer;">
                        Thêm mới: <span style="margin-left:6px;opacity:0.95;">${escapeHtml(keyword)}</span>
                    </div>`);

                    row.on("click", () => {
                        row.css("opacity", 0.6).text("Đang tạo...");
                        defaultCreateNew(keyword).then(newItem => {
                            row.css("opacity", 1).text("Thêm mới: " + keyword);
                            handleNewItem(newItem);
                        }).catch(() => {
                            row.css("opacity", 1).text("Thêm mới: " + keyword);
                            uiManager?.showAlert?.({ type: "error", message: "Tạo thất bại" });
                        });
                    });

                    itemsContainer.prepend(row);
                }
                // ==================== RENDER DROPDOWN ====================
                function renderDropdown(filter, appendMode) {
                    if (filter === undefined || filter === null) {
                        const $inlineSearch = display.find(".hpa-field-inline-search");
                        filter = $inlineSearch.length ? ($inlineSearch.val() || "") : "";
                    }

                    const q = (filter || "").toLowerCase();
                    const actualSearchMode = getActualSearchMode();

                    // ===== LOCAL SEARCH MODE =====
                    if (actualSearchMode === "local") {
                        if (!appendMode) itemsContainer.empty();

                        // Merge cả _fetchedItems (items được tạo mới) và cfg.options
                        let allItems = [..._fetchedItems];
                        (cfg.options || []).forEach(opt => {
                            const val = getItemValue(opt);
                            if (!_fetchedMap[val]) {
                                allItems.push(opt);
                            }
                        });

                        let filteredOpts = allItems;
                        if (q) {
                            filteredOpts = allItems.filter(o => itemMatchesSearch(o, q));
                        }

                        // ĐƯA SELECTED LÊN ĐẦU
                        const selectedSet = new Set(selected.map(String));
                        const selectedItems = [];
                        const otherItems = [];
                        filteredOpts.forEach(item => {
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
                                filteredItems = _fetchedItems.filter(item => itemMatchesSearch(item, q));
                            }

                            // ĐƯA SELECTED LÊN ĐẦU — giống như trong initialApiLoad
                            const selectedSet = new Set(selected.map(String));
                            const selectedItems = [];
                            const otherItems = [];
                            filteredItems.forEach(item => {
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
                        filteredOpts = filteredOpts.filter(o => itemMatchesSearch(o, q));
                    }

                    renderList(filteredOpts, false);

                    if (q) {
                        renderCreateRow(filter);
                    }
                }
                function saveToDB(val) {
                    if (!cfg.tableName || !cfg.idValue) return;
                    AjaxHPAParadise({
                        data: {
                            name: "sp_Common_SaveDataTable",
                            param: [
                                "LoginID", window.LoginID || 0,
                                "LanguageID", typeof LanguageID !== "undefined" ? LanguageID : "VN",
                                "TableName", cfg.tableName,
                                "ColumnName", cfg.columnName,
                                "IDColumnName", cfg.idColumnName || "ID",
                                "ColumnValue", cfg.multi ? (val || []).join(",") : (val || ""),
                                "ID_Value", cfg.idValue
                            ]
                        },
                        success: () => {
                            if (!cfg.silent) uiManager?.showAlert?.({ type: "success", message: "%UpdateSuccess%" });
                        }
                    });
                }
                // ==================== CLICK HANDLER - INLINE SEARCH ====================
                display.on("click", e => {
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
                        const debouncedRender = debounce(val => renderDropdown(val, false), 500);
                        $inlineSearch.on("input", function () {
                            debouncedRender($(this).val() || "");
                        });
                    }

                    // Xử lý phím tắt
                    $inlineSearch.on("keydown", function(e) {
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
                $(document).on("click.hpaField", e => {
                    if (!wrapper.is(e.target) && wrapper.has(e.target).length === 0) closeDropdown();
                });
                // Render display ban đầu
                renderDisplay();

                // ==================== PUBLIC API ====================
                return {
                    setValue(v) {
                        selected = cfg.multi ? (Array.isArray(v) ? v.map(String) : (v ? [String(v)] : [])) : (v ? [String(v)] : []);
                        renderDisplay();
                        saveToDB(cfg.multi ? selected : selected[0] || null);
                    },
                    getValue() {
                        return cfg.multi ? selected.slice() : (selected[0] || null);
                    },
                    getSelectedItem() {
                        if (!selected.length) return null;
                        const id = selected[0];
                        return _fetchedItems.find(x => String(getItemValue(x)) === String(id));
                    },
                    getText() {
                        if (!selected.length) return null;
                        const id = selected[0];
                        const o = _fetchedItems.find(x => String(getItemValue(x)) === String(id)) || (cfg.options || []).find(x => String(x.value) === String(id));
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
                    }
                };
            }

			// Linh: Control chọn nhân viên dạng dropdown với DevExtreme Grid
            function hpaControlEmployeeSelector(el, config) {
                const $el = $(el);
                if (!$el.length) return null;

                // ===== CONFIG DEFAULTS =====
                const defaults = {
                    // Hiển thị
                    containerId: null,
                    dropdownId: null,
                    placeholder: "Chọn nhân viên",
                    maxVisibleChips: 3,
                    avatarWidth: 32,
                    avatarHeight: 32,
                    width: 350,
                    height: 400,
                    showAvatar: true,
                    
                    // Dữ liệu
                    ajaxListName: "EmployeeListAll_DataSetting_Custom",
                    selectedIds: [],
                    apiData: null, // Nếu có data sẵn thì không cần gọi API
                    useApi: true,
                    
                    // Phân trang
                    pageSize: 10,
                    take: 10,
                    skip: 0,
                    
                    // Chức năng
                    multi: true,
                    searchable: true,
                    
                    // Lưu trữ
                    tableName: null,
                    columnName: null,
                    idColumnName: null,
                    idValue: null,
                    silent: true,
                    
                    // Callbacks
                    onChange: null
                };
                
                const cfg = { ...defaults, ...config };
                
                // Tạo unique IDs nếu chưa có
                const uniqueId = `emp-dropdown-${Date.now()}-${Math.random().toString(36).substr(2, 9)}`;
                cfg.containerId = cfg.containerId || `${uniqueId}-container`;
                cfg.dropdownId = cfg.dropdownId || `${uniqueId}-dropdown`;
                
                // ===== STATE VARIABLES =====
                const SVG_PLACEHOLDER = "data:image/svg+xml,%3Csvg xmlns=%22http://www.w3.org/2000/svg%22 viewBox=%220 0 100 100%22%3E%3Ccircle cx=%2250%22 cy=%2250%22 r=%2250%22 fill=%22%23e0e0e0%22/%3E%3C/svg%3E";
                const avatarCache = {};
                let allEmployees = [];
                let selectedIds = [...cfg.selectedIds].map(String);
                let dataGridInstance = null;
                let totalCount = 0;
                let currentSkip = 0;
                let isLoadingApiData = false;
                // Queue to ensure API calls are executed sequentially
                let apiQueue = Promise.resolve();
                // Cache for selected-only load: ensures one batched request
                let selectedLoaded = false;
                let selectedLoadPromise = null;
                let selectedCache = [];
                let currentSearchText = "";
                let snapshotEmployees = [];
                let isGridInitializing = true;
                
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
                        }
                        
                        .hpa-emp-dropdown-container {
                            display: none;
                            position: absolute;
                            z-index: 3000;
                            border: 1px solid #dee2e6;
                            border-radius: 4px;
                            box-shadow: 0 4px 12px rgba(0,0,0,0.15);
                            overflow: hidden;
                            background: #fff;
                            margin-top: 4px;
                        }
                        
                        .hpa-emp-dropdown-header {
                            padding: 12px;
                            border-bottom: 1px solid #dee2e6;
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
                        
                        .hpa-emp-dropdown-body { overflow-y: auto; }
                        
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
                    `;
                    document.head.appendChild(style);
                }
                
                // ===== HELPER FUNCTIONS =====
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
                    return (fullName.substring(0, 2)).toUpperCase();
                }
                
                function getAvatarStyle() {
                    return `width:${cfg.avatarWidth}px;height:${cfg.avatarHeight}px;`;
                }
                
                function getChipFontSize() {
                    const size = Math.min(cfg.avatarWidth, cfg.avatarHeight);
                    return Math.max(8, Math.floor(size * 0.4));
                }
                
                // ===== DATA LOADING =====
                function loadEmployeeList(skip, take) {
                    const jqDeferred = $.Deferred();

                    // Nếu có apiData sẵn
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

                    // Nếu đã load đủ
                    if (allEmployees.length >= totalCount && totalCount > 0) {
                        jqDeferred.resolve(allEmployees);
                        return jqDeferred.promise();
                    }

                    skip = skip || 0;
                    take = take || cfg.take;

                    // Build params for the API call
                    const extraparam = [];
                    extraparam.push("@ProcName"); extraparam.push(cfg.ajaxListName);
                    extraparam.push("@Take"); extraparam.push(take);
                    extraparam.push("@Skip"); extraparam.push(skip);
                    extraparam.push("@LanguageID"); extraparam.push(typeof LanguageID !== "undefined" ? LanguageID : "VN");

                    // Enqueue the actual Ajax call so that requests run sequentially
                    const runFetch = () => new Promise((resolveFetch, rejectFetch) => {
                        isLoadingApiData = true;
                        AjaxHPAParadise({
                            data: {
                                name: "sp_LoadGridUsingAPI",
                                param: extraparam
                            },
                            success: function (resultData) {
                                try {
                                    let jsonData = typeof resultData === "string" ? JSON.parse(resultData) : resultData;
                                    if (jsonData.reason == "error") throw new Error("Data error");

                                    const newData = (jsonData.data && jsonData.data[0]) ? jsonData.data[0] : [];
                                    const existingIds = new Set(allEmployees.map(e => e.EmployeeID));
                                    const uniqueNewData = newData.filter(e => !existingIds.has(e.EmployeeID));
                                    allEmployees = [...allEmployees, ...uniqueNewData];

                                    if (jsonData.data && jsonData.data[1] && jsonData.data[1][0]) {
                                        totalCount = jsonData.data[1][0].TotalCount || 0;
                                    }

                                    currentSkip = skip;
                                    isLoadingApiData = false;
                                    resolveFetch(allEmployees);
                                } catch (error) {
                                    isLoadingApiData = false;
                                    rejectFetch("Data Loading Error");
                                }
                            },
                            error: function () {
                                isLoadingApiData = false;
                                rejectFetch("Data Loading Error");
                            }
                        });
                    });

                    // Chain through apiQueue to ensure sequential execution
                    apiQueue = apiQueue.then(() => runFetch());

                    // Bridge the Promise to jQuery Deferred for callers
                    apiQueue.then(function() {
                        jqDeferred.resolve(allEmployees);
                    }).catch(function(err) {
                        jqDeferred.reject(err);
                    });

                    return jqDeferred.promise();
                }

                // Load only selected employees (fast path) — returns jQuery promise
                function loadSelectedEmployees() {
                    // Per-selected-set single fetch: ensure one API call per unique selected-id set and cache result globally
                    const jqDeferred = $.Deferred();

                    if (!cfg.useApi || !selectedIds || selectedIds.length === 0) {
                        selectedLoaded = true;
                        selectedCache = [];
                        jqDeferred.resolve([]);
                        return jqDeferred.promise();
                    }

                    // If already loaded in this instance, merge and return
                    if (selectedLoaded && Array.isArray(selectedCache)) {
                        const existingIds = new Set(allEmployees.map(e => String(e.EmployeeID)));
                        selectedCache.forEach(s => { if (!existingIds.has(String(s.EmployeeID))) allEmployees.push(s); });
                        jqDeferred.resolve(allEmployees);
                        return jqDeferred.promise();
                    }

                    // If apiData provided locally, filter and cache
                    if (cfg.apiData && Array.isArray(cfg.apiData)) {
                        const sel = cfg.apiData.filter(e => selectedIds.includes(String(e.EmployeeID)));
                        const existingIds = new Set(allEmployees.map(e => String(e.EmployeeID)));
                        sel.forEach(s => { if (!existingIds.has(String(s.EmployeeID))) allEmployees.push(s); });
                        selectedCache = sel.slice();
                        selectedLoaded = true;
                        jqDeferred.resolve(allEmployees);
                        return jqDeferred.promise();
                    }

                    // Ensure global maps exist
                    window.__hpaEmployeeSelectedPromises = window.__hpaEmployeeSelectedPromises || {};
                    window.__hpaEmployeeSelectedCache = window.__hpaEmployeeSelectedCache || {};

                    // stable key for this selected set
                    const selKey = selectedIds.slice().map(String).sort().join(",");

                    // If globally cached, merge and return
                    if (window.__hpaEmployeeSelectedCache[selKey]) {
                        const cached = window.__hpaEmployeeSelectedCache[selKey] || [];
                        const existingIds = new Set(allEmployees.map(e => String(e.EmployeeID)));
                        cached.forEach(s => { if (!existingIds.has(String(s.EmployeeID))) allEmployees.push(s); });
                        selectedCache = cached.slice();
                        selectedLoaded = true;
                        totalCount = Math.max(totalCount, allEmployees.length);
                        jqDeferred.resolve(allEmployees);
                        return jqDeferred.promise();
                    }

                    // If an in-flight promise exists for this selKey, attach to it
                    if (window.__hpaEmployeeSelectedPromises[selKey]) {
                        window.__hpaEmployeeSelectedPromises[selKey].then((selData) => {
                            const cached = window.__hpaEmployeeSelectedCache[selKey] || [];
                            const existingIds = new Set(allEmployees.map(e => String(e.EmployeeID)));
                            cached.forEach(s => { if (!existingIds.has(String(s.EmployeeID))) allEmployees.push(s); });
                            selectedCache = cached.slice();
                            selectedLoaded = true;
                            totalCount = Math.max(totalCount, allEmployees.length);
                            jqDeferred.resolve(allEmployees);
                        }).catch(() => {
                            selectedLoaded = true;
                            selectedCache = [];
                            jqDeferred.resolve(allEmployees);
                        });
                        return jqDeferred.promise();
                    }

                    // Start the API call and store native Promise globally
                    const nativePromise = new Promise((resolveNative, rejectNative) => {
                        // Dùng wrapper sp_LoadGridUsingAPI giống như load danh sách
                        const extraparam = [];
                        extraparam.push("@ProcName"); extraparam.push(cfg.ajaxListName || "EmployeeListAll_DataSetting_Custom");
                        extraparam.push("@Take");     extraparam.push(1000); // Load nhiều để chắc chắn lấy hết selected (thường ít)
                        extraparam.push("@Skip");     extraparam.push(0);
                        extraparam.push("@LanguageID"); extraparam.push(LanguageID || "VN");
                        extraparam.push("@SelectedIds"); extraparam.push(selectedIds.join(",")); // Thêm SelectedIds vào đây

                        AjaxHPAParadise({
                            data: {
                                name: "sp_LoadGridUsingAPI",  // <<< QUAN TRỌNG: Dùng wrapper
                                param: extraparam
                            },
                            success: function (resultData) {
                                try {
                                    let jsonData = typeof resultData === "string" ? JSON.parse(resultData) : resultData;
                                    if (jsonData.reason == "error") throw new Error("Data error");

                                    const selData = (jsonData.data && jsonData.data[0]) ? jsonData.data[0] : [];

                                    window.__hpaEmployeeSelectedCache[selKey] = selData.slice();

                                    const existingIds = new Set(allEmployees.map(e => String(e.EmployeeID)));
                                    const uniqueNew = selData.filter(e => !existingIds.has(String(e.EmployeeID)));
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
                            }
                        });
                    });

                    window.__hpaEmployeeSelectedPromises[selKey] = nativePromise;

                    // Attach to nativePromise and resolve jQuery deferred when done
                    nativePromise.then(() => {
                        const cached = window.__hpaEmployeeSelectedCache[selKey] || [];
                        const existingIds = new Set(allEmployees.map(e => String(e.EmployeeID)));
                        cached.forEach(s => { if (!existingIds.has(String(s.EmployeeID))) allEmployees.push(s); });
                        selectedCache = cached.slice();
                        selectedLoaded = true;
                        totalCount = Math.max(totalCount, allEmployees.length);
                        jqDeferred.resolve(allEmployees);
                    }).catch(() => {
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
                    
                    const cacheKey = employee.EmployeeID;
                    if (avatarCache[cacheKey]) {
                        return avatarCache[cacheKey];
                    }
                    
                    try {
                        const decoded = decodeURIComponent(employee.paramImg);
                        const paramArray = JSON.parse(decoded);
                        if (Array.isArray(paramArray) && paramArray.length > 1) {
                            AjaxHPAParadise({
                                data: {
                                    name: employee.storeImgName,
                                    param: paramArray
                                },
                                xhrFields: { responseType: "blob" },
                                cache: true,
                                success: function(blob) {
                                    if (blob && blob.size > 0) {
                                        const imgUrl = URL.createObjectURL(blob);
                                        avatarCache[cacheKey] = imgUrl;
                                        
                                        // Update all images with this employee ID
                                        $(`#${cfg.containerId} .hpa-emp-dropdown-chip[data-emp-id="${cacheKey}"] img`).attr("src", imgUrl);
                                        $(`#${cfg.dropdownId} .grid-employee-image[data-emp-id="${cacheKey}"]`).attr("src", imgUrl);
                                        
                                        // Cleanup after 5 minutes
                                        setTimeout(() => {
                                            URL.revokeObjectURL(imgUrl);
                                            delete avatarCache[cacheKey];
                                        }, 300000);
                                    }
                                }
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
                    
                    const selectedEmps = selectedIds
                        .map(id => allEmployees.find(e => String(e.EmployeeID) === String(id)))
                        .filter(e => e);
                    
                    const maxVisible = cfg.maxVisibleChips;
                    const visibleEmps = selectedEmps.slice(0, maxVisible);
                    const remainingCount = selectedEmps.length - maxVisible;
                    
                    if (selectedEmps.length === 0) {
                        html += `<span class="hpa-emp-dropdown-count">${cfg.placeholder}</span>`;
                    } else {
                        if (cfg.showAvatar) {
                            visibleEmps.forEach(emp => {
                                const imgUrl = avatarCache[emp.EmployeeID] || loadEmployeeImage(emp);
                                html += `
                                    <div class="hpa-emp-dropdown-chip" data-emp-id="${emp.EmployeeID}" title="${escapeHtml(emp.FullName)}" style="${getAvatarStyle()}">
                                        <img src="${imgUrl}" alt="${escapeHtml(emp.FullName)}" />
                                    </div>
                                `;
                            });
                        } else {
                            visibleEmps.forEach(emp => {
                                const initials = getInitials(emp.FullName);
                                html += `
                                    <div class="hpa-emp-dropdown-chip-text" data-emp-id="${emp.EmployeeID}" title="${escapeHtml(emp.FullName)}" style="${getAvatarStyle()}font-size:${getChipFontSize()}px;">
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
                    
                    $(`#empDropdownBtn_${cfg.containerId}`).off("click").on("click", function(e) {
                        e.stopPropagation();
                        toggleDropdown();
                    });
                    
                    // Load images for visible chips
                    if (cfg.showAvatar) {
                        selectedEmps.forEach(emp => {
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
                        display: "none"
                    });
                }
                
                function positionDropdown() {
                    const $btn = $(`#empDropdownBtn_${cfg.containerId}`);
                    const $dropdown = $(`#${cfg.dropdownId}`);

                    if ($btn.length === 0) return;

                    // Ensure dropdown is appended to body for correct absolute positioning
                    if ($dropdown.parent().prop("tagName") !== "BODY") {
                        $dropdown.appendTo(document.body);
                    }

                    const btnOffset = $btn.offset();
                    const btnHeight = $btn.outerHeight();

                    $dropdown.css({
                        position: "absolute",
                        top: (btnOffset.top + btnHeight + 4) + "px",
                        left: btnOffset.left + "px",
                        zIndex: 3005
                    });
                }
                
                function toggleDropdown() {
                    const $dropdown = $(`#${cfg.dropdownId}`);
                    const isVisible = $dropdown.is(":visible");
                    
                    if (isVisible) {
                        $dropdown.hide();
                    } else {
                        positionDropdown();

                        // Render dropdown (will show selected-only initially)
                        $dropdown.show();

                        if (!dataGridInstance) {
                            createDataGrid();

                            // Start background loading of the full list; when completed, reload grid
                            loadEmployeeList(0, cfg.take).then(() => {
                                snapshotEmployees = getSortedEmployees();
                                if (dataGridInstance) {
                                    dataGridInstance.beginUpdate();
                                    dataGridInstance.getDataSource().reload();
                                    dataGridInstance.endUpdate();

                                    // Re-apply selection from cached selected employees (single batched load)
                                    if (selectedLoaded && Array.isArray(selectedCache) && selectedCache.length > 0) {
                                        const cachedIds = selectedCache.map(e => String(e.EmployeeID));
                                        const toSelect = selectedIds.filter(id => cachedIds.includes(String(id)));
                                        if (toSelect.length > 0) {
                                            dataGridInstance.option("selectedRowKeys", toSelect);
                                        }
                                    }
                                }
                            }).catch(() => {});
                        } else {
                            if (allEmployees.length < totalCount) {
                                loadEmployeeList(allEmployees.length, cfg.take).then(() => {
                                    snapshotEmployees = getSortedEmployees();
                                    if (dataGridInstance) {
                                        dataGridInstance.beginUpdate();
                                        dataGridInstance.getDataSource().reload();
                                        dataGridInstance.endUpdate();

                                        if (selectedLoaded && Array.isArray(selectedCache) && selectedCache.length > 0) {
                                            const cachedIds = selectedCache.map(e => String(e.EmployeeID));
                                            const toSelect = selectedIds.filter(id => cachedIds.includes(String(id)));
                                            if (toSelect.length > 0) {
                                                dataGridInstance.option("selectedRowKeys", toSelect);
                                            }
                                        }
                                    }
                                }).catch(() => {});
                            }
                        }

                        setTimeout(() => {
                            $(`#${cfg.dropdownId} .hpa-emp-dropdown-search`).focus();
                        }, 100);
                    }
                }
                
                function filterEmployees(searchText) {
                    if (!dataGridInstance || isGridInitializing) return;
                    
                    currentSearchText = searchText.trim();
                    
                    if (currentSearchText) {
                        const searchLower = currentSearchText.toLowerCase();
                        dataGridInstance.filter(["FullName", "contains", searchLower]);
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
                        load: function(loadOptions) {
                            const deferred = $.Deferred();
                            const skip = loadOptions.skip || 0;
                            const take = loadOptions.take || cfg.take;
                            
                            let gridData = getGridData();
                            const needsMoreData = (skip + take) > gridData.length && allEmployees.length < totalCount;
                            
                            if (needsMoreData && !isLoadingApiData) {
                                const apiSkip = allEmployees.length;
                                loadEmployeeList(apiSkip, cfg.take).then(() => {
                                    snapshotEmployees = getSortedEmployees();
                                    gridData = snapshotEmployees;
                                    const pageData = gridData.slice(skip, skip + take);
                                    const finalTotalCount = totalCount > 0 ? totalCount : gridData.length;
                                    deferred.resolve({ data: pageData, totalCount: finalTotalCount });
                                }).catch(err => deferred.reject(err));
                                return deferred.promise();
                            }
                            
                            const pageData = gridData.slice(skip, skip + take);
                            const finalTotalCount = totalCount > 0 ? totalCount : gridData.length;
                            deferred.resolve({ data: pageData, totalCount: finalTotalCount });
                            return deferred.promise();
                        }
                    });
                    
                    function getSortedEmployees() {
                        let data = [...allEmployees];
                        if (currentSearchText.trim()) {
                            const searchLower = currentSearchText.toLowerCase().trim();
                            data = data.filter(emp => emp.FullName && emp.FullName.toLowerCase().includes(searchLower));
                        }
                        return data.sort((a, b) => {
                            const aSelected = selectedIds.includes(String(a.EmployeeID));
                            const bSelected = selectedIds.includes(String(b.EmployeeID));
                            if (aSelected && !bSelected) return -1;
                            if (!aSelected && bSelected) return 1;
                            return 0;
                        });
                    }
                    
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
                            cellTemplate: function(container, options) {
                                const emp = options.data;
                                let imgUrl = avatarCache[emp.EmployeeID] || loadEmployeeImage(emp);
                                const $img = $(`<img class="grid-employee-image" data-emp-id="${emp.EmployeeID}" src="${imgUrl}" alt="${escapeHtml(emp.FullName)}" style="${getAvatarStyle()}border-radius:50%;object-fit:cover;" />`);
                                container.html($img);
                            }
                        });
                        fixedColumnsWidth += (cfg.avatarWidth + 16);
                    }
                    
                    const nameColumnWidth = `calc(100% - ${fixedColumnsWidth}px)`;
                    gridColumns.push({ dataField: "FullName", caption: "Tên nhân viên", width: nameColumnWidth });
                    
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
                            selectAllMode: cfg.multi ? "allPages" : "page"
                        },
                        selectedRowKeys: selectedIds,
                        onSelectionChanged: function(selectedItems) {
                            const newSelectedIds = cfg.multi ? selectedItems.selectedRowKeys : [selectedItems.selectedRowKeys[0]];
                            const hasChanged = JSON.stringify([...selectedIds].sort()) !== JSON.stringify([...newSelectedIds].sort());
                            
                            if (!hasChanged) return;
                            
                            selectedIds = newSelectedIds.map(String);
                            
                            if (cfg.onChange) cfg.onChange(selectedIds);
                            
                            // Save to DB if configured
                            if (cfg.tableName && cfg.idValue) {
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
                        }
                    };
                    
                    $(`#${cfg.dropdownId} .employee-grid-inner`).dxDataGrid(gridConfig);
                    dataGridInstance = $(`#${cfg.dropdownId} .employee-grid-inner`).dxDataGrid("instance");
                    
                    setTimeout(() => {
                        if (dataGridInstance) {
                            let foundSelectedEmps = [];
                            if (selectedLoaded && Array.isArray(selectedCache) && selectedCache.length > 0) {
                                // Use cached selected employees (single batched load) when available
                                const cachedIds = selectedCache.map(e => String(e.EmployeeID));
                                foundSelectedEmps = selectedIds.filter(id => cachedIds.includes(String(id)));
                            } else {
                                foundSelectedEmps = selectedIds.filter(id =>
                                    allEmployees.some(e => String(e.EmployeeID) === String(id))
                                );
                            }

                            if (foundSelectedEmps.length > 0) {
                                dataGridInstance.option("selectedRowKeys", foundSelectedEmps);
                            }
                        }
                    }, 100);

                    // Attach scroll handlers robustly: try multiple strategies and retry if element not ready
                    function attachScrollHandlers() {
                        const onScrollLoadMore = function() {
                            try {
                                const el = this;
                                const $el = $(el);
                                const scrollTop = (typeof el.scrollTop === "number") ? el.scrollTop : $el.scrollTop();
                                const scrollHeight = (typeof el.scrollHeight === "number") ? el.scrollHeight : ($el.prop("scrollHeight") || 0);
                                const clientHeight = (typeof el.clientHeight === "number") ? el.clientHeight : ($el.innerHeight() || 0);
                                const distanceFromBottom = scrollHeight - (scrollTop + clientHeight);

                                if (distanceFromBottom < 140 && allEmployees.length < totalCount && !isLoadingApiData) {
                                    const apiSkip = allEmployees.length;
                                    loadEmployeeList(apiSkip, cfg.take).then(() => {
                                        snapshotEmployees = getSortedEmployees();
                                        if (dataGridInstance) {
                                            dataGridInstance.beginUpdate();
                                            dataGridInstance.getDataSource().reload();
                                            dataGridInstance.endUpdate();

                                            if (selectedLoaded && Array.isArray(selectedCache) && selectedCache.length > 0) {
                                                const cachedIds = selectedCache.map(e => String(e.EmployeeID));
                                                const toSelect = selectedIds.filter(id => cachedIds.includes(String(id)));
                                                if (toSelect.length > 0) dataGridInstance.option("selectedRowKeys", toSelect);
                                            }
                                        }
                                    }).catch(() => {});
                                }
                            } catch (err) {}
                        };

                        const tryBind = (attempt) => {
                            attempt = attempt || 0;
                            try {
                                var $scrollEl = null;

                                // 1) Prefer DevExtreme scrollable element
                                var scrollable = dataGridInstance && dataGridInstance.getScrollable ? dataGridInstance.getScrollable() : null;
                                if (scrollable && typeof scrollable.element === "function") {
                                    try { $scrollEl = $(scrollable.element()); } catch(e) { $scrollEl = null; }
                                }

                                // 2) try dx-viewport inside dropdown
                                if ((!$scrollEl || $scrollEl.length === 0) && $(`#${cfg.dropdownId} .dx-viewport`).length) {
                                    $scrollEl = $(`#${cfg.dropdownId} .dx-viewport`);
                                }

                                // 3) fallback to dropdown body
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
                    
                    $(`#${cfg.dropdownId} .hpa-emp-dropdown-search`).off("keyup").on("keyup", function() {
                        filterEmployees($(this).val());
                    });
                    
                    setTimeout(() => {
                        isGridInitializing = false;
                    }, 100);
                    
                    $(`#${cfg.dropdownId} .hpa-emp-dropdown-body`).off("scroll").on("scroll", function() {
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
                                        const cachedIds = selectedCache.map(e => String(e.EmployeeID));
                                        const toSelect = selectedIds.filter(id => cachedIds.includes(String(id)));
                                        if (toSelect.length > 0) dataGridInstance.option("selectedRowKeys", toSelect);
                                    }
                                }
                            });
                        }
                    });
                }
                
                function saveToDB(val) {
                    if (!cfg.tableName || !cfg.idValue) return;
                    
                    AjaxHPAParadise({
                        data: {
                            name: "sp_Common_SaveDataTable",
                            param: [
                                "LoginID", LoginID,
                                "LanguageID", LanguageID || "VN",
                                "TableName", cfg.tableName,
                                "ColumnName", cfg.columnName,
                                "IDColumnName", cfg.idColumnName || "ID",
                                "ColumnValue", cfg.multi ? (val || []).join(",") : (val || ""),
                                "ID_Value", cfg.idValue
                            ]
                        },
                        success: () => {
                            if (!cfg.silent && typeof uiManager !== "undefined") {
                                uiManager.showAlert({ type: "success", message: "%UpdateSuccess%" });
                            }
                        },
                        error: () => {
                            if (typeof uiManager !== "undefined") {
                                uiManager.showAlert({ type: "error", message: "Lưu thất bại!" });
                            }
                        }
                    });
                }
                
                // ===== EVENT HANDLERS =====
                $(document).off(`click.employeeDropdown_${cfg.containerId}`).on(`click.employeeDropdown_${cfg.containerId}`, function(e) {
                    if (!$(e.target).closest(`#${cfg.containerId}, #${cfg.dropdownId}`).length) {
                        $(`#${cfg.dropdownId}`).hide();
                    }
                });
                
                // ===== INITIALIZATION =====
                // Create container structure
                const containerHtml = `
                    <div id="${cfg.containerId}"></div>
                    <div id="${cfg.dropdownId}"></div>
                `;
                $el.html(containerHtml);
                
                initDropdownContainer();

                // Initial render: try to show selected employees first (fast path)
                renderSelectorButton();

                if (cfg.useApi && !cfg.apiData) {
                    if (selectedIds && selectedIds.length > 0) {
                        // Load only selected employees first and render
                        loadSelectedEmployees().then(() => {
                            renderSelectorButton();
                        }).catch(() => {
                            renderSelectorButton();
                        });
                    } else {
                        // No selected IDs — defer full load until dropdown open (first open will trigger background load)
                    }
                } else {
                    renderSelectorButton();  // Render ngay nếu có apiData
                }
                
                // ===== PUBLIC API =====
                return {
                    getSelectedIds: () => selectedIds,
                    setSelectedIds: (ids) => {
                        selectedIds = ids.map(String);
                        // Clear cached selected-load so we will fetch the new set on demand
                        selectedLoaded = false;
                        selectedLoadPromise = null;
                        selectedCache = [];
                        renderSelectorButton();
                        if (dataGridInstance) {
                            dataGridInstance.option("selectedRowKeys", selectedIds);
                        }
                    },
                    refresh: () => {
                        if (dataGridInstance) {
                            dataGridInstance.refresh();
                        }
                    },
                    open: () => {
                        positionDropdown();
                        $(`#${cfg.dropdownId}`).show();
                    },
                    close: () => {
                        $(`#${cfg.dropdownId}`).hide();
                    },
                    destroy: () => {
                        $(document).off(`click.employeeDropdown_${cfg.containerId}`);
                        $el.empty();
                    }
                };
            }

            //Thắng: Hàm control date
            function hpaControlDateBox(el, config) {
                const $el = $(el);
                const defaults = {
                    type: "date",
                    field: null,
                    tableName: null,
                    idColumnName: null,
                    idValue: null,
                    getValue: () => $el.text().trim(),
                    setValue: (val) => $el.text(val),
                    silent: config.silent || false,
                    onSave: null,
                    language: "VN",
                    width: config.width
                };
                const cfg = { ...defaults, ...config };

                if (!cfg.field || !cfg.tableName || !cfg.idColumnName) return console.error("thiếu field, tableName hoặc idColumnName");

                if (!window.__hpaEditableRowDateCSSInjected) {
                    const style = document.createElement("style");
                    style.textContent = `
                        .hpa-editable-row-date.control-editable-date { cursor: pointer; padding: 8px 4px; border-radius: 4px; transition: all 0.2s; display: inline-block; min-height: 1.2em; vertical-align: middle; box-sizing: border-box; }
                        .hpa-editable-row-date.control-editable-date.editing-date { border-radius: 6px; padding: 0; box-shadow: none; z-index: 100;}
                        .hpa-editable-row-date.control-editable-date.editing-date input { width: 100% !important; min-width: 120px; font-size: 14px; padding: 4px 8px; height: 30px; }
                        .hpa-editable-row-date.control-editable-date.editing-date input[type="datetime-local"] { min-width: 200px; }
                        .dx-button.dx-button-default { background-color: none; }
                    `;
                    document.head.appendChild(style);
                    window.__hpaEditableRowDateCSSInjected = true;
                }

                if (cfg.width) {
                    $el.css({
                        "width": cfg.width,
                        "min-width": cfg.width,
                        "white-space": "nowrap",
                        "overflow": "hidden",
                        "text-overflow": "ellipsis"
                    });
                }

                const parseDate = (str) => {
                    if (!str || str.trim() === "") return null;

                    if (str.indexOf("/") !== -1) {
                        const parts = str.split("/");
                        if (parts.length === 3) {
                            return new Date(parts[2], parts[1] - 1, parts[0]);
                        }
                    }

                    const d = new Date(str);
                    return isNaN(d.getTime()) ? new Date() : d;
                };

                const formatDateToVN = (dateObj) => {
                    if (!dateObj || isNaN(dateObj.getTime())) return "";
                    const day = ("0" + dateObj.getDate()).slice(-2);
                    const month = ("0" + (dateObj.getMonth() + 1)).slice(-2);
                    const year = dateObj.getFullYear();
                    if (cfg.type === "datetime") {
                        const h = ("0" + dateObj.getHours()).slice(-2);
                        const m = ("0" + dateObj.getMinutes()).slice(-2);
                        return `${day}/${month}/${year} ${h}:${m}`;
                    }
                    return `${day}/${month}/${year}`;
                };

                const initialText = $el.text().trim();
                if (initialText && initialText.indexOf("-") > -1 && initialText.indexOf("/") === -1) {
                    const initDate = new Date(initialText);
                    if (!isNaN(initDate.getTime())) {
                        $el.text(formatDateToVN(initDate));
                    }
                }

                let inputType = cfg.type === "datetime" ? "datetime-local" : "date";
                const resolvedId = cfg.idValue || (typeof currentTaskID !== "undefined" ? currentTaskID : null);

                $el.addClass("hpa-editable-row-date control-editable-date")
                    .off("click.datebox")
                    .removeClass("editable editing-date");

                $el.on("click.datebox", function(e) {
                    $(".hpa-editable-row.editing, .hpa-editable-row-number.editing").not($el).find(".btn-save").trigger("click");
                    if ($(".hpa-editable-row-date.editing-date, .hpa-editable-row-time.editing-time").not($el).length > 0) {
                        $("body").trigger("click");
                    }
                    e.stopPropagation(); e.preventDefault();
                    if ($el.hasClass("editing-date")) return false;

                if (cfg.width) $el.css("overflow", "visible");

                    const rawText = typeof cfg.getValue === "function" ? cfg.getValue() : cfg.getValue;
                    const dateValue = parseDate(rawText);

                    const $editorContainer = $("<div class=\"dx-field-value\" style=\"width:100%; height:100%\"></div>");

                    $el.addClass("editing-date").html("").append($editorContainer);

                    let currentIdValue = resolvedId;
                    let isSaved = false;

                    const finish = (saveIt) => {
                        if (isSaved) return;

                        const dxInstance = $editorContainer.dxDateBox("instance");
                        const vnResult = dxInstance ? dxInstance.option("text") : rawText;
                        const rawInput = dxInstance ? dxInstance.option("value") : null;

                        isSaved = true;
                        $el.removeClass("editing-date");

                        if (cfg.width) $el.css("overflow", "hidden");

                        if (dxInstance) dxInstance.dispose();
                        $editorContainer.remove();

                        if (!saveIt || vnResult === rawText) {
                            typeof cfg.setValue === "function" ? cfg.setValue(rawText) : $el.text(rawText);
                            return;
                        }

                        typeof cfg.setValue === "function" ? cfg.setValue(vnResult) : $el.text(vnResult);
                        if (!rawInput) currentIdValue = null;

                        let spDataType = cfg.type === "datetime" ? "datetime" : "date";

                        const params = [
                            "LoginID", (typeof LoginID !== "undefined" ? LoginID : 0),
                            "LanguageID", cfg.language,
                            "TableName", cfg.tableName,
                            "ColumnName", cfg.field,
                            "IDColumnName", cfg.idColumnName,
                            "ColumnValue", vnResult,
                            "ID_Value", currentIdValue,
                            "DataType", spDataType
                        ];

                        AjaxHPAParadise({
                            data: { name: "sp_Common_SaveDataTable", param: params },
                            success: () => {
                                if (cfg.silent) uiManager.showAlert({ type: "success", message: typeof isAddMode !== "undefined" && isAddMode ? "%AddSuccess%" : "%UpdateSuccess%" });
                                if (cfg.onSave) cfg.onSave(vnResult, true);
                            },
                            error: () => {
                                if (typeof uiManager !== "undefined") uiManager.showAlert({ type: "error", message: "Lỗi lưu!" });
                                typeof cfg.setValue === "function" ? cfg.setValue(rawText) : $el.text(rawText);
                            }
                        });
                    };

                    const dxBox = $editorContainer.dxDateBox({
                        value: dateValue,
                        type: cfg.type === "datetime" ? "datetime" : "date",
                        displayFormat: cfg.type === "datetime" ? "dd/MM/yyyy HH:mm" : "dd/MM/yyyy",
                        useMaskBehavior: true,
                        placeholder: "dd/mm/yyyy",
                        openOnFieldClick: true,
                        showClearButton: false,
                        dateSerializationFormat: "yyyy-MM-dd",
                        width: "100%",
                        elementAttr: { class: "hpa-dx-datebox-inline" },
                        onOpened: function(e) {
                            setTimeout(() => { e.component.focus(); }, 100);
                        },
                        onClosed: function(e) {
                            setTimeout(() => finish(true), 50);
                        },
                        onKeyDown: function(e) {
                            if (e.event.key === "Enter") {
                                e.event.preventDefault();
                                e.component.close();
                            }
                            if (e.event.key === "Escape") {
                                e.event.preventDefault();
                                finish(false);
                            }
                        }
                    }).dxDateBox("instance");

                    dxBox.open();
                });
            }

            //Thắng: Hàm control hour
            function hpaControlTimeBox(el, config) {
                const $el = $(el);
                const defaults = {
                    field: null,
                    tableName: null,
                    idColumnName: null,
                    idValue: null,
                    getValue: () => $el.text().trim(),
                    setValue: (val) => $el.text(val),
                    silent: config.silent || false,
                    onSave: null,
                    language: "VN",
                    width: config.width
                };
                const cfg = { ...defaults, ...config };

                if (!cfg.field || !cfg.tableName || !cfg.idColumnName) return console.error("thiếu field, tableName hoặc idColumnName");

                if (!window.__hpaEditableRowTimeCSSInjected) {
                    const style = document.createElement("style");
                    style.textContent = `
                        .hpa-editable-row-time.control-editable-time { cursor: pointer; padding: 8px 4px; border-radius: 4px; transition: all 0.2s; display: inline-block; min-height: 1.2em; vertical-align: middle; box-sizing: border-box; }
                        .hpa-editable-row-time.control-editable-time.editing-time { border-radius: 6px; padding: 0; box-shadow: none; z-index: 100; min-width: 90%; }
                        .hpa-editable-row-time.control-editable-time.editing-time .dx-datebox { width: 100% !important; }
                        .dx-popup-wrapper .dx-popup-content { min-width: 300px !important; }
                        .dx-popup-wrapper .dx-timeview { min-width: 300px !important; }
                        .dx-button.dx-button-default { background-color: #00673b; }
                        .dx-button-content { color: #fff; }
                    `;
                    document.head.appendChild(style);
                    window.__hpaEditableRowTimeCSSInjected = true;
                }

                if (cfg.width) {
                    $el.css({
                        "width": cfg.width,
                        "min-width": cfg.width,
                        "white-space": "nowrap",
                        "overflow": "hidden",
                        "text-overflow": "ellipsis"
                    });
                }

                const resolvedId = cfg.idValue || (typeof currentTaskID !== "undefined" ? currentTaskID : null);

                $el.addClass("hpa-editable-row-time control-editable-time")
                    .off("click.timebox")
                    .removeClass("editable editing-time");

                $el.on("click.timebox", function(e) {
                    $(".hpa-editable-row.editing, .hpa-editable-row-number.editing").not($el).find(".btn-save").trigger("click");
                        if ($(".hpa-editable-row-date.editing-date, .hpa-editable-row-time.editing-time").not($el).length > 0) {
                            $("body").trigger("click");
                        }
                    e.stopPropagation(); e.preventDefault();
                    if ($el.hasClass("editing-time")) return false;

                    if (cfg.width) $el.css("overflow", "visible");

                    const rawText = typeof cfg.getValue === "function" ? cfg.getValue() : cfg.getValue;

                    let initialValue = null;
                    if (rawText) {
                        const timeParts = rawText.split(":");
                        if (timeParts.length >= 2) {
                            const [h, min] = timeParts;
                            const today = new Date();
                            initialValue = new Date(today.getFullYear(), today.getMonth(), today.getDate(), h, min);
                        }
                    }

                    const $container = $("<div></div>");
                    $el.addClass("editing-time").html("").append($container);

                    const dxInstance = $container.dxDateBox({
                        value: initialValue,
                        type: "time",
                        displayFormat: "HH:mm",
                        useMaskBehavior: true,
                        openOnFieldClick: true,
                        showClearButton: true,
                        width: "100%",
                        pickerType: "rollers",
                        applyButtonText: "Xong",
                        cancelButtonText: "Hủy",
                        stylingMode: "outlined",
                        onInitialized: function(e) {
                            setTimeout(() => { e.component.open(); }, 100);
                        }
                    }).dxDateBox("instance");

                    let currentIdValue = resolvedId;
                    let isSaving = false;
                    let hasFinished = false;

                    const finish = (saveIt) => {
                        if (isSaving || hasFinished) return;
                        hasFinished = true;

                        const dateValue = dxInstance.option("value");
                        let vnResult = "";

                        if (dateValue) {
                            const h = String(dateValue.getHours()).padStart(2, "0");
                            const min = String(dateValue.getMinutes()).padStart(2, "0");
                            vnResult = `${h}:${min}`;
                        }

                        try { dxInstance.dispose(); } catch(e) {}
                        $el.removeClass("editing-time");

                        if (cfg.width) $el.css("overflow", "hidden");

                        if (!saveIt || vnResult === rawText) {
                            typeof cfg.setValue === "function" ? cfg.setValue(rawText) : $el.text(rawText);
                            return;
                        }

                        typeof cfg.setValue === "function" ? cfg.setValue(vnResult) : $el.text(vnResult);

                        if (!vnResult) currentIdValue = null;

                        const params = [
                            "LoginID", (typeof LoginID !== "undefined" ? LoginID : 0),
                            "LanguageID", cfg.language,
                            "TableName", cfg.tableName,
                            "ColumnName", cfg.field,
                            "IDColumnName", cfg.idColumnName,
                            "ColumnValue", vnResult,
                            "ID_Value", currentIdValue,
                            "DataType", "time"
                        ];

                        isSaving = true;
                        AjaxHPAParadise({
                            data: { name: "sp_Common_SaveDataTable", param: params },
                            success: () => {
                                isSaving = false;
                                if (cfg.silent) uiManager.showAlert({ type: "success", message: isAddMode ? "%AddSuccess%" : "%UpdateSuccess%" });
                                if (cfg.onSave) cfg.onSave(vnResult, true);
                            },
                            error: () => {
                                isSaving = false;
                                if (typeof uiManager !== "undefined") uiManager.showAlert({ type: "error", message: "Lỗi lưu!" });
                                typeof cfg.setValue === "function" ? cfg.setValue(rawText) : $el.text(rawText);
                            }
                        });
                    };

                    let buttonClicked = false;

                    dxInstance.on("valueChanged", function(e) {
                        if (e.event && e.event.type === "dxclick") {
                            buttonClicked = true;
                            finish(true);
                        }
                    });

                    dxInstance.on("closed", function() {
                        if (!buttonClicked && !hasFinished) {
                            finish(false);
                        }
                    });
                });
            }

			//Thắng: Hàm control number
            function hpaControlEditableNumber(el, config) {
                const $el = $(el);

                const cfg = {
                    type: config.type || "NumberInt",
                    tableName: config.tableName,
                    columnName: config.columnName,
                    idColumnName: config.idColumnName,
                    idValue: config.idValue,
                    silent: config.silent || false,
                    allowAdd: config.allowAdd || false,
                    onSave: config.onSave || null,
                    language: config.language || "VN",
                    width: config.width
                };

                if (!cfg.columnName || !cfg.tableName || !cfg.idColumnName) return console.error("thiếu columnName, tableName, idColumnName");

                if (!window.__hpaEditableRowNumberCSSInjected) {
                    const style = document.createElement("style");
                    style.textContent = `
                        .hpa-editable-row-number.control-editable-number {
                            cursor: pointer;
                            padding: 8px 4px;
                            border-radius: 4px;
                            transition: all 0.2s;
                            display: inline-block;
                            vertical-align: middle;
                            box-sizing: border-box;
                        }
                        .hpa-editable-row-number.control-editable-number.editing {
                            padding: 4px 8px;
                            z-index: 100;
                        }
                        .hpa-editable-row-number.control-editable-number.editing input {
                            width: 100% !important; /* Full width input */
                            font-size: inherit;
                            font-weight: inherit;
                            padding: 6px 10px;
                            border: 1px solid #1c975e !important;
                            box-sizing: border-box;
                        }
                        .hpa-editable-row-number.control-editable-number .edit-actions {
                            position: absolute;
                            top: 110%;
                            display: inline-flex;
                            gap: 4px;
                            margin-left: 6px;
                            align-items: center;
                            z-index: 101;
                            right: 0;
                        }
                        .hpa-editable-row-number.control-editable-number .btn-edit {
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
                        .hpa-editable-row-number.control-editable-number .btn-edit:hover {
                            transform: scale(1.1);
                        }
                        .hpa-editable-row-number.control-editable-number .btn-edit.btn-save {
                            background: #2E7D32;
                            color: white;
                            border-color: #2E7D32;
                        }
                        .hpa-editable-row-number.control-editable-number .btn-edit.btn-save:hover {
                            background: #1c975e;
                        }
                        .hpa-editable-row-number.control-editable-number .btn-edit.btn-cancel {
                            background: #fff;
                            color: #676879;
                        }
                        .hpa-editable-row-number.control-editable-number .btn-edit.btn-cancel:hover {
                            background: #f5f5f5;
                            color: #E53935;
                        }
                    `;
                    document.head.appendChild(style);
  window.__hpaEditableRowNumberCSSInjected = true;
                }

                if (cfg.width) {
                    $el.css({
                        "width": cfg.width,
                        "min-width": cfg.width,
                        "white-space": "nowrap",
                        "overflow": "hidden",
                        "text-overflow": "ellipsis"
                    });
                }

                const formatValue = (val, type) => {
                    if (!val) return "";
                    const cleanVal = val.toString().replace(/[^\d+,.-]/g, "");
                    if (type === "Money") {
                        const num = cleanVal.replace(/,/g, "");
                        if (!num || isNaN(num)) return cleanVal;
                        return parseFloat(num).toLocaleString("en-US");
                    }
                    return cleanVal;
                };

                const getRawValue = (val, type) => {
                    if (type === "Money") return val.replace(/,/g, "");
                    else if (type === "NumberFlo") return val.replace(/,/g, ".");
                    return val;
                };

                $el.addClass("hpa-editable-row-number control-editable-number")
                    .off("click.control-editable-number")
                    .on("click.control-editable-number", function(e) {
                        $(".hpa-editable-row.editing, .hpa-editable-row-number.editing").not($el).find(".btn-save").trigger("click");
                        if ($(".hpa-editable-row-date.editing-date, .hpa-editable-row-time.editing-time").not($el).length > 0) {
                            $("body").trigger("click");
                        }
                        e.stopPropagation();
                        e.preventDefault();

                        $(".hpa-editable-row-number.control-editable-number.editing").each(function() {
                            if (this !== $el[0]) {
                                $(this).find(".btn-save").trigger("click");
                            }
                        });

                        if ($el.hasClass("editing")) return false;

                        if (cfg.width) $el.css("overflow", "visible");

                        const curVal = $el.text().trim();
                        const $input = $("<input type=\"text\" class=\"form-control form-control-sm\">").val(curVal);

                        let isAddMode = false;
                        let recordId = cfg.idValue;

                        const $save = $("<button class=\"btn-edit btn-save\" title=\"Lưu\"><i class=\"bi bi-check-lg\"></i></button>");
                        const $cancel = $("<button class=\"btn-edit btn-cancel\" title=\"Hủy\"><i class=\"bi bi-x-lg\"></i></button>");

                        const updateButtonState = () => {
                            const isEmpty = !$input.val() || $input.val().trim().length === 0;
                            if (cfg.allowAdd && isEmpty && !isAddMode) {
                                isAddMode = true;
                                recordId = null;
                                $save.html("<i class=\"bi bi-plus-lg\"></i>").attr("title", "Thêm");
                            }
                        };

                        const $actions = $("<div class=\"edit-actions\"></div>").append($save).append($cancel);
                        const $wrap = $("<div class=\"d-flex align-items-end gap-1 w-100 flex-column position-relative\"></div>").append($input).append($actions);
                        $el.addClass("editing").html("").append($wrap);

                        setTimeout(() => {
                            const el = $input[0];
                            el.focus();
                            const len = el.value.length;
                            el.setSelectionRange(len, len);
                        }, 50);

             $input.on("input", function(e) {
                            let val = $(this).val();
                            if (cfg.type === "Phone") {
                                val = val.replace(/[^0-9+]/g, "");
                            } else if (cfg.type === "NumberInt") {
                                val = val.replace(/[^0-9]/g, "");
                                if (val.length > 1 && val.startsWith("0")) val = val.replace(/^0+/, "");
                            } else if (cfg.type === "NumberFlo" || cfg.type === "Money") {
                                val = val.replace(/[^0-9.,]/g, "");
                            }

                            if (val !== $(this).val()) $(this).val(val);

                            if (cfg.type === "Money") {
                                const cursorPos = this.selectionStart;
                                const oldLen = val.length;
                                const formatted = formatValue(val, cfg.type);
                                if (formatted !== val) {
                                    $(this).val(formatted);
                                    const newLen = formatted.length;
                                    const newPos = cursorPos + (newLen - oldLen);
                                    this.setSelectionRange(newPos, newPos);
                                }
                            }
                            updateButtonState();
                        });

                        const finish = (saveIt) => {
                            const displayVal = $input.val().trim();
                            const rawVal = getRawValue(displayVal, cfg.type);

                            $save.off("click");
                            $cancel.off("click");
                            $input.off("click keydown input");
                            $(document).off("click.hpaEditableNumber");

                            $el.removeClass("editing").off("keydown");

                            if (cfg.width) $el.css("overflow", "hidden");

                            if (!saveIt || (rawVal === getRawValue(curVal, cfg.type) && !isAddMode)) {
                                $el.text(curVal);
                                return;
                            }

                            const params = [
                                "LoginID", LoginID,
                                "LanguageID", cfg.language,
                                "TableName", cfg.tableName,
                                "ColumnName", cfg.columnName,
                                "IDColumnName", cfg.idColumnName,
                      "ColumnValue", rawVal,
                                "ID_Value", recordId
                            ];

                            AjaxHPAParadise({
                                data: { name: "sp_Common_SaveDataTable", param: params },
                                success: () => {
                                    $el.text(displayVal);
                                    if (cfg.silent) uiManager.showAlert({ type: "success", message: isAddMode ? "%AddSuccess%" : "%UpdateSuccess%" });
                                    if (cfg.onSave) cfg.onSave(rawVal, isAddMode, recordId);
                                },
                                error: () => {
                                    uiManager.showAlert({ type: "error", message: "Lưu thất bại!" });
                                    $el.text(curVal);
                                }
                            });
                        };

                        $save.on("click", function(e) {
                            e.stopPropagation();
                            $(document).off("click.hpaEditableNumber");
                            finish(true);
                        });

                        $cancel.on("click", (e) => {
                            e.stopPropagation();
                            e.preventDefault();
                            finish(false);
                            return false;
                        });
                        $input.on("keydown", (e) => {
                            if (e.key === "Enter") {
                                e.preventDefault();
                                finish(true);
                            }
                            if (e.key === "Escape") finish(false);
                        });
                        $(document).one("click.hpaEditableNumber", (e) => {
                            if (!$(e.target).closest($el).length) finish(true);
                        });
                    });
            }


            //Thang: Hàm control file, photo
            function hpaControlFileDropzone(el, config) {
                const $el = $(el);
                const uniqueId = `hpa-dropzone-${Date.now()}-${Math.floor(Math.random() * 1000)}`;

                // Config mặc định
                const cfg = {
                    uploadUrl: config.uploadUrl || "/api/Upload/Image", // [QUAN TRỌNG] API Upload phía server
                    allowedExtensions: config.allowedExtensions || [".jpg", ".jpeg", ".gif", ".png"],
                    maxFileSize: config.maxFileSize || 5000000, // 5MB
                    currentValue: config.currentValue || "", // Đường dẫn ảnh hiện tại (nếu có)
                    width: config.width || "100%",
                    height: config.height || "200px",
                    tableName: config.tableName,      // Dùng để auto save nếu cần
                    columnName: config.columnName,    // Dùng để auto save nếu cần
                    idColumnName: config.idColumnName,// Dùng để auto save nếu cần
                    idValue: config.idValue,          // Dùng để auto save nếu cần
                    onSuccess: config.onSuccess || null, // Callback (url, file) => {}
                    onError: config.onError || null
                };

                // 1. Inject CSS (Chỉ inject 1 lần)
                if (!window.__hpaFileDropzoneCSSInjected) {
                    const style = document.createElement("style");
                    style.textContent = `
                        .hpa-dropzone-box {
                            position: relative;
                            border: 2px dashed #dce1e5;
                            border-radius: 8px;
                            background: #f8f9fa;
                            display: flex;
                            flex-direction: column;
                            align-items: center;
                            justify-content: center;
                            overflow: hidden;
                            transition: all 0.3s ease;
                            cursor: pointer;
                        }
                        .hpa-dropzone-box.dropzone-active {
                            border-color: #1c975e;
                            background: #e8f5e9;
                        }
                        .hpa-dropzone-box:hover {
                            border-color: #a0a0a0;
                        }
                        .hpa-dropzone-content {
                            text-align: center;
                            pointer-events: none; /* Để sự kiện drag xuyên qua vào div cha */
                            z-index: 1;
                            width: 100%;
                            height: 100%;
                            display: flex;
                            align-items: center;
                            justify-content: center;
                        }
                        .hpa-preview-img {
                            max-width: 100%;
                            max-height: 100%;
                            object-fit: contain;
                            display: block;
                        }
                        .hpa-placeholder-text {
                            color: #6c757d;
                            font-size: 13px;
                            padding: 10px;
                        }
                        .hpa-placeholder-text i {
                            font-size: 24px;
                            display: block;
                            margin-bottom: 5px;
                        }
                        .hpa-upload-progress-bar {
                            position: absolute;
                            bottom: 10px;
                            left: 10%;
                            width: 80%;
                            z-index: 10;
                        }
                        /* Ẩn input file mặc định của dx */
                        .dx-fileuploader-input-wrapper { display: none; }
                        .dx-fileuploader-wrapper { display: none; }
                    `;
                    document.head.appendChild(style);
                    window.__hpaFileDropzoneCSSInjected = true;
                }

                // 2. Xây dựng DOM
                $el.addClass("hpa-dropzone-wrapper");
                // Tạo ID duy nhất cho Dropzone để DevExpress bind đúng chỗ
                $el.attr("id", uniqueId);

                const $dropZone = $(`<div class="hpa-dropzone-box" id="${uniqueId}-zone"></div>`);
                $dropZone.css({ width: cfg.width, height: cfg.height });

                const $content = $(`<div class="hpa-dropzone-content"></div>`);
                const $img = $(`<img class="hpa-preview-img" src="${cfg.currentValue}" style="${cfg.currentValue ? '''' : ''display:none''}" />`);
                const $placeholder = $(`
                    <div class="hpa-placeholder-text" style="${cfg.currentValue ? ''display:none'' : ''''}">
                        <i class="dx-icon-image"></i>
                        <span>Kéo thả hoặc click để chọn</span>
                    </div>
                `);

                // Container ẩn cho control DevExpress
                const $dxUploaderContainer = $(`<div id="${uniqueId}-uploader"></div>`);
                const $dxProgressContainer = $(`<div class="hpa-upload-progress-bar" id="${uniqueId}-progress"></div>`);

                $content.append($img).append($placeholder);
                $dropZone.append($content).append($dxProgressContainer);
                $el.empty().append($dropZone).append($dxUploaderContainer);

                // 3. Khởi tạo DevExpress ProgressBar
                const progressBar = $dxProgressContainer.dxProgressBar({
                    min: 0,
                    max: 100,
                    width: "100%",
                    showStatus: false,
                    visible: false
                }).dxProgressBar("instance");

                // Helper functions
                const toggleActive = (isActive) => $dropZone.toggleClass("dropzone-active", isActive);
                const toggleView = (hasImage) => {
                    if (hasImage) {
                        $img.show();
                        $placeholder.hide();
                    } else {
                        $img.hide();
                        $placeholder.show();
                    }
                };

                // 4. Khởi tạo DevExpress FileUploader
                $dxUploaderContainer.dxFileUploader({
                    dialogTrigger: `#${uniqueId}-zone`,
                    dropZone: `#${uniqueId}-zone`,
                    multiple: false,
                    allowedFileExtensions: cfg.allowedExtensions,
                    maxFileSize: cfg.maxFileSize,
                    uploadMode: "instantly",
                    uploadUrl: cfg.uploadUrl,
                    visible: false, // Ẩn UI mặc định của DX

                    onDropZoneEnter: function({ component, dropZoneElement, event }) {
                        if (dropZoneElement.id === `${uniqueId}-zone`) {
                            const items = event.originalEvent.dataTransfer.items;
                            // Kiểm tra sơ bộ loại file
                            if (items && items.length > 0) {
                                 toggleActive(true);
                            }
                        }
                    },

                    onDropZoneLeave: function(e) {
                        if (e.dropZoneElement.id === `${uniqueId}-zone`) {
                            toggleActive(false);
                        }
                    },

                    onUploadStarted: function() {
                        toggleActive(false);
                        $img.css("opacity", "0.3");
                        progressBar.option("visible", true);
                        progressBar.option("value", 0);
                    },

                    onProgress: function(e) {
                        progressBar.option("value", (e.bytesLoaded / e.bytesTotal) * 100);
                    },

                    onUploaded: function(e) {
                        const file = e.file;
                        // Ví dụ response text: "/uploads/2023/image123.jpg" hoặc JSON "{ url: ... }"
                        let uploadedUrl = "";
                        try {
                            // Giả sử server trả về JSON hoặc plain text URL
                            // Bạn cần điều chỉnh dòng này tùy theo format trả về của Server
                             const response = JSON.parse(e.request.responseText);
                             uploadedUrl = response.url || response.path || e.request.responseText;
                        } catch (err) {
                            uploadedUrl = e.request.responseText; // Fallback plain text
                        }

                        // 1. Update Preview bằng FileReader để user thấy ngay (hoặc dùng URL từ server)
                        const fileReader = new FileReader();
                        fileReader.onload = function() {
                            $img.attr("src", fileReader.result);
                            $img.css("opacity", "1");
                            toggleView(true);
                        };
                        fileReader.readAsDataURL(file);

                        // 2. Reset UI
                        progressBar.option("visible", false);
                        progressBar.option("value", 0);

                        // 3. Logic Auto Save vào DB (giống hpaControlEditableRow)
                        if (cfg.tableName && cfg.columnName && cfg.idValue) {
                             saveToDatabase(uploadedUrl, cfg.idValue);
                        }

                        // 4. Callback ra ngoài
                        if (cfg.onSuccess) cfg.onSuccess(uploadedUrl, file);
                    },

                    onUploadError: function(e) {
                        progressBar.option("visible", false);
                        $img.css("opacity", "1");
                        toggleActive(false);
                        // Sử dụng uiManager nếu có, hoặc alert
                        if (typeof uiManager !== ''undefined'') {
                            uiManager.showAlert({ type: "error", message: "Upload thất bại: " + e.error.message });
                        } else {
                            alert("Upload thất bại!");
                        }
                        if (cfg.onError) cfg.onError(e);
                    }
                });

                // Hàm lưu dữ liệu vào DB (Tái sử dụng logic của bạn)
                function saveToDatabase(newVal, recordId) {
                    const params = [
                        "LoginID", (typeof LoginID !== ''undefined'' ? LoginID : 0), // Global variable check
                        "LanguageID", "VN",
                        "TableName", cfg.tableName,
           "ColumnName", cfg.columnName,
                        "IDColumnName", cfg.idColumnName,
                        "ColumnValue", newVal,
                        "ID_Value", recordId
                    ];

                    // Kiểm tra hàm Ajax có tồn tại không
                    if (typeof AjaxHPAParadise !== ''undefined'') {
                        AjaxHPAParadise({
                            data: { name: "sp_Common_SaveDataTable", param: params },
                            success: () => {
                                if (typeof uiManager !== ''undefined'')
                                    uiManager.showAlert({ type: "success", message: "%UpdateSuccess%" });
                            },
                            error: () => {
                                console.error("Lỗi lưu DB đường dẫn ảnh");
                            }
                        });
                    }
                }
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