
class ServiceManager {
    constructor() {
        // Modal elements
        this.modal = document.getElementById('services-modal');
        this.openModalBtn = document.getElementById('btn-save-1');
        this.closeModalBtns = this.modal?.querySelectorAll('.cross-button-svg-c');
        this.createQuoteBtn = document.querySelector('.quote-create-c');

        // Table elements
        this.tableBody = document.querySelector('.quote-custom-table-c tbody');
        this.form = document.getElementById('quoteForm');

        // Level buttons
        this.btnL1 = document.getElementById('item-level-1');
        this.btnL2 = document.getElementById('item-level-2');
        this.btnL3 = document.getElementById('item-level-3');

        // Dropdown toggle
        this.toggleBtn = document.getElementById('dropDownToggle-add');
        this.dropdownMenu = document.getElementById('dropdownMenu-add');
        this.pageType = document.querySelector('input[name="type"]');

        // Constants
        this.DISABLED_COLOR = '#d4d4d4';
        this.ENABLED_COLOR = '#484848';
        this.apiService = new DefaultApiService();

        this.init();
    }

    init() {
        if (!this.modal || !this.tableBody) {
            console.error('❌ Required elements not found');
            return;
        }
            if (this.pageType.value === "details") {
                this.checkDownloadBtnStatus();
            } 
        this.setupModalHandlers();
        this.setupTableHandlers();
        this.setupDropdownHandlers();
        this.loadInitialTemplateItems();
        this.initializeValidation();
        this.attachAutocompleteToExistingRows();
        this.attatchEventListnerToDownload();
        this.attatchEventListnerToRevision();
        //('✅ ServiceManager initialized');
    }

    // MODAL MANAGEMENT

    setupModalHandlers() {
        if (this.openModalBtn) {
            this.openModalBtn.addEventListener("click", (e) => {
                const state = this.openModalBtn.dataset.state;

                if (state === "add") {
                    e.preventDefault();
                    this.openModal();
                    return; // <--- important
                }

                if (state === "review") {
                    this.openModalBtn.textContent = "Add Services";
                    this.openModalBtn.dataset.state = "add";
                    return; // <--- THIS fixes your issue
                }
            });
        }


        // Close buttons
        if (this.closeModalBtns) {
            this.closeModalBtns.forEach(btn => {
                btn.addEventListener('click', () => this.closeModal());
            });
        }

        // Click outside to close
        if (this.modal) {
            this.modal.addEventListener('click', (e) => {
                if (e.target === this.modal) {
                    this.closeModal();
                }
            });
        }
    }

    openModal() {
        if (this.modal) {
            this.modal.classList.add('active');
        }
    }

    closeModal() {
        if (this.modal) {
            this.modal.classList.remove('active');
            //('📁 Service modal closed');
        }
    }

    // DROPDOWN HANDLERS

    setupDropdownHandlers() {
        if (this.toggleBtn && this.dropdownMenu) {
            this.toggleBtn.addEventListener('click', (e) => {
                e.stopPropagation();
                this.dropdownMenu.classList.toggle('show');
            });

            document.addEventListener('click', (e) => {
                if (!this.toggleBtn.contains(e.target)) {
                    this.dropdownMenu.classList.remove('show');
                }
            });
        }

        // Level button handlers
        if (this.btnL1) {
            this.btnL1.addEventListener('click', () => this.addLevel1Row());
        }
        if (this.btnL2) {
            this.btnL2.addEventListener('click', () => this.addLevel2Row());
        }
        if (this.btnL3) {
            this.btnL3.addEventListener('click', () => this.addLevel3Row());
        }
    }

    // ========================================
    // TABLE MANAGEMENT
    // ========================================

    setupTableHandlers() {
        // Delete row handler
        this.tableBody.addEventListener('click', (e) => {
            const icon = e.target.closest('.quote-icon-c');
            if (icon && getComputedStyle(icon).visibility !== 'hidden') {
                const tr = icon.closest('tr');
                if (tr) {
                    this.deleteRow(tr);
                }
            }
        });

        // Input handlers for totals
        this.tableBody.addEventListener('input', (e) => {
            const target = e.target;
            if (target.matches('[data-prop="Quantity"], [data-prop="ItemPrice"]')) {
                const row = target.closest('tr');
                this.updateRowTotal(row);
                this.updateGrandTotal();
            }
        });

        // Autocomplete setup for existing rows
        this.attachAutocompleteToAllRows();
    }

    loadInitialTemplateItems() {
        const quoteId = this.getQuoteId();
        if (!quoteId || quoteId === "0") {
            //('📝 No QuoteId found, adding default row');
            this.addLevel1Row();
            return;
        }

        fetch(`/api/TemplateItems/GetItems?quoteId=${quoteId}`)
            .then(response => response.json())
            .then(data => {
                if (!data || data.length === 0) {
                    //('📝 No template items found, adding default row');
                    this.addLevel1Row();
                } else {
                    //(`📦 Loading ${data.length} template items`);
                    this.populateTable(data);
                }
                this.updateAllStates();
            })
            .catch(err => {
                console.error('❌ Error loading template items:', err);
                this.addLevel1Row();
            });
    }

    populateTable(items) {
        this.tableBody.innerHTML = '';

        items.forEach((item, index) => {
            const rowId = item.rowId || item.templateItemId || String(index + 1);
            const tr = this.createRowElement(rowId, false);

            // Fill in values
            tr.querySelector('[data-prop="TemplateItemId"]').value = item.templateItemId || 0;
            tr.querySelector('[data-prop="ServiceName"]').value = item.serviceName || '';
            tr.querySelector('[data-prop="Description"]').value = item.description || '';
            tr.querySelector('[data-prop="Quantity"]').value = item.quantity || 0;
            tr.querySelector('[data-prop="Unit"]').value = item.unit || '';
            tr.querySelector('[data-prop="ItemPrice"]').value = item.itemPrice || 0;
            tr.querySelector('[data-prop="Total"]').value = item.total || 0;

            this.tableBody.appendChild(tr);
            this.attachAutocompleteToRow(tr);
        });

        this.refreshInputNames();
        this.updateAllStates();
    }

    addLevel1Row() {
        const id = this.getNextTopLevelId();
        const newRow = this.createRowElement(id, true);
        this.tableBody.appendChild(newRow);
        this.attachAutocompleteToRow(newRow);
        this.refreshInputNames();
        this.updateAllStates();
        //(`➕ Added Level 1 row: ${id}`);
    }

    addLevel2Row() {
        const last = this.getLastRow();
        if (!last) return;

        const lastLevel = this.getLevelOfId(last.dataset.rowId);
        if (lastLevel < 1) return;

        const parentId = lastLevel === 1 ? last.dataset.rowId : this.getParentOfId(last.dataset.rowId);
        if (!parentId) return;

        const id = this.getNextChildIdForParent(parentId);
        const newRow = this.createRowElement(id, true);
        this.insertRowAfterParent(newRow, parentId);
        this.attachAutocompleteToRow(newRow);
        this.refreshInputNames();
        this.updateAllStates();
        //(`➕ Added Level 2 row: ${id}`);
    }

    addLevel3Row() {
        const last = this.getLastRow();
        if (!last) return;

        const lastLevel = this.getLevelOfId(last.dataset.rowId);
        if (lastLevel < 2) return;

        const parentId = lastLevel === 2 ? last.dataset.rowId : this.getParentOfId(last.dataset.rowId);
        if (!parentId) return;

        const id = this.getNextChildIdForParent(parentId);
        const newRow = this.createRowElement(id, true);
        this.insertRowAfterParent(newRow, parentId);
        this.attachAutocompleteToRow(newRow);
        this.refreshInputNames();
        this.updateAllStates();
        //(`➕ Added Level 3 row: ${id}`);
    }

    createRowElement(id, isNew = true) {
        const tr = document.createElement('tr');
        tr.dataset.rowId = id;

        tr.innerHTML = `
            <td><input type="checkbox" class="radio-style-c"></td>
            <td>
                <span class="visible-row-id-c">${id}</span>
                <input type="hidden" data-prop="TemplateItemId" value="0" />
                <input type="hidden" data-prop="RowId" value="${id}" />
            </td>
            <td>
                <div class="section-input-wrapper-c quote-wrapper-c autocomplete-wrapper-c">
                    <input type="text" class="section-input-c quote-input-c service-input-c"
                           data-prop="ServiceName"
                           value=""
                           autocomplete="off" />
                    <div class="autocomplete-dropdown-c"></div>
                </div>
            </td>
            <td>
                <div class="section-input-wrapper-c quote-wrapper-c autocomplete-wrapper-c">
                    <input type="text" class="section-input-c quote-input-c description-input-c"
                           data-prop="Description"
                           value=""
                           autocomplete="off" />
                    <div class="autocomplete-dropdown-c"></div>
                </div>
            </td>
            <td>
                <div class="section-input-wrapper-c quote-wrapper-c">
                    <input type="number" class="section-input-c quote-input-c" 
                           data-prop="Quantity" min="0" step="1" value="0">
                </div>
            </td>
            <td>
                <div class="section-input-wrapper-c quote-wrapper-c">
                    <input type="text" class="section-input-c quote-input-c" 
                           data-prop="Unit" value="">
                </div>
            </td>
            <td>
                <div class="section-input-wrapper-c quote-wrapper-c">
                    <input type="number" class="section-input-c quote-input-c" 
                           data-prop="ItemPrice" min="0" step="0.01" value="0.00">
                </div>
            </td>
            <td>
                <div class="section-input-wrapper-c quote-wrapper-c">
                    <input type="number" class="section-input-c quote-input-c total-input-c" 
                           data-prop="Total" min="0" step="0.01" value="0.00" readonly>
                </div>
            </td>
            <td>
                <svg class="quote-icon-c" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" 
                     style="cursor:pointer;visibility:hidden;">
                    <path d="M3 6h18v2H3V6zm2 3h14l-1.5 12.5a1 1 0 0 1-1 .5H7a1 1 0 0 1-1-.5L4 9zm5 2v8h2v-8H9zm4 0v8h2v-8h-2zM9 4V2h6v2h5v2H4V4h5z"/>
                </svg>
            </td>
        `;
        this.attachAutocompleteToRow(tr);
        return tr;
    }

    deleteRow(tr) {
        const rowId = tr.dataset.rowId;
        const rows = this.getAllRows();

        if (rows.length <= 1) {
            //('⚠️ Cannot delete last row');
            return;
        }

        // Check if row has children
        const hasChildren = rows.some(r => {
            const rid = r.dataset.rowId;
            return rid.startsWith(rowId + '.') && rid !== rowId;
        });

        if (hasChildren) {
            alert('Cannot delete this row because it has child items. Please delete child items first.');
            //('⚠️ Cannot delete row with children');
            return;
        }

        const parentId = this.getParentOfId(rowId);
        tr.remove();

        this.renumberSiblings(parentId);
        this.refreshInputNames();
        this.updateAllStates();

        //(`🗑️ Deleted row: ${rowId}`);
    }

    // ROW ID MANAGEMENT

    getLevelOfId(id) {
        return id ? id.split('.').length : 0;
    }

    getParentOfId(id) {
        if (!id || !id.includes('.')) return null;
        return id.split('.').slice(0, -1).join('.');
    }

    getNextTopLevelId() {
        const topRows = this.getAllRows().filter(r => this.getLevelOfId(r.dataset.rowId) === 1);
        return String(topRows.length + 1);
    }

    getNextChildIdForParent(parentId) {
        const siblings = this.getAllRows().filter(r => this.getParentOfId(r.dataset.rowId) === parentId);
        return `${parentId}.${siblings.length + 1}`;
    }

    renumberSiblings(parentId) {
        const siblings = this.getAllRows()
            .filter(r => this.getParentOfId(r.dataset.rowId) === parentId)
            .map(r => r.dataset.rowId);

        siblings.forEach((oldId, index) => {
            const newId = parentId ? `${parentId}.${index + 1}` : String(index + 1);
            if (oldId !== newId) {
                this.renameIdAndDescendants(oldId, newId);
            }
        });
    }

    renameIdAndDescendants(oldId, newId) {
        this.getAllRows().forEach(r => {
            const rid = r.dataset.rowId;
            if (rid === oldId || rid.startsWith(oldId + '.')) {
                const suffix = rid.slice(oldId.length);
                const replaced = newId + suffix;
                r.dataset.rowId = replaced;

                const span = r.querySelector('.visible-row-id-c');
                if (span) span.textContent = replaced;

                const hiddenRow = r.querySelector('[data-prop="RowId"]');
                if (hiddenRow) hiddenRow.value = replaced;
            }
        });
    }

    insertRowAfterParent(newRow, parentId) {
        const all = this.getAllRows();
        let insertAfter = null;

        for (let i = all.length - 1; i >= 0; i--) {
            const id = all[i].dataset.rowId;
            if (id === parentId || id.startsWith(parentId + '.')) {
                insertAfter = all[i];
                break;
            }
        }

        if (insertAfter) {
            insertAfter.after(newRow);
        } else {
            this.tableBody.appendChild(newRow);
        }
    }

    // AUTOCOMPLETE FUNCTIONALITY

    attachAutocompleteToAllRows() {
        this.getAllRows().forEach(row => this.attachAutocompleteToRow(row));
    }

    attachAutocompleteToRow(row) {
        const serviceInput = row.querySelector('[data-prop="ServiceName"]');
        const descInput = row.querySelector('[data-prop="Description"]');

        if (serviceInput) {
            this.setupAutocomplete(serviceInput, 'service');
        }
        if (descInput) {
            this.setupAutocomplete(descInput, 'description');
        }
    }

    setupAutocomplete(input, type) {
        const wrapper = input.closest('.autocomplete-wrapper-c');
        if (!wrapper) return;

        const dropdown = wrapper.querySelector('.autocomplete-dropdown-c');
        if (!dropdown) return;

        let debounceTimer;

        input.addEventListener('input', () => {
            clearTimeout(debounceTimer);
            const val = input.value.trim();

            if (val.length < 2) {
                dropdown.innerHTML = '';
                dropdown.classList.remove('show');
                return;
            }

            debounceTimer = setTimeout(() => {
                this.fetchAutocomplete(val, type, dropdown, input);
            }, 300);
        });

        input.addEventListener('focus', () => {
            if (input.value.trim().length >= 2 && dropdown.children.length > 0) {
                dropdown.classList.add('show');
            }
        });

        input.addEventListener('blur', () => {
            setTimeout(() => dropdown.classList.remove('show'), 200);
        });
    }

    fetchAutocomplete(query, type, dropdown, input) {
        const quoteId = this.getQuoteId();
        const endpoint = type === 'service'
            ? `/api/Quote/SearchServices?query=${encodeURIComponent(query)}&quoteId=${quoteId}`
            : `/api/Quote/SearchDescriptions?query=${encodeURIComponent(query)}&quoteId=${quoteId}`;

        fetch(endpoint)
            .then(res => res.json())
            .then(data => {
                dropdown.innerHTML = '';

                if (!data || data.length === 0) {
                    dropdown.classList.remove('show');
                    return;
                }

                data.forEach(item => {
                    const div = document.createElement('div');
                    div.className = 'autocomplete-item-c';
                    div.textContent = item;

                    div.addEventListener('click', () => {
                        input.value = div.textContent;
                        dropdown.classList.remove('show');
                    });

                    dropdown.appendChild(div);
                });

                dropdown.classList.add('show');
            })
            .catch(err => {
                console.error(`❌ Autocomplete error (${type}):`, err);
                dropdown.classList.remove('show');
            });
    }

    // CALCULATIONS

    updateRowTotal(row) {
        if (!row) return;

        const qtyInput = row.querySelector('[data-prop="Quantity"]');
        const priceInput = row.querySelector('[data-prop="ItemPrice"]');
        const totalInput = row.querySelector('[data-prop="Total"]');

        if (!qtyInput || !priceInput || !totalInput) return;

        const qty = parseFloat(qtyInput.value) || 0;
        const price = parseFloat(priceInput.value) || 0;
        const total = qty * price;

        totalInput.value = total.toFixed(2);
    }

    updateGrandTotal() {
        const totalInputs = this.tableBody.querySelectorAll('[data-prop="Total"]');
        let grandTotal = 0;

        totalInputs.forEach(input => {
            grandTotal += parseFloat(input.value) || 0;
        });

        const grandTotalDisplay = document.querySelector('.grand-total-value-c');
        if (grandTotalDisplay) {
            const currency = this.getCurrencySymbol();
            grandTotalDisplay.textContent = `${currency}${grandTotal.toFixed(2)}`;
        }

        //(`💰 Grand Total: ${grandTotal.toFixed(2)}`);
    }

    getCurrencySymbol() {
        const currencyInput = document.getElementById('currencyInput');
        const locale = currencyInput ? currencyInput.value : 'en-GB';
        return locale === 'en-GB' ? '£' : '$';
    }

    // STATE MANAGEMENT

    updateAllStates() {
        this.updateButtonStates();
        this.updateDeleteIconsVisibility();
        this.updateRowBackgroundColors();
        this.updateGrandTotal();
    }

    updateButtonStates() {
        const last = this.getLastRow();
        if (!last) {
            this.disableButton(this.btnL1);
            this.disableButton(this.btnL2);
            this.disableButton(this.btnL3);
            return;
        }

        const lastLevel = this.getLevelOfId(last.dataset.rowId);

        this.enableButton(this.btnL1);

        if (lastLevel >= 1) {
            this.enableButton(this.btnL2);
        } else {
            this.disableButton(this.btnL2);
        }

        if (lastLevel >= 2) {
            this.enableButton(this.btnL3);
        } else {
            this.disableButton(this.btnL3);
        }
    }

    enableButton(btn) {
        if (!btn) return;

        // Find the SVG circle inside the button
        const circle = btn.querySelector('svg circle');
        if (circle) {
            circle.setAttribute('fill', this.ENABLED_COLOR);
            circle.setAttribute('stroke', this.ENABLED_COLOR);
        }

        btn.disabled = false;
        btn.style.cursor = 'pointer';
        btn.style.opacity = '1';
    }

    disableButton(btn) {
        if (!btn) return;

        // Find the SVG circle inside the button
        const circle = btn.querySelector('svg circle');
        if (circle) {
            circle.setAttribute('fill', this.DISABLED_COLOR);
            circle.setAttribute('stroke', this.DISABLED_COLOR);
        }

        btn.disabled = true;
        btn.style.cursor = 'not-allowed';
        btn.style.opacity = '0.6';
    }

    updateDeleteIconsVisibility() {
        const all = this.getAllRows();
        const showIcons = all.length > 1;

        all.forEach(r => {
            const rowId = r.dataset.rowId;
            const hasChildren = all.some(other => {
                const otherId = other.dataset.rowId;
                return otherId.startsWith(rowId + '.') && otherId !== rowId;
            });

            const icon = r.querySelector('.quote-icon-c');
            if (icon) {
                if (hasChildren) {
                    icon.style.visibility = 'hidden';
                } else {
                    icon.style.visibility = showIcons ? 'visible' : 'hidden';
                }
            }
        });
    }

    updateRowBackgroundColors() {
        this.getAllRows().forEach(row => {
            const level = this.getLevelOfId(row.dataset.rowId);
            row.style.backgroundColor =
                level === 1 ? '#f9f9f9' :
                    level === 2 ? '#ffffff' :
                        '#f5f5f5';
        });
    }

    // ========================================
    // FORM SUBMISSION & VALIDATION
    // ========================================

    initializeValidation() {
        if (this.createQuoteBtn) {
            this.createQuoteBtn.addEventListener('click', (e) => {
                e.preventDefault();
                this.validateAndSubmit();
                
            });
        }
    }

    validateAndSubmit() {
        const errors = this.validateForm();

        if (errors.length > 0) {
            alert('Please fix the following errors:\n\n' + errors.join('\n'));
            return;
        }

        this.refreshInputNames();
        this.addServices();
        this.closeModal();
    }

    validateForm() {
        const errors = [];
        const rows = this.getAllRows();

        if (rows.length === 0) {
            errors.push('- At least one service row is required');
        }

        rows.forEach((row, idx) => {
            const serviceName = row.querySelector('[data-prop="ServiceName"]').value.trim();
            const quantity = row.querySelector('[data-prop="Quantity"]').value;
            const price = row.querySelector('[data-prop="ItemPrice"]').value;

            if (!serviceName) {
                errors.push(`- Row ${idx + 1}: Service name is required`);
            }
            if (!quantity || parseFloat(quantity) <= 0) {
                errors.push(`- Row ${idx + 1}: Valid quantity is required`);
            }
            if (!price || parseFloat(price) < 0) {
                errors.push(`- Row ${idx + 1}: Valid price is required`);
            }
        });

        return errors;
    }

    refreshInputNames() {
        const rows = this.getAllRows();

        rows.forEach((row, index) => {
            row.querySelectorAll('input[data-prop]').forEach(input => {
                const prop = input.dataset.prop;
                input.name = `TemplateItems[${index}].${prop}`;
            });
        });
    }

    addServices() {
        //("📤 Submitting quote via AJAX...");

        const rows = this.getAllRows(); 
        const metafields = this.MetafieldAnswers();
        var downloadBtn = document.querySelector('#downloadBtn');
        // Map table rows to TemplateItem objects
        const items = rows.map(row => {
            const rowObj = {
                RowId: row.getAttribute('data-row-id'),
                TemplateItemId: 0, // or pull from hidden input if needed
                TemplateId: parseInt(document.getElementById("form-TemplateId").value) || 0,
                TemplateVersion: parseInt(document.getElementById("form-TemplateVersion").value) || 0
            };

            row.querySelectorAll('input[data-prop]').forEach(input => {
                const prop = input.getAttribute('data-prop');
                let value = input.value;

                // Convert number fields properly
                if (input.type === 'number') {
                    value = value ? parseFloat(value) : 0;
                }

                rowObj[prop] = value;
            });

            return rowObj;
        });

        // Build the UserAnswerVM object directly
        const model = {
            TemplateId: parseInt(document.querySelector('input[name="TemplateId"]').value) || null,
            TemplateVersion: parseInt(document.querySelector('input[name="TemplateVersion"]').value) || null,
            RecStatusId: parseInt(document.querySelector('input[name="QuoteId"]').value) || null,
            CustomerId: parseInt(document.getElementById("form-CustomerId").value) || null,
            Items: items,
            Metafields: metafields
        };
        // Anti-forgery token
        const token = document.querySelector("input[name='__RequestVerificationToken']").value;

        // Send currency as query string
        const currency = document.getElementById("currencyInput").value || "en-GB";
        const url = `/api/TemplateItems/CreateQuote?currency=${encodeURIComponent(currency)}`;

        fetch(url, {
            method: "POST",
            headers: {
                "Content-Type": "application/json"
            },
            body: JSON.stringify(model), // send the model directly
             keepalive: true
        })
            .then(res => res.json())
            .then(result => {
                //("Server Response:", result);
           
                    //("✅ Quote created successfully");
                    downloadBtn.style.background = ""; // or set your normal background color
                    downloadBtn.style.color = "";      // or set your normal text color
                    downloadBtn.style.cursor = "pointer";
                    downloadBtn.disabled = false;
                    downloadBtn.title = "Download";   // or whatever tooltip you want

                    ['downloadBtn', 'createRevisionBtn'].forEach(id => document.getElementById(id).style.display = 'flex');

               
            })
            .catch(err => console.error("❌ AJAX Error:", err));
    }
    MetafieldAnswers() {

        // 1. Find "Additional Information" section
        const sections = document.querySelectorAll('.item-c');
        let targetSection = null;

        sections.forEach(section => {
            const titleEl = section.querySelector('.dropdown-header-text-c');
            if (titleEl && titleEl.textContent.trim() === 'Additional Information') {
                targetSection = section;
            }
        });

        if (!targetSection) {
            console.warn("Additional Information section not found");
            return [];
        }

        // 2. Get all metafield wrappers
        const metafieldWrappers = targetSection.querySelectorAll('.question-bottom-margins-c');

        return Array.from(metafieldWrappers).map(wrapper => {

            const metafieldId = parseInt(wrapper.getAttribute('data-metafield-id'));

            // ---------------------------
            // TEXT METAFIELD
            // ---------------------------
            const textInput = wrapper.querySelector('.metafield-input');

            if (textInput) {
                return {
                    MetafieldId: metafieldId,
                    Name: textInput.getAttribute('data-metafield-name'),
                    Value: textInput.value ?? '',
                    PID: parseInt(
                        wrapper.querySelector('input[type="hidden"]')?.value || 0
                    ),
                    TemplateId: parseInt(document.getElementById("form-TemplateId")?.value || 0),
                    TemplateVersion: parseInt(document.getElementById("form-TemplateVersion")?.value || 0)
                };
            }

            // ---------------------------
            // TABLE METAFIELD
            // ---------------------------
            const table = wrapper.querySelector('[id^="table-rows-"]');

            if (table) {
                const rows = Array.from(table.querySelectorAll('.selects-wrapper-c'));

                const tableData = rows
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
                    .filter(Boolean);

                return {
                    MetafieldId: metafieldId,
                    Name: 'table',
                    Value: JSON.stringify(tableData),
                    PID: 0,
                    TemplateId: parseInt(document.getElementById("form-TemplateId")?.value || 0),
                    TemplateVersion: parseInt(document.getElementById("form-TemplateVersion")?.value || 0)
                };
            }

            // ---------------------------
            // FALLBACK (should never hit)
            // ---------------------------
            return {
                MetafieldId: metafieldId,
                Name: '',
                Value: '',
                PID: 0,
                TemplateId: parseInt(document.getElementById("form-TemplateId")?.value || 0),
                TemplateVersion: parseInt(document.getElementById("form-TemplateVersion")?.value || 0)
            };
        });
    }





    // UTILITY METHODS

    getAllRows() {
        return Array.from(this.tableBody.querySelectorAll('tr'));
    }

    getLastRow() {
        const rows = this.getAllRows();
        return rows.length > 0 ? rows[rows.length - 1] : null;
    }

    getQuoteId() {
        const input = document.querySelector('input[name="QuoteId"]');
        return input ? input.value : "0";
    }
    checkDownloadBtnStatus() {
        var quoteId = document.querySelector('input[name="QuoteId"]').value;
        var downloadBtn = document.querySelector('#downloadBtn');

        fetch(`/api/TemplateItems/CheckTemplateItems?quoteId=${quoteId}`)
            .then(response => response.json())
            .then(data => {
                if (!data.exists) {
                    // Disable button visually and functionally
                    downloadBtn.style.background = "rgba(200,200,200,0.6)";
                    downloadBtn.style.color = "rgba(120,120,120,1)";
                    downloadBtn.style.cursor = "not-allowed";
                    downloadBtn.disabled = true;
                    downloadBtn.title = "No template items found";
                } else {
                    // Attach click event to download
                    downloadBtn.addEventListener('click', function () {
                        window.location.href = `/api/TemplateItems/DownloadPDF/${quoteId}`;
                    });
                }
            })
            .catch(err => console.error("Error checking template items:", err));
    }

    // Autocomplete functionality
    attachAutocompleteToRow(tr) {
        tr.querySelectorAll('.service-input-c').forEach(input =>
            this.attachAutocomplete(input, 'ServiceName')
        );
        tr.querySelectorAll('.description-input-c').forEach(input =>
            this.attachAutocomplete(input, 'Description')
        );
    }

    attachAutocompleteToExistingRows() {
        const serviceInputs = document.querySelectorAll('.service-input-c');
        //("Number of .service-input-c elements:", serviceInputs.length);

        document.querySelectorAll('.service-input-c').forEach(input =>
            this.attachAutocomplete(input, 'ServiceName')
        );
        document.querySelectorAll('.description-input-c').forEach(input =>
            this.attachAutocomplete(input, 'Description')
        );
    }

    attachAutocomplete(inputEl, type) {
        const dropdown = inputEl.closest('.autocomplete-wrapper-c').querySelector('.autocomplete-dropdown-c');


        inputEl.addEventListener('input', () => {
            const query = inputEl.value.trim(); 
            if (!query) {
                dropdown.style.display = 'none';

                return;
            }
       
            const recStatusId = parseInt(document.getElementById("RecStatusId").value) || 0;
            const customerId = parseInt(document.getElementById("form-CustomerId").value) || 0;

            fetch(`/api/TemplateItems/GetTemplateItemSuggestions?type=${type}&query=${encodeURIComponent(query)}&recStatusId=${recStatusId}&customerId=${customerId}`)
                .then(res => res.json())
                .then(data => {
                    dropdown.innerHTML = '';
                    if (!data || data.length === 0) {
                        dropdown.style.display = 'none';
                        return;
                    }

                    data.forEach(item => {
                        const div = document.createElement('div');
                        div.className = 'dropdown-item-c';
                        div.textContent = item;
                        div.addEventListener('click', () => {
                            inputEl.value = item;
                            dropdown.style.display = 'none';
                        });
                        dropdown.appendChild(div);
                    });

                    const rect = inputEl.getBoundingClientRect();
                    dropdown.style.top = rect.bottom + window.scrollY + 'px';
                    dropdown.style.left = rect.left + window.scrollX + 'px';
                    dropdown.style.width = rect.width + 'px';
                    dropdown.style.display = 'block';
                })
                .catch(err => console.error(err));
        });

        document.addEventListener('click', (e) => {
            if (!inputEl.contains(e.target) && !dropdown.contains(e.target)) {
                dropdown.style.display = 'none';
            }
        });

        window.addEventListener('scroll', () => dropdown.style.display = 'none');
    }
    attatchEventListnerToDownload() {
  
        var downloadBtn = document.querySelector('#downloadBtn');
        downloadBtn.addEventListener('click', () => {
            var quoteId = document.querySelector('input[name="QuoteId"]').value;
            console.log("rec in download: ", document.querySelector('input[name="QuoteId"]').value)
            fetch(`/api/TemplateItems/DownloadPDF/${quoteId}`)
                .then(async response => {
                    // Try to parse as JSON (in case of error)
                    try {
                        const data = await response.json();
                        if (!data.success) {
                            alert(data.message); // Pop-up
                            return;
                        }
                    } catch {
                        // If not JSON, then it's a file response → force download
                        window.location.href = `/api/TemplateItems/DownloadPDF/${quoteId}`;
                    }
                })
                .catch(() => {
                    alert("An unexpected error occurred while downloading the file.");
                });
        });
    }
    attatchEventListnerToRevision() {
        document.getElementById("createRevisionBtn").addEventListener("click", async () => {
            const templateId = document.querySelector('input[name="TemplateId"]').value;
            const templateVersion = document.querySelector('input[name="TemplateVersion"]').value;
            const answers = this.collectAllAnswers(); // ✅ now works

            const customerId = document.getElementById('form-CustomerId').value;
            console.log('Revision payload:', {
                TemplateId: templateId,
                TemplateVersion: templateVersion,
                Answers: answers,
                CustomerId: customerId
            });
            if (!answers.length) {
                alert("Please select at least one answer before creating a revision.");
                return;
            }
            try {
                const response = await this.apiService.makeRequest(
                    '/api/Quote/CreateAndSaveQuote',
                    'POST',
                    {
                        TemplateId: templateId,
                        TemplateVersion: templateVersion,
                        Answers: answers,
                        CustomerId: customerId
                    }
                );

                if (response.success) {
                    const data = response; 


                    var downloadBtn = document.querySelector('#downloadBtn');
                    // Disable button visually and functionally
                    downloadBtn.style.background = "rgba(200,200,200,0.6)";
                    downloadBtn.style.color = "rgba(120,120,120,1)";
                    downloadBtn.style.cursor = "not-allowed";
                    downloadBtn.disabled = true;
                    downloadBtn.title = "No template items found";
                    // Update hidden inputs
                    const recStatusInput = document.querySelector('input[name="RecStatusId"]');
                    const quoteIdInput = document.querySelector('input[name="QuoteId"]');

                    if (recStatusInput) {
                        console.log("recStatusInput: ", data.recStatusId);
                        recStatusInput.value = data.recStatusId;
                        quoteIdInput.value = data.recStatusId;
                    } else {
                        console.error("❌ Revision creation request failed!");
                    }
                }
            } catch (error) {
                console.error("⚠️ Error:", error);
            }
        });
    }


    collectAllAnswers() {
        const answers = [];
        const seenQuestions = new Set();

        // Helper to add answer safely
        const addAnswer = (questionId, selectedOptionId = null, answerText = null, quantity = 1) => {
            if (!questionId || seenQuestions.has(questionId)) return;
            seenQuestions.add(questionId);

            answers.push({
                QuestionId: questionId,
                SelectedOptionId: selectedOptionId,
                AnswerText: answerText,
                Quantity: quantity
            });
        };

        // 1. Checkboxes
        document.querySelectorAll('input[type=checkbox].single-select-c:checked').forEach(cb => {
            const questionId = parseInt(cb.dataset.questionid);
            const selectedOptionId = parseInt(cb.value);
            addAnswer(questionId, selectedOptionId, null, 1);
        });

        // 2. Radios
        document.querySelectorAll('input[type=radio]:checked').forEach(radio => {
            const questionId = parseInt(radio.dataset.questionid);
            const selectedOptionId = parseInt(radio.value);
            addAnswer(questionId, selectedOptionId, null, 1);
        });

        // 3. Select lists (non-table)
        document.querySelectorAll('select.section-input-c.selectt-c, select.conditional-select').forEach(select => {
            if (select.closest('.selects-wrapper-c')) return; // skip table rows
            if (!select.value) return;

            const questionId = parseInt(select.selectedOptions[0]?.dataset.questionid || select.dataset.questionid);
            const selectedOptionId = parseInt(select.value);
            addAnswer(questionId, selectedOptionId, null, 1);
        });

        // 4. Table rows
        document.querySelectorAll('.selects-wrapper-c').forEach(row => {
            const selectEl = row.querySelector('select');
            if (!selectEl || !selectEl.value) return;

            const questionId = parseInt(selectEl.selectedOptions[0]?.dataset.questionid || selectEl.dataset.questionid);
            const selectedOptionId = parseInt(selectEl.value);

            const quantityEl = row.querySelector('input[type=number]');
            const quantity = quantityEl ? parseInt(quantityEl.value) || 1 : 1;

            addAnswer(questionId, selectedOptionId, quantity.toString(), quantity);
        });

        // 5. Text inputs
        document.querySelectorAll('input[type=text].section-input-c').forEach(input => {
            if (!input.value || !input.value.trim()) return;

            const questionId = parseInt(input.dataset.questionid);
            addAnswer(questionId, null, input.value.trim(), 1);
        });

        return answers;
    }

}
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
// INITIALIZE ON DOM LOAD

document.addEventListener('DOMContentLoaded', () => {
    window.serviceManager = new ServiceManager();
});

