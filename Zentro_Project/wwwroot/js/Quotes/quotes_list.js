class quoteManager {
    constructor() {
        this.ajax = new AjaxService('/api/Quote/');
        this.events();
    }

    //page events
    events() {
        $('[data-createQuote]').off('click').on('click', async () => await startupClass.popupGenerator("/components/createQuote.html", ".modal-v", () => this.popupEvents()));
    }

    async popupEvents() {
        $('#template, #customer').on('change', function () {
            const templateId = $('#template').val();
            const customerId = $('#customer').val();
            if (templateId !== "0" && customerId !== "0") {
                $('#createQuote').removeClass('btn-disable').prop('disabled', false);
            } else {
                $('#createQuote').addClass('btn-disable').prop('disabled', true);
            }
        });
        $('#createQuote').off('click').on('click', async () => {
            const templateId = $('#template').val();
            const customerId = $('#customer').val();

            if (templateId === "0" || customerId === "0") {
                alert("Please select both Template and Customer before creating a quote.");
                return;
            }

            try {
                // Show loading UI
                $('#createQuote').prop('disabled', true).text('Creating...');

                // ✅ Call backend API (POST request)
                const result = await this.ajax.post('CreateQuoteOnly', {
                    templateVersionId: parseInt(templateId),
                    customerId: parseInt(customerId)
                });

                console.log('Quote created successfully:', result);

                window.location.href = `/Home/CreateQuote?id=${result}&customerId=${customerId}`;

            } catch (error) {
                console.error('Error creating quote:', error);
                alert("Failed to create quote. Please try again.");
            } finally {
                // Re-enable button
                $('#createQuote').prop('disabled', false).text('Create Quote');
            }

        });

        const pick = (obj, keys) => {
            for (const k of keys) if (obj?.[k] !== undefined && obj?.[k] !== null) return obj[k];
            return '';
        };

        const load = async (url, idKeys, nameKeys, selector) => {
            const res = await fetch(url);
            if (!res.ok) return; // silently fail (no options)
            let arr = await res.json();
            arr = arr?.data ?? arr ?? [];
            const $sel = $(selector).empty().append('<option value="0">Select</option>');
            arr.forEach(item => {
                const id = pick(item, idKeys) || '';
                const text = pick(item, nameKeys) || (id ? `#${id}` : '');
                $sel.append(`<option value="${id}">${text}</option>`);
            });
        };

        await load('/api/Quote/LatestTemplate',
            ['LatestVersionId', 'latestVersionId', 'Id', 'id', 'template_id'],
            ['TemplateName', 'templateName', 'Name', 'name', 'template_name'],
            '#template');

        await load('/api/Quote/Customers',
            ['CustomerId', 'customerId', 'Id', 'id', 'customer_id'],
            ['Name', 'name', 'CustomerName', 'customerName', 'customer_name'],
            '#customer');
    }
}