class customerTable {
    constructor(settingsPram = settings) {
        this.table;
        this.selectBoxesProducs;
        this.settings = settingsPram;
        this.customerList();
        this.events();
    }

    /* GENERAL FUNCTIONS */
    fetchData(url, additionalCallback) {
        var self = this;
        $.ajax({
            url: url,
            type: 'GET',
            contentType: 'application/json',
            success: function (results) {
                if (additionalCallback) additionalCallback(results);
            },
            error: function (error) {
                console.log(error);
            }
        });
    }

    // Load customers and initialize table
    customerList() {
        var self = this;
        const url = '/Api/customer';

        function successCallback(results) {
            if (results.lists) results = results.lists;
            if (results.length == 0) {
                $('[data-norecords]').attr('style', 'display:block!important');
            } else {
                $('.innerBottomContainer').removeClass('hidden');
            }

            $('.tableCount span').text(`(${results.length})`);

            const formattedResults = results.map(item => ({
                ...item,
                id: item.customerId,
                link: `/page/customer/${item.customerId}`
            }));
            self.table = new tableClass(formattedResults, self.settings, formattedResults, "", ".container");
            self.table.hideShowFilterSearch();

            if (self.settings.checkboxes) {
                self.selectBoxesProducts = new checkBox(self.settings.tableHeader, '#table input', '');
            }
        }

        self.fetchData(url, successCallback);
    }

    events() {
        var self = this;
        $('[data-customerbtn]').off('click').on('click', (e) => {
            self.createUpdateCustomer(e);
        });

        $(document).on('click', 'tbody tr', (e) => {
            self.createUpdateCustomer(e);
        });
    }

    async createUpdateCustomer(e) {
        var self = this;
        var url = "/Api/customer/Create/";
        var currentTarget = e.currentTarget.tagName;
        await startupClass.popupGenerator("/components/manageCustomer.html", ".modal-v");
        const addButton = $('#addCustomer');
        addButton.prop('disabled', true);
        function toggleAddButton() {
            const firstName = $('#firstName').val().trim();
            const lastName = $('#lastName').val().trim();
            const email = $('#emailAddress').val().trim();
            const phone = $('#phoneNumber').val().trim();
            const address = $('#addressFirstLinePopup').val().trim();
            const city = $('#cityPopup').val().trim();
            const postcode = $('#postcodePopup').val().trim();
            const country = $('#countryPopupList').val();

            if (firstName && lastName && email && phone && address && city && postcode && country && country !== "0") {
                addButton.prop('disabled', false);
            } else {
                addButton.prop('disabled', true);
            }
        }

        $('#firstName, #lastName, #emailAddress, #phoneNumber, #addressFirstLinePopup, #cityPopup, #postcodePopup, #countryPopupList')
            .off('input change')
            .on('input change', toggleAddButton);
        // --- load countries into the dropdown right after opening the popup ---
        $('#countryPopupList').empty().append('<option value="">Select</option>');

        try {
            // use the same casing that your controller uses. Both usually work but be consistent:
            const countriesRes = await fetch('/api/Customer/CountryList');
            if (!countriesRes.ok) throw new Error('Failed to load countries');
            const countries = await countriesRes.json();

            // populate the select
            countries.forEach(c => {
                $('#countryPopupList').append(`<option value="${c}">${c}</option>`);
            });
        } catch (err) {
            console.error('Error loading countries:', err);
            // optionally show a small message in the popup instead of alert
        }


        if (currentTarget == "TR") {
            url = "/Api/customer/Update/";
            var itemid = $(e.target).closest('[data-itemid]').attr('data-itemid');
            $('.model-content').attr('data-itemid', itemid);
            $('.t1-pop-up-heading').text('Update Customer Record');
            $('#deleteCustomer').removeClass('hidden');
            $('#addCustomer').text('Update');

            $('#deleteCustomer').off('click').on('click', (e) => {
                self.deleteCustomer();
            });

            try {
                // 1) Ensure countries are loaded (in case the earlier fetch failed)
                if ($('#countryPopupList option').length <= 1) {
                    const countriesRes = await fetch('/api/Customer/CountryList');
                    if (countriesRes.ok) {
                        const countries = await countriesRes.json();
                        $('#countryPopupList').empty().append('<option value="">Select</option>');
                        countries.forEach(c => $('#countryPopupList').append(`<option value="${c}">${c}</option>`));
                    }
                }

                // 2) Now load the customer and set the fields (country will match an option)
                const res = await fetch(`/api/Customer/${itemid}`);
                if (!res.ok) throw new Error('Failed to fetch customer');
                const results = await res.json();

                $('#firstName').val(results.firstName || results.FirstName || '');
                $('#lastName').val(results.lastName || results.LastName || '');
                $('#emailAddress').val(results.email || results.Email || '');
                $('#phoneNumber').val(results.phoneNumber || results.PhoneNumber || '');
                $('#addressFirstLinePopup').val(results.address || results.Address || '');
                $('#addressSecondLinePopup').val(results.appartmentSuite || results.AppartmentSuite || '');
                $('#cityPopup').val(results.city || results.City || '');
                $('#postcodePopup').val(results.postalCode || results.PostalCode || '');
                // set country after options are present
                $('#countryPopupList').val(results.country || results.Country || '');
            } catch (err) {
                console.error(err);
                alert('Failed to load customer for update.');
            }
        }

        $('#addCustomer').off('click').on('click', (e) => {
            var data = new FormData();
            data.append("FirstName", $('#firstName').val());
            data.append("LastName", $('#lastName').val());
            data.append("Email", $('#emailAddress').val());
            data.append("PhoneNumber", $('#phoneNumber').val());
            data.append("Address", $('#addressFirstLinePopup').val());
            data.append("AppartmentSuite", $('#addressSecondLinePopup').val());
            data.append("City", $('#cityPopup').val());
            data.append("PostalCode", $('#postcodePopup').val());
            data.append("Country", $('#countryPopupList').val());

            if (currentTarget == 'TR') {
                data.append("CustomerId", $('.model-content').attr('data-itemid'));
            }

            $.ajax({
                url: url,
                data: data,
                type: 'POST',
                contentType: false,
                processData: false,
                success: (result) => {
                    $('#customerTable thead tr, #customerTable tbody, #customerTable .tableFilters').empty();
                    $('[data-norecords]').addClass('hidden').css('display', 'none');
                    $('#customerTable').removeClass('hidden').css('display', 'block');
                    self.customerList();
                    $('.model-content').css('margin-bottom', '-200px');
                    $('.modal-v').fadeOut(300);
                    $('.model-content').remove();
                },
                error: (xhr, status, error) => {
                    console.error('AJAX Error:', status, error);
                    alert("An error occurred. Please verify the details and try again.");
                }
            });
        });
    }

    deleteCustomer() {
        var self = this;
        var id = $('.model-content').attr('data-itemid');
        $.ajax({
            url: `/Api/customer/DeleteCustomer/${id}`,
            type: 'DELETE',
            success: function (response) {
                $('#customerTable thead tr, #customerTable tbody, #customerTable .tableFilters').empty();
                $('[data-norecords]').addClass('hidden');
                $('#customerTable').addClass('hidden');
                self.customerList();
                $('.model-content').css('margin-bottom', '-200px');
                $('.modal-v').fadeOut(300);
                $('.model-content').remove();
            },
            error: function (xhr) {
                if (xhr.status === 404) {
                    alert('Customer record not found or unauthorized.');
                } else if (xhr.status === 409) {
                    const message = xhr.responseJSON?.message || 'Concurrency conflict.';
                    alert('Conflict: ' + message);
                } else {
                    alert('An error occurred while deleting this record.');
                }
            }
        });
    }
}
