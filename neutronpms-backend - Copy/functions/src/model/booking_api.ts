export class BookingApi {
    private _id: string;
    private _name: string;
    private _sid: string;
    private _in_date: Date;
    private _out_date: Date;
    private _name_room: string;
    private _group: boolean;
    private _source: string;


    constructor(id: string, name: string, sid: string, name_room: string, group: boolean, in_date: Date, out_date: Date, source: string) {
        this._id = id;
        this._name = name;
        this._sid = sid;
        this._in_date = in_date;
        this._out_date = out_date;
        this._name_room = name_room;
        this._group = group;
        this._source = source;
    };

    public get id(): string {
        return this._id;
    }
    public set id(value: string) {
        this._id = value;
    }

    public get group(): boolean {
        return this._group;
    }
    public set group(value: boolean) {
        this._group = value;
    }
    public get name_room(): string {
        return this._name_room;
    }
    public set name_room(value: string) {
        this._name_room = value;
    }

    public get out_date(): Date {
        return this._out_date;
    }
    public set out_date(value: Date) {
        this._out_date = value;
    }
    public get in_date(): Date {
        return this._in_date;
    }
    public set in_date(value: Date) {
        this._in_date = value;
    }
    public get name(): string {
        return this._name;
    }
    public set name(value: string) {
        this._name = value;
    }

    public get sid(): string {
        return this._sid;
    }
    public set sid(value: string) {
        this._sid = value;
    }

    public get source(): string {
        return this._source;
    }
    public set source(value: string) {
        this._source = value;
    }
}