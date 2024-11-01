class CustomResponse {

    constructor(status, message, data) {
        this._status = status;
        this._message = message;
        this._data = data;
    }

    get status() {
        return this._status;
    }

    set status(value) {
        this._status = value;
    }

    get message() {
        return this._message;
    }

    set message(value) {
        this._message = value;
    }

    get data() {
        return this._data;
    }

    set data(value) {
        this._data = value;
    }

    toJSON() {
        return {
            status: this.status,
            message: this.message,
            data: this.data
        };
    }
}
module.exports = CustomResponse;