var settings = {
    tableNameId: ".view-window",
    tableHeader: [
        { "name": "partNo", "value": "Part No" },
        { "name": "name", "value": "Name" },
        { "name": "description", "value": "Description" },
        { "name": "sellPrice", "value": "Sell Price" },
        {"name":"costPrice","value":"Cost Price"},
        { "name": "supplier", "value": "Supplier" }
    ],
    cols: [

        {
            colName: "partNo",
            fieldType: "text",
            editable: false,
            html: (contentArray, filterName) => {
                // preserve existing pattern (max width, editable div)
                return `<td style="width:60px"><div data-name="partNo" data-editable="true">${escapeHtml(filterName)}</div></td>`;
            }
        },
        {
            colName: "name",
            fieldType: "text",
            editable: false,
            html: (contentArray, filterName) => {
                // preserve existing pattern (max width, editable div)
                return `<td style="width:150px"><div data-name="name" data-editable="true">${escapeHtml(filterName)}</div></td>`;
            }
        },
    
        {
            colName: "description",
            fieldType: "text",
            editable: false,
            html: (contentArray, filterName) => {
                // preserve existing pattern (max width, editable div)
                return `<td style="width:300px"><div data-name="description" data-editable="true">${escapeHtml(filterName)}</div></td>`;
            }
        },
        {
            colName: "sellPrice",
            fieldType: "text",
            editable: false,
            html: (contentArray, filterName) => {
                // right aligned price column with formatting
                return `<td style="text-align:right; width:25px;"><div data-name="sellPrice">${formatCurrency(filterName)}</div></td>`;
            }
        },
        {
            colName: "costPrice",
            fieldType: "text",
            editable: false,
            html: (contentArray, filterName) => {
                // right aligned price column with formatting
                return `<td style="text-align:right; width:25px;"><div data-name="costPrice">${formatCurrency(filterName)}</div></td>`;
            }
        },
        {
            colName: "supplier",
            fieldType: "text",
            editable: false,
            html: (contentArray, filterName) => {
                // right aligned price column with formatting
                return `<td style="text-align:right; width:150px;"><div data-name="supplier">${filterName}</div></td>`;
            }
        }

    ],
    filterTypes: {
        filters: [
            {
                position: 1,
                name: "Supplier",
                listname: "supplierLists",
                url: "/api/material/FilterMaterialIndex",
                queryName: "Supplier"
            }
      
        ],
        url: "/api/material/MaterialFilterLists"
    },
    // search endpoint (same pattern as customer)
    search: {
        apiUrl: "/api/material/FilterMaterialIndex",
    },
    checkboxes: false,
    editable: false,
    links: {
        available: true,
        baseUrl: ""
    }
};



const formatCurrency = (amount) => {
    if (!amount || isNaN(amount)) return "0.00";

    const currency = localStorage.getItem('currency') || 'GBP';
    const currencyIdentity = localStorage.getItem('currencyIdentity') || 'en-GB';

    return new Intl.NumberFormat(currencyIdentity, {
        style: "currency",
        currency: currency
    }).format(amount);
};

function escapeHtml(unsafe) {
    if (unsafe === null || unsafe === undefined) return "";
    return String(unsafe)
        .replace(/&/g, "&amp;")
        .replace(/</g, "&lt;")
        .replace(/>/g, "&gt;")
        .replace(/"/g, "&quot;")
        .replace(/'/g, "&#039;");
}
