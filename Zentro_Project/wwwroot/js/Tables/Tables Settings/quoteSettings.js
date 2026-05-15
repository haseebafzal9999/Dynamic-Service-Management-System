var settings = {
    tableNameId: ".view-window",
    tableHeader: [
        { name: "QuoteNumber", value: "Quote Number" },
        { name: "Name", value: "Name" },
        { name: "ContactInfo", value: "Contact Info" },
        { name: "TemplateName", value: "Template Name" },
        { name: "CostPrice", value: "Cost Price" },
        { name: "SellPrice", value: "Sell Price" },
        { name: "Status", value: "Status" }
    ],

    cols: [
        { colName: "quoteNumber", fieldType: "text", editable: false },
        { colName: "name", fieldType: "text", editable: false },


        {
            colName: "ContactInfo",
            fieldType: "text",
            editable: false,
            html: (row) => {
                return `<td>
                    <div>
                        <div><b>Email:</b> ${escapeHtml(row.email ?? "")}</div>
                        <div><b>Phone:</b> ${escapeHtml(row.phoneNumber ?? "")}</div>
                    </div>
                </td>`;
            }
        },

        { colName: "TemplateName", fieldType: "text", editable: false, html: (row) => `<td>${escapeHtml(row.templateName ?? "")}</td>` },

        {
            colName: "CostPrice",
            fieldType: "text",
            editable: false,
            html: (row) => {
                return `<td>${formatCurrencyWithSymbols(row.costPrice)}</td>`;
            }
        },

        {
            colName: "SellPrice",
            fieldType: "text",
            editable: false,
            html: (row) => {
                return `<td>${formatCurrencyWithSymbols(row.sellPrice)}</td>`;
            }
        },

        {
            colName: "Status",
            fieldType: "text",
            editable: false,
            html: (row) => `<td style="cursor: pointer;">
                    <div style="display: flex; justify-content: center; width:90px;" class="${getClassStatus(row.status ?? "")}">
                        <p class="status-text">${escapeHtml(row.status ?? "")}</p>
                    </div>
                </td>`
        }
    ],
    filterTypes: {
        filters: [
            {
                position: 1,
                name: "Status",
                listname: "statusLists",
                url: "/api/Quote/QuoteFilterLists", // ? make sure it points here
                queryName: "status"
            }
            
        ],
        url: "/api/quote/QuoteFilterLists"
    },

    search: {
        apiUrl: "/api/quote/FilterQuoteIndex"
    },

    checkboxes: false,
    editable: false,

    links: {
        available: true,
        baseUrl: "/page/quote/"
    }
};

// Utility functions
function escapeHtml(unsafe) {
    if (unsafe === null || unsafe === undefined) return "";
    return String(unsafe)
        .replace(/&/g, "&amp;")
        .replace(/</g, "&lt;")
        .replace(/>/g, "&gt;")
        .replace(/"/g, "&quot;")
        .replace(/'/g, "&#039;");
}

function formatCurrencyWithSymbols(amount) {
    if (!amount || isNaN(amount)) amount = "0.00";

    const currency = localStorage.getItem('currency') || 'GBP';
    const currencyIdentity = localStorage.getItem('currencyIdentity') || 'en-GB';

    return new Intl.NumberFormat(currencyIdentity, {
        style: "currency",
        currency: currency
    }).format(amount);
}


function getClassStatus(state) {
    switch (state) {
        case "Requested":
            return "status-badge-red";
        case "Authorised":
            return "status-badge";
        case "Sent":
            return "status-badge-amber";
    }
}