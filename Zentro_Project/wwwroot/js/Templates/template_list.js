class templateManager {
    constructor() {
        this.events();
    }

    // Page Events
    events() {
        $('[data-createTemplate]')
            .off('click')
            .on('click', async () =>
                await startupClass.popupGenerator(
                    "/components/addTemplate.html",
                    ".modal-v",
                    () => this.popupEvents()
                )
            );
    }

    // Popup Events
    popupEvents() {

        const $templateName = $('#templateName');
        const $templateDes = $('#templateDes');
        const $createBtn = $('#createTemplate');

        // --- Enable/disable Create button ---
        function toggleCreateButton() {
            const name = $templateName.val().trim();
            if (name.length > 0) {
                $createBtn.removeClass('btn-disable');
            } else {
                $createBtn.addClass('btn-disable');
            }
        }

        $templateName.on('input', toggleCreateButton);
        toggleCreateButton(); // Initial check

        // --- Create button click event ---
        $createBtn.off('click').on('click', function (e) {
            e.preventDefault();

            if ($createBtn.hasClass('btn-disable')) return;

            // ✅ Match property names with your C# TemplateVM
            const templateData = {
                name: $templateName.val().trim(),
                description: $templateDes.val().trim()
            };


            // Disable button while saving
            $createBtn.addClass('btn-disable').text('Creating...');

            $.ajax({
                // ✅ Check if your controller route is correct:
                // if you’re using MVC controller -> '/Template/CreateTemplate'
                // if using API controller -> '/api/Template/Create'
                url: '/api/Template/Create',
                method: 'POST',
                contentType: 'application/json',
                data: JSON.stringify(templateData),
                success: function (response) {
                    if (response.success) {
                        // Redirect to Template Detail view
                        window.location.href = response.redirect;

                    } else {
                        alert('Error: ' + (response.message || 'Unable to create template.'));
                        $createBtn.removeClass('btn-disable').text('Create');
                    }
                },
                error: function (xhr) {
                    console.error('Error creating template:', xhr.responseText);
                    alert('An unexpected error occurred while creating the template.');
                    $createBtn.removeClass('btn-disable').text('Create');
                }
            });
        });
    }
}
