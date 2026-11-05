# Password reset email setup

The forgot-password flow sends a one-time reset code through Gmail SMTP. Configure these environment variables for the backend:

| Variable | Value |
| --- | --- |
| `MAIL_HOST` | `smtp.gmail.com` |
| `MAIL_PORT` | `587` |
| `MAIL_USERNAME` | The Gmail address used to send reset emails |
| `MAIL_PASSWORD` | A Google App Password for that account |
| `MAIL_FROM` | Optional sender address; defaults to `MAIL_USERNAME` |

Create a Google App Password for the sender account and store it as a deployment secret. Do not commit the password to the repository. The app uses STARTTLS on port 587.

The user requests a code from the login screen, enters that code and a new password in the app, and submits the reset form. Codes are random, expire after 30 minutes, are stored only as SHA-256 hashes, and can be used once. Resetting a password revokes that user's refresh tokens.

The forgot-password endpoint returns the same response whether or not the email is registered to avoid disclosing account existence.
