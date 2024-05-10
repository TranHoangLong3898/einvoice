import https = require('https');
import { URL } from 'url';

export class RestUtil {
    static async postRequest(options: string | https.RequestOptions | URL, postData: any): Promise<any> {
        return new Promise<string>(function (resolve, reject) {
            const req = https.request(options, (res) => {
                let data = '';

                res.on('data', (chunk) => {
                    data += chunk;
                });

                res.on('end', () => {
                    resolve(JSON.parse(data));
                });

            }).on("error", (err) => {
                reject('Post request error: ' + err.message);
                console.error('Post request error: ' + err.message + '\\nOptions: ' + options + '\\nData: ' + postData);
            });

            req.write(postData);
            req.end();
        });
    }


    static async getRequest(options: string | https.RequestOptions | URL): Promise<any> {
        return new Promise<string>(function (resolve, reject) {
            const req = https.request(options, (res) => {
                console.log('statusCode:', res.statusCode);
                console.log('headers:', res.headers);
                let data = '';

                res.on('data', (d) => {
                    data += d;
                });

                res.on('end', () => {
                    resolve(JSON.parse(data));
                });

            }).on("error", (err) => {
                reject('Post request error: ' + err.message);
                console.error('Post request error: ' + err.message);
            });
            req.end();
        });
    }
}