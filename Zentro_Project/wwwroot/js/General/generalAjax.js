class AjaxService {
    constructor(baseUrl = '') {
        this.baseUrl = baseUrl;
    }

    async request(endpoint, method = 'GET', data = null) {
        try {
            const url = `${this.baseUrl}${endpoint}`;
            const options = {
                method: method.toUpperCase(),
                headers: { 'Content-Type': 'application/json' }
            };

            if (data) {
                options.body = JSON.stringify(data);
            }

            const response = await fetch(url, options);

            if (!response.ok) {
                throw new Error(`HTTP Error: ${response.status}`);
            }

            return await response.json();

        } catch (error) {
            console.error('AJAX Request Failed:', error);
            throw error;
        }
    }

    get(endpoint, data = null) {
        return this.request(endpoint, 'GET', data);
    }

    post(endpoint, data = null) {
        return this.request(endpoint, 'POST', data);
    }

}
