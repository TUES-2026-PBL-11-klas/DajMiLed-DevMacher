package com.elsys.server.filter;

import io.github.bucket4j.Bucket;
import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Component;
import org.springframework.web.filter.OncePerRequestFilter;

import java.io.IOException;
import java.time.Duration;
import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;

@Component
public class RateLimitFilter extends OncePerRequestFilter {

    private static final int AUTH_CAPACITY = 10;
    private static final int GENERAL_CAPACITY = 60;

    @Value("${app.rate-limit.enabled:true}")
    private boolean enabled;

    private final Map<String, Bucket> authBuckets = new ConcurrentHashMap<>();
    private final Map<String, Bucket> generalBuckets = new ConcurrentHashMap<>();

    @Override
    protected void doFilterInternal(
            HttpServletRequest request,
            HttpServletResponse response,
            FilterChain filterChain
    ) throws ServletException, IOException {

        if (!enabled) {
            filterChain.doFilter(request, response);
            return;
        }

        String ip = resolveClientIp(request);
        boolean isAuthPath = request.getRequestURI().startsWith("/api/auth/");

        Bucket bucket = isAuthPath
                ? authBuckets.computeIfAbsent(ip, k -> newBucket(AUTH_CAPACITY))
                : generalBuckets.computeIfAbsent(ip, k -> newBucket(GENERAL_CAPACITY));

        long remaining = bucket.getAvailableTokens();
        response.setHeader("X-RateLimit-Remaining", String.valueOf(remaining));

        if (bucket.tryConsume(1)) {
            filterChain.doFilter(request, response);
        } else {
            response.setStatus(HttpStatus.TOO_MANY_REQUESTS.value());
            response.setContentType("application/json");
            response.setHeader("Retry-After", "60");
            response.getWriter().write(String.format(
                    "{\"status\":429,\"error\":\"Too Many Requests\"," +
                    "\"message\":\"Rate limit exceeded. Please try again in 1 minute.\"," +
                    "\"path\":\"%s\",\"timestamp\":\"%s\"}",
                    request.getRequestURI(), java.time.LocalDateTime.now()
            ));
        }
    }

    private Bucket newBucket(int capacity) {
        return Bucket.builder()
                .addLimit(limit -> limit.capacity(capacity).refillGreedy(capacity, Duration.ofMinutes(1)))
                .build();
    }

    private String resolveClientIp(HttpServletRequest request) {
        String forwarded = request.getHeader("X-Forwarded-For");
        if (forwarded != null && !forwarded.isBlank()) {
            return forwarded.split(",")[0].trim();
        }
        return request.getRemoteAddr();
    }
}
