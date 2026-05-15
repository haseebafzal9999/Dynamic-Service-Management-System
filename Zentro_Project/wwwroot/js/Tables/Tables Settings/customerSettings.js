var settings = {
    tableNameId: ".view-window",
    tableHeader: [
        { name: "name", value: "Name" },
        { name: "contact", value: "Contact Details" },
        { name: "address", value: "Address" }
    ],
    cols: [
        {
            colName: "name",
            fieldType: "text",
            editable: false,
            html: (content) => {
                const fullName = [content.firstName, content.lastName].filter(Boolean).join(" ");
                return `<td><div data-name="name">${escapeHtml(fullName)}</div></td>`;
            }
        },
        {
            colName: "contact",
            fieldType: "text",
            editable: false,
            html: (content) => {
                return `<td>
                    <div data-name="contact-details" data-editable="false" style="min-width:120px; max-width:220px;">
                        <p style="margin-bottom:5px;"><b>Email:</b> ${escapeHtml(content.email)}</p>
                        <p style="margin-bottom:5px;"><b>Phone:</b> ${escapeHtml(content.phoneNumber)}</p>
                    </div>
                </td>`;
            }
        },
        {
            colName: "address",
            fieldType: "text",
            editable: false,
            html: (content) => {
                return `<td>
                    <div data-name="address-details" data-editable="false" style="min-width:300px; max-width:450px;">
                        <div>${escapeHtml(content.address)}, ${escapeHtml(content.appartmentSuite)}, ${escapeHtml(content.city)}, ${escapeHtml(content.postalCode)}, ${escapeHtml(content.country)}</div>
                    </div>
                </td>`;
            }
        }
    ],
    filterTypes: {
        filters: [
            {
                position: 1,
                name: "Status",
                listname: "statusLists",
                url: "/api/Customer/CustomerFilterLists", // ✅ make sure it points here
                queryName: "status"
            }
          
        ],
        url: "/api/Customer/CustomerFilterLists"
    },
   
    search: {
        apiUrl: "/api/Customer/FilterCustomerIndex"
    },
    checkboxes: false,
    editable: false,
    links: {
        available: true,
        baseUrl: ""
    }
};

// Utility function for escaping HTML
function escapeHtml(unsafe) {
    if (unsafe === null || unsafe === undefined) return "";
    return String(unsafe)
        .replace(/&/g, "&amp;")
        .replace(/</g, "&lt;")
        .replace(/>/g, "&gt;")
        .replace(/"/g, "&quot;")
        .replace(/'/g, "&#039;");
}

