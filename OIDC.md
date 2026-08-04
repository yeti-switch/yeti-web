# yeti-web as an OpenID Connect provider

yeti-web's Doorkeeper is an OAuth 2.0 provider: it answers *"may this client call
the API?"*. With `oauth.oidc.enabled` it also answers *"who is the user?"* — it
issues a signed `id_token`, publishes a JWKS and a discovery document, and serves
`userinfo`. `admin_users` then become the login for other components:
yeti-statistics, Grafana, anything that speaks OIDC.

Everything below is off unless you turn it on. An existing OAuth-only deployment
behaves exactly as before.

---

## When *not* to use this

If yeti-web already signs its own admins in through an external IdP (Keycloak,
Authentik, Okta…) — i.e. `config/oidc.yml` exists — point the other component at
**that same issuer** instead. Two lines of config, no key to manage:

```yaml
# yeti-statistics config.yml
auth:
  enabled: true
  issuer: https://<the same IdP yeti-web uses>
  client_id: yeti-statistics
```

Both apps become clients of one IdP, which is what single sign-on *is*. Making
yeti-web an IdP that itself federates to another IdP inserts a pointless hop and
leaves you maintaining token signing and key rotation that a purpose-built IdP
already does better.

Use this document when `AdminUser` with a local password is the real login.

---

## What you get

| Endpoint | Serves |
|---|---|
| `/.well-known/openid-configuration` | OIDC discovery — clients read everything else from here |
| `/oauth/discovery/keys` | JWKS: the public half of the signing key, with a `kid` |
| `/oauth/userinfo` | Claims for a bearer token |
| `/oauth/authorize`, `/oauth/token` | Unchanged; the token response gains an `id_token` when `openid` was granted |
| `/.well-known/oauth-authorization-server` | Unchanged RFC 8414 document for MCP clients, now also naming the OIDC endpoints |

Claims in both the `id_token` and `userinfo`:

| Claim | Source |
|---|---|
| `sub` | `AdminUser#id` — stable, never recycled |
| `name`, `preferred_username` | `AdminUser#username` |
| `email` | `AdminUser#email`, which comes off the billing contact — **nil if the admin has none** |
| `email_verified` | whether that address exists |
| `groups` | `AdminUser#roles` — this is what clients authorise on |

---

## Setup

### 1. Generate the signing key

```sh
bundle exec rake 'oauth:oidc:generate_signing_key[/etc/yeti-web/oidc_signing_key.pem]'
```

2048-bit RSA, written at mode 0400. **This key mints identities**: anyone who can
read it can forge an `id_token` for any admin on every client that trusts this
issuer. Deploy it out of band (Ansible, not git) and treat it like the database
password. `config/oidc_signing_key.pem` is gitignored for the same reason.

### 2. Enable it

```yaml
# config/yeti_web.yml
oauth:
  enabled: true
  issuer: https://web.example.com
  oidc:
    enabled: true
    signing_key_path: /etc/yeti-web/oidc_signing_key.pem
```

`issuer` sits on `oauth`, not on `oauth.oidc`, because it identifies the
authorization server itself: the same string is reported by
`/.well-known/oauth-authorization-server` and `/.well-known/openid-configuration`
and carried in every `id_token`. One server, one identity — a client that
discovers through either document must see the same answer.

It must be the URL clients actually reach yeti-web on. Clients compare it against
the discovery document, against the URL they fetched it from, and against the
`iss` claim — a trailing slash is enough to break every login. It is mandatory
once `oidc.enabled`, and yeti-web refuses to boot without it (or if the key is
unreadable). With OAuth alone it may be omitted, in which case the RFC 8414
document reports the URL the request came in on — which is what lets MCP
one-click connect work with no configuration at all.

Run the migration if this is an upgrade: the `nonce` a client sends has to
survive between the authorization request and the token exchange, and it lives in
`gui.oauth_openid_requests`.

### 3. Register the client

In the admin UI: **System → Admin Access → OAuth Applications → New**. Give it a
name, a redirect URI and the `openid profile email` scopes; leave Client ID and
Client secret blank to have them generated, or set them to fixed values when the
client's config is deployed from a template. The detail page shows both
afterwards, and has a **Rotate secret** action.

The page is root-only until a role is granted the `System/OauthApplication`
section in `config/policy_roles.yml` — it displays client secrets in cleartext,
which is how Doorkeeper stores them.

The `redirect_uri` must match what the client sends **byte for byte**, including
any base path (`https://stats.example.com/stats/api/auth/callback`), and must be
HTTPS unless the host is a loopback address.

MCP clients (Claude Code, Cursor) need none of this — they self-register through
`POST /oauth/register`, and appear in the same list once they have. OIDC clients
cannot: that endpoint is unauthenticated, so it grants the `mcp` scope only and
rejects a registration asking for `openid`, `profile` or `email` with
`invalid_client_metadata`. Anything that signs users in is registered here, by an
operator.

### 4. Configure the client

```yaml
# yeti-statistics config.yml
auth:
  enabled: true
  issuer: https://web.example.com
  client_id: <from the detail page>
  client_secret: <from the detail page>
  redirect_url: https://stats.example.com/api/auth/callback
  cookie_secret: <openssl rand -hex 32>
  allowed_groups: [admin]     # matched against AdminUser#roles
```

**Set `allowed_groups`.** Without it, any account this provider knows — every
enabled admin — can read every customer's traffic and margin.

---

## Verification

```sh
# 1. Discovery, and the issuer it claims.
curl -s https://web.example.com/.well-known/openid-configuration | jq
#    issuer must equal what the client is configured with, exactly.
#    Also check: jwks_uri, id_token_signing_alg_values_supported ["RS256"],
#    code_challenge_methods_supported ["S256"], scopes_supported incl. "openid".

# 2. JWKS serves a public key with a kid.
curl -s https://web.example.com/oauth/discovery/keys | jq

# 3. MCP discovery is untouched — registration_endpoint must still be there.
curl -s https://web.example.com/.well-known/oauth-authorization-server | jq
```

Then run the real flow: open yeti-statistics, click **Sign in**. You should land
on the ActiveAdmin login page and come back signed in.

When it fails, the client's error says which step broke:

| error | cause |
|---|---|
| `provider returned no id_token: it is OAuth2, not OIDC` | `oauth.oidc.enabled` is off, or the client's registered scopes don't include `openid` |
| `id_token: issuer did not match` | `oauth.issuer` ≠ the client's `issuer` |
| `id_token: failed to verify signature` | JWKS unreachable, or the key was rotated with no overlap |
| `nonce mismatch` | the `gui.oauth_openid_requests` migration has not been run |
| `account "x" is in none of the permitted groups` | `AdminUser#roles` contains none of the client's `allowed_groups` |
| yeti-web won't boot, complaining about `oauth.issuer` / `oauth.oidc.signing_key_path` | step 1 or 2 is incomplete — the message says which |

---

## Operating it

**Key rotation.** Publish the new key in JWKS *before* signing with it, keep the
old one published until every issued token has expired, then drop the old one.
The `kid` header on each token says which key signed it. Skipping the overlap
signs everyone out.

**Offboarding.** Setting `enabled = false` on an `AdminUser` takes effect
immediately: `OauthAccessToken#accessible?` checks the owner, so the token stops
working at `userinfo`, at introspection and at `/api/mcp` on the next request,
and `before_successful_strategy_response` blocks any new token or refresh. An
`id_token` already handed to a client stays valid until that client's own session
expires (yeti-statistics: `session_ttl`, 12h by default) — shorten it there if
immediate revocation matters.

**Scopes.** `openid` is optional and never granted by default; a client has to
ask for it. Withholding it is also what keeps the whole OIDC layer dormant when
the feature is off.

---

## Implementation notes

Three things here are load-bearing and not obvious from the gem's README:

- **The gem is configured unconditionally**
  (`config/initializers/doorkeeper_openid_connect.rb`), even when the feature is
  off. It prepends an `openid_request` association onto every Doorkeeper access
  grant model, and that association reads
  `Doorkeeper::OpenidConnect.configuration` while the class body is evaluated —
  so leaving it unconfigured makes `OauthAccessGrant` raise at eager load, in
  every deployment. What the flag actually gates is the `openid` scope and the
  routes.
- **Claims declare `response: [:id_token, :user_info]`.** The gem's default is
  `user_info` alone, which would leave a client that never calls
  `/oauth/userinfo` — the normal case — with a token carrying nothing but `sub`.
- **Route order in `config/routes.rb` matters.** The OIDC gem's discovery routes
  claim `/.well-known/oauth-authorization-server` too, and its version of that
  document has no `registration_endpoint`. yeti's own route is declared first so
  MCP clients can still self-register.

`use_doorkeeper` also skips Doorkeeper's built-in `:applications` controller.
That UI was already unreachable (`admin_authenticator` answers 403), and leaving
it mounted claimed the `oauth_application(s)` route-helper names that the
ActiveAdmin page needs for its own links.

**RP-initiated logout** (`end_session_endpoint`) is not implemented. Clients
default to dropping their own session and leaving yeti-web's alone, which is the
right default: a "sign out" button in a stats dashboard should not sign the user
out of everything on the issuer.
