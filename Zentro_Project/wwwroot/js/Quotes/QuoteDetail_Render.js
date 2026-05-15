// MAIN CLASS: QuotePreviewManager
class QuotePreviewManager {
    constructor() {
        this.quoteData = null;
        this.apiService = new QuoteApiService();
        this.renderer = new QuoteRenderer();
        this.eventManager = new QuoteEventManager();
        this.stickyNoteManager = new StickyNoteManager();
        this.autoSaveManager = new AutoSaveManager();
        this.metafields = [];
        this.init();
    }

    async init() {
        try {
            await this.getQuoteIdFromUrl();
            await this.getQuote();   // Must complete first
           
       
            this.setupEventDelegation();
            await this.loadQuoteData();
            this.autoSaveManager.setup(); // Setup auto-save
            this.autoSaveManager.checkRequiredAnswersAndToggleButton();
            //('✅ QuotePreviewManager initialized');
        } catch (error) {
            this.handleError('Initialization failed', error);
        }
    }
    async getQuote() {
        const quoteInput = document.getElementById("quoteId");
        if (!quoteInput) {
            console.error("❌ #quoteId input not found in HTML");
            throw new Error("quoteId input missing");
        }

        const quoteId = quoteInput.value;
        if (!quoteId) {
            console.error("❌ quoteId has no value");
            throw new Error("Quote ID missing");
        }

        console.log("Quote ID:", quoteId);

        // Call your controller endpoint which calls the service internally
        const response = await fetch(`/api/TemplateItems/${quoteId}`);  // <-- uses your GetQuoteDetails API

        if (!response.ok) {
            alert("Quote not found");
            throw new Error("Quote not found");
        }

        const data = await response.json();

        // Fill hidden inputs
        document.querySelector("input[name='QuoteId']").value = quoteId;
        // Get the hidden input by name
        const recStatusInput = document.getElementById("RecStatusId");

        // Assign a value
        recStatusInput.value = quoteId;
            console.log("recStatus: ",recStatusInput.value);  // use real RecStatusId from API
        document.getElementById("form-CustomerId").value = data.customerId;
        document.getElementById("form-TemplateId").value = data.templateId;
        document.getElementById("form-TemplateVersion").value = data.templateVersionId;

        // Fill labels for UI
        document.querySelector(".customerNamefromDB").innerText =
            data.customerName ?? "--";

        document.querySelector(".main-heading-c").innerText =
            data.templateName ?? "";

        return data; // return for init() if needed
    }

    async getQuoteIdFromUrl() {
        const match = window.location.pathname.match(/\/quote\/(\d+)/);
        const quoteId = match ? match[1] : null;

        if (!quoteId) {
            console.error("❌ Quote ID not found in URL");
            throw new Error("Quote ID missing");
        }

        console.log("Quote ID from URL:", quoteId);

        // Assign ID to your hidden inputs
        const quoteIdInput = document.getElementById("quoteId");
        if (quoteIdInput) quoteIdInput.value = quoteId;

        const quoteIdNameInput = document.querySelector("input[name='QuoteId']");
        if (quoteIdNameInput) quoteIdNameInput.value = quoteId;
    }



    async loadQuoteData() {
        const quoteId = this.getQuoteId();
        if (!quoteId) {
            throw new Error('QuoteId not found');
        }

        const fullResponse = await this.apiService.makeRequest(
            '/api/Quote/GetQuoteDetails',
            'POST',
            { id: quoteId }
        );


        // ✅ DEBUG: Check what lineItems are coming from API
        console.log('📊 API Response:', fullResponse);


        if (!fullResponse.success || !fullResponse.details) {
            throw new Error(fullResponse.message || 'Failed to load quote data');
        }

        this.quoteData = fullResponse.details;

        if (fullResponse.currency) {
            localStorage.setItem('currency', fullResponse.currency);
        }
        if (fullResponse.currencyIdentity) {
            localStorage.setItem('currencyIdentity', fullResponse.currencyIdentity);
        }

        this.quoteData.customerName = fullResponse.customerName;
        this.quoteData.templateName = fullResponse.templateName; 

        //('📊 Quote Data Loaded:', this.quoteData);
        await this.renderer.renderQuote(this.quoteData);
        this.stickyNoteManager.initialize(this.quoteData);
        const headingEl = document.querySelector('.main-heading-c');
        if (headingEl && this.quoteData.templateName) {
            headingEl.textContent = this.quoteData.templateName;
        }

        await this.loadMetafields(quoteId);
    }

    // loadMetafields
    async loadMetafields(quoteId) {
        try {
            const response = await this.apiService.makeRequest(
                '/api/Metafield/GetMetafieldsForQuoteDetail',
                'POST',
                { id: quoteId }
            );

            if (response.success && response.data && response.data.length > 0) {
                this.metafields = response.data;
                this.renderer.renderMetafields(this.metafields);
                console.log('✅ Metafields loaded:', this.metafields);
            } else {
                console.log('ℹ️ No metafields found for this quote');
            }
        } catch (error) {
            console.error('❌ Error loading metafields:', error);
        }
    }

    getQuoteId() {
        const input = document.querySelector('input[name="QuoteId"]');
        return input ? parseInt(input.value) : null;
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
class QuoteApiService {
    async fetchDependentQuestions(quoteId, questionOptionId) {
        const url = '/api/Quote/GetDependentQuestionsForQuote';
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

// RENDERER CLASS
class QuoteRenderer {
    constructor() {
        this.container = document.getElementById('question-render-root');
    }

    async renderQuote(data) {
        if (!this.container) {
            throw new Error('Question container not found');
        }

        this.setQuoteMetadata(data);
        this.renderQuestions(data);
        //this.initializeDependentSectionsOnLoad();
        await this.initializeDependentSectionsOnLoad();
        this.expandAllGroups();
    }

    async loadNestedDependents(container) {
        const inputs = container.querySelectorAll('[data-toggle=conditional]');

        for (const input of inputs) {
            if (
                (input.type === 'checkbox' && input.checked) ||
                (input.type === 'radio' && input.checked) ||
                (input.tagName === 'SELECT' && input.value)
            ) {
                const questionDiv = input.closest('.question-bottom-margins-c');
                const questionIdInput = questionDiv?.querySelector('input[type=hidden][name$=".QuestionId"]');
                const questionId = questionIdInput?.value;

                if (!questionId) continue;

                const dependentContainer = questionDiv.querySelector('.dependent-section-c');
                if (dependentContainer) {
                    const optionId = parseInt(input.value);
                    const quoteId = window.quotePreviewManager.getQuoteId();

                    try {
                        const result = await window.quotePreviewManager.apiService.fetchDependentQuestions(quoteId, optionId);
                        if (result.success && result.data) {
                            window.quotePreviewManager.eventManager.renderDependentQuestions(
                                optionId,
                                result.data,
                                questionId,
                                questionDiv
                            );

                            // ✅ Recursively load nested dependents
                            await this.loadNestedDependents(dependentContainer);
                        }
                    } catch (error) {
                        console.error('❌ Error loading nested dependent:', error);
                    }
                }
            }
        }
    }

    setQuoteMetadata(data) {
        if (data.templateId) {
            document.querySelector('input[name="TemplateId"]').value = data.templateId;
        }
        if (data.templateVersion) {
            document.querySelector('input[name="TemplateVersion"]').value = data.templateVersion;
        }
        if (data.recStatusId) {
            document.querySelector('input[name="RecStatusId"]').value = data.recStatusId;
        }
        if (data.quoteVersionId) {
            const versionInput = document.getElementById('QuoteVersionId');
            if (versionInput) {
                versionInput.value = data.quoteVersionId;
            }
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

    // In QuoteRenderer class - REPLACE initializeDependentSectionsOnLoad method:

    async initializeDependentSectionsOnLoad() {
        await new Promise(resolve => setTimeout(resolve, 100));

        const inputs = document.querySelectorAll('[data-toggle=conditional]');
        console.log(`🔍 Found ${inputs.length} conditional inputs to check`);

        // ✅ FIX: Track which parent options we've already processed
        const processedOptions = new Set();

        for (const input of inputs) {
            const isSelected = (input.type === 'checkbox' && input.checked) ||
                (input.type === 'radio' && input.checked) ||
                (input.tagName === 'SELECT' && input.value);

            if (!isSelected) continue;

            const questionDiv = input.closest('.question-bottom-margins-c');
            const questionIdInput = questionDiv?.querySelector('input[type=hidden][name$=".QuestionId"]');
            const questionId = questionIdInput?.value;

            if (!questionId) continue;

            const optionId = parseInt(input.value);

            // ✅ FIX: Get the parent option ID to create unique key
            const parentOptionId = input.getAttribute('data-parent-option-id') || 'root';
            const uniqueKey = `${questionId}-${optionId}-${parentOptionId}`;

            // ✅ Skip if we've already processed this combination
            if (processedOptions.has(uniqueKey)) {
                console.log(`⏭️ Skipping already processed: Q${questionId}, Option${optionId}, Parent${parentOptionId}`);
                continue;
            }
            processedOptions.add(uniqueKey);

            const dependentContainer = questionDiv.querySelector('.dependent-section-c');
            if (!dependentContainer) continue;

            const quoteId = window.quotePreviewManager.getQuoteId();

            console.log(`📥 Loading dependents for Q${questionId}, Option${optionId}, Parent${parentOptionId}`);

            try {
                const result = await window.quotePreviewManager.apiService.fetchDependentQuestions(quoteId, optionId);

                if (result.success && result.data) {
                    await window.quotePreviewManager.eventManager.renderDependentQuestions(
                        optionId,
                        result.data,
                        questionId,
                        questionDiv
                    );
                    console.log(`✅ Loaded dependents for Q${questionId}`);
                }
            } catch (error) {
                console.error(`❌ Error loading dependents for Q${questionId}:`, error);
            }
        }

        await new Promise(resolve => setTimeout(resolve, 200));
        window.quotePreviewManager.stickyNoteManager.updateTotals();
        console.log('✅ All dependent sections initialized');
    }
    renderQuestions(data) {
        this.container.innerHTML = '';
        const questionGroups = data.questionGroups || [];

        if (!questionGroups.length) {
            this.container.innerHTML = '<p class="text-center">No question groups found.</p>';
            return;
        }

        (`📊 Rendering ${questionGroups.length} question groups`);
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
    const selectedId = question.selectedOptionId || null; 
    const primaryId = question.primaryId || 0; 

        sortedOptions.forEach((opt, index) => {
            const isChecked = selectedId === opt.qOptionId;
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
                    data-primaryid="${isChecked ? primaryId : 0}"
                    data-toggle="conditional"
                    ${isChecked ? 'checked' : ''}
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
        const selectedId = question.selectedOptionId || null; // ✅ Uses answer
        const primaryId = question.primaryId || 0;

        sortedOptions.forEach((opt, index) => {
            const isChecked = selectedId === opt.qOptionId;
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
                    data-primaryid="${isChecked ? primaryId : 0}"
                    data-toggle="conditional"
                    ${isChecked ? 'checked' : ''}
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
        const lineItems = question.lineItems && question.lineItems.length > 0
            ? question.lineItems
            : [{ optionId: null, quantity: 0, primaryId: 0 }];

        let tableHTML = `
            <div class="section-container-c line-item-modal-c">
                <header class="popup-section-header-c no-top-margin-c custom-bg-c">
                    <span class="popup-header-text-c">Type</span>
                    <span class="popup-header-text-c line-modal-margin-c">Quantity</span>
                    <span class="popup-header-text-c"></span>
                </header>
                <div class="line-item-modal-c popup-sub-box-c top-corners-c">
                    <div class="selects-container-c" id="table-rows-${question.questionId}">
        `;

        lineItems.forEach((item, itemIndex) => {
            const itemPrimaryId = item.primaryId || 0;
            tableHTML += `
                <div class="selects-wrapper-c">
                    <div class="section-input-wrapper-c less-width-select2-c">
                        <select class="section-input-c selectt-c conditional-select"
                            name="Answers[${question.questionId}].LineItems[${itemIndex}].OptionId"
                            data-toggle="conditional"
                            data-questionid="${question.questionId}"
                            data-primaryid="${itemPrimaryId}">
                            <option value="">Select</option>
                            ${sortedOptions.map(opt => `
                                <option value="${opt.qOptionId}"
                                    data-questionid="${question.questionId}"
                                    data-optionid="${opt.qOptionId}"
                                    data-sellprice="${opt.sellPrice || 0}"
                                    data-costprice="${opt.costPrice || 0}"
                                    ${item.optionId === opt.qOptionId ? 'selected' : ''}>
                                    ${this.escapeHtml(opt.optionText)}
                                </option>
                            `).join('')}
                        </select>
                    </div>
                    <div class="section-input-wrapper-c less-width-select2-c">
                        <input type="number"
                            class="section-input-c"
                            name="Answers[${question.questionId}].LineItems[${itemIndex}].Quantity"
                            data-questionid="${question.questionId}"
                            data-primaryid="${itemPrimaryId}"
                            min="0"
                            value="${item.quantity || 0}"
                        />
                    </div>
                    <div class="line-item-cross-container-c">
                        <button type="button" class="line-item-cross-btn-c">
                            <img src="/images/close-cancel.svg" alt="Remove">
                        </button>
                    </div>
                </div>
            `;
        });

        tableHTML += `
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
        const selectedId = question.selectedOptionId || null;
        const primaryId = question.primaryId || 0;

        const selectHTML = `
            <div class="section-input-wrapper-c less-width-select-c">
                <select class="section-input-c selectt-c conditional-select"
                    name="Answers[${question.questionId}].SelectedOptionId"
                    id="q-${question.questionId}"
                    data-questionid="${question.questionId}"
                    data-primaryid="${primaryId}"
                    data-toggle="conditional">
                    <option value="">Select</option>
                    ${sortedOptions.map(opt => `
                        <option value="${opt.qOptionId}"
                            data-questionid="${question.questionId}"
                            data-optionid="${opt.qOptionId}"
                            data-sellprice="${opt.sellPrice || 0}"
                            data-costprice="${opt.costPrice || 0}"
                            ${selectedId === opt.qOptionId ? 'selected' : ''}>
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
        const answerText = question.answerText || '';
        const primaryId = question.primaryId || 0;

        const inputHTML = `
            <div class="section-input-wrapper-c less-width-select-c">
                <input type="text"
                    class="section-input-c"
                    name="Answers[${question.questionId}].AnswerText"
                    id="q-${question.questionId}"
                    data-questionid="${question.questionId}"
                    data-optionid="0"
                    data-primaryid="${primaryId}"
                    value="${this.escapeHtml(answerText)}"
                />
            </div>
        `;

        container.innerHTML += inputHTML;
    }

    expandAllGroups() {
        const headers = document.querySelectorAll('.dropdown-header-c.parentToggler');
        const sections = document.querySelectorAll('.section-container-c.shadow-c');

        headers.forEach((header, i) => {
            const section = sections[i];
            if (header && section) {
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
            }
        });
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

            // ✅ FIX: Get savedValue from the metafield object
            const savedValue = metafield.savedValue || '';

            const fieldType = (metafield.fieldType || '').toLowerCase();

            // ✅ Handle different field types
            if (['input', 'text', 'textbox', 'string', 'single line text'].includes(fieldType) || !fieldType) {
                const inputHTML = `
                <div class="section-input-wrapper-c less-width-select-c">
                    <input type="text"
                        class="section-input-c metafield-input"
                        name="Metafields[${metafield.pid}].Value"
                        id="metafield-${metafield.pid}"
                        data-metafield-id="${metafield.pid}"
                        data-metafield-name="${this.escapeHtml(metafield.name)}"
                        value="${this.escapeHtml(savedValue)}"
                    />
                    <input type="hidden" name="Metafields[${metafield.pid}].PID" value="${metafield.pid}" />
                </div>
            `;
                metafieldDiv.innerHTML += inputHTML;
            }
            else if (fieldType === 'table') {
                // ✅ Handle table type metafields
                let rows = [];

                if (savedValue) {
                    try {
                        rows = JSON.parse(savedValue);
                    } catch (e) {
                        console.warn('Invalid table JSON:', savedValue);
                    }
                }

                if (!Array.isArray(rows) || rows.length === 0) {
                    rows = [{ optionId: "", quantity: 0 }];
                }

                const rowsHtml = rows.map((row, index) => `
                <div class="selects-wrapper-c">
                    <div class="section-input-wrapper-c less-width-select2-c">
                        <select class="section-input-c selectt-c conditional-select"
                            data-metafield-id="${metafield.pid}">
                            <option value="">Select</option>
                            ${(metafield.options || []).map(opt => `
                                <option value="${opt.optionId}"
                                    ${String(opt.optionId) === String(row.optionId) ? 'selected' : ''}>
                                    ${this.escapeHtml(opt.optionText)}
                                </option>
                            `).join('')}
                        </select>
                    </div>

                    <div class="section-input-wrapper-c less-width-select2-c">
                        <input type="number"
                            class="section-input-c"
                            min="0"
                            value="${row.quantity ?? 0}" />
                    </div>

                    <div class="line-item-cross-container-c">
                        <button type="button" class="line-item-cross-btn-c">
                            <img src="/images/close-cancel.svg" alt="Remove">
                        </button>
                    </div>
                </div>
            `).join('');

                metafieldDiv.innerHTML += `
                <div class="section-container-c line-item-modal-c">
                    <header class="popup-section-header-c no-top-margin-c custom-bg-c">
                        <span class="popup-header-text-c">Type</span>
                        <span class="popup-header-text-c line-modal-margin-c">Quantity</span>
                        <span class="popup-header-text-c"></span>
                    </header>

                    <div class="line-item-modal-c popup-sub-box-c top-corners-c">
                        <div class="selects-container-c" id="table-rows-${metafield.pid}">
                            ${rowsHtml}
                        </div>

                        <div class="save-btn-container-c">
                            <button type="button"
                                class="btn-save-c add-line-c"
                                data-metafield="${metafield.pid}">
                                Add Line Item
                            </button>
                        </div>
                    </div>
                </div>
            `;
            }

            container.appendChild(metafieldDiv);
        });

        // ✅ Expand the metafields section after rendering
        this.expandMetafieldsSection();

        console.log(`✅ Rendered ${metafields.length} metafields with saved values`);
    }

    // ✅ ADD THIS NEW METHOD to expand metafields section
    expandMetafieldsSection() {
        const metafieldsContainer = document.getElementById('metafields-container');
        if (!metafieldsContainer) return;

        const header = metafieldsContainer.querySelector('.metafield-header');
        const section = metafieldsContainer.querySelector('.metafield-section');

        if (header && section) {
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
        }
    }


    // RENDER METAFIELDS
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

    //    metafieldsContainer.style.display = 'block';
    //    container.innerHTML = '';

    //    metafields.forEach(metafield => {
    //        const metafieldDiv = this.createDOMElement('div', {
    //            className: 'question-bottom-margins-c',
    //            attributes: {
    //                'data-metafield-id': metafield.pid
    //            }
    //        });

    //        metafieldDiv.innerHTML = `
    //        <h2 class="section-subheading-c no-margin-c">
    //            ${this.escapeHtml(metafield.name)}
    //        </h2>
    //    `;

    //        const fieldType = (metafield.fieldType || '').toLowerCase();
    //        const savedValue = metafield.savedValue;

    //        /* ===================== TEXT ===================== */
    //        if (['input', 'text', 'textbox', 'string', 'single line text'].includes(fieldType)) {

    //            metafieldDiv.innerHTML += `
    //            <div class="section-input-wrapper-c less-width-select-c">
    //                <input type="text"
    //                    class="section-input-c metafield-input"
    //                    name="Metafields[${metafield.pid}].Value"
    //                    id="metafield-${metafield.pid}"
    //                    data-metafield-id="${metafield.pid}"
    //                    value="${this.escapeHtml(savedValue ?? '')}"
    //                />
    //                <input type="hidden" name="Metafields[${metafield.pid}].PID" value="${metafield.pid}" />
    //            </div>
    //        `;
    //        }

    //        /* ===================== TABLE ===================== */
    //        else if (fieldType === 'table') {

    //            let rows = [];

    //            if (savedValue) {
    //                try {
    //                    rows = JSON.parse(savedValue);
    //                } catch (e) {
    //                    console.warn('Invalid table JSON:', savedValue);
    //                }
    //            }

    //            if (!Array.isArray(rows) || rows.length === 0) {
    //                rows = [{ optionId: "", quantity: 0 }];
    //            }

    //            const rowsHtml = rows.map((row, index) => `
    //            <div class="selects-wrapper-c">
    //                <div class="section-input-wrapper-c less-width-select2-c">
    //                    <select class="section-input-c selectt-c conditional-select"
    //                        data-metafield-id="${metafield.pid}">
    //                        <option value="">Select</option>
    //                        ${(metafield.options || []).map(opt => `
    //                            <option value="${opt.optionId}"
    //                                ${String(opt.optionId) === String(row.optionId) ? 'selected' : ''}>
    //                                ${this.escapeHtml(opt.optionText)}
    //                            </option>
    //                        `).join('')}
    //                    </select>
    //                </div>

    //                <div class="section-input-wrapper-c less-width-select2-c">
    //                    <input type="number"
    //                        class="section-input-c"
    //                        min="0"
    //                        value="${row.quantity ?? 0}" />
    //                </div>

    //                <div class="line-item-cross-container-c">
    //                    <button type="button" class="line-item-cross-btn-c">
    //                        <img src="/images/close-cancel.svg" alt="Remove">
    //                    </button>
    //                </div>
    //            </div>
    //        `).join('');

    //            metafieldDiv.innerHTML += `
    //            <div class="section-container-c line-item-modal-c">
    //                <header class="popup-section-header-c no-top-margin-c custom-bg-c">
    //                    <span class="popup-header-text-c">Type</span>
    //                    <span class="popup-header-text-c line-modal-margin-c">Quantity</span>
    //                    <span class="popup-header-text-c"></span>
    //                </header>

    //                <div class="line-item-modal-c popup-sub-box-c top-corners-c">
    //                    <div class="selects-container-c" id="table-rows-${metafield.pid}">
    //                        ${rowsHtml}
    //                    </div>

    //                    <div class="save-btn-container-c">
    //                        <button type="button"
    //                            class="btn-save-c add-line-c"
    //                            data-metafield="${metafield.pid}">
    //                            Add Line Item
    //                        </button>
    //                    </div>
    //                </div>
    //            </div>
    //        `;
    //        }

    //        container.appendChild(metafieldDiv);
    //    });

    //    console.log(`✅ Rendered ${metafields.length} metafields with saved values`);
    //}

}

// STICKY NOTE MANAGER CLASS
class StickyNoteManager {
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

        //(`💰 Totals Updated: Cost=${totalCost}, Sell=${totalSell}`);
    }

    // In StickyNoteManager class - REPLACE getSelectedOptionsWithPrices method:

    getSelectedOptionsWithPrices() {
        const selected = [];

        // ✅ Use composite key (optionId + parentOptionId) to track uniqueness
        const seenKeys = new Set();

        // Checkboxes
        document.querySelectorAll('input[type=checkbox].single-select-c:checked').forEach(checkbox => {
            const optionId = parseInt(checkbox.value);
            const parentOptionId = checkbox.getAttribute('data-parent-option-id') ||
                checkbox.dataset.parentOptionId ||
                'root';

            const uniqueKey = `${optionId}-${parentOptionId}`;

            if (!seenKeys.has(uniqueKey)) {
                const prices = this.getPricesForOption(optionId);
                selected.push({
                    optionId,
                    parentOptionId,
                    quantity: 1,
                    ...prices
                });
                seenKeys.add(uniqueKey);
            }
        });

        // Radios
        document.querySelectorAll('input[type=radio]:checked').forEach(radio => {
            const optionId = parseInt(radio.value);
            const parentOptionId = radio.getAttribute('data-parent-option-id') ||
                radio.dataset.parentOptionId ||
                'root';

            const uniqueKey = `${optionId}-${parentOptionId}`;

            if (!seenKeys.has(uniqueKey)) {
                const prices = this.getPricesForOption(optionId);
                selected.push({
                    optionId,
                    parentOptionId,
                    quantity: 1,
                    ...prices
                });
                seenKeys.add(uniqueKey);
            }
        });

        // Select lists (including tables)
        document.querySelectorAll('select.section-input-c.selectt-c, select.conditional-select').forEach(sel => {
            if (sel.value && !isNaN(sel.value)) {
                const optionId = parseInt(sel.value);
                const parentOptionId = sel.getAttribute('data-parent-option-id') ||
                    sel.dataset.parentOptionId ||
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

                // ✅ For tables, include row index to allow multiple rows with same option
                const rowIndex = wrapper ?
                    Array.from(wrapper.parentElement.children).indexOf(wrapper) : 0;
                const uniqueKey = `${optionId}-${parentOptionId}-${rowIndex}`;

                if (!seenKeys.has(uniqueKey) && quantity > 0) {
                    const prices = this.getPricesForOption(optionId);
                    selected.push({
                        optionId,
                        parentOptionId,
                        quantity,
                        ...prices
                    });
                    seenKeys.add(uniqueKey);
                }
            }
        });

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
class QuoteEventManager {
    setupGlobalHandlers(manager) {
        this.manager = manager;
        this.setupGroupToggleHandlers();
        this.setupConditionalQuestionHandlers();
        this.setupTableHandlers();
        this.setupSingleCheckboxEnforcement(); 
        this.setupPriceUpdateHandlers(); 
    }

    async deleteTableRowFromDB(row) {
        const selectEl = row.querySelector('select');
        const inputEl = row.querySelector('input[type="number"]');

        if (!selectEl || !inputEl) return;

        const selectedOption = selectEl.selectedOptions[0];
        if (!selectedOption || !selectedOption.value) return;

        const quoteIdInput = document.querySelector('input[name="QuoteId"]');
        if (!quoteIdInput) return;

        const quoteId = quoteIdInput.value;
        const quoteVersionId = document.getElementById('QuoteVersionId')?.value || 2;

        const primaryId = Math.max(
            Number(selectEl.dataset.primaryid || 0),
            Number(inputEl.dataset.primaryid || 0)
        );

        // ✅ Get parent option ID for dependent questions
        const parentOptionId = selectEl.getAttribute('data-parent-option-id') ||
            selectEl.dataset.parentOptionId ||
            row.closest('[data-parent-option-id]')?.getAttribute('data-parent-option-id') ||
            null;

        const data = {
            quoteId: parseInt(quoteId),
            primaryId: primaryId,
            questionId: parseInt(selectedOption.dataset.questionid || selectEl.dataset.questionid),
            optionId: parseInt(selectedOption.dataset.optionid),
            sellPrice: selectedOption.dataset.sellprice || null,
            costPrice: selectedOption.dataset.costprice || null,
            value: inputEl.value,
            action: "delete",
            fieldType: "table",
            quoteVersionId: parseInt(quoteVersionId),
            parentOptionId: parentOptionId ? parseInt(parentOptionId) : null
        };

        console.log('🗑️ Deleting table row from DB:', data);

        try {
            const response = await fetch('/api/QuoteAnswer/RemoveQuoteDetailAnswer', {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify(data)
            });

            const result = await response.json();

            if (result.success) {
                console.log('✅ Table row deleted from DB');
            } else {
                console.error('❌ Failed to delete table row:', result.message);
            }
        } catch (error) {
            console.error('❌ Error deleting table row:', error);
        }
    }

    setupGroupToggleHandlers() {
        // ✅ Use document instead of container
        document.addEventListener('click', (e) => {
            const header = e.target.closest('.dropdown-header-c.parentToggler');
            if (!header) return;

            e.preventDefault();
            e.stopPropagation();

            console.log('🖱️ Header clicked:', header.classList);

            // ✅ CHECK: Is it metafield header?
            if (header.classList.contains('metafield-header')) {
                console.log('📋 Metafield header detected');

                const headerWrapper = header.closest('.section-container-c');
                const metafieldSection = headerWrapper?.nextElementSibling;

                console.log('📦 Metafield section found:', metafieldSection);

                if (metafieldSection && metafieldSection.classList.contains('metafield-section')) {
                    console.log('🔄 Toggling metafield section');
                    this.manager.renderer.toggleGroup(header, metafieldSection);
                } else {
                    console.error('❌ Metafield section not found!');
                }
                return;
            }

            // ✅ REGULAR QUESTION GROUPS
            console.log('📝 Question group header detected');
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

        const maxRows = firstSelect.options.length - 1; // Exclude "Select"
        const currentRows = container.querySelectorAll('.selects-wrapper-c').length;
        if (currentRows >= maxRows) return; // Limit rows

        const newIndex = currentRows;
        const newRow = document.createElement('div');
        newRow.className = 'selects-wrapper-c';

        newRow.innerHTML = `
        <div class="section-input-wrapper-c less-width-select2-c">
            <select class="section-input-c selectt-c conditional-select"
                    name="Answers[${questionId}].LineItems[${newIndex}].OptionId"
                    data-toggle="conditional"
                    data-questionid="${questionId}">
                ${firstSelect.innerHTML}
            </select>
        </div>
        <div class="section-input-wrapper-c less-width-select2-c">
            <input type="number"
                   class="section-input-c"
                   name="Answers[${questionId}].LineItems[${newIndex}].Quantity"
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
    }

    handleRemoveLineItem(removeButton) {
        const row = removeButton.closest('.selects-wrapper-c');
        const container = row?.closest('.selects-container-c');
        const wrappers = container ? container.querySelectorAll('.selects-wrapper-c') : [];

        if (container && wrappers.length > 1) {
            // Delete from DB first, then remove UI
            const select = row.querySelector('select');
            const input = row.querySelector('input[type="number"]');
            const selectedOption = select?.selectedOptions[0];

            if (selectedOption && selectedOption.value) {
                const quoteIdInput = document.querySelector('input[name="QuoteId"]');
                const quoteId = quoteIdInput ? quoteIdInput.value : null;
                const quoteVersionId = document.getElementById('QuoteVersionId')?.value || 2;
                const primaryId = Math.max(
                    Number(select.dataset.primaryid || 0),
                    Number(input.dataset.primaryid || 0)
                );

                // ✅ FIX: Get parent option ID
                const parentOptionId = select.getAttribute('data-parent-option-id') ||
                    select.dataset.parentOptionId ||
                    row.closest('[data-parent-option-id]')?.getAttribute('data-parent-option-id') ||
                    null;

                const data = {
                    quoteId: parseInt(quoteId),                                                              // ✅ Integer
                    primaryId: parseInt(primaryId) || 0,                                                     // ✅ Integer
                    questionId: parseInt(selectedOption.dataset.questionid || select.dataset.questionid) || 0,  // ✅ FIX
                    optionId: parseInt(selectedOption.dataset.optionid || selectedOption.value) || 0,        // ✅ FIX
                    sellPrice: selectedOption.dataset.sellprice || null,
                    costPrice: selectedOption.dataset.costprice || null,
                    value: input.value,
                    action: "delete",
                    fieldType: "table",
                    quoteVersionId: parseInt(quoteVersionId) || 2,                                           // ✅ Integer
                    parentOptionId: parentOptionId ? parseInt(parentOptionId) : null                         // ✅ FIX
                };

                console.log("🗑️ Remove Line Item Payload:", data);  // ✅ Debug
                this.manager.autoSaveManager.updateAnswerInDb("delete", data, null);
            }

            row.remove();
            this.manager.stickyNoteManager.updateTotals();
        } else if (container && wrappers.length === 1) {
            // Only one row left: delete from DB if it has data
            const select = row.querySelector('select');
            const input = row.querySelector('input[type="number"]');
            const selectedOption = select?.selectedOptions[0];

            if (selectedOption && selectedOption.value) {
                const quoteIdInput = document.querySelector('input[name="QuoteId"]');
                const quoteId = quoteIdInput ? quoteIdInput.value : null;
                const quoteVersionId = document.getElementById('QuoteVersionId')?.value || 2;
                const primaryId = Math.max(
                    Number(select.dataset.primaryid || 0),
                    Number(input.dataset.primaryid || 0)
                );

                // ✅ FIX: Get parent option ID
                const parentOptionId = select.getAttribute('data-parent-option-id') ||
                    select.dataset.parentOptionId ||
                    row.closest('[data-parent-option-id]')?.getAttribute('data-parent-option-id') ||
                    null;

                const data = {
                    quoteId: parseInt(quoteId),                                                              // ✅ Integer
                    primaryId: parseInt(primaryId) || 0,                                                     // ✅ Integer
                    questionId: parseInt(selectedOption.dataset.questionid || select.dataset.questionid) || 0,  // ✅ FIX
                    optionId: parseInt(selectedOption.dataset.optionid || selectedOption.value) || 0,        // ✅ FIX
                    sellPrice: selectedOption.dataset.sellprice || null,
                    costPrice: selectedOption.dataset.costprice || null,
                    value: input.value,
                    action: "delete",
                    fieldType: "table",
                    quoteVersionId: parseInt(quoteVersionId) || 2,                                           // ✅ Integer
                    parentOptionId: parentOptionId ? parseInt(parentOptionId) : null                         // ✅ FIX
                };

                console.log("🗑️ Reset Last Row Payload:", data);  // ✅ Debug
                this.manager.autoSaveManager.updateAnswerInDb("delete", data, null);
            }

            // Reset UI
            if (select) select.selectedIndex = 0;
            if (input) input.value = 0;
            this.manager.stickyNoteManager.updateTotals();
        }
    }

    // In QuoteEventManager class - REPLACE setupConditionalQuestionHandlers method:

    setupConditionalQuestionHandlers() {
        document.addEventListener('change', async (e) => {
            if (!e.target.matches('[data-toggle=conditional]')) return;

            const input = e.target;
            const questionDiv = input.closest('.question-bottom-margins-c');
            const questionIdInput = questionDiv?.querySelector('input[type=hidden][name$=".QuestionId"]');
            const questionId = questionIdInput?.value;

            if (!questionId) return;

            // ✅ FIX: Get the parent option ID of the current input
            const currentParentOptionId = input.getAttribute('data-parent-option-id') || null;

            // ✅ FIX: Find dependent container specific to THIS context
            let dependentContainer = questionDiv.querySelector('.dependent-section-c');

            // ✅ Clear only this specific dependent section
            if (dependentContainer) {
                const previousParentOption = dependentContainer.getAttribute('data-parent-option');

                // Only clear if this is for a different option or unchecking
                if (previousParentOption) {
                    // Get all table rows before clearing
                    const allTableRows = dependentContainer.querySelectorAll('.selects-wrapper-c');

                    // Delete all table row data from database
                    for (const row of allTableRows) {
                        await this.deleteTableRowFromDB(row);
                    }
                }

                // Clear the UI
                dependentContainer.classList.add('hidden');
                dependentContainer.innerHTML = '';
                dependentContainer.removeAttribute('data-parent-option');
                console.log(`🗑️ Cleared dependent section for Q${questionId}`);
            }

            // Load new dependents if option is selected
            if (input.checked || (input.tagName === 'SELECT' && input.value)) {
                const optionId = parseInt(input.value);
                const quoteId = this.manager.getQuoteId();

                console.log(`📥 Loading dependents for Q${questionId}, Option${optionId}, ParentOption${currentParentOptionId}`);

                try {
                    const result = await this.manager.apiService.fetchDependentQuestions(quoteId, optionId);
                    if (result.success && result.data) {
                        await this.renderDependentQuestions(optionId, result.data, questionId, questionDiv);
                        console.log(`✅ Rendered dependents for Q${questionId}`);
                    }
                } catch (error) {
                    console.error('❌ Error fetching dependent questions:', error);
                }
            }

            this.manager.stickyNoteManager.updateTotals();
        });

        console.log('✅ Conditional question handlers setup with parent-aware cleanup');
    }

    async renderDependentQuestions(optionId, dependentData, parentQuestionId, parentQuestionDiv) {
        // ✅ DEBUG: Log the dependent data received from API
        console.log('📋 Dependent Data for Option', optionId, ':', dependentData);

        // ✅ FIX: Find or create a dependent section specific to THIS parent option
        let dependentSection = parentQuestionDiv.querySelector(`.dependent-section-c[data-parent-option="${optionId}"]`);

        // If no section exists for this specific parent option, use the generic one
        if (!dependentSection) {
            dependentSection = parentQuestionDiv.querySelector('.dependent-section-c');
        }

        if (!dependentSection) return;

        // ✅ FIX: Mark this section with the parent option ID
        dependentSection.setAttribute('data-parent-option', optionId);
        dependentSection.classList.remove('hidden');
        dependentSection.innerHTML = '';

        if (dependentData.questionGroups && dependentData.questionGroups.length > 0) {
            dependentData.questionGroups.forEach(group => {
                console.log('📦 Group:', group.questionGroupName);

                group.questions.forEach(question => {
                    // ✅ DEBUG: Log each question and its lineItems
                    const fieldType = (question.fieldTypeName || '').toLowerCase();
                    console.log(`❓ Question ${question.questionId} (${fieldType}):`, {
                        questionText: question.questionText,
                        lineItems: question.lineItems,
                        lineItemsCount: question.lineItems?.length || 0,
                        selectedOptionId: question.selectedOptionId,
                        options: question.options?.length || 0
                    });

                    // ✅ DEBUG: If it's a table, log detailed lineItems
                    if (fieldType === 'table') {
                        console.log(`📊 TABLE Q${question.questionId} lineItems:`, JSON.stringify(question.lineItems, null, 2));
                    }

                    const questionElement = this.manager.renderer.renderQuestion(question);

                    // ✅ Mark the container with parent option ID
                    questionElement.setAttribute('data-parent-option-id', optionId);

                    // ✅ Add ParentOptionId to all inputs in this dependent question
                    questionElement.querySelectorAll('input, select').forEach(input => {
                        input.setAttribute('data-parent-option-id', optionId);
                    });

                    // ✅ FIX: Make the nested dependent section unique
                    const nestedDependentSection = questionElement.querySelector('.dependent-section-c');
                    if (nestedDependentSection) {
                        nestedDependentSection.setAttribute('data-grandparent-option', optionId);
                    }

                    dependentSection.appendChild(questionElement);
                });
            });

            // Update price map
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

            // ✅ Recursively load nested dependents
            await this.manager.renderer.loadNestedDependents(dependentSection);
        }
    }
    // Ensures only one checkbox is selected per group (single-select behavior)
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

    // Updates totals on any radio/select change (price recalculation)
    setupPriceUpdateHandlers() {
        document.addEventListener('change', function (e) {
            if (e.target.matches('input[type=radio], select.section-input-c, select.conditional-select')) {
                if (window.quotePreviewManager && window.quotePreviewManager.stickyNoteManager) {
                    window.quotePreviewManager.stickyNoteManager.updateTotals();
                }
            }
        });
    }


}

// AUTOSAVE MANAGER CLASS
class AutoSaveManager {
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
        const revisionBtn = document.getElementById('createRevisionBtn');
        if (!btn && !revisionBtn) return;

        try {
            const quoteVersionId = document.getElementById('QuoteVersionId')?.value || 2;
            const res = await fetch(`/api/QuoteAnswer/IsAllRequiredAnswered?quoteId=${quoteId}&quoteVersionId=${quoteVersionId}`);
            const data = await res.json();

            // For Add Services button
            if (btn) {
                if (!data.hasRequired || data.allAnswered) {
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
            }

            // For Create Revision button
            if (revisionBtn) {
                if (!data.hasRequired || data.allAnswered) {
                    revisionBtn.disabled = false;
                    revisionBtn.style.opacity = "1";
                    revisionBtn.style.pointerEvents = "auto";
                    revisionBtn.style.cursor = "";
                } else {
                    revisionBtn.disabled = true;
                    revisionBtn.style.opacity = "0.5";
                    revisionBtn.style.pointerEvents = "none";
                    revisionBtn.style.cursor = "not-allowed";
                }
            }
        } catch (err) {
            if (btn) {
                btn.disabled = false;
                btn.style.opacity = "1";
                btn.style.pointerEvents = "auto";
                btn.style.cursor = "";
            }
            if (revisionBtn) {
                revisionBtn.disabled = false;
                revisionBtn.style.opacity = "1";
                revisionBtn.style.pointerEvents = "auto";
                revisionBtn.style.cursor = "";
            }
            console.error('Error checking required answers', err);
        }
    }


    setupFieldChangeListener() {
        const getQuoteVersionId = () => {
            const input = document.getElementById('QuoteVersionId');
            return input ? parseInt(input.value) || 2 : 2;
        };

        const getFieldData = (el) => {
            const quoteIdInput = document.querySelector('input[name="QuoteId"]');
            if (!quoteIdInput) return null;

            const quoteId = parseInt(quoteIdInput.value) || 0;
            const primaryId = parseInt(el.dataset.primaryid) || 0;
            const quoteVersionId = getQuoteVersionId();

            // Get ParentOptionId correctly
            const parentOptionId = el.getAttribute('data-parent-option-id') ||
                el.dataset.parentOptionId ||
                el.dataset.parentoptionid ||
                null;

            // Case 1: Table row
            const row = el.closest(".selects-wrapper-c");
            if (row) {
                const selectEl = row.querySelector("select");
                const inputEl = row.querySelector("input[type='number']");
                if (!selectEl || !inputEl) return null;

                const selectedOption = selectEl.selectedOptions[0];
                if (!selectedOption) return null;

                const rowPrimaryId = Math.max(
                    parseInt(selectEl.dataset.primaryid) || 0,
                    parseInt(inputEl.dataset.primaryid) || 0
                );

                const rowParentOptionId = selectEl.getAttribute('data-parent-option-id') ||
                    selectEl.dataset.parentOptionId ||
                    row.closest('[data-parent-option-id]')?.getAttribute('data-parent-option-id') ||
                    null;

                return {
                    quoteId: quoteId,
                    primaryId: rowPrimaryId,
                    questionId: parseInt(selectedOption.dataset.questionid || selectEl.dataset.questionid) || 0,
                    optionId: parseInt(selectedOption.dataset.optionid) || 0,
                    sellPrice: selectedOption.dataset.sellprice || null,
                    costPrice: selectedOption.dataset.costprice || null,
                    value: inputEl.value,
                    action: "add",
                    fieldType: "table",
                    quoteVersionId: quoteVersionId,
                    parentOptionId: rowParentOptionId ? parseInt(rowParentOptionId) : null
                };
            }

            // Case 2: Checkbox/Radio
            if (el.type === "checkbox" || el.type === "radio") {
                return {
                    quoteId: quoteId,
                    primaryId: primaryId,
                    questionId: parseInt(el.dataset.questionid) || 0,
                    optionId: parseInt(el.dataset.optionid) || 0,
                    sellPrice: el.dataset.sellprice || null,
                    costPrice: el.dataset.costprice || null,
                    value: el.checked ? "checked" : "unchecked",
                    action: el.checked ? "add" : "delete",
                    fieldType: el.type,
                    quoteVersionId: quoteVersionId,
                    parentOptionId: parentOptionId ? parseInt(parentOptionId) : null
                };
            }

            // Case 3: Text input
            if (el.dataset?.questionid && el.tagName !== "SELECT") {
                return {
                    quoteId: quoteId,
                    primaryId: primaryId,
                    questionId: parseInt(el.dataset.questionid) || 0,
                    optionId: parseInt(el.dataset.optionid) || 0,
                    sellPrice: el.dataset.sellprice || null,
                    costPrice: el.dataset.costprice || null,
                    value: el.value,
                    action: "add",
                    fieldType: "input",
                    quoteVersionId: quoteVersionId,
                    parentOptionId: parentOptionId ? parseInt(parentOptionId) : null
                };
            }

            // Case 4: Select dropdown
            if (el.tagName === "SELECT") {
                const selectedOption = el.selectedOptions[0];
                if (!selectedOption) return null;

                const selectParentOptionId = el.getAttribute('data-parent-option-id') ||
                    el.dataset.parentOptionId ||
                    el.closest('[data-parent-option-id]')?.getAttribute('data-parent-option-id') ||
                    null;

                return {
                    quoteId: quoteId,
                    primaryId: parseInt(el.dataset.primaryid) || 0,
                    questionId: parseInt(selectedOption.dataset.questionid || el.dataset.questionid) || 0,
                    optionId: parseInt(selectedOption.dataset.optionid) || 0,
                    sellPrice: selectedOption.dataset.sellprice || null,
                    costPrice: selectedOption.dataset.costprice || null,
                    value: selectedOption.value,
                    action: "add",
                    fieldType: "select",
                    quoteVersionId: quoteVersionId,
                    parentOptionId: selectParentOptionId ? parseInt(selectParentOptionId) : null
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
            const quoteVersionId = getQuoteVersionId();

            const primaryId = Math.max(
                Number(selectEl.dataset.primaryid || 0),
                Number(inputEl.dataset.primaryid || 0)
            );

            // ✅ FIX: Get parent option ID
            const parentOptionId = selectEl.getAttribute('data-parent-option-id') ||
                selectEl.dataset.parentOptionId ||
                row.closest('[data-parent-option-id]')?.getAttribute('data-parent-option-id') ||
                null;

            const data = {
                quoteId: parseInt(quoteId),                                                           // ✅ Ensure integer
                primaryId: parseInt(primaryId) || 0,                                                  // ✅ Ensure integer
                questionId: parseInt(selectedOption.dataset.questionid || selectEl.dataset.questionid) || 0,  // ✅ FIX: Parse to integer
                optionId: parseInt(selectedOption.dataset.optionid || selectedOption.value) || 0,    // ✅ FIX: Parse to integer
                sellPrice: selectedOption.dataset.sellprice || null,
                costPrice: selectedOption.dataset.costprice || null,
                value: inputEl.value,
                action: "delete",
                fieldType: "table",
                quoteVersionId: parseInt(quoteVersionId) || 2,                                        // ✅ Ensure integer
                parentOptionId: parentOptionId ? parseInt(parentOptionId) : null                      // ✅ FIX: Add parentOptionId
            };

            console.log("🗑️ Delete Row Payload:", data);  // ✅ Debug log
            this.updateAnswerInDb("delete", data, null);
        };

        // Main change listener
        document.addEventListener("change", (e) => {
            const el = e.target;

            if (!el.dataset.questionid &&
                !el.closest('.selects-wrapper-c') &&
                el.type !== 'checkbox' &&
                el.type !== 'radio' &&
                el.tagName !== 'SELECT') {
                return;
            }

            // ✅ FIX: Skip if we're in the middle of copying to version 2
            if (el.dataset.skipAutoSave === 'true') {
                return;
            }

            if (el.type === "checkbox" || el.type === "radio") {
                const data = getFieldData(el);
                if (!data || !data.questionId) return;
                this.updateAnswerInDb(data.action, data, el);
                return;
            }

            const data = getFieldData(el);
            if (!data || !data.questionId) return;

            if (data.fieldType === "table") {
                if (!this._debouncedTableSave) {
                    this._debouncedTableSave = this._debounce(this.updateAnswerInDb.bind(this), 350);
                }
                this._debouncedTableSave(data.action, data, el);
            } else {
                this.updateAnswerInDb(data.action, data, el);
            }
        });

        // ✅ FIX: Only ONE delete button listener (removed duplicate)
        document.addEventListener("click", handleRowDelete.bind(this));


        // ✅ ADD THIS BLOCK - Metafield AutoSave
        let metafieldSaveTimer = null;

        document.addEventListener('input', function (e) {

            const isTextbox = e.target.classList.contains('metafield-input');

            // ✅ FIX: Only match tables INSIDE the metafields container
            const metafieldsContainer = document.getElementById('metafields-container');
            const isMetafieldTableInput =
                metafieldsContainer &&
                metafieldsContainer.contains(e.target) &&  // ✅ Must be inside metafields container
                e.target.closest('.selects-wrapper-c') &&
                (
                    e.target.tagName === 'SELECT' ||
                    (e.target.tagName === 'INPUT' && e.target.type === 'number')
                );

            // ✅ FIX: Skip if this is a regular question table (has data-questionid)
            if (!isTextbox && !isMetafieldTableInput) return;

            // ✅ FIX: Skip if this element has a questionid (it's a question, not a metafield)
            if (e.target.dataset.questionid || e.target.closest('[data-questionid]')) {
                return;
            }

            clearTimeout(metafieldSaveTimer);

            metafieldSaveTimer = setTimeout(async () => {

                const quoteId = document.querySelector('input[name="QuoteId"]')?.value;
                const templateVersionId = document.querySelector('input[name="TemplateVersion"]')?.value;

                let metafieldId;
                let metafieldInput;

                if (isTextbox) {
                    metafieldId = e.target.dataset.metafieldId;
                    metafieldInput = e.target.value;
                }
                else {
                    const table = e.target.closest('[id^="table-rows-"]');
                    if (!table) return;  // ✅ Safety check

                    const tableId = table.id.replace('table-rows-', '');

                    // ✅ FIX: Check if this is a question table (numeric questionId) vs metafield table
                    // Question tables have numeric IDs, skip them
                    if (!isNaN(parseInt(tableId))) {
                        // Check if a question with this ID exists in the DOM
                        const questionElement = document.querySelector(`[data-question-id="${tableId}"]`);
                        if (questionElement) {
                            console.log(`⏭️ Skipping question table ${tableId} - not a metafield`);
                            return;
                        }
                    }

                    metafieldId = tableId;
                    metafieldInput = buildMetafieldTableValue(metafieldId);
                }

                if (!quoteId || !templateVersionId || !metafieldId) {
                    console.warn('⚠️ Missing metafield save data');
                    return;
                }

                const payload = {
                    quoteId: parseInt(quoteId),
                    templateVersionId: parseInt(templateVersionId),
                    metafieldId: parseInt(metafieldId),
                    metafieldInput: metafieldInput
                };

                console.log('📤 Metafield autosave payload:', payload);

                try {
                    const response = await fetch('/api/Metafield/SaveMetafieldAnswer', {
                        method: 'POST',
                        headers: { 'Content-Type': 'application/json' },
                        body: JSON.stringify(payload)
                    });

                    const result = await response.json();

                    if (!result.success) {
                        console.error('❌ Metafield save failed', result);
                    }

                } catch (err) {
                    console.error('❌ Metafield autosave error', err);
                }

            }, 400);
        });


        console.log('✅ Field change listener setup for QuoteDetail (including metafields)');
    }

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
            quoteVersionId: data.quoteVersionId || 2
        };
        // NEW API endpoints for QuoteDetail (version 2)
        const url = action === "delete"
            ? "/api/QuoteAnswer/RemoveQuoteDetailAnswer"
            : "/api/QuoteAnswer/AddQuoteDetailAnswer";

        //("📤 Sending to API:", url, payload);

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
                    //("✅ Saved:", result.message);
                    
                    // Update primaryId on element
                    if (result.primaryId !== undefined && result.primaryId !== null && el) {
                        el.setAttribute("data-primaryid", result.primaryId);
                    }

                    // ✅ Update QuoteVersionId in hidden input
                    if (result.quoteVersionId) {
                        const versionInput = document.getElementById('QuoteVersionId');
                        if (versionInput) {
                            versionInput.value = result.quoteVersionId;
                        }
                    }
                } else {
                    console.error("❌ Failed:", result.message);
                }
                window.quotePreviewManager.autoSaveManager.checkRequiredAnswersAndToggleButton();
              })
            .catch((err) => console.error("Error:", err));
    }

    

}
//  APPLICATION BOOTSTRAP
document.addEventListener('DOMContentLoaded', () => {
    window.quotePreviewManager = new QuotePreviewManager();
    //window.quotePreviewManager.autoSaveManager.checkRequiredAnswersAndToggleButton();
  });

function buildMetafieldTableValue(metafieldId) {
    const table = document.getElementById(`table-rows-${metafieldId}`);
    if (!table) return "[]";

    const rows = Array.from(table.querySelectorAll('.selects-wrapper-c'));

    const data = rows
        .map(row => {
            const select = row.querySelector('select');
            const qty = row.querySelector('input[type="number"]');

            const optionId = select?.value;
            const quantity = qty?.value;

            if (!optionId && !quantity) return null;

            return {
                optionId: optionId ? parseInt(optionId) : 0,
                quantity: quantity ? parseInt(quantity) : 0
            };
        })
        .filter(x => x !== null);

    return JSON.stringify(data);
}



