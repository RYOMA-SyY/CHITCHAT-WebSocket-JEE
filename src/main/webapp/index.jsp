<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
    <!DOCTYPE html>
    <html>

    <head>
        <meta charset="UTF-8">
        <title>Simple Chat App</title>
        <style>
            body {
                font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
                max-width: 800px;
                margin: 20px auto;
                padding: 0 20px;
                background-color: #f0f2f5;
            }

            h1 {
                text-align: center;
                color: #333;
            }

            #chat-container {
                border: 1px solid #ddd;
                border-radius: 8px;
                padding: 20px;
                height: 400px;
                overflow-y: scroll;
                margin-bottom: 20px;
                background-color: #ffffff;
                box-shadow: 0 2px 5px rgba(0, 0, 0, 0.1);
            }

            .controls-area {
                background: white;
                padding: 15px;
                border-radius: 8px;
                box-shadow: 0 2px 5px rgba(0, 0, 0, 0.1);
                display: flex;
                flex-direction: column;
                gap: 10px;
            }

            .input-row {
                display: flex;
                gap: 10px;
                align-items: center;
            }

            input[type="text"] {
                padding: 10px;
                border: 1px solid #ddd;
                border-radius: 4px;
                font-size: 14px;
            }

            #username {
                width: 120px;
            }

            #message {
                flex-grow: 1;
            }

            #gif-search-input {
                width: 100%;
                box-sizing: border-box;
                margin-bottom: 10px;
            }

            button {
                padding: 10px 15px;
                color: white;
                border: none;
                border-radius: 4px;
                cursor: pointer;
                font-weight: bold;
                transition: background 0.2s;
            }

            #sendBtn {
                background-color: #007bff;
            }

            #sendBtn:hover {
                background-color: #0056b3;
            }

            #connectBtn {
                background-color: #28a745;
            }

            #connectBtn:hover {
                background-color: #218838;
            }

            #disconnectBtn {
                background-color: #dc3545;
                display: none;
            }

            #disconnectBtn:hover {
                background-color: #c82333;
            }

            #gifBtn {
                background-color: #6f42c1;
            }

            #gifBtn:hover {
                background-color: #59359a;
            }

            button:disabled {
                background-color: #ccc;
                cursor: not-allowed;
            }

            .message {
                margin-bottom: 10px;
                padding: 8px 12px;
                border-radius: 12px;
                border-bottom: 1px solid #f1f1f1;
                animation: fadeIn 0.3s ease;
            }

            .message strong {
                color: #555;
                display: block;
                font-size: 0.8em;
                margin-bottom: 2px;
            }

            .system-message {
                color: #888;
                font-style: italic;
                text-align: center;
                border: none;
            }

            .chat-image {
                max-width: 200px;
                border-radius: 8px;
                margin-top: 5px;
                cursor: pointer;
                transition: transform 0.2s;
            }

            .chat-image:hover {
                transform: scale(1.05);
            }

            #status-bar {
                margin-bottom: 10px;
                font-weight: bold;
                text-align: right;
            }

            /* GIF Picker Styles */
            #gif-picker {
                display: none;
                position: absolute;
                bottom: 100px;
                /* Adjust based on layout */
                background: white;
                border: 1px solid #ccc;
                border-radius: 8px;
                padding: 10px;
                width: 320px;
                box-shadow: 0 4px 12px rgba(0, 0, 0, 0.2);
                z-index: 1000;
            }

            .gif-grid {
                display: grid;
                grid-template-columns: repeat(3, 1fr);
                gap: 5px;
                max-height: 250px;
                overflow-y: auto;
            }

            .gif-item {
                width: 100%;
                height: 80px;
                object-fit: cover;
                border-radius: 4px;
                cursor: pointer;
                border: 2px solid transparent;
            }

            .gif-item:hover {
                border-color: #6f42c1;
                opacity: 0.8;
            }

            .close-gif {
                float: right;
                cursor: pointer;
                font-size: 18px;
                color: #888;
            }

            @keyframes fadeIn {
                from {
                    opacity: 0;
                    transform: translateY(5px);
                }

                to {
                    opacity: 1;
                    transform: translateY(0);
                }
            }
        </style>
    </head>

    <body>
        <h1>CHITCHAT</h1>

        <div id="status-bar">Status: <span id="connection-status" style="color: red;">Disconnected</span></div>

        <div id="chat-container"></div>

        <div class="controls-area">
            <div class="input-row">
                <input type="text" id="username" placeholder="Username" value="Guest">
                <button id="connectBtn" onclick="connect()">Connect</button>
                <button id="disconnectBtn" onclick="disconnect()">Disconnect</button>
            </div>

            <div class="input-row" style="position: relative;">
                <input type="text" id="message" placeholder="Type a message..." disabled>
                <button id="gifBtn" onclick="toggleGifPicker()" disabled>GIF</button>
                <button id="sendBtn" onclick="sendMessage()" disabled>Send</button>

                <!-- GIF Picker Modal -->
                <div id="gif-picker">
                    <span class="close-gif" onclick="toggleGifPicker()">&times;</span>
                    <div style="margin-bottom: 10px; font-weight: bold; color: #555;">Pick a GIF</div>
                    <div class="gif-grid" id="gif-grid"></div>
                </div>
            </div>
        </div>

        <!-- Footer with Documentation Link -->
        <div style="text-align: center; margin-top: 30px; margin-bottom: 20px;">
            <a href="explanation.html" target="_blank" style="text-decoration: none;">
                <button
                    style="background-color: #0d1b2a; color: white; padding: 10px 20px; border-radius: 20px; border: none; cursor: pointer; font-size: 14px; box-shadow: 0 2px 5px rgba(0,0,0,0.2);">
                    📖 Documentation | Made by <strong>Riyoma</strong>
                </button>
            </a>
        </div>

        <script type="text/javascript">
            var ws;
            var chatContainer = document.getElementById("chat-container");
            var messageInput = document.getElementById("message");
            var sendBtn = document.getElementById("sendBtn");
            var connectBtn = document.getElementById("connectBtn");
            var disconnectBtn = document.getElementById("disconnectBtn");
            var usernameInput = document.getElementById("username");
            var statusDiv = document.getElementById("connection-status");
            var gifBtn = document.getElementById("gifBtn");
            var gifPicker = document.getElementById("gif-picker");

            // Tenor API Key setup
            // Note: 'LIVDSRZULELA' is a legacy public key that often works for small demos.
            // If it stops working, you will need to get a FREE API Key from https://tenor.com/developer/keyregistration
            const TENOR_API_KEY = "LIVDSRZULELA";
            const CLIENT_KEY = "ChatApp";

            function initGifs() {
                searchGifs("trending");
            }

            function searchGifs(query) {
                var grid = document.getElementById("gif-grid");
                grid.innerHTML = '<div style="text-align:center; padding:20px; color:#666;">Loading...</div>';

                // Using Tenor v1 API which often works with the legacy key
                var url = "https://g.tenor.com/v1/search?q=" + encodeURIComponent(query) + "&key=" + TENOR_API_KEY + "&limit=9";

                if (query === "trending") {
                    url = "https://g.tenor.com/v1/trending?key=" + TENOR_API_KEY + "&limit=9";
                }

                fetch(url)
                    .then(response => response.json())
                    .then(data => {
                        grid.innerHTML = "";
                        if (data.results && data.results.length > 0) {
                            data.results.forEach(result => {
                                // Tenor v1 structure: result.media[0].mediumgif.url
                                if (result.media && result.media.length > 0) {
                                    var gifUrl = result.media[0].mediumgif.url;
                                    var img = document.createElement("img");
                                    img.src = gifUrl;
                                    img.className = "gif-item";
                                    img.title = result.content_description || "GIF";
                                    img.onclick = function () { sendGif(gifUrl); };
                                    grid.appendChild(img);
                                }
                            });
                        } else {
                            grid.innerHTML = '<div style="text-align:center; padding:20px; color:#888;">No GIFs found :(</div>';
                        }
                    })
                    .catch(error => {
                        console.error("Error fetching GIFs:", error);
                        grid.innerHTML = '<div style="text-align:center; padding:20px; color:red; font-size:12px;">Failed to load GIFs.<br>Check API Key or Connection.</div>';
                        // Fallback to local static list
                        loadStaticFallback();
                    });
            }

            function loadStaticFallback() {
                var grid = document.getElementById("gif-grid");
                // Append fallback title
                var msg = document.createElement("div");
                msg.style.gridColumn = "1 / -1";
                msg.style.textAlign = "center";
                msg.style.color = "#888";
                msg.style.fontSize = "12px";
                msg.innerHTML = "Using offline fallbacks:";
                grid.appendChild(msg);

                const fallbackGifs = [
                    "https://media.giphy.com/media/v1.Y2lkPTc5MGI3NjExbXp4OXFxZnZ4Ynd6azFubGx4azFubGx4azFubGx4azFubGx4azFubGx4eSZlcD12MV9pbnRlcm5hbF9naWZfYnlfaWQmY3Q9Zw/3o7TKs6KSy8f7T8lC8/giphy.gif",
                    "https://media.giphy.com/media/l0HlHFRbmaZtBRhXG/giphy.gif",
                    "https://media.giphy.com/media/3o7abKhOpu0NwenH3O/giphy.gif",
                    "https://media.giphy.com/media/26AHONQ79FdWZhAI0/giphy.gif",
                    "https://media.giphy.com/media/l2JhtJsLSxhp9n5bG/giphy.gif"
                ];
                fallbackGifs.forEach(function (url) {
                    var img = document.createElement("img");
                    img.src = url;
                    img.className = "gif-item";
                    img.onclick = function () { sendGif(url); };
                    grid.appendChild(img);
                });
            }

            // Auto-run init
            initGifs();

            function connect() {
                var protocol = window.location.protocol === "https:" ? "wss://" : "ws://";
                var host = window.location.host;
                var pathname = window.location.pathname;
                var contextPath = pathname.substring(0, pathname.lastIndexOf("/"));
                var wsUrl = protocol + host + contextPath + "/chat";
                if (wsUrl.includes("//chat")) wsUrl = wsUrl.replace("//chat", "/chat");

                console.log("Connecting to: " + wsUrl);

                ws = new WebSocket(wsUrl);

                ws.onopen = function (event) {
                    statusDiv.innerHTML = "Connected";
                    statusDiv.style.color = "green";
                    messageInput.disabled = false;
                    sendBtn.disabled = false;
                    gifBtn.disabled = false;
                    connectBtn.style.display = "none";
                    disconnectBtn.style.display = "inline-block";
                    usernameInput.disabled = true;
                    addMessage("System", "You have joined the chat.");
                };

                ws.onmessage = function (event) {
                    var msg = event.data;
                    // Check if it's a rate limit system message
                    if (msg.startsWith("System: 🚫")) {
                        alert(msg.replace("System: ", ""));
                        return;
                    }

                    var parts = msg.split(": ", 2);
                    if (parts.length > 1) {
                        addMessage(parts[0], msg.substring(parts[0].length + 2));
                    } else {
                        addMessage("Unknown", msg);
                    }
                };

                ws.onclose = function (event) {
                    setDisconnectedState();
                };

                ws.onerror = function (event) {
                    console.error("WebSocket error:", event);
                    statusDiv.innerHTML = "Error";
                    statusDiv.style.color = "red";
                };
            }

            function disconnect() {
                if (ws) {
                    ws.close();
                }
            }

            function setDisconnectedState() {
                statusDiv.innerHTML = "Disconnected";
                statusDiv.style.color = "red";
                messageInput.disabled = true;
                sendBtn.disabled = true;
                gifBtn.disabled = true;
                connectBtn.style.display = "inline-block";
                disconnectBtn.style.display = "none";
                usernameInput.disabled = false;
                gifPicker.style.display = "none";
            }

            function sendMessage() {
                var username = usernameInput.value.trim();
                var message = messageInput.value.trim();

                if (message && ws && ws.readyState === WebSocket.OPEN) {
                    ws.send(username + ": " + message);
                    messageInput.value = "";
                }
            }

            function sendGif(url) {
                var username = usernameInput.value.trim();
                if (ws && ws.readyState === WebSocket.OPEN) {
                    ws.send(username + ": [GIF]" + url);
                    toggleGifPicker();
                }
            }

            function toggleGifPicker() {
                if (gifPicker.style.display === "block") {
                    gifPicker.style.display = "none";
                } else {
                    gifPicker.style.display = "block";
                    // Optionally focus input
                    setTimeout(() => document.getElementById("gif-search-input").focus(), 100);
                }
            }

            function handleGifSearch(e) {
                if (e.key === "Enter") {
                    var query = e.target.value.trim();
                    searchGifs(query);
                }
            }

            function addMessage(user, text) {
                var div = document.createElement("div");
                div.className = "message";

                var contentHtml = text;

                if (text.startsWith("[GIF]")) {
                    var url = text.substring(5);
                    contentHtml = '<br><img src="' + url + '" class="chat-image">';
                }
                else if (text.match(/\.(jpeg|jpg|gif|png)$/) != null) {
                    contentHtml = '<br><img src="' + text + '" class="chat-image">';
                }

                div.innerHTML = "<strong>" + user + "</strong> " + contentHtml;
                chatContainer.appendChild(div);
                chatContainer.scrollTo({ top: chatContainer.scrollHeight, behavior: 'smooth' });
            }

            messageInput.addEventListener("keypress", function (event) {
                if (event.key === "Enter") {
                    sendMessage();
                }
            });
        </script>
    </body>

    </html>