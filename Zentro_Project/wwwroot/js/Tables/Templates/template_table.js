class templateTable {
    constructor(settingsPram = settings) {
        this.table;
        this.selectBoxesProducts;
        this.settings = settingsPram;
        this.templateList();
        this.events();
    }

    fetchData(url, additionalCallback) {
        var self = this;
        $.ajax({
            url: url,
            type: 'GET',
            contentType: 'application/json',
            success: function (results) {
                if (additionalCallback) additionalCallback(results);
            },
            error: function (error) {
                console.log(error);
            }
        });
    }

    templateList() {
        var self = this;
        const url = '/api/Template/ListAll';

        function successCallback(results) {
            results = results.map(item => ({
                ...item,
                id: item.templateId,
                link: `/Home/TemplateDetail/${item.templateId}?tempVersionId=${item.latestTempVersionId || 0}&isNewTemplate=false`
            }));

            if (results.length === 0) {
                $('[data-norecords]').attr('style', 'display:block!important');
            } else {
                $('.innerBottomContainer').removeClass('hidden');
            }

            $('.tableCount span').text(`(${results.length})`);

            self.table = new tableClass(results, self.settings, results, "", ".container");
            self.table.hideShowFilterSearch();

            if (self.settings.checkboxes) {
                self.selectBoxesProducts = new checkBox(self.settings.tableHeader, '#table input', '');
            }
        }

        self.fetchData(url, successCallback);
    }

    events() {
        var self = this;
        $('[data-templatebtn]').off('click').on('click', (e) => {
            self.createUpdateTemplate(e);
        });

        $(document).on('click', '#table tbody tr', function (e) {
            const templateId = $(this).attr('data-itemid');
            const tempVersionId = $(this).attr('data-itemlink')?.split('tempVersionId=')[1]?.split('&')[0] || 0;
            if (templateId) {
                self.openTemplateDetail(tempVersionId);
            }
        });

    }
    openTemplateDetail(tempVersionId = 0) {
        if (!tempVersionId) return;
        window.location.href = `/page/template/${tempVersionId}`;
        //window.location.href = `/Home/TemplateDetail/${tempVersionId}`;
    }


}
