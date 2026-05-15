// MAIN CLASS: CreateQuoteManager
class CreateQuoteManager {
    constructor() {
        this.quoteData = null;
        this.apiService = new CreateQuoteApiService();
        this.renderer = new CreateQuoteRenderer();
        this.eventManager = new CreateQuoteEventManager();
        this.stickyNoteManager = new CreateQuoteStickyNoteManager();
        this.autoSaveManager = new CreateQuoteAutoSaveManager();
        this.metafields = [];
        this.init();
        this.setupReviewButton();
    }

    async init() {
        try {
            await this.loadTemplateData();
            this.setupEventDelegation();
            this.autoSaveManager.setup();
            //('✅ CreateQuoteManager initialized');
        } catch (error) {
            this.handleError('Initialization failed', error);
        }
    }

    async loadTemplateData() {
        const quoteId = this.getQuoteId();
        if (!quoteId) {
            throw new Error('QuoteId not found');
        }

        // Get template structure (no answers)
        const response = await this.apiService.makeRequest(
            '/api/Quote/GetTemplateForCreateQuote',
            'POST',
            { id: quoteId }
        );

        if (!response.success || !response.data) {
            throw new Error(response.message || 'Failed to load template');
        }

        this.quoteData = response.data;

        if (response.currency) {
            localStorage.setItem('currency', response.currency);
        }
        if (response.currencyIdentity) {
            localStorage.setItem('currencyIdentity', response.currencyIdentity);
        }

        this.quoteData.customerName = response.customerName;
        this.quoteData.quoteId = quoteId;
        this.quoteData.templateName = response.templateName;
        console.log('📊 Template Data Loaded:', this.quoteData);
        this.renderer.renderTemplate(this.quoteData);
        this.stickyNoteManager.initialize(this.quoteData);
        const headingEl = document.querySelector('.main-heading-c');
        if (headingEl && this.quoteData.templateName) {
            headingEl.textContent = this.quoteData.templateName;
        }

        await this.loadMetafields(quoteId);
    }

    
    // Load MetaField
    async loadMetafields(quoteId) {
        try {
            const response = await this.apiService.makeRequest(
                '/api/Metafield/GetMetafieldsForCreateQuote',
                'POST',
                { id: quoteId }
            );

            if (response.success && response.data && response.data.length > 0) {
                this.metafields = response.data;
                this.renderer.renderMetafields(this.metafields);
                console.log('✅ Metafields loaded:', this.metafields);
            } else {
                console.log('ℹ️ No metafields found for this template');
            }
        } catch (error) {
            console.error('❌ Error loading metafields:', error);
        }
    }


    setupReviewButton() {
        const reviewBtn = document.getElementById('btn-save-1');
        if (reviewBtn) {
            reviewBtn.addEventListener('click', (e) => {
                // Open all groups
                this.renderer.openAllGroups();
                // Change button text to "Service"
                reviewBtn.textContent = "Add Services";
            });
        }
    }


    getQuoteId() {
        // Try multiple ways to get QuoteId
        let quoteId = null;

        const input = document.querySelector('input[name="QuoteId"]');
        if (input && input.value) {
            quoteId = parseInt(input.value);
        }

        return quoteId;
    }

    setupEventDelegation() {
        this.eventManager.setupGlobalHandlers(this);
    }

    handleError(context, error) {
        console.error(`❌ ${context}:`, error);
        alert(`Failed to ${context.toLowerCase()}`);
    }
}

// ========================================
// API SERVICE CLASS
// ========================================
class CreateQuoteApiService {
    async fetchDependentQuestions(quoteId, questionOptionId) {
        const url = '/api/Quote/GetDependentQuestionsForCreateQuote';
        return this.makeRequest(url, 'POST', { quoteId, questionOptionId });
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

// ========================================
// RENDERER CLASS
// ========================================
class CreateQuoteRenderer {
    constructor() {
        this.container = document.getElementById('question-render-root');
    }

    renderTemplate(data) {
        if (!this.container) {
            throw new Error('Question container not found');
        }

        this.setTemplateMetadata(data);
        this.renderQuestions(data);

        this.expandAllGroups();
    }

    openGroupAndCloseOthers(headerToToggle) {
        const headers = document.querySelectorAll('.dropdown-header-c.parentToggler');
        const sections = document.querySelectorAll('.section-container-c.shadow-c');

        // Find the index of the clicked header
        let clickedIndex = -1;
        headers.forEach((header, i) => {
            if (header === headerToToggle) clickedIndex = i;
        });
        if (clickedIndex === -1) return;

        const clickedSection = sections[clickedIndex];
        const isCurrentlyOpen = clickedSection && !clickedSection.classList.contains('hidden');

        if (isCurrentlyOpen) {
            // If already open, just close it
            this.toggleGroup(headerToToggle, clickedSection, false);
        } else {
            // If closed, open it and close all others
            headers.forEach((header, i) => {
                const section = sections[i];
                if (!header || !section) return;
                if (i === clickedIndex) {
                    this.toggleGroup(header, section, true);
                } else {
                    this.toggleGroup(header, section, false);
                }
            });
        }
    }

    openAllGroups() {
        // ✅ ONLY select question group headers (NOT metafield)
        const headers = document.querySelectorAll('.dropdown-header-c.parentToggler:not(.metafield-header)');
        const sections = document.querySelectorAll('.section-container-c.shadow-c:not(.metafield-section)');

        headers.forEach((header, i) => {
            const section = sections[i];
            if (header && section) {
                section.classList.remove('hidden');
                section.style.display = '';
                section.style.overflow = '';
                section.style.maxHeight = '';
                const carrotSvg = header.querySelector('.carrot-c svg');
                if (carrotSvg) carrotSvg.classList.add('rotate-180-c');
                header.classList.add('bottom-corners-c');
                header.classList.remove('shadow-c');
                header.classList.add('shadow-toggle-c');
                const breaker = header.querySelector('.section-line-breaker-c');
                if (breaker) breaker.classList.remove('hidden');
                header.style.borderRadius = '0.75rem 0.75rem 0 0';
            }
        });

        // ✅ SEPARATELY open metafield if exists
        const metafieldHeader = document.querySelector('.metafield-header');
        const metafieldSection = document.querySelector('.metafield-section');
        if (metafieldHeader && metafieldSection) {
            this.toggleGroup(metafieldHeader, metafieldSection, true);
        }
    }

    setTemplateMetadata(data) {
        // Set hidden form fields
        if (data.templateId) {
            const templateIdInput = document.querySelector('input[name="TemplateId"]');
            if (templateIdInput) templateIdInput.value = data.templateId;

            const formTemplateIdInput = document.getElementById('form-TemplateId');
            if (formTemplateIdInput) formTemplateIdInput.value = data.templateId;
        }

        if (data.templateVersion) {
            const templateVersionInput = document.querySelector('input[name="TemplateVersion"]');
            if (templateVersionInput) templateVersionInput.value = data.templateVersion;

            const formTemplateVersionInput = document.getElementById('form-TemplateVersion');
            if (formTemplateVersionInput) formTemplateVersionInput.value = data.templateVersion;
        }

        if (data.recStatusId) {
            const recStatusInput = document.querySelector('input[name="RecStatusId"]');
            if (recStatusInput) recStatusInput.value = data.recStatusId;

            const formRecStatusInput = document.getElementById('RecStatusId');
            if (formRecStatusInput) formRecStatusInput.value = data.recStatusId;
        }

        if (data.customerId) {
            const customerIdInput = document.querySelector('input[name="CustomerId"]');
            if (customerIdInput) customerIdInput.value = data.customerId;

            const formCustomerIdInput = document.getElementById('form-CustomerId');
            if (formCustomerIdInput) formCustomerIdInput.value = data.customerId;
        }

        // Build option prices map
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

        //(`📊 Rendering ${questionGroups.length} question groups`);
        questionGroups.forEach((group, index) => {
            const groupElement = this.createGroupElement(group, index);
            this.container.appendChild(groupElement);
        });
    }

    createGroupElement(group, index) {
        const itemDiv = this.createDOMElement('div', { className: 'item-c' });
        //itemDiv.style.marginBottom = '1.5rem';

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
                    data-primaryid="0"
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
                    data-primaryid="0"
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
                                    data-questionid="${question.questionId}"
                                    data-primaryid="0">
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
                                    data-primaryid="0"
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
                    data-primaryid="0"
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
                    data-primaryid="0"
                    value=""
                />
            </div>
        `;

        container.innerHTML += inputHTML;
    }

    expandAllGroups() {
        // ✅ ONLY select question groups (NOT metafield)
        const headers = document.querySelectorAll('.dropdown-header-c.parentToggler:not(.metafield-header)');
        const sections = document.querySelectorAll('.section-container-c.shadow-c:not(.metafield-section)');

        headers.forEach((header, i) => {
            const section = sections[i];
            if (header && section) {
                if (i === 0) {
                    // Open the first question group
                    section.classList.remove('hidden');
                    section.style.display = '';
                    section.style.overflow = '';
                    section.style.maxHeight = '';

                    const carrotSvg = header.querySelector('.carrot-c svg');
                    if (carrotSvg) {
                        carrotSvg.classList.add('rotate-180-c');
                    }

                    header.classList.add('bottom-corners-c');
                    header.classList.remove('shadow-c');
                    header.classList.add('shadow-toggle-c');

                    const breaker = header.querySelector('.section-line-breaker-c');
                    if (breaker) {
                        breaker.classList.remove('hidden');
                    }

                    header.style.borderRadius = '0.75rem 0.75rem 0 0';
                } else {
                    // Close all other question groups
                    section.classList.add('hidden');
                    section.style.display = '';
                    section.style.overflow = '';
                    section.style.maxHeight = '';

                    const carrotSvg = header.querySelector('.carrot-c svg');
                    if (carrotSvg) {
                        carrotSvg.classList.remove('rotate-180-c');
                    }

                    header.classList.remove('bottom-corners-c');
                    header.classList.add('shadow-c');
                    header.classList.remove('shadow-toggle-c');

                    const breaker = header.querySelector('.section-line-breaker-c');
                    if (breaker) {
                        breaker.classList.add('hidden');
                    }

                    header.style.borderRadius = '0.75rem';
                }
            }
        });

        // ✅ Keep metafield CLOSED by default (user will open manually)
        // No code needed - already hidden by default in HTML
    }

    toggleGroup(header, section, forceOpen = null) {
        const isHidden = section.classList.contains('hidden');

        // Determine if should open
        let shouldOpen;
        if (forceOpen !== null) {
            shouldOpen = forceOpen;
        } else {
            shouldOpen = isHidden; // Toggle behavior
        }

        console.log('🔄 toggleGroup called:', {
            isHidden,
            shouldOpen,
            forceOpen,
            sectionClasses: section.className
        }); // ✅ DEBUG LOG

        if (shouldOpen) {
            // OPEN
            if (isHidden) {
                section.style.display = 'block';
                section.style.overflow = 'hidden';
                section.style.maxHeight = '0px';
                section.classList.remove('hidden');
                header.style.borderRadius = '0.75rem 0.75rem 0 0';

                setTimeout(() => {
                    section.style.transition = 'max-height 0.4s ease';
                    section.style.maxHeight = section.scrollHeight + 'px';
                }, 20);

                setTimeout(() => {
                    section.style.transition = '';
                    section.style.maxHeight = '';
                    section.style.overflow = '';
                    section.style.display = '';
                }, 420);
            }

            // Open state styles
            const carrotSvg = header.querySelector('.carrot-c svg');
            if (carrotSvg) carrotSvg.classList.add('rotate-180-c');
            header.classList.add('bottom-corners-c');
            header.classList.remove('shadow-c');
            header.classList.add('shadow-toggle-c');
            const breaker = header.querySelector('.section-line-breaker-c');
            if (breaker) breaker.classList.remove('hidden');

            console.log('✅ Section opened'); // ✅ DEBUG LOG
        } else {
            // CLOSE
            if (!isHidden) {
                section.style.overflow = 'hidden';
                section.style.transition = 'max-height 0.4s ease';
                section.style.maxHeight = section.scrollHeight + 'px';

                setTimeout(() => {
                    section.style.maxHeight = '0px';
                }, 20);

                setTimeout(() => {
                    section.classList.add('hidden');
                    section.style.transition = '';
                    section.style.maxHeight = '';
                    section.style.overflow = '';
                    section.style.display = '';
                    header.style.borderRadius = '0.75rem';
                }, 420);
            }

            // Close state styles
            const carrotSvg = header.querySelector('.carrot-c svg');
            if (carrotSvg) carrotSvg.classList.remove('rotate-180-c');
            header.classList.remove('bottom-corners-c');
            header.classList.add('shadow-c');
            header.classList.remove('shadow-toggle-c');
            const breaker = header.querySelector('.section-line-breaker-c');
            if (breaker) breaker.classList.add('hidden');

            console.log('✅ Section closed'); // ✅ DEBUG LOG
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

    // Render Metafield
    renderMetafields(metafields) {
        const container = document.getElementById('metafields-render-root');
        const metafieldsContainer = document.getElementById('metafields-container');

        if (!container || !metafieldsContainer) {
            console.error('❌ Metafields container not found');
            return;
        }

        if (!metafields || metafields.length === 0) {
            metafieldsContainer.style.display = 'none';
            return;
        }

        // Show the metafields section
        metafieldsContainer.style.display = 'block';

        // Clear existing content
        container.innerHTML = '';

        metafields.forEach(metafield => {
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
            if (metafield.fieldType && ['input', 'text', 'textbox', 'string'].includes(metafield.fieldType.toLowerCase())) {
                const inputHTML = `
        <div class="section-input-wrapper-c less-width-select-c">
            <input type="text"
                class="section-input-c metafield-input"
                name="Metafields[${metafield.pid}].Value"
                id="metafield-${metafield.pid}"
                data-metafield-id="${metafield.pid}"
                data-metafield-name="${this.escapeHtml(metafield.name)}"
                value=""

            />
            <input type="hidden" name="Metafields[${metafield.pid}].PID" value="${metafield.pid}" />
        </div>
    `;
                metafieldDiv.innerHTML += inputHTML;
            } else {
                // Optionally, render a default input if fieldType is missing
                const inputHTML = `
        <div class="section-input-wrapper-c less-width-select-c">
            <input type="text"
                class="section-input-c metafield-input"
                name="Metafields[${metafield.pid}].Value"
                id="metafield-${metafield.pid}"
                data-metafield-id="${metafield.pid}"
                data-metafield-name="${this.escapeHtml(metafield.name)}"
                value=""

            />
            <input type="hidden" name="Metafields[${metafield.pid}].PID" value="${metafield.pid}" />
        </div>
    `;
                metafieldDiv.innerHTML += inputHTML;
            }

            container.appendChild(metafieldDiv);
        });

        console.log(`✅ Rendered ${metafields.length} metafields`);
    }

    //renderMetafields(metafields) {
    //    const container = document.getElementById('metafields-render-root');
    //    const metafieldsContainer = document.getElementById('metafields-container');

    //    if (!container || !metafieldsContainer) {
    //        console.error('❌ Metafields container not found');
    //        return;
    //    }

    //    if (!metafields || metafields.length === 0) {
    //        metafieldsContainer.style.display = 'none';
    //        return;
    //    }

    //    // Show the metafields section
    //    metafieldsContainer.style.display = 'block';

    //    // Clear existing content
    //    container.innerHTML = '';

    //    metafields.forEach(metafield => {
    //        const metafieldDiv = this.createDOMElement('div', {
    //            className: 'question-bottom-margins-c',
    //            attributes: {
    //                'data-metafield-id': metafield.pid
    //            }
    //        });

    //        const headingHTML = `
    //        <h2 class="section-subheading-c no-margin-c">
    //            ${this.escapeHtml(metafield.name)}
    //        </h2>
    //    `;
    //        metafieldDiv.innerHTML = headingHTML;

    //        // Render based on field type
    //        const fieldType = (metafield.fieldType || '').toLowerCase();

    //        if (['input', 'text', 'textbox', 'string', 'single line text'].includes(fieldType)) {
    //            // Single line text input
    //            const inputHTML = `
    //            <div class="section-input-wrapper-c less-width-select-c">
    //                <input type="text"
    //                    class="section-input-c metafield-input"
    //                    name="Metafields[${metafield.pid}].Value"
    //                    id="metafield-${metafield.pid}"
    //                    data-metafield-id="${metafield.pid}"
    //                    data-metafield-name="${this.escapeHtml(metafield.name)}"
    //                    value=""
    //                />
    //                <input type="hidden" name="Metafields[${metafield.pid}].PID" value="${metafield.pid}" />
    //            </div>
    //        `;
    //            metafieldDiv.innerHTML += inputHTML;
    //        } else if (fieldType === 'table') {
    //            // Table-type metafield
    //            const tableHTML = `
    //            <div class="section-container-c line-item-modal-c">
    //                <header class="popup-section-header-c no-top-margin-c custom-bg-c">
    //                    <span class="popup-header-text-c">Type</span>
    //                    <span class="popup-header-text-c line-modal-margin-c">Quantity</span>
    //                    <span class="popup-header-text-c"></span>
    //                </header>
    //                <div class="line-item-modal-c popup-sub-box-c top-corners-c">
    //                    <div class="selects-container-c" id="table-rows-${metafield.pid}">
    //                        <div class="selects-wrapper-c">
    //                            <div class="section-input-wrapper-c less-width-select2-c">
    //                                <select class="section-input-c selectt-c conditional-select"
    //                                    name="Metafields[${metafield.pid}].LineItems[0].OptionId"
    //                                    data-metafield-id="${metafield.pid}">
    //                                    <option value="">Select</option>
    //                                    ${(metafield.options || []).map(opt => `
    //                                        <option value="${opt.optionId}"
    //                                            data-optionid="${opt.optionId}">
    //                                            ${this.escapeHtml(opt.optionText)}
    //                                        </option>
    //                                    `).join('')}
    //                                </select>
    //                            </div>
    //                            <div class="section-input-wrapper-c less-width-select2-c">
    //                                <input type="number"
    //                                    class="section-input-c"
    //                                    name="Metafields[${metafield.pid}].LineItems[0].Quantity"
    //                                    min="0"
    //                                    value="0"
    //                                />
    //                            </div>
    //                            <div class="line-item-cross-container-c">
    //                                <button type="button" class="line-item-cross-btn-c">
    //                                    <img src="/images/close-cancel.svg" alt="Remove">
    //                                </button>
    //                            </div>
    //                        </div>
    //                    </div>
    //                    <div class="save-btn-container-c">
    //                        <button type="button" class="btn-save-c add-line-c" data-metafield="${metafield.pid}">
    //                            Add Line Item
    //                        </button>
    //                    </div>
    //                </div>
    //            </div>
    //        `;
    //            metafieldDiv.innerHTML += tableHTML;
    //        } else {
    //            // Default input fallback
    //            const inputHTML = `
    //            <div class="section-input-wrapper-c less-width-select-c">
    //                <input type="text"
    //                    class="section-input-c metafield-input"
    //                    name="Metafields[${metafield.pid}].Value"
    //                    id="metafield-${metafield.pid}"
    //                    data-metafield-id="${metafield.pid}"
    //                    data-metafield-name="${this.escapeHtml(metafield.name)}"
    //                    value=""
    //                />
    //                <input type="hidden" name="Metafields[${metafield.pid}].PID" value="${metafield.pid}" />
    //            </div>
    //        `;
    //            metafieldDiv.innerHTML += inputHTML;
    //        }

    //        container.appendChild(metafieldDiv);
    //    });

    //    console.log(`✅ Rendered ${metafields.length} metafields`);
    //}

}

// ========================================
// STICKY NOTE MANAGER CLASS - FIXED
// ========================================
class CreateQuoteStickyNoteManager {
    constructor() {
        this.costElement = document.getElementById('sticky-total-cost');
        this.sellElement = document.getElementById('sticky-total-sell');
        this.customerElement = document.querySelector('.customerNamefromDB');
    }

    initialize(data) {
        if (this.customerElement) {
            this.customerElement.textContent = data.customerName || 'N/A';
        }
        this.updateTotals();
    }

    updateTotals() {
        const selectedOptions = this.getSelectedOptionsWithPrices();
        let totalCost = 0;
        let totalSell = 0;

        selectedOptions.forEach(item => {
            totalCost += (item.costPrice || 0) * item.quantity;
            totalSell += (item.sellPrice || 0) * item.quantity;
        });

        if (this.costElement) {
            this.costElement.textContent = `Total Cost: ${this.formatCurrency(totalCost)}`;
        }
        if (this.sellElement) {
            this.sellElement.textContent = `Total Sell: ${this.formatCurrency(totalSell)}`;
        }

        console.log(`💰 Totals Updated: Cost=${totalCost}, Sell=${totalSell}, Items=${selectedOptions.length}`);
    }

    getSelectedOptionsWithPrices() {
        const selected = [];

        // ✅ FIX: Use a composite key (optionId + ParentOptionId) to track uniqueness
        // This allows same option under different parents to be counted separately
        const seenKeys = new Set();

        // Checkboxes
        document.querySelectorAll('input[type=checkbox].single-select-c:checked').forEach(checkbox => {
            const optionId = parseInt(checkbox.value);
            const ParentOptionId = checkbox.getAttribute('data-parent-option-id') ||
                checkbox.dataset.ParentOptionId ||
                checkbox.dataset.ParentOptionId ||
                'root';

            // ✅ Create unique key combining optionId and ParentOptionId
            const uniqueKey = `${optionId}-${ParentOptionId}`;

            if (!seenKeys.has(uniqueKey)) {
                const prices = this.getPricesForOption(optionId);
                selected.push({
                    optionId,
                    ParentOptionId,
                    quantity: 1,
                    ...prices
                });
                seenKeys.add(uniqueKey);
                console.log(`✅ Checkbox added: optionId=${optionId}, ParentOptionId=${ParentOptionId}`);
            }
        });

        // Radios
        document.querySelectorAll('input[type=radio]:checked').forEach(radio => {
            const optionId = parseInt(radio.value);
            const ParentOptionId = radio.getAttribute('data-parent-option-id') ||
                radio.dataset.ParentOptionId ||
                radio.dataset.ParentOptionId ||
                'root';

            const uniqueKey = `${optionId}-${ParentOptionId}`;

            if (!seenKeys.has(uniqueKey)) {
                const prices = this.getPricesForOption(optionId);
                selected.push({
                    optionId,
                    ParentOptionId,
                    quantity: 1,
                    ...prices
                });
                seenKeys.add(uniqueKey);
                console.log(`✅ Radio added: optionId=${optionId}, ParentOptionId=${ParentOptionId}`);
            }
        });

        // Select lists
        document.querySelectorAll('select.section-input-c.selectt-c, select.conditional-select').forEach(sel => {
            if (sel.value && !isNaN(sel.value)) {
                const optionId = parseInt(sel.value);
                const ParentOptionId = sel.getAttribute('data-parent-option-id') ||
                    sel.dataset.ParentOptionId ||
                    sel.dataset.ParentOptionId ||
                    sel.closest('[data-parent-option-id]')?.getAttribute('data-parent-option-id') ||
                    'root';

                const wrapper = sel.closest('.selects-wrapper-c');
                let quantity = 1;

                if (wrapper) {
                    const quantityInput = wrapper.querySelector('input[type=number]');
                    if (quantityInput && !isNaN(quantityInput.value) && parseInt(quantityInput.value) > 0) {
                        quantity = parseInt(quantityInput.value);
                    }
                }

                // ✅ For tables, also include the row index to allow multiple rows with same option
                const rowIndex = wrapper ?
                    Array.from(wrapper.parentElement.children).indexOf(wrapper) : 0;
                const uniqueKey = `${optionId}-${ParentOptionId}-${rowIndex}`;

                if (!seenKeys.has(uniqueKey) && quantity > 0) {
                    const prices = this.getPricesForOption(optionId);
                    selected.push({
                        optionId,
                        ParentOptionId,
                        quantity,
                        ...prices
                    });
                    seenKeys.add(uniqueKey);
                    console.log(`✅ Select added: optionId=${optionId}, ParentOptionId=${ParentOptionId}, qty=${quantity}`);
                }
            }
        });

        console.log('📊 Total selected items:', selected.length, selected);
        return selected;
    }

    getPricesForOption(optionId) {
        if (window.optionPricesMap && window.optionPricesMap[optionId]) {
            return {
                costPrice: window.optionPricesMap[optionId].costPrice || 0,
                sellPrice: window.optionPricesMap[optionId].sellPrice || 0
            };
        }
        return { costPrice: 0, sellPrice: 0 };
    }

    formatCurrency(amount) {
        const currency = localStorage.getItem('currency') || 'GBP';
        const locale = localStorage.getItem('currencyIdentity') || 'en-GB';
        return new Intl.NumberFormat(locale, {
            style: 'currency',
            currency: currency
        }).format(amount);
    }
}

// EVENT MANAGER CLASS
class CreateQuoteEventManager {
    setupGlobalHandlers(manager) {
        this.manager = manager;
        this.setupGroupToggleHandlers();
        this.setupConditionalQuestionHandlers();
        this.setupTableHandlers();
        this.setupSingleCheckboxEnforcement();
        this.setupPriceUpdateHandlers();
    }

    setupGroupToggleHandlers() {
        // ✅ Listen on parent container
        document.addEventListener('click', (e) => {
            const header = e.target.closest('.dropdown-header-c.parentToggler');
            if (!header) return;

            e.preventDefault();
            e.stopPropagation();

            console.log('🖱️ Header clicked:', header.classList); // ✅ DEBUG LOG

            // ✅ CHECK: Is it metafield header?
            if (header.classList.contains('metafield-header')) {
                console.log('📋 Metafield header detected'); // ✅ DEBUG LOG

                // Find the section using nextElementSibling
                const headerWrapper = header.closest('.section-container-c');
                const metafieldSection = headerWrapper?.nextElementSibling;

                console.log('📦 Metafield section found:', metafieldSection); // ✅ DEBUG LOG

                if (metafieldSection && metafieldSection.classList.contains('metafield-section')) {
                    console.log('🔄 Toggling metafield section'); // ✅ DEBUG LOG
                    this.manager.renderer.toggleGroup(header, metafieldSection);
                } else {
                    console.error('❌ Metafield section not found!');
                }
                return; // EXIT - don't process as question group
            }

            // ✅ REGULAR QUESTION GROUPS (old flow)
            console.log('📝 Question group header detected'); // ✅ DEBUG LOG
            const sectionContainer = header.closest('.section-container-c');
            const dropDown = sectionContainer?.nextElementSibling;

            if (dropDown?.classList.contains('section-container-c')) {
                this.manager.renderer.openGroupAndCloseOthers(header);
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

        document.addEventListener('input', (e) => {
            if (e.target.matches('input[type=number]')) {
                this.manager.stickyNoteManager.updateTotals();
            }
        });

        //('✅ Table handlers setup');
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

        const newIndex = currentRows;
        const newRow = document.createElement('div');
        newRow.className = 'selects-wrapper-c';

        newRow.innerHTML = `
            <div class="section-input-wrapper-c less-width-select2-c">
                <select class="section-input-c selectt-c conditional-select"
                        name="Answers[${questionId}].LineItems[${newIndex}].OptionId"
                        data-toggle="conditional"
                        data-questionid="${questionId}"
                        data-primaryid="0">
                    ${firstSelect.innerHTML}
                </select>
            </div>
            <div class="section-input-wrapper-c less-width-select2-c">
                <input type="number"
                       class="section-input-c"
                       name="Answers[${questionId}].LineItems[${newIndex}].Quantity"
                       data-questionid="${questionId}"
                       data-primaryid="0"
                       min="0" value="0" />
            </div>
            <div class="line-item-cross-container-c">
                <button type="button" class="line-item-cross-btn-c">
                    <img src="/images/close-cancel.svg" alt="Remove">
                </button>
            </div>
        `;

        container.appendChild(newRow);
        this.manager.stickyNoteManager.updateTotals();
        //(`➕ Added line item for question ${questionId}`);
    }

    handleRemoveLineItem(removeButton) {
        const row = removeButton.closest('.selects-wrapper-c');
        const container = row?.closest('.selects-container-c');
        const wrappers = container ? container.querySelectorAll('.selects-wrapper-c') : [];

        if (container && wrappers.length > 1) {
            const select = row.querySelector('select');
            const input = row.querySelector('input[type="number"]');
            const selectedOption = select?.selectedOptions[0];
            if (selectedOption && selectedOption.value) {
                const quoteIdInput = document.querySelector('input[name="QuoteId"]');
                const quoteId = quoteIdInput ? quoteIdInput.value : null;
                const primaryId = Math.max(
                    Number(select.dataset.primaryid || 0),
                    Number(input.dataset.primaryid || 0)
                );

                const data = {
                    quoteId,
                    primaryId,
                    questionId: selectedOption.dataset.questionid || select.dataset.questionid,
                    optionId: selectedOption.dataset.optionid,
                    sellPrice: selectedOption.dataset.sellprice || null,
                    costPrice: selectedOption.dataset.costprice || null,
                    value: input.value,
                    action: "delete",
                    fieldType: "table",
                    quoteVersionId: 1
                };

                this.manager.autoSaveManager.updateAnswerInDb("delete", data, null);
            }

            row.remove();
            this.manager.stickyNoteManager.updateTotals();
            //('➖ Removed line item');
        } else if (container && wrappers.length === 1) {
            const select = row.querySelector('select');
            const input = row.querySelector('input[type="number"]');
            const selectedOption = select?.selectedOptions[0];

            if (selectedOption && selectedOption.value) {
                const quoteIdInput = document.querySelector('input[name="QuoteId"]');
                const quoteId = quoteIdInput ? quoteIdInput.value : null;
                const primaryId = Math.max(
                    Number(select.dataset.primaryid || 0),
                    Number(input.dataset.primaryid || 0)
                );

                const data = {
                    quoteId,
                    primaryId,
                    questionId: selectedOption.dataset.questionid || select.dataset.questionid,
                    optionId: selectedOption.dataset.optionid,
                    sellPrice: selectedOption.dataset.sellprice || null,
                    costPrice: selectedOption.dataset.costprice || null,
                    value: input.value,
                    action: "delete",
                    fieldType: "table",
                    quoteVersionId: 1
                };

                this.manager.autoSaveManager.updateAnswerInDb("delete", data, null);
            }

            if (select) select.selectedIndex = 0;
            if (input) input.value = 0;
            this.manager.stickyNoteManager.updateTotals();
            //('🔄 Reset last line item');
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

            const dependentContainer = questionDiv.querySelector('.dependent-section-c');
            if (dependentContainer) {
                dependentContainer.classList.add('hidden');
                dependentContainer.innerHTML = '';
            }

            if (input.checked || (input.tagName === 'SELECT' && input.value)) {
                const optionId = parseInt(input.value);
                const quoteId = this.manager.getQuoteId();

                try {
                    const result = await this.manager.apiService.fetchDependentQuestions(quoteId, optionId);
                    if (result.success && result.data) {
                        this.renderDependentQuestions(optionId, result.data, questionId, questionDiv);
                    }
                } catch (error) {
                    console.error('❌ Error fetching dependent questions:', error);
                }
            }

            this.manager.stickyNoteManager.updateTotals();
        });

        //('✅ Conditional question handlers setup');
    }

    // In CreateQuoteEventManager class - modify renderDependentQuestions method:

    renderDependentQuestions(optionId, dependentData, parentQuestionId, parentQuestionDiv) {
        const dependentSection = parentQuestionDiv.querySelector('.dependent-section-c');
        if (!dependentSection) return;

        dependentSection.classList.remove('hidden');
        dependentSection.innerHTML = '';

        if (dependentData.questionGroups && dependentData.questionGroups.length > 0) {
            dependentData.questionGroups.forEach(group => {
                group.questions.forEach(question => {
                    const questionElement = this.manager.renderer.renderQuestion(question);

                    // ✅ NEW: Add ParentOptionId to all inputs in this dependent question
                    questionElement.querySelectorAll('input, select').forEach(input => {
                        input.setAttribute('data-parent-option-id', optionId);
                    });

                    dependentSection.appendChild(questionElement);
                });
            });

            // Update price map
            if (dependentData.questionGroups) {
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
            }
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
    }

    setupPriceUpdateHandlers() {
        document.addEventListener('change', function (e) {
            if (e.target.matches('input[type=radio], select.section-input-c, select.conditional-select')) {
                if (window.createQuoteManager && window.createQuoteManager.stickyNoteManager) {
                    window.createQuoteManager.stickyNoteManager.updateTotals();
                }
            }
        });
    }
}
// ========================================
// AUTOSAVE MANAGER CLASS
// ========================================
class CreateQuoteAutoSaveManager {
    setup() {
        this.setupFieldChangeListener();
    }


    _debounce(fn, delay) {
        let timer;
        return function (...args) {
            clearTimeout(timer);
            timer = setTimeout(() => fn.apply(this, args), delay);
        };
    }

    async checkRequiredAnswersAndToggleButton() {
        const quoteIdInput = document.querySelector('input[name="QuoteId"]');
        if (!quoteIdInput) return;
        const quoteId = quoteIdInput.value;
        const btn = document.getElementById('btn-save-1');
        if (!btn) return;

        try {
            const res = await fetch(`/api/QuoteAnswer/IsAllRequiredAnswered?quoteId=${quoteId}`);
            const data = await res.json();

            if (!data.hasRequired) {
                btn.disabled = false;
                btn.style.opacity = "1";
                btn.style.pointerEvents = "auto";
                btn.style.cursor = "";
            } else if (data.allAnswered) {
                btn.disabled = false;
                btn.style.opacity = "1";
                btn.style.pointerEvents = "auto";
                btn.style.cursor = "";
            } else {
                btn.disabled = true;
                btn.style.opacity = "0.5";
                btn.style.pointerEvents = "none";
                btn.style.cursor = "not-allowed";
            }
        } catch (err) {
            btn.disabled = false;
            btn.style.opacity = "1";
            btn.style.pointerEvents = "auto";
            btn.style.cursor = "";
            console.error('Error checking required answers', err);
        }
    }

    // In CreateQuoteAutoSaveManager class - update getFieldData:

    setupFieldChangeListener() {

        const getFieldData = (el) => {
            const quoteIdInput = document.querySelector('input[name="QuoteId"]');
            if (!quoteIdInput) return null;

            const quoteId = quoteIdInput.value;
            const primaryId = el.dataset.primaryid || 0;
            const quoteVersionId = 1;

            // ✅ FIX: Get ParentOptionId correctly - HTML converts to lowercase
            // el.dataset.ParentOptionId becomes el.dataset.ParentOptionId in some browsers
            const ParentOptionId = el.getAttribute('data-parent-option-id') ||
                el.dataset.ParentOptionId ||
                el.dataset.ParentOptionId ||
                null;

            console.log('🔍 Parent Option ID extracted:', ParentOptionId, 'from element:', el); // DEBUG

            const row = el.closest(".selects-wrapper-c");
            if (row) {
                const selectEl = row.querySelector("select");
                const inputEl = row.querySelector("input[type='number']");
                if (!selectEl || !inputEl) return null;

                const selectedOption = selectEl.selectedOptions[0];
                if (!selectedOption) return null;

                const rowPrimaryId = Math.max(
                    Number(selectEl.dataset.primaryid || 0),
                    Number(inputEl.dataset.primaryid || 0)
                );

                // ✅ FIX: Also check parent option from select element
                const rowParentOptionId = selectEl.getAttribute('data-parent-option-id') ||
                    selectEl.dataset.ParentOptionId ||
                    selectEl.dataset.ParentOptionId ||
                    row.closest('[data-parent-option-id]')?.getAttribute('data-parent-option-id') ||
                    null;

                return {
                    quoteId,
                    primaryId: rowPrimaryId,
                    questionId: selectedOption.dataset.questionid || selectEl.dataset.questionid,
                    optionId: selectedOption.dataset.optionid,
                    sellPrice: selectedOption.dataset.sellprice || null,
                    costPrice: selectedOption.dataset.costprice || null,
                    value: inputEl.value,
                    action: "add",
                    fieldType: "table",
                    quoteVersionId: quoteVersionId,
                    ParentOptionId: rowParentOptionId ? parseInt(rowParentOptionId) : null
                };
            }

            if (el.type === "checkbox" || el.type === "radio") {
                return {
                    quoteId,
                    primaryId,
                    questionId: el.dataset.questionid,
                    optionId: el.dataset.optionid || null,
                    sellPrice: el.dataset.sellprice || null,
                    costPrice: el.dataset.costprice || null,
                    value: el.checked ? "checked" : "unchecked",
                    action: el.checked ? "add" : "delete",
                    fieldType: el.type,
                    quoteVersionId: quoteVersionId,
                    ParentOptionId: ParentOptionId ? parseInt(ParentOptionId) : null
                };
            }

            if (el.dataset?.questionid && el.tagName !== "SELECT") {
                return {
                    quoteId,
                    primaryId,
                    questionId: el.dataset.questionid,
                    optionId: el.dataset.optionid || 0,
                    sellPrice: el.dataset.sellprice || null,
                    costPrice: el.dataset.costprice || null,
                    value: el.value,
                    action: "add",
                    fieldType: "input",
                    quoteVersionId: quoteVersionId,
                    ParentOptionId: ParentOptionId ? parseInt(ParentOptionId) : null
                };
            }

            if (el.tagName === "SELECT") {
                const selectedOption = el.selectedOptions[0];
                if (!selectedOption) return null;

                // ✅ FIX: Get parent option from select or parent container
                const selectParentOptionId = el.getAttribute('data-parent-option-id') ||
                    el.dataset.ParentOptionId ||
                    el.dataset.ParentOptionId ||
                    el.closest('[data-parent-option-id]')?.getAttribute('data-parent-option-id') ||
                    null;

                return {
                    quoteId,
                    primaryId: el.dataset.primaryid || 0,
                    questionId: selectedOption.dataset.questionid || el.dataset.questionid,
                    optionId: selectedOption.dataset.optionid,
                    sellPrice: selectedOption.dataset.sellprice || null,
                    costPrice: selectedOption.dataset.costprice || null,
                    value: selectedOption.value,
                    action: "add",
                    fieldType: "select",
                    quoteVersionId: quoteVersionId,
                    ParentOptionId: selectParentOptionId ? parseInt(selectParentOptionId) : null
                };
            }

            return null;
        };


        const handleRowDelete = (e) => {
            const el = e.target.closest(".line-item-cross-btn-c");
            if (!el) return;

            const row = el.closest(".selects-wrapper-c");
            if (!row) return;

            const selectEl = row.querySelector("select");
            const inputEl = row.querySelector("input[type='number']");
            if (!selectEl || !inputEl) return;

            const selectedOption = selectEl.selectedOptions[0];
            if (!selectedOption || !selectedOption.value) return;

            const quoteIdInput = document.querySelector('input[name="QuoteId"]');
            if (!quoteIdInput) return;

            const quoteId = quoteIdInput.value;

            const primaryId = Math.max(
                Number(selectEl.dataset.primaryid || 0),
                Number(inputEl.dataset.primaryid || 0)
            );

            const data = {
                quoteId,
                primaryId,
                questionId: selectedOption.dataset.questionid || selectEl.dataset.questionid,
                optionId: selectedOption.dataset.optionid,
                sellPrice: selectedOption.dataset.sellprice || null,
                costPrice: selectedOption.dataset.costprice || null,
                value: inputEl.value,
                action: "delete",
                fieldType: "table",
                quoteVersionId: 1
            };

            //("Delete Row:", data);
            this.updateAnswerInDb("delete", data, null);
        };

        document.addEventListener("change", (e) => {
            const el = e.target;

            if (!el.dataset.questionid &&
                !el.closest('.selects-wrapper-c') &&
                el.type !== 'checkbox' &&
                el.type !== 'radio' &&
                el.tagName !== 'SELECT') {
                return;
            }

            if (el.type === "checkbox" || el.type === "radio") {
                const data = getFieldData(el);
                if (!data || !data.questionId) return;
                //("Checkbox/Radio change:", data);
                this.updateAnswerInDb(data.action, data, el);
                return;
            }

            const data = getFieldData(el);
            if (!data || !data.questionId) return;

            if (data.fieldType === "table") {
                if (!this._debouncedTableSave) {
                    this._debouncedTableSave = this._debounce(this.updateAnswerInDb.bind(this), 250);
                }
                this._debouncedTableSave(data.action, data, el);
            } else {
                this.updateAnswerInDb(data.action, data, el);
            }
        });

        document.addEventListener("click", handleRowDelete.bind(this));

        let metafieldSaveTimer = null;

        document.addEventListener('input', function (e) {
            if (e.target.classList.contains('metafield-input')) {
                clearTimeout(metafieldSaveTimer);
                metafieldSaveTimer = setTimeout(async () => {
                    const input = e.target;
                    const quoteId = document.querySelector('input[name="QuoteId"]')?.value;
                    const templateVersionId = document.querySelector('input[name="TemplateVersion"]')?.value;
                    const metafieldId = input.dataset.metafieldId;
                    const value = input.value;

                    if (!quoteId || !templateVersionId || !metafieldId) return;

                    const payload = {
                        quoteId: parseInt(quoteId),
                        templateVersionId: parseInt(templateVersionId),
                        metafieldId: parseInt(metafieldId),
                        metafieldInput: value
                    };

                    console.log('📤 Metafield autosave payload:', payload);
                    try {
                        const response = await fetch('/api/Metafield/SaveMetafieldAnswer', {
                            method: 'POST',
                            headers: { 'Content-Type': 'application/json' },
                            body: JSON.stringify(payload)
                        });
                        const result = await response.json();
                        console.log('✅ Metafield API response:', result);
                    } catch (err) {
                        console.error('❌ Metafield autosave error:', err);
                    }
                }, 400); 
            }
        });
    }

    // In CreateQuoteAutoSaveManager class:
    // In CreateQuoteAutoSaveManager class - Fix updateAnswerInDb method:

    updateAnswerInDb(action, data, el) {
        const quoteIdInput = document.querySelector('input[name="QuoteId"]');
        if (!quoteIdInput) {
            console.error("QuoteId input not found");
            return;
        }

        const quoteId = quoteIdInput.value;
        const payload = {
            ...data,
            quoteId: parseInt(quoteId),
            quoteVersionId: 1,
            ParentOptionId: data.ParentOptionId ? parseInt(data.ParentOptionId) : null
        };

        const url = action === "delete"
            ? "/api/QuoteAnswer/RemoveQuoteAnswer"
            : "/api/QuoteAnswer/AddQuoteAnswer";

        console.log("📤 Sending to API:", url, payload);

        fetch(url, {
            method: "POST",
            headers: { "Content-Type": "application/json" },
            body: JSON.stringify(payload),
        })
            .then((res) => {
                if (!res.ok) throw new Error("Server error");
                return res.json();
            })
            .then((result) => {
                if (result.success) {
                    console.log("✅ Saved:", result.message);
                    // ✅ FIX: Removed the typo "setupFieldChangeListener" that was here
                    if (result.primaryId !== undefined && result.primaryId !== null && el) {
                        el.setAttribute("data-primaryid", result.primaryId);
                    }
                } else {
                    console.error("❌ Failed:", result.message);
                }
                window.createQuoteManager.autoSaveManager.checkRequiredAnswersAndToggleButton();
            })
            .catch((err) => console.error("Error:", err));
    }

}

// CURRENCY INITIALIZATION
document.addEventListener('DOMContentLoaded', function () {
    const currencyInput = document.getElementById('currencyInput');
    if (currencyInput) {
        currencyInput.value = localStorage.getItem('currencyIdentity') || 'en-GB';
    }
});
// APPLICATION BOOTSTRAP
document.addEventListener('DOMContentLoaded', () => {
    window.createQuoteManager = new CreateQuoteManager();
    window.createQuoteManager.autoSaveManager.checkRequiredAnswersAndToggleButton();
});