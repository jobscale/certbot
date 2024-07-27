const fs = require('fs');
const { logger } = require('@jobscale/logger');

const {
  ENV, CERTBOT_DOMAIN, CERTBOT_VALIDATION,
  CERTBOT_AUTH_HOOK, CERTBOT_CLEANUP_HOOK,
} = process.env;

const ZONE = 'is1a';
const API = `https://secure.sakura.ad.jp/cloud/zone/${ZONE}/api/cloud/1.1`;

class App {
  async allowInsecure(use) {
    if (use === false) delete process.env.NODE_TLS_REJECT_UNAUTHORIZED;
    else process.env.NODE_TLS_REJECT_UNAUTHORIZED = '0';
  }

  fetchEnv() {
    const Host = 'https://partner.credentials.svc.cluster.local';
    const Cookie = 'X-AUTH=X0X0X0X0X0X0X0X';
    const request = [
      `${Host}/value-domain.env.json`,
      { method: 'GET', headers: { Cookie } },
    ];
    return this.allowInsecure()
    .then(() => fetch(...request))
    .then(res => this.allowInsecure(false) && res)
    .then(res => res.json())
    .catch(() => {
      const CIA = fs.readFileSync('../partner/sakura-cloud');
      const toml = Buffer.from(CIA.toString(), 'base64').toString();
      const env = {};
      toml.split('\n').map(row => row.split('='))
      .forEach(([key, value]) => {
        if (!key) return;
        env[key] = value;
      });
      return {
        accessToken: env.SAKURACLOUD_ACCESS_TOKEN,
        accessTokenSecret: env.SAKURACLOUD_ACCESS_TOKEN_SECRET,
        zone: env.SAKURACLOUD_ZONE,
      };
    });
  }

  fetchIP() {
    return fetch('https://inet-ip.info/ip')
    .then(res => res.text())
    .then(res => res.split('\n')[0]);
  }

  waiter(milliseconds) {
    return new Promise(
      resolve => { setTimeout(resolve, milliseconds); },
    );
  }

  async setRecord(ip, env) {
    const Type = 'TXT';
    logger.info(`Dynamic DNS polling. - [${ENV}] ${ip}`);
    if (!CERTBOT_AUTH_HOOK || !CERTBOT_CLEANUP_HOOK) return 'ng';
    const zone = await this.getDNSRecords(env, 'jsx.jp');
    const host = CERTBOT_DOMAIN.replace(/\.jsx\.jp$/, '');
    const RData = CERTBOT_VALIDATION;
    const records = zone.ResourceRecordSets.filter(
      item => item.Type !== Type || item.Name !== host,
    );
    records.push({ Name: host, Type, RData, TTL: 120 });
    this.putDNSRecords(env, { ...zone, ResourceRecordSets: records });
    return 'dynamic';
  }

  async getDNSZones(env) {
    const url = `${API}/commonserviceitem`;
    const { accessToken, accessTokenSecret } = env;
    const Authorization = `Basic ${Buffer.from(`${accessToken}:${accessTokenSecret}`).toString('base64')}`;
    const response = await fetch(url, {
      headers: { Authorization },
    });
    if (!response.ok) {
      throw new Error(`fetching DNS zones: ${response.status} ${response.statusText}`);
    }
    const data = await response.json();
    const zones = data.CommonServiceItems
    .filter(item => item.ServiceClass === 'cloud/dns')
    .map(item => ({
      ID: item.ID,
      Name: item.Name,
    }));
    return zones;
  }

  async getDNSRecords(env, zoneName) {
    const url = `${API}/commonserviceitem`;
    const { accessToken, accessTokenSecret } = env;
    const Authorization = `Basic ${Buffer.from(`${accessToken}:${accessTokenSecret}`).toString('base64')}`;
    const response = await fetch(url, {
      headers: { Authorization },
    });
    if (!response.ok) {
      throw new Error(`fetching DNS records: ${response.status} ${response.statusText}`);
    }
    const data = await response.json();
    const [zone] = data.CommonServiceItems
    .filter(item => item.ServiceClass === 'cloud/dns' && item.Name === zoneName)
    .map(item => ({
      ID: item.ID,
      Name: item.Name,
      ResourceRecordSets: item.Settings.DNS.ResourceRecordSets,
    }));
    return zone;
  }

  async putDNSRecords(env, zone) {
    const url = `${API}/commonserviceitem/${zone.ID}`;
    const { accessToken, accessTokenSecret } = env;
    const Authorization = `Basic ${Buffer.from(`${accessToken}:${accessTokenSecret}`).toString('base64')}`;
    const payload = {
      CommonServiceItem: {
        Settings: {
          DNS: {
            ResourceRecordSets: zone.ResourceRecordSets,
          },
        },
      },
    };
    const response = await fetch(url, {
      method: 'PUT',
      headers: { Authorization, 'Content-Type': 'application/json' },
      body: JSON.stringify(payload),
    });
    if (!response.ok) {
      throw new Error(`update DNS records: ${response.status} ${response.statusText}`);
    }
    const data = await response.json();
    return data;
  }

  main() {
    return Promise.all([this.fetchIP(), this.fetchEnv()])
    .then(data => this.setRecord(...data));
  }

  start() {
    const ts = new Date();
    logger.info({ ts: ts.getTime(), now: ts.toISOString() });
    this.main()
    .catch(e => logger.error({ message: e.toString() }));
  }
}

new App().start();
