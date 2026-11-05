package com.example.prm_smart_task.feature.auth.service;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertThrows;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.when;

import org.junit.jupiter.api.Test;

import com.example.prm_smart_task.feature.shared.exception.UnauthorizedException;
import com.google.api.client.googleapis.auth.oauth2.GoogleIdToken;
import com.google.api.client.googleapis.auth.oauth2.GoogleIdTokenVerifier;

class GoogleIdTokenVerifierServiceTest {

    @Test
    void rejectsTokensWhenGoogleDoesNotVerifyThem() throws Exception {
        GoogleIdTokenVerifier verifier = mock(GoogleIdTokenVerifier.class);
        when(verifier.verify("invalid-token")).thenReturn(null);
        GoogleIdTokenVerifierService tokenVerifier =
                new GoogleIdTokenVerifierService("web-client-id", verifier);

        assertThrows(UnauthorizedException.class, () -> tokenVerifier.verify("invalid-token"));
    }

    @Test
    void rejectsGoogleAccountsWithUnverifiedEmail() throws Exception {
        GoogleIdTokenVerifier verifier = mock(GoogleIdTokenVerifier.class);
        GoogleIdToken token = mock(GoogleIdToken.class);
        GoogleIdToken.Payload payload = new GoogleIdToken.Payload()
                .setEmail("person@example.com")
                .setEmailVerified(false);
        when(verifier.verify("signed-token")).thenReturn(token);
        when(token.getPayload()).thenReturn(payload);
        GoogleIdTokenVerifierService tokenVerifier =
                new GoogleIdTokenVerifierService("web-client-id", verifier);

        assertThrows(UnauthorizedException.class, () -> tokenVerifier.verify("signed-token"));
    }

    @Test
    void returnsOnlyProfileClaimsFromVerifiedToken() throws Exception {
        GoogleIdTokenVerifier verifier = mock(GoogleIdTokenVerifier.class);
        GoogleIdToken token = mock(GoogleIdToken.class);
        GoogleIdToken.Payload payload = new GoogleIdToken.Payload()
                .setEmail("person@example.com")
                .setEmailVerified(true)
                .set("name", "Example Person")
                .set("picture", "https://example.com/avatar.png");
        when(verifier.verify("signed-token")).thenReturn(token);
        when(token.getPayload()).thenReturn(payload);
        GoogleIdTokenVerifierService tokenVerifier =
                new GoogleIdTokenVerifierService("web-client-id", verifier);

        GoogleUserInfo user = tokenVerifier.verify("signed-token");

        assertEquals(
                new GoogleUserInfo(
                        "person@example.com",
                        "Example Person",
                        "https://example.com/avatar.png"),
                user);
    }

    @Test
    void failsClearlyWhenClientIdIsNotConfigured() {
        GoogleIdTokenVerifier verifier = mock(GoogleIdTokenVerifier.class);
        GoogleIdTokenVerifierService tokenVerifier =
                new GoogleIdTokenVerifierService("", verifier);

        assertThrows(IllegalStateException.class, () -> tokenVerifier.verify("signed-token"));
    }
}
