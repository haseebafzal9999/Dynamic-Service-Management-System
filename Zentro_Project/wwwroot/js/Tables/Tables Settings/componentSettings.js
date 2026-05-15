
var settings = {
    tableNameId: ".view-window",
    tableHeader: [
        { "name": "partNo", "value": "Part No" },
        { "name": "name", "value": "Name" },
        { "name": "description", "value": "Description" },
        { "name": "buildCost", "value": "Build Cost" },
        { "name": "sellPrice", "value": "Sell Price" },
        { "name": "supplier", "value": "Supplier" },
        { "name": "materialComponents", "value": "Materials" }
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
            colName: "buildCost",
            fieldType: "text",
            editable: false,
            html: (contentArray, filterName) => {
                // right aligned build cost column with formatting
                return `<td style="text-align:right;width:20px; max-width:30px;"><div data-name="buildCost">${formatCurrency(filterName)}</div></td>`;
            }
        },
        {
            colName: "sellPrice",
            fieldType: "text",
            editable: false,
            html: (contentArray, filterName) => {
                // right aligned price column with formatting
                return `<td style="text-align:right; width:20px;"><div data-name="sellPrice">${formatCurrency(filterName)}</div></td>`;
            }
        },
        {
            colName: "supplier",
            fieldType: "text",
            editable: false,
            html: (contentArray, filterName) => {
                // right aligned price column with formatting
                return `<td style="width:150px;"><div data-name="supplier">${filterName}</div></td>`;
            }
        },

        {
            colName: "materials",
            fieldType: "list",
            editable: false,
            html: (contentArray, materials) => {
                if (!Array.isArray(materials) || materials.length === 0) return "<td></td>";

                // Show first 2 materials
                const visible = materials.slice(0, 3);
                const extraCount = materials.length - visible.length;

                const display = visible.map(escapeHtml).join(", ") + (extraCount > 0 ? `, ... +${extraCount} more` : "");
                const title = escapeHtml(materials.join(", ")); // full list on hover

                return `<td style="width:250px; white-space:nowrap; overflow:hidden; text-overflow:ellipsis;" title="${title}">
                    <div data-name="materialComponents">${display}</div>
                </td>`;
            }
        }

    ],
    filterTypes: {
        filters: [
            {
                position: 1,
                name: "Supplier",
                listname: "supplierLists",
                url: "/api/component/FilterComponentIndex",
                queryName: "Supplier"
            }
          
        ],
        url: "/api/component/ComponentFilterLists"
    },

    // search endpoint (same pattern as material)
    search: {
        apiUrl: "/api/component/FilterComponentIndex",
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
