export class DateUtil {
    static dateToShortString(date: Date): string {
        const year = '' + date.getFullYear();
        let month = '' + (date.getMonth() + 1);
        if (date.getMonth() < 9) month = '0' + month;
        let day = '' + date.getDate();
        if (date.getDate() < 10) day = '0' + day;
        return year + month + day;
    }

    static dateToShortStringHls(date: Date): string {
        const year = date.getFullYear() + '-';
        let month = (date.getMonth() + 1) + '-';
        if (date.getMonth() < 9) {
            month = '0' + (date.getMonth() + 1) + '-';
        }
        let day = '' + date.getDate();
        if (date.getDate() < 10) day = '0' + day;
        return year + month + day;
    }

    static dateToShortStringYearMonth(date: Date): string {
        const year = '' + date.getFullYear();
        let month = '' + (date.getMonth() + 1);
        if (date.getMonth() < 9) month = '0' + month;
        return year + month;
    }

    static dateToShortStringDay(date: Date): string {
        let day = '' + date.getDate();
        if (date.getDate() < 10) day = '0' + day;
        return day;
    }

    static shortStringToDate(strDate: string): Date {
        return new Date(parseInt(strDate.substring(0, 4)), parseInt(strDate.substring(4, 6)) - 1, parseInt(strDate.substring(6, 8)), 12);
    }

    static convertOffSetTimezone(date: Date, utc: string): Date {
        const utc_parse = utc.split(' ')[0].replace(/[\)\(UTC]/g, '').split(':');
        let utc_offset_hour;
        let utc_offset_minute;
        if (utc_parse[0] === '') {
            utc_offset_hour = 0;
            utc_offset_minute = 0;
        } else {
            utc_offset_hour = Number.parseInt(utc_parse[0]);
            utc_offset_minute = Number.parseInt(utc_parse[1]);
        }
        return new Date(date.getTime() - utc_offset_hour * 60 * 60 * 1000 - utc_offset_minute * 60 * 1000);
    }

    static convertUpSetTimezone(date: Date, utc: string): Date {
        const utc_parse = utc.split(' ')[0].replace(/[\)\(UTC]/g, '').split(':');
        let utc_offset_hour;
        let utc_offset_minute;
        if (utc_parse[0] === '') {
            utc_offset_hour = 0;
            utc_offset_minute = 0;
        } else {
            utc_offset_hour = Number.parseInt(utc_parse[0]);
            utc_offset_minute = Number.parseInt(utc_parse[1]);
        }
        return new Date(date.getTime() + utc_offset_hour * 60 * 60 * 1000 + utc_offset_minute * 60 * 1000);
    }


    static dateToDayMonthString(date: Date): string {
        let month = '' + (date.getMonth() + 1);
        if (date.getMonth() < 9) month = '0' + month;
        let day = '' + date.getDate();
        if (date.getDate() < 10) day = '0' + day;
        return day + '/' + month;
    }
    static dateToDayMonthYearString(date: Date): string {
        let month = '' + (date.getMonth() + 1);
        if (date.getMonth() < 9) month = '0' + month;
        let day = '' + date.getDate();
        if (date.getDate() < 10) day = '0' + day;
        const year = date.getFullYear();
        return day + '/' + month +'/'+year;
    }

    static addDate(date: Date, days: number): Date {
        return new Date(date.getTime() + days * 24 * 60 * 60 * 1000);
    }

    static addHours(date: Date, hours: number): Date {
        const resultDate = new Date(date);
        resultDate.setHours(resultDate.getHours() + hours);
        return resultDate;
    }

    static addMonth(date: Date, month: number) {
        return new Date(date.setMonth(date.getMonth() + month, 1));
    }

    static addMonthToStringYearMonth(date: Date, addMonth: number) {
        let year: number = date.getFullYear();
        let month: number = (date.getMonth() + 1);
        const yearNum = addMonth / 12;
        const monthNum = addMonth % 12;
        month += monthNum;
        if (yearNum >= 1) {
            year += Math.trunc(yearNum);
        }
        if (month > 12) {
            month = month - 12;
            year++;
        }
        if (month < 10) {
            return year + '0' + month;
        } else {
            return year + '' + month;
        }
    }

    static newDateWithTimeZone(timeZone: string, year: number, month: number, day: number, hour: number, minute: number, second: number): Date {
        const date = new Date(Date.UTC(year, month, day, hour, minute, second));
        const utcDate = new Date(date.toLocaleString('en-US', { timeZone: "UTC" }));
        const tzDate = new Date(date.toLocaleString('en-US', { timeZone: timeZone }));
        const offset = utcDate.getTime() - tzDate.getTime();
        date.setTime(date.getTime() + offset);
        return date;
    };

    static getDateFromHLSDateString(strDate: string): Date {
        const splitted = strDate.split('-');
        return DateUtil.newDateWithTimeZone("Asia/Ho_Chi_Minh", Number.parseInt(splitted[0]), Number.parseInt(splitted[1]) - 1, Number.parseInt(splitted[2]), 12, 0, 0);
    }

    static getDateFromHLSDateStringNew(strDate: string): Date {
        const splitted = strDate.split('-');
        return new Date(Number.parseInt(splitted[0]), Number.parseInt(splitted[1]) - 1, Number.parseInt(splitted[2]), 12, 0, 0);
    }

    static getHLSDateStringFromShortString(strDate: string): string {
        return strDate.substring(0, 4) + '-' + strDate.substring(4, 6) + '-' + strDate.substring(6, 8);
    }

    static getStayDates(checkIn: Date, checkOut: Date): Date[] {
        const dates: Date[] = [];
        const length = (checkOut.getTime() - checkIn.getTime()) / (24 * 60 * 60 * 1000);
        for (let index = 0; index < length; index++) {
            dates[index] = new Date(checkIn.getTime() + 24 * 60 * 60 * 1000 * index);
        }
        return dates;
    }

    // static convertTimeZone(date: Date, timeZone: string): Date {
    //     return new Date(date.toLocaleString("en-US", { timeZone: timeZone }));
    // }

    static getDateRange(start: Date, end: Date): number {
        return (end.getTime() - start.getTime()) / (24 * 60 * 60 * 1000);
    }

    static equal(date1: Date, date2: Date): boolean {
        return (date1.getFullYear() === date2.getFullYear() && date1.getMonth() === date2.getMonth() && date1.getDate() === date2.getDate());
    }

    static getTimeZonesByHour(hour: number): string[] {
        switch (hour) {
            case -12: return ['(UTC-12:00) International Date Line West', "(UTC+12:00) Magadan", "(UTC+12:00) Fiji", "(UTC+12:00) Coordinated Universal Time+12", "(UTC+12:00) Auckland, Wellington"];
            case -11: return ['(UTC-11:00) Coordinated Universal Time-11'];
            case -10: return ['(UTC-10:00) Hawaii'];
            case -9: return ['(UTC-09:00) Alaska'];
            case -8: return ['(UTC-08:00) Pacific Time (US & Canada)', '(UTC-08:00) Baja California'];
            case -7: return ['(UTC-07:00) Mountain Time (US & Canada)', '(UTC-07:00) Chihuahua, La Paz, Mazatlan', '(UTC-07:00) Arizona', '(UTC-07:00) Pacific Time (US & Canada)'];
            case -6: return ["(UTC-06:00) Saskatchewan", "(UTC-06:00) Guadalajara, Mexico City, Monterrey", "(UTC-06:00) Central Time (US & Canada)", "(UTC-06:00) Central America"];
            case -5: return ["(UTC-05:00) Indiana (East)", "(UTC-05:00) Eastern Time (US & Canada)", "(UTC-05:00) Bogota, Lima, Quito"];
            case -4.5: return ["(UTC-04:30) Caracas"];
            case -4: return ["(UTC-04:00) Santiago", "(UTC-04:00) Georgetown, La Paz, Manaus, San Juan", "(UTC-04:00) Cuiaba", "(UTC-04:00) Atlantic Time (Canada)", "(UTC-04:00) Asuncion"];
            case -3: return ["(UTC-03:00) Salvador", "(UTC-03:00) Montevideo", "(UTC-03:00) Greenland", "(UTC-03:00) Cayenne, Fortaleza", "(UTC-03:00) Buenos Aires", "(UTC-03:00) Brasilia", "(UTC-03:30) Newfoundland"];
            case -2: return ["(UTC-02:00) Coordinated Universal Time-02"];
            case -1: return ["(UTC-01:00) Cape Verde Is.", "(UTC-01:00) Azores"];
            case 0: return ["(UTC) Monrovia, Reykjavik", "(UTC) Dublin, Lisbon", "(UTC) Edinburgh, London", "(UTC) Coordinated Universal Time", "(UTC) Casablanca"];
            case 1: return ["(UTC+01:00) Windhoek", "(UTC+01:00) West Central Africa", "(UTC+01:00) Sarajevo, Skopje, Warsaw, Zagreb", "(UTC+01:00) Brussels, Copenhagen, Madrid, Paris", "(UTC+01:00) Belgrade, Bratislava, Budapest, Ljubljana, Prague", "(UTC+01:00) Amsterdam, Berlin, Bern, Rome, Stockholm, Vienna", "(UTC+01:00) Edinburgh, London",];
            case 2: return ["(UTC+02:00) Athens, Bucharest", "(UTC+02:00) Beirut", "(UTC+02:00) Cairo", "(UTC+02:00) Damascus", "(UTC+02:00) E. Europe", "(UTC+02:00) Harare, Pretoria", "(UTC+02:00) Helsinki, Kyiv, Riga, Sofia, Tallinn, Vilnius", "(UTC+02:00) Jerusalem", "(UTC+02:00) Tripoli", "(UTC+02:00) Kaliningrad"];
            case 3: return ["(UTC+03:00) Moscow, St. Petersburg, Volgograd, Minsk", "(UTC+03:00) Nairobi", "(UTC+03:00) Kuwait, Riyadh", "(UTC+03:00) Baghdad", "(UTC+03:00) Amman", "(UTC+03:00) Istanbul"];
            case 3.5: return ["(UTC+03:30) Tehran"];
            case 4: return ["(UTC+04:00) Yerevan", "(UTC+04:00) Tbilisi", "(UTC+04:00) Port Louis", "(UTC+04:00) Baku", "(UTC+04:00) Abu Dhabi, Muscat", "(UTC+04:00) Samara, Ulyanovsk, Saratov"];
            case 4.5: return ["(UTC+04:30) Kabul"];
            case 5: return ["(UTC+05:00) Islamabad, Karachi", "(UTC+05:00) Yekaterinburg", "(UTC+05:00) Ashgabat, Tashkent"];
            case 5.5: return ["(UTC+05:30) Sri Jayawardenepura", "(UTC+05:30) Chennai, Kolkata, Mumbai, New Delhi"];
            case 5.75: return ["(UTC+05:45) Kathmandu"];
            case 6: return ["(UTC+06:00) Dhaka", "(UTC+06:00) Nur-Sultan (Astana)"];
            case 6.5: return ["(UTC+06:30) Yangon (Rangoon)"];
            case 7: return ["(UTC+07:00) Novosibirsk", "(UTC+07:00) Bangkok, Hanoi, Jakarta"];
            case 8: return ["(UTC+08:00) Irkutsk", "(UTC+08:00) Ulaanbaatar", "(UTC+08:00) Taipei", "(UTC+08:00) Perth", "(UTC+08:00) Kuala Lumpur, Singapore", "(UTC+08:00) Krasnoyarsk", "(UTC+08:00) Beijing, Chongqing, Hong Kong, Urumqi"];
            case 9: return ["(UTC+09:00) Yakutsk", "(UTC+09:00) Seoul", "(UTC+09:00) Osaka, Sapporo, Tokyo"];
            case 9.5: return ["(UTC+09:30) Darwin", "(UTC+09:30) Adelaide"];
            case 10: return ["(UTC+10:00) Hobart", "(UTC+10:00) Guam, Port Moresby", "(UTC+10:00) Canberra, Melbourne, Sydney", "(UTC+10:00) Brisbane"];
            case 11: return ["(UTC+11:00) Vladivostok", "(UTC+11:00) Solomon Is., New Caledonia"];
            // case 12: return ["(UTC+12:00) Magadan", "(UTC+12:00) Fiji", "(UTC+12:00) Coordinated Universal Time+12", "(UTC+12:00) Auckland, Wellington"];
        }

        return [];
    }
}