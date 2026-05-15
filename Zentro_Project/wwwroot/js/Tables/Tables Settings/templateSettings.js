var settings = {
    tableNameId: ".view-window",
    tableHeader: [
        {
            "name": "templateName",
            "value": "Name"
        },
      
        {
            "name": "description",
            "value": "Description"
        }
        ,
        {
            "name": "createdAt",
            "value": "Created At"
        },

        {
            "name": "isActive",
            "value": "Status"
        }
    ],
    cols: [
        {
            colName: "templateName",
            fieldType: "text",
            editable: false,
            html: (contentArray, filterName) => {
                return `<td style="min-width:50px; max-width:100px"><div data-name="name" data-editable="true">${filterName}</div></td>`

            },
        },
        {
            colName: "description",
            fieldType: "text",
            editable: false,
            html: (contentArray, filterName) => {
                return `<td style="min-width:200px; max-width:300px"><div data-name="name" data-editable="true">${filterName}</div></td>`
            
            },
        },

        {
            colName: "createdAt",
            fieldType: "datetime",
            editable: false,
            html: (contentArray) => {
                const date = new Date(contentArray.createdAt);
                const formatted = date.toLocaleDateString('en-US', { month: 'short', day: 'numeric', year: 'numeric' });
                return `<td>${formatted}</td>`;
            }
        },


        {
            colName: "isActive",
            fieldType: "text",
            editable: false,
            html: (contentArray) => {
                const status = contentArray.isActive ? "Active" : "InActive";
                return `<td style="cursor: pointer;">
                    <div style="display: flex; justify-content: center; width:90px;" class="${getClassStatus(status)}">
                        <p class="status-text">${status}</p>
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
            },
            //{
            //    position: 1,
            //    name: "Created By",
            //    listname: "createdByLists",  // matches JSON returned by TemplateFilterLists
            //    url: "/api/Template/TemplateFilterLists",
            //    queryName: "createdBy"       // will send createdBy=value to backend
            //},
            //{
            //    position: 2,
            //    name: "Version",
            //    listname: "versionLists",     // matches JSON returned by TemplateFilterLists
            //    url: "/api/Template/TemplateFilterLists",
            //    queryName: "version"          // can send version=value to backend if you extend the filter
            //}
        ],
        url: "/api/Template/TemplateFilterLists" // main filter list URL
    },

    //edit: "editProductItems",
    search: {
        apiUrl: "/api/Template/FilterTemplateIndex",
    },
    checkboxes: false,
    editable: false,
    links: {
        available: true,
        baseUrl: ""
    }
}

function getClassStatus(state) {
    switch (state) {
        case "InActive":
            return "status-badge-red";
        case "Active":
            return "status-badge";
    }
}
