// MAIN CLASS: DefaultTemplateManager
class DefaultTemplateManager {
    constructor() {
        this.templateData = null;
        this.apiService = new DefaultApiService();
        this.renderer = new DefaultRenderer();
        this.eventManager = new DefaultEventManager();
        this.init();
    }

    async init() {
        try {
            //await this.loadTemplateData();
            await this.loadTemplateDataForToken();
            await this.checkRequiredAnswersAndToggleButton();
            this.setupEventDelegation();
            this.setupSubmitButton();
            document.addEventListener('input', () => this.checkRequiredAnswersAndToggleButton());
            document.addEventListener('change', () => this.checkRequiredAnswersAndToggleButton());

            console.log('✅ DefaultTemplateManager initialized');
        } catch (error) {
            this.handleError('Initialization failed', error);
        }
    }

    collectMetafieldAnswers() {
        const answers = [];
        document.querySelectorAll('#metafields-render-root input[type="text"][data-metafield-id]').forEach(input => {
            const metafieldId = input.getAttribute('data-metafield-id');
            const value = input.value;
            if (metafieldId && value && value.trim() !== "") {
                answers.push({
                    MetafieldId: parseInt(metafieldId),
                    MetafieldInput: value
                });
            }
        });
        return answers;
    }

    async checkRequiredAnswersAndToggleButton() {
        const submitBtn = document.getElementById('btn-save-1');
        if (!submitBtn || !this.templateData) return;

        console.log('📋 Template Data:', this.templateData);
        console.log('📋 Template Version ID:', this.templateData.templateVersion);

        // Collect all answered question IDs
        const answeredIds = new Set();

        // Checkboxes and radios
        document.querySelectorAll('input[type=checkbox].single-select-c:checked, input[type=radio]:checked').forEach(input => {
            answeredIds.add(parseInt(input.dataset.questionid));
        });

        // Select lists (not in table)
        document.querySelectorAll('select.section-input-c.selectt-c, select.conditional-select').forEach(select => {
            if (select.closest('.selects-wrapper-c')) return;
            if (select.value && select.value !== "") {
                const selectedOption = select.selectedOptions[0];
                answeredIds.add(parseInt(selectedOption.dataset.questionid || select.dataset.questionid));
            }
        });

        // Table rows
        document.querySelectorAll('.selects-wrapper-c').forEach(row => {
            const selectEl = row.querySelector('select');
            const quantityEl = row.querySelector('input[type=number]');
            if (selectEl && selectEl.value && selectEl.value !== "" && quantityEl && parseInt(quantityEl.value) > 0) {
                const selectedOption = selectEl.selectedOptions[0];
                answeredIds.add(parseInt(selectedOption.dataset.questionid || selectEl.dataset.questionid));
            }
        });

        // Text inputs
        document.querySelectorAll('input[type=text].section-input-c').forEach(input => {
            if (input.value && input.value.trim() !== "") {
                answeredIds.add(parseInt(input.dataset.questionid));
            }
        });

        // Call backend to check
        const templateVersionId = this.templateData.templateVersion;
        const idsArray = Array.from(answeredIds);
        console.log('📋 Answered Question IDs:', idsArray);

        const url = `/api/Quote/IsAllRequiredAnsweredForDefault?templateVersionId=${templateVersionId}&` +
            idsArray.map(id => `answeredQuestionIds=${id}`).join('&');
        console.log('📋 API URL:', url);



        try {
            const res = await fetch(url);
            const data = await res.json();

            console.log('📋 Required Check Response:', data);

            if (!data.hasRequired) {
                submitBtn.disabled = false;
                submitBtn.style.opacity = "1";
                submitBtn.style.pointerEvents = "auto";
                submitBtn.style.cursor = "";
            } else if (data.allAnswered) {
                submitBtn.disabled = false;
                submitBtn.style.opacity = "1";
                submitBtn.style.pointerEvents = "auto";
                submitBtn.style.cursor = "";
            } else {
                submitBtn.disabled = true;
                submitBtn.style.opacity = "0.5";
                submitBtn.style.pointerEvents = "none";
                submitBtn.style.cursor = "not-allowed";
            }
        } catch (err) {
            // On error, keep button enabled (fail open)
            submitBtn.disabled = false;
            submitBtn.style.opacity = "1";
            submitBtn.style.pointerEvents = "auto";
            submitBtn.style.cursor = "";
            console.error('Error checking required answers', err);
        }
    }

    //async loadTemplateData() {
    //    // Get latest template structure (no RecStatusId needed)
    //    const response = await this.apiService.makeRequest(
    //        '/api/Quote/GetLatestTemplateForDefault',
    //        'GET'
    //    );

    //    if (!response.success || !response.data) {
    //        throw new Error(response.message || 'Failed to load template');
    //    }

    //    this.templateData = response.data;

    //    console.log('📊 Template Data Loaded:', this.templateData);
    //    this.renderer.renderTemplate(this.templateData);

    //    await this.loadMetafields(this.templateData.templateVersion);

    //}
    async loadTemplateDataForToken() {

        // 1️⃣ Get version ID from token (await it)
        const templateId = await this.getTemplateId();

        if (!templateId) {
            throw new Error("Invalid or missing template version ID");
        }

        // 2️⃣ Pass it to the endpoint
        const response = await this.apiService.makeRequest(
            `/api/Quote/GetTemplateForDefaultToken?templateId=${templateId}`,
            'GET'
        );

        if (!response.success || !response.data) {
            throw new Error(response.message || 'Failed to load template');
        }

        // 3️⃣ Use the returned data
        this.templateData = response.data;

        console.log('📊 Template Data Loaded:', this.templateData);

        this.renderer.renderTemplate(this.templateData);

        await this.loadMetafields(this.templateData.templateVersion);
    }

    async  getTemplateId() {
    const token = document.getElementById("tokenInput")?.value;

    if (!token) {
        console.error("Token missing");
        return null;
    }

    try {
        const res = await fetch(`/api/IFrame/DecodeToken?token=${encodeURIComponent(token)}`, {
            method: "GET"
        });

        if (!res.ok) {
            console.error("Invalid token");
            return null;
        }

        const templateVersionId = await res.json();
        console.log("Template Version ID:", templateVersionId);

        return templateVersionId;

    } catch (err) {
        console.error("Error decoding token:", err);
        return null;
    }
}

    setupEventDelegation() {
        this.eventManager.setupGlobalHandlers(this);
    }

    setupSubmitButton() {
        const submitBtn = document.getElementById('btn-save-1');
        if (submitBtn) {
            submitBtn.addEventListener('click', async (e) => {
                e.preventDefault();
                await this.handleSubmit();
            });
        }
    }

    async handleSubmit() {
        try {
            // Collect all answers from form
            const answers = this.collectAllAnswers();

            if (answers.length === 0) {
                alert('Please answer at least one question');
                return;
            }

            console.log('📤 Submitting answers:', answers);

            // 1. Create the quote and get the new QuoteId (recStatusId)
            const response = await this.apiService.makeRequest(
                '/api/Quote/CreateAndSaveQuote',
                'POST',
                {
                    TemplateId: this.templateData.templateId,
                    TemplateVersion: this.templateData.templateVersion,
                    Answers: answers,
                    customerId: null
                }
            );

            if (response.success) {
                // 2. Collect metafield answers
                const metafieldAnswers = this.collectMetafieldAnswers();

                // 3. Save metafield answers if any
                if (metafieldAnswers.length > 0) {
                    await this.apiService.makeRequest(
                        '/api/Metafield/SaveMetafieldAnswersBulk',
                        'POST',
                        {
                            QuoteId: response.recStatusId,
                            TemplateVersionId: this.templateData.templateVersion,
                            Answers: metafieldAnswers
                        }
                    );
                }

                // 4. Redirect as before
                window.location.href = `/Home/SubmitQuestionnaire?recordId=${response.recStatusId}&quoteRef=${encodeURIComponent(response.quoteReference)}`;
            } else {
                alert('❌ Failed to create quote: ' + response.message);
            }
        } catch (error) {
            console.error('❌ Submit error:', error);
            alert('Failed to submit quote');
        }
    }

    collectAllAnswers() {
        const answers = [];

        // 1. Collect checkboxes
        document.querySelectorAll('input[type=checkbox].single-select-c:checked').forEach(checkbox => {
            const parentOptionId = checkbox.getAttribute('data-parent-option-id') || null;
            answers.push({
                QuestionId: parseInt(checkbox.dataset.questionid),
                SelectedOptionId: parseInt(checkbox.value),
                AnswerText: null,
                Quantity: 1,
                ParentOptionId: parentOptionId ? parseInt(parentOptionId) : null
            });
        });

        // 2. Collect radio buttons
        document.querySelectorAll('input[type=radio]:checked').forEach(radio => {
            const parentOptionId = radio.getAttribute('data-parent-option-id') || null;
            answers.push({
                QuestionId: parseInt(radio.dataset.questionid),
                SelectedOptionId: parseInt(radio.value),
                AnswerText: null,
                Quantity: 1,
                ParentOptionId: parentOptionId ? parseInt(parentOptionId) : null
            });
        });

        // 3. Collect select lists (non-table)
        document.querySelectorAll('select.section-input-c.selectt-c, select.conditional-select').forEach(select => {
            // Skip if it's inside a table row
            if (select.closest('.selects-wrapper-c')) return;

            if (select.value && select.value !== "") {
                const selectedOption = select.selectedOptions[0];
                const parentOptionId = select.getAttribute('data-parent-option-id') ||
                    select.closest('[data-parent-option-id]')?.getAttribute('data-parent-option-id') ||
                    null;

                answers.push({
                    QuestionId: parseInt(selectedOption.dataset.questionid || select.dataset.questionid),
                    SelectedOptionId: parseInt(select.value),
                    AnswerText: null,
                    Quantity: 1,
                    ParentOptionId: parentOptionId ? parseInt(parentOptionId) : null
                });
            }
        });

        // 4. Collect table rows
        document.querySelectorAll('.selects-wrapper-c').forEach(row => {
            const selectEl = row.querySelector('select');
            const quantityEl = row.querySelector('input[type=number]');

            if (selectEl && selectEl.value && selectEl.value !== "") {
                const selectedOption = selectEl.selectedOptions[0];
                const quantity = quantityEl ? parseInt(quantityEl.value) || 1 : 1;

                // Get ParentOptionId from select or parent container
                const parentOptionId = selectEl.getAttribute('data-parent-option-id') ||
                    row.closest('[data-parent-option-id]')?.getAttribute('data-parent-option-id') ||
                    null;

                // Only add if quantity > 0
                if (quantity > 0) {
                    answers.push({
                        QuestionId: parseInt(selectedOption.dataset.questionid || selectEl.dataset.questionid),
                        SelectedOptionId: parseInt(selectEl.value),
                        AnswerText: quantity.toString(),
                        Quantity: quantity,
                        ParentOptionId: parentOptionId ? parseInt(parentOptionId) : null
                    });
                }
            }
        });

        // 5. Collect text inputs (ONLY those with a valid questionid)
        document.querySelectorAll('input[type=text].section-input-c').forEach(input => {
            if (
                input.value &&
                input.value.trim() !== "" &&
                input.hasAttribute('data-questionid') &&
                input.dataset.questionid &&
                !isNaN(parseInt(input.dataset.questionid))
            ) {
                const parentOptionId = input.getAttribute('data-parent-option-id') ||
                    input.closest('[data-parent-option-id]')?.getAttribute('data-parent-option-id') ||
                    null;

                answers.push({
                    QuestionId: parseInt(input.dataset.questionid),
                    SelectedOptionId: null,
                    AnswerText: input.value,
                    Quantity: 1,
                    ParentOptionId: parentOptionId ? parseInt(parentOptionId) : null
                });
            }
        });

        return answers;
    }

    // LOAD METAFIELDS
    async loadMetafields(templateVersionId) {
        try {
            const response = await this.apiService.makeRequest(
                '/api/Metafield/GetMetafieldsForPreview',
                'POST',
                { templateVersionId: templateVersionId }
            );

            if (response.success && response.data && response.data.length > 0) {
                const visibleMetafields = response.data.filter(
                    m => (m.visibility || '').toLowerCase() !== 'admin only'
                );

                // if no visible metafields, hide the entire section (heading + content)
                const metafieldContainer = document.getElementById('metafields-container');
                const renderRoot = document.getElementById('metafields-render-root');

                if (!visibleMetafields.length) {
                    if (metafieldContainer) metafieldContainer.style.display = 'none';
                    if (renderRoot) renderRoot.innerHTML = '';
                    console.log('ℹ️ No customer-visible metafields found');
                    return;
                }

                // Render only visible metafields
                this.metafields = visibleMetafields;
                this.renderer.renderMetafields(this.metafields);
                console.log('✅ Metafields loaded:', this.metafields);
            } else {
                // No metafields at all: hide section
                const metafieldContainer = document.getElementById('metafields-container');
                const renderRoot = document.getElementById('metafields-render-root');
                if (metafieldContainer) metafieldContainer.style.display = 'none';
                if (renderRoot) renderRoot.innerHTML = '';
                console.log('ℹ️ No metafields found');
            }
        } catch (error) {
            console.error('❌ Error loading metafields:', error);
        }
    }

    handleError(context, error) {
        console.error(`❌ ${context}:`, error);
        alert(`Failed to ${context.toLowerCase()}`);
    }
    handleError(context, error) {
        console.error(`❌ ${context}:`, error);
        alert(`Failed to ${context.toLowerCase()}`);
    }
}

// API SERVICE CLASS
class DefaultApiService {
    async fetchDependentQuestions(templateVersionId, questionOptionId) {
        const url = '/api/Quote/GetDependentQuestionsForDefault';
        return this.makeRequest(url, 'POST', { templateVersionId, questionOptionId });
    }

    async makeRequest(url, method = 'GET', data = null) {
        const config = {
            method: method,
            credentials: 'same-origin',
            headers: {
                'Accept': 'application/json',
                'Content-Type': 'application/json'
            }
        };

        if (data) {
            config.body = JSON.stringify(data);
        }

        const response = await fetch(url, config);
        if (!response.ok) {
            const error = await this.parseError(response);
            throw error;
        }
        return response.json();
    }

    async parseError(response) {
        try {
            const body = await response.json();
            return new Error(body.message || `API returned ${response.status}`);
        } catch {
            return new Error(`Request failed with status ${response.status}`);
        }
    }
}

// RENDERER CLASS 
class DefaultRenderer {
    constructor() {
        this.container = document.getElementById('question-render-root');
    }

    renderTemplate(data) {
        if (!this.container) {
            throw new Error('Question container not found');
        }

        this.setTemplateMetadata(data);
        this.renderQuestions(data);
        this.expandFirstGroup();
    }

    setTemplateMetadata(data) {
        // Set page title
        const pageTitle = document.querySelector('.main-heading-c');
        if (pageTitle) {
            pageTitle.textContent = data.templateName || 'Default Template';
        }

        // Build option prices map for calculations (if needed later)
        window.optionPricesMap = {};
        if (data.questionGroups) {
            data.questionGroups.forEach(group => {
                if (group.questions) {
                    group.questions.forEach(question => {
                        if (question.options) {
                            question.options.forEach(opt => {
                                window.optionPricesMap[opt.qOptionId] = {
                                    costPrice: opt.costPrice || 0,
                                    sellPrice: opt.sellPrice || 0
                                };
                            });
                        }
                    });
                }
            });
        }
    }

    renderQuestions(data) {
        this.container.innerHTML = '';
        const questionGroups = data.questionGroups || [];

        if (!questionGroups.length) {
            this.container.innerHTML = '<p class="text-center">No question groups found.</p>';
            return;
        }

        console.log(`📊 Rendering ${questionGroups.length} question groups`);
        questionGroups.forEach((group, index) => {
            const groupElement = this.createGroupElement(group, index);
            this.container.appendChild(groupElement);
        });
    }

    createGroupElement(group, index) {
        const itemDiv = this.createDOMElement('div', { className: 'item-c' });

        const headerWrapper = this.createDOMElement('div', { className: 'section-container-c' });
        const header = this.createGroupHeader(group, index);
        headerWrapper.appendChild(header);
        itemDiv.appendChild(headerWrapper);

        const sectionDiv = this.createGroupSection(group, index);
        itemDiv.appendChild(sectionDiv);

        return itemDiv;
    }

    createGroupHeader(group, index) {
        const header = this.createDOMElement('header', {
            className: `dropdown-header-c parentToggler shadow-c ${index === 0 ? 'auto-open' : ''}`,
            id: `capsule-${group.questionGroupId}`
        });

        header.innerHTML = `
            <span class="dropdown-header-text-c">${this.escapeHtml(group.questionGroupName)}</span>
            <span class="carrot-c">
                <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="size-6">
                    <path stroke-linecap="round" stroke-linejoin="round" d="m19.5 8.25-7.5 7.5-7.5-7.5" />
                </svg>
            </span>
            <div class="section-line-breaker-c hidden"></div>
        `;

        return header;
    }

    createGroupSection(group, index) {
        const sectionDiv = this.createDOMElement('div', {
            className: `section-container-c shadow-c hidden ${index === 0 ? 'auto-open-target' : ''}`,
            id: `groupSection-${group.questionGroupId}`
        });

        const sectionBox = this.createDOMElement('section', {
            className: 'section-box-c top-corners-c less-padding-c'
        });

        if (group.questions && group.questions.length) {
            group.questions.forEach(question => {
                const questionElement = this.renderQuestion(question);
                sectionBox.appendChild(questionElement);
            });
        }

        sectionDiv.appendChild(sectionBox);
        return sectionDiv;
    }

    renderQuestion(question) {
        const questionDiv = this.createDOMElement('div', {
            className: 'question-bottom-margins-c',
            attributes: {
                'data-is-required': question.isRequired ? 'true' : 'false',
                'data-question-id': question.questionId
            }
        });

        const headingHTML = `
            <h2 class="section-subheading-c no-margin-c">
                ${this.escapeHtml(question.questionText)}
                ${question.isRequired ? '<span class="required-asterisk-c">*</span>' : ''}
            </h2>
            <input type="hidden" name="Answers[${question.questionId}].QuestionId" value="${question.questionId}" />
        `;

        questionDiv.innerHTML = headingHTML;

        const fieldType = this.getFieldType(question);
        this.renderQuestionOptions(questionDiv, question, fieldType);

        return questionDiv;
    }

    renderQuestionOptions(container, question, fieldType) {
        const sortedOptions = question.options
            ? [...question.options].sort((a, b) => (a.optionDisplayOrder || 0) - (b.optionDisplayOrder || 0))
            : [];

        switch (fieldType) {
            case 'checkboxes':
                this.renderCheckboxes(container, question, sortedOptions);
                break;
            case 'radio buttons':
                this.renderRadioButtons(container, question, sortedOptions);
                break;
            case 'table':
                this.renderTable(container, question, sortedOptions);
                break;
            case 'select list':
                this.renderSelectList(container, question, sortedOptions);
                break;
            case 'input':
                this.renderInput(container, question);
                break;
            default:
                container.innerHTML += `<p class="text-gray-500-c">Unsupported field type: ${fieldType}</p>`;
        }
    }

    renderCheckboxes(container, question, sortedOptions) {
        sortedOptions.forEach((opt, index) => {
            const checkboxDiv = this.createDOMElement('div', {
                className: `checkbox-wrapper-c ${index > 0 ? 'less-top-margin-c' : ''}`
            });

            checkboxDiv.innerHTML = `
                <input type="checkbox"
                    id="q-${question.questionId}-opt-${opt.qOptionId}"
                    name="Answers[${question.questionId}].SelectedOptionId"
                    value="${opt.qOptionId}"
                    class="radio-style-c single-select-c"
                    data-questionid="${question.questionId}"
                    data-optionid="${opt.qOptionId}"
                    data-sellprice="${opt.sellPrice || 0}"
                    data-costprice="${opt.costPrice || 0}"
                    data-toggle="conditional"
                />
                <label class="checkbox-text-c" for="q-${question.questionId}-opt-${opt.qOptionId}">
                    ${this.escapeHtml(opt.optionText)}
                </label>
            `;

            container.appendChild(checkboxDiv);
        });

        const dependentDiv = this.createDOMElement('div', {
            className: 'dependent-section-c hidden',
            attributes: { 'data-question': question.questionId }
        });
        container.appendChild(dependentDiv);
    }

    renderRadioButtons(container, question, sortedOptions) {
        sortedOptions.forEach((opt, index) => {
            const radioDiv = this.createDOMElement('div', {
                className: `checkbox-wrapper-c ${index > 0 ? 'less-top-margin-c' : ''}`
            });

            radioDiv.innerHTML = `
                <input type="radio"
                    id="q-${question.questionId}-opt-${opt.qOptionId}"
                    name="Answers[${question.questionId}].SelectedOptionId"
                    value="${opt.qOptionId}"
                    class="radio-style-c single-select-c"
                    data-questionid="${question.questionId}"
                    data-optionid="${opt.qOptionId}"
                    data-sellprice="${opt.sellPrice || 0}"
                    data-costprice="${opt.costPrice || 0}"
                    data-toggle="conditional"
                />
                <label class="checkbox-text-c" for="q-${question.questionId}-opt-${opt.qOptionId}">
                    ${this.escapeHtml(opt.optionText)}
                </label>
            `;

            container.appendChild(radioDiv);
        });

        const dependentDiv = this.createDOMElement('div', {
            className: 'dependent-section-c hidden',
            attributes: { 'data-question': question.questionId }
        });
        container.appendChild(dependentDiv);
    }

    renderTable(container, question, sortedOptions) {
        let tableHTML = `
            <div class="section-container-c line-item-modal-c">
                <header class="popup-section-header-c no-top-margin-c custom-bg-c">
                    <span class="popup-header-text-c">Type</span>
                    <span class="popup-header-text-c line-modal-margin-c">Quantity</span>
                    <span class="popup-header-text-c"></span>
                </header>
                <div class="line-item-modal-c popup-sub-box-c top-corners-c">
                    <div class="selects-container-c" id="table-rows-${question.questionId}">
                        <div class="selects-wrapper-c">
                            <div class="section-input-wrapper-c less-width-select2-c">
                                <select class="section-input-c selectt-c conditional-select"
                                    name="Answers[${question.questionId}].LineItems[0].OptionId"
                                    data-toggle="conditional"
                                    data-questionid="${question.questionId}">
                                    <option value="">Select</option>
                                    ${sortedOptions.map(opt => `
                                        <option value="${opt.qOptionId}"
                                            data-questionid="${question.questionId}"
                                            data-optionid="${opt.qOptionId}"
                                            data-sellprice="${opt.sellPrice || 0}"
                                            data-costprice="${opt.costPrice || 0}">
                                            ${this.escapeHtml(opt.optionText)}
                                        </option>
                                    `).join('')}
                                </select>
                            </div>
                            <div class="section-input-wrapper-c less-width-select2-c">
                                <input type="number"
                                    class="section-input-c"
                                    name="Answers[${question.questionId}].LineItems[0].Quantity"
                                    data-questionid="${question.questionId}"
                                    min="0"
                                    value="0"
                                />
                            </div>
                            <div class="line-item-cross-container-c">
                                <button type="button" class="line-item-cross-btn-c">
                                    <img src="/images/close-cancel.svg" alt="Remove">
                                </button>
                            </div>
                        </div>
                    </div>
                    <div class="save-btn-container-c">
                        <button type="button" class="btn-save-c add-line-c" data-question="${question.questionId}">
                            Add Line Item
                        </button>
                    </div>
                </div>
            </div>
        `;

        container.innerHTML += tableHTML;

        const dependentDiv = this.createDOMElement('div', {
            className: 'dependent-section-c hidden',
            attributes: { 'data-question': question.questionId }
        });
        container.appendChild(dependentDiv);
    }

    renderSelectList(container, question, sortedOptions) {
        const selectHTML = `
            <div class="section-input-wrapper-c less-width-select-c">
                <select class="section-input-c selectt-c conditional-select"
                    name="Answers[${question.questionId}].SelectedOptionId"
                    id="q-${question.questionId}"
                    data-questionid="${question.questionId}"
                    data-toggle="conditional">
                    <option value="">Select</option>
                    ${sortedOptions.map(opt => `
                        <option value="${opt.qOptionId}"
                            data-questionid="${question.questionId}"
                            data-optionid="${opt.qOptionId}"
                            data-sellprice="${opt.sellPrice || 0}"
                            data-costprice="${opt.costPrice || 0}">
                            ${this.escapeHtml(opt.optionText)}
                        </option>
                    `).join('')}
                </select>
            </div>
        `;

        container.innerHTML += selectHTML;

        const dependentDiv = this.createDOMElement('div', {
            className: 'dependent-section-c hidden',
            attributes: { 'data-question': question.questionId }
        });
        container.appendChild(dependentDiv);
    }

    renderInput(container, question) {
        const inputHTML = `
            <div class="section-input-wrapper-c less-width-select-c">
                <input type="text"
                    class="section-input-c"
                    name="Answers[${question.questionId}].AnswerText"
                    id="q-${question.questionId}"
                    data-questionid="${question.questionId}"
                    data-optionid="0"
                    value=""
                />
            </div>
        `;

        container.innerHTML += inputHTML;
    }

    expandFirstGroup() {
        const firstHeader = document.querySelector('.dropdown-header-c.auto-open');
        const firstSection = document.querySelector('.section-container-c.auto-open-target');

        if (firstHeader && firstSection) {
            // Open first group instantly WITHOUT transition
            firstSection.classList.remove('hidden');
            firstSection.style.display = '';
            firstSection.style.overflow = '';
            firstSection.style.maxHeight = '';

            const carrotSvg = firstHeader.querySelector('.carrot-c svg');
            if (carrotSvg) {
                carrotSvg.classList.add('rotate-180-c');
            }

            firstHeader.classList.add('bottom-corners-c');
            firstHeader.classList.remove('shadow-c');
            firstHeader.classList.add('shadow-toggle-c');

            const breaker = firstHeader.querySelector('.section-line-breaker-c');
            if (breaker) {
                breaker.classList.remove('hidden');
            }

            firstHeader.style.borderRadius = '0.75rem 0.75rem 0 0';
        }
    }

    toggleGroup(header, section, forceOpen = false) {
        const isHidden = section.classList.contains('hidden');
        const shouldOpen = forceOpen ? true : isHidden;

        if (shouldOpen) {
            section.style.display = 'block';
            section.style.overflow = 'hidden';
            section.style.maxHeight = '0px';
            section.classList.remove('hidden');
            header.style.borderRadius = '0.75rem 0.75rem 0 0';

            setTimeout(() => {
                section.style.transition = 'max-height 0.4s ease';
                section.style.maxHeight = section.scrollHeight + 'px';
            }, 70);

            setTimeout(() => {
                section.style.transition = '';
                section.style.maxHeight = '';
                section.style.overflow = '';
                section.style.display = '';
            }, 310);
        } else {
            header.style.borderRadius = '0.75rem 0.75rem 0 0';
            section.style.overflow = 'hidden';
            section.style.transition = 'max-height 0.4s ease';
            section.style.maxHeight = section.scrollHeight + 'px';

            setTimeout(() => {
                section.style.maxHeight = '0px';
            }, 70);

            setTimeout(() => {
                section.classList.add('hidden');
                section.style.transition = '';
                section.style.maxHeight = '';
                section.style.overflow = '';
                section.style.display = '';
                header.style.borderRadius = '0.75rem';
            }, 310);
        }

        const carrotSvg = header.querySelector('.carrot-c svg');
        if (carrotSvg) {
            carrotSvg.classList.toggle('rotate-180-c', shouldOpen);
        }

        header.classList.toggle('bottom-corners-c', shouldOpen);
        header.classList.toggle('shadow-c');
        header.classList.toggle('shadow-toggle-c');

        const breaker = header.querySelector('.section-line-breaker-c');
        if (breaker) {
            breaker.classList.toggle('hidden', !shouldOpen);
        }
    }

    getFieldType(question) {
        const fieldType = question.fieldTypeName || question.fieldTypeDisplayName || '';
        return fieldType.toLowerCase();
    }

    escapeHtml(text) {
        if (!text) return '';
        const div = document.createElement('div');
        div.textContent = text;
        return div.innerHTML;
    }

    createDOMElement(tag, { className, id, attributes = {} }) {
        const element = document.createElement(tag);
        if (className) element.className = className;
        if (id) element.id = id;
        Object.entries(attributes).forEach(([key, value]) => {
            element.setAttribute(key, value);
        });
        return element;
    }

    renderMetafields(metafields) {
        const container = document.getElementById('metafields-render-root');
        const metafieldContainer = document.getElementById('metafields-container');

        if (!container || !metafieldContainer) {
            console.error('❌ Metafield containers not found');
            return;
        }

        if (!metafields || metafields.length === 0) {
            metafieldContainer.style.display = 'none';
            return;
        }

        // Show metafield section
        metafieldContainer.style.display = 'block';
        container.innerHTML = '';

        metafields
            .filter(metafield => metafield.visibility?.toLowerCase() !== "admin only")
            .forEach(metafield => {
            const metafieldDiv = this.createDOMElement('div', {
                className: 'question-bottom-margins-c',
                attributes: {
                    'data-metafield-id': metafield.pid
                }
            });

            const headingHTML = `
            <h2 class="section-subheading-c no-margin-c">
                ${this.escapeHtml(metafield.name)}
            </h2>
        `;

            metafieldDiv.innerHTML = headingHTML;

            const inputHTML = `
            <div class="section-input-wrapper-c less-width-select-c">
                <input type="text"
                    class="section-input-c"
                    data-metafield-id="${metafield.pid}"
                />
            </div>
                `;

            metafieldDiv.innerHTML += inputHTML;
            container.appendChild(metafieldDiv);
        });

        console.log(`✅ Rendered ${metafields.length} metafields`);
    }
}
// EVENT MANAGER CLASS - COMPLETE REPLACEMENT
class DefaultEventManager {
    setupGlobalHandlers(manager) {
        this.manager = manager;
        this.setupGroupToggleHandlers();
        this.setupConditionalQuestionHandlers();
        this.setupTableHandlers();
        this.setupSingleCheckboxEnforcement();
    }

    setupGroupToggleHandlers() {
        const container = document.querySelector('.capsule-containers-c') || document.getElementById('question-render-root');
        if (!container) return;

        container.addEventListener('click', (e) => {
            const header = e.target.closest('.dropdown-header-c.parentToggler');
            if (!header) return;

            e.preventDefault();
            e.stopPropagation();

            // CHECK: Is it metafield header?
            if (header.classList.contains('metafield-header')) {
                const headerWrapper = header.closest('.section-container-c');
                const metafieldSection = headerWrapper?.nextElementSibling;

                if (metafieldSection && metafieldSection.classList.contains('metafield-section')) {
                    this.manager.renderer.toggleGroup(header, metafieldSection);
                }
                return;
            }

            // REGULAR QUESTION GROUPS
            const sectionContainer = header.closest('.section-container-c');
            const dropDown = sectionContainer?.nextElementSibling;

            if (dropDown?.classList.contains('section-container-c')) {
                this.manager.renderer.toggleGroup(header, dropDown);
            }
        });

        console.log('✅ Group toggle handlers setup');
    }

    setupTableHandlers() {
        document.addEventListener('click', (e) => {
            if (e.target.closest('.add-line-c')) {
                this.handleAddLineItem(e.target.closest('.add-line-c'));
            }
            if (e.target.closest('.line-item-cross-btn-c')) {
                this.handleRemoveLineItem(e.target.closest('.line-item-cross-btn-c'));
            }
        });

        console.log('✅ Table handlers setup');
    }

    handleAddLineItem(button) {
        const questionId = button.getAttribute('data-question');
        const container = document.getElementById(`table-rows-${questionId}`);

        if (!container) return;

        const firstSelect = container.querySelector('select');
        if (!firstSelect) return;

        const maxRows = firstSelect.options.length - 1;
        const currentRows = container.querySelectorAll('.selects-wrapper-c').length;
        if (currentRows >= maxRows) return;

        // ✅ Get ParentOptionId from the container or parent element
        const parentOptionId = container.closest('[data-parent-option-id]')?.getAttribute('data-parent-option-id') || null;

        const newIndex = currentRows;
        const newRow = document.createElement('div');
        newRow.className = 'selects-wrapper-c';

        if (parentOptionId) {
            newRow.setAttribute('data-parent-option-id', parentOptionId);
        }

        newRow.innerHTML = `
            <div class="section-input-wrapper-c less-width-select2-c">
                <select class="section-input-c selectt-c conditional-select"
                        name="Answers[${questionId}].LineItems[${newIndex}].OptionId"
                        data-toggle="conditional"
                        data-questionid="${questionId}"
                        ${parentOptionId ? `data-parent-option-id="${parentOptionId}"` : ''}>
                    ${firstSelect.innerHTML}
                </select>
            </div>
            <div class="section-input-wrapper-c less-width-select2-c">
                <input type="number"
                       class="section-input-c"
                       name="Answers[${questionId}].LineItems[${newIndex}].Quantity"
                       data-questionid="${questionId}"
                       ${parentOptionId ? `data-parent-option-id="${parentOptionId}"` : ''}
                       min="0" value="0" />
            </div>
            <div class="line-item-cross-container-c">
                <button type="button" class="line-item-cross-btn-c">
                    <img src="/images/close-cancel.svg" alt="Remove">
                </button>
            </div>
        `;

        container.appendChild(newRow);
        console.log(`➕ Added line item for question ${questionId} with ParentOptionId: ${parentOptionId}`);
    }

    handleRemoveLineItem(removeButton) {
        const row = removeButton.closest('.selects-wrapper-c');
        const container = row?.closest('.selects-container-c');
        const wrappers = container ? container.querySelectorAll('.selects-wrapper-c') : [];

        if (container && wrappers.length > 1) {
            row.remove();
            console.log('➖ Removed line item');
        } else if (container && wrappers.length === 1) {
            const select = row.querySelector('select');
            const input = row.querySelector('input[type="number"]');
            if (select) select.selectedIndex = 0;
            if (input) input.value = 0;
            console.log('🔄 Reset last line item');
        }
    }

    setupConditionalQuestionHandlers() {
        document.addEventListener('change', async (e) => {
            if (!e.target.matches('[data-toggle=conditional]')) return;

            const input = e.target;
            const questionDiv = input.closest('.question-bottom-margins-c');
            const questionIdInput = questionDiv?.querySelector('input[type=hidden][name$=".QuestionId"]');
            const questionId = questionIdInput?.value;

            if (!questionId) return;

            // ✅ Get the parent option ID of the current input (for nested dependents)
            const currentParentOptionId = input.getAttribute('data-parent-option-id') || null;

            const dependentContainer = questionDiv.querySelector('.dependent-section-c');

            // ✅ Clear only this specific dependent section
            if (dependentContainer) {
                dependentContainer.classList.add('hidden');
                dependentContainer.innerHTML = '';
                dependentContainer.removeAttribute('data-parent-option');
                console.log(`🗑️ Cleared dependent section for Q${questionId}`);
            }

            // Load new dependents if option is selected
            if (input.checked || (input.tagName === 'SELECT' && input.value)) {
                const optionId = parseInt(input.value);
                const templateVersionId = this.manager.templateData.templateVersion;

                console.log(`📥 Loading dependents for Q${questionId}, Option${optionId}, ParentOption${currentParentOptionId}`);

                try {
                    const result = await this.manager.apiService.fetchDependentQuestions(templateVersionId, optionId);
                    if (result.success && result.data) {
                        this.renderDependentQuestions(optionId, result.data, questionId, questionDiv);
                        console.log(`✅ Rendered dependents for Q${questionId}`);
                    }
                } catch (error) {
                    console.error('❌ Error fetching dependent questions:', error);
                }
            }
        });

        console.log('✅ Conditional question handlers setup with parent-aware tracking');
    }

    renderDependentQuestions(optionId, dependentData, parentQuestionId, parentQuestionDiv) {
        const dependentSection = parentQuestionDiv.querySelector('.dependent-section-c');
        if (!dependentSection) return;

        // ✅ Mark this section with the parent option ID
        dependentSection.setAttribute('data-parent-option', optionId);
        dependentSection.classList.remove('hidden');
        dependentSection.innerHTML = '';

        if (dependentData.questionGroups && dependentData.questionGroups.length > 0) {
            dependentData.questionGroups.forEach(group => {
                group.questions.forEach(question => {
                    const questionElement = this.manager.renderer.renderQuestion(question);

                    // ✅ Mark the container with parent option ID
                    questionElement.setAttribute('data-parent-option-id', optionId);

                    // ✅ Add ParentOptionId to all inputs in this dependent question
                    questionElement.querySelectorAll('input, select').forEach(input => {
                        input.setAttribute('data-parent-option-id', optionId);
                    });

                    // ✅ Make the nested dependent section unique
                    const nestedDependentSection = questionElement.querySelector('.dependent-section-c');
                    if (nestedDependentSection) {
                        nestedDependentSection.setAttribute('data-grandparent-option', optionId);
                    }

                    dependentSection.appendChild(questionElement);
                });
            });

            // Update prices map
            window.optionPricesMap = window.optionPricesMap || {};
            dependentData.questionGroups.forEach(group => {
                if (group.questions) {
                    group.questions.forEach(question => {
                        if (question.options) {
                            question.options.forEach(opt => {
                                window.optionPricesMap[opt.qOptionId] = {
                                    costPrice: opt.costPrice || 0,
                                    sellPrice: opt.sellPrice || 0
                                };
                            });
                        }
                    });
                }
            });

            console.log(`✅ Rendered dependent questions for option ${optionId} with ParentOptionId tracking`);
        }

        if (window.defaultTemplateManager) {
            window.defaultTemplateManager.checkRequiredAnswersAndToggleButton();
        }
    }

    setupSingleCheckboxEnforcement() {
        document.addEventListener('change', function (e) {
            if (e.target.matches('input[type=checkbox].single-select-c')) {
                const groupName = e.target.name;
                if (groupName) {
                    document.querySelectorAll(`input[type=checkbox][name="${groupName}"]`).forEach(cb => {
                        if (cb !== e.target) cb.checked = false;
                    });
                }
            }
        });

        console.log('✅ Single checkbox enforcement setup');
    }
}

document.addEventListener('DOMContentLoaded', () => {
    window.defaultTemplateManager = new DefaultTemplateManager();

});