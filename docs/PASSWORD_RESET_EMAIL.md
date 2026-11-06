# Password reset email setup

The forgot-password flow sends its one-time reset code through the Mailjet Send API v3.1 over HTTPS. Configure these environment variables for the backend:

| Variable | Value |
| --- | --- |
| `MJ_APIKEY_PUBLIC` | Public API key from the Mailjet account |
| `MJ_APIKEY_PRIVATE` | Private API key from the Mailjet account; keep it secret |
| `MAILJET_FROM_EMAIL` | Sender address validated and active in Mailjet |
| `MAILJET_FROM_NAME` | Optional display name; defaults to `PRM Smart Task` |

Add these values to the backend service's Render Environment settings. Do not commit the private API key to the repository or share it in chat.

Mailjet requires the sender address to be validated and active. If you do not own a domain, first try validating an email address you control in the Mailjet Sender addresses page; the account may require domain authentication or additional verification depending on its current policy. Follow the status and instructions shown in the Mailjet dashboard.

The user requests a code from the login screen, enters that code and a new password in the app, and submits the reset form. Codes are random, expire after 30 minutes, are stored only as SHA-256 hashes, and can be used once. Resetting a password revokes that user's refresh tokens.

The forgot-password endpoint returns the same success response whether or not the email is registered to avoid disclosing account existence. If Mailjet is unavailable or misconfigured, the endpoint responds with HTTP 503 rather than reporting success.
