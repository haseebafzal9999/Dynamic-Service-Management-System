class damageManager {
    constructor(settingsPram = settings) {
        this.table;
        this.dDlists;
        this.files = [];
        this.selectBoxesProducts;
        this.settings = settingsPram;
        this.init();
    }

    init() {
        this.vehicleDamageList()
        this.damageList();
        this.events();
    }

    events() {
        var self = this;
        $('[data-damagebtn]').off('click').on('click', (e) => {
            self.createUpdateDamages(e)
        });

        $(document).on('click', 'tbody tr', (e) => {
            if (e.currentTarget.tagName == 'TR' && e.target.tagName == 'BUTTON') {

                if ($(e.target).attr('data-id') == "downloadMultipleBtn") {
                    self.popupDamageDownload(e);
                }

                return;
            }
            self.createUpdateDamages(e);
        });
    }

    vehicleDamageList() {
        return $.ajax({
            url: `/Api/VehicleDamage/DamageLists/`,
            type: 'GET',
            contentType: 'application/json',
            success: (results) => {
                if (results?.lists?.[0]) {
                    const list = results.lists[0];
                    this.dDlists = list;
                } else {
                    console.error('Unexpected response structure for service lists:', results);
                }
            },
            error: (error) => {
                console.error('Error fetching service lists:', error);
            }
        });
    }

    damageList() {
        const self = this;

        $.ajax({
            url: '/api/VehicleDamage/GetDamages',
            type: 'GET',
            contentType: 'application/json',
            success: function (results) {
                if (results.length == 0) {
                    $('[data-norecords]').attr('style', 'display:block!  important');
                } else {
                    $('.innerBottomContainer').removeClass('hidden');
                }

                // Set the quantity of products found
                $('.tableCount span').text(`(${results.length})`);

                // Initiate a class to create new tables
                self.table = new tableClass(results, self.settings, results, "", ".container");

                // Set up search & filter
                self.table.hideShowFilterSearch();

                // Center the checkboxes
                if (self.settings.checkboxes) {
                    self.selectBoxesProducts = new checkBox(self.settings.tableHeader, '#table input', '');
                }
            },
            error: function (error) {
                console.error(error);
            }
        });
    }

    async createUpdateDamages(e) {
        var self = this;
        var url = "/Api/VehicleDamage/CreateDamage/";
        var currentTarget = e.currentTarget.tagName;
        await self.popupGenerator("/components/addDamage.html", ".modal-v");
        new commonFunc().generateDDLists(self.dDlists.damageStatus, '#vehicleStatus');
        new commonFunc().generateDDLists(self.dDlists.faultAttr, '#faultAttribution');
        new FileUploader("incidentUpload", "[data-incidentupload]", false, '#incidentAttachError');

        if (currentTarget == "TR") {
            url = "/Api/VehicleDamage/UpdateDamage/";
            var damageId = $(e.target).closest('[data-itemid]').attr('data-itemid');
            var xMin = $(e.target).closest('[data-xmin]').attr('data-xmin');
            $('.model-content').attr('data-damageId', damageId).attr('data-xmin', xMin);
            $('.t1-pop-up-heading').text('Update Damage Record')
            $('#deleteDamage').removeClass('hidden')

            $('#deleteDamage').off('click').on('click', (e) => {
                self.deleteDamage();
            });

            $.ajax({
                url: `/Api/VehicleDamage/DamageDetails/${damageId}`,
                type: 'GET',
                contentType: 'application/json',
                success: function (results) {
                    $('#registrationNumber').val(results.registrationNumber);
                    $('#vehicleStatus').val(results.status);
                    $('#driverName').val(results.driverName);
                    $('#insuranceRef').val(results.insuranceReferenceNumber);
                    $('#repairCost').val(results.cost);
                    $('#dateReported').val(self.convertDateFormat(results.reportedDate));
                    $('#DateOfIncident').val(self.convertDateFormat(results.incidentDate));
                    $('#faultAttribution').val(results.faultAttribution);
                    $('#incidentDes').val(results.incidentDescription);

                },
                error: function (error) {
                    console.log(error);
                }
            });
        };

        $('#vehicleStatus, #faultAttribution').off('change').on('change', (e) => {
            self.validateDamagePopup(e);
        });

        $('#repairCost').off('blur').on('blur', (e) => {
            e.target.value = self.formatNumber(e.target.value)
            self.validateDamagePopup(e);
        });

        $('#registrationNumber, #driverName, #insuranceRef, #dateReported, #DateOfIncident, #incidentDes').off('input').on('input', (e) => {
            self.validateDamagePopup(e);
        });

        $('#addDamage').off('click').on('click', (e) => {
            var data = new FormData();
            data.append("DriverName", $('#driverName').val());
            data.append("RegistrationNumber", $('#registrationNumber').val());
            data.append("ReportedDate", $('#dateReported').val());
            data.append("IncidentDate", $('#DateOfIncident').val());
            data.append("InsuranceReferenceNumber", $('#insuranceRef').val());
            data.append("FaultAttribution", $('#faultAttribution').val());
            data.append("Cost", $('#repairCost').val());
            data.append("Status", $('#vehicleStatus').val());
            data.append("IncidentDescription", $('#incidentDes').val());

            if (currentTarget == 'TR') {
                data.append("Xmin", xMin);
                data.append("DamageId", damageId);
            }

            var filesToUpload = $('#incidentUpload')[0].files
            if (filesToUpload.length > 0) {
                for (var i = 0; i < filesToUpload.length; i++) {
                    data.append("FileList", filesToUpload[i]);
                }
            }

            $.ajax({
                url: url,
                data: data,
                type: 'POST',
                contentType: false,
                processData: false,
                success: (result) => {
                    $('#table thead tr, #table tbody, #table .tableFilters').empty();
                    $('[data-norecords]').addClass('hidden').css('display', 'none')
                    $('#table').removeClass('hidden').css('display', 'block');
                    self.damageList();
                    $('.model-content').css('margin-bottom', '-200px');
                    $('.modal-v').fadeOut(300);
                    $('.model-content').remove();
                },
                error: (xhr) => {
                    alert("An error occurred. The vehicle may not exist. Please verify the details and try again.");
                }
            });
        })
    }

    validateDamagePopup(e) {
        var isValid = true;

        $('.model-content [data-required]').each(function () {
            var value = $(this).val();
            var isDropdown = $(this).is('select');

            if ((isDropdown && value === "0") || (!isDropdown && $.trim(value) === "")) {
                isValid = false;
                return false;
            }
        });

        if (isValid) {
            $('#addDamage').removeClass('btn-disable');
        } else {
            $('#addDamage').addClass('btn-disable');
        }

        return isValid;
    }

    popupDamageDownload(e) {
        //when clicking on the multiple file download button
        $('#popup').hide();
        $('#popUpinnerContainer').empty()

        var self = this;

        //finding the id of the damage record which was clicked
        var damageId = $(e.currentTarget).closest('tr').data('itemid');

        //finding the position of the download btn
        var btnClickedPos = e.currentTarget.getBoundingClientRect();

        //setting the default value of the popup
        var offScreen = false;

        //function to create the popup
        var createPopup = () => {

            //popup container
            var children = `<div class="popupFile" style="right:40px;">
                                        <div class="fileContainer polaris-box border-dark" style="width:auto; max-width:350px; padding-bottom: 10px;">
                                            <div class="polaris-box-item w-inline-block" style="padding-left: 10px; border-bottom: #e1e3e5 solid 1px; margin-bottom:2px;">
                                                <div class="polaris-box-item-text" style="font-weight: 700;">Download File(s)</div>
                                            </div>
                                        </div>
                                        <div class="polaris-box-list-item user-information"></div>
                                    </div>
                                </div>`

            //adding it to the dom
            $('#damages').append(children);

            //getting the popup
            var filePopUp = $('.popupFile');

            //getting the dimentions of the popup
            var filePopUpDimensions = filePopUp[0].getBoundingClientRect();

            // Finding the files related to that damage record
            var findFiles = self.files.filter(x => damageId == x.damageId);

            // Filtering out any duplicates
            var fileUiMap = new Map(findFiles.map(item => [item.fileDisplayName, item]));
            var fileUi = [...fileUiMap.values()].map(x => `<div class="polaris-box-list-item-inner-wrapper" style="margin-bottom:0px; height: 24px;">
                                                                    <div class="polaris-box-item w-inline-block">
                                                                        <a class="polaris-box-item-text" style="pointer-events: all; width: 100%; white-space: pre;" href="/Api/vehicleDamage/downloadfile?fileId=${x.fileId}">${x.fileDisplayName}</a>
                                                                    </div>
                                                               </div>`).join('');

            //setting the popup position
            var popUpPos = btnClickedPos.top - filePopUpDimensions.top;
            $(filePopUp).css('top', `${popUpPos}px`);

            //setting the popup to display none
            $('.popupFile').hide();

            //adding the files to the view
            $('.popupFile .fileContainer').append(fileUi);

            //working out the height the popup should be
            var popUpSize = fileUiMap.length * 32.5;

            //setting the popup to display flex
            filePopUp[0].style.display = 'flex';
            $('.popupFile .fileContainer').css('display', 'flex').css('flex-direction', 'column').css('padding-bottom', '10px')

            //setting the size of the popup
            document.documentElement.style.setProperty('--popup-size', `${popUpSize + 34.5}px`);

            //checking if the popup is off the screen
            var isOffScreen = self.isPopupOffScreen(filePopUp[0]);

            //setting the new popup position
            popUpPos = popUpPos - isOffScreen.offBottom - isOffScreen.offTop
            filePopUp.css('top', `${popUpPos}px`);

            //if the popup is off the screen set to true
            if (isOffScreen.offBottom > 0 || isOffScreen.offTop > 0) {
                offScreen = true;
                popUpPos = popUpPos - 15
            }


            //if the popup if off the screen set the relevant animation
            if (offScreen) {
                document.documentElement.style.setProperty('--popup-top', `${popUpPos}px`);
                filePopUp[0].style.animation = "growFromBottom 0.6s ease forwards";
            } else {
                filePopUp[0].style.animation = "growFromTop 0.6s ease forwards";
            }


            //when the mouse leaves the popup remove the popup from the dom
            filePopUp.mouseleave(() => {
                filePopUp[0].style.animation = "";
                filePopUp[0].style.top = popUpPos + 'px';
                $('.popupFile').fadeOut('slow');
                $('.popupFile').remove();
            });
        };

        createPopup();
    }

    deleteDamage() {
        var self = this;
        var id = $('.model-content').attr('data-damageId')
        var xmin = $('.model-content').attr('data-xmin')
        $.ajax({
            url: `/Api/VehicleDamage/DeleteDamage/${id}/${xmin}`,
            type: 'DELETE',
            success: function (response) {
                $('#damages thead tr, #damages tbody, #damages .tableFilters').empty();
                $('[data-norecords]').addClass('hidden')
                $('#damages').removeClass('hidden');
                self.damageList();
                $('.model-content').css('margin-bottom', '-200px');
                $('.modal-v').fadeOut(300);
                $('.model-content').remove();
            },
            error: function (xhr) {
                if (xhr.status === 404) {
                    alert('Damage record not found or unauthorized.');
                } else if (xhr.status === 409) {
                    const message = xhr.responseJSON?.message || 'Concurrency conflict.';
                    alert('Conflict: ' + message);
                } else {
                    alert('An error occurred while deleting this record.');
                }
            }
        });
    }


    // Helper Functions
    isPopupOffScreen(popup) {
        // Get the dimensions of the popup and the viewport
        var popupRect = popup.getBoundingClientRect();
        var viewportWidth = window.innerWidth || document.documentElement.clientWidth;
        var viewportHeight = window.innerHeight || document.documentElement.clientHeight;

        // Get the scroll position
        var scrollLeft = window.pageXOffset || document.documentElement.scrollLeft;
        var scrollTop = window.pageYOffset || document.documentElement.scrollTop;

        // Check if any of the edges of the popup are outside the viewport, considering scroll
        var isOffLeft = popupRect.left + scrollLeft < 0;
        var isOffTop = popupRect.top + scrollTop < 0;
        var isOffRight = popupRect.right + scrollLeft > viewportWidth;
        var isOffBottom = popupRect.bottom + scrollTop > viewportHeight;

        var offScreenInfo = {
            offLeft: isOffLeft ? Math.abs(popupRect.left + scrollLeft) : 0,
            offTop: isOffTop ? Math.abs(popupRect.top + scrollTop) : 0,
            offRight: isOffRight ? popupRect.right + scrollLeft - viewportWidth : 0,
            offBottom: isOffBottom ? popupRect.bottom + scrollTop - viewportHeight : 0,
        };

        return offScreenInfo;
    }

    popupGenerator(path, parentContainer, additionalEvents = "") {
        const self = this;
        const randomQuery = Math.random().toString(36).substr(2, 6);
        const url = path + "?" + randomQuery;

        return new Promise((resolve, reject) => {
            $('.modal-v').fadeIn().css('display', 'flex');
            $.get(url)
                .done((data) => {
                    $(parentContainer).html(data);

                    $('.model-content').css('margin-bottom', '-200px');

                    $('.model-content').animate({
                        marginBottom: window.innerWidth < 768 ? '0px' : '50px'
                    }, 200);

                    if (additionalEvents !== "") {
                        self[additionalEvents]();
                    }

                    $('.model-content .cross-button, .cancel-btn-model, .model-save-btn').on('click', () => {
                        $('.model-content').css('margin-bottom', '-200px');
                        $('.modal-v').fadeOut(300);
                        $('.model-content').remove();
                    });

                    resolve();
                })
                .fail((error) => {
                    console.error(error);
                    reject(error);
                });
        });
    }

    appendError(element, message) {
        const errorHtml = `<span class="polaris-form-label errorSpanMessage text-danger"> ${message}</span>`;
        element.closest('.polaris-form-layout-third').find('.polaris-form-label').append(errorHtml);
    };

    formatNumber(value) {
        const currencyIdentity = localStorage.getItem('currencyIdentity') || 'en-GB';

        return new Intl.NumberFormat(currencyIdentity, {
            minimumFractionDigits: 2,
            maximumFractionDigits: 2
        }).format(value);
    };

    convertDateFormat(dateStr) {
        // Split the input by "/"
        var parts = dateStr.split('/');
        if (parts.length !== 3) {
            return null; // Invalid format
        }
        var day = parts[0];
        var month = parts[1];
        var year = parts[2];

        return year + '-' + month + '-' + day;
    }
}