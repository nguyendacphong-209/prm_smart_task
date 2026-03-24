package com.example.prm_smart_task.feature.shared.security;

import java.nio.charset.StandardCharsets;
import java.util.Date;
import java.util.UUID;

import javax.crypto.SecretKey;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

import io.jsonwebtoken.Claims;
import io.jsonwebtoken.Jwts;
import io.jsonwebtoken.security.Keys;

@Service
public class JwtService {

    private final SecretKey secretKey;
    private final long expirationMs;

    public JwtService(
            @Value("${security.jwt.secret}") String secret,
            @Value("${security.jwt.expiration-ms}") long expirationMs) {
        this.secretKey = Keys.hmacShaKeyFor(secret.getBytes(StandardCharsets.UTF_8));
        this.expirationMs = expirationMs;
    }

    public String generateAccessToken(UUID userId, String email) {
        Date now = new Date();
        Date expiryDate = new Date(now.getTime() + expirationMs);

        return Jwts.builder()
                .subject(email)
                .claim("userId", userId.toString())
                .issuedAt(now)
                .expiration(expiryDate)
                .signWith(secretKey)
                .compact();
    }

    public long getAccessTokenExpirationMs() {
        return expirationMs;
    }

    public String extractEmail(String token) {
        return extractAllClaims(token).getSubject();
    }

    public boolean isTokenValid(String token, String expectedEmail) {
        String email = normalizeEmail(extractEmail(token));
        String normalizedExpectedEmail = normalizeEmail(expectedEmail);
        return normalizedExpectedEmail != null
                && normalizedExpectedEmail.equals(email)
                && !isTokenExpired(token);
    }

    private String normalizeEmail(String email) {
        if (email == null) {
            return null;
        }

        String normalizedEmail = email.trim().toLowerCase();
        return normalizedEmail.isEmpty() ? null : normalizedEmail;
    }

    private boolean isTokenExpired(String token) {
        Date expiration = extractAllClaims(token).getExpiration();
        return expiration.before(new Date());
    }

    private Claims extractAllClaims(String token) {
        return Jwts.parser()
                .verifyWith(secretKey)
                .build()
                .parseSignedClaims(token)
                .getPayload();
    }
}
