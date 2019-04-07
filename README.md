# ginware-backend

Exposes a Gincoin JSONRPC interface with 60s caching on `masternodelist` methods to be used by the GINware software for hardware wallets interfacing.

## Prerequisites
- Ubuntu 18.04
- Docker & docker-compose
- Certbot

## Installation
```bash
git clone git@github.com:GIN-coin/ginware-backend.git /opt/ginware-backend
cd /opt/ginware-backend
certbot certonly -d ginware1.gincoin.io
openssl dhparam -out dhparam.pem 2048
docker-compose up -d
```

## Example request
```bash
curl -X POST \
  https://ginware1.gincoin.io/ \
  -H 'Content-Type: application/json' \
  -d '{
	"jsonrpc":"2.0",
	"method":"getinfo",
	"params":[]
}'```
