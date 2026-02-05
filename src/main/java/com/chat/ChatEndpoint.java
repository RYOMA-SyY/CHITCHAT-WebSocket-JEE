package com.chat;

import java.io.IOException;
import java.util.Collections;
import java.util.HashMap;
import java.util.HashSet;
import java.util.LinkedList;
import java.util.Map;
import java.util.Queue;
import java.util.Set;
import jakarta.websocket.OnClose;
import jakarta.websocket.OnError;
import jakarta.websocket.OnMessage;
import jakarta.websocket.OnOpen;
import jakarta.websocket.Session;
import jakarta.websocket.server.ServerEndpoint;

/**
 * WebSocket Endpoint for a simple chat application.
 * Mapped to /chat URL.
 */
@ServerEndpoint("/chat")
public class ChatEndpoint {

    // Thread-safe set to store all connected sessions
    private static final Set<Session> sessions = Collections.synchronizedSet(new HashSet<>());

    // Rate Limiting: Map Session to a list of timestamps
    // We will allow max 5 messages per 5 seconds.
    private static final Map<Session, Queue<Long>> rateLimits = Collections.synchronizedMap(new HashMap<>());
    private static final int MAX_MESSAGES = 5;
    private static final int TIME_WINDOW_MS = 5000; // 5 seconds

    // Message History: Keep last 50 messages
    private static final int MAX_HISTORY = 50;
    private static final LinkedList<String> messageHistory = new LinkedList<>();

    @OnOpen
    public void onOpen(Session session) {
        sessions.add(session);
        rateLimits.put(session, new LinkedList<>());
        System.out.println("New session connected: " + session.getId());

        // Send history to new user
        synchronized (messageHistory) {
            for (String msg : messageHistory) {
                try {
                    session.getBasicRemote().sendText(msg);
                } catch (IOException e) {
                    e.printStackTrace();
                }
            }
        }
    }

    @OnMessage
    public void onMessage(String message, Session session) {
        if (isRateLimited(session)) {
            try {
                session.getBasicRemote().sendText("System: 🚫 You are sending messages too fast! Wait a moment.");
            } catch (IOException e) {
                e.printStackTrace();
            }
            return;
        }

        // Broadcast the received message
        System.out.println("Message received from " + session.getId() + ": " + message);

        // Add to history
        synchronized (messageHistory) {
            if (messageHistory.size() >= MAX_HISTORY) {
                messageHistory.removeFirst();
            }
            messageHistory.add(message);
        }

        broadcast(message);
    }

    @OnClose
    public void onClose(Session session) {
        sessions.remove(session);
        rateLimits.remove(session);
        System.out.println("Session closed: " + session.getId());
    }

    @OnError
    public void onError(Session session, Throwable throwable) {
        // Handle error but don't crash everything
        if (session != null) {
            System.err.println("Error in session " + session.getId());
            rateLimits.remove(session);
        }
        throwable.printStackTrace();
    }

    private boolean isRateLimited(Session session) {
        Queue<Long> timestamps = rateLimits.get(session);
        long now = System.currentTimeMillis();

        synchronized (timestamps) {
            // Remove timestamps older than the time window
            while (!timestamps.isEmpty() && now - timestamps.peek() > TIME_WINDOW_MS) {
                timestamps.poll();
            }

            if (timestamps.size() < MAX_MESSAGES) {
                timestamps.add(now);
                return false; // Not rate limited
            } else {
                return true; // Rate limited
            }
        }
    }

    private void broadcast(String message) {
        synchronized (sessions) {
            for (Session session : sessions) {
                if (session.isOpen()) {
                    try {
                        session.getBasicRemote().sendText(message);
                    } catch (IOException e) {
                        e.printStackTrace();
                    }
                }
            }
        }
    }
}
