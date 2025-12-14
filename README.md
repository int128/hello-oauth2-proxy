# hello-oauth2-proxy

This is an example config with oauth2-proxy and nginx for a wildcard domain.

## Request flow

```mermaid
sequenceDiagram
    participant User
    participant nginx
    participant oauth2-proxy
    participant Google

    User->>nginx: GET https://www-sandbox.example.com/foo
    nginx->>oauth2-proxy: auth_request /oauth2/auth
    oauth2-proxy-->>nginx: 401 Unauthorized (no valid cookie)
    nginx->>User: 302 Redirect to /oauth2/start
    
    User->>oauth2-proxy: GET /oauth2/start
    oauth2-proxy->>User: 302 Redirect to Google OAuth
    
    User->>Google: GET https://accounts.google.com/o/oauth2/auth<br/>(with client_id, redirect_uri, scope, state)
    Google->>User: Show login page & consent
    User->>Google: Login & consent
    Google->>User: 302 Redirect to callback
    
    User->>oauth2-proxy: GET https://auth-sandbox.example.com/oauth2/callback<br/>(with code and state)
    oauth2-proxy->>Google: POST token exchange (code for access token)
    Google-->>oauth2-proxy: access_token, id_token
    oauth2-proxy->>oauth2-proxy: Validate token & create session
    oauth2-proxy->>User: 302 Redirect to original URL<br/>(Set-Cookie: _oauth2_proxy)
    
    User->>nginx: GET https://www-sandbox.example.com/foo<br/>(with cookie)
    nginx->>oauth2-proxy: auth_request /oauth2/auth (with cookie)
    oauth2-proxy-->>nginx: 200 OK (valid session)
    nginx->>User: 200 OK (serve protected content)
```

### URL Examples

- `https://www-sandbox.example.com/foo`
- `https://accounts.google.com/o/oauth2/auth?access_type=offline&client_id=***&prompt=+&redirect_uri=https%3A%2F%2Fauth-sandbox.example.com%2Foauth2%2Fcallback&response_type=code&scope=profile+email&state=***%3Ahttp%3A%2F%2Fwww-sandbox.example.com%2Ffoo`
- `https://auth-sandbox.example.com/oauth2/callback?state=***%3Ahttp%3A%2F%2Fwww-sandbox.example.com%2Ffoo&code=***&scope=email+profile+https%3A%2F%2Fwww.googleapis.com%2Fauth%2Fuserinfo.email+https%3A%2F%2Fwww.googleapis.com%2Fauth%2Fuserinfo.profile+openid&authuser=0&prompt=none`
- `http://www-sandbox.example.com/foo`
- `https://www-sandbox.example.com/foo`
