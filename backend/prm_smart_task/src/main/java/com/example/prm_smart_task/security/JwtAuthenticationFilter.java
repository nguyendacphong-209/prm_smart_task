package com.example.prm_smart_task.security;

import java.io.IOException;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.core.userdetails.UsernameNotFoundException;
import org.springframework.security.web.authentication.WebAuthenticationDetailsSource;
import org.springframework.stereotype.Component;
import org.springframework.web.filter.OncePerRequestFilter;

import io.jsonwebtoken.JwtException;
import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

@Component
public class JwtAuthenticationFilter extends OncePerRequestFilter {

    private static final Logger authLogger = LoggerFactory.getLogger(JwtAuthenticationFilter.class);

    private final JwtService jwtService;
    private final AppUserDetailsService appUserDetailsService;

    public JwtAuthenticationFilter(JwtService jwtService, AppUserDetailsService appUserDetailsService) {
        this.jwtService = jwtService;
        this.appUserDetailsService = appUserDetailsService;
    }

    @Override
    protected void doFilterInternal(
            HttpServletRequest request,
            HttpServletResponse response,
            FilterChain filterChain) throws ServletException, IOException {
        String authHeader = request.getHeader("Authorization");
        if (authHeader == null || authHeader.isBlank() || !authHeader.regionMatches(true, 0, "Bearer ", 0, 7)) {
            filterChain.doFilter(request, response);
            return;
        }

        String token = authHeader.substring(7).trim();
        if (token.isEmpty()) {
            SecurityContextHolder.clearContext();
            authLogger.warn("Empty bearer token. method={} path={}", request.getMethod(), request.getRequestURI());
            filterChain.doFilter(request, response);
            return;
        }

        try {
            String email = jwtService.extractEmail(token);
            if (email != null && SecurityContextHolder.getContext().getAuthentication() == null) {
                UserDetails userDetails = appUserDetailsService.loadUserByUsername(email);
                if (jwtService.isTokenValid(token, userDetails.getUsername())) {
                    UsernamePasswordAuthenticationToken authenticationToken = new UsernamePasswordAuthenticationToken(
                            userDetails,
                            null,
                            userDetails.getAuthorities());
                    authenticationToken.setDetails(new WebAuthenticationDetailsSource().buildDetails(request));
                    SecurityContextHolder.getContext().setAuthentication(authenticationToken);
                } else {
                    SecurityContextHolder.clearContext();
                    authLogger.warn("JWT rejected by isTokenValid. method={} path={} emailFromToken={}",
                            request.getMethod(), request.getRequestURI(), email);
                }
            }
        } catch (JwtException exception) {
            SecurityContextHolder.clearContext();
            authLogger.warn("JWT parse/verify failed. method={} path={} reason={}",
                    request.getMethod(), request.getRequestURI(), exception.getMessage());
        } catch (UsernameNotFoundException exception) {
            SecurityContextHolder.clearContext();
            authLogger.warn("JWT subject user not found. method={} path={} reason={}",
                    request.getMethod(), request.getRequestURI(), exception.getMessage());
        }

        filterChain.doFilter(request, response);
    }
}
