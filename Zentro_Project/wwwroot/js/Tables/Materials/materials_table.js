class materialsTable {
    constructor(settingsPram = settings) {
        this.table;
        this.selectBoxesProducs;
        this.settings = settingsPram;
        this.materialsList();
        this.events();
    }


    /* GENERAL FUNCTIONS */
    //general api function for all tabs
    fetchData(url, additionalCallback) {
        var self = this;
        $.ajax({
            url: url,
            type: 'GET',
            contentType: 'application/json',
            success: function (results, status, jqXHR) {
                if (additionalCallback) {
                    additionalCallback(results);
                };
            },
            error: function (error) {
                console.log(error);
            }
        });
    }


    //getting a list of records and adding then to the view
    materialsList() {
        var self = this;
        const url = '/api/material';
        function successCallback(results) {

            if (results.length == 0) {
                $('[data-norecords]').attr('style', 'display:block!  important');
            } else {
                $('.innerBottomContainer').removeClass('hidden');
            }

            //setting the quantity of records found
            $('.tableCount span').text(`(${results.length})`)

            // Map results to include a generic 'id' property like in componentsTable
            const formattedResults = results.map(item => ({
                ...item,
                id: item.materialId,             // ✅ gives each row a universal ID
                link: `/page/material/${item.materialId}` // optional, for consistency
            }));

            // Initiating a class to create new tables

            self.table = new tableClass(formattedResults, self.settings, formattedResults, "", ".container");


            //setting up the search & filter
            self.table.hideShowFilterSearch();

            //centering the checkboxes
            if (self.settings.checkboxes) {
                self.selectBoxesProducts = new checkBox(self.settings.tableHeader, '#table input', '')
            }
        };

        self.fetchData(url, successCallback);
    }

    events() {
        var self = this;
        $('[data-addMaterial]').off('click').on('click', (e) => {
            self.createUpdateMaterial(e)
        });

        $(document).on('click', 'tbody tr', (e) => {
            self.createUpdateMaterial(e);
        });
    }

    async createUpdateMaterial(e) {
        var self = this;
        var url = "/Api/material/Create/";
        var currentTarget = e.currentTarget.tagName;
        await startupClass.popupGenerator("/components/manageMaterial.html", ".modal-v");


        // ✅ Add this part here:
        const saveButton = $('#createMaterial');
        saveButton.prop('disabled', true);

        function toggleSaveButton() {
            const partNo = $('#itemPartNumber').val().trim();
            const itemName = $('#itemName').val().trim();
            const cost = $('#costPrice').val().trim();
            const sell = $('#sellPrice').val().trim();
            const supplier = $('#supplier').val().trim();

            if (partNo && itemName && cost && sell && supplier) {
                saveButton.prop('disabled', false);
            } else {
                saveButton.prop('disabled', true);
            }
        }

        $('#itemPartNumber, #itemName, #costPrice, #sellPrice, #supplier')
            .off('input change')
            .on('input change', toggleSaveButton);

        const costInput = $('#costPrice');
        const sellInput = $('#sellPrice');

        // 1️⃣ Attach blur/focus events first
        [costInput, sellInput].forEach(input => {
            input.off('blur').on('blur', function () {
                const formatted = self.formatCurrencyModal($(this).val());
                $(this).val(formatted);
            });

            input.off('focus').on('focus', function () {
                let raw = $(this).val();

                // Remove currency symbols and commas
                raw = raw.replace(/[^0-9.-]+/g, "");

                // Remove unnecessary .00 at the end
                raw = raw.replace(/\.00$/, "");

                $(this).val(raw);
            });

        });

        if (currentTarget == "TR") {
            url = "/Api/material/Update/";
            var itemid = $(e.target).closest('[data-itemid]').attr('data-itemid');
            //var xMin = $(e.target).closest('[data-xmin]');//.attr('data-xmin');
            $('.model-content').attr('data-itemid', itemid);//.attr('data-xmin', xMin);
            self.checkMaterialDependency();
            $('.t1-pop-up-heading').text('Update Material Record')
            $('#deleteMaterial').removeClass('hidden')
            $('#createMaterial').text('Update');

            $('#deleteMaterial').off('click').on('click', (e) => {
                self.deleteMaterial();
            });

            $.ajax({
                url: `/Api/material/${itemid}`,
                type: 'GET',
                contentType: 'application/json',
                success: function (results) {
                    //debugger;
                    $('#itemPartNumber').val(results.partNo);
                    $('#itemName').val(results.name);
                    $('#materialDes').val(results.description);
                    $('#supplier').val(results.supplier);
                    $('#costPrice').val(self.formatCurrencyModal(results.costPrice));
                    $('#sellPrice').val(self.formatCurrencyModal(results.sellPrice));


                },
                error: function (error) {
                    console.log(error);
                }
            });
        };

        $('#createMaterial').off('click').on('click', (e) => {
            var data = new FormData();
            data.append("PartNo", $('#itemPartNumber').val());
            data.append("Name", $('#itemName').val());
            data.append("Description", $('#materialDes').val());
            data.append("Supplier", $('#supplier').val());
            const costVal = parseFloat($('#costPrice').val().replace(/[^0-9.-]+/g, "")) || 0;
            const sellVal = parseFloat($('#sellPrice').val().replace(/[^0-9.-]+/g, "")) || 0;
            data.append("CostPrice", costVal);
            data.append("SellPrice", sellVal);

           

            if (currentTarget == 'TR') {
                //data.append("Xmin", xMin);
                data.append("MaterialId", itemid);
            }

            $.ajax({
                url: url,
                data: data,
                type: 'POST',
                contentType: false,
                processData: false,
                success: (result) => {
                    $('#materialTable thead tr,#materialTable tbody,#materialTable .tableFilters').empty();
                    $('[data-norecords]').addClass('hidden').css('display', 'none')
                    $('#materialTable').removeClass('hidden').css('display', 'block');
                    self.materialsList();
                    $('.model-content').css('margin-bottom', '-200px');
                    $('.modal-v').fadeOut(300);
                    $('.model-content').remove();
                },
                error: (xhr, status, error) => {
                    console.error('AJAX Error:', status, error);
                    console.error('Response Text:', xhr.responseText);

                    // Optional: if backend sends JSON error messages
                    try {
                        const err = JSON.parse(xhr.responseText);
                        console.error('Parsed Error:', err);
                    } catch (e) {
                        // not JSON, ignore
                    }

                    alert("An error occurred. The material may not exist. Please verify the details and try again.");
                }
            });
        })
    }


    formatCurrencyModal = (amount) => {
        if (!amount || isNaN(amount)) return "0.00";

        const currency = localStorage.getItem('currency') || 'GBP';
        const currencyIdentity = localStorage.getItem('currencyIdentity') || 'en-GB';

        return new Intl.NumberFormat(currencyIdentity, {
            style: "currency",
            currency: currency
        }).format(amount);
    };

    deleteMaterial() {
        var self = this;
        var id = $('.model-content').attr('data-itemid')
        /*var xmin = $('.model-content').attr('data-xmin')*/
        $.ajax({
            url: `/Api/material/DeleteMaterial/${id}`,
            type: 'DELETE',
            success: function (response) {
                $('#materialTable thead tr, #materialTable tbody, #materialTable .tableFilters').empty();
                $('[data-norecords]').addClass('hidden')
                $('#materialTable').addClass('hidden');
                self.materialsList();
                $('.model-content').css('margin-bottom', '-200px');
                $('.modal-v').fadeOut(300);
                $('.model-content').remove();
            },
            error: function (xhr) {
                if (xhr.status === 404) {
                    alert('Material record not found or unauthorized.');
                } else if (xhr.status === 409) {
                    const message = xhr.responseJSON?.message || 'Concurrency conflict.';
                    alert('Conflict: ' + message);
                } else {
                    alert('An error occurred while deleting this record.');
                }
            }
        });
    }

    checkMaterialDependency() {
        var id = $('.model-content').attr('data-itemid')
        $.ajax({
            url: `/Api/material/IsMaterialDependent/${id}`,
            type: 'GET',
            contentType: 'application/json',
            success: function (response) {
                if (response.success) {
                    $('#deleteMaterial').addClass('btn-disable')
                }

            },
            error: function (xhr) {
                alert('An error occurred while checking material dependency.');
            }
        });
    }
} 