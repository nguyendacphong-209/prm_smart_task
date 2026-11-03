package com.example.prm_smart_task.feature.auth.service;

import java.io.IOException;
import java.security.GeneralSecurityException;
import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;

import com.example.prm_smart_task.feature.shared.exception.UnauthorizedException;
import com.google.api.client.googleapis.auth.oauth2.GoogleIdToken;
import com.google.api.client.googleapis.auth.oauth2.GoogleIdTokenVerifier;
import com.google.api.client.http.javanet.NetHttpTransport;
import com.google.api.client.json.gson.GsonFactory;

@Component
public class GoogleIdTokenVerifierService {

    private final GoogleIdTokenVerifier verifier;
    private final String clientId;

    @Autowired
    public GoogleIdTokenVerifierService(@Value("${security.google.client-id:}") String clientId) {
        this(clientId, createVerifier(clientId));
    }

    GoogleIdTokenVerifierService(String clientId, GoogleIdTokenVerifier verifier) {
        this.clientId = clientId == null ? "" : clientId.trim();
        this.verifier = verifier;
    }

    private static GoogleIdTokenVerifier createVerifier(String clientId) {
        String normalizedClientId = clientId == null ? "" : clientId.trim();
        GoogleIdTokenVerifier.Builder verifierBuilder = new GoogleIdTokenVerifier.Builder(
                new NetHttpTransport(),
                GsonFactory.getDefaultInstance());
        if (!normalizedClientId.isBlank()) {
            verifierBuilder.setAudience(List.of(normalizedClientId));
        }
        return verifierBuilder.build();
    }

    public GoogleUserInfo verify(String idToken) {
        if (clientId.isBlank()) {
            throw new IllegalStateException("Google Sign-In is not configured. Set GOOGLE_CLIENT_ID.");
        }
        if (idToken == null || idToken.isBlank()) {
            throw new UnauthorizedException("Invalid Google ID token");
        }

        GoogleIdToken verifiedToken;
        try {
            verifiedToken = verifier.verify(idToken);
        } catch (GeneralSecurityException exception) {
            throw new UnauthorizedException("Invalid Google ID token");
        } catch (IOException exception) {
            throw new IllegalStateException("Google token verification is temporarily unavailable", exception);
        }

        if (verifiedToken == null) {
            throw new UnauthorizedException("Invalid Google ID token");
        }

        GoogleIdToken.Payload payload = verifiedToken.getPayload();
        if (!Boolean.TRUE.equals(payload.getEmailVerified())) {
            throw new UnauthorizedException("Google account email is not verified");
        }

        String email = payload.getEmail();
        if (email == null || email.isBlank()) {
            throw new UnauthorizedException("Google ID token does not contain an email");
        }

        return new GoogleUserInfo(
                email,
                (String) payload.get("name"),
                (String) payload.get("picture"));
    }
}
