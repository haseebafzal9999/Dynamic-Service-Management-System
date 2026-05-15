class componentsTable {
    constructor(settingsPram = settings) {
        this.table;
        this.selectBoxesProducts;
        this.settings = settingsPram;
        this.materialCache = null; // ✅ cache to reuse loaded materials
        this.componentsList();
        this.events();
    }

    /* GENERAL FUNCTIONS */
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

    async loadMaterials(preselectedIds = []) {

        // ✅ Use cache if available
        let data = this.materialCache;
        if (!data) {
            const res = await fetch('/api/Material');
            data = await res.json();
            this.materialCache = data;
        }

        const wrapper = $('#materialMultiSelect');
        // Adding somenew classes only for material dropdown
        const box = wrapper.find('.custom-select-box');
        const optionsContainer = wrapper.find('.custom-select-options');
        const optionsList = wrapper.find('.options-list');

        // Clear prior content
        optionsList.empty();
        optionsContainer.find('input[type="text"]').remove(); // remove leftover search input (if any)

        optionsContainer.prepend('<input type="text" placeholder="Search..." class="material-search" />');

        // Build options dynamically
        data.forEach(m => {
            const checked = preselectedIds.includes(m.materialId) ? 'checked' : '';
            const optionHTML = `
                <label class="option select2-option-with-checkbox" style="display:block; margin:6px 0;">
                    <input type="checkbox" value="${m.materialId}" ${checked}>
                    <span class="checkbox-label">${m.name}</span>
                </label>
            `;


            optionsList.append(optionHTML);
        });

        // Add "no results" placeholder
        if (!optionsContainer.find('.no-results').length) {
            optionsList.after('<div class="no-results" style="display:none; padding:10px;">No results</div>');
        }
        const noResults = optionsContainer.find('.no-results');


        // Dropdown toggle
        box.off('click').on('click', (ev) => {
            ev.stopPropagation();
            optionsContainer.toggle();
            if (optionsContainer.is(':visible')) {
                optionsContainer.find('input.material-search').focus().select();
            }
        });

        // Close dropdown when clicking outside
        $(document).off('click.materialSelect').on('click.materialSelect', function (e) {
            if (!wrapper.is(e.target) && wrapper.has(e.target).length === 0) {
                optionsContainer.hide();
            }
        });

        // Search filter
        const searchInput = optionsContainer.find('input.material-search');
        searchInput.off('click keydown input').on('click keydown input', function (e) {
            e.stopPropagation();
        });

        searchInput.off('input').on('input', function () {
            const q = $(this).val().trim().toLowerCase();
            let anyVisible = false;

            optionsList.find('label.option').each(function () {
                const $label = $(this);
                const txt = $label.find('.checkbox-label').text().trim().toLowerCase();
                if (txt.indexOf(q) !== -1) {
                    $label.show();
                    anyVisible = true;
                } else {
                    $label.hide();
                }
            });

            if (anyVisible) noResults.hide();
            else noResults.show();
        });

        // Update display text
        const updateBoxText = () => {
            const selected = optionsList.find('input:checked').map(function () {
                return $(this).siblings('.checkbox-label').text();
            }).get();
            box.text(selected.length ? selected.join(', ') : 'Select Materials');
        };

        optionsList.off('change', 'input[type="checkbox"]').on('change', 'input[type="checkbox"]', updateBoxText);
        updateBoxText(); // initial text update





        // 🟢 Auto-calc total cost/sell price based on selected materials
        const costInput = $('#costPrice');
   

        const recalcPrices = () => {
            let totalCost = 0;


            optionsList.find('input:checked').each(function () {
                const id = $(this).val();
                const mat = data.find(m => m.materialId == id);
                if (mat) {
                    totalCost += parseFloat(mat.costPrice || 0);
   
                }
            });

            /*costInput.val(totalCost ? `$${totalCost.toFixed(2)}` : '');*/
            costInput.val(formatCurrency(totalCost));

        };

        // trigger price recalculation when selection changes
        optionsList.off('change.price').on('change.price', 'input[type="checkbox"]', recalcPrices);

        // recalc if preselected
        recalcPrices();
        $('.options-list').removeAttr('style');
        $('.options-list label').css('font-weight', 'normal');

    }

    //getting a list of records and adding then to the view
    componentsList() {
        var self = this;
        const url = '/api/component';
        function successCallback(results) {
            if (results.length == 0) {
                $('[data-norecords]').attr('style', 'display:block !important');
            } else {
                $('.innerBottomContainer').removeClass('hidden');
            }

            $('.tableCount span').text(`(${results.length})`);

            const formattedResults = results.map(item => ({
                ...item,
                id: item.componentId,
                link: `/page/component/${item.componentId}`,
            }));


            self.table = new tableClass(formattedResults, self.settings, formattedResults, "", ".container");
            self.table.hideShowFilterSearch();

            if (self.settings.checkboxes) {
                self.selectBoxesProducts = new checkBox(self.settings.tableHeader, '#table input', '');
            }
        };

        self.fetchData(url, successCallback);
    }

    events() {
        var self = this;

        $('[data-createComp]').off('click').on('click', (e) => {
            self.createUpdateComponent(e);
        });

        $(document).on('click', 'tbody tr', (e) => {
            self.createUpdateComponent(e);
        });
    }

    async createUpdateComponent(e) {
        var self = this;
        var url = "/Api/component/Create/";
        var currentTarget = e.currentTarget.tagName;

        await startupClass.popupGenerator("/components/manageComponent.html", ".modal-v");

        const saveButton = $('#createComponent');
        saveButton.prop('disabled', true);

        function toggleSaveButton() {
            const partNo = $('#itemPartNumber').val().trim();
            const itemName = $('#itemName').val().trim();
            const cost = $('#costPrice').val().trim();
            const sell = $('#sellPrice').val().trim();
            const supplier = $('#supplier').val().trim();
            const materials = $('#materialMultiSelect input[type="checkbox"]:checked');

            if (partNo && itemName && cost && sell && supplier && materials.length > 0) {
                saveButton.prop('disabled', false);
            } else {
                saveButton.prop('disabled', true);
            }
        }

        $('#itemPartNumber, #itemName, #costPrice, #sellPrice, #supplier')
            .off('input change')
            .on('input change', toggleSaveButton);

        $(document).on('change', '#materialMultiSelect input[type="checkbox"]', toggleSaveButton);

        // Default: load materials without preselection
        let preselectedIds = [];
        const costInput = $('#costPrice');
        const sellInput = $('#sellPrice');

        // 1️⃣ Attach blur/focus events first
        [costInput, sellInput].forEach(input => {
            input.off('blur').on('blur', function () {
                const formatted = self.formatCurrency($(this).val());
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
            url = "/Api/component/Update/";
            var itemid = $(e.target).closest('[data-itemid]').attr('data-itemid');
            $('.model-content').attr('data-itemid', itemid);
            self.checkComponentDependency();
            $('.t1-pop-up-heading').text('Update Component Record');
            $('#deleteComponent').removeClass('hidden');
            $('#createComponent').text('Update');

            $('#deleteComponent').off('click').on('click', (e) => {
                self.deleteComponent();
            });

            // Fetch component details for prefill
            try {
                const res = await fetch(`/Api/component/${itemid}`);
                const results = await res.json();

                $('#itemPartNumber').val(results.partNo || '');
                $('#itemName').val(results.name || '');
                $('#materialDes').val(results.description || '');
                $('#supplier').val(results.supplier || '');
                //$('#costPrice').val(results.buildCost || '');
                //$('#sellPrice').val(results.sellPrice || '');
                $('#costPrice').val(self.formatCurrency(results.buildCost));
                $('#sellPrice').val(self.formatCurrency(results.sellPrice));



                // Extract existing material IDs for preselect
                if (Array.isArray(results.selectedMaterialIds)) {
                    preselectedIds = [...results.selectedMaterialIds];
                } else if (results.selectedMaterialIds && typeof results.selectedMaterialIds === 'object') {
                    preselectedIds = Object.values(results.selectedMaterialIds);
                }
            } catch (error) {
                console.error("Error fetching component details:", error);
            }
        }

        // Load materials after popup and after fetching preselectedIds
        await self.loadMaterials(preselectedIds);

        // -------------------------
        // SAVE BUTTON CLICK
        // -------------------------
        $('#createComponent').off('click').on('click', (e) => {
            const materials = $('#materialMultiSelect input[type="checkbox"]:checked')
                .map(function () { return Number($(this).val()); })
                .get();

            var data = new FormData();
            data.append("PartNo", $('#itemPartNumber').val());
            data.append("Name", $('#itemName').val());
            data.append("Description", $('#materialDes').val());
            data.append("Supplier", $('#supplier').val());
            // Strip non-numeric characters and convert to float
            const costVal = parseFloat($('#costPrice').val().replace(/[^0-9.-]+/g, "")) || 0;
            const sellVal = parseFloat($('#sellPrice').val().replace(/[^0-9.-]+/g, "")) || 0;

            data.append("BuildCost", costVal);
            data.append("SellPrice", sellVal);

            materials.forEach(id => data.append("SelectedMaterialIds", id));
            
            if (currentTarget === 'TR') {
                data.append("componentId", $('.model-content').attr('data-itemid'));
            }

            $.ajax({
                url: url,
                data: data,
                type: 'POST',
                contentType: false,
                processData: false,
                success: (result) => {
                    $('#componentTable thead tr,#componentTable tbody,#componentTable .tableFilters').empty();
                    $('[data-norecords]').addClass('hidden').css('display', 'none');
                    $('#componentTable').removeClass('hidden').css('display', 'block');
                    self.componentsList();
                    $('.model-content').css('margin-bottom', '-200px');
                    $('.modal-v').fadeOut(300);
                    $('.model-content').remove();
                },
                error: (xhr, status, error) => {
                    console.error('AJAX Error:', status, error);
                    console.error('Response Text:', xhr.responseText);
                    try {
                        const err = JSON.parse(xhr.responseText);
                        console.error('Parsed Error:', err);
                    } catch (e) { }
                    alert("An error occurred. Please verify the details and try again.");
                }
            });
        });
    }

    // -------------------------
    // HELPER FUNCTION
    // -------------------------

    formatCurrency = (amount) => {
        if (!amount || isNaN(amount)) return "0.00";

        const currency = localStorage.getItem('currency') || 'GBP';
        const currencyIdentity = localStorage.getItem('currencyIdentity') || 'en-GB';

        return new Intl.NumberFormat(currencyIdentity, {
            style: "currency",
            currency: currency
        }).format(amount);
    };

    deleteComponent() {
        var self = this;
        var id = $('.model-content').attr('data-itemid')
        /*var xmin = $('.model-content').attr('data-xmin')*/
        $.ajax({
            url: `/Api/component/DeleteComponent/${id}`,
            type: 'DELETE',
            success: function (response) {
                $('#componentTable thead tr, #componentTable tbody, #componentTable .tableFilters').empty();
                $('[data-norecords]').addClass('hidden')
                $('#componentTable').addClass('hidden');
                self.componentsList();
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

    checkComponentDependency() {
        var id = $('.model-content').attr('data-itemid')
        $.ajax({
            url: `/Api/component/IsComponentDependent/${id}`,
            type: 'GET',
            contentType: 'application/json',
            success: function (response) {
                if (response.success) {
                    $('#deleteComponent').addClass('btn-disable')
                }

            },
            error: function (xhr) {
                alert('An error occurred while checking component dependency.');
            }
        });
    }


}
