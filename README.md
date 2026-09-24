# OpenTelemetry Pizza Workshop

A small pizza-ordering app built from three Node services and a web frontend.
The three services are instrumented with OpenTelemetry's zero-code Node.js
auto-instrumentation and report to Dash0; this file covers getting the app
running and pointing it at your own Dash0 account.

## Prerequisites

- **Docker Desktop** — [download here](https://www.docker.com/products/docker-desktop)
- **Node.js** v18 or higher — [download here](https://nodejs.org/) (only needed
  once you start changing the services)
- Ports `3000`, `3001`, `3002` and `8080` free

## Get the code

**Fork first, then clone your fork.** Later stages of the workshop open pull
requests against your repository, so you need to own the remote.

1. Open <https://github.com/dash0-community/otel-pizza-workshop> and click **Fork**.
   Keep the default name.

2. Clone your fork and keep a link to this repository:

```bash
# replace YOUR-USERNAME with your GitHub username
git clone https://github.com/YOUR-USERNAME/otel-pizza-workshop.git
cd otel-pizza-workshop

git remote add upstream https://github.com/dash0-community/otel-pizza-workshop.git
git remote -v
```

## Point it at Dash0

The services need an endpoint and a token before they will start. Create your
`.env` from inside `pizza-app/`:

```bash
cd pizza-app
cp .env.template .env
```

Then fill in two values from <https://app.dash0.com>:

| Variable | Where it comes from |
|---|---|
| `DASH0_AUTH_TOKEN` | Settings → Auth Tokens |
| `DASH0_ENDPOINT` | Settings → Endpoints → **OTLP/gRPC** (ends in `:4317`) |

Everything else in `.env` is optional. If either value is missing,
`docker compose up` stops and tells you which one.

## Run it

```bash
cd pizza-app
docker compose up
```

The first build takes a few minutes. When all four containers are up, open
<http://localhost:8080> and order a pizza.

Stop with `Ctrl+C`, or:

```bash
docker compose down            # stop
docker compose down -v         # and volumes
docker compose down --rmi all  # and images
```

## What's running

| Service | Port | Does |
|---|---|---|
| Frontend | 8080 | Order form |
| Order Service | 3000 | Takes the order, calls the other two |
| Kitchen Service | 3001 | Checks availability, cooks |
| Delivery Service | 3002 | Assigns a driver |

Logs from all four are interleaved in the terminal you ran `docker compose up`
in. For one service on its own:

```bash
docker compose logs -f order-service
```

## What lands in Dash0

Order a pizza, then look in Dash0. No tracing code was added to the services —
the OpenTelemetry Node.js auto-instrumentation is loaded before the app starts
and patches Express, `http` and Pino for you.

- **Traces** — one trace per order, spanning all three services: the inbound
  `POST /order`, the two calls into Kitchen Service, the call into Delivery
  Service, and the Express middleware in between.
- **Logs** — every Pino line, each one carrying the `trace_id` and `span_id` of
  the request that produced it, so a log jumps straight to its trace.
- **Metrics** — request rate, duration and error counts per service, plus
  Node.js runtime metrics such as event-loop lag and heap usage.

The `/health` endpoints are polled every five seconds by the container health
checks, so their spans show up too. Filter them out with
`http.route != /health` when they get in the way.

Browser monitoring is off until you set `DASH0_WEB_AUTH_TOKEN` — see the
comments in `.env.template`. It needs a second, ingest-only token because that
one is served to the browser and is therefore public.

## Failure modes you can switch on

```bash
SLOW_KITCHEN=true docker compose up   # the oven takes ~5s per pizza
NO_DRIVERS=true docker compose up     # nobody is available to deliver
```

## Troubleshooting

**Containers won't start** — check Docker Desktop is running, then
`docker compose down && docker compose up --build`.

**Port already in use** — something else holds 3000, 3001, 3002 or 8080.
`lsof -i :3000` will name it.

**Changed a file and nothing happened** — the services are baked into images.
Rebuild: `docker compose up -d --build`.

**Build fails** — `docker compose build --no-cache`, and check the JSON in any
`package.json` you edited.

**`missing DASH0_AUTH_TOKEN` / `missing DASH0_ENDPOINT`** — the `.env` is absent
or incomplete. It has to live at `pizza-app/.env`, next to `docker-compose.yml`;
one in the repo root is not read.

**App runs but nothing shows up in Dash0** — `docker compose logs order-service`
and look for exporter errors. `UNAUTHENTICATED` means the token is wrong;
`DEADLINE_EXCEEDED` or a DNS failure means `DASH0_ENDPOINT` is wrong or blocked.
Check it is the **OTLP/gRPC** endpoint ending in `:4317`, and that the dataset
you are looking at in Dash0 matches `DASH0_DATASET`.

## Credits

The pizza app and the original workshop are the work of
[Julia Morgado](https://github.com/juliafmorgado/otel-pizza-workshop).

## License

MIT License — feel free to use this for learning!
