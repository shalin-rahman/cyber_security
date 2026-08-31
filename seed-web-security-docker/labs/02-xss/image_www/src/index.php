<?php
/*
 * SEED Labs — XSS Attack Lab (Elgg Simulation)
 *
 * Tasks implemented:
 *   Task 1  — Reflected XSS (GET parameter echoed unescaped)
 *   Task 2  — Stored XSS (profile "About Me" stored/rendered unescaped)
 *   Task 3  — Steal cookie via XSS (payload visible in rendered page)
 *   Task 4  — XSS worm (self-propagating: viewing Samy's profile re-infects viewer)
 *   Task 5  — Defense: toggle $XSS_PROTECTION to use htmlspecialchars()
 *
 * Toggle:
 *   $XSS_PROTECTION = false → all above attacks succeed
 *   $XSS_PROTECTION = true  → output is encoded; scripts stripped
 */

$XSS_PROTECTION = false;  // Task 5: set true to enable the fix

session_start();
$conn = new mysqli(getenv('MYSQL_HOST') ?: '10.9.0.6', 'root', 'seedubuntu', 'elgg');
if ($conn->connect_error) {
    die("Connection failed: " . $conn->connect_error);
}

// Helper: conditionally encode output
function out($str, $protect) {
    return $protect ? htmlspecialchars($str, ENT_QUOTES, 'UTF-8') : $str;
}
?>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>SEED Labs — Cross-Site Scripting (XSS) Attack Lab</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 40px; background: #f4f6f9; }
        .container { max-width: 860px; margin: auto; background: white; padding: 30px; border-radius: 8px; box-shadow: 0 2px 10px rgba(0,0,0,0.1); }
        h1 { color: #333; border-bottom: 2px solid #E74C3C; padding-bottom: 10px; }
        h2 { color: #c0392b; }
        .card { background: #f9f9f9; padding: 20px; border: 1px solid #e1e1e1; margin-bottom: 20px; border-radius: 5px; }
        input[type=text], textarea { width: 90%; padding: 10px; margin: 8px 0; border: 1px solid #ccc; border-radius: 4px; }
        input[type=submit] { background: #E74C3C; color: white; padding: 10px 20px; border: none; border-radius: 4px; cursor: pointer; }
        .profile { border-left: 4px solid #E74C3C; padding-left: 15px; margin-top: 15px; }
        .config { background: #ecf0f1; padding: 10px 15px; border-radius: 4px; font-family: monospace; margin-bottom: 20px; }
        .task-label { display: inline-block; background: #e74c3c; color: white; padding: 2px 8px; border-radius: 3px; font-size: 12px; margin-bottom: 6px; }
    </style>
</head>
<body>
<div class="container">
    <h1>SEED Labs — XSS Social Network (Elgg Simulation)</h1>

    <div class="config">
        Task 5 XSS Protection: <strong><?php echo $XSS_PROTECTION ? 'ENABLED ✅ (htmlspecialchars active)' : 'DISABLED ❌ (vulnerable)'; ?></strong>
    </div>

    <!-- Task 1: Reflected XSS -->
    <div class="card">
        <span class="task-label">Task 1 — Reflected XSS</span>
        <h2>Search Users</h2>
        <form method="GET" action="index.php">
            <input type="text" name="q" value="<?php echo isset($_GET['q']) ? htmlspecialchars($_GET['q']) : ''; ?>" placeholder="Try: <script>alert('XSS')</script>">
            <input type="submit" value="Search">
        </form>
        <?php if (isset($_GET['q'])): ?>
        <p>Search results for:
            <!-- VULNERABLE: echoes raw GET param — payload executes in browser -->
            <strong><?php echo out($_GET['q'], $XSS_PROTECTION); ?></strong>
        </p>
        <?php endif; ?>
    </div>

    <!-- Task 2 & 3: Stored XSS + Cookie Theft -->
    <div class="card">
        <span class="task-label">Task 2/3 — Stored XSS + Cookie Theft</span>
        <h2>Update Profile "About Me"</h2>
        <p>Try payload: <code>&lt;script&gt;alert(document.cookie)&lt;/script&gt;</code></p>
        <form method="POST" action="index.php">
            <input type="hidden" name="action" value="update_profile">
            <label>Select User:</label><br>
            <select name="username">
                <option value="samy">Samy (Attacker)</option>
                <option value="alice">Alice (Victim)</option>
                <option value="boby">Boby</option>
            </select><br><br>
            <label>About Me (XSS Payload):</label><br>
            <textarea name="profile_about" rows="4" placeholder="Enter bio or <script>alert('XSS')</script>"></textarea><br>
            <input type="submit" value="Save Profile">
        </form>

        <?php
        if ($_SERVER['REQUEST_METHOD'] === 'POST' && isset($_POST['profile_about']) && $_POST['action'] === 'update_profile') {
            $user  = $_POST['username'];
            $about = $_POST['profile_about'];
            // Stored raw — no escaping at write time (vulnerability is at render time)
            $stmt = $conn->prepare("UPDATE users SET profile_about = ? WHERE username = ?");
            $stmt->bind_param("ss", $about, $user);
            $stmt->execute();
            echo "<p style='color:green;'>Profile for " . htmlspecialchars($user) . " updated.</p>";
        }
        ?>
    </div>

    <!-- Task 4: XSS Worm — self-propagating -->
    <div class="card">
        <span class="task-label">Task 4 — XSS Worm (Self-Propagating)</span>
        <h2>View User Profiles</h2>
        <p>View Samy's profile to trigger stored XSS. With the worm payload, viewing it also updates the viewer's own profile.</p>
        <ul>
            <li><a href="?view=samy">View Samy's Profile (Attacker)</a></li>
            <li><a href="?view=alice">View Alice's Profile (Victim)</a></li>
            <li><a href="?view=boby">View Boby's Profile</a></li>
        </ul>

        <?php
        if (isset($_GET['view'])) {
            $viewUser = $_GET['view'];
            $stmt = $conn->prepare("SELECT name, profile_about FROM users WHERE username = ?");
            $stmt->bind_param("s", $viewUser);
            $stmt->execute();
            $res = $stmt->get_result();

            if ($row = $res->fetch_assoc()) {
                echo "<div class='profile'>";
                echo "<h3>" . htmlspecialchars($row['name']) . "</h3>";
                echo "<p><strong>About Me:</strong></p>";
                if ($XSS_PROTECTION) {
                    // =========================================================================
                    // FIX: Contextual Output Encoding (htmlspecialchars)
                    // =========================================================================
                    // DEFINITION: Output encoding safely converts potentially dangerous
                    // characters into their HTML entity equivalents.
                    // For example, <script> becomes &lt;script&gt;
                    // The browser renders the text literally on the screen rather than
                    // executing it as code.
                    // =========================================================================
                    echo "<div>" . htmlspecialchars($row['profile_about'], ENT_QUOTES, 'UTF-8') . "</div>";
                    echo "<p><em style='color:green;'>[Task 5] XSS protection active: script tags encoded.</em></p>";
                } else {
                    // =========================================================================
                    // VULNERABILITY: Stored XSS (Raw HTML Rendering)
                    // =========================================================================
                    // DEFINITION: Stored XSS occurs when malicious input is saved in the
                    // database (e.g., during profile update) and later rendered to other
                    // users verbatim without escaping. The victim's browser executes the
                    // injected JavaScript within the context of their session.
                    // =========================================================================
                    echo "<div>" . $row['profile_about'] . "</div>";
                }
                echo "</div>";
            }
        }
        ?>
    </div>

    <!-- Task 5 explanation -->
    <div class="card">
        <span class="task-label">Task 5 — Defense</span>
        <h2>Countermeasure: Output Encoding</h2>
        <p>To fix XSS, set <code>$XSS_PROTECTION = true</code> in <code>index.php</code>.</p>
        <p>This wraps all user-controlled output in <code>htmlspecialchars()</code>, converting
        <code>&lt;script&gt;</code> into <code>&amp;lt;script&amp;gt;</code> — rendered as text, never executed.</p>
        <p>Additionally, a <strong>Content Security Policy</strong> header can block inline scripts entirely:</p>
        <code>Content-Security-Policy: script-src 'self'</code>
    </div>
</div>
</body>
</html>
