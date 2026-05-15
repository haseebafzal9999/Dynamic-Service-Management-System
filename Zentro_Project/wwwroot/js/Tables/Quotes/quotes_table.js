class quotesTable {
    constructor(settingsPram = settings) {
        this.table;
        this.selectBoxesProducs;
        this.settings = settingsPram;
        this.quoteList();
    }

    fetchData(url, additionalCallback) {
        var self = this;
        $.ajax({
            url: url,
            type: 'GET',
            contentType: 'application/json',
            success: function (results, status, jqXHR) {
                if (additionalCallback) {
                    additionalCallback(results);
                };
            },
            error: function (error) {
                console.log(error);
            }
        });
    }
    quoteList() {
        var self = this;
        const url = '/api/Quote/QuoteTable';
        function successCallback(results) {
            if (results.length == 0) {
                $('[data-norecords]').attr('style', 'display:block !important');
            } else {
                $('.innerBottomContainer').removeClass('hidden');
            }

            $('.tableCount span').text(`(${results.length})`);

            const formattedResults = results.map(item => ({
                ...item,
                id: item.id
                //link: `/page/quote/${item.id}`,
            }));


            self.table = new tableClass(formattedResults, self.settings, formattedResults, "", ".container");
            self.table.hideShowFilterSearch();

            if (self.settings.checkboxes) {
                self.selectBoxesProducts = new checkBox(self.settings.tableHeader, '#table input', '');
            }
        };

        self.fetchData(url, successCallback);
    }
}


