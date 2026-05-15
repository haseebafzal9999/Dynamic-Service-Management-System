class tableClass {
    constructor(tableContent, tableSettings, results, searchFunc, tableArea = ".view-window", additionalEvents = "") {
        this.searchBuffer = [];
        this.currentContent = [];
        this.rowContent = [];
        this.settings = tableSettings;
        this.page = $('[data-page]').data('page');
        this.previousValue = "";
        this.elementCheck;
        this.filterName;
        this.editMode = false;
        this.initialRow;
        this.initialRowHeight;
        this.rowNo;
        this.itemId;
        this.td;
        this.searchFunc = searchFunc;
        this.searchItem = "";
        this.selectedCheckBoxes = 0;
        this.tdWidth;
        this.filterChecks;
        this.tableArea = tableArea;
        this.itemLink;
        this.popupState;
        this.dropdownList = results;
        this.currentDate = new Date();
        this.nextMonthDate = new Date(this.currentDate.getFullYear(), this.currentDate.getMonth() + 1, 1);
        this.startDate = "";
        this.endDate = "";
        this.dates = [];
        this.priceRangeFilter = false;
        this.datePicker = false;
        this.startup = true;
        this.additionalEvents = additionalEvents;
        this.generateTableHeader(this.settings.tableHeader);
        this.contentAvailable;
        this.createTableRows(tableContent, this.settings, this.tableArea);
        this.tableFilter();
        this.events();
        this.convertTableHeaderToSticky();

    }


    /* ORDER OF LOADING, EDITING AND SAVING ROWS */

    //generating all the headers for the table
    generateTableHeader(headerContent) {
        var self = this;
        var head = $(`${self.tableArea} thead tr`)
        var children;

        //if checkbox enabled then add the following
        if (self.settings.checkboxes) {
            children = `<th data-none class="selectTableContainer">
                            <div class="selectInnerTableContainer">
                                <label class="container">
                                    <input type="checkbox" class="selectAll"/>
                                    <span class="checkmark"> </span>
                                </label>
                            </div>
                        </th >`
        }


        //looping through all the headers
        for (var i = 0; i < headerContent.length; i++) {
            children += `<th id="${headerContent[i].name}">${headerContent[i].value}</th>`
        };

        //if the edit btn is enabled add the following
        if (self.settings.editable) {
            children += `<th id="editBtn"></th>`
        }

        //add all the children to the parent
        head.append(children)
    }


    //converting the table header to sticky
    convertTableHeaderToSticky() {
        var self = this;

        // Get the table head, table search filter container, and data filter menu elements
        const containerHeight = document.querySelector('.main-view');
        var addTop;
        // Listen for the scroll event on the window object
        containerHeight.addEventListener('scroll', () => {

            // Get the current scroll position
            const scrollPosition = $('.main-view').scrollTop();

            //getting the screen size
            var screenSize = $(window).width();

            //if the screen size is greater than a 768 then change the scroll margin
            if (screenSize < 768) {
                addTop = 241
            } else {
                addTop = 250
            }

            // Update the position of the table search filter container and data filter menu
            if (scrollPosition < 238) {
                $('thead').css('top', `0px`).css('border-bottom', `none`).css('box-shadow', `none`);;
            } else {
                //closing the filter bar
                $(`${self.tableArea} #cancelSearch`).trigger('click');
                var position = scrollPosition - addTop
                var positionFilter = scrollPosition - 15
                $('thead').css('top', `${position}px`).css('box-shadow', `0 0 0 1px #e1e3e5`);
            }
        });
    }


    //creating all the table rows
    createTableRows(contentArray, settings = this.settings, tableName = ".view-window") {
        var self = this;

        // Check if contentArray.length is less than 200
        var itemsToDisplay = contentArray.length < 200 ? contentArray.length : 200;

        if (itemsToDisplay > 0) {
            if (!self.startup) {
                $(`${tableName} .tableFilters`).css('display', 'flex');
            }

            self.contentAvailable = true;
            $(`${tableName} #noInfo`).css('display', 'none');
            $(`${tableName} .shortcutSearchContainer`).css('display', 'flex');
            $(`${tableName} #TableHead`).removeAttr("style");

            for (var i = 0; i < itemsToDisplay; i++) {
                var tableBody = $(`${tableName} .tableContainer tbody`);
                var tableRowContent = self.addTableContent(contentArray[i], settings);
                var children = `<tr data-ItemId="${contentArray[i].id}" data-itemLink="${contentArray[i].link}" data-xmin="${contentArray[i].xmin}">${tableRowContent}</tr>`;
                tableBody.append(children);
            }

            self.startup = false;

            // Add scroll event listener for lazy loading
            $(`.main-view`).off('scroll').on('scroll', function () {
                var scrollTop = $(this).scrollTop();
                var scrollHeight = $(this).prop('scrollHeight');
                var clientHeight = $(this).prop('clientHeight');

                // Check if the scroll bar is at the bottom
                if (scrollTop + clientHeight >= scrollHeight - 50) {
                    // Add 200 items at a time
                    var itemsToAdd = 200;
                    for (var i = itemsToDisplay; i < itemsToDisplay + itemsToAdd && i < contentArray.length; i++) {
                        var tableRowContent = self.addTableContent(contentArray[i], settings);
                        var children = `<tr data-ItemId="${contentArray[i].id}" data-itemLink="${contentArray[i].link}">${tableRowContent}</tr>`;
                        tableBody.append(children);
                    }

                    // Update the total number of items displayed
                    itemsToDisplay += itemsToAdd;
                }

                // Adding links
                self.links()
            });
        } else {
            if (self.startup) {
                $(`${tableName} #noInfoItems`).css('display', 'flex');
                $(`${tableName} #TableHead`).css('display', 'none');
            } else {
                $(`${tableName} #noInfo`).css('display', 'flex');
                $(`${tableName} #TableHead`).css('display', 'none');
            }
        }
    }


    //adding content to the table rows
    addTableContent(contentArray, settings = this.settings) {
        var self = this;
        self.settings = settings
        var children = "";

        if (self.settings.checkboxes) {
            children = `<td data-none a class="selectOptionWithinTableBody">
                            <div class="selectInnerTableContainer">
                                <label class="container">
                                    <input type="checkbox" />
                                    <div class="checkmark"> </div>
                                </label>
                            </div>
                        </td>`
        }


        for (var x = 0; x < self.settings.cols.length; x++) {
            self.filterName = contentArray[self.settings.cols[x].colName]

            if ((self.filterName == undefined) || self.filterName == null) {
                self.filterName = "-";
            }

            if (self.settings.cols[x].html == undefined) {
                children += `<td><div data-name="${self.settings.cols[x].colName}" data-editable="${self.settings.cols[x].editable}" style="min-width:70px; max-width:200px;">${self.filterName.trim()}</div></td>`
            }
            else {
                children += self.settings.cols[x].html(contentArray, self.filterName)
            }

        }

        if (self.settings.editable) {
            children += `<td data-none data-id="editContainer"><div data-id="buttons" style="width:75px;"><button data-id=editBtn><img class="editIcon" src="/images/edit.svg" alt="edit"><button data-id="saveRow" class="dimmed" disabled><img class="tickIcon" src="/images/rowTick.svg" alt="tick"></td>`
        }


        return children;
    }


    //adding all events to the table
    events() {
        var self = this;

        //determining the state of the row which has been clicked
        if (self.settings.editable) {
            self.rowState();
        }

        //generating links for the rows
        if (self.settings.links.available) {
            self.links();
        }

        //attaching an event to search
        self.search();

        //adding a resize event to resize the table rows when resizing the window
        self.windowResize();
    };




    /* GENERAL EVENTS */

    //an event which is fired when doing a search
    search() {

        var self = this;

        $(`${self.tableArea} #tableSearch`).off("keyup").on("keyup", (e) => {

            //clear the previous time out if a key is pressed within 300 milliseconds
            clearTimeout(searchTimer);

            //getting the text from the input field 
            var item = e.target.value.toLowerCase().trim();

            //setting the searchTimer
            var searchTimer = setTimeout(function () {

                //search cross function
                self.searchCross(item.length)

                //if the search buffer is cleared and the length of the text is greater than 1 or if the del/ backspace button is pressed
                if ((self.searchBuffer.length == 0 && item.length > 0) || (e.keyCode == 8) || (e.keyCode == 46)) {

                    //checking if a animation is running on the loadbar
                    if (!$('.loadingBar').is(':animated') && item.length > 0) {
                        $('.loadingBar').width("10%").fadeIn()
                    }

                    //adding a item to the search buffer
                    self.searchBuffer.push(item)

                    //setting the search item
                    self.searchItem = `Q${encodeURI(item)}`;

                    //checking to see that the item length is not blank
                    if (item.length > 0) {
                        $(`${self.tableArea} #crossSearch`).show();
                        $(`${self.tableArea} #crossSearch`).off('click').on('click', (e) => {
                            $(`${self.tableArea} .tableSearchContainer #tableSearch`).val('')
                            self.searchItem = "";
                            self.filterChecks(e);
                            $(`${self.tableArea} #crossSearch`).hide();
                            $(`${self.tableArea} .tableSearchContainer`).removeClass("focusTableSearchContainer")
                        })
                    }

                    self.filterChecks(e);

                    //clearing the search buffer
                    self.searchBuffer = []

                    //setting the previous value
                    self.previousValue = item
                }
            }, 300)
        });

        $(`body`).off(`click.${self.tableArea}`).on(`click.${self.tableArea}`, (e) => {
            const filterPopup = $(e.target).closest('.filterPopup');
            const filterBtn = $(e.target).closest('.tableFiltersBtn');

            if (e.target.id === "tableSearch" || e.target.id === "searchFilter") {
                $(`${self.tableArea} .tableSearchContainer`).addClass("focusTableSearchContainer");
                $(`${self.tableArea} #crossSearch`).show();
            } else {
                $(`${self.tableArea} .tableSearchContainer`).removeClass("focusTableSearchContainer");
                $(`${self.tableArea} #crossSearch`).hide();
            }

            if (filterPopup.length === 0 && filterBtn.length === 0) {
                $(`${self.tableArea} .filterPopup`).addClass("hidden");
            }
        });

    };


    //determine the state of the row
    rowState() {
        var self = this;

        $('.tableContainer tbody').off('click').on('click', (e) => {
            //get the current row number
            self.rowNo = $(e.target).closest('tr').index()

            //getting the button state
            var btnState = $(e.target).data('id')

            switch (btnState) {
                case "crossBtn":
                    self.crossBtnState();
                    break
                case "editBtn":
                    self.editBtnState(e);
                    break
                case "saveRow":
                    self.saveRowBtnState();
                    break
            }
        });
    }


    //an event which is fired when cancelling edit miode
    crossBtnState() {

        var self = this;

        $(`.tableContainer tbody tr:eq(${self.rowNo}) [data-id="editBtn"] img`).removeAttr('src').attr("src", "/images/edit.svg").addClass('editIcon').removeClass('rowCross').removeClass('saveRow')

        //remove the bg colour on the row 
        $(`.tableContainer tbody tr:eq(${self.rowNo})`).removeClass('selectedRowEdit')

        //replace the html with the new old html before editing
        $(`.tableContainer tbody tr:eq(${self.rowNo})`)[0].innerHTML = self.initialRow;

        //setting the row height back to normal
        $(`.tableContainer tbody tr:eq(${self.rowNo})`).height(self.initialRowHeight)

        //removing the cross from the row
        $(`.tableContainer tbody tr:eq(${self.rowNo}) [data-id="crossBtn"]`).remove()

        //enabling all edit btns
        $(`.tableContainer tbody [data-id="editBtn"]`).removeAttr("disabled").css("opacity", "1")

        //changing the state of the mode the row is in
        self.editMode = false

        //enable links if available
        if (self.settings.links.available) {
            self.links()
        }

        if (self.settings.checkboxes) {
            //adding events back to the checkbox
            selectBoxesProducts.events();

            //centering all the checkboxes
            selectBoxesProducts.checkBoxCenter()
        }
    }


    //an event which is fired when editing a row
    editBtnState(e) {

        var self = this;

        //clearing out the content of the previous row
        self.rowContent = [];

        //changing the state of the mode the row is in
        self.editMode = true;

        //disabling all edit buttons
        $(`.tableContainer tbody [data-id="editBtn"]`).attr("disabled", true).css("opacity", "0.5")

        //getting the intial row
        self.initialRow = $(`.tableContainer tbody tr:eq(${self.rowNo})`)[0].innerHTML;

        //getting the intial row height
        self.initialRowHeight = $(`.tableContainer tbody tr:eq(${self.rowNo})`).height()

        //removing the edit btn
        $(`.tableContainer tbody tr:eq(${self.rowNo}) [data-id="editBtn"]`).remove()

        //adding a cancel button
        $(`.tableContainer tbody tr:eq(${self.rowNo}) [data-id="buttons"]`).append(`<button data-id="crossBtn"><img class="rowCross" src="/images/filter cross.svg" alt="cross"></button>`)

        //getting all the editable fields
        var editFields = $(`.tableContainer tbody tr:eq(${self.rowNo}) [data-editable="true"]`)

        //looping through all the fields
        for (var y = 0; y < editFields.length; y++) {

            //getting the current cell
            var cell = $(editFields)[y]

            //matching the name of the element within the cell to the settings 
            var filteredSettings = self.settings.cols.filter(x => {
                return x.colName == $(cell).data('name')
            })

            //checking the cell can be edited
            if (filteredSettings[0].editable) {

                //getting the text within the cell
                var tdText = $(cell).text()

                //getting the parent element
                self.td = cell.parentElement

                //getting the width and height of the cell
                self.tdWidth = cell.getBoundingClientRect()

                //empty the cell
                $(self.td).empty();

                //check the settings to see which type of field the cell needs
                switch (filteredSettings[0].fieldType) {
                    case "text":
                        $(self.td).append(`<div data-name="${filteredSettings[0].colName}" data-id="editField" class="editInputContainer" style="width:${self.tdWidth.width}px;"><textarea  class="editInput" style="height:${self.tdWidth.height + 12}px;">${tdText}</textarea></div>`)
                        self.rowContent.push({ index: y, value: tdText })
                        if (filteredSettings[0].customFunction != undefined) {
                            filteredSettings[0].customFunction(self.rowNo)
                        }
                        break;
                    case "dropdown":
                        $(self.td).append(`<select data-name="${filteredSettings[0].colName}" data-id="editField" class="selectOptionEdit" style="min-width:90px; max-width:${self.tdWidth.width}px;"></select>`);
                        var elementToAppendTo = $(`tbody tr:eq(${self.rowNo}) [data-name="${filteredSettings[0].colName}"]`)[0]
                        filteredSettings[0].contentList(self.dropdownList[filteredSettings[0].colName], tdText, elementToAppendTo);
                        break;
                }
            }
        }

        //show the save btn disabled
        $(`.tableContainer tbody tr:eq(${self.rowNo}) [data-id="saveRow"]`).show();

        //add a minimum width to the buttons 
        $(`.tableContainer tbody tr:eq(${self.rowNo}) [data-id="buttons"]`).css('min-width', '75px')

        //add a bg colour to the row to show that it is selected
        $(`.tableContainer tbody tr:eq(${self.rowNo})`).addClass('selectedRowEdit')

        //getting the orginal dropdowns values
        var dropDownOptions = $(`.tableContainer tbody tr:eq(${self.rowNo}) .selectOptionEdit :selected`);

        //pushing the default values of the dropdown into the array
        for (var x = 0; x < dropDownOptions.length; x++) {
            self.rowContent.push({ index: x, value: dropDownOptions[x].innerText })
        };

        //getting the maximum size that the row can be
        var rowSize = self.resizeInput()

        //resizing the row
        $(`.tableContainer tbody tr:eq(${self.rowNo})`).height(rowSize + 25)

        //getting all the editable text fields 
        var allEditField = $('.editInput');

        //setting the height of the text boxes based on the content within
        for (var x = 0; x < allEditField.length; x++) {
            $(allEditField)[x].style.height = '0px';
            $(allEditField)[x].style.height = `${allEditField[x].scrollHeight + 2}px`
        }

        //checking to see if the content within the row has changed and increasing the height of the text boxes when on a new line 
        $('.editInput').off('keyup').on('keyup', (e) => {
            $(e.target).height(0)
            $(e.target).height(e.target.scrollHeight - 8)
            var maxSize = self.resizeInput()
            $(e.target).closest('tr').height(maxSize + 25)
            self.rowCheck(e, self.rowNo, self.rowContent);

            if (self.settings.checkboxes) {
                selectBoxesProducts.checkBoxCenter()
            }
        });

        //checking to see if the dropdown options have changed 
        $('.selectOptionEdit').off('change').on('change', (e) => {
            self.rowCheck(e, self.rowNo, self.rowContent);
        });
    }


    //an event which is fired when saving a row
    saveRowBtnState() {

        var self = this;

        //hiding the save button after it has been pressed
        $(`.tableContainer tbody tr:eq(${self.rowNo}) [data-id="saveRow"]`).hide();

        //removing the cross from the row
        $(`.tableContainer tbody tr:eq(${self.rowNo}) [data-id="crossBtn"]`).remove()

        //adding a cancel button
        $(`.tableContainer tbody tr:eq(${self.rowNo}) [data-id="buttons"]`).append(`<button data-id="editBtn"><img class="editIcon" src="/images/edit.svg" alt="edit"></button>`)

        //api call to save the data and getting the name of the function and passing a param
        //var functionObj = window[self.settings.edit];
        //functionObj(self.rowNo)

        self.editStateSave(self.rowNo)

        //enabling all edit btns
        $(`.tableContainer tbody [data-id="editBtn"]`).removeAttr("disabled").css("opacity", "1")

        //remove the bg colour on the row 
        $(`.tableContainer tbody tr:eq(${self.rowNo})`).removeClass('selectedRowEdit')

        //changing the state of the mode the row is in
        self.editMode = false

        //enable links if available
        if (self.settings.links.available) {
            self.links()
        }
    }


    //cross button on the search bar
    searchCross(stringLength) {
        var self = this;
        if (stringLength > 0) {
            $(`${self.tableArea} #crossSearch`).show();
            $(`${self.tableArea} #crossSearch`).off('click').on('click', (e) => {
                $(`${self.tableArea} .tableSearchContainer #tableSearch`).val('')
                $(`${self.tableArea} #crossSearch`).hide();
                $(`${self.tableArea} .tableSearchContainer`).removeClass("focusTableSearchContainer")

            })
        }
        else {
            $(`${self.tableArea} #crossSearch`).hide();
        }
    }






    /* FILTERS */

    //table filters
    tableFilter() {
        var self = this;
        var result = "";
        var children = "";

        if (self.settings.filterTypes != undefined && self.contentAvailable == true) {

            //creating the filter popup and adding it to the DOM
            self.settings.filterTypes.filters.forEach(x => {

                if (x.typeOfFilter == undefined) {
                    children += `<div class="tableFiltersBtn" data-pos=${x.position} data-name="${x.name}" data-type="selectDropdown">
                            <div class="containerCrossArrowName">
                                <button>
                                    <div class="filterIconContainer"">
                                        <p>${x.name}</p>
                                        <svg style="width:18px;" class="chevy" viewBox="0 0 20 20"><path fill-rule="evenodd" d="M5.72 8.47a.75.75 0 0 1 1.06 0l3.47 3.47 3.47-3.47a.75.75 0 1 1 1.06 1.06l-4 4a.75.75 0 0 1-1.06 0l-4-4a.75.75 0 0 1 0-1.06Z"></path></svg>
                                    </div>
                                </button>
                                <div class="crossFilter hidden">
                                    <svg xmlns="http://www.w3.org/2000/svg" fill="#000000" style="width:15px; pointer-events: none; height: 15px; margin-left: 5px;" viewBox="0 0 24 24" data-name="Flat Color"><path id="primary" d="M13.41,12l6.3-6.29a1,1,0,1,0-1.42-1.42L12,10.59,5.71,4.29A1,1,0,0,0,4.29,5.71L10.59,12l-6.3,6.29a1,1,0,0,0,0,1.42,1,1,0,0,0,1.42,0L12,13.41l6.29,6.3a1,1,0,0,0,1.42,0,1,1,0,0,0,0-1.42Z" style="fill: rgb(0, 0, 0);"></path></svg>
                                </div>
                            </div>
                            <div class="filterPopup hidden" style="width:${x.widthSize != undefined ? x.widthSize : 200};">
                                <div class="filterPopupContainer">
                                    <input id="popupSearch" placeholder="Search">
                                </div>
                                <div class="text-danger text-align-margin hidden">Select at least 1 option</div>
                                <div data-filterPopupContent></div>
                                <div class="filterMe hidden">Filter</div>
                                <div class="clearFilter hidden">Clear</div>
                                <div class="hidden noResults">No Results Found</div>
                            </div>
                        </div>`
                }
                else {

                    // Get the function object based on the typeOfFilter
                    var filterFunction = self[x.typeOfFilter];
                    children += filterFunction(x, self);

                }
            });

            //Appending the filter to the table
            $(`${self.settings.tableNameId} .tableFilters`).append(children);


            //making an api call to get the popup list information
            self.filterListsInfo(self.settings.filterTypes.filters, self.settings.filterTypes.url);


            //opening and closing the popup
            $(`${self.settings.tableNameId} .tableFiltersBtn button`).off('click').on('click', (e) => {

                //getting the closest button
                var currentTarget = $(e.currentTarget).closest('.tableFiltersBtn');

                //clear and cross button
                var currentClearBtn = currentTarget.find('.clearFilter');
                var currentClearCrossBtn = currentTarget.find('.crossFilter');

                //when typing in the search bar
                $(currentTarget).find(`#popupSearch`).off('keyup').on('keyup', (e) => {
                    self.popupSearch(currentTarget)
                });

                //finding the correct popup to open
                var filterPopup = $(currentTarget).find('.filterPopup').css({
                    "max-height": "none",
                    "width": "auto"
                });

                //if the popup is already open then close it otherwise open it
                if ($(filterPopup).hasClass('hidden')) {
                    $('.filterPopup').addClass('hidden')
                    filterPopup.removeClass('hidden');

                    //show the filter pop up
                    filterPopup.fadeIn().css('display', 'block');
                } else {
                    $('.filterPopup').addClass('hidden')
                }

                //hiding the error message
                //$('.text-danger').addClass('hidden')

                //when clicking on the filter items
                $(`${self.settings.tableNameId} [data-filterItems]`).off('click').on('click', (x) => {

                    //if the your not clicking on the checkebox
                    if (x.target.type != "checkbox") {

                        //checking to see if the input is selected
                        var input = $(x.target).find('input')

                        //if the element is selected then we untick otherwise we check it
                        if (input[0].checked == true) {
                            input[0].checked = false;
                        }
                        else {
                            input[0].checked = true;
                        }
                    };

                    //running the filter check function
                    self.filterChecks(x)
                });


                //checking to see if there is a cross or clear button
                if (currentClearCrossBtn.length != 0 && currentClearBtn != 0) {

                    //when clicking the clear or cross button on the filters
                    $([currentClearCrossBtn[0], currentClearBtn[0]]).off('click').on('click', (x) => {

                        //checking to see which check boxes are checked
                        var selectedCheckBoxes = currentTarget.find('[data-filterpopupcontent] input[type="checkbox"]:checked');

                        //going through each check box and unchecking them
                        selectedCheckBoxes.each(function () {
                            this.checked = false;
                        });

                        //running the filter check function
                        self.filterChecks(x)
                    })
                }
            });

        }
    };


    //getting the filter popup infomation
    filterListsInfo(filters, url) {
        var self = this;
        $.ajax({
            url: url,
            type: 'GET',
            contentType: 'application/json',
            success: function (results, status, jqXHR) {

                //looping through the filters
                for (var x = 0; x < filters.length; x++) {

                    //matching the filter to the filter name
                    var filteredList = results.lists[0][filters[x].listname]
                    var children = ""

                    //if the filtered list is not undefined
                    if (filteredList != undefined) {
                        //looping through the filtered list
                        for (var y = 0; y < filteredList.length; y++) {
                            children += `<div data-filterItems data-value="${filteredList[y].value}"><input class="popupSelectBoxes" type="checkbox"/><p>${filteredList[y].name}</p></div>`
                        }

                        //add the list to the filter
                        $(`${self.settings.tableNameId} [data-pos=${filters[x].position}] [data-filterPopupContent]`).append(children);
                    }
                }
                // --- PRICE SLIDER INIT (add this at the end of the success handler) ---
                // --- PRICE SLIDER INIT (updated to initialize each priceRange filter individually) ---
                try {
                    // prefer the lists object at results.lists[0], fallback to results.lists
                    var listsObj = results && results.lists && results.lists[0] ? results.lists[0] : results.lists;

                    // find all priceRange filter configs (there may be multiple: SellPrice, CostPrice)
                    var priceFilterConfigs = self.settings && self.settings.filterTypes && self.settings.filterTypes.filters
                        ? self.settings.filterTypes.filters.filter(function (f) { return f.typeOfFilter === 'priceRange'; })
                        : [];

                    priceFilterConfigs.forEach(function (priceFilterConfig) {
                        var pos = priceFilterConfig.position;
                        var field = priceFilterConfig.queryNameField || 'SellPrice';
                        var priceLists = (listsObj && listsObj.priceLists) ? listsObj.priceLists : [];
                        var chosen = priceLists.find(function (p) { return p.value === field; }) || priceLists[0];

                        var min = 0, max = 1000;
                        if (chosen && chosen.min != null && chosen.max != null) {
                            min = Math.floor(Number(chosen.min) || 0);
                            max = Math.ceil(Number(chosen.max) || (min + 1));
                        } else {
                            // try hitting the PriceRange endpoint as a fallback per field (optional)
                            min = 0; max = 1000;
                        }

                        try { self.initialisePriceSlider(min, max, pos); } catch (err) { console.error(err); }
                    });
                } catch (err) {
                    console.error('Price slider init error', err);
                    try {
                        // fallback: init the first priceRange filter if exists
                        var anyPrice = self.settings && self.settings.filterTypes && self.settings.filterTypes.filters
                            ? self.settings.filterTypes.filters.find(function (f) { return f.typeOfFilter === 'priceRange'; })
                            : null;
                        if (anyPrice) self.initialisePriceSlider(0, 1000, anyPrice.position);
                    } catch (e) { console.error(e); }
                }

            },
            error: function (error) {
                console.log(error)
            }
        });
    }


    //checking the filter items and which filters are active
    filterChecks(x) {
        var self = this

        //creating a child varible 
        var children = "";

        //checking to see which btn was clicked
        var popup = $(x.target).closest('.tableFiltersBtn');

        //getting the name of current filter
        var currentFilterType = $(popup).attr('data-type');

        //finding the position of the button
        var btnPos = $(popup).data("pos")

        //clear & cross filter btn
        var clearBtn = popup.find('.clearFilter')
        var crossBtn = popup.find('.crossFilter')

        //getting the url for popup filter
        var getUrl = self.settings.search.apiUrl;



        /* SELECT DROPDOWN */
        //checking how many boxes are checked all together
        var selectedCheckBoxes = $('[data-filterpopupcontent] input[type="checkbox"]:checked');

        //putting all the value into a query string
        selectedCheckBoxes.each(function () {
            var inputParentPos = $(this).closest('[data-pos]').data('pos');
            var queryName = self.settings.filterTypes.filters.filter(x => {
                return x.position == inputParentPos
            });
            children += `${queryName[0].queryName}=${$(this).closest('[data-value]').data('value')}&`;
        });

        if ($('[data-customer-id]').length != 0) {
            children += `customerId=${$('[data-customer-id]').attr("data-customer-id") }&`
        };

        if ($('[data-fleet-id]').length != 0) {
            children += `vehicleId=${$('[data-fleet-id]').attr("data-fleet-id")}&`
        };

        if ($('[data-contractId]').length != 0) {
            children += `contractId=${$('[data-contractId]').attr("data-contractId")}&`
        };

        //if the selectDropdown filter is active
        if (currentFilterType == "selectDropdown") {

            //checking how many boxes are checked in the current popup
            var currentSelectedCheckBoxes = popup.find('[data-filterpopupcontent] input[type="checkbox"]:checked');

            //if the checked box is checked then we change the text within the button
            if (currentSelectedCheckBoxes.length > 1) {
                $(`${self.settings.tableNameId} [data-pos="${btnPos}"] .filterIconContainer p`).text("Multiple Selected")
            }
            else if (currentSelectedCheckBoxes.length == 1) {
                var selectedCheckBoxes1 = $(currentSelectedCheckBoxes).closest('[data-filteritems]');
                var filterItemName = $(selectedCheckBoxes1).find('p')
                $(`${self.settings.tableNameId} [data-pos="${btnPos}"] .filterIconContainer p`).text(filterItemName[0].innerText)
            }
            else {
                var originalName = $(`${self.settings.tableNameId} [data-pos="${btnPos}"]`).data('name')
                $(`${self.settings.tableNameId} [data-pos="${btnPos}"] .filterIconContainer p`).text(originalName)
            };

            //if there are boxes selected show the cross and hide the arrow
            if (currentSelectedCheckBoxes.length > 0) {
                $([clearBtn[0], crossBtn[0]]).removeClass('hidden');
                $(`[data-pos="${btnPos}"] .chevy`).addClass('hidden');
            }
            else {
                $([clearBtn[0], crossBtn[0]]).addClass('hidden')
                $(`[data-pos="${btnPos}"] .chevy`).removeClass('hidden');
            };
        };




        /* PRICE RANGE */
        //if price range is active
        if (self.priceRangeFilter) {
            // try to find the closest popup container from the event target, else find all
            var popup = $(x.target).closest('.tableFiltersBtn');
            var priceRangeFilter = popup.length ? popup.find('.range-input input') : $('.range-input input');

            priceRangeFilter.each(function () {
                var inputParentPos = $(this).closest('[data-pos]').data('pos');
                var queryName = self.settings.filterTypes.filters.filter(f => f.position == inputParentPos);
                if (queryName && queryName[0]) {
                    children += `${queryName[0].queryName}=${$(this).val()}&`;
                }
            });
        }





        /* DATE PICKER */
        //if the date picker is active
        if (self.datePicker) {
            var dateRangeFilter = $('#datePicker .selectedDataCell');

            //checking if we are on the date created filter
            if (currentFilterType == "dateFilter") {

                //setting the date range text in the filter button
                var btnText = dateRangeFilter.length == 0 ? 'Date Created' : `${dateRangeFilter[0].dataset.date} - ${dateRangeFilter[1].dataset.date}`;
                $(`[data-type="dateFilter"]`).find('.filterIconContainer p').text(btnText);

                //hiding the arrow as the filter is applied
                $(`[data-type="dateFilter"]`).find(`.chevy`).addClass('hidden');

                //showing the cross
                $(`[data-type="dateFilter"]`).find(`.crossFilterCustom `).removeClass('hidden');
            }

            //creating a date range
            dateRangeFilter.each(function () {
                var inputParentPos = $(this).closest('[data-pos]').data('pos');
                var queryName = self.settings.filterTypes.filters.filter(x => {
                    return x.position == inputParentPos
                });

                // returns a date string in "dd-MM-yyyy" format
                var dateStr = $(this).data("date");
                var parts = dateStr.split("-"); // Split the date string into parts

                // create a new Date object using the parts from the date string
                var date = new Date(parts[2], parts[1] - 1, parts[0]); // parts[1] - 1 to adjust for zero-based month index

                // convert the Date object to a string in the desired format (e.g., "MM-dd-yyyy")
                var formattedDate = ("0" + (date.getMonth() + 1)).slice(-2) + "-" + ("0" + date.getDate()).slice(-2) + "-" + date.getFullYear();

                // add the formatted date to the children string
                children += `${queryName[0].queryName}=${formattedDate}&`;
            });
        }



        /* SEARCH */
        if (self.searchItem != "") {
            children += `sT=${self.searchItem}&`;
        };



        //sending the data back and appending the results to the view
        self.filteredList(getUrl, children.slice(0, -1));
    };


    //returning the filtered information and appending it to the view
    filteredList(url, data) {
        var self = this;
        var combinedUrl = url + "?" + data
        $.ajax({
            url: combinedUrl,
            type: 'GET',
            contentType: 'application/json',
            success: function (results, status, jqXHR) {

                //if there are no records hide the filters
                if (results.lists.length == 0) {
                    $(`.tableFilters`).addClass('tableFiltersBottomBorder')
                } else {
                    $(`.tableFilters`).removeClass('tableFiltersBottomBorder')
                }

                //removing elements from the dom
                var tbody = $(`${self.settings.tableNameId} .tableContainer tbody tr`);

                //removing all the items from the dom
                tbody.remove();

                //creates table rows
                self.createTableRows(results.lists, self.settings, self.settings.tableNameId);

                //adds links to the rows
                if (self.settings.links.available) {
                    self.links();
                }

                //setting table headers to sticky
                self.convertTableHeaderToSticky();


                if (self.additionalEvents != "" && self.additionalEvents != undefined) {
                    self.additionalEvents();
                };

                //Animating the loading bar to full width and fading it out
                $('.loadingBar').animate({
                    width: "100%",
                }, 300);
                $('.loadingBar').fadeOut()
            },
            error: function (error) {
                console.log(error)
            }
        });
    }


    //running the search function
    popupSearch(currentTarget) {

        //default value for the results
        var resultsFound = 0;

        //getting the popupSearch
        var input = $(currentTarget).find('#popupSearch');

        //getting the input values
        var filter = $(input).val().toLowerCase();

        //getting all the items within the popup list
        var menuItems = $(currentTarget).find('[data-filteritems]');

        //looping through the list and comparing the input to the menu items
        for (var i = 0; i < menuItems.length; i++) {
            var a = menuItems[i];
            var txtValue = a.textContent || a.innerText;
            if (txtValue.toLowerCase().indexOf(filter) > -1) {
                menuItems[i].style.display = "";
                resultsFound++
            } else {
                menuItems[i].style.display = "none";
            };
        };

        //if there are no results found then we display the error message otherwise we hide it
        if (resultsFound == 0) {
            $('.noResults').removeClass('hidden')
        }
        else {
            $('.noResults').addClass('hidden')
        }
    };




    /* PRICE FILTER */

    //adding the pricing range
    // adding the pricing range
    priceRange(x, self) {
        self.priceRangeFilter = true;
        var pos = x.position;
        const children = `
<div class="tableFiltersBtn" data-pos=${pos} data-name="${x.name}" data-type="${x.typeOfFilter}">
  <div class="containerCrossArrowName">
    <button>
      <div class="filterIconContainer">
        <p>${x.name}</p>
        <svg style="width:18px;" class="chevy" viewBox="0 0 20 20">
          <path fill-rule="evenodd" d="M5.72 8.47a.75.75 0 0 1 1.06 0l3.47 3.47 3.47-3.47a.75.75 0 1 1 1.06 1.06l-4 4a.75.75 0 0 1-1.06 0l-4-4a.75.75 0 0 1 0-1.06Z"></path>
        </svg>
      </div>
    </button>
    <div class="crossFilterCustom hidden">
      <svg xmlns="http://www.w3.org/2000/svg" fill="#000000" style="width:15px;height:15px;margin-left:5px;" viewBox="0 0 24 24">
        <path id="primary" d="M13.41,12l6.3-6.29a1,1,0,1,0-1.42-1.42L12,10.59,5.71,4.29A1,1,0,0,0,4.29,5.71L10.59,12l-6.3,6.29a1,1,0,0,0,0,1.42,1,1,0,0,0,1.42,0L12,13.41l6.29,6.3a1,1,0,0,0,1.42,0,1,1,0,0,0,0-1.42Z"></path>
      </svg>
    </div>
  </div>

  <div class="filterPopup hidden" data-pos="${pos}">
    <div class="price-slider-wrapper">
      <div class="slider-track">
        <!-- visible range inputs -->
        <input type="range" class="min-range" step="1" data-pos="${pos}">
        <input type="range" class="max-range" step="1" data-pos="${pos}">
      </div>

      <!-- wrapper so filterChecks finds the inputs (hidden inputs, unique IDs) -->
      <div class="range-input">
        <input type="hidden" class="min-range-hidden" id="min-price-${pos}" />
        <input type="hidden" class="max-range-hidden" id="max-price-${pos}" />
      </div>

      <div class="price-inputs">
        <div class="price-box">
          <span>&pound;</span>
          <input type="text" id="min-price-display-${pos}" readonly>
        </div>
        <div class="price-box">
          <span>&pound;</span>
          <input type="text" id="max-price-display-${pos}" readonly>
        </div>
      </div>
    </div>
  </div>
</div>`;
        return children;
    }




    //setting the min and max value for price range slider withi events
    // setting the min and max value for price range slider with events (now scoped by pos)
    initialisePriceSlider(minValue, maxValue, pos) {
        var self = this;
        // locate the specific popup container for this pos
        var container = $(`${self.settings.tableNameId} [data-pos="${pos}"] .filterPopup[data-pos="${pos}"]`);
        if (!container || container.length === 0) {
            // fallback: try any .filterPopup inside the pos element
            container = $(`${self.settings.tableNameId} [data-pos="${pos}"] .filterPopup`);
        }

        // visible slider inputs (they have data-pos attr)
        var minRange = container.find('.slider-track .min-range');
        var maxRange = container.find('.slider-track .max-range');

        // hidden inputs for filterChecks
        var minHidden = container.find(`#min-price-${pos}`);
        var maxHidden = container.find(`#max-price-${pos}`);

        // display inputs
        var minInputDisplay = container.find(`#min-price-display-${pos}`);
        var maxInputDisplay = container.find(`#max-price-display-${pos}`);

        // Set default values (ensure elements exist)
        minRange.attr({ min: minValue, max: maxValue, value: minValue });
        maxRange.attr({ min: minValue, max: maxValue, value: maxValue });

        // hidden inputs to be used by filterChecks (they expect inputs under .range-input)
        if (minHidden.length) minHidden.val(minValue);
        if (maxHidden.length) maxHidden.val(maxValue);

        if (minInputDisplay.length) minInputDisplay.val(minValue.toFixed(2));
        if (maxInputDisplay.length) maxInputDisplay.val(maxValue.toFixed(2));

        const gap = 1;

        // --- NEW: function to paint the gradient on the two range inputs ---
        function updateSliderTrackVisual() {
            // ensure native DOM nodes
            var minEl = minRange[0];
            var maxEl = maxRange[0];
            if (!minEl || !maxEl) return;

            var min = parseInt(minEl.min || 0, 10);
            var max = parseInt(minEl.max || 1000, 10);
            var minVal = parseInt(minEl.value || min, 10);
            var maxVal = parseInt(maxEl.value || max, 10);

            // protect against division by zero
            if (max <= min) { max = min + 1; }

            var percent1 = ((minVal - min) / (max - min)) * 100;
            var percent2 = ((maxVal - min) / (max - min)) * 100;

            // clamp
            percent1 = Math.max(0, Math.min(100, percent1));
            percent2 = Math.max(0, Math.min(100, percent2));

            // colors - update to the purple/gray you want
            var inactive = '#d3d3d3'; // gray (outside)
            var active = '#7e22ce';   // purple (selected range)

            var gradient = `linear-gradient(to right, ${inactive} ${percent1}%, ${active} ${percent1}%, ${active} ${percent2}%, ${inactive} ${percent2}%)`;

            // apply gradient to both inputs so it appears consistent across browsers
            minEl.style.background = gradient;
            maxEl.style.background = gradient;
            minEl.style.zIndex = 5;
            maxEl.style.zIndex = 5;
        }

        function updateSlider(e) {
            var target = (e && e.target) ? e.target : this;

            // read values using the scoped inputs
            let minVal = parseInt(minRange.val(), 10);
            let maxVal = parseInt(maxRange.val(), 10);

            // enforce gap using the actual target's class
            if (maxVal - minVal <= gap) {
                if (target.classList && target.classList.contains("min-range")) {
                    minVal = maxVal - gap;
                    minRange.val(minVal);
                } else {
                    maxVal = minVal + gap;
                    maxRange.val(maxVal);
                }
            }

            // update hidden/display inputs
            if (minHidden.length) minHidden.val(minVal);
            if (maxHidden.length) maxHidden.val(maxVal);
            if (minInputDisplay.length) minInputDisplay.val(minVal.toFixed(2));
            if (maxInputDisplay.length) maxInputDisplay.val(maxVal.toFixed(2));

            // Update label text in button (scoped by data-type + pos)
            const controlElem = $(`${self.settings.tableNameId} [data-pos="${pos}"][data-type="priceRange"]`);
            const controlName = controlElem.attr("data-name") || $('[data-type="priceRange"]').attr("data-name");
            if (minVal === minValue && maxVal === maxValue) {
                controlElem.find('.filterIconContainer p').text(controlName);
                controlElem.find('.chevy').removeClass('hidden');
                controlElem.find('.crossFilterCustom').addClass('hidden');
            } else {
                controlElem.find('.filterIconContainer p').text(`$${minVal} - $${maxVal}`);
                controlElem.find('.chevy').addClass('hidden');
                controlElem.find('.crossFilterCustom').removeClass('hidden');
            }

            // update the visual gradient
            try { updateSliderTrackVisual(); } catch (err) { console.error(err); }

            // Build a tiny event-like object that filterChecks expects
            var eventLike = { target: container[0] || target };

            setTimeout(() => {
                try { self.filterChecks(eventLike); } catch (err) { console.error(err); }
            }, 300);
        }

        // bind handlers for this container's sliders only
        minRange.off("input").on("input", updateSlider);
        maxRange.off("input").on("input", updateSlider);

        // initialize gradient on load (important)
        try { updateSliderTrackVisual(); } catch (err) { console.error(err); }

        // Reset when clicking the cross — scope the click to this filter button
        var crossBtn = $(`${self.settings.tableNameId} [data-pos="${pos}"] .crossFilterCustom`);
        crossBtn.off("click").on("click", (e) => {
            minRange.val(minValue);
            maxRange.val(maxValue);
            if (minHidden.length) minHidden.val(minValue);
            if (maxHidden.length) maxHidden.val(maxValue);
            if (minInputDisplay.length) minInputDisplay.val(minValue.toFixed(2));
            if (maxInputDisplay.length) maxInputDisplay.val(maxValue.toFixed(2));
            $(`${self.settings.tableNameId} [data-pos="${pos}"] .filterIconContainer p`).text(
                $(`${self.settings.tableNameId} [data-pos="${pos}"]`).attr("data-name")
            );
            // update visual
            try { updateSliderTrackVisual(); } catch (err) { console.error(err); }
            // call filterChecks with scoped container as target
            try { self.filterChecks({ target: container[0] }); } catch (err) { console.error(err); }
        });
    }







    /* DATE FILTER */

    //adding a date filter
    dateFilter(x, self) {
        self.datePicker = true;
        var children = `<div class="tableFiltersBtn" data-pos=${x.position} data-name="${x.name}" data-type="${x.typeOfFilter}">
                            <div class="containerCrossArrowName">
                                <button>
                                    <div class="filterIconContainer"">
                                        <p>${x.name}</p>
                                        <svg style="width:18px;" class="chevy" viewBox="0 0 20 20"><path fill-rule="evenodd" d="M5.72 8.47a.75.75 0 0 1 1.06 0l3.47 3.47 3.47-3.47a.75.75 0 1 1 1.06 1.06l-4 4a.75.75 0 0 1-1.06 0l-4-4a.75.75 0 0 1 0-1.06Z"></path></svg>
                                    </div>
                                </button>
                                <div class="crossFilterCustom hidden">
                                    <svg xmlns="http://www.w3.org/2000/svg" fill="#000000" style="width:15px; pointer-events: none; height: 15px; margin-left: 5px;" viewBox="0 0 24 24" data-name="Flat Color"><path id="primary" d="M13.41,12l6.3-6.29a1,1,0,1,0-1.42-1.42L12,10.59,5.71,4.29A1,1,0,0,0,4.29,5.71L10.59,12l-6.3,6.29a1,1,0,0,0,0,1.42,1,1,0,0,0,1.42,0L12,13.41l6.29,6.3a1,1,0,0,0,1.42,0,1,1,0,0,0,0-1.42Z" style="fill: rgb(0, 0, 0);"></path></svg>
                                </div>
                            </div>
                            <div class="filterPopup dateFilterPopup hidden">
                                <div class="date-picker" >
                                    <div class="calendar-container calendar-container-range">
                                    <div class="calendar">
                                        <input id="startInput" class="dateInput" type="text" placeholder="DD-MM-YYYY" autocomplete="off" />
                                        <div class="btnTitleCont">
                                        <div id="prevMonthBtn"><svg viewBox="0 0 20 20" class="svg-button" style="width:20px;" focusable="false" aria-hidden="true"><path fill="#8a8a8a" d="M16.5 10a.75.75 0 0 1-.75.75h-9.69l2.72 2.72a.75.75 0 0 1-1.06 1.06l-4-4a.75.75 0 0 1 0-1.06l4-4a.75.75 0 1 1 1.06 1.06l-2.72 2.72h9.69a.75.75 0 0 1 .75.75Z"></path></svg></div>
                                        <span id="currentMonth1"></span>
                                        </div>
                                        <table id="calendar1">
                                        <thead>
                                            <tr id="daysOfWeek1"></tr>
                                        </thead>
                                        <tbody></tbody>
                                        </table>
                                    </div>
                                    <div class="spacer">
                                        <svg class="svg-button" viewBox="0 0 20 20" focusable="false" aria-hidden="true" fill="#8a8a8a" width="20px" height="20px"><path fill-rule="evenodd" d="M3.5 10a.75.75 0 0 1 .75-.75h9.69l-2.72-2.72a.75.75 0 1 1 1.06-1.06l4 4a.75.75 0 0 1 0 1.06l-4 4a.75.75 0 0 1-1.06-1.06l2.72-2.72h-9.69a.75.75 0 0 1-.75-.75Z"></path></svg>
                                    </div>
                                    <div class="calendar">
                                        <input id="endInput" class="dateInput" type="text" placeholder="DD-MM-YYYY" autocomplete="off" />
                                        <div class="btnTitleCont">
                                        <span id="currentMonth2"></span>
                                        <div id="nextMonthBtn"><svg viewBox="0 0 20 20" style="width:20px;" class="svg-button" focusable="false" aria-hidden="true"><path fill="#8a8a8a" d="M3.5 10a.75.75 0 0 1 .75-.75h9.69l-2.72-2.72a.75.75 0 1 1 1.06-1.06l4 4a.75.75 0 0 1 0 1.06l-4 4a.75.75 0 0 1-1.06-1.06l2.72-2.72h-9.69a.75.75 0 0 1-.75-.75Z"></path></svg></div>
                                        </div>
                                        <table id="calendar2">
                                        <thead>
                                            <tr id="daysOfWeek2"></tr>
                                        </thead>
                                        <tbody></tbody>
                                        </table>
                                    </div>
                                    </div>
                                </div>
                                <div id="clearFilterDate" class="hidden">Clear Filter</div>
                            </div>
                        </div>`

        return children;
    }


    //rendering the calendar 
    renderCalendar(date, calendarId, monthId, daysOfWeekId) {
        var self = this;
        var calendarBody = $('.calendar-container-range #' + calendarId + ' tbody');
        var currentMonth = $('.calendar-container-range #' + monthId);
        var daysOfWeekRow = $('.calendar-container-range #' + daysOfWeekId);

        var monthNames = ["January", "February", "March", "April", "May", "June",
            "July", "August", "September", "October", "November", "December"];

        currentMonth.text(monthNames[date.getMonth()] + ' ' + date.getFullYear());

        calendarBody.empty();

        // Clear days of the week row before adding again
        daysOfWeekRow.empty();

        var daysInMonth = new Date(date.getFullYear(), date.getMonth() + 1, 0).getDate();
        var firstDayOfMonth = new Date(date.getFullYear(), date.getMonth(), 1).getDay();
        var daysOfWeek = ['Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa', 'Su'];

        $.each(daysOfWeek, function (index, value) {
            var th = $('<th>').text(value);
            daysOfWeekRow.append(th);
        });

        var dayCounter = 1;
        var weekdayIndex = (firstDayOfMonth + 6) % 7;

        for (var i = 0; dayCounter <= daysInMonth; i++) {
            var row = $('<tr>');
            for (var j = 0; j < 7; j++) {
                var cell = $('<td>');
                if ((i === 0 && j < weekdayIndex) || dayCounter > daysInMonth) {
                    cell.text('');
                } else {
                    cell.text(dayCounter++);
                    cell.addClass('dateCell');

                    var cellDate = new Date(date.getFullYear(), date.getMonth(), parseInt(cell.text()));
                    var formattedDate = cellDate.toLocaleDateString('en-GB', { day: '2-digit', month: '2-digit', year: 'numeric' }).split('/').join('-');
                    cell.attr('data-date', formattedDate);

                    var today = new Date();
                    today.setHours(0, 0, 0, 0);
                    if (cellDate > today) {
                        cell.addClass('greaterCurrent');
                    }
                }
                row.append(cell);
            }
            calendarBody.append(row);
        };

        self.calendarEvents();
        self.checkHighlightedDates();
    };


    // adding all the events to the calendar
    calendarEvents() {
        var self = this;

        //click events on the next and previous month buttons
        $('.calendar-container-range #nextMonthBtn, .calendar-container-range #prevMonthBtn').off('click').on('click', (e) => {
            var plusMinus = e.target.id == "nextMonthBtn" ? 1 : -1
            self.currentDate.setMonth(self.currentDate.getMonth() + plusMinus);
            self.renderCalendar(self.currentDate, 'calendar1', 'currentMonth1', 'daysOfWeek1');
            self.nextMonthDate.setMonth(self.nextMonthDate.getMonth() + plusMinus);
            self.renderCalendar(self.nextMonthDate, 'calendar2', 'currentMonth2', 'daysOfWeek2');
        })


        //click events on the table cells
        $('.calendar-container-range .dateCell').off('click').on('click', (e) => {
            var date = $(e.target).data('date');
            var popup = $(e.target).closest('[data-pos]')

            if (self.startDate === "") {
                self.startDate = new Date(self.parseDate(date));
            } else if (self.endDate === "") {
                self.endDate = new Date(self.parseDate(date));
            } else {
                self.startDate = new Date(self.parseDate(date));
                self.endDate = "";
                $('.calendar-container-range .dateCell').removeClass('selectedDataCell');
                $('.calendar-container-range [data-date]').removeClass('rangeCell');
            }

            $(e.target).addClass('selectedDataCell');

            if (self.startDate > self.endDate && self.endDate != "") {
                [self.startDate, self.endDate] = [self.endDate, self.startDate];
                self.filterChecks(e)
            } else if (self.endDate != "") {
                self.filterChecks(e)
            }

            if (self.startDate != "" && self.endDate != "") {
                $('#clearFilterDate').removeClass('hidden')
            } else {
                $('#clearFilterDate').addClass('hidden')
            }

            $('.calendar-container-range #startInput').val(self.formatDate(self.startDate));
            $('.calendar-container-range #endInput').val(self.endDate ? self.formatDate(self.endDate) : "");
        });

        //mouse enter events on the table cells
        $('.calendar-container-range .dateCell').mouseenter(function () {
            if (self.startDate != "" && self.endDate == "") {
                setTimeout(() => {
                    var secondDate = $(this).data('date');
                    var newEndDate = new Date(self.parseDate(secondDate));
                    $('.calendar-container-range [data-date]').removeClass('rangeCell');
                    self.generateDatesInRange(self.startDate, newEndDate);
                }, 50);
            }
        });

        //when typing in the start date field
        $('.calendar-container-range #startInput').off('keyup').on('keyup', (e) => {
            self.handleInput(e.target, e);
        });

        //when typing in the end date field
        $('.calendar-container-range #endInput').off('keyup').on('keyup', (e) => {
            self.handleInput(e.target, e);
        });

        //when clicking on the container away from the date input fields
        $('body').on('click', (e) => {
            self.startDate != "" ? $('.calendar-container-range #startInput').val(self.formatDate(self.startDate)) : "";
            self.endDate != "" ? $('.calendar-container-range #endInput').val(self.formatDate(self.endDate)) : "";
        });

        //when clicking the clear button on the date tange filter
        $('#clearFilterDate, [data-type="dateFilter"] .crossFilterCustom').off('click').on('click', (e) => {
            var self = this;
            self.startDate = "";
            self.endDate = "";
            self.currentDate = new Date();
            self.nextMonthDate = new Date(self.currentDate.getFullYear(), self.currentDate.getMonth() + 1, 1);
            self.dates = [];
            self.renderCalendar(self.currentDate, 'calendar1', 'currentMonth1', 'daysOfWeek1');
            self.renderCalendar(self.nextMonthDate, 'calendar2', 'currentMonth2', 'daysOfWeek2');
            $(`.filterPopup .calendar-container-range td`).removeClass('rangeCell');
            $(`.filterPopup .calendar-container-range .dataCell`).removeClass('selectedDataCell');
            $('.calendar-container-range #startInput, .calendar-container-range #endInput').val('');
            self.filterChecks(e);
            $(e.target).closest('[data-name]').find('#clearFilterDate').addClass('hidden');
            $(e.target).closest('[data-name]').find('.crossFilterCustom').addClass('hidden');
            $(e.target).closest('[data-name]').find('.chevy').removeClass('hidden');
        });
    };


    //events for the date input fields
    handleInput(inputElement, e) {
        var self = this;
        var regex = /^\d{2}-\d{2}-\d{4}$/;
        var date = regex.test(inputElement.value);
        var parsedDate = date ? self.parseDate(inputElement.value) : "";
        var newDate = new Date(parsedDate);

        var today = new Date();
        today.setHours(0, 0, 0, 0);
        if (newDate > today) {
            return
        };

        if (inputElement.id === 'startInput' && date) {
            $(`.calendar-container-range [data-date="${self.startDate != "" ? self.formatDate(self.startDate) : ""}"]`).removeClass('selectedDataCell');
            self.startDate = newDate;
            self.currentDate = new Date(self.startDate);
            self.renderCalendar(self.currentDate, 'calendar1', 'currentMonth1', 'daysOfWeek1');
            self.nextMonthDate = new Date(self.currentDate.getFullYear(), self.currentDate.getMonth() + 1, 1);
            self.renderCalendar(self.nextMonthDate, 'calendar2', 'currentMonth2', 'daysOfWeek2');
            $(`.calendar-container-range [data-date="${self.formatDate(self.startDate)}"]`).removeClass('selectedDataCell');
        } else if (inputElement.id === 'endInput' && date) {
            $(`.calendar-container-range [data-date="${self.endDate != "" ? self.formatDate(endDate) : ""}"]`).removeClass('selectedDataCell');
            self.endDate = newDate;
            $(`.calendar-container-range [data-date="${self.formatDate(self.endDate)}"]`).removeClass('selectedDataCell');
        };

        if (self.startDate > self.endDate && self.endDate != "") {
            [self.startDate, self.endDate] = [self.endDate, self.startDate];
        };

        $('#clearFilterDate').addClass('hidden')

        $(`.calendar-container-range [data-date="${inputElement.value}"]`).addClass('selectedDataCell');

        if (self.startDate && self.endDate) {
            $('.calendar-container-range [data-date]').removeClass('rangeCell');
            self.generateDatesInRange(self.startDate, self.endDate);
            self.filterChecks(e)
            $('#clearFilterDate').removeClass('hidden')
        };
    };


    //checking if any dates need highlighting
    checkHighlightedDates() {
        var self = this;
        var stringStartDate = self.startDate != "" ? self.formatDate(self.startDate) : "";
        var stringEndDate = self.endDate != "" ? self.formatDate(self.endDate) : "";
        $(`.calendar-container-range [data-date="${stringStartDate}"], .calendar-container-range [data-date="${stringEndDate}"]`).addClass('selectedDataCell')

        for (var i = 0; i < self.dates.length; i++) {
            $(`.calendar-container-range [data-date="${self.dates[i]}"]`).addClass('rangeCell')
        };
    };


    //generating dates between 2 given ranges
    generateDatesInRange(startDate, endDate) {
        var self = this;
        self.dates = [];
        var currentDate = new Date(startDate);
        var $cellsToHighlight = $();

        if (currentDate > endDate) {
            [currentDate, endDate] = [endDate, currentDate];
        };

        currentDate.setDate(currentDate.getDate() + 1);

        while (currentDate < endDate) {
            var day = String(currentDate.getDate()).padStart(2, '0');
            var month = String(currentDate.getMonth() + 1).padStart(2, '0');
            var year = currentDate.getFullYear();
            self.dates.push(`${day}-${month}-${year}`);
            var cell = $(`.calendar-container-range [data-date="${day}-${month}-${year}"]`);
            $cellsToHighlight = $cellsToHighlight.add(cell);
            currentDate.setDate(currentDate.getDate() + 1);
        };

        $cellsToHighlight.addClass('rangeCell');

        return self.dates;
    };







    /* GENERAL FUNCTIONS */

    //a function which generates and attaches links to rows
    links() {

        var self = this;

        $(`${self.tableArea} tbody tr`).on({
            mouseenter: function () {
                $(this).css('background-color', '#f1f2f3')
                $(`${self.tableArea} tbody tr td`).css('cursor', 'pointer')
            },
            mouseleave: function () {
                $(this).css('background-color', '#ffffff')
            },
            click: function (e) {
                if (self.settings.links.baseUrl != "") {
                    self.rowNo = $(e.target).closest('tr').index();
                    self.elementCheck = $(e.target).closest('td').data('none');
                    self.itemLink = $(`tbody tr:eq(${self.rowNo})`).data('itemlink');

                    if (self.elementCheck == undefined && self.elementCheck != "" && self.editMode == false) {
                        location.href = self.settings.links.baseUrl + `${self.itemLink}`;
                    }
                }
            }
        });
    }


    //checking to see if the row has been edited if it has enable the save btn
    rowCheck(e) {
        var self = this;

        //array for current content
        self.currentContent = []

        //setting the initial value to false
        var check = false;

        //getting all the text fields
        var selectedRow = $(e.target).closest("tr").find('.editInput')

        //checking if the dropdowns have been changed
        var dropDownOptions = $(`.tableContainer tbody tr:eq(${self.rowNo}) .selectOptionEdit :selected`);

        //getting all the previous values
        var contentCheckArray = self.rowContent.map(function (obj) {
            return obj.value;
        });

        //looping through all the text fields and putting them in an array
        for (var x = 0; x < selectedRow.length; x++) {
            self.currentContent.push(selectedRow[x].value)
        }

        //looping through all the dropdown and adding the values to the current array
        for (var x = 0; x < dropDownOptions.length; x++) {
            self.currentContent.push(dropDownOptions[x].innerText)
        }

        //looping the old content and comparing it with the current content
        for (let i = 0; i < contentCheckArray.length; i++) {
            var a = self.currentContent[i].trim()
            var b = contentCheckArray[i].trim()
            //if the row has been updated we shown/enable the save button 
            if (a !== b) {
                check = true
                $(`.tableContainer tbody tr:eq(${self.rowNo}) [data-id="saveRow"]`).removeClass('dimmed').removeAttr('disabled');
            };
        };

        //if nothing has changed we show the cancel button 
        if (check == false) {
            $(`.tableContainer tbody tr:eq(${self.rowNo}) [data-id="saveRow"]`).addClass('dimmed').attr('disabled', true);
        };
    }


    //a function which resizes all components of the row
    resizeInput() {
        //getting all the table inputs
        var inputFields = $('.editInput');

        //creating a empty height array
        var heightArray = []

        //looping through all the text areas getting the height and adding them to the array
        for (var i = 0; i < inputFields.length; i++) {
            var height = $('.editInput')[i].scrollHeight
            heightArray.push(height)
        }

        //getting the max height 
        var maxHeight = Math.max(...heightArray);
        return maxHeight;
    }


    //a function which is ran when resizing the browser window
    windowResize() {
        var self = this;
        $(window).on('resize', (e) => {
            self.resizeInput()
        })
    };


    //hiding and showing the filters
    hideShowFilterSearch(tableName = "") {
        $(`${tableName} #searchFilter`).off('click').on('click', (e) => {
            $(`${tableName} #searchBox, ${tableName} #cancelSearch`).css('display', 'flex').show()
            $(`${tableName} .tableFilters`).slideDown().css('display', 'flex')
            $(`${tableName} .tableShortcuts, ${tableName} #searchFilter`).hide()
            $('.tableSearchContainer #tableSearch').focus()
        })

        $(`${tableName} #cancelSearch`).off('click').on('click', (e) => {
            $(`${tableName} .tableShortcuts`).css('display', 'block').show()
            $(`${tableName} #searchFilter`).css('display', 'flex').show()
            $(`${tableName} .tableFilters`).slideUp()
            $(`${tableName} #searchBox, ${tableName} #cancelSearch`).hide()
        })
    };


    //parsing the date and giving the following output: December 31, 2023.
    parseDate(dateString) {
        const parts = dateString.split('-');
        return new Date(parts[2], parts[1] - 1, parts[0]);
    };


    //formatting the date in the following output: 01-02-2024
    formatDate(date) {
        var formattedDate = date.toLocaleDateString('en-GB', { day: '2-digit', month: '2-digit', year: 'numeric' }).replace(/\//g, '-');
        return formattedDate;
    };


    //when saving a row after editing it
    editStateSave(rowNo) {

        var self = this;
        var objData = {};

        // Find elements with data-name and data-editable="true"
        $(`.tableContainer tbody tr:eq(${rowNo})`).find('[data-id="editField"]').each(function () {
            // Get the data-name attribute value
            var key = $(this).data('name');
            // Get the value based on the element type (input, select, etc.)
            var value;
            if ($(this).find(".editInput").is('textarea, input, select')) {
                value = $(this).find(".editInput").val();
            } else {
                value = $(this).find(".editInput").text();
            }
            // Add the key-value pair to the object
            objData[key] = value;
        });

        //get the id of the row to modify
        objData["id"] = $(`.tableContainer tbody tr:eq(${rowNo})`).data('itemid');


        $.ajax({
            url: self.settings.editUrl,
            type: 'POST',
            data: objData,
            dataType: 'json',
            contentType: 'application/x-www-form-urlencoded;charset=utf-8;',
            success: function (results, status, jqXHR) {

                //console.log(results)

                //getting the row which is being edited
                var trBody = $(`.tableContainer tbody tr:eq(${rowNo})`)

                //emptying the row
                $(trBody).empty()

                //setting the height to zero
                $(trBody).css('height', '0px')

                //getting the new content for the row
                var rowContent = self.addTableContent(results.item[0])

                //adding the content to the row
                trBody.append(rowContent);

                //removing the height from the row
                $(trBody).removeAttr('style')

                if (self.settings.checkboxes) {
                    //adding events back to the checkbox
                    selectBoxesProducts.events();

                    //centering all the checkboxes
                    selectBoxesProducts.checkBoxCenter()
                }
            },
            error: function (error) {
                console.log(error)
            }
        });
    }

};
